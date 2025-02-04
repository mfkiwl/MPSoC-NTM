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

module ntm_scalar_modular_inverter #(
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

    // DATA
    input [DATA_SIZE-1:0] MODULO_IN,
    input [DATA_SIZE-1:0] DATA_IN,
    output reg [DATA_SIZE-1:0] DATA_OUT
  );

  ///////////////////////////////////////////////////////////////////////
  // Types
  ///////////////////////////////////////////////////////////////////////

  parameter [2:0] STARTER_STATE = 0;
  parameter [2:0] ENDER_STATE = 1;
  parameter [2:0] CHECK_U_STATE = 2;
  parameter [2:0] CHECK_V_STATE = 3;
  parameter [2:0] CHECK_D_STATE = 4;

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
  reg [2:0] inverter_ctrl_fsm_int;

  // Internal Signals
  reg [DATA_SIZE:0] u_int;
  reg [DATA_SIZE:0] v_int;
  reg [DATA_SIZE:0] x_int;
  reg [DATA_SIZE:0] y_int;

  ///////////////////////////////////////////////////////////////////////
  // Body
  ///////////////////////////////////////////////////////////////////////

  // 1 = DATA_OUT · DATA_IN mod MODULO_IN

  // CONTROL
  always @(posedge CLK or posedge RST) begin
    if(RST == 1'b0) begin
      // Data Outputs
      DATA_OUT <= ZERO_DATA;

      // Control Outputs
      READY <= 1'b0;

      // Assignation
      u_int <= ZERO_DATA;
      v_int <= ZERO_DATA;
      x_int <= ZERO_DATA;
      y_int <= ZERO_DATA;
    end
    else begin
      case(inverter_ctrl_fsm_int)
        STARTER_STATE : begin  // STEP 0
          // Control Outputs
          READY <= 1'b0;

          if(START == 1'b1) begin
            // Assignation
            u_int <= {1'b0,DATA_IN};
            v_int <= {1'b0,MODULO_IN};

            x_int <= ONE_CONTROL;
            y_int <= ZERO_DATA;

            // FSM Control
            inverter_ctrl_fsm_int <= ENDER_STATE;
          end
        end
        ENDER_STATE : begin  // STEP 1
          if(u_int == ONE_CONTROL) begin
            if(x_int < {1'b0,MODULO_IN}) begin
              // Data Outputs
              DATA_OUT <= x_int[DATA_SIZE-1:0];

              // Control Outputs
              READY <= 1'b1;

              // FSM Control
              inverter_ctrl_fsm_int <= STARTER_STATE;
            end
            else begin
              // Assignations
              x_int <= (x_int - {1'b0,MODULO_IN});
            end
          end
          else if(v_int == ONE_CONTROL) begin
            if(y_int < {1'b0,MODULO_IN}) begin
              // Data Outputs
              DATA_OUT <= y_int[DATA_SIZE-1:0];

              // Control Outputs
              READY <= 1'b1;

              // FSM Control
              inverter_ctrl_fsm_int <= STARTER_STATE;
            end
            else begin
              // Assignations
              y_int <= (y_int - {1'b0,MODULO_IN});
            end
          end
          else if(u_int[0] == 1'b0) begin
            // FSM Control
            inverter_ctrl_fsm_int <= CHECK_U_STATE;
          end
          else if(v_int[0] == 1'b0) begin
            // FSM Control
            inverter_ctrl_fsm_int <= CHECK_V_STATE;
          end
          else begin
            // FSM Control
            inverter_ctrl_fsm_int <= CHECK_D_STATE;
          end
        end
        CHECK_U_STATE : begin  // STEP 2
          // Assignation
          u_int <= u_int;
          if(x_int[0] == 1'b0) begin
            x_int <= x_int;
          end
          else begin
            x_int <= (x_int + {1'b0,MODULO_IN});
          end
          // FSM Control
          if(v_int[0] == 1'b0) begin
            inverter_ctrl_fsm_int <= CHECK_V_STATE;
          end
          else begin
            inverter_ctrl_fsm_int <= CHECK_D_STATE;
          end
        end
        CHECK_V_STATE : begin  // STEP 3
          // Assignation
          v_int <= v_int;
          if(y_int[0] == 1'b0) begin
            y_int <= y_int;
          end
          else begin
            y_int <= (y_int + {1'b0,MODULO_IN});
          end
          // FSM Control
          inverter_ctrl_fsm_int <= CHECK_D_STATE;
        end
        CHECK_D_STATE : begin  // STEP 4
          // Assignation
          if(u_int < v_int) begin
            v_int <= (v_int - u_int);
            if(y_int > x_int) begin
              y_int <= (y_int - x_int);
            end
            else begin
              y_int <= (y_int - x_int + {1'b0,MODULO_IN});
            end
          end
          else begin
            u_int <= (u_int - v_int);
            if(x_int > y_int) begin
              x_int <= (x_int - y_int);
            end
            else begin
              x_int <= (x_int - y_int + {1'b0,MODULO_IN});
            end
          end
          // FSM Control
          inverter_ctrl_fsm_int <= ENDER_STATE;
        end
        default : begin
          // FSM Control
          inverter_ctrl_fsm_int <= STARTER_STATE;
        end
      endcase
    end
  end

endmodule
