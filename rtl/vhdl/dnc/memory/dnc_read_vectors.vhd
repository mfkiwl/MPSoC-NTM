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

entity dnc_read_vectors is
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

    M_IN_J_ENABLE : in std_logic;       -- for j in 0 to N-1
    M_IN_K_ENABLE : in std_logic;       -- for k in 0 to W-1

    M_OUT_J_ENABLE : out std_logic;     -- for j in 0 to N-1
    M_OUT_K_ENABLE : out std_logic;     -- for k in 0 to W-1

    W_IN_I_ENABLE : in std_logic;       -- for i in 0 to R-1 (read heads flow)
    W_IN_J_ENABLE : in std_logic;       -- for j in 0 to N-1

    W_OUT_I_ENABLE : out std_logic;     -- for i in 0 to R-1 (read heads flow)
    W_OUT_J_ENABLE : out std_logic;     -- for j in 0 to N-1

    R_OUT_I_ENABLE : out std_logic;     -- for i in 0 to R-1 (read heads flow)
    R_OUT_K_ENABLE : out std_logic;     -- for k in 0 to W-1

    -- DATA
    SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_N_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

    M_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
    W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

    R_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity;

architecture dnc_read_vectors_architecture of dnc_read_vectors is

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  type controller_ctrl_fsm is (
    STARTER_STATE,                      -- STEP 0
    INPUT_I_FIRST_STATE,                -- STEP 1
    INPUT_J_FIRST_STATE,                -- STEP 2
    MATRIX_TRANSPOSE_I_STATE,           -- STEP 3
    MATRIX_TRANSPOSE_J_STATE,           -- STEP 4
    INPUT_I_SECOND_STATE,               -- STEP 5
    INPUT_J_SECOND_STATE,               -- STEP 6
    MATRIX_PRODUCT_I_STATE,             -- STEP 7
    MATRIX_PRODUCT_J_STATE              -- STEP 8
    );

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

  -- Finite State Machine
  signal controller_ctrl_fsm_int : controller_ctrl_fsm;

  -- Data Internal
  signal data_int_matrix_transpose : std_logic_vector(DATA_SIZE-1 downto 0);

  -- Control Internal
  signal index_i_transpose_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal index_j_transpose_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);

  signal index_i_product_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal index_j_product_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);

  -- MATRIX TRANSPOSE
  -- CONTROL
  signal start_matrix_transpose : std_logic;
  signal ready_matrix_transpose : std_logic;

  signal data_in_i_enable_matrix_transpose : std_logic;
  signal data_in_j_enable_matrix_transpose : std_logic;

  signal data_out_i_enable_matrix_transpose : std_logic;
  signal data_out_j_enable_matrix_transpose : std_logic;

  -- DATA
  signal size_i_in_matrix_transpose : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_j_in_matrix_transpose : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal data_in_matrix_transpose   : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_out_matrix_transpose  : std_logic_vector(DATA_SIZE-1 downto 0);

  -- MATRIX PRODUCT
  -- CONTROL
  signal start_matrix_product : std_logic;
  signal ready_matrix_product : std_logic;

  signal data_a_in_i_enable_matrix_product : std_logic;
  signal data_a_in_j_enable_matrix_product : std_logic;
  signal data_b_in_i_enable_matrix_product : std_logic;
  signal data_b_in_j_enable_matrix_product : std_logic;

  signal data_out_i_enable_matrix_product : std_logic;
  signal data_out_j_enable_matrix_product : std_logic;

  -- DATA
  signal size_a_i_in_matrix_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_a_j_in_matrix_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_b_i_in_matrix_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal size_b_j_in_matrix_product : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal data_a_in_matrix_product   : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_b_in_matrix_product   : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_out_matrix_product    : std_logic_vector(DATA_SIZE-1 downto 0);

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  -- r(t;i;k) = transpose(M(t;j;k))·w(t;i;j)

  -- CONTROL
  ctrl_fsm : process(CLK, RST)
  begin
    if (RST = '0') then
      -- Data Outputs
      R_OUT <= ZERO_DATA;

      -- Control Outputs
      READY <= '0';

      R_OUT_I_ENABLE <= '0';
      R_OUT_K_ENABLE <= '0';

      -- Control Internal
      index_i_transpose_loop <= ZERO_CONTROL;
      index_j_transpose_loop <= ZERO_CONTROL;

      index_i_product_loop <= ZERO_CONTROL;
      index_j_product_loop <= ZERO_CONTROL;

    elsif (rising_edge(CLK)) then

      case controller_ctrl_fsm_int is
        when STARTER_STATE =>           -- STEP 0
          -- Control Outputs
          READY <= '0';

          if (START = '1') then
            -- Control Internal
            index_i_transpose_loop <= ZERO_CONTROL;
            index_j_transpose_loop <= ZERO_CONTROL;

            index_i_product_loop <= ZERO_CONTROL;
            index_j_product_loop <= ZERO_CONTROL;

            -- FSM Control
            controller_ctrl_fsm_int <= INPUT_I_FIRST_STATE;
          end if;

        when INPUT_I_FIRST_STATE =>     -- STEP 1

          if (((M_IN_J_ENABLE = '1') and (M_IN_K_ENABLE = '1')) or (unsigned(index_j_transpose_loop) = unsigned(ZERO_CONTROL))) then
            -- Data Inputs
            size_i_in_matrix_transpose <= SIZE_N_IN;
            size_j_in_matrix_transpose <= SIZE_W_IN;

            data_in_matrix_transpose <= M_IN;

            -- Control Internal
            if (unsigned(index_j_transpose_loop) = unsigned(ZERO_CONTROL)) then
              start_matrix_transpose <= '1';
            end if;

            data_in_i_enable_matrix_transpose <= '1';
            data_in_j_enable_matrix_transpose <= '1';

            -- FSM Control
            controller_ctrl_fsm_int <= MATRIX_TRANSPOSE_J_STATE;
          end if;

          -- Control Outputs
          M_OUT_J_ENABLE <= '0';
          M_OUT_K_ENABLE <= '0';

        when INPUT_J_FIRST_STATE =>     -- STEP 2

          if (M_IN_K_ENABLE = '1') then
            -- Data Inputs
            data_in_matrix_transpose <= M_IN;

            -- Control Internal
            data_in_j_enable_matrix_transpose <= '1';

            -- FSM Control
            if (unsigned(index_j_transpose_loop) = unsigned(SIZE_W_IN)-unsigned(ONE_CONTROL)) then
              controller_ctrl_fsm_int <= MATRIX_TRANSPOSE_I_STATE;
            else
              controller_ctrl_fsm_int <= MATRIX_TRANSPOSE_J_STATE;
            end if;
          end if;

          -- Control Outputs
          M_OUT_K_ENABLE <= '0';

        when MATRIX_TRANSPOSE_I_STATE =>  -- STEP 3

          if (data_out_i_enable_matrix_transpose = '1' and data_out_j_enable_matrix_transpose = '1') then
            if ((unsigned(index_i_transpose_loop) = unsigned(SIZE_N_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_j_transpose_loop) = unsigned(SIZE_W_IN)-unsigned(ONE_CONTROL))) then
              -- Data Outputs
              data_int_matrix_transpose <= data_out_matrix_transpose;

              -- Control Outputs
              M_OUT_J_ENABLE <= '1';
              M_OUT_K_ENABLE <= '1';

              READY <= '1';

              -- Control Internal
              index_i_transpose_loop <= ZERO_CONTROL;
              index_j_transpose_loop <= ZERO_CONTROL;

              -- FSM Control
              controller_ctrl_fsm_int <= INPUT_I_SECOND_STATE;
            elsif ((unsigned(index_i_transpose_loop) < unsigned(SIZE_N_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_j_transpose_loop) = unsigned(SIZE_W_IN)-unsigned(ONE_CONTROL))) then
              -- Data Outputs
              data_int_matrix_transpose <= data_out_matrix_transpose;

              -- Control Outputs
              M_OUT_J_ENABLE <= '1';
              M_OUT_K_ENABLE <= '1';

              -- Control Internal
              index_i_transpose_loop <= std_logic_vector(unsigned(index_i_transpose_loop) + unsigned(ONE_CONTROL));
              index_j_transpose_loop <= ZERO_CONTROL;

              -- FSM Control
              controller_ctrl_fsm_int <= INPUT_I_SECOND_STATE;
            end if;
          else
            -- Control Internal
            start_matrix_transpose <= '0';

            data_in_i_enable_matrix_transpose <= '0';
            data_in_j_enable_matrix_transpose <= '0';
          end if;

        when MATRIX_TRANSPOSE_J_STATE =>  -- STEP 4

          if (data_out_j_enable_matrix_transpose = '1') then
            if (unsigned(index_j_transpose_loop) < unsigned(SIZE_W_IN)-unsigned(ONE_CONTROL)) then
              -- Data Outputs
              data_int_matrix_transpose <= data_out_matrix_transpose;

              -- Control Outputs
              M_OUT_K_ENABLE <= '1';

              -- Control Internal
              index_j_transpose_loop <= std_logic_vector(unsigned(index_j_transpose_loop) + unsigned(ONE_CONTROL));

              -- FSM Control
              controller_ctrl_fsm_int <= INPUT_J_SECOND_STATE;
            end if;
          else
            -- Control Internal
            start_matrix_transpose <= '0';

            data_in_i_enable_matrix_transpose <= '0';
            data_in_j_enable_matrix_transpose <= '0';
          end if;

        when INPUT_I_SECOND_STATE =>    -- STEP 5

          if (((W_IN_I_ENABLE = '1') and (W_IN_J_ENABLE = '1')) or (unsigned(index_j_product_loop) = unsigned(ZERO_CONTROL))) then
            -- Data Inputs
            size_a_i_in_matrix_product <= SIZE_W_IN;
            size_a_j_in_matrix_product <= SIZE_N_IN;
            size_b_i_in_matrix_product <= SIZE_N_IN;
            size_b_j_in_matrix_product <= SIZE_R_IN;

            data_a_in_matrix_product <= data_int_matrix_transpose;
            data_b_in_matrix_product <= W_IN;

            -- Control Internal
            if (unsigned(index_j_product_loop) = unsigned(ZERO_CONTROL)) then
              start_matrix_product <= '1';
            end if;

            data_a_in_i_enable_matrix_product <= '1';
            data_a_in_j_enable_matrix_product <= '1';
            data_b_in_i_enable_matrix_product <= '1';
            data_b_in_j_enable_matrix_product <= '1';

            -- FSM Control
            controller_ctrl_fsm_int <= MATRIX_PRODUCT_J_STATE;
          end if;

          -- Control Outputs
          W_OUT_I_ENABLE <= '0';
          W_OUT_J_ENABLE <= '0';

          R_OUT_I_ENABLE <= '0';
          R_OUT_K_ENABLE <= '0';

        when INPUT_J_SECOND_STATE =>    -- STEP 6

          if (W_IN_J_ENABLE = '1') then
            -- Data Inputs
            data_a_in_matrix_product <= data_int_matrix_transpose;
            data_b_in_matrix_product <= W_IN;

            -- Control Internal
            data_a_in_j_enable_matrix_product <= '1';
            data_b_in_j_enable_matrix_product <= '1';

            -- FSM Control
            if (unsigned(index_j_product_loop) = unsigned(SIZE_R_IN)-unsigned(ONE_CONTROL)) then
              controller_ctrl_fsm_int <= MATRIX_PRODUCT_I_STATE;
            else
              controller_ctrl_fsm_int <= MATRIX_PRODUCT_J_STATE;
            end if;
          end if;

          -- Control Outputs
          W_OUT_J_ENABLE <= '0';

          R_OUT_K_ENABLE <= '0';

        when MATRIX_PRODUCT_I_STATE =>  -- STEP 7

          if (data_out_i_enable_matrix_product = '1' and data_out_j_enable_matrix_product = '1') then
            if ((unsigned(index_i_product_loop) = unsigned(SIZE_N_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_j_product_loop) = unsigned(SIZE_R_IN)-unsigned(ONE_CONTROL))) then
              -- Data Outputs
              R_OUT <= data_out_matrix_product;

              -- Control Outputs
              READY <= '1';

              W_OUT_I_ENABLE <= '1';
              W_OUT_J_ENABLE <= '1';

              R_OUT_I_ENABLE <= '1';
              R_OUT_K_ENABLE <= '1';

              -- Control Internal
              index_i_product_loop <= ZERO_CONTROL;
              index_j_product_loop <= ZERO_CONTROL;

              -- FSM Control
              controller_ctrl_fsm_int <= STARTER_STATE;
            elsif ((unsigned(index_i_product_loop) < unsigned(SIZE_N_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_j_product_loop) = unsigned(SIZE_R_IN)-unsigned(ONE_CONTROL))) then
              -- Data Outputs
              R_OUT <= data_out_matrix_product;

              -- Control Outputs
              W_OUT_I_ENABLE <= '1';
              W_OUT_J_ENABLE <= '1';

              R_OUT_I_ENABLE <= '1';
              R_OUT_K_ENABLE <= '1';

              -- Control Internal
              index_i_product_loop <= std_logic_vector(unsigned(index_i_product_loop) + unsigned(ONE_CONTROL));
              index_j_product_loop <= ZERO_CONTROL;

              -- FSM Control
              controller_ctrl_fsm_int <= INPUT_I_FIRST_STATE;
            end if;
          else
            -- Control Internal
            start_matrix_product <= '0';

            data_a_in_i_enable_matrix_product <= '0';
            data_a_in_j_enable_matrix_product <= '0';
            data_b_in_i_enable_matrix_product <= '0';
            data_b_in_j_enable_matrix_product <= '0';
          end if;

        when MATRIX_PRODUCT_J_STATE =>  -- STEP 8

          if (data_out_j_enable_matrix_product = '1') then
            if (unsigned(index_j_product_loop) < unsigned(SIZE_N_IN)-unsigned(ONE_CONTROL)) then
              -- Data Outputs
              R_OUT <= data_out_matrix_product;

              -- Control Outputs
              W_OUT_J_ENABLE <= '1';

              R_OUT_K_ENABLE <= '1';

              -- Control Internal
              index_j_product_loop <= std_logic_vector(unsigned(index_j_product_loop) + unsigned(ONE_CONTROL));

              -- FSM Control
              controller_ctrl_fsm_int <= INPUT_J_FIRST_STATE;
            end if;
          else
            -- Control Internal
            start_matrix_product <= '0';

            data_a_in_i_enable_matrix_product <= '0';
            data_a_in_j_enable_matrix_product <= '0';
            data_b_in_i_enable_matrix_product <= '0';
            data_b_in_j_enable_matrix_product <= '0';
          end if;

        when others =>
          -- FSM Control
          controller_ctrl_fsm_int <= STARTER_STATE;
      end case;
    end if;
  end process;

  -- MATRIX TRANSPOSE
  matrix_transpose : ntm_matrix_transpose
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_matrix_transpose,
      READY => ready_matrix_transpose,

      DATA_IN_I_ENABLE => data_in_i_enable_matrix_transpose,
      DATA_IN_J_ENABLE => data_in_j_enable_matrix_transpose,

      DATA_OUT_I_ENABLE => data_out_i_enable_matrix_transpose,
      DATA_OUT_J_ENABLE => data_out_j_enable_matrix_transpose,

      -- DATA
      SIZE_I_IN => size_i_in_matrix_transpose,
      SIZE_J_IN => size_j_in_matrix_transpose,
      DATA_IN   => data_in_matrix_transpose,
      DATA_OUT  => data_out_matrix_transpose
      );

  -- MATRIX PRODUCT
  matrix_product : ntm_matrix_product
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_matrix_product,
      READY => ready_matrix_product,

      DATA_A_IN_I_ENABLE => data_a_in_i_enable_matrix_product,
      DATA_A_IN_J_ENABLE => data_a_in_j_enable_matrix_product,
      DATA_B_IN_I_ENABLE => data_b_in_i_enable_matrix_product,
      DATA_B_IN_J_ENABLE => data_b_in_j_enable_matrix_product,

      DATA_OUT_I_ENABLE => data_out_i_enable_matrix_product,
      DATA_OUT_J_ENABLE => data_out_j_enable_matrix_product,

      -- DATA
      SIZE_A_I_IN => size_a_i_in_matrix_product,
      SIZE_A_J_IN => size_a_j_in_matrix_product,
      SIZE_B_I_IN => size_b_i_in_matrix_product,
      SIZE_B_J_IN => size_b_j_in_matrix_product,
      DATA_A_IN   => data_a_in_matrix_product,
      DATA_B_IN   => data_b_in_matrix_product,
      DATA_OUT    => data_out_matrix_product
      );

end architecture;
