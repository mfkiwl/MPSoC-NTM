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

module ntm_write_heads_testbench;

  ///////////////////////////////////////////////////////////////////////
  // Types
  ///////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////
  // Constants
  ///////////////////////////////////////////////////////////////////////

  // SYSTEM-SIZE
  parameter DATA_SIZE=512;
  parameter INDEX_SIZE=512;

  parameter X=64;
  parameter Y=64;
  parameter N=64;
  parameter W=64;
  parameter L=64;
  parameter R=64;

  ///////////////////////////////////////////////////////////////////////
  // Signals
  ///////////////////////////////////////////////////////////////////////

  // GLOBAL
  wire CLK;
  wire RST;

  // WRITING
  // CONTROL
  wire start_writing;
  wire ready_writing;

  wire m_in_j_enable_writing;
  wire m_in_k_enable_writing;

  wire a_in_enable_writing;

  wire a_out_enable_writing;

  wire m_out_j_enable_writing;
  wire m_out_k_enable_writing;

  // DATA
  wire [DATA_SIZE-1:0] size_n_in_writing;
  wire [DATA_SIZE-1:0] size_w_in_writing;

  wire [DATA_SIZE-1:0] m_in_writing;
  wire [DATA_SIZE-1:0] a_in_writing;
  wire [DATA_SIZE-1:0] w_in_writing;

  wire [DATA_SIZE-1:0] m_out_writing;

  // ERASING
  // CONTROL
  wire start_erasing;
  wire ready_erasing;

  wire m_in_j_enable_erasing;
  wire m_in_k_enable_erasing;
  
  wire e_in_enable_erasing;
  
  wire e_out_enable_erasing;
  
  wire m_out_j_enable_erasing;
  wire m_out_k_enable_erasing;

  // DATA
  wire [DATA_SIZE-1:0] size_n_in_erasing;
  wire [DATA_SIZE-1:0] size_w_in_erasing;

  wire [DATA_SIZE-1:0] m_in_erasing;
  wire [DATA_SIZE-1:0] e_in_erasing;
  wire [DATA_SIZE-1:0] w_in_erasing;

  wire [DATA_SIZE-1:0] m_out_erasing;

  ///////////////////////////////////////////////////////////////////////
  // Body
  ///////////////////////////////////////////////////////////////////////

  // STIMULUS
  ntm_write_heads_stimulus #(
    // SYSTEM-SIZE
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE),

    .X(X),
    .Y(Y),
    .N(N),
    .W(W),
    .L(L),
    .R(R)
  )
  write_heads_stimulus(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .NTM_WRITE_HEADS_START(start_writing),
    .NTM_WRITE_HEADS_READY(ready_writing),

    .NTM_WRITE_HEADS_M_IN_J_ENABLE(m_in_j_enable_writing),
    .NTM_WRITE_HEADS_M_IN_K_ENABLE(m_in_k_enable_writing),

    .NTM_WRITE_HEADS_A_IN_ENABLE(a_in_enable_writing),

    .NTM_WRITE_HEADS_A_OUT_ENABLE(a_out_enable_writing),

    .NTM_WRITE_HEADS_M_OUT_J_ENABLE(m_out_j_enable_writing),
    .NTM_WRITE_HEADS_M_OUT_K_ENABLE(m_out_k_enable_writing),

    // DATA
    .NTM_WRITE_HEADS_SIZE_N_IN(size_n_in_writing),
    .NTM_WRITE_HEADS_SIZE_W_IN(size_w_in_writing),
    .NTM_WRITE_HEADS_M_IN(m_in_writing),
    .NTM_WRITE_HEADS_A_IN(a_in_writing),
    .NTM_WRITE_HEADS_W_IN(w_in_writing),
    .NTM_WRITE_HEADS_M_OUT(m_out_writing)
  );

  // WRITING
  ntm_writing #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  writing(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_writing),
    .READY(ready_writing),

    .M_IN_J_ENABLE(m_in_j_enable_writing),
    .M_IN_K_ENABLE(m_in_k_enable_writing),

    .A_IN_ENABLE(a_in_enable_writing),

    .A_OUT_ENABLE(a_out_enable_writing),

    .M_OUT_J_ENABLE(m_out_j_enable_writing),
    .M_OUT_K_ENABLE(m_out_k_enable_writing),

    // DATA
    .SIZE_N_IN(size_n_in_writing),
    .SIZE_W_IN(size_w_in_writing),

    .M_IN(m_in_writing),
    .A_IN(a_in_writing),
    .W_IN(w_in_writing),

    .M_OUT(m_out_writing)
  );

  // ERASING
  ntm_erasing #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  erasing(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_erasing),
    .READY(ready_erasing),
    
    .M_IN_J_ENABLE(m_in_j_enable_erasing),
    .M_IN_K_ENABLE(m_in_k_enable_erasing),

    .E_IN_ENABLE(e_in_enable_erasing),

    .E_OUT_ENABLE(e_out_enable_erasing),

    .M_OUT_J_ENABLE(m_out_j_enable_erasing),
    .M_OUT_K_ENABLE(m_out_k_enable_erasing),

    // DATA
    .SIZE_N_IN(size_n_in_erasing),
    .SIZE_W_IN(size_w_in_erasing),

    .M_IN(m_in_erasing),
    .E_IN(e_in_erasing),
    .W_IN(w_in_erasing),

    .M_OUT(m_out_erasing)
  );

endmodule
