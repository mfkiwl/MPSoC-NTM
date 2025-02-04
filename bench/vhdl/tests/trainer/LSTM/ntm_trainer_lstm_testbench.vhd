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

use work.ntm_math_pkg.all;
use work.ntm_lstm_controller_pkg.all;
use work.ntm_trainer_lstm_pkg.all;

entity ntm_trainer_lstm_testbench is
  generic (
    -- SYSTEM-SIZE
    DATA_SIZE    : integer := 32;
    CONTROL_SIZE : integer := 64;

    X : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(64, DATA_SIZE));  -- x in 0 to X-1
    Y : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(64, DATA_SIZE));  -- y in 0 to Y-1
    N : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(64, DATA_SIZE));  -- j in 0 to N-1
    W : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(64, DATA_SIZE));  -- k in 0 to W-1
    L : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(64, DATA_SIZE));  -- l in 0 to L-1
    R : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(64, DATA_SIZE));  -- i in 0 to R-1

    -- FUNCTIONALITY
    ENABLE_NTM_SCALAR_INTEGER_ADDER_TEST      : boolean := false;
    ENABLE_NTM_SCALAR_INTEGER_MULTIPLIER_TEST : boolean := false;
    ENABLE_NTM_SCALAR_INTEGER_DIVIDER_TEST    : boolean := false
    );
end ntm_trainer_lstm_testbench;

