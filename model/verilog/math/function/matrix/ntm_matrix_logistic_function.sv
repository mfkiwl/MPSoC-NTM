////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              Peripheral-NTM for MPSoC                                      //
//              Neural Turing Machine for MPSoC                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020-2021 by the author(s)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////
// Author(s):
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

module ntm_matrix_logistic_function #(
  parameter DATA_SIZE=128,
  parameter CONTROL_SIZE=64
)
  (
    // GLOBAL
    input CLK,
    input RST,

    // CONTROL
    input START,
    output reg READY,

    input DATA_IN_I_ENABLE,
    input DATA_IN_J_ENABLE,
    output reg DATA_OUT_I_ENABLE,
    output reg DATA_OUT_J_ENABLE,

    // DATA
    input [DATA_SIZE-1:0] SIZE_I_IN,
    input [DATA_SIZE-1:0] SIZE_J_IN,
    input [DATA_SIZE-1:0] DATA_IN,
    output reg [DATA_SIZE-1:0] DATA_OUT
  );

  ///////////////////////////////////////////////////////////////////////
  // Types
  ///////////////////////////////////////////////////////////////////////

  parameter [2:0] STARTER_STATE = 0;
  parameter [2:0] INPUT_I_STATE = 1;
  parameter [2:0] INPUT_J_STATE = 2;
  parameter [2:0] ENDER_STATE = 3;

  ///////////////////////////////////////////////////////////////////////
  // Constants
  ///////////////////////////////////////////////////////////////////////

  parameter ZERO_CONTROL  = 0;
  parameter ONE_CONTROL   = 1;
  parameter TWO_CONTROL   = 2;
  parameter THREE_CONTROL = 3;

  parameter ZERO_DATA  = 0;
  parameter ONE_DATA   = 1;
  parameter TWO_DATA   = 2;
  parameter THREE_DATA = 3;

  parameter FULL  = 1;
  parameter EMPTY = 0;

  parameter EULER = 0;

  ///////////////////////////////////////////////////////////////////////
  // Signals
  ///////////////////////////////////////////////////////////////////////

  // Finite State Machine
  reg [1:0] logistic_ctrl_fsm_int;

  // Internal Signals
  reg [CONTROL_SIZE-1:0] index_i_loop;
  reg [CONTROL_SIZE-1:0] index_j_loop;

  // VECTOR LOGISTIC
  // CONTROL
  reg start_vector_logistic;
  wire ready_vector_logistic;
  reg data_in_enable_vector_logistic;
  wire data_out_enable_vector_logistic;

  // DATA
  reg [DATA_SIZE-1:0] size_in_vector_logistic;
  reg [DATA_SIZE-1:0] data_in_vector_logistic;
  wire [DATA_SIZE-1:0] data_out_vector_logistic;

  ///////////////////////////////////////////////////////////////////////
  // Body
  ///////////////////////////////////////////////////////////////////////

  // CONTROL
  always @(posedge CLK or posedge RST) begin
    if(RST == 1'b0) begin
      // Data Outputs
      DATA_OUT <= ZERO_DATA;

      // Control Outputs
      READY <= 1'b0;

      // Assignations
      index_i_loop <= ZERO_DATA;
      index_j_loop <= ZERO_DATA;
    end
    else begin
      case(logistic_ctrl_fsm_int)
        STARTER_STATE : begin  // STEP 0
          // Control Outputs
          READY <= 1'b0;

          if(START == 1'b1) begin
            // Assignations
            index_i_loop <= ZERO_DATA;
            index_j_loop <= ZERO_DATA;

            // FSM Control
            logistic_ctrl_fsm_int <= INPUT_I_STATE;
          end
        end
        INPUT_I_STATE : begin  // STEP 1
          if(DATA_IN_I_ENABLE == 1'b1) begin
            // Data Inputs
            data_in_vector_logistic <= DATA_IN;

            if(index_i_loop == ZERO_DATA) begin
              // Control Internal
              start_vector_logistic <= 1'b1;
            end

            data_in_enable_vector_logistic <= 1'b1;

            // FSM Control
            logistic_ctrl_fsm_int <= ENDER_STATE;
          end
          else begin
            // Control Internal
            data_in_enable_vector_logistic <= 1'b0;
          end

          // Control Outputs
          DATA_OUT_I_ENABLE <= 1'b0;
          DATA_OUT_J_ENABLE <= 1'b0;
        end
        INPUT_J_STATE : begin  // STEP 2
          if(DATA_IN_J_ENABLE == 1'b1) begin
            // Data Inputs
            size_in_vector_logistic <= SIZE_J_IN;
            data_in_vector_logistic <= DATA_IN;

            if(index_j_loop == ZERO_DATA) begin
              // Control Internal
              start_vector_logistic <= 1'b1;
            end

            data_in_enable_vector_logistic <= 1'b1;

            // FSM Control
            logistic_ctrl_fsm_int <= ENDER_STATE;
          end
          else begin
            // Control Internal
            data_in_enable_vector_logistic <= 1'b0;
          end

          // Control Outputs
          DATA_OUT_J_ENABLE <= 1'b0;
        end
        ENDER_STATE : begin  // STEP 3
          if(ready_vector_logistic == 1'b1) begin
            if((index_i_loop == (SIZE_I_IN - ONE_CONTROL)) && index_j_loop == (SIZE_J_IN - ONE_CONTROL)) begin
              // Control Outputs
              READY <= 1'b1;
              DATA_OUT_J_ENABLE <= 1'b1;

              // FSM Control
              logistic_ctrl_fsm_int <= STARTER_STATE;
            end
            else if((index_i_loop < (SIZE_I_IN - ONE_CONTROL)) && index_j_loop == (SIZE_J_IN - ONE_CONTROL)) begin
              // Control Internal
              index_i_loop <= (index_i_loop + ONE_CONTROL);
              index_j_loop <= ZERO_DATA;

              // Control Outputs
              DATA_OUT_I_ENABLE <= 1'b1;
              DATA_OUT_J_ENABLE <= 1'b1;

              // FSM Control
              logistic_ctrl_fsm_int <= INPUT_I_STATE;
            end
            else if((index_i_loop < (SIZE_I_IN - ONE_CONTROL)) && index_j_loop < (SIZE_J_IN - ONE_CONTROL)) begin
              // Control Internal
              index_j_loop <= (index_j_loop + ONE_CONTROL);

              // Control Outputs
              DATA_OUT_J_ENABLE <= 1'b1;

              // FSM Control
              logistic_ctrl_fsm_int <= INPUT_J_STATE;
            end
            // Data Outputs
            DATA_OUT <= data_out_vector_logistic;
          end
          else begin
            // Control Internal
            start_vector_logistic <= 1'b0;
          end
        end
        default : begin
          // FSM Control
          logistic_ctrl_fsm_int <= STARTER_STATE;
        end
      endcase
    end
  end

  // VECTOR LOGISTIC
  ntm_vector_logistic_function #(
    .DATA_SIZE(DATA_SIZE),
    .CONTROL_SIZE(CONTROL_SIZE)
  )
  vector_logistic_function(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_logistic),
    .READY(ready_vector_logistic),

    .DATA_IN_ENABLE(data_in_enable_vector_logistic),
    .DATA_OUT_ENABLE(data_out_enable_vector_logistic),

    // DATA
    .SIZE_IN(size_in_vector_logistic),
    .DATA_IN(data_in_vector_logistic),
    .DATA_OUT(data_out_vector_logistic)
  );

endmodule
