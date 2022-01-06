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

entity ntm_matrix_cosine_similarity_function is
  generic (
    DATA_SIZE    : integer := 128;
    CONTROL_SIZE : integer := 64
    );
  port (
    -- GLOBAL
    CLK : in std_logic;
    RST : in std_logic;

    -- CONTROL
    START : in  std_logic;
    READY : out std_logic;

    DATA_A_IN_MATRIX_ENABLE : in std_logic;
    DATA_A_IN_VECTOR_ENABLE : in std_logic;
    DATA_A_IN_SCALAR_ENABLE : in std_logic;
    DATA_B_IN_MATRIX_ENABLE : in std_logic;
    DATA_B_IN_VECTOR_ENABLE : in std_logic;
    DATA_B_IN_SCALAR_ENABLE : in std_logic;

    DATA_OUT_MATRIX_ENABLE : out std_logic;
    DATA_OUT_VECTOR_ENABLE : out std_logic;
    DATA_OUT_SCALAR_ENABLE : out std_logic;

    -- DATA
    SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
    LENGTH_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
    DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
    DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
    DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity;

architecture ntm_matrix_cosine_similarity_function_architecture of ntm_matrix_cosine_similarity_function is

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  type cosine_similarity_ctrl_fsm is (
    STARTER_STATE,                      -- STEP 0
    INPUT_MATRIX_STATE,                 -- STEP 1
    INPUT_VECTOR_STATE,                 -- STEP 2
    INPUT_SCALAR_STATE,                 -- STEP 3
    ENDER_MATRIX_STATE,                 -- STEP 4
    ENDER_VECTOR_STATE,                 -- STEP 5
    ENDER_SCALAR_STATE                  -- STEP 6
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
  signal cosine_similarity_ctrl_fsm_int : cosine_similarity_ctrl_fsm;

  -- Internal Signals
  signal index_matrix_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal index_vector_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal index_scalar_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);

  signal data_a_in_matrix_cosine_similarity_int : std_logic;
  signal data_a_in_vector_cosine_similarity_int : std_logic;
  signal data_a_in_scalar_cosine_similarity_int : std_logic;
  signal data_b_in_matrix_cosine_similarity_int : std_logic;
  signal data_b_in_vector_cosine_similarity_int : std_logic;
  signal data_b_in_scalar_cosine_similarity_int : std_logic;

  -- VECTOR COSINE SIMILARITY
  -- CONTROL
  signal start_vector_cosine_similarity : std_logic;
  signal ready_vector_cosine_similarity : std_logic;

  signal data_a_in_vector_enable_vector_cosine_similarity : std_logic;
  signal data_a_in_scalar_enable_vector_cosine_similarity : std_logic;
  signal data_b_in_vector_enable_vector_cosine_similarity : std_logic;
  signal data_b_in_scalar_enable_vector_cosine_similarity : std_logic;

  signal data_out_vector_enable_vector_cosine_similarity : std_logic;
  signal data_out_scalar_enable_vector_cosine_similarity : std_logic;

  -- DATA
  signal size_in_vector_cosine_similarity   : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal length_in_vector_cosine_similarity : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal data_a_in_vector_cosine_similarity : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_b_in_vector_cosine_similarity : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_out_vector_cosine_similarity  : std_logic_vector(DATA_SIZE-1 downto 0);

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  -- DATA_OUT = (DATA_A_IN · DATA_B_IN)/((DATA_A_IN · DATA_A_IN)(DATA_B_IN · DATA_B_IN))

  -- CONTROL
  ctrl_fsm : process(CLK, RST)
  begin
    if (RST = '0') then
      -- Data Outputs
      DATA_OUT <= ZERO_DATA;

      -- Control Outputs
      READY <= '0';

      -- Assignations
      index_matrix_loop <= ZERO_CONTROL;
      index_vector_loop <= ZERO_CONTROL;
      index_scalar_loop <= ZERO_CONTROL;

      data_a_in_matrix_cosine_similarity_int <= '0';
      data_a_in_vector_cosine_similarity_int <= '0';
      data_a_in_scalar_cosine_similarity_int <= '0';
      data_b_in_matrix_cosine_similarity_int <= '0';
      data_b_in_vector_cosine_similarity_int <= '0';
      data_b_in_scalar_cosine_similarity_int <= '0';

    elsif (rising_edge(CLK)) then

      case cosine_similarity_ctrl_fsm_int is
        when STARTER_STATE =>  -- STEP 0
          -- Control Outputs
          READY <= '0';

          if (START = '1') then
            -- Assignations
            index_matrix_loop <= ZERO_CONTROL;
            index_vector_loop <= ZERO_CONTROL;
            index_scalar_loop <= ZERO_CONTROL;

            -- FSM Control
            cosine_similarity_ctrl_fsm_int <= INPUT_MATRIX_STATE;
          end if;

        when INPUT_MATRIX_STATE =>  -- STEP 1

          if (((DATA_A_IN_MATRIX_ENABLE = '1') and (DATA_A_IN_VECTOR_ENABLE = '1') and (DATA_A_IN_SCALAR_ENABLE = '1')) or ((index_vector_loop = ZERO_CONTROL) and (index_scalar_loop = ZERO_CONTROL))) then
            -- Data Inputs
            data_a_in_vector_cosine_similarity <= DATA_A_IN;

            -- Control Internal
            data_a_in_vector_enable_vector_cosine_similarity <= '1';
            data_a_in_scalar_enable_vector_cosine_similarity <= '1';

            data_a_in_matrix_cosine_similarity_int <= '1';
            data_a_in_vector_cosine_similarity_int <= '1';
            data_a_in_scalar_cosine_similarity_int <= '1';
          else
            -- Control Internal
            data_a_in_vector_enable_vector_cosine_similarity <= '0';
            data_a_in_scalar_enable_vector_cosine_similarity <= '0';
          end if;

          if (((DATA_B_IN_MATRIX_ENABLE = '1') and (DATA_B_IN_VECTOR_ENABLE = '1') and (DATA_B_IN_SCALAR_ENABLE = '1')) or ((index_vector_loop = ZERO_CONTROL) and (index_scalar_loop = ZERO_CONTROL))) then
            -- Data Inputs
            data_b_in_vector_cosine_similarity <= DATA_B_IN;

            -- Control Internal
            data_b_in_vector_enable_vector_cosine_similarity <= '1';
            data_b_in_scalar_enable_vector_cosine_similarity <= '1';

            data_b_in_matrix_cosine_similarity_int <= '1';
            data_a_in_vector_cosine_similarity_int <= '1';
            data_a_in_scalar_cosine_similarity_int <= '1';
          else
            -- Control Internal
            data_b_in_vector_enable_vector_cosine_similarity <= '0';
            data_b_in_scalar_enable_vector_cosine_similarity <= '0';
          end if;

          -- Control Outputs
          DATA_OUT_MATRIX_ENABLE <= '0';
          DATA_OUT_VECTOR_ENABLE <= '0';
          DATA_OUT_SCALAR_ENABLE <= '0';

          if (data_a_in_matrix_cosine_similarity_int = '1' and data_a_in_vector_cosine_similarity_int = '1' and data_a_in_scalar_cosine_similarity_int = '1' and data_b_in_matrix_cosine_similarity_int = '1' and data_a_in_vector_cosine_similarity_int = '1' and data_a_in_scalar_cosine_similarity_int = '1') then
            -- Data Inputs
            size_in_vector_cosine_similarity   <= SIZE_J_IN;
            length_in_vector_cosine_similarity <= LENGTH_IN;

            -- Control Internal
            start_vector_cosine_similarity <= '1';

            data_a_in_vector_enable_vector_cosine_similarity <= '0';
            data_a_in_scalar_enable_vector_cosine_similarity <= '0';
            data_b_in_vector_enable_vector_cosine_similarity <= '0';
            data_b_in_scalar_enable_vector_cosine_similarity <= '0';

            data_a_in_matrix_cosine_similarity_int <= '0';
            data_a_in_vector_cosine_similarity_int <= '0';
            data_a_in_scalar_cosine_similarity_int <= '0';
            data_b_in_matrix_cosine_similarity_int <= '0';
            data_a_in_vector_cosine_similarity_int <= '0';
            data_a_in_scalar_cosine_similarity_int <= '0';

            -- FSM Control
            cosine_similarity_ctrl_fsm_int <= ENDER_SCALAR_STATE;
          end if;

        when INPUT_VECTOR_STATE =>  -- STEP 2

          if (((DATA_A_IN_VECTOR_ENABLE = '1') and (DATA_A_IN_SCALAR_ENABLE = '1')) or (index_scalar_loop = ZERO_CONTROL)) then
            -- Data Inputs
            data_a_in_vector_cosine_similarity <= DATA_A_IN;

            -- Control Internal
            data_a_in_scalar_enable_vector_cosine_similarity <= '1';

            data_a_in_vector_cosine_similarity_int <= '1';
            data_a_in_scalar_cosine_similarity_int <= '1';
          else
            -- Control Internal
            data_a_in_scalar_enable_vector_cosine_similarity <= '0';
          end if;

          if (((DATA_B_IN_VECTOR_ENABLE = '1') and (DATA_B_IN_SCALAR_ENABLE = '1')) or (index_scalar_loop = ZERO_CONTROL)) then
            -- Data Inputs
            data_b_in_vector_cosine_similarity <= DATA_B_IN;

            -- Control Internal
            data_b_in_scalar_enable_vector_cosine_similarity <= '1';

            data_a_in_vector_cosine_similarity_int <= '1';
            data_a_in_scalar_cosine_similarity_int <= '1';
          else
            -- Control Internal
            data_b_in_scalar_enable_vector_cosine_similarity <= '0';
          end if;

          -- Control Outputs
          DATA_OUT_MATRIX_ENABLE <= '0';
          DATA_OUT_VECTOR_ENABLE <= '0';
          DATA_OUT_SCALAR_ENABLE <= '0';

          if (data_a_in_vector_cosine_similarity_int = '1' and data_a_in_scalar_cosine_similarity_int = '1' and data_a_in_vector_cosine_similarity_int = '1' and data_a_in_scalar_cosine_similarity_int = '1') then
            -- Data Inputs
            data_a_in_scalar_enable_vector_cosine_similarity <= '0';
            data_b_in_scalar_enable_vector_cosine_similarity <= '0';

            data_a_in_vector_cosine_similarity_int <= '0';
            data_a_in_scalar_cosine_similarity_int <= '0';
            data_a_in_vector_cosine_similarity_int <= '0';
            data_a_in_scalar_cosine_similarity_int <= '0';

            -- FSM Control
            cosine_similarity_ctrl_fsm_int <= ENDER_SCALAR_STATE;
          end if;

        when INPUT_SCALAR_STATE =>  -- STEP 3

          if (DATA_A_IN_SCALAR_ENABLE = '1') then
            -- Data Inputs
            data_a_in_vector_cosine_similarity <= DATA_A_IN;

            -- Control Internal
            data_a_in_scalar_enable_vector_cosine_similarity <= '1';

            data_a_in_scalar_cosine_similarity_int <= '1';
          else
            -- Control Internal
            data_a_in_scalar_enable_vector_cosine_similarity <= '0';
          end if;

          if (DATA_B_IN_SCALAR_ENABLE = '1') then
            -- Data Inputs
            data_b_in_vector_cosine_similarity <= DATA_B_IN;

            -- Control Internal
            data_b_in_scalar_enable_vector_cosine_similarity <= '1';

            data_a_in_scalar_cosine_similarity_int <= '1';
          else
            -- Control Internal
            data_b_in_scalar_enable_vector_cosine_similarity <= '0';
          end if;

          -- Control Outputs
          DATA_OUT_SCALAR_ENABLE <= '0';

          if (data_a_in_scalar_cosine_similarity_int = '1' and data_a_in_scalar_cosine_similarity_int = '1') then
            -- Control Internal
            data_a_in_scalar_enable_vector_cosine_similarity <= '0';
            data_b_in_scalar_enable_vector_cosine_similarity <= '0';

            data_a_in_scalar_cosine_similarity_int <= '0';
            data_a_in_scalar_cosine_similarity_int <= '0';

            -- FSM Control
            if (unsigned(index_scalar_loop) = unsigned(LENGTH_IN)-unsigned(ONE_CONTROL)) then
              if (unsigned(index_vector_loop) = unsigned(SIZE_J_IN)-unsigned(ONE_CONTROL)) then
                cosine_similarity_ctrl_fsm_int <= ENDER_MATRIX_STATE;
              else
                cosine_similarity_ctrl_fsm_int <= ENDER_VECTOR_STATE;
              end if;
            else
              cosine_similarity_ctrl_fsm_int <= ENDER_SCALAR_STATE;
            end if;
          end if;

        when ENDER_MATRIX_STATE =>  -- STEP 4

          if (data_out_vector_enable_vector_cosine_similarity = '1' and data_out_scalar_enable_vector_cosine_similarity = '1') then
            if ((unsigned(index_matrix_loop) = unsigned(SIZE_I_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_vector_loop) = unsigned(SIZE_J_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_scalar_loop) = unsigned(unsigned(LENGTH_IN)-unsigned(ONE_CONTROL)))) then
              -- Data Outputs
              DATA_OUT <= data_out_vector_cosine_similarity;

              -- Control Outputs
              DATA_OUT_MATRIX_ENABLE <= '1';
              DATA_OUT_VECTOR_ENABLE <= '1';
              DATA_OUT_SCALAR_ENABLE <= '1';

              READY <= '1';

              -- Control Internal
              index_matrix_loop <= ZERO_CONTROL;
              index_vector_loop <= ZERO_CONTROL;
              index_scalar_loop <= ZERO_CONTROL;

              -- FSM Control
              cosine_similarity_ctrl_fsm_int <= STARTER_STATE;
            elsif ((unsigned(index_matrix_loop) < unsigned(SIZE_I_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_vector_loop) = unsigned(SIZE_J_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_scalar_loop) = unsigned(unsigned(LENGTH_IN)-unsigned(ONE_CONTROL)))) then
              -- Data Outputs
              DATA_OUT <= data_out_vector_cosine_similarity;

              -- Control Outputs
              DATA_OUT_MATRIX_ENABLE <= '1';
              DATA_OUT_VECTOR_ENABLE <= '1';
              DATA_OUT_SCALAR_ENABLE <= '1';

              -- Control Internal
              index_matrix_loop <= std_logic_vector(unsigned(index_matrix_loop) + unsigned(ONE_CONTROL));
              index_vector_loop <= ZERO_CONTROL;
              index_scalar_loop <= ZERO_CONTROL;

              -- FSM Control
              cosine_similarity_ctrl_fsm_int <= INPUT_MATRIX_STATE;
            end if;
          else
            -- Control Internal
            start_vector_cosine_similarity <= '0';
          end if;

        when ENDER_VECTOR_STATE =>  -- STEP 5

          if (data_out_scalar_enable_vector_cosine_similarity = '1') then
            if ((unsigned(index_vector_loop) < unsigned(SIZE_J_IN)-unsigned(ONE_CONTROL)) and (unsigned(index_scalar_loop) = unsigned(unsigned(LENGTH_IN)-unsigned(ONE_CONTROL)))) then
              -- Data Outputs
              DATA_OUT <= data_out_vector_cosine_similarity;

              -- Control Outputs
              DATA_OUT_VECTOR_ENABLE <= '1';
              DATA_OUT_SCALAR_ENABLE <= '1';

              -- Control Internal
              index_vector_loop <= std_logic_vector(unsigned(index_vector_loop) + unsigned(ONE_CONTROL));
              index_scalar_loop <= ZERO_CONTROL;

              -- FSM Control
              cosine_similarity_ctrl_fsm_int <= INPUT_VECTOR_STATE;
            end if;
          else
            -- Control Internal
            start_vector_cosine_similarity <= '0';
          end if;

        when ENDER_SCALAR_STATE =>  -- STEP 6

          if (data_out_scalar_enable_vector_cosine_similarity = '1') then
            if (unsigned(index_scalar_loop) < unsigned(LENGTH_IN)-unsigned(ONE_CONTROL)) then
              -- Data Outputs
              DATA_OUT <= data_out_vector_cosine_similarity;

              -- Control Outputs
              DATA_OUT_SCALAR_ENABLE <= '1';

              -- Control Internal
              index_scalar_loop <= std_logic_vector(unsigned(index_scalar_loop) + unsigned(ONE_CONTROL));

              -- FSM Control
              cosine_similarity_ctrl_fsm_int <= INPUT_SCALAR_STATE;
            end if;
          else
            -- Control Internal
            start_vector_cosine_similarity <= '0';
          end if;

        when others =>
          -- FSM Control
          cosine_similarity_ctrl_fsm_int <= STARTER_STATE;
      end case;
    end if;
  end process;

  -- VECTOR COSINE SIMILARITY
  vector_cosine_similarity_function : ntm_vector_cosine_similarity_function
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_vector_cosine_similarity,
      READY => ready_vector_cosine_similarity,

      DATA_A_IN_VECTOR_ENABLE => data_a_in_vector_enable_vector_cosine_similarity,
      DATA_A_IN_SCALAR_ENABLE => data_a_in_scalar_enable_vector_cosine_similarity,
      DATA_B_IN_VECTOR_ENABLE => data_b_in_vector_enable_vector_cosine_similarity,
      DATA_B_IN_SCALAR_ENABLE => data_b_in_scalar_enable_vector_cosine_similarity,

      DATA_OUT_VECTOR_ENABLE => data_out_vector_enable_vector_cosine_similarity,
      DATA_OUT_SCALAR_ENABLE => data_out_scalar_enable_vector_cosine_similarity,

      -- DATA
      SIZE_IN   => size_in_vector_cosine_similarity,
      LENGTH_IN => length_in_vector_cosine_similarity,
      DATA_A_IN => data_a_in_vector_cosine_similarity,
      DATA_B_IN => data_b_in_vector_cosine_similarity,
      DATA_OUT  => data_out_vector_cosine_similarity
      );

end architecture;