architecture ntm_trainer_lstm_testbench_architecture of ntm_trainer_lstm_testbench is

  -----------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------

  -- GLOBAL
  signal CLK : std_logic;
  signal RST : std_logic;

  -- CONTROLLER
  -- CONTROL
  signal start_controller : std_logic;
  signal ready_controller : std_logic;

  signal w_in_l_enable_controller : std_logic;
  signal w_in_x_enable_controller : std_logic;

  signal k_in_i_enable_controller : std_logic;
  signal k_in_l_enable_controller : std_logic;
  signal k_in_k_enable_controller : std_logic;

  signal u_in_l_enable_controller : std_logic;
  signal u_in_p_enable_controller : std_logic;

  signal b_in_enable_controller : std_logic;

  signal x_in_enable_controller : std_logic;

  signal x_out_enable_controller : std_logic;

  signal r_in_i_enable_controller : std_logic;
  signal r_in_k_enable_controller : std_logic;

  signal r_out_i_enable_controller : std_logic;
  signal r_out_k_enable_controller : std_logic;

  signal h_in_enable_controller : std_logic;

  signal w_out_l_enable_controller : std_logic;
  signal w_out_x_enable_controller : std_logic;

  signal k_out_i_enable_controller : std_logic;
  signal k_out_l_enable_controller : std_logic;
  signal k_out_k_enable_controller : std_logic;

  signal u_out_l_enable_controller : std_logic;
  signal u_out_p_enable_controller : std_logic;

  signal b_out_enable_controller : std_logic;

  signal h_out_enable_controller : std_logic;

  -- DATA
  signal size_x_in_controller : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_w_in_controller : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_l_in_controller : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_r_in_controller : std_logic_vector(CONTROL_SIZE-1 downto 0);

  signal w_in_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal k_in_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal u_in_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal b_in_controller : std_logic_vector(DATA_SIZE-1 downto 0);

  signal x_in_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal r_in_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal h_in_controller : std_logic_vector(DATA_SIZE-1 downto 0);

  signal w_out_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal k_out_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal u_out_controller : std_logic_vector(DATA_SIZE-1 downto 0);
  signal b_out_controller : std_logic_vector(DATA_SIZE-1 downto 0);

  signal h_out_controller : std_logic_vector(DATA_SIZE-1 downto 0);

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  -- STIMULUS
  ntm_trainer_lstm_stimulus_i : ntm_trainer_lstm_stimulus
    generic map (
      -- SYSTEM-SIZE
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE,

      X => X,
      Y => Y,
      N => N,
      W => W,
      L => L,
      R => R
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      NTM_TRAINER_LSTM_START => start_controller,
      NTM_TRAINER_LSTM_READY => ready_controller,

      NTM_TRAINER_LSTM_W_IN_L_ENABLE => w_in_l_enable_controller,
      NTM_TRAINER_LSTM_W_IN_X_ENABLE => w_in_x_enable_controller,

      NTM_TRAINER_LSTM_K_IN_I_ENABLE => k_in_i_enable_controller,
      NTM_TRAINER_LSTM_K_IN_L_ENABLE => k_in_l_enable_controller,
      NTM_TRAINER_LSTM_K_IN_K_ENABLE => k_in_k_enable_controller,

      NTM_TRAINER_LSTM_U_IN_L_ENABLE => u_in_l_enable_controller,
      NTM_TRAINER_LSTM_U_IN_P_ENABLE => u_in_p_enable_controller,

      NTM_TRAINER_LSTM_B_IN_ENABLE => b_in_enable_controller,

      NTM_TRAINER_LSTM_X_IN_ENABLE => x_in_enable_controller,

      NTM_TRAINER_LSTM_X_OUT_ENABLE => x_out_enable_controller,

      NTM_TRAINER_LSTM_R_IN_I_ENABLE => r_in_i_enable_controller,
      NTM_TRAINER_LSTM_R_IN_K_ENABLE => r_in_k_enable_controller,

      NTM_TRAINER_LSTM_R_OUT_I_ENABLE => r_out_i_enable_controller,
      NTM_TRAINER_LSTM_R_OUT_K_ENABLE => r_out_k_enable_controller,

      NTM_TRAINER_LSTM_H_IN_ENABLE => h_in_enable_controller,

      NTM_TRAINER_LSTM_W_OUT_L_ENABLE => w_out_l_enable_controller,
      NTM_TRAINER_LSTM_W_OUT_X_ENABLE => w_out_x_enable_controller,

      NTM_TRAINER_LSTM_K_OUT_I_ENABLE => k_out_i_enable_controller,
      NTM_TRAINER_LSTM_K_OUT_L_ENABLE => k_out_l_enable_controller,
      NTM_TRAINER_LSTM_K_OUT_K_ENABLE => k_out_k_enable_controller,

      NTM_TRAINER_LSTM_U_OUT_L_ENABLE => u_out_l_enable_controller,
      NTM_TRAINER_LSTM_U_OUT_P_ENABLE => u_out_p_enable_controller,

      NTM_TRAINER_LSTM_B_OUT_ENABLE => b_out_enable_controller,

      NTM_TRAINER_LSTM_H_OUT_ENABLE => h_out_enable_controller,

      -- DATA
      NTM_TRAINER_LSTM_SIZE_X_IN => size_x_in_controller,
      NTM_TRAINER_LSTM_SIZE_W_IN => size_w_in_controller,
      NTM_TRAINER_LSTM_SIZE_L_IN => size_l_in_controller,
      NTM_TRAINER_LSTM_SIZE_R_IN => size_r_in_controller,

      NTM_TRAINER_LSTM_W_IN => w_in_controller,
      NTM_TRAINER_LSTM_K_IN => k_in_controller,
      NTM_TRAINER_LSTM_U_IN => u_in_controller,
      NTM_TRAINER_LSTM_B_IN => b_in_controller,

      NTM_TRAINER_LSTM_X_IN => x_in_controller,
      NTM_TRAINER_LSTM_R_IN => r_in_controller,
      NTM_TRAINER_LSTM_H_IN => h_in_controller,

      NTM_TRAINER_LSTM_W_OUT => w_out_controller,
      NTM_TRAINER_LSTM_K_OUT => k_out_controller,
      NTM_TRAINER_LSTM_U_OUT => u_out_controller,
      NTM_TRAINER_LSTM_B_OUT => b_out_controller,

      NTM_TRAINER_LSTM_H_OUT => h_out_controller
      );

  -- CONTROLLER
  ntm_controller_i : ntm_controller
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_controller,
      READY => ready_controller,

      W_IN_L_ENABLE => w_in_l_enable_controller,
      W_IN_X_ENABLE => w_in_x_enable_controller,

      K_IN_I_ENABLE => k_in_i_enable_controller,
      K_IN_L_ENABLE => k_in_l_enable_controller,
      K_IN_K_ENABLE => k_in_k_enable_controller,

      U_IN_L_ENABLE => u_in_l_enable_controller,
      U_IN_P_ENABLE => u_in_p_enable_controller,

      B_IN_ENABLE => b_in_enable_controller,

      X_IN_ENABLE => x_in_enable_controller,

      X_OUT_ENABLE => x_out_enable_controller,

      R_IN_I_ENABLE => r_in_i_enable_controller,
      R_IN_K_ENABLE => r_in_k_enable_controller,

      R_OUT_I_ENABLE => r_out_i_enable_controller,
      R_OUT_K_ENABLE => r_out_k_enable_controller,

      H_IN_ENABLE => h_in_enable_controller,

      W_OUT_L_ENABLE => w_out_l_enable_controller,
      W_OUT_X_ENABLE => w_out_x_enable_controller,

      K_OUT_I_ENABLE => k_out_i_enable_controller,
      K_OUT_L_ENABLE => k_out_l_enable_controller,
      K_OUT_K_ENABLE => k_out_k_enable_controller,

      U_OUT_L_ENABLE => u_out_l_enable_controller,
      U_OUT_P_ENABLE => u_out_p_enable_controller,

      B_OUT_ENABLE => b_out_enable_controller,

      H_OUT_ENABLE => h_out_enable_controller,

      -- DATA
      SIZE_X_IN => size_x_in_controller,
      SIZE_W_IN => size_w_in_controller,
      SIZE_L_IN => size_l_in_controller,
      SIZE_R_IN => size_r_in_controller,

      W_IN => w_in_controller,
      K_IN => k_in_controller,
      U_IN => u_in_controller,
      B_IN => b_in_controller,

      X_IN => x_in_controller,
      R_IN => r_in_controller,
      H_IN => h_in_controller,

      W_OUT => w_out_controller,
      K_OUT => k_out_controller,
      U_OUT => u_out_controller,
      B_OUT => b_out_controller,

      H_OUT => h_out_controller
      );

end ntm_trainer_lstm_testbench_architecture;
