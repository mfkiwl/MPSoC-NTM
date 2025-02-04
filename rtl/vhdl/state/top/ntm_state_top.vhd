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
-- Author(s):
--   Paco Reina Campo <pacoreinacampo@queenfield.tech>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ntm_math_pkg.all;
use work.ntm_state_pkg.all;

entity ntm_state_top is
  generic (
    DATA_SIZE    : integer := 32;
    CONTROL_SIZE : integer := 64
    );
  port (
    -- GLOBAL
    CLK : in std_logic;
    RST : in std_logic;

    -- CONTROL
    START : in  std_logic;
    READY : out std_logic;

    DATA_A_IN_I_ENABLE : in std_logic;
    DATA_A_IN_J_ENABLE : in std_logic;
    DATA_B_IN_I_ENABLE : in std_logic;
    DATA_B_IN_J_ENABLE : in std_logic;
    DATA_C_IN_I_ENABLE : in std_logic;
    DATA_C_IN_J_ENABLE : in std_logic;
    DATA_D_IN_I_ENABLE : in std_logic;
    DATA_D_IN_J_ENABLE : in std_logic;

    DATA_A_I_ENABLE : out std_logic;
    DATA_A_J_ENABLE : out std_logic;
    DATA_B_I_ENABLE : out std_logic;
    DATA_B_J_ENABLE : out std_logic;
    DATA_C_I_ENABLE : out std_logic;
    DATA_C_J_ENABLE : out std_logic;
    DATA_D_I_ENABLE : out std_logic;
    DATA_D_J_ENABLE : out std_logic;

    DATA_K_IN_I_ENABLE : in std_logic;
    DATA_K_IN_J_ENABLE : in std_logic;

    DATA_K_I_ENABLE : out std_logic;
    DATA_K_J_ENABLE : out std_logic;

    DATA_X_OUT_ENABLE : out std_logic;
    DATA_Y_OUT_ENABLE : out std_logic;

    -- DATA
    SIZE_A_I_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_C_I_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_C_J_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_D_I_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_D_J_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

    DATA_A_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
    DATA_B_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
    DATA_C_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
    DATA_D_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

    DATA_K_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

    DATA_X_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
    DATA_Y_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity;

architecture ntm_state_top_architecture of ntm_state_top is

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------

  constant ZERO_CONTROL  : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(0, CONTROL_SIZE));
  constant ONE_CONTROL   : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(1, CONTROL_SIZE));
  constant TWO_CONTROL   : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(2, CONTROL_SIZE));
  constant THREE_CONTROL : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(3, CONTROL_SIZE));

  constant ZERO_DATA  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(0, DATA_SIZE));
  constant ONE_DATA   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(1, DATA_SIZE));
  constant TWO_DATA   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(2, DATA_SIZE));
  constant THREE_DATA : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(3, DATA_SIZE));

  constant FULL  : std_logic_vector(DATA_SIZE-1 downto 0) := (others => '1');
  constant EMPTY : std_logic_vector(DATA_SIZE-1 downto 0) := (others => '0');

  constant EULER : std_logic_vector(DATA_SIZE-1 downto 0) := (others => '0');

  -----------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------

  -- STATE OUTPUT
  -- CONTROL
  signal start_vector_output : std_logic;
  signal ready_vector_output : std_logic;

  signal data_a_in_i_enable_vector_output : std_logic;
  signal data_a_in_j_enable_vector_output : std_logic;
  signal data_b_in_i_enable_vector_output : std_logic;
  signal data_b_in_j_enable_vector_output : std_logic;
  signal data_c_in_i_enable_vector_output : std_logic;
  signal data_c_in_j_enable_vector_output : std_logic;
  signal data_d_in_i_enable_vector_output : std_logic;
  signal data_d_in_j_enable_vector_output : std_logic;

  signal data_a_i_enable_vector_output : std_logic;
  signal data_a_j_enable_vector_output : std_logic;
  signal data_b_i_enable_vector_output : std_logic;
  signal data_b_j_enable_vector_output : std_logic;
  signal data_c_i_enable_vector_output : std_logic;
  signal data_c_j_enable_vector_output : std_logic;
  signal data_d_i_enable_vector_output : std_logic;
  signal data_d_j_enable_vector_output : std_logic;

  signal data_k_in_i_enable_vector_output : std_logic;
  signal data_k_in_j_enable_vector_output : std_logic;

  signal data_k_i_enable_vector_output : std_logic;
  signal data_k_j_enable_vector_output : std_logic;

  signal data_x_out_enable_vector_output : std_logic;
  signal data_y_out_enable_vector_output : std_logic;

  -- DATA
  signal size_a_in_i_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_a_in_j_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_b_in_i_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_b_in_j_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_c_in_i_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_c_in_j_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_d_in_i_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_d_in_j_vector_output : std_logic_vector(CONTROL_SIZE-1 downto 0);

  signal data_a_in_vector_output : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_b_in_vector_output : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_c_in_vector_output : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_d_in_vector_output : std_logic_vector(DATA_SIZE-1 downto 0);

  signal data_k_in_vector_output : std_logic_vector(DATA_SIZE-1 downto 0);

  signal data_x_out_vector_output : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_y_out_vector_output : std_logic_vector(DATA_SIZE-1 downto 0);

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  -- x(k+1) = A·x(k) + B·u(k)
  -- y(k) = C·x(k) + D·u(k)

  -- x(k) = exp(A,k)·x(0) + summation(exp(A,k-j-1)·B·u(j))[j in 0 to k-1]
  -- y(k) = C·exp(A,k)·x(0) + summation(C·exp(A,k-j)·B·u(j))[j in 0 to k-1] + D·u(k)

  -- CONTROL

  -- STATE OUTPUT
  -- CONTROL
  start_vector_output <= START;

  READY <= ready_vector_output;

  data_a_in_i_enable_vector_output <= DATA_A_IN_I_ENABLE;
  data_a_in_j_enable_vector_output <= DATA_A_IN_J_ENABLE;
  data_b_in_i_enable_vector_output <= DATA_B_IN_I_ENABLE;
  data_b_in_j_enable_vector_output <= DATA_B_IN_J_ENABLE;
  data_c_in_i_enable_vector_output <= DATA_C_IN_I_ENABLE;
  data_c_in_j_enable_vector_output <= DATA_C_IN_J_ENABLE;
  data_d_in_i_enable_vector_output <= DATA_D_IN_I_ENABLE;
  data_d_in_j_enable_vector_output <= DATA_D_IN_J_ENABLE;

  DATA_A_I_ENABLE <= data_a_i_enable_vector_output;
  DATA_A_J_ENABLE <= data_a_j_enable_vector_output;
  DATA_B_I_ENABLE <= data_b_i_enable_vector_output;
  DATA_B_J_ENABLE <= data_b_j_enable_vector_output;
  DATA_C_I_ENABLE <= data_c_i_enable_vector_output;
  DATA_C_J_ENABLE <= data_c_j_enable_vector_output;
  DATA_D_I_ENABLE <= data_d_i_enable_vector_output;
  DATA_D_J_ENABLE <= data_d_j_enable_vector_output;

  data_k_in_i_enable_vector_output <= DATA_K_IN_I_ENABLE;
  data_k_in_j_enable_vector_output <= DATA_K_IN_J_ENABLE;

  DATA_K_I_ENABLE <= data_k_i_enable_vector_output;
  DATA_K_J_ENABLE <= data_k_j_enable_vector_output;

  data_x_out_enable_vector_output <= DATA_X_OUT_ENABLE;
  data_y_out_enable_vector_output <= DATA_Y_OUT_ENABLE;

  -- DATA
  size_a_in_i_vector_output <= SIZE_A_I_IN;
  size_a_in_j_vector_output <= SIZE_A_J_IN;
  size_b_in_i_vector_output <= SIZE_B_I_IN;
  size_b_in_j_vector_output <= SIZE_B_J_IN;
  size_c_in_i_vector_output <= SIZE_C_I_IN;
  size_c_in_j_vector_output <= SIZE_C_J_IN;
  size_d_in_i_vector_output <= SIZE_D_I_IN;
  size_d_in_j_vector_output <= SIZE_D_J_IN;

  data_a_in_vector_output <= DATA_A_IN;
  data_b_in_vector_output <= DATA_B_IN;
  data_c_in_vector_output <= DATA_C_IN;
  data_d_in_vector_output <= DATA_D_IN;

  data_k_in_vector_output <= DATA_K_IN;

  DATA_X_OUT <= data_x_out_vector_output;
  DATA_Y_OUT <= data_y_out_vector_output;

  -- VECTOR OUTPUT
  state_vector_output : ntm_state_vector_output
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_vector_output,
      READY => ready_vector_output,

      DATA_A_IN_I_ENABLE => data_a_in_i_enable_vector_output,
      DATA_A_IN_J_ENABLE => data_a_in_j_enable_vector_output,
      DATA_B_IN_I_ENABLE => data_b_in_i_enable_vector_output,
      DATA_B_IN_J_ENABLE => data_b_in_j_enable_vector_output,
      DATA_C_IN_I_ENABLE => data_c_in_i_enable_vector_output,
      DATA_C_IN_J_ENABLE => data_c_in_j_enable_vector_output,
      DATA_D_IN_I_ENABLE => data_d_in_i_enable_vector_output,
      DATA_D_IN_J_ENABLE => data_d_in_j_enable_vector_output,

      DATA_A_I_ENABLE => data_a_i_enable_vector_output,
      DATA_A_J_ENABLE => data_a_j_enable_vector_output,
      DATA_B_I_ENABLE => data_b_i_enable_vector_output,
      DATA_B_J_ENABLE => data_b_j_enable_vector_output,
      DATA_C_I_ENABLE => data_c_i_enable_vector_output,
      DATA_C_J_ENABLE => data_c_j_enable_vector_output,
      DATA_D_I_ENABLE => data_d_i_enable_vector_output,
      DATA_D_J_ENABLE => data_d_j_enable_vector_output,

      DATA_K_IN_I_ENABLE => data_k_in_i_enable_vector_output,
      DATA_K_IN_J_ENABLE => data_k_in_j_enable_vector_output,

      DATA_K_I_ENABLE => data_k_i_enable_vector_output,
      DATA_K_J_ENABLE => data_k_j_enable_vector_output,

      DATA_X_OUT_ENABLE => data_x_out_enable_vector_output,
      DATA_Y_OUT_ENABLE => data_y_out_enable_vector_output,

      -- DATA
      SIZE_A_I_IN => size_a_in_i_vector_output,
      SIZE_A_J_IN => size_a_in_j_vector_output,
      SIZE_B_I_IN => size_b_in_i_vector_output,
      SIZE_B_J_IN => size_b_in_j_vector_output,
      SIZE_C_I_IN => size_c_in_i_vector_output,
      SIZE_C_J_IN => size_c_in_j_vector_output,
      SIZE_D_I_IN => size_d_in_i_vector_output,
      SIZE_D_J_IN => size_d_in_j_vector_output,

      DATA_A_IN => data_a_in_vector_output,
      DATA_B_IN => data_b_in_vector_output,
      DATA_C_IN => data_c_in_vector_output,
      DATA_D_IN => data_d_in_vector_output,

      DATA_K_IN => data_k_in_vector_output,

      DATA_X_OUT => data_x_out_vector_output,
      DATA_Y_OUT => data_y_out_vector_output
      );

end architecture;
