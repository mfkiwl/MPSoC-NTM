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

use work.ntm_arithmetic_pkg.all;
use work.ntm_math_pkg.all;

entity dnc_forward_weighting is
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

    L_IN_I_ENABLE : in std_logic;       -- for i in 0 to R-1 (read heads flow)
    L_IN_G_ENABLE : in std_logic;       -- for g in 0 to N-1 (square tensor)
    L_IN_J_ENABLE : in std_logic;       -- for j in 0 to N-1 (square tensor)

    W_IN_I_ENABLE : in std_logic;       -- for i in 0 to R-1 (read heads flow)
    W_IN_J_ENABLE : in std_logic;       -- for j in 0 to N-1

    F_I_ENABLE : out std_logic;         -- for i in 0 to R-1 (read heads flow)
    F_J_ENABLE : out std_logic;         -- for j in 0 to N-1

    F_OUT_I_ENABLE : out std_logic;     -- for i in 0 to R-1 (read heads flow)
    F_OUT_J_ENABLE : out std_logic;     -- for j in 0 to N-1

    -- DATA
    SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_N_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

    L_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

    W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

    F_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity;

architecture dnc_forward_weighting_architecture of dnc_forward_weighting is

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

  -- TENSOR PRODUCT
  -- CONTROL
  signal start_tensor_product : std_logic;
  signal ready_tensor_product : std_logic;

  signal data_a_in_i_enable_tensor_product : std_logic;
  signal data_a_in_j_enable_tensor_product : std_logic;
  signal data_a_in_k_enable_tensor_product : std_logic;
  signal data_b_in_i_enable_tensor_product : std_logic;
  signal data_b_in_j_enable_tensor_product : std_logic;
  signal data_b_in_k_enable_tensor_product : std_logic;

  signal data_i_enable_tensor_product : std_logic;
  signal data_j_enable_tensor_product : std_logic;
  signal data_k_enable_tensor_product : std_logic;

  signal data_out_i_enable_tensor_product : std_logic;
  signal data_out_j_enable_tensor_product : std_logic;
  signal data_out_k_enable_tensor_product : std_logic;

  -- DATA
  signal size_a_i_in_tensor_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_a_j_in_tensor_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_a_k_in_tensor_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_b_i_in_tensor_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_b_j_in_tensor_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_b_k_in_tensor_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal data_a_in_tensor_product   : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_b_in_tensor_product   : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_out_tensor_product    : std_logic_vector(DATA_SIZE-1 downto 0);

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  -- f(t;i;j) = L(t;g;j)·w(t-1;i;j)

  -- ASSIGNATIONS
  -- CONTROL
  start_tensor_product <= START;

  READY <= ready_tensor_product;

  data_a_in_i_enable_tensor_product <= L_IN_I_ENABLE;
  data_a_in_j_enable_tensor_product <= L_IN_G_ENABLE;
  data_a_in_k_enable_tensor_product <= L_IN_J_ENABLE;
  data_b_in_i_enable_tensor_product <= W_IN_I_ENABLE;
  data_b_in_j_enable_tensor_product <= W_IN_J_ENABLE;
  data_b_in_k_enable_tensor_product <= '0';

  F_I_ENABLE <= data_i_enable_tensor_product;
  F_J_ENABLE <= data_j_enable_tensor_product;

  F_OUT_I_ENABLE <= data_out_i_enable_tensor_product;
  F_OUT_J_ENABLE <= data_out_j_enable_tensor_product;

  -- DATA
  size_a_i_in_tensor_product <= SIZE_R_IN;
  size_a_j_in_tensor_product <= SIZE_N_IN;
  size_a_k_in_tensor_product <= SIZE_N_IN;
  size_b_i_in_tensor_product <= SIZE_R_IN;
  size_b_j_in_tensor_product <= SIZE_N_IN;
  size_b_k_in_tensor_product <= ONE_CONTROL;
  data_a_in_tensor_product   <= L_IN;
  data_b_in_tensor_product   <= W_IN;

  F_OUT <= data_out_tensor_product;

  -- TENSOR PRODUCT
  tensor_product : ntm_tensor_product
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_tensor_product,
      READY => ready_tensor_product,

      DATA_A_IN_I_ENABLE => data_a_in_i_enable_tensor_product,
      DATA_A_IN_J_ENABLE => data_a_in_j_enable_tensor_product,
      DATA_A_IN_K_ENABLE => data_a_in_k_enable_tensor_product,
      DATA_B_IN_I_ENABLE => data_b_in_i_enable_tensor_product,
      DATA_B_IN_J_ENABLE => data_b_in_j_enable_tensor_product,
      DATA_B_IN_K_ENABLE => data_b_in_k_enable_tensor_product,

      DATA_I_ENABLE => data_i_enable_tensor_product,
      DATA_J_ENABLE => data_j_enable_tensor_product,
      DATA_K_ENABLE => data_k_enable_tensor_product,

      DATA_OUT_I_ENABLE => data_out_i_enable_tensor_product,
      DATA_OUT_J_ENABLE => data_out_j_enable_tensor_product,
      DATA_OUT_K_ENABLE => data_out_k_enable_tensor_product,

      -- DATA
      SIZE_A_I_IN => size_a_i_in_tensor_product,
      SIZE_A_J_IN => size_a_j_in_tensor_product,
      SIZE_A_K_IN => size_a_k_in_tensor_product,
      SIZE_B_I_IN => size_b_i_in_tensor_product,
      SIZE_B_J_IN => size_b_j_in_tensor_product,
      SIZE_B_K_IN => size_b_k_in_tensor_product,
      DATA_A_IN   => data_a_in_tensor_product,
      DATA_B_IN   => data_b_in_tensor_product,
      DATA_OUT    => data_out_tensor_product
      );

end architecture;
