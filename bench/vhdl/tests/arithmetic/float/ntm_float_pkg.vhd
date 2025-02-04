--------------------------------------------------------------------------------
--                                            __ _      _     _               --
--                                           / _(_)    | |   | |              --
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              --
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              --
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              --
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              --
--                  | |                                                       --
--                  |_|                                                       --
--                                                                            --
--                                                                            --
--              Peripheral-NTM for MPSoC                                      --
--              Neural Turing Machine for MPSoC                               --
--                                                                            --
--------------------------------------------------------------------------------

-- Copyright (c) 2020-2021 by the author(s)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ntm_float_pkg is

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  -- SYSTEM-SIZE
  constant DATA_SIZE : integer := 32;

  constant CONTROL_X_SIZE : integer := 3;
  constant CONTROL_Y_SIZE : integer := 3;
  constant CONTROL_Z_SIZE : integer := 3;

  type tensor_buffer is array (0 to CONTROL_X_SIZE-1, 0 to CONTROL_Y_SIZE-1, 0 to CONTROL_Z_SIZE-1) of std_logic_vector(DATA_SIZE-1 downto 0);
  type matrix_buffer is array (0 to CONTROL_X_SIZE-1, 0 to CONTROL_Y_SIZE-1) of std_logic_vector(DATA_SIZE-1 downto 0);
  type vector_buffer is array (0 to CONTROL_X_SIZE-1) of std_logic_vector(DATA_SIZE-1 downto 0);

  -----------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------

  signal MONITOR_TEST : string(40 downto 1) := "                                        ";
  signal MONITOR_CASE : string(40 downto 1) := "                                        ";

  -----------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------

  -- SYSTEM-SIZE
  constant SIZE_I : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));
  constant SIZE_J : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));
  constant SIZE_K : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));

  constant SIZE : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));

  constant X : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- x in 0 to X-1
  constant Y : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- y in 0 to Y-1
  constant N : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- j in 0 to N-1
  constant W : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- k in 0 to W-1
  constant L : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- l in 0 to L-1
  constant R : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- i in 0 to R-1

  -- INTEGERS
  constant INT_P_ZERO  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(0, DATA_SIZE));
  constant INT_P_ONE   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(1, DATA_SIZE));
  constant INT_P_TWO   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(2, DATA_SIZE));
  constant INT_P_THREE : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(3, DATA_SIZE));
  constant INT_P_FOUR  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(4, DATA_SIZE));
  constant INT_P_FIVE  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(5, DATA_SIZE));
  constant INT_P_SIX   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(6, DATA_SIZE));
  constant INT_P_SEVEN : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(7, DATA_SIZE));
  constant INT_P_EIGHT : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(8, DATA_SIZE));
  constant INT_P_NINE  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(9, DATA_SIZE));

  constant INT_N_ONE   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-1, DATA_SIZE));
  constant INT_N_TWO   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-2, DATA_SIZE));
  constant INT_N_THREE : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-3, DATA_SIZE));
  constant INT_N_FOUR  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-4, DATA_SIZE));
  constant INT_N_FIVE  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-5, DATA_SIZE));
  constant INT_N_SIX   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-6, DATA_SIZE));
  constant INT_N_SEVEN : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-7, DATA_SIZE));
  constant INT_N_EIGHT : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-8, DATA_SIZE));
  constant INT_N_NINE  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_signed(-9, DATA_SIZE));

  -- FLOATS
  constant FLOAT_P_ZERO  : std_logic_vector(DATA_SIZE-1 downto 0) := X"00000000";
  constant FLOAT_P_ONE   : std_logic_vector(DATA_SIZE-1 downto 0) := X"3f8ccccd";
  constant FLOAT_P_TWO   : std_logic_vector(DATA_SIZE-1 downto 0) := X"400ccccd";
  constant FLOAT_P_THREE : std_logic_vector(DATA_SIZE-1 downto 0) := X"40533333";
  constant FLOAT_P_FOUR  : std_logic_vector(DATA_SIZE-1 downto 0) := X"408ccccd";
  constant FLOAT_P_FIVE  : std_logic_vector(DATA_SIZE-1 downto 0) := X"40b00000";
  constant FLOAT_P_SIX   : std_logic_vector(DATA_SIZE-1 downto 0) := X"40d33333";
  constant FLOAT_P_SEVEN : std_logic_vector(DATA_SIZE-1 downto 0) := X"40f66666";
  constant FLOAT_P_EIGHT : std_logic_vector(DATA_SIZE-1 downto 0) := X"410ccccd";
  constant FLOAT_P_NINE  : std_logic_vector(DATA_SIZE-1 downto 0) := X"411e6666";
  constant FLOAT_P_INF   : std_logic_vector(DATA_SIZE-1 downto 0) := X"7f800000";

  constant FLOAT_N_ZERO  : std_logic_vector(DATA_SIZE-1 downto 0) := X"80000000";
  constant FLOAT_N_ONE   : std_logic_vector(DATA_SIZE-1 downto 0) := X"bf8ccccd";
  constant FLOAT_N_TWO   : std_logic_vector(DATA_SIZE-1 downto 0) := X"c00ccccd";
  constant FLOAT_N_THREE : std_logic_vector(DATA_SIZE-1 downto 0) := X"c0533333";
  constant FLOAT_N_FOUR  : std_logic_vector(DATA_SIZE-1 downto 0) := X"c08ccccd";
  constant FLOAT_N_FIVE  : std_logic_vector(DATA_SIZE-1 downto 0) := X"c0b00000";
  constant FLOAT_N_SIX   : std_logic_vector(DATA_SIZE-1 downto 0) := X"c0d33333";
  constant FLOAT_N_SEVEN : std_logic_vector(DATA_SIZE-1 downto 0) := X"c0f66666";
  constant FLOAT_N_EIGHT : std_logic_vector(DATA_SIZE-1 downto 0) := X"c10ccccd";
  constant FLOAT_N_NINE  : std_logic_vector(DATA_SIZE-1 downto 0) := X"c11e6666";
  constant FLOAT_N_INF   : std_logic_vector(DATA_SIZE-1 downto 0) := X"ff800000";

  -- Integer Buffer
  constant TENSOR_SAMPLE_A : tensor_buffer := (((FLOAT_P_TWO, FLOAT_P_ONE, FLOAT_P_FOUR), (FLOAT_P_NINE, FLOAT_P_FOUR, FLOAT_P_TWO), (FLOAT_P_ONE, FLOAT_P_ONE, FLOAT_P_TWO)), ((FLOAT_P_EIGHT, FLOAT_P_SIX, FLOAT_P_TWO), (FLOAT_P_EIGHT, FLOAT_P_FIVE, FLOAT_P_TWO), (FLOAT_P_ONE, FLOAT_P_FOUR, FLOAT_P_ONE)), ((FLOAT_P_THREE, FLOAT_P_ONE, FLOAT_P_SIX), (FLOAT_P_FIVE, FLOAT_P_ZERO, FLOAT_P_FOUR), (FLOAT_P_FIVE, FLOAT_P_EIGHT, FLOAT_P_FIVE)));
  constant TENSOR_SAMPLE_B : tensor_buffer := (((FLOAT_P_ONE, FLOAT_P_THREE, FLOAT_P_ONE), (FLOAT_P_TWO, FLOAT_P_FOUR, FLOAT_P_EIGHT), (FLOAT_P_FOUR, FLOAT_P_ONE, FLOAT_P_TWO)), ((FLOAT_P_NINE, FLOAT_P_ONE, FLOAT_P_FIVE), (FLOAT_P_NINE, FLOAT_P_EIGHT, FLOAT_P_ONE), (FLOAT_P_FIVE, FLOAT_P_EIGHT, FLOAT_P_FOUR)), ((FLOAT_P_FIVE, FLOAT_P_FOUR, FLOAT_P_ONE), (FLOAT_P_THREE, FLOAT_P_FOUR, FLOAT_P_SIX), (FLOAT_P_ONE, FLOAT_P_EIGHT, FLOAT_P_EIGHT)));

  constant MATRIX_SAMPLE_A : matrix_buffer := ((FLOAT_P_ONE, FLOAT_P_FOUR, FLOAT_P_ONE), (FLOAT_P_ZERO, FLOAT_P_EIGHT, FLOAT_P_FOUR), (FLOAT_P_FIVE, FLOAT_P_THREE, FLOAT_P_NINE));
  constant MATRIX_SAMPLE_B : matrix_buffer := ((FLOAT_P_ONE, FLOAT_P_TWO, FLOAT_P_SIX), (FLOAT_P_ONE, FLOAT_P_THREE, FLOAT_P_SIX), (FLOAT_P_EIGHT, FLOAT_P_FOUR, FLOAT_P_FOUR));

  constant VECTOR_SAMPLE_A : vector_buffer := (FLOAT_P_FOUR, FLOAT_P_SEVEN, FLOAT_N_THREE);
  constant VECTOR_SAMPLE_B : vector_buffer := (FLOAT_P_THREE, FLOAT_N_NINE, FLOAT_N_ONE);

  constant SCALAR_SAMPLE_A : std_logic_vector(DATA_SIZE-1 downto 0) := FLOAT_P_NINE;
  constant SCALAR_SAMPLE_B : std_logic_vector(DATA_SIZE-1 downto 0) := FLOAT_N_FOUR;

  -- SCALAR-FUNCTIONALITY
  signal STIMULUS_NTM_SCALAR_ADDER_TEST      : boolean := false;
  signal STIMULUS_NTM_SCALAR_MULTIPLIER_TEST : boolean := false;
  signal STIMULUS_NTM_SCALAR_DIVIDER_TEST    : boolean := false;

  signal STIMULUS_NTM_SCALAR_FLOAT_ADDER_TEST      : boolean := false;
  signal STIMULUS_NTM_SCALAR_FLOAT_MULTIPLIER_TEST : boolean := false;
  signal STIMULUS_NTM_SCALAR_FLOAT_DIVIDER_TEST    : boolean := false;

  signal STIMULUS_NTM_SCALAR_ADDER_CASE_0      : boolean := false;
  signal STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_0 : boolean := false;
  signal STIMULUS_NTM_SCALAR_DIVIDER_CASE_0    : boolean := false;

  signal STIMULUS_NTM_SCALAR_FLOAT_ADDER_CASE_0      : boolean := false;
  signal STIMULUS_NTM_SCALAR_FLOAT_MULTIPLIER_CASE_0 : boolean := false;
  signal STIMULUS_NTM_SCALAR_FLOAT_DIVIDER_CASE_0    : boolean := false;

  signal STIMULUS_NTM_SCALAR_ADDER_CASE_1      : boolean := false;
  signal STIMULUS_NTM_SCALAR_MULTIPLIER_CASE_1 : boolean := false;
  signal STIMULUS_NTM_SCALAR_DIVIDER_CASE_1    : boolean := false;

  signal STIMULUS_NTM_SCALAR_FLOAT_ADDER_CASE_1      : boolean := false;
  signal STIMULUS_NTM_SCALAR_FLOAT_MULTIPLIER_CASE_1 : boolean := false;
  signal STIMULUS_NTM_SCALAR_FLOAT_DIVIDER_CASE_1    : boolean := false;

  -- VECTOR-FUNCTIONALITY
  signal STIMULUS_NTM_VECTOR_FLOAT_ADDER_TEST      : boolean := false;
  signal STIMULUS_NTM_VECTOR_FLOAT_MULTIPLIER_TEST : boolean := false;
  signal STIMULUS_NTM_VECTOR_FLOAT_DIVIDER_TEST    : boolean := false;

  signal STIMULUS_NTM_VECTOR_FLOAT_ADDER_CASE_0      : boolean := false;
  signal STIMULUS_NTM_VECTOR_FLOAT_MULTIPLIER_CASE_0 : boolean := false;
  signal STIMULUS_NTM_VECTOR_FLOAT_DIVIDER_CASE_0    : boolean := false;

  signal STIMULUS_NTM_VECTOR_FLOAT_ADDER_CASE_1      : boolean := false;
  signal STIMULUS_NTM_VECTOR_FLOAT_MULTIPLIER_CASE_1 : boolean := false;
  signal STIMULUS_NTM_VECTOR_FLOAT_DIVIDER_CASE_1    : boolean := false;

  -- MATRIX-FUNCTIONALITY
  signal STIMULUS_NTM_MATRIX_FLOAT_ADDER_TEST      : boolean := false;
  signal STIMULUS_NTM_MATRIX_FLOAT_MULTIPLIER_TEST : boolean := false;
  signal STIMULUS_NTM_MATRIX_FLOAT_DIVIDER_TEST    : boolean := false;

  signal STIMULUS_NTM_MATRIX_FLOAT_ADDER_CASE_0      : boolean := false;
  signal STIMULUS_NTM_MATRIX_FLOAT_MULTIPLIER_CASE_0 : boolean := false;
  signal STIMULUS_NTM_MATRIX_FLOAT_DIVIDER_CASE_0    : boolean := false;

  signal STIMULUS_NTM_MATRIX_FLOAT_ADDER_CASE_1      : boolean := false;
  signal STIMULUS_NTM_MATRIX_FLOAT_MULTIPLIER_CASE_1 : boolean := false;
  signal STIMULUS_NTM_MATRIX_FLOAT_DIVIDER_CASE_1    : boolean := false;

  -- TENSOR-FUNCTIONALITY
  signal STIMULUS_NTM_TENSOR_FLOAT_ADDER_TEST      : boolean := false;
  signal STIMULUS_NTM_TENSOR_FLOAT_MULTIPLIER_TEST : boolean := false;
  signal STIMULUS_NTM_TENSOR_FLOAT_DIVIDER_TEST    : boolean := false;

  signal STIMULUS_NTM_TENSOR_FLOAT_ADDER_CASE_0      : boolean := false;
  signal STIMULUS_NTM_TENSOR_FLOAT_MULTIPLIER_CASE_0 : boolean := false;
  signal STIMULUS_NTM_TENSOR_FLOAT_DIVIDER_CASE_0    : boolean := false;

  signal STIMULUS_NTM_TENSOR_FLOAT_ADDER_CASE_1      : boolean := false;
  signal STIMULUS_NTM_TENSOR_FLOAT_MULTIPLIER_CASE_1 : boolean := false;
  signal STIMULUS_NTM_TENSOR_FLOAT_DIVIDER_CASE_1    : boolean := false;

  -----------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------

  component ntm_float_stimulus is
    generic (
      -- SYSTEM-SIZE
      DATA_SIZE    : integer := 32;
      CONTROL_SIZE : integer := 64;

      X : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- x in 0 to X-1
      Y : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- y in 0 to Y-1
      N : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- j in 0 to N-1
      W : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- k in 0 to W-1
      L : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE));  -- l in 0 to L-1
      R : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(32, DATA_SIZE))  -- i in 0 to R-1
      );
    port (
      -- GLOBAL
      CLK : out std_logic;
      RST : out std_logic;

      -----------------------------------------------------------------------
      -- STIMULUS SCALAR FLOAT
      -----------------------------------------------------------------------

      -- SCALAR FLOAT ADDER
      -- CONTROL
      SCALAR_FLOAT_ADDER_START : out std_logic;
      SCALAR_FLOAT_ADDER_READY : in  std_logic;

      SCALAR_FLOAT_ADDER_OPERATION : out std_logic;

      -- DATA
      SCALAR_FLOAT_ADDER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_ADDER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_ADDER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_ADDER_OVERFLOW_OUT : in  std_logic;

      -- SCALAR FLOAT MULTIPLIER
      -- CONTROL
      SCALAR_FLOAT_MULTIPLIER_START : out std_logic;
      SCALAR_FLOAT_MULTIPLIER_READY : in  std_logic;

      -- DATA
      SCALAR_FLOAT_MULTIPLIER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_MULTIPLIER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_MULTIPLIER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_MULTIPLIER_OVERFLOW_OUT : in  std_logic;

      -- SCALAR FLOAT DIVIDER
      -- CONTROL
      SCALAR_FLOAT_DIVIDER_START : out std_logic;
      SCALAR_FLOAT_DIVIDER_READY : in  std_logic;

      -- DATA
      SCALAR_FLOAT_DIVIDER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_DIVIDER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_DIVIDER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      SCALAR_FLOAT_DIVIDER_OVERFLOW_OUT : in  std_logic;

      -----------------------------------------------------------------------
      -- STIMULUS VECTOR FLOAT
      -----------------------------------------------------------------------

      -- VECTOR FLOAT ADDER
      -- CONTROL
      VECTOR_FLOAT_ADDER_START : out std_logic;
      VECTOR_FLOAT_ADDER_READY : in  std_logic;

      VECTOR_FLOAT_ADDER_OPERATION : out std_logic;

      VECTOR_FLOAT_ADDER_DATA_A_IN_ENABLE : out std_logic;
      VECTOR_FLOAT_ADDER_DATA_B_IN_ENABLE : out std_logic;

      VECTOR_FLOAT_ADDER_DATA_OUT_ENABLE : in std_logic;

      -- DATA
      VECTOR_FLOAT_ADDER_SIZE_IN      : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      VECTOR_FLOAT_ADDER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_ADDER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_ADDER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_ADDER_OVERFLOW_OUT : in  std_logic;

      -- VECTOR FLOAT MULTIPLIER
      -- CONTROL
      VECTOR_FLOAT_MULTIPLIER_START : out std_logic;
      VECTOR_FLOAT_MULTIPLIER_READY : in  std_logic;

      VECTOR_FLOAT_MULTIPLIER_DATA_A_IN_ENABLE : out std_logic;
      VECTOR_FLOAT_MULTIPLIER_DATA_B_IN_ENABLE : out std_logic;

      VECTOR_FLOAT_MULTIPLIER_DATA_OUT_ENABLE : in std_logic;

      -- DATA
      VECTOR_FLOAT_MULTIPLIER_SIZE_IN      : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      VECTOR_FLOAT_MULTIPLIER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_MULTIPLIER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_MULTIPLIER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_MULTIPLIER_OVERFLOW_OUT : in  std_logic;

      -- VECTOR FLOAT DIVIDER
      -- CONTROL
      VECTOR_FLOAT_DIVIDER_START : out std_logic;
      VECTOR_FLOAT_DIVIDER_READY : in  std_logic;

      VECTOR_FLOAT_DIVIDER_DATA_A_IN_ENABLE : out std_logic;
      VECTOR_FLOAT_DIVIDER_DATA_B_IN_ENABLE : out std_logic;

      VECTOR_FLOAT_DIVIDER_DATA_OUT_ENABLE : in std_logic;

      -- DATA
      VECTOR_FLOAT_DIVIDER_SIZE_IN      : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      VECTOR_FLOAT_DIVIDER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_DIVIDER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_DIVIDER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      VECTOR_FLOAT_DIVIDER_OVERFLOW_OUT : in  std_logic;

      -----------------------------------------------------------------------
      -- STIMULUS MATRIX FLOAT
      -----------------------------------------------------------------------

      -- MATRIX FLOAT ADDER
      -- CONTROL
      MATRIX_FLOAT_ADDER_START : out std_logic;
      MATRIX_FLOAT_ADDER_READY : in  std_logic;

      MATRIX_FLOAT_ADDER_OPERATION : out std_logic;

      MATRIX_FLOAT_ADDER_DATA_A_IN_I_ENABLE : out std_logic;
      MATRIX_FLOAT_ADDER_DATA_A_IN_J_ENABLE : out std_logic;
      MATRIX_FLOAT_ADDER_DATA_B_IN_I_ENABLE : out std_logic;
      MATRIX_FLOAT_ADDER_DATA_B_IN_J_ENABLE : out std_logic;

      MATRIX_FLOAT_ADDER_DATA_OUT_I_ENABLE : in std_logic;
      MATRIX_FLOAT_ADDER_DATA_OUT_J_ENABLE : in std_logic;

      -- DATA
      MATRIX_FLOAT_ADDER_SIZE_I_IN    : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      MATRIX_FLOAT_ADDER_SIZE_J_IN    : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      MATRIX_FLOAT_ADDER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_ADDER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_ADDER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_ADDER_OVERFLOW_OUT : in  std_logic;

      -- MATRIX FLOAT MULTIPLIER
      -- CONTROL
      MATRIX_FLOAT_MULTIPLIER_START : out std_logic;
      MATRIX_FLOAT_MULTIPLIER_READY : in  std_logic;

      MATRIX_FLOAT_MULTIPLIER_DATA_A_IN_I_ENABLE : out std_logic;
      MATRIX_FLOAT_MULTIPLIER_DATA_A_IN_J_ENABLE : out std_logic;
      MATRIX_FLOAT_MULTIPLIER_DATA_B_IN_I_ENABLE : out std_logic;
      MATRIX_FLOAT_MULTIPLIER_DATA_B_IN_J_ENABLE : out std_logic;

      MATRIX_FLOAT_MULTIPLIER_DATA_OUT_I_ENABLE : in std_logic;
      MATRIX_FLOAT_MULTIPLIER_DATA_OUT_J_ENABLE : in std_logic;

      -- DATA
      MATRIX_FLOAT_MULTIPLIER_SIZE_I_IN    : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      MATRIX_FLOAT_MULTIPLIER_SIZE_J_IN    : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      MATRIX_FLOAT_MULTIPLIER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_MULTIPLIER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_MULTIPLIER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_MULTIPLIER_OVERFLOW_OUT : in  std_logic;

      -- MATRIX FLOAT DIVIDER
      -- CONTROL
      MATRIX_FLOAT_DIVIDER_START : out std_logic;
      MATRIX_FLOAT_DIVIDER_READY : in  std_logic;

      MATRIX_FLOAT_DIVIDER_DATA_A_IN_I_ENABLE : out std_logic;
      MATRIX_FLOAT_DIVIDER_DATA_A_IN_J_ENABLE : out std_logic;
      MATRIX_FLOAT_DIVIDER_DATA_B_IN_I_ENABLE : out std_logic;
      MATRIX_FLOAT_DIVIDER_DATA_B_IN_J_ENABLE : out std_logic;

      MATRIX_FLOAT_DIVIDER_DATA_OUT_I_ENABLE : in std_logic;
      MATRIX_FLOAT_DIVIDER_DATA_OUT_J_ENABLE : in std_logic;

      -- DATA
      MATRIX_FLOAT_DIVIDER_SIZE_I_IN    : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      MATRIX_FLOAT_DIVIDER_SIZE_J_IN    : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      MATRIX_FLOAT_DIVIDER_DATA_A_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_DIVIDER_DATA_B_IN    : out std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_DIVIDER_DATA_OUT     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      MATRIX_FLOAT_DIVIDER_OVERFLOW_OUT : in  std_logic;

      -----------------------------------------------------------------------
      -- STIMULUS TENSOR FLOAT
      -----------------------------------------------------------------------

      -- TENSOR ADDER
      -- CONTROL
      TENSOR_FLOAT_ADDER_START : out std_logic;
      TENSOR_FLOAT_ADDER_READY : in  std_logic;

      TENSOR_FLOAT_ADDER_OPERATION : out std_logic;

      TENSOR_FLOAT_ADDER_DATA_A_IN_I_ENABLE : out std_logic;
      TENSOR_FLOAT_ADDER_DATA_A_IN_J_ENABLE : out std_logic;
      TENSOR_FLOAT_ADDER_DATA_A_IN_K_ENABLE : out std_logic;
      TENSOR_FLOAT_ADDER_DATA_B_IN_I_ENABLE : out std_logic;
      TENSOR_FLOAT_ADDER_DATA_B_IN_J_ENABLE : out std_logic;
      TENSOR_FLOAT_ADDER_DATA_B_IN_K_ENABLE : out std_logic;

      TENSOR_FLOAT_ADDER_DATA_OUT_I_ENABLE : in std_logic;
      TENSOR_FLOAT_ADDER_DATA_OUT_J_ENABLE : in std_logic;
      TENSOR_FLOAT_ADDER_DATA_OUT_K_ENABLE : in std_logic;

      -- DATA
      TENSOR_FLOAT_ADDER_SIZE_I_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_ADDER_SIZE_J_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_ADDER_SIZE_K_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_ADDER_DATA_A_IN : out std_logic_vector(DATA_SIZE-1 downto 0);
      TENSOR_FLOAT_ADDER_DATA_B_IN : out std_logic_vector(DATA_SIZE-1 downto 0);

      TENSOR_FLOAT_ADDER_DATA_OUT     : in std_logic_vector(DATA_SIZE-1 downto 0);
      TENSOR_FLOAT_ADDER_OVERFLOW_OUT : in std_logic;

      -- TENSOR MULTIPLIER
      -- CONTROL
      TENSOR_FLOAT_MULTIPLIER_START : out std_logic;
      TENSOR_FLOAT_MULTIPLIER_READY : in  std_logic;

      TENSOR_FLOAT_MULTIPLIER_DATA_A_IN_I_ENABLE : out std_logic;
      TENSOR_FLOAT_MULTIPLIER_DATA_A_IN_J_ENABLE : out std_logic;
      TENSOR_FLOAT_MULTIPLIER_DATA_A_IN_K_ENABLE : out std_logic;
      TENSOR_FLOAT_MULTIPLIER_DATA_B_IN_I_ENABLE : out std_logic;
      TENSOR_FLOAT_MULTIPLIER_DATA_B_IN_J_ENABLE : out std_logic;
      TENSOR_FLOAT_MULTIPLIER_DATA_B_IN_K_ENABLE : out std_logic;

      TENSOR_FLOAT_MULTIPLIER_DATA_OUT_I_ENABLE : in std_logic;
      TENSOR_FLOAT_MULTIPLIER_DATA_OUT_J_ENABLE : in std_logic;
      TENSOR_FLOAT_MULTIPLIER_DATA_OUT_K_ENABLE : in std_logic;

      -- DATA
      TENSOR_FLOAT_MULTIPLIER_SIZE_I_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_MULTIPLIER_SIZE_J_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_MULTIPLIER_SIZE_K_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_MULTIPLIER_DATA_A_IN : out std_logic_vector(DATA_SIZE-1 downto 0);
      TENSOR_FLOAT_MULTIPLIER_DATA_B_IN : out std_logic_vector(DATA_SIZE-1 downto 0);

      TENSOR_FLOAT_MULTIPLIER_DATA_OUT     : in std_logic_vector(DATA_SIZE-1 downto 0);
      TENSOR_FLOAT_MULTIPLIER_OVERFLOW_OUT : in std_logic;

      -- TENSOR DIVIDER
      -- CONTROL
      TENSOR_FLOAT_DIVIDER_START : out std_logic;
      TENSOR_FLOAT_DIVIDER_READY : in  std_logic;

      TENSOR_FLOAT_DIVIDER_DATA_A_IN_I_ENABLE : out std_logic;
      TENSOR_FLOAT_DIVIDER_DATA_A_IN_J_ENABLE : out std_logic;
      TENSOR_FLOAT_DIVIDER_DATA_A_IN_K_ENABLE : out std_logic;
      TENSOR_FLOAT_DIVIDER_DATA_B_IN_I_ENABLE : out std_logic;
      TENSOR_FLOAT_DIVIDER_DATA_B_IN_J_ENABLE : out std_logic;
      TENSOR_FLOAT_DIVIDER_DATA_B_IN_K_ENABLE : out std_logic;

      TENSOR_FLOAT_DIVIDER_DATA_OUT_I_ENABLE : in std_logic;
      TENSOR_FLOAT_DIVIDER_DATA_OUT_J_ENABLE : in std_logic;
      TENSOR_FLOAT_DIVIDER_DATA_OUT_K_ENABLE : in std_logic;

      -- DATA
      TENSOR_FLOAT_DIVIDER_SIZE_I_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_DIVIDER_SIZE_J_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_DIVIDER_SIZE_K_IN : out std_logic_vector(CONTROL_SIZE-1 downto 0);
      TENSOR_FLOAT_DIVIDER_DATA_A_IN : out std_logic_vector(DATA_SIZE-1 downto 0);
      TENSOR_FLOAT_DIVIDER_DATA_B_IN : out std_logic_vector(DATA_SIZE-1 downto 0);

      TENSOR_FLOAT_DIVIDER_DATA_OUT     : in std_logic_vector(DATA_SIZE-1 downto 0);
      TENSOR_FLOAT_DIVIDER_OVERFLOW_OUT : in std_logic
      );
  end component;

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

end ntm_float_pkg;
