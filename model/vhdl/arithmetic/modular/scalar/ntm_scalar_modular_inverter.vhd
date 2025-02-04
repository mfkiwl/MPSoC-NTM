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

entity ntm_scalar_modular_inverter is
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

    -- DATA
    MODULO_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
    DATA_IN   : in std_logic_vector(DATA_SIZE-1 downto 0);

    DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity;

architecture ntm_scalar_modular_inverter_architecture of ntm_scalar_modular_inverter is

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  type inverter_ctrl_fsm is (
    STARTER_STATE,                      -- STEP 0
    MODULO_STATE,                       -- STEP 1
    ENDER_STATE                         -- STEP 2
    );

  -----------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------

  constant ZERO_DATA : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(0, DATA_SIZE));

  constant ONE_DATA : std_logic_vector(2*DATA_SIZE-1 downto 0) := std_logic_vector(to_unsigned(1, 2*DATA_SIZE));

  -----------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------

  -- Finite State Machine
  signal inverter_ctrl_fsm_int : inverter_ctrl_fsm;

  -- Internal Signals
  signal inversion_int : std_logic_vector(DATA_SIZE-1 downto 0);

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  ctrl_fsm : process(CLK, RST)
    variable a_var : std_logic_vector(2*DATA_SIZE-1 downto 0);
    variable b_var : std_logic_vector(2*DATA_SIZE-1 downto 0);
    variable q_var : std_logic_vector(2*DATA_SIZE-1 downto 0);
    variable t_var : std_logic_vector(2*DATA_SIZE-1 downto 0);

    variable x0_var : std_logic_vector(2*DATA_SIZE-1 downto 0);
    variable x1_var : std_logic_vector(2*DATA_SIZE-1 downto 0);
  begin

    if (RST = '0') then
      -- Data Outputs
      DATA_OUT <= ZERO_DATA;

      -- Control Outputs
      READY <= '0';

      -- Data Internal
      inversion_int <= ZERO_DATA;

    elsif (rising_edge(CLK)) then

      case inverter_ctrl_fsm_int is
        when STARTER_STATE =>           -- STEP 0
          -- Control Outputs
          READY <= '0';

          if (START = '1') then
            -- Data Internal
            a_var := ZERO_DATA & DATA_IN;
            b_var := ZERO_DATA & MODULO_IN;

            x0_var := ZERO_DATA & ZERO_DATA;
            x1_var := ONE_DATA;

            if (unsigned(b_var) = unsigned(ONE_DATA)) then
              x1_var := ONE_DATA;
            else
              while (unsigned(a_var) > unsigned(ONE_DATA)) loop
                q_var := std_logic_vector(unsigned(a_var) / unsigned(b_var));
                t_var := b_var;
                b_var := std_logic_vector(unsigned(a_var) mod unsigned(b_var));
                a_var := t_var;
                t_var := x0_var;

                x0_var := std_logic_vector(unsigned(x1_var) - resize(unsigned(q_var), DATA_SIZE) * resize(unsigned(x0_var), DATA_SIZE));
                x1_var := t_var;
              end loop;
            end if;

            -- FSM Control
            inverter_ctrl_fsm_int <= MODULO_STATE;
          end if;

        when MODULO_STATE =>            -- STEP 1

          -- Data Internal
          inversion_int <= x1_var(DATA_SIZE-1 downto 0);

          -- FSM Control
          inverter_ctrl_fsm_int <= ENDER_STATE;

        when ENDER_STATE =>             -- STEP 2

          if (unsigned(MODULO_IN) > unsigned(ZERO_DATA)) then
            if (unsigned(inversion_int) > unsigned(ZERO_DATA)) then
              if (x0_var(0) = '0') then
                if (unsigned(inversion_int) = unsigned(MODULO_IN)) then
                  -- Data Outputs
                  DATA_OUT <= ZERO_DATA;

                  -- Control Outputs
                  READY <= '1';

                  -- FSM Control
                  inverter_ctrl_fsm_int <= STARTER_STATE;
                elsif (unsigned(inversion_int) < unsigned(MODULO_IN)) then
                  -- Data Outputs
                  DATA_OUT <= inversion_int;

                  -- Control Outputs
                  READY <= '1';

                  -- FSM Control
                  inverter_ctrl_fsm_int <= STARTER_STATE;
                else
                  -- Data Internal
                  inversion_int <= std_logic_vector(unsigned(inversion_int) - unsigned(MODULO_IN));
                end if;
              else
                if (unsigned(inversion_int) = unsigned(MODULO_IN)) then
                  -- Data Outputs
                  DATA_OUT <= ZERO_DATA;

                  -- Control Outputs
                  READY <= '1';

                  -- FSM Control
                  inverter_ctrl_fsm_int <= STARTER_STATE;
                elsif (unsigned(inversion_int) < unsigned(MODULO_IN)) then
                  -- Data Outputs
                  DATA_OUT <= inversion_int;

                  -- Control Outputs
                  READY <= '1';

                  -- FSM Control
                  inverter_ctrl_fsm_int <= STARTER_STATE;
                else
                  -- Data Internal
                  inversion_int <= std_logic_vector(unsigned(inversion_int) + unsigned(MODULO_IN));
                end if;
              end if;
            elsif (unsigned(inversion_int) = unsigned(ZERO_DATA)) then
              -- Data Outputs
              DATA_OUT <= ZERO_DATA;

              -- Control Outputs
              READY <= '1';

              -- FSM Control
              inverter_ctrl_fsm_int <= STARTER_STATE;
            end if;
          elsif (unsigned(MODULO_IN) = unsigned(ZERO_DATA)) then
            -- Data Outputs
            DATA_OUT <= inversion_int;

            -- Control Outputs
            READY <= '1';

            -- FSM Control
            inverter_ctrl_fsm_int <= STARTER_STATE;
          end if;

        when others =>
          -- FSM Control
          inverter_ctrl_fsm_int <= STARTER_STATE;
      end case;
    end if;
  end process;

end architecture;
