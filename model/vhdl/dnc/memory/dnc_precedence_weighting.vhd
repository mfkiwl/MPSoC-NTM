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

entity dnc_precedence_weighting is
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

    W_IN_ENABLE : in std_logic;         -- for j in 0 to N-1
    P_IN_ENABLE : in std_logic;         -- for j in 0 to N-1

    W_OUT_ENABLE : out std_logic;       -- for j in 0 to N-1
    P_OUT_ENABLE : out std_logic;       -- for j in 0 to N-1

    -- DATA
    SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_N_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

    W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
    P_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

    P_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity;

architecture dnc_precedence_weighting_architecture of dnc_precedence_weighting is

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  type controller_ctrl_fsm is (
    STARTER_STATE,                      -- STEP 0
    INPUT_FIRST_STATE,                  -- STEP 1
    VECTOR_SUMMATION_STATE,             -- STEP 2
    VECTOR_FIRST_ADDER_STATE,           -- STEP 3
    INPUT_SECOND_STATE,                 -- STEP 4
    VECTOR_MULTIPLIER_STATE,            -- STEP 5
    INPUT_THIRD_STATE,                  -- STEP 6
    VECTOR_SECOND_ADDER_STATE           -- STEP 7
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

  -- Control Internal
  signal index_loop : std_logic_vector(CONTROL_SIZE-1 downto 0);

  -- VECTOR SUMMATION
  -- CONTROL
  signal start_vector_summation : std_logic;
  signal ready_vector_summation : std_logic;

  signal data_in_enable_vector_summation : std_logic;

  signal data_out_enable_vector_summation : std_logic;

  -- DATA
  signal length_in_vector_summation : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal data_in_vector_summation   : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_out_vector_summation  : std_logic_vector(DATA_SIZE-1 downto 0);

  -- VECTOR ADDER
  -- CONTROL
  signal start_vector_float_adder : std_logic;
  signal ready_vector_float_adder : std_logic;

  signal operation_vector_float_adder : std_logic;

  signal data_a_in_enable_vector_float_adder : std_logic;
  signal data_b_in_enable_vector_float_adder : std_logic;

  signal data_out_enable_vector_float_adder : std_logic;

  -- DATA
  signal size_in_vector_float_adder   : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal data_a_in_vector_float_adder : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_b_in_vector_float_adder : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_out_vector_float_adder  : std_logic_vector(DATA_SIZE-1 downto 0);

  -- VECTOR MULTIPLIER
  -- CONTROL
  signal start_vector_float_multiplier : std_logic;
  signal ready_vector_float_multiplier : std_logic;

  signal data_a_in_enable_vector_float_multiplier : std_logic;
  signal data_b_in_enable_vector_float_multiplier : std_logic;

  signal data_out_enable_vector_float_multiplier : std_logic;

  -- DATA
  signal size_in_vector_float_multiplier   : std_logic_vector(CONTROL_SIZE-1 downto 0);
  signal data_a_in_vector_float_multiplier : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_b_in_vector_float_multiplier : std_logic_vector(DATA_SIZE-1 downto 0);
  signal data_out_vector_float_multiplier  : std_logic_vector(DATA_SIZE-1 downto 0);

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  -- p(t;j) = (1 - summation(w(t;j))[i in 1 to N])·p(t-1;j) + w(t;j)

  -- p(t=0) = 0

  -- CONTROL
  ctrl_fsm : process(CLK, RST)
  begin
    if (RST = '0') then
      -- Data Outputs
      P_OUT <= ZERO_DATA;

      -- Control Outputs
      READY <= '0';

      -- Control Internal
      index_loop <= ZERO_CONTROL;

    elsif (rising_edge(CLK)) then

      case controller_ctrl_fsm_int is
        when STARTER_STATE =>           -- STEP 0
          -- Control Outputs
          READY <= '0';

          -- Control Internal
          index_loop <= ZERO_CONTROL;

          if (START = '1') then
            -- Data Outputs
            P_OUT <= ZERO_DATA;

            if (index_loop = ZERO_CONTROL) then
              -- Control Internal
              start_vector_summation <= '1';
            end if;

            -- FSM Control
            controller_ctrl_fsm_int <= INPUT_FIRST_STATE;
          end if;

        when INPUT_FIRST_STATE =>       -- STEP 1

        when VECTOR_SUMMATION_STATE =>  -- STEP 2

          if (data_out_enable_vector_summation = '1') then
            if (unsigned(index_loop) = unsigned(ZERO_CONTROL)) then
              -- Control Internal
              start_vector_float_adder <= '1';
            end if;

            -- FSM Control
            controller_ctrl_fsm_int <= VECTOR_FIRST_ADDER_STATE;
          else
            -- Control Internal
            start_vector_summation <= '0';
          end if;

        when VECTOR_FIRST_ADDER_STATE =>  -- STEP 3

          -- Data Inputs
          size_in_vector_float_adder   <= SIZE_N_IN;
          data_a_in_vector_float_adder <= ONE_DATA;
          data_b_in_vector_float_adder <= data_out_vector_summation;

          if (data_out_enable_vector_float_adder = '1') then
            if (unsigned(index_loop) = unsigned(ZERO_CONTROL)) then
              -- Control Internal
              start_vector_float_multiplier <= '1';
            end if;

            -- FSM Control
            controller_ctrl_fsm_int <= VECTOR_MULTIPLIER_STATE;
          else
            -- Control Internal
            start_vector_float_adder <= '0';
          end if;

        when INPUT_SECOND_STATE =>      -- STEP 4

        when VECTOR_MULTIPLIER_STATE =>  -- STEP 5

          if (data_out_enable_vector_float_multiplier = '1') then
            if (unsigned(index_loop) = unsigned(ZERO_CONTROL)) then
              -- Control Internal
              start_vector_float_adder <= '1';
            end if;

            -- FSM Control
            controller_ctrl_fsm_int <= VECTOR_SECOND_ADDER_STATE;
          else
            -- Control Internal
            start_vector_float_multiplier <= '0';
          end if;

        when INPUT_THIRD_STATE =>       -- STEP 6

        when VECTOR_SECOND_ADDER_STATE =>  -- STEP 7

          -- Data Inputs
          size_in_vector_float_adder   <= SIZE_N_IN;
          data_a_in_vector_float_adder <= data_out_vector_float_multiplier;
          data_b_in_vector_float_adder <= W_IN;

          if (data_out_enable_vector_float_adder = '1') then
            if (unsigned(index_loop) = unsigned(SIZE_N_IN) - unsigned(ONE_CONTROL)) then
              -- Control Outputs
              READY <= '1';

              -- FSM Control
              controller_ctrl_fsm_int <= STARTER_STATE;
            else
              -- Control Internal
              index_loop <= std_logic_vector(unsigned(index_loop) + unsigned(ONE_CONTROL));

              -- FSM Control
              controller_ctrl_fsm_int <= VECTOR_MULTIPLIER_STATE;
            end if;

            -- Data Outputs
            P_OUT <= data_out_vector_float_adder;

            -- Control Outputs
            P_OUT_ENABLE <= '1';
          else
            -- Control Outputs
            P_OUT_ENABLE <= '0';

            -- Control Internal
            start_vector_float_adder <= '0';
          end if;

        when others =>
          -- FSM Control
          controller_ctrl_fsm_int <= STARTER_STATE;
      end case;
    end if;
  end process;

  -- VECTOR SUMMATION
  data_in_enable_vector_summation <= '0';
  data_in_enable_vector_summation <= W_IN_ENABLE;

  -- VECTOR MULTIPLIER
  data_a_in_enable_vector_float_multiplier <= data_out_enable_vector_float_adder;
  data_b_in_enable_vector_float_multiplier <= P_IN_ENABLE;

  -- DATA
  -- VECTOR SUMMATION
  length_in_vector_summation <= SIZE_R_IN;
  data_in_vector_summation   <= W_IN;

  -- VECTOR MULTIPLIER
  size_in_vector_float_multiplier   <= SIZE_N_IN;
  data_a_in_vector_float_multiplier <= data_out_vector_float_adder;
  data_b_in_vector_float_multiplier <= P_IN;

  -- VECTOR SUMMATION
  vector_summation : ntm_vector_summation
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_vector_summation,
      READY => ready_vector_summation,

      DATA_IN_ENABLE => data_in_enable_vector_summation,

      DATA_OUT_ENABLE => data_out_enable_vector_summation,

      -- DATA
      LENGTH_IN => length_in_vector_summation,
      DATA_IN   => data_in_vector_summation,
      DATA_OUT  => data_out_vector_summation
      );

  -- VECTOR ADDER
  vector_float_adder : ntm_vector_float_adder
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_vector_float_adder,
      READY => ready_vector_float_adder,

      OPERATION => operation_vector_float_adder,

      DATA_A_IN_ENABLE => data_a_in_enable_vector_float_adder,
      DATA_B_IN_ENABLE => data_b_in_enable_vector_float_adder,

      DATA_OUT_ENABLE => data_out_enable_vector_float_adder,

      -- DATA
      SIZE_IN   => size_in_vector_float_adder,
      DATA_A_IN => data_a_in_vector_float_adder,
      DATA_B_IN => data_b_in_vector_float_adder,
      DATA_OUT  => data_out_vector_float_adder
      );

  -- VECTOR MULTIPLIER
  vector_float_multiplier : ntm_vector_float_multiplier
    generic map (
      DATA_SIZE    => DATA_SIZE,
      CONTROL_SIZE => CONTROL_SIZE
      )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_vector_float_multiplier,
      READY => ready_vector_float_multiplier,

      DATA_A_IN_ENABLE => data_a_in_enable_vector_float_multiplier,
      DATA_B_IN_ENABLE => data_b_in_enable_vector_float_multiplier,

      DATA_OUT_ENABLE => data_out_enable_vector_float_multiplier,

      -- DATA
      SIZE_IN   => size_in_vector_float_multiplier,
      DATA_A_IN => data_a_in_vector_float_multiplier,
      DATA_B_IN => data_b_in_vector_float_multiplier,
      DATA_OUT  => data_out_vector_float_multiplier
      );

end architecture;
