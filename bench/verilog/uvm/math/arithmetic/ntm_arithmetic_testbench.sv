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

module ntm_arithmetic_testbench;

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

  // SCALAR-FUNCTIONALITY
  parameter STIMULUS_NTM_SCALAR_MOD_TEST           = 0;
  parameter STIMULUS_NTM_SCALAR_ADDER_TEST         = 0;
  parameter STIMULUS_NTM_SCALAR_MULTIPLIER_TEST    = 0;
  parameter STIMULUS_NTM_SCALAR_INVERTER_TEST      = 0;
  parameter STIMULUS_NTM_SCALAR_DIVIDER_TEST       = 0;
  parameter STIMULUS_NTM_SCALAR_EXPONENTIATOR_TEST = 0;
  parameter STIMULUS_NTM_SCALAR_LCM_TEST          = 0;
  parameter STIMULUS_NTM_SCALAR_GCD_TEST     = 0;

  parameter STIMULUS_NTM_SCALAR_MOD_CASE_0           = 0;
  parameter STIMULUS_NTM_SCALAR_ADDER_CASE_0         = 0;
  parameter STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_0    = 0;
  parameter STIMULUS_NTM_SCALAR_INVERTER_CASE_0      = 0;
  parameter STIMULUS_NTM_SCALAR_DIVIDER_CASE_0       = 0;
  parameter STIMULUS_NTM_SCALAR_EXPONENTIATOR_CASE_0 = 0;
  parameter STIMULUS_NTM_SCALAR_LCM_CASE_0          = 0;
  parameter STIMULUS_NTM_SCALAR_GCD_CASE_0     = 0;

  parameter STIMULUS_NTM_SCALAR_MOD_CASE_1           = 0;
  parameter STIMULUS_NTM_SCALAR_ADDER_CASE_1         = 0;
  parameter STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_1    = 0;
  parameter STIMULUS_NTM_SCALAR_INVERTER_CASE_1      = 0;
  parameter STIMULUS_NTM_SCALAR_DIVIDER_CASE_1       = 0;
  parameter STIMULUS_NTM_SCALAR_EXPONENTIATOR_CASE_1 = 0;
  parameter STIMULUS_NTM_SCALAR_LCM_CASE_1          = 0;
  parameter STIMULUS_NTM_SCALAR_GCD_CASE_1     = 0;

  // VECTOR-FUNCTIONALITY
  parameter STIMULUS_NTM_VECTOR_MOD_TEST           = 0;
  parameter STIMULUS_NTM_VECTOR_ADDER_TEST         = 0;
  parameter STIMULUS_NTM_VECTOR_MULTIPLIER_TEST    = 0;
  parameter STIMULUS_NTM_VECTOR_INVERTER_TEST      = 0;
  parameter STIMULUS_NTM_VECTOR_DIVIDER_TEST       = 0;
  parameter STIMULUS_NTM_VECTOR_EXPONENTIATOR_TEST = 0;
  parameter STIMULUS_NTM_VECTOR_LCM_TEST          = 0;
  parameter STIMULUS_NTM_VECTOR_GCD_TEST     = 0;

  parameter STIMULUS_NTM_VECTOR_MOD_CASE_0           = 0;
  parameter STIMULUS_NTM_VECTOR_ADDER_CASE_0         = 0;
  parameter STIMULUS_NTM_VECTOR_MULTIPLIER_CASE_0    = 0;
  parameter STIMULUS_NTM_VECTOR_INVERTER_CASE_0      = 0;
  parameter STIMULUS_NTM_VECTOR_DIVIDER_CASE_0       = 0;
  parameter STIMULUS_NTM_VECTOR_EXPONENTIATOR_CASE_0 = 0;
  parameter STIMULUS_NTM_VECTOR_LCM_CASE_0          = 0;
  parameter STIMULUS_NTM_VECTOR_GCD_CASE_0     = 0;

  parameter STIMULUS_NTM_VECTOR_MOD_CASE_1           = 0;
  parameter STIMULUS_NTM_VECTOR_ADDER_CASE_1         = 0;
  parameter STIMULUS_NTM_VECTOR_MULTIPLIER_CASE_1    = 0;
  parameter STIMULUS_NTM_VECTOR_INVERTER_CASE_1      = 0;
  parameter STIMULUS_NTM_VECTOR_DIVIDER_CASE_1       = 0;
  parameter STIMULUS_NTM_VECTOR_EXPONENTIATOR_CASE_1 = 0;
  parameter STIMULUS_NTM_VECTOR_LCM_CASE_1          = 0;
  parameter STIMULUS_NTM_VECTOR_GCD_CASE_1     = 0;

  // MATRIX-FUNCTIONALITY
  parameter STIMULUS_NTM_MATRIX_MOD_TEST           = 0;
  parameter STIMULUS_NTM_MATRIX_ADDER_TEST         = 0;
  parameter STIMULUS_NTM_MATRIX_MULTIPLIER_TEST    = 0;
  parameter STIMULUS_NTM_MATRIX_INVERTER_TEST      = 0;
  parameter STIMULUS_NTM_MATRIX_DIVIDER_TEST       = 0;
  parameter STIMULUS_NTM_MATRIX_EXPONENTIATOR_TEST = 0;
  parameter STIMULUS_NTM_MATRIX_LCM_TEST          = 0;
  parameter STIMULUS_NTM_MATRIX_GCD_TEST     = 0;

  parameter STIMULUS_NTM_MATRIX_MOD_CASE_0           = 0;
  parameter STIMULUS_NTM_MATRIX_ADDER_CASE_0         = 0;
  parameter STIMULUS_NTM_MATRIX_MULTIPLIER_CASE_0    = 0;
  parameter STIMULUS_NTM_MATRIX_INVERTER_CASE_0      = 0;
  parameter STIMULUS_NTM_MATRIX_DIVIDER_CASE_0       = 0;
  parameter STIMULUS_NTM_MATRIX_EXPONENTIATOR_CASE_0 = 0;
  parameter STIMULUS_NTM_MATRIX_LCM_CASE_0          = 0;
  parameter STIMULUS_NTM_MATRIX_GCD_CASE_0     = 0;

  parameter STIMULUS_NTM_MATRIX_MOD_CASE_1           = 0;
  parameter STIMULUS_NTM_MATRIX_ADDER_CASE_1         = 0;
  parameter STIMULUS_NTM_MATRIX_MULTIPLIER_CASE_1    = 0;
  parameter STIMULUS_NTM_MATRIX_INVERTER_CASE_1      = 0;
  parameter STIMULUS_NTM_MATRIX_DIVIDER_CASE_1       = 0;
  parameter STIMULUS_NTM_MATRIX_EXPONENTIATOR_CASE_1 = 0;
  parameter STIMULUS_NTM_MATRIX_LCM_CASE_1          = 0;
  parameter STIMULUS_NTM_MATRIX_GCD_CASE_1     = 0;

  ///////////////////////////////////////////////////////////////////////
  // Signals
  ///////////////////////////////////////////////////////////////////////
  // GLOBAL
  wire CLK;
  wire RST;

  ///////////////////////////////////////////////////////////////////////
  // SCALAR
  ///////////////////////////////////////////////////////////////////////

  // SCALAR MOD
  // CONTROL
  wire start_scalar_mod;
  wire ready_scalar_mod;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_mod;
  wire [DATA_SIZE-1:0] data_in_scalar_mod;
  wire [DATA_SIZE-1:0] data_out_scalar_mod;

  // SCALAR ADDER
  // CONTROL
  wire start_scalar_adder;
  wire ready_scalar_adder;

  wire operation_scalar_adder;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_adder;
  wire [DATA_SIZE-1:0] data_a_in_scalar_adder;
  wire [DATA_SIZE-1:0] data_b_in_scalar_adder;
  wire [DATA_SIZE-1:0] data_out_scalar_adder;

  // SCALAR MULTIPLIER
  // CONTROL
  wire start_scalar_multiplier;
  wire ready_scalar_multiplier;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_multiplier;
  wire [DATA_SIZE-1:0] data_a_in_scalar_multiplier;
  wire [DATA_SIZE-1:0] data_b_in_scalar_multiplier;
  wire [DATA_SIZE-1:0] data_out_scalar_multiplier;

  // SCALAR INVERTER
  // CONTROL
  wire start_scalar_inverter;
  wire ready_scalar_inverter;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_inverter;
  wire [DATA_SIZE-1:0] data_in_scalar_inverter;
  wire [DATA_SIZE-1:0] data_out_scalar_inverter;

  // SCALAR DIVIDER
  // CONTROL
  wire start_scalar_divider;
  wire ready_scalar_divider;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_divider;
  wire [DATA_SIZE-1:0] data_a_in_scalar_divider;
  wire [DATA_SIZE-1:0] data_b_in_scalar_divider;
  wire [DATA_SIZE-1:0] data_out_scalar_divider;

  // SCALAR EXPONENTIATOR
  // CONTROL
  wire start_scalar_exponentiator;
  wire ready_scalar_exponentiator;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_exponentiator;
  wire [DATA_SIZE-1:0] data_a_in_scalar_exponentiator;
  wire [DATA_SIZE-1:0] data_b_in_scalar_exponentiator;
  wire [DATA_SIZE-1:0] data_out_scalar_exponentiator;

  // SCALAR LCM
  // CONTROL
  wire start_scalar_lcm;
  wire ready_scalar_lcm;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_lcm;
  wire [DATA_SIZE-1:0] data_a_in_scalar_lcm;
  wire [DATA_SIZE-1:0] data_b_in_scalar_lcm;
  wire [DATA_SIZE-1:0] data_out_scalar_lcm;

  // SCALAR GCD
  wire start_scalar_gcd;
  wire ready_scalar_gcd;

  // CONTROL
  // DATA
  wire [DATA_SIZE-1:0] modulo_in_scalar_gcd;
  wire [DATA_SIZE-1:0] data_a_in_scalar_gcd;
  wire [DATA_SIZE-1:0] data_b_in_scalar_gcd;
  wire [DATA_SIZE-1:0] data_out_scalar_gcd;

  ///////////////////////////////////////////////////////////////////////
  // VECTOR
  ///////////////////////////////////////////////////////////////////////

  // VECTOR MOD
  // CONTROL
  wire start_vector_mod;
  wire ready_vector_mod;

  wire data_in_enable_vector_mod;
  wire data_out_enable_vector_mod;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_mod;
  wire [DATA_SIZE-1:0] size_in_vector_mod;
  wire [DATA_SIZE-1:0] data_in_vector_mod;
  wire [DATA_SIZE-1:0] data_out_vector_mod;

  // VECTOR ADDER
  // CONTROL
  wire start_vector_adder;
  wire ready_vector_adder;

  wire operation_vector_adder;

  wire data_a_in_enable_vector_adder;
  wire data_b_in_enable_vector_adder;
  wire data_out_enable_vector_adder;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_adder;
  wire [DATA_SIZE-1:0] size_in_vector_adder;
  wire [DATA_SIZE-1:0] data_a_in_vector_adder;
  wire [DATA_SIZE-1:0] data_b_in_vector_adder;
  wire [DATA_SIZE-1:0] data_out_vector_adder;

  // VECTOR MULTIPLIER
  // CONTROL
  wire start_vector_multiplier;
  wire ready_vector_multiplier;

  wire data_a_in_enable_vector_multiplier;
  wire data_b_in_enable_vector_multiplier;
  wire data_out_enable_vector_multiplier;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_multiplier;
  wire [DATA_SIZE-1:0] size_in_vector_multiplier;
  wire [DATA_SIZE-1:0] data_a_in_vector_multiplier;
  wire [DATA_SIZE-1:0] data_b_in_vector_multiplier;
  wire [DATA_SIZE-1:0] data_out_vector_multiplier;

  // VECTOR INVERTER
  // CONTROL
  wire start_vector_inverter;
  wire ready_vector_inverter;

  wire data_in_enable_vector_inverter;
  wire data_out_enable_vector_inverter;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_inverter;
  wire [DATA_SIZE-1:0] size_in_vector_inverter;
  wire [DATA_SIZE-1:0] data_in_vector_inverter;
  wire [DATA_SIZE-1:0] data_out_vector_inverter;

  // VECTOR DIVIDER
  // CONTROL
  wire start_vector_divider;
  wire ready_vector_divider;

  wire data_a_in_enable_vector_divider;
  wire data_b_in_enable_vector_divider;
  wire data_out_enable_vector_divider;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_divider;
  wire [DATA_SIZE-1:0] size_in_vector_divider;
  wire [DATA_SIZE-1:0] data_a_in_vector_divider;
  wire [DATA_SIZE-1:0] data_b_in_vector_divider;
  wire [DATA_SIZE-1:0] data_out_vector_divider;

  // VECTOR EXPONENTIATOR
  // CONTROL
  wire start_vector_exponentiator;
  wire ready_vector_exponentiator;

  wire data_a_in_enable_vector_exponentiator;
  wire data_b_in_enable_vector_exponentiator;
  wire data_out_enable_vector_exponentiator;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_exponentiator;
  wire [DATA_SIZE-1:0] size_in_vector_exponentiator;
  wire [DATA_SIZE-1:0] data_a_in_vector_exponentiator;
  wire [DATA_SIZE-1:0] data_b_in_vector_exponentiator;
  wire [DATA_SIZE-1:0] data_out_vector_exponentiator;

  // VECTOR LCM
  // CONTROL
  wire start_vector_lcm;
  wire ready_vector_lcm;

  wire data_a_in_enable_vector_lcm;
  wire data_b_in_enable_vector_lcm;
  wire data_out_enable_vector_lcm;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_lcm;
  wire [DATA_SIZE-1:0] size_in_vector_lcm;
  wire [DATA_SIZE-1:0] data_a_in_vector_lcm;
  wire [DATA_SIZE-1:0] data_b_in_vector_lcm;
  wire [DATA_SIZE-1:0] data_out_vector_lcm;

  // VECTOR GCD
  // CONTROL
  wire start_vector_gcd;
  wire ready_vector_gcd;

  wire data_a_in_enable_vector_gcd;
  wire data_b_in_enable_vector_gcd;
  wire data_out_enable_vector_gcd;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_vector_gcd;
  wire [DATA_SIZE-1:0] size_in_vector_gcd;
  wire [DATA_SIZE-1:0] data_a_in_vector_gcd;
  wire [DATA_SIZE-1:0] data_b_in_vector_gcd;
  wire [DATA_SIZE-1:0] data_out_vector_gcd;

  ///////////////////////////////////////////////////////////////////////
  // MATRIX
  ///////////////////////////////////////////////////////////////////////
  // MATRIX MOD
  // CONTROL
  wire start_matrix_mod;
  wire ready_matrix_mod;

  wire data_in_i_enable_matrix_mod;
  wire data_in_j_enable_matrix_mod;
  wire data_out_i_enable_matrix_mod;
  wire data_out_j_enable_matrix_mod;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_mod;
  wire [DATA_SIZE-1:0] size_i_in_matrix_mod;
  wire [DATA_SIZE-1:0] size_j_in_matrix_mod;
  wire [DATA_SIZE-1:0] data_in_matrix_mod;
  wire [DATA_SIZE-1:0] data_out_matrix_mod;

  // MATRIX ADDER
  // CONTROL
  wire start_matrix_adder;
  wire ready_matrix_adder;

  wire operation_matrix_adder;

  wire data_a_in_i_enable_matrix_adder;
  wire data_a_in_j_enable_matrix_adder;
  wire data_b_in_i_enable_matrix_adder;
  wire data_b_in_j_enable_matrix_adder;
  wire data_out_i_enable_matrix_adder;
  wire data_out_j_enable_matrix_adder;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_adder;
  wire [DATA_SIZE-1:0] size_i_in_matrix_adder;
  wire [DATA_SIZE-1:0] size_j_in_matrix_adder;
  wire [DATA_SIZE-1:0] data_a_in_matrix_adder;
  wire [DATA_SIZE-1:0] data_b_in_matrix_adder;
  wire [DATA_SIZE-1:0] data_out_matrix_adder;

  // MATRIX MULTIPLIER
  // CONTROL
  wire start_matrix_multiplier;
  wire ready_matrix_multiplier;

  wire data_a_in_i_enable_matrix_multiplier;
  wire data_a_in_j_enable_matrix_multiplier;
  wire data_b_in_i_enable_matrix_multiplier;
  wire data_b_in_j_enable_matrix_multiplier;
  wire data_out_i_enable_matrix_multiplier;
  wire data_out_j_enable_matrix_multiplier;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_multiplier;
  wire [DATA_SIZE-1:0] size_i_in_matrix_multiplier;
  wire [DATA_SIZE-1:0] size_j_in_matrix_multiplier;
  wire [DATA_SIZE-1:0] data_a_in_matrix_multiplier;
  wire [DATA_SIZE-1:0] data_b_in_matrix_multiplier;
  wire [DATA_SIZE-1:0] data_out_matrix_multiplier;

  // MATRIX INVERTER
  // CONTROL
  wire start_matrix_inverter;
  wire ready_matrix_inverter;

  wire data_in_i_enable_matrix_inverter;
  wire data_in_j_enable_matrix_inverter;
  wire data_out_i_enable_matrix_inverter;
  wire data_out_j_enable_matrix_inverter;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_inverter;
  wire [DATA_SIZE-1:0] size_i_in_matrix_inverter;
  wire [DATA_SIZE-1:0] size_j_in_matrix_inverter;
  wire [DATA_SIZE-1:0] data_in_matrix_inverter;
  wire [DATA_SIZE-1:0] data_out_matrix_inverter;

  // MATRIX DIVIDER
  // CONTROL
  wire start_matrix_divider;
  wire ready_matrix_divider;

  wire data_a_in_i_enable_matrix_divider;
  wire data_a_in_j_enable_matrix_divider;
  wire data_b_in_i_enable_matrix_divider;
  wire data_b_in_j_enable_matrix_divider;
  wire data_out_i_enable_matrix_divider;
  wire data_out_j_enable_matrix_divider;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_divider;
  wire [DATA_SIZE-1:0] size_i_in_matrix_divider;
  wire [DATA_SIZE-1:0] size_j_in_matrix_divider;
  wire [DATA_SIZE-1:0] data_a_in_matrix_divider;
  wire [DATA_SIZE-1:0] data_b_in_matrix_divider;
  wire [DATA_SIZE-1:0] data_out_matrix_divider;

  // MATRIX EXPONENTIATOR
  // CONTROL
  wire start_matrix_exponentiator;
  wire ready_matrix_exponentiator;

  wire data_a_in_i_enable_matrix_exponentiator;
  wire data_a_in_j_enable_matrix_exponentiator;
  wire data_b_in_i_enable_matrix_exponentiator;
  wire data_b_in_j_enable_matrix_exponentiator;
  wire data_out_i_enable_matrix_exponentiator;
  wire data_out_j_enable_matrix_exponentiator;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_exponentiator;
  wire [DATA_SIZE-1:0] size_i_in_matrix_exponentiator;
  wire [DATA_SIZE-1:0] size_j_in_matrix_exponentiator;
  wire [DATA_SIZE-1:0] data_a_in_matrix_exponentiator;
  wire [DATA_SIZE-1:0] data_b_in_matrix_exponentiator;
  wire [DATA_SIZE-1:0] data_out_matrix_exponentiator;

  // MATRIX LCM
  // CONTROL
  wire start_matrix_lcm;
  wire ready_matrix_lcm;

  wire data_a_in_i_enable_matrix_lcm;
  wire data_a_in_j_enable_matrix_lcm;
  wire data_b_in_i_enable_matrix_lcm;
  wire data_b_in_j_enable_matrix_lcm;
  wire data_out_i_enable_matrix_lcm;
  wire data_out_j_enable_matrix_lcm;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_lcm;
  wire [DATA_SIZE-1:0] size_i_in_matrix_lcm;
  wire [DATA_SIZE-1:0] size_j_in_matrix_lcm;
  wire [DATA_SIZE-1:0] data_a_in_matrix_lcm;
  wire [DATA_SIZE-1:0] data_b_in_matrix_lcm;
  wire [DATA_SIZE-1:0] data_out_matrix_lcm;

  // MATRIX GCD
  // CONTROL
  wire start_matrix_gcd;
  wire ready_matrix_gcd;

  wire data_a_in_i_enable_matrix_gcd;
  wire data_a_in_j_enable_matrix_gcd;
  wire data_b_in_i_enable_matrix_gcd;
  wire data_b_in_j_enable_matrix_gcd;
  wire data_out_i_enable_matrix_gcd;
  wire data_out_j_enable_matrix_gcd;

  // DATA
  wire [DATA_SIZE-1:0] modulo_in_matrix_gcd;
  wire [DATA_SIZE-1:0] size_i_in_matrix_gcd;
  wire [DATA_SIZE-1:0] size_j_in_matrix_gcd;
  wire [DATA_SIZE-1:0] data_a_in_matrix_gcd;
  wire [DATA_SIZE-1:0] data_b_in_matrix_gcd;
  wire [DATA_SIZE-1:0] data_out_matrix_gcd;

  ///////////////////////////////////////////////////////////////////////
  // Body
  ///////////////////////////////////////////////////////////////////////
  ntm_arithmetic_stimulus #(
    // SYSTEM-SIZE
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE),

    .X(X),
    .Y(Y),
    .N(N),
    .W(W),
    .L(L),
    .R(R),

    // SCALAR-FUNCTIONALITY
    .STIMULUS_NTM_SCALAR_MOD_TEST(STIMULUS_NTM_SCALAR_MOD_TEST),
    .STIMULUS_NTM_SCALAR_ADDER_TEST(STIMULUS_NTM_SCALAR_ADDER_TEST),
    .STIMULUS_NTM_SCALAR_MULTIPLIER_TEST(STIMULUS_NTM_SCALAR_MULTIPLIER_TEST),
    .STIMULUS_NTM_SCALAR_INVERTER_TEST(STIMULUS_NTM_SCALAR_INVERTER_TEST),
    .STIMULUS_NTM_SCALAR_DIVIDER_TEST(STIMULUS_NTM_SCALAR_DIVIDER_TEST),
    .STIMULUS_NTM_SCALAR_EXPONENTIATOR_TEST(STIMULUS_NTM_SCALAR_EXPONENTIATOR_TEST),
    .STIMULUS_NTM_SCALAR_LCM_TEST(STIMULUS_NTM_SCALAR_LCM_TEST),
    .STIMULUS_NTM_SCALAR_GCD_TEST(STIMULUS_NTM_SCALAR_GCD_TEST),
    .STIMULUS_NTM_SCALAR_MOD_CASE_0(STIMULUS_NTM_SCALAR_MOD_CASE_0),
    .STIMULUS_NTM_SCALAR_ADDER_CASE_0(STIMULUS_NTM_SCALAR_ADDER_CASE_0),
    .STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_0(STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_0),
    .STIMULUS_NTM_SCALAR_INVERTER_CASE_0(STIMULUS_NTM_SCALAR_INVERTER_CASE_0),
    .STIMULUS_NTM_SCALAR_DIVIDER_CASE_0(STIMULUS_NTM_SCALAR_DIVIDER_CASE_0),
    .STIMULUS_NTM_SCALAR_EXPONENTIATOR_CASE_0(STIMULUS_NTM_SCALAR_EXPONENTIATOR_CASE_0),
    .STIMULUS_NTM_SCALAR_LCM_CASE_0(STIMULUS_NTM_SCALAR_LCM_CASE_0),
    .STIMULUS_NTM_SCALAR_GCD_CASE_0(STIMULUS_NTM_SCALAR_GCD_CASE_0),
    .STIMULUS_NTM_SCALAR_MOD_CASE_1(STIMULUS_NTM_SCALAR_MOD_CASE_1),
    .STIMULUS_NTM_SCALAR_ADDER_CASE_1(STIMULUS_NTM_SCALAR_ADDER_CASE_1),
    .STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_1(STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_1),
    .STIMULUS_NTM_SCALAR_INVERTER_CASE_1(STIMULUS_NTM_SCALAR_INVERTER_CASE_1),
    .STIMULUS_NTM_SCALAR_DIVIDER_CASE_1(STIMULUS_NTM_SCALAR_DIVIDER_CASE_1),
    .STIMULUS_NTM_SCALAR_EXPONENTIATOR_CASE_1(STIMULUS_NTM_SCALAR_EXPONENTIATOR_CASE_1),
    .STIMULUS_NTM_SCALAR_LCM_CASE_1(STIMULUS_NTM_SCALAR_LCM_CASE_1),
    .STIMULUS_NTM_SCALAR_GCD_CASE_1(STIMULUS_NTM_SCALAR_GCD_CASE_1),

    // VECTOR-FUNCTIONALITY
    .STIMULUS_NTM_VECTOR_MOD_TEST(STIMULUS_NTM_VECTOR_MOD_TEST),
    .STIMULUS_NTM_VECTOR_ADDER_TEST(STIMULUS_NTM_VECTOR_ADDER_TEST),
    .STIMULUS_NTM_VECTOR_MULTIPLIER_TEST(STIMULUS_NTM_VECTOR_MULTIPLIER_TEST),
    .STIMULUS_NTM_VECTOR_INVERTER_TEST(STIMULUS_NTM_VECTOR_INVERTER_TEST),
    .STIMULUS_NTM_VECTOR_DIVIDER_TEST(STIMULUS_NTM_VECTOR_DIVIDER_TEST),
    .STIMULUS_NTM_VECTOR_EXPONENTIATOR_TEST(STIMULUS_NTM_VECTOR_EXPONENTIATOR_TEST),
    .STIMULUS_NTM_VECTOR_LCM_TEST(STIMULUS_NTM_VECTOR_LCM_TEST),
    .STIMULUS_NTM_VECTOR_GCD_TEST(STIMULUS_NTM_VECTOR_GCD_TEST),
    .STIMULUS_NTM_VECTOR_MOD_CASE_0(STIMULUS_NTM_VECTOR_MOD_CASE_0),
    .STIMULUS_NTM_VECTOR_ADDER_CASE_0(STIMULUS_NTM_VECTOR_ADDER_CASE_0),
    .STIMULUS_NTM_VECTOR_MULTIPLIER_CASE_0(STIMULUS_NTM_VECTOR_MULTIPLIER_CASE_0),
    .STIMULUS_NTM_VECTOR_INVERTER_CASE_0(STIMULUS_NTM_VECTOR_INVERTER_CASE_0),
    .STIMULUS_NTM_VECTOR_DIVIDER_CASE_0(STIMULUS_NTM_VECTOR_DIVIDER_CASE_0),
    .STIMULUS_NTM_VECTOR_EXPONENTIATOR_CASE_0(STIMULUS_NTM_VECTOR_EXPONENTIATOR_CASE_0),
    .STIMULUS_NTM_VECTOR_LCM_CASE_0(STIMULUS_NTM_VECTOR_LCM_CASE_0),
    .STIMULUS_NTM_VECTOR_GCD_CASE_0(STIMULUS_NTM_VECTOR_GCD_CASE_0),
    .STIMULUS_NTM_VECTOR_MOD_CASE_1(STIMULUS_NTM_VECTOR_MOD_CASE_1),
    .STIMULUS_NTM_VECTOR_ADDER_CASE_1(STIMULUS_NTM_VECTOR_ADDER_CASE_1),
    .STIMULUS_NTM_VECTOR_MULTIPLIER_CASE_1(STIMULUS_NTM_VECTOR_MULTIPLIER_CASE_1),
    .STIMULUS_NTM_VECTOR_INVERTER_CASE_1(STIMULUS_NTM_VECTOR_INVERTER_CASE_1),
    .STIMULUS_NTM_VECTOR_DIVIDER_CASE_1(STIMULUS_NTM_VECTOR_DIVIDER_CASE_1),
    .STIMULUS_NTM_VECTOR_EXPONENTIATOR_CASE_1(STIMULUS_NTM_VECTOR_EXPONENTIATOR_CASE_1),
    .STIMULUS_NTM_VECTOR_LCM_CASE_1(STIMULUS_NTM_VECTOR_LCM_CASE_1),
    .STIMULUS_NTM_VECTOR_GCD_CASE_1(STIMULUS_NTM_VECTOR_GCD_CASE_1),

    // MATRIX-FUNCTIONALITY
    .STIMULUS_NTM_MATRIX_MOD_TEST(STIMULUS_NTM_MATRIX_MOD_TEST),
    .STIMULUS_NTM_MATRIX_ADDER_TEST(STIMULUS_NTM_MATRIX_ADDER_TEST),
    .STIMULUS_NTM_MATRIX_MULTIPLIER_TEST(STIMULUS_NTM_MATRIX_MULTIPLIER_TEST),
    .STIMULUS_NTM_MATRIX_INVERTER_TEST(STIMULUS_NTM_MATRIX_INVERTER_TEST),
    .STIMULUS_NTM_MATRIX_DIVIDER_TEST(STIMULUS_NTM_MATRIX_DIVIDER_TEST),
    .STIMULUS_NTM_MATRIX_EXPONENTIATOR_TEST(STIMULUS_NTM_MATRIX_EXPONENTIATOR_TEST),
    .STIMULUS_NTM_MATRIX_LCM_TEST(STIMULUS_NTM_MATRIX_LCM_TEST),
    .STIMULUS_NTM_MATRIX_GCD_TEST(STIMULUS_NTM_MATRIX_GCD_TEST),
    .STIMULUS_NTM_MATRIX_MOD_CASE_0(STIMULUS_NTM_MATRIX_MOD_CASE_0),
    .STIMULUS_NTM_MATRIX_ADDER_CASE_0(STIMULUS_NTM_MATRIX_ADDER_CASE_0),
    .STIMULUS_NTM_MATRIX_MULTIPLIER_CASE_0(STIMULUS_NTM_MATRIX_MULTIPLIER_CASE_0),
    .STIMULUS_NTM_MATRIX_INVERTER_CASE_0(STIMULUS_NTM_MATRIX_INVERTER_CASE_0),
    .STIMULUS_NTM_MATRIX_DIVIDER_CASE_0(STIMULUS_NTM_MATRIX_DIVIDER_CASE_0),
    .STIMULUS_NTM_MATRIX_EXPONENTIATOR_CASE_0(STIMULUS_NTM_MATRIX_EXPONENTIATOR_CASE_0),
    .STIMULUS_NTM_MATRIX_LCM_CASE_0(STIMULUS_NTM_MATRIX_LCM_CASE_0),
    .STIMULUS_NTM_MATRIX_GCD_CASE_0(STIMULUS_NTM_MATRIX_GCD_CASE_0),
    .STIMULUS_NTM_MATRIX_MOD_CASE_1(STIMULUS_NTM_MATRIX_MOD_CASE_1),
    .STIMULUS_NTM_MATRIX_ADDER_CASE_1(STIMULUS_NTM_MATRIX_ADDER_CASE_1),
    .STIMULUS_NTM_MATRIX_MULTIPLIER_CASE_1(STIMULUS_NTM_MATRIX_MULTIPLIER_CASE_1),
    .STIMULUS_NTM_MATRIX_INVERTER_CASE_1(STIMULUS_NTM_MATRIX_INVERTER_CASE_1),
    .STIMULUS_NTM_MATRIX_DIVIDER_CASE_1(STIMULUS_NTM_MATRIX_DIVIDER_CASE_1),
    .STIMULUS_NTM_MATRIX_EXPONENTIATOR_CASE_1(STIMULUS_NTM_MATRIX_EXPONENTIATOR_CASE_1),
    .STIMULUS_NTM_MATRIX_LCM_CASE_1(STIMULUS_NTM_MATRIX_LCM_CASE_1),
    .STIMULUS_NTM_MATRIX_GCD_CASE_1(STIMULUS_NTM_MATRIX_GCD_CASE_1))
  arithmetic_stimulus(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    ///////////////////////////////////////////////////////////////////////
    // STIMULUS SCALAR
    ///////////////////////////////////////////////////////////////////////

    // SCALAR MOD
    // CONTROL
    .SCALAR_MOD_START(start_scalar_mod),
    .SCALAR_MOD_READY(ready_scalar_mod),

    // DATA
    .SCALAR_MOD_MODULO_IN(modulo_in_scalar_mod),
    .SCALAR_MOD_DATA_IN(data_in_scalar_mod),
    .SCALAR_MOD_DATA_OUT(data_out_scalar_mod),

    // SCALAR ADDER
    // CONTROL
    .SCALAR_ADDER_START(start_scalar_adder),
    .SCALAR_ADDER_READY(ready_scalar_adder),

    .SCALAR_ADDER_OPERATION(operation_scalar_adder),

    // DATA
    .SCALAR_ADDER_MODULO_IN(modulo_in_scalar_adder),
    .SCALAR_ADDER_DATA_A_IN(data_a_in_scalar_adder),
    .SCALAR_ADDER_DATA_B_IN(data_b_in_scalar_adder),
    .SCALAR_ADDER_DATA_OUT(data_out_scalar_adder),

    // SCALAR MULTIPLIER
    // CONTROL
    .SCALAR_MULTIPLIER_START(start_scalar_multiplier),
    .SCALAR_MULTIPLIER_READY(ready_scalar_multiplier),

    // DATA
    .SCALAR_MULTIPLIER_MODULO_IN(modulo_in_scalar_multiplier),
    .SCALAR_MULTIPLIER_DATA_A_IN(data_a_in_scalar_multiplier),
    .SCALAR_MULTIPLIER_DATA_B_IN(data_b_in_scalar_multiplier),
    .SCALAR_MULTIPLIER_DATA_OUT(data_out_scalar_multiplier),

    // SCALAR INVERTER
    // CONTROL
    .SCALAR_INVERTER_START(start_scalar_inverter),
    .SCALAR_INVERTER_READY(ready_scalar_inverter),

    // DATA
    .SCALAR_INVERTER_MODULO_IN(modulo_in_scalar_inverter),
    .SCALAR_INVERTER_DATA_IN(data_in_scalar_inverter),
    .SCALAR_INVERTER_DATA_OUT(data_out_scalar_inverter),

    // SCALAR DIVIDER
    // CONTROL
    .SCALAR_DIVIDER_START(start_scalar_divider),
    .SCALAR_DIVIDER_READY(ready_scalar_divider),

    // DATA
    .SCALAR_DIVIDER_MODULO_IN(modulo_in_scalar_divider),
    .SCALAR_DIVIDER_DATA_A_IN(data_a_in_scalar_divider),
    .SCALAR_DIVIDER_DATA_B_IN(data_b_in_scalar_divider),
    .SCALAR_DIVIDER_DATA_OUT(data_out_scalar_divider),

    // SCALAR EXPONENTIATOR
    // CONTROL
    .SCALAR_EXPONENTIATOR_START(start_scalar_exponentiator),
    .SCALAR_EXPONENTIATOR_READY(ready_scalar_exponentiator),

    // DATA
    .SCALAR_EXPONENTIATOR_MODULO_IN(modulo_in_scalar_exponentiator),
    .SCALAR_EXPONENTIATOR_DATA_A_IN(data_a_in_scalar_exponentiator),
    .SCALAR_EXPONENTIATOR_DATA_B_IN(data_b_in_scalar_exponentiator),
    .SCALAR_EXPONENTIATOR_DATA_OUT(data_out_scalar_exponentiator),

    // SCALAR LCM
    // CONTROL
    .SCALAR_LCM_START(start_scalar_lcm),
    .SCALAR_LCM_READY(ready_scalar_lcm),

    // DATA
    .SCALAR_LCM_MODULO_IN(modulo_in_scalar_lcm),
    .SCALAR_LCM_DATA_A_IN(data_a_in_scalar_lcm),
    .SCALAR_LCM_DATA_B_IN(data_b_in_scalar_lcm),
    .SCALAR_LCM_DATA_OUT(data_out_scalar_lcm),

    // SCALAR GCD
    // CONTROL
    .SCALAR_GCD_START(start_scalar_gcd),
    .SCALAR_GCD_READY(ready_scalar_gcd),

    // DATA
    .SCALAR_GCD_MODULO_IN(modulo_in_scalar_gcd),
    .SCALAR_GCD_DATA_A_IN(data_a_in_scalar_gcd),
    .SCALAR_GCD_DATA_B_IN(data_b_in_scalar_gcd),
    .SCALAR_GCD_DATA_OUT(data_out_scalar_gcd),

    ///////////////////////////////////////////////////////////////////////
    // STIMULUS VECTOR
    ///////////////////////////////////////////////////////////////////////

    // VECTOR MOD
    // CONTROL
    .VECTOR_MOD_START(start_vector_mod),
    .VECTOR_MOD_READY(ready_vector_mod),

    .VECTOR_MOD_DATA_IN_ENABLE(data_in_enable_vector_mod),
    .VECTOR_MOD_DATA_OUT_ENABLE(data_out_enable_vector_mod),

    // DATA
    .VECTOR_MOD_MODULO_IN(modulo_in_vector_mod),
    .VECTOR_MOD_SIZE_IN(size_in_vector_mod),
    .VECTOR_MOD_DATA_IN(data_in_vector_mod),
    .VECTOR_MOD_DATA_OUT(data_out_vector_mod),

    // VECTOR ADDER
    // CONTROL
    .VECTOR_ADDER_START(start_vector_adder),
    .VECTOR_ADDER_READY(ready_vector_adder),

    .VECTOR_ADDER_OPERATION(operation_vector_adder),

    .VECTOR_ADDER_DATA_A_IN_ENABLE(data_a_in_enable_vector_adder),
    .VECTOR_ADDER_DATA_B_IN_ENABLE(data_b_in_enable_vector_adder),
    .VECTOR_ADDER_DATA_OUT_ENABLE(data_out_enable_vector_adder),

    // DATA
    .VECTOR_ADDER_MODULO_IN(modulo_in_vector_adder),
    .VECTOR_ADDER_SIZE_IN(size_in_vector_adder),
    .VECTOR_ADDER_DATA_A_IN(data_a_in_vector_adder),
    .VECTOR_ADDER_DATA_B_IN(data_b_in_vector_adder),
    .VECTOR_ADDER_DATA_OUT(data_out_vector_adder),

    // VECTOR MULTIPLIER
    // CONTROL
    .VECTOR_MULTIPLIER_START(start_vector_multiplier),
    .VECTOR_MULTIPLIER_READY(ready_vector_multiplier),

    .VECTOR_MULTIPLIER_DATA_A_IN_ENABLE(data_a_in_enable_vector_multiplier),
    .VECTOR_MULTIPLIER_DATA_B_IN_ENABLE(data_b_in_enable_vector_multiplier),
    .VECTOR_MULTIPLIER_DATA_OUT_ENABLE(data_out_enable_vector_multiplier),

    // DATA
    .VECTOR_MULTIPLIER_MODULO_IN(modulo_in_vector_multiplier),
    .VECTOR_MULTIPLIER_SIZE_IN(size_in_vector_multiplier),
    .VECTOR_MULTIPLIER_DATA_A_IN(data_a_in_vector_multiplier),
    .VECTOR_MULTIPLIER_DATA_B_IN(data_b_in_vector_multiplier),
    .VECTOR_MULTIPLIER_DATA_OUT(data_out_vector_multiplier),

    // VECTOR INVERTER
    // CONTROL
    .VECTOR_INVERTER_START(start_vector_inverter),
    .VECTOR_INVERTER_READY(ready_vector_inverter),

    .VECTOR_INVERTER_DATA_IN_ENABLE(data_in_enable_vector_inverter),
    .VECTOR_INVERTER_DATA_OUT_ENABLE(data_out_enable_vector_inverter),

    // DATA
    .VECTOR_INVERTER_MODULO_IN(modulo_in_vector_inverter),
    .VECTOR_INVERTER_SIZE_IN(size_in_vector_inverter),
    .VECTOR_INVERTER_DATA_IN(data_in_vector_inverter),
    .VECTOR_INVERTER_DATA_OUT(data_out_vector_inverter),

    // VECTOR DIVIDER
    // CONTROL
    .VECTOR_DIVIDER_START(start_vector_divider),
    .VECTOR_DIVIDER_READY(ready_vector_divider),

    .VECTOR_DIVIDER_DATA_A_IN_ENABLE(data_a_in_enable_vector_divider),
    .VECTOR_DIVIDER_DATA_B_IN_ENABLE(data_b_in_enable_vector_divider),
    .VECTOR_DIVIDER_DATA_OUT_ENABLE(data_out_enable_vector_divider),

    // DATA
    .VECTOR_DIVIDER_MODULO_IN(modulo_in_vector_divider),
    .VECTOR_DIVIDER_SIZE_IN(size_in_vector_divider),
    .VECTOR_DIVIDER_DATA_A_IN(data_a_in_vector_divider),
    .VECTOR_DIVIDER_DATA_B_IN(data_b_in_vector_divider),
    .VECTOR_DIVIDER_DATA_OUT(data_out_vector_divider),

    // VECTOR EXPONENTIATOR
    // CONTROL
    .VECTOR_EXPONENTIATOR_START(start_vector_exponentiator),
    .VECTOR_EXPONENTIATOR_READY(ready_vector_exponentiator),

    .VECTOR_EXPONENTIATOR_DATA_A_IN_ENABLE(data_a_in_enable_vector_exponentiator),
    .VECTOR_EXPONENTIATOR_DATA_B_IN_ENABLE(data_b_in_enable_vector_exponentiator),
    .VECTOR_EXPONENTIATOR_DATA_OUT_ENABLE(data_out_enable_vector_exponentiator),

    // DATA
    .VECTOR_EXPONENTIATOR_MODULO_IN(modulo_in_vector_exponentiator),
    .VECTOR_EXPONENTIATOR_SIZE_IN(size_in_vector_exponentiator),
    .VECTOR_EXPONENTIATOR_DATA_A_IN(data_a_in_vector_exponentiator),
    .VECTOR_EXPONENTIATOR_DATA_B_IN(data_b_in_vector_exponentiator),
    .VECTOR_EXPONENTIATOR_DATA_OUT(data_out_vector_exponentiator),

    // VECTOR LCM
    // CONTROL
    .VECTOR_LCM_START(start_vector_lcm),
    .VECTOR_LCM_READY(ready_vector_lcm),

    .VECTOR_LCM_DATA_A_IN_ENABLE(data_a_in_enable_vector_lcm),
    .VECTOR_LCM_DATA_B_IN_ENABLE(data_b_in_enable_vector_lcm),
    .VECTOR_LCM_DATA_OUT_ENABLE(data_out_enable_vector_lcm),

    // DATA
    .VECTOR_LCM_MODULO_IN(modulo_in_vector_lcm),
    .VECTOR_LCM_SIZE_IN(size_in_vector_lcm),
    .VECTOR_LCM_DATA_A_IN(data_a_in_vector_lcm),
    .VECTOR_LCM_DATA_B_IN(data_b_in_vector_lcm),
    .VECTOR_LCM_DATA_OUT(data_out_vector_lcm),

    // VECTOR GCD
    // CONTROL
    .VECTOR_GCD_START(start_vector_gcd),
    .VECTOR_GCD_READY(ready_vector_gcd),

    .VECTOR_GCD_DATA_A_IN_ENABLE(data_a_in_enable_vector_gcd),
    .VECTOR_GCD_DATA_B_IN_ENABLE(data_b_in_enable_vector_gcd),
    .VECTOR_GCD_DATA_OUT_ENABLE(data_out_enable_vector_gcd),

    // DATA
    .VECTOR_GCD_MODULO_IN(modulo_in_vector_gcd),
    .VECTOR_GCD_SIZE_IN(size_in_vector_gcd),
    .VECTOR_GCD_DATA_A_IN(data_a_in_vector_gcd),
    .VECTOR_GCD_DATA_B_IN(data_b_in_vector_gcd),
    .VECTOR_GCD_DATA_OUT(data_out_vector_gcd),

    ///////////////////////////////////////////////////////////////////////
    // STIMULUS MATRIX
    ///////////////////////////////////////////////////////////////////////

    // MATRIX MOD
    // CONTROL
    .MATRIX_MOD_START(start_matrix_mod),
    .MATRIX_MOD_READY(ready_matrix_mod),

    .MATRIX_MOD_DATA_IN_I_ENABLE(data_in_i_enable_matrix_mod),
    .MATRIX_MOD_DATA_IN_J_ENABLE(data_in_j_enable_matrix_mod),
    .MATRIX_MOD_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_mod),
    .MATRIX_MOD_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_mod),

    // DATA
    .MATRIX_MOD_MODULO_IN(modulo_in_matrix_mod),
    .MATRIX_MOD_SIZE_I_IN(size_i_in_matrix_mod),
    .MATRIX_MOD_SIZE_J_IN(size_j_in_matrix_mod),
    .MATRIX_MOD_DATA_IN(data_in_matrix_mod),
    .MATRIX_MOD_DATA_OUT(data_out_matrix_mod),

    // MATRIX ADDER
    // CONTROL
    .MATRIX_ADDER_START(start_matrix_adder),
    .MATRIX_ADDER_READY(ready_matrix_adder),

    .MATRIX_ADDER_OPERATION(operation_matrix_adder),

    .MATRIX_ADDER_DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_adder),
    .MATRIX_ADDER_DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_adder),
    .MATRIX_ADDER_DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_adder),
    .MATRIX_ADDER_DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_adder),
    .MATRIX_ADDER_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_adder),
    .MATRIX_ADDER_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_adder),

    // DATA
    .MATRIX_ADDER_MODULO_IN(modulo_in_matrix_adder),
    .MATRIX_ADDER_SIZE_I_IN(size_i_in_matrix_adder),
    .MATRIX_ADDER_SIZE_J_IN(size_j_in_matrix_adder),
    .MATRIX_ADDER_DATA_A_IN(data_a_in_matrix_adder),
    .MATRIX_ADDER_DATA_B_IN(data_b_in_matrix_adder),
    .MATRIX_ADDER_DATA_OUT(data_out_matrix_adder),

    // MATRIX MULTIPLIER
    // CONTROL
    .MATRIX_MULTIPLIER_START(start_matrix_multiplier),
    .MATRIX_MULTIPLIER_READY(ready_matrix_multiplier),

    .MATRIX_MULTIPLIER_DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_multiplier),

    // DATA
    .MATRIX_MULTIPLIER_MODULO_IN(modulo_in_matrix_multiplier),
    .MATRIX_MULTIPLIER_SIZE_I_IN(size_i_in_matrix_multiplier),
    .MATRIX_MULTIPLIER_SIZE_J_IN(size_j_in_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_A_IN(data_a_in_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_B_IN(data_b_in_matrix_multiplier),
    .MATRIX_MULTIPLIER_DATA_OUT(data_out_matrix_multiplier),

    // MATRIX INVERTER
    // CONTROL
    .MATRIX_INVERTER_START(start_matrix_inverter),
    .MATRIX_INVERTER_READY(ready_matrix_inverter),

    .MATRIX_INVERTER_DATA_IN_I_ENABLE(data_in_i_enable_matrix_inverter),
    .MATRIX_INVERTER_DATA_IN_J_ENABLE(data_in_j_enable_matrix_inverter),
    .MATRIX_INVERTER_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_inverter),
    .MATRIX_INVERTER_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_inverter),

    // DATA
    .MATRIX_INVERTER_MODULO_IN(modulo_in_matrix_inverter),
    .MATRIX_INVERTER_SIZE_I_IN(size_i_in_matrix_inverter),
    .MATRIX_INVERTER_SIZE_J_IN(size_j_in_matrix_inverter),
    .MATRIX_INVERTER_DATA_IN(data_in_matrix_inverter),
    .MATRIX_INVERTER_DATA_OUT(data_out_matrix_inverter),

    // MATRIX DIVIDER
    // CONTROL
    .MATRIX_DIVIDER_START(start_matrix_divider),
    .MATRIX_DIVIDER_READY(ready_matrix_divider),

    .MATRIX_DIVIDER_DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_divider),
    .MATRIX_DIVIDER_DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_divider),
    .MATRIX_DIVIDER_DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_divider),
    .MATRIX_DIVIDER_DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_divider),
    .MATRIX_DIVIDER_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_divider),
    .MATRIX_DIVIDER_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_divider),

    // DATA
    .MATRIX_DIVIDER_MODULO_IN(modulo_in_matrix_divider),
    .MATRIX_DIVIDER_SIZE_I_IN(size_i_in_matrix_divider),
    .MATRIX_DIVIDER_SIZE_J_IN(size_j_in_matrix_divider),
    .MATRIX_DIVIDER_DATA_A_IN(data_a_in_matrix_divider),
    .MATRIX_DIVIDER_DATA_B_IN(data_b_in_matrix_divider),
    .MATRIX_DIVIDER_DATA_OUT(data_out_matrix_divider),

    // MATRIX EXPONENTIATOR
    // CONTROL
    .MATRIX_EXPONENTIATOR_START(start_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_READY(ready_matrix_exponentiator),

    .MATRIX_EXPONENTIATOR_DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_exponentiator),

    // DATA
    .MATRIX_EXPONENTIATOR_MODULO_IN(modulo_in_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_SIZE_I_IN(size_i_in_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_SIZE_J_IN(size_j_in_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_A_IN(data_a_in_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_B_IN(data_b_in_matrix_exponentiator),
    .MATRIX_EXPONENTIATOR_DATA_OUT(data_out_matrix_exponentiator),

    // MATRIX LCM
    // CONTROL
    .MATRIX_LCM_START(start_matrix_lcm),
    .MATRIX_LCM_READY(ready_matrix_lcm),

    .MATRIX_LCM_DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_lcm),
    .MATRIX_LCM_DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_lcm),
    .MATRIX_LCM_DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_lcm),
    .MATRIX_LCM_DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_lcm),
    .MATRIX_LCM_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_lcm),
    .MATRIX_LCM_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_lcm),

    // DATA
    .MATRIX_LCM_MODULO_IN(modulo_in_matrix_lcm),
    .MATRIX_LCM_SIZE_I_IN(size_i_in_matrix_lcm),
    .MATRIX_LCM_SIZE_J_IN(size_j_in_matrix_lcm),
    .MATRIX_LCM_DATA_A_IN(data_a_in_matrix_lcm),
    .MATRIX_LCM_DATA_B_IN(data_b_in_matrix_lcm),
    .MATRIX_LCM_DATA_OUT(data_out_matrix_lcm),

    // MATRIX GCD
    // CONTROL
    .MATRIX_GCD_START(start_matrix_gcd),
    .MATRIX_GCD_READY(ready_matrix_gcd),

    .MATRIX_GCD_DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_gcd),
    .MATRIX_GCD_DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_gcd),
    .MATRIX_GCD_DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_gcd),
    .MATRIX_GCD_DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_gcd),
    .MATRIX_GCD_DATA_OUT_I_ENABLE(data_out_i_enable_matrix_gcd),
    .MATRIX_GCD_DATA_OUT_J_ENABLE(data_out_j_enable_matrix_gcd),

    // DATA
    .MATRIX_GCD_MODULO_IN(modulo_in_matrix_gcd),
    .MATRIX_GCD_SIZE_I_IN(size_i_in_matrix_gcd),
    .MATRIX_GCD_SIZE_J_IN(size_j_in_matrix_gcd),
    .MATRIX_GCD_DATA_A_IN(data_a_in_matrix_gcd),
    .MATRIX_GCD_DATA_B_IN(data_b_in_matrix_gcd),
    .MATRIX_GCD_DATA_OUT(data_out_matrix_gcd)
  );

  ///////////////////////////////////////////////////////////////////////
  // SCALAR
  ///////////////////////////////////////////////////////////////////////

  // SCALAR MOD
  ntm_scalar_mod #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_mod(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_mod),
    .READY(ready_scalar_mod),

    // DATA
    .MODULO_IN(modulo_in_scalar_mod),
    .DATA_IN(data_in_scalar_mod),
    .DATA_OUT(data_out_scalar_mod)
  );

  // SCALAR ADDER
  ntm_scalar_adder #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_adder(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_adder),
    .READY(ready_scalar_adder),

    .OPERATION(operation_scalar_adder),

    // DATA
    .MODULO_IN(modulo_in_scalar_adder),
    .DATA_A_IN(data_a_in_scalar_adder),
    .DATA_B_IN(data_b_in_scalar_adder),
    .DATA_OUT(data_out_scalar_adder)
  );

  // SCALAR MULTIPLIER
  ntm_scalar_multiplier #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_multiplier(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_multiplier),
    .READY(ready_scalar_adder),

    // DATA
    .MODULO_IN(modulo_in_scalar_multiplier),
    .DATA_A_IN(data_a_in_scalar_multiplier),
    .DATA_B_IN(data_b_in_scalar_multiplier),
    .DATA_OUT(data_out_scalar_multiplier)
  );

  // SCALAR INVERTER
  ntm_scalar_inverter #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_inverter(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_inverter),
    .READY(ready_scalar_inverter),

    // DATA
    .MODULO_IN(modulo_in_scalar_inverter),
    .DATA_IN(data_in_scalar_inverter),
    .DATA_OUT(data_out_scalar_inverter)
  );

  // SCALAR DIVIDER
  ntm_scalar_divider #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_divider(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_divider),
    .READY(ready_scalar_divider),

    // DATA
    .MODULO_IN(modulo_in_scalar_divider),
    .DATA_A_IN(data_a_in_scalar_divider),
    .DATA_B_IN(data_b_in_scalar_divider),
    .DATA_OUT(data_out_scalar_divider)
  );

  // SCALAR EXPONENTIATOR
  ntm_scalar_exponentiator #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_exponentiator(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_exponentiator),
    .READY(ready_scalar_exponentiator),

    // DATA
    .MODULO_IN(modulo_in_scalar_exponentiator),
    .DATA_A_IN(data_a_in_scalar_exponentiator),
    .DATA_B_IN(data_b_in_scalar_exponentiator),
    .DATA_OUT(data_out_scalar_exponentiator)
  );

  // SCALAR LCM
  ntm_scalar_lcm #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_lcm(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_lcm),
    .READY(ready_scalar_lcm),

    // DATA
    .MODULO_IN(modulo_in_scalar_lcm),
    .DATA_A_IN(data_a_in_scalar_lcm),
    .DATA_B_IN(data_b_in_scalar_lcm),
    .DATA_OUT(data_out_scalar_lcm)
  );

  // SCALAR GCD
  ntm_scalar_gcd #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  scalar_gcd(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_scalar_gcd),
    .READY(ready_scalar_gcd),

    // DATA
    .MODULO_IN(modulo_in_scalar_gcd),
    .DATA_A_IN(data_a_in_scalar_gcd),
    .DATA_B_IN(data_b_in_scalar_gcd),
    .DATA_OUT(data_out_scalar_gcd)
  );

  ///////////////////////////////////////////////////////////////////////
  // VECTOR
  ///////////////////////////////////////////////////////////////////////

  // VECTOR MOD
  ntm_vector_mod #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_mod(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_mod),
    .READY(ready_vector_mod),

    .DATA_IN_ENABLE(data_in_enable_vector_mod),
    .DATA_OUT_ENABLE(data_out_enable_vector_mod),

    // DATA
    .MODULO_IN(modulo_in_vector_mod),
    .SIZE_IN(size_in_vector_mod),
    .DATA_IN(data_in_vector_mod),
    .DATA_OUT(data_out_vector_mod)
  );

  // VECTOR ADDER
  ntm_vector_adder #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_adder(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_adder),
    .READY(ready_vector_adder),

    .OPERATION(operation_vector_adder),

    .DATA_A_IN_ENABLE(data_a_in_enable_vector_adder),
    .DATA_B_IN_ENABLE(data_b_in_enable_vector_adder),
    .DATA_OUT_ENABLE(data_out_enable_vector_adder),

    // DATA
    .MODULO_IN(modulo_in_vector_adder),
    .SIZE_IN(size_in_vector_adder),
    .DATA_A_IN(data_a_in_vector_adder),
    .DATA_B_IN(data_b_in_vector_adder),
    .DATA_OUT(data_out_vector_adder)
  );

  // VECTOR MULTIPLIER
  ntm_vector_multiplier #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_multiplier(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_multiplier),
    .READY(ready_vector_multiplier),

    .DATA_A_IN_ENABLE(data_a_in_enable_vector_multiplier),
    .DATA_B_IN_ENABLE(data_b_in_enable_vector_multiplier),
    .DATA_OUT_ENABLE(data_out_enable_vector_multiplier),

    // DATA
    .MODULO_IN(modulo_in_vector_multiplier),
    .SIZE_IN(size_in_vector_multiplier),
    .DATA_A_IN(data_a_in_vector_multiplier),
    .DATA_B_IN(data_b_in_vector_multiplier),
    .DATA_OUT(data_out_vector_multiplier)
  );

  // VECTOR INVERTER
  ntm_vector_inverter #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_inverter(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_inverter),
    .READY(ready_vector_inverter),

    .DATA_IN_ENABLE(data_in_enable_vector_inverter),
    .DATA_OUT_ENABLE(data_out_enable_vector_inverter),

    // DATA
    .MODULO_IN(modulo_in_vector_inverter),
    .SIZE_IN(size_in_vector_inverter),
    .DATA_IN(data_in_vector_inverter),
    .DATA_OUT(data_out_vector_inverter)
  );

  // VECTOR DIVIDER
  ntm_vector_divider #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_divider(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_divider),
    .READY(ready_vector_divider),

    .DATA_A_IN_ENABLE(data_a_in_enable_vector_divider),
    .DATA_B_IN_ENABLE(data_b_in_enable_vector_divider),
    .DATA_OUT_ENABLE(data_out_enable_vector_divider),

    // DATA
    .MODULO_IN(modulo_in_vector_divider),
    .SIZE_IN(size_in_vector_divider),
    .DATA_A_IN(data_a_in_vector_divider),
    .DATA_B_IN(data_b_in_vector_divider),
    .DATA_OUT(data_out_vector_divider)
  );

  // VECTOR EXPONENTIATOR
  ntm_vector_exponentiator #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_exponentiator(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_exponentiator),
    .READY(ready_vector_exponentiator),

    .DATA_A_IN_ENABLE(data_a_in_enable_vector_exponentiator),
    .DATA_B_IN_ENABLE(data_b_in_enable_vector_exponentiator),
    .DATA_OUT_ENABLE(data_out_enable_vector_exponentiator),

    // DATA
    .MODULO_IN(modulo_in_vector_exponentiator),
    .SIZE_IN(size_in_vector_exponentiator),
    .DATA_A_IN(data_a_in_vector_exponentiator),
    .DATA_B_IN(data_b_in_vector_exponentiator),
    .DATA_OUT(data_out_vector_exponentiator)
  );

  // VECTOR LCM
  ntm_vector_lcm #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_lcm(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_lcm),
    .READY(ready_vector_lcm),

    .DATA_A_IN_ENABLE(data_a_in_enable_vector_lcm),
    .DATA_B_IN_ENABLE(data_b_in_enable_vector_lcm),
    .DATA_OUT_ENABLE(data_out_enable_vector_lcm),

    // DATA
    .MODULO_IN(modulo_in_vector_lcm),
    .SIZE_IN(size_in_vector_lcm),
    .DATA_A_IN(data_a_in_vector_lcm),
    .DATA_B_IN(data_b_in_vector_lcm),
    .DATA_OUT(data_out_vector_lcm)
  );

  // VECTOR GCD
  ntm_vector_gcd #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  vector_gcd(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_vector_gcd),
    .READY(ready_vector_gcd),

    .DATA_A_IN_ENABLE(data_a_in_enable_vector_gcd),
    .DATA_B_IN_ENABLE(data_b_in_enable_vector_gcd),
    .DATA_OUT_ENABLE(data_out_enable_vector_gcd),

    // DATA
    .MODULO_IN(modulo_in_vector_gcd),
    .SIZE_IN(size_in_vector_gcd),
    .DATA_A_IN(data_a_in_vector_gcd),
    .DATA_B_IN(data_b_in_vector_gcd),
    .DATA_OUT(data_out_vector_gcd)
  );

  ///////////////////////////////////////////////////////////////////////
  // MATRIX
  ///////////////////////////////////////////////////////////////////////

  // MATRIX MOD
  ntm_matrix_mod #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_mod(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_mod),
    .READY(ready_matrix_mod),

    .DATA_IN_I_ENABLE(data_in_i_enable_matrix_mod),
    .DATA_IN_J_ENABLE(data_in_j_enable_matrix_mod),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_mod),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_mod),

    // DATA
    .MODULO_IN(modulo_in_matrix_mod),
    .SIZE_I_IN(size_i_in_matrix_mod),
    .SIZE_J_IN(size_j_in_matrix_mod),
    .DATA_IN(data_in_matrix_mod),
    .DATA_OUT(data_out_matrix_mod)
  );

  // MATRIX ADDER
  ntm_matrix_adder #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_adder(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_adder),
    .READY(ready_matrix_adder),

    .OPERATION(operation_matrix_adder),

    .DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_adder),
    .DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_adder),
    .DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_adder),
    .DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_adder),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_adder),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_adder),

    // DATA
    .MODULO_IN(modulo_in_matrix_adder),
    .SIZE_I_IN(size_i_in_matrix_adder),
    .SIZE_J_IN(size_j_in_matrix_adder),
    .DATA_A_IN(data_a_in_matrix_adder),
    .DATA_B_IN(data_b_in_matrix_adder),
    .DATA_OUT(data_out_matrix_adder)
  );

  // MATRIX MULTIPLIER
  ntm_matrix_multiplier #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_multiplier(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_multiplier),
    .READY(ready_matrix_multiplier),

    .DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_multiplier),
    .DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_multiplier),
    .DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_multiplier),
    .DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_multiplier),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_multiplier),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_multiplier),

    // DATA
    .MODULO_IN(modulo_in_matrix_multiplier),
    .SIZE_I_IN(size_i_in_matrix_multiplier),
    .SIZE_J_IN(size_j_in_matrix_multiplier),
    .DATA_A_IN(data_a_in_matrix_multiplier),
    .DATA_B_IN(data_b_in_matrix_multiplier),
    .DATA_OUT(data_out_matrix_multiplier)
  );

  // MATRIX INVERTER
  ntm_matrix_inverter #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_inverter(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_inverter),
    .READY(ready_matrix_inverter),

    .DATA_IN_I_ENABLE(data_in_i_enable_matrix_inverter),
    .DATA_IN_J_ENABLE(data_in_j_enable_matrix_inverter),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_inverter),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_inverter),

    // DATA
    .MODULO_IN(modulo_in_matrix_inverter),
    .SIZE_I_IN(size_i_in_matrix_inverter),
    .SIZE_J_IN(size_j_in_matrix_inverter),
    .DATA_IN(data_in_matrix_inverter),
    .DATA_OUT(data_out_matrix_inverter)
  );

  // MATRIX DIVIDER
  ntm_matrix_divider #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_divider(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_divider),
    .READY(ready_matrix_divider),

    .DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_divider),
    .DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_divider),
    .DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_divider),
    .DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_divider),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_divider),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_divider),

    // DATA
    .MODULO_IN(modulo_in_matrix_divider),
    .SIZE_I_IN(size_i_in_matrix_divider),
    .SIZE_J_IN(size_j_in_matrix_divider),
    .DATA_A_IN(data_a_in_matrix_divider),
    .DATA_B_IN(data_b_in_matrix_divider),
    .DATA_OUT(data_out_matrix_divider)
  );

  // MATRIX EXPONENTIATOR
  ntm_matrix_exponentiator #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_exponentiator(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_exponentiator),
    .READY(ready_matrix_exponentiator),

    .DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_exponentiator),
    .DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_exponentiator),
    .DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_exponentiator),
    .DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_exponentiator),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_exponentiator),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_exponentiator),

    // DATA
    .MODULO_IN(modulo_in_matrix_exponentiator),
    .SIZE_I_IN(size_i_in_matrix_exponentiator),
    .SIZE_J_IN(size_j_in_matrix_exponentiator),
    .DATA_A_IN(data_a_in_matrix_exponentiator),
    .DATA_B_IN(data_b_in_matrix_exponentiator),
    .DATA_OUT(data_out_matrix_exponentiator)
  );

  // MATRIX LCM
  ntm_matrix_lcm #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_lcm(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_lcm),
    .READY(ready_matrix_lcm),

    .DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_lcm),
    .DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_lcm),
    .DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_lcm),
    .DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_lcm),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_lcm),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_lcm),

    // DATA
    .MODULO_IN(modulo_in_matrix_lcm),
    .SIZE_I_IN(size_i_in_matrix_lcm),
    .SIZE_J_IN(size_j_in_matrix_lcm),
    .DATA_A_IN(data_a_in_matrix_lcm),
    .DATA_B_IN(data_b_in_matrix_lcm),
    .DATA_OUT(data_out_matrix_lcm)
  );

  // MATRIX GCD
  ntm_matrix_gcd #(
    .DATA_SIZE(DATA_SIZE),
    .INDEX_SIZE(INDEX_SIZE)
  )
  matrix_gcd(
    // GLOBAL
    .CLK(CLK),
    .RST(RST),

    // CONTROL
    .START(start_matrix_gcd),
    .READY(ready_matrix_gcd),

    .DATA_A_IN_I_ENABLE(data_a_in_i_enable_matrix_gcd),
    .DATA_A_IN_J_ENABLE(data_a_in_j_enable_matrix_gcd),
    .DATA_B_IN_I_ENABLE(data_b_in_i_enable_matrix_gcd),
    .DATA_B_IN_J_ENABLE(data_b_in_j_enable_matrix_gcd),
    .DATA_OUT_I_ENABLE(data_out_i_enable_matrix_gcd),
    .DATA_OUT_J_ENABLE(data_out_j_enable_matrix_gcd),

    // DATA
    .MODULO_IN(modulo_in_matrix_gcd),
    .SIZE_I_IN(size_i_in_matrix_gcd),
    .SIZE_J_IN(size_j_in_matrix_gcd),
    .DATA_A_IN(data_a_in_matrix_gcd),
    .DATA_B_IN(data_b_in_matrix_gcd),
    .DATA_OUT(data_out_matrix_gcd)
  );

endmodule
