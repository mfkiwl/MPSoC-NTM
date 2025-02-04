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

package ntm_algebra_pkg;

  ///////////////////////////////////////////////////////////////////////
  // Types
  ///////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////
  // Constants
  ///////////////////////////////////////////////////////////////////////

  // SYSTEM-SIZE
  parameter DATA_SIZE=128;
  parameter CONTROL_SIZE=64;

  parameter X=64;  // x in 0 to X-1
  parameter Y=64;  // y in 0 to Y-1
  parameter N=64;  // j in 0 to N-1
  parameter W=64;  // k in 0 to W-1
  parameter L=64;  // l in 0 to L-1
  parameter R=64;  // i in 0 to R-1

  parameter SIZE_I=64;
  parameter SIZE_J=64;

  parameter SIZE=64;

  // VECTOR-FUNCTIONALITY
  parameter STIMULUS_NTM_DOT_PRODUCT_TEST      = 0;
  parameter STIMULUS_NTM_VECTOR_TRANSPOSE_TEST = 0;

  parameter STIMULUS_NTM_DOT_PRODUCT_CASE_0      = 0;
  parameter STIMULUS_NTM_VECTOR_TRANSPOSE_CASE_0 = 0;

  parameter STIMULUS_NTM_DOT_PRODUCT_CASE_1      = 0;
  parameter STIMULUS_NTM_VECTOR_TRANSPOSE_CASE_1 = 0;

  // MATRIX-FUNCTIONALITY
  parameter STIMULUS_NTM_MATRIX_PRODUCT_TEST   = 0;
  parameter STIMULUS_NTM_MATRIX_TRANSPOSE_TEST = 0;

  parameter STIMULUS_NTM_MATRIX_PRODUCT_CASE_0   = 0;
  parameter STIMULUS_NTM_MATRIX_TRANSPOSE_CASE_0 = 0;

  parameter STIMULUS_NTM_MATRIX_PRODUCT_CASE_1   = 0;
  parameter STIMULUS_NTM_MATRIX_TRANSPOSE_CASE_1 = 0;

  // TENSOR-FUNCTIONALITY
  parameter STIMULUS_NTM_TENSOR_PRODUCT_TEST   = 0;
  parameter STIMULUS_NTM_TENSOR_TRANSPOSE_TEST = 0;

  parameter STIMULUS_NTM_TENSOR_PRODUCT_CASE_0   = 0;
  parameter STIMULUS_NTM_TENSOR_TRANSPOSE_CASE_0 = 0;

  parameter STIMULUS_NTM_TENSOR_PRODUCT_CASE_1   = 0;
  parameter STIMULUS_NTM_TENSOR_TRANSPOSE_CASE_1 = 0;

  ///////////////////////////////////////////////////////////////////////
  // Signals
  ///////////////////////////////////////////////////////////////////////

endpackage