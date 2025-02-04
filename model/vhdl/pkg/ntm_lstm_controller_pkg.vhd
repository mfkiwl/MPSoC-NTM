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

use ieee.math_real.all;
use ieee.float_pkg.all;

use work.ntm_math_pkg.all;

package ntm_lstm_controller_pkg is

  -----------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------

  constant DATA_SIZE    : integer := 32;
  constant CONTROL_SIZE : integer := 64;

  constant ZERO_CONTROL  : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(0, CONTROL_SIZE));
  constant ONE_CONTROL   : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(1, CONTROL_SIZE));
  constant TWO_CONTROL   : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(2, CONTROL_SIZE));
  constant THREE_CONTROL : std_logic_vector(CONTROL_SIZE-1 downto 0) := std_logic_vector(to_unsigned(3, CONTROL_SIZE));

  constant ZERO_DATA  : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_float(0.0));
  constant ONE_DATA   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_float(1.0));
  constant TWO_DATA   : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_float(2.0));
  constant THREE_DATA : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_float(3.0));

  constant LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0) := std_logic_vector(to_float(0.001));

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  -- Buffer
  type vector_buffer is array (CONTROL_SIZE-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);
  type matrix_buffer is array (CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);
  type tensor_buffer is array (CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);
  type array4_buffer is array (CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);

  -----------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------

  component ntm_activation_gate_vector is
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

      W_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      W_IN_X_ENABLE : in std_logic;     -- for x in 0 to X-1

      W_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      W_OUT_X_ENABLE : in std_logic;    -- for x in 0 to X-1

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : in std_logic;      -- for x in 0 to X-1

      K_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      K_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      K_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      K_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      K_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      U_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      U_IN_P_ENABLE : in std_logic;     -- for p in 0 to L-1

      U_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      U_OUT_P_ENABLE : in std_logic;    -- for p in 0 to L-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      B_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      B_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      A_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      K_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      U_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      B_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      A_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_activation_trainer is
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

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : out std_logic;     -- for x in 0 to X-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      A_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      I_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      S_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      A_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      I_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      S_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      W_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      W_OUT_X_ENABLE : out std_logic;   -- for x in 0 to X-1

      K_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      K_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      U_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      U_OUT_P_ENABLE : out std_logic;   -- for p in 0 to L-1

      B_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      A_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      I_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      S_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      W_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      K_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      U_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      B_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_input_gate_vector is
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

      W_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      W_IN_X_ENABLE : in std_logic;     -- for x in 0 to X-1

      W_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      W_OUT_X_ENABLE : in std_logic;    -- for x in 0 to X-1

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : in std_logic;      -- for x in 0 to X-1

      K_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      K_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      K_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      K_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      K_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      U_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      U_IN_P_ENABLE : in std_logic;     -- for p in 0 to L-1

      U_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      U_OUT_P_ENABLE : in std_logic;    -- for p in 0 to L-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      B_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      B_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      I_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      K_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      U_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      B_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      I_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_input_trainer is
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

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : out std_logic;     -- for x in 0 to X-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      A_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      I_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      S_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      A_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      I_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      S_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      W_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      W_OUT_X_ENABLE : out std_logic;   -- for x in 0 to X-1

      K_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      K_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      U_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      U_OUT_P_ENABLE : out std_logic;   -- for p in 0 to L-1

      B_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      A_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      I_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      S_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      W_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      K_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      U_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      B_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_output_gate_vector is
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

      W_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      W_IN_X_ENABLE : in std_logic;     -- for x in 0 to X-1

      W_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      W_OUT_X_ENABLE : in std_logic;    -- for x in 0 to X-1

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : in std_logic;      -- for x in 0 to X-1

      K_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      K_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      K_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      K_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      K_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      U_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      U_IN_P_ENABLE : in std_logic;     -- for p in 0 to L-1

      U_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      U_OUT_P_ENABLE : in std_logic;    -- for p in 0 to L-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      B_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      B_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      O_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      K_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      U_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      B_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      O_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_output_trainer is
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

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : out std_logic;     -- for x in 0 to X-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      A_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      O_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      A_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      O_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      W_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      W_OUT_X_ENABLE : out std_logic;   -- for x in 0 to X-1

      K_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      K_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      U_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      U_OUT_P_ENABLE : out std_logic;   -- for p in 0 to L-1

      B_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      A_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      O_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      W_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      K_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      U_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      B_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_forget_gate_vector is
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

      W_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      W_IN_X_ENABLE : in std_logic;     -- for x in 0 to X-1

      W_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      W_OUT_X_ENABLE : in std_logic;    -- for x in 0 to X-1

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : in std_logic;      -- for x in 0 to X-1

      K_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      K_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      K_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      K_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      K_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : in std_logic;    -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : in std_logic;    -- for k in 0 to W-1

      U_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      U_IN_P_ENABLE : in std_logic;     -- for p in 0 to L-1

      U_OUT_L_ENABLE : in std_logic;    -- for l in 0 to L-1
      U_OUT_P_ENABLE : in std_logic;    -- for p in 0 to L-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      B_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      B_OUT_ENABLE : in std_logic;      -- for l in 0 to L-1

      F_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      K_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      U_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      B_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      F_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_forget_trainer is
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

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : out std_logic;     -- for x in 0 to X-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      H_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      F_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      S_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      F_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      S_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      W_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      W_OUT_X_ENABLE : out std_logic;   -- for x in 0 to X-1

      K_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      K_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      U_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      U_OUT_P_ENABLE : out std_logic;   -- for p in 0 to L-1

      B_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      F_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      S_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      W_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      K_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      U_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      B_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_state_gate_vector is
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

      I_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      F_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      A_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      I_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      F_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      A_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      S_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      S_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      S_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      I_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      F_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      A_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      S_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_hidden_gate_vector is
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

      S_IN_ENABLE : in std_logic;       -- for l in 0 to L-1
      O_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      S_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1
      O_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      H_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      S_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      O_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      H_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_controller is
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

      W_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      W_IN_X_ENABLE : in std_logic;     -- for x in 0 to X-1

      K_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      K_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      K_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      U_IN_L_ENABLE : in std_logic;     -- for l in 0 to L-1
      U_IN_P_ENABLE : in std_logic;     -- for p in 0 to L-1

      B_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      X_IN_ENABLE : in std_logic;       -- for x in 0 to X-1

      X_OUT_ENABLE : out std_logic;     -- for x in 0 to X-1

      R_IN_I_ENABLE : in std_logic;     -- for i in 0 to R-1 (read heads flow)
      R_IN_K_ENABLE : in std_logic;     -- for k in 0 to W-1

      R_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      R_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      H_IN_ENABLE : in std_logic;       -- for l in 0 to L-1

      W_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      W_OUT_X_ENABLE : out std_logic;   -- for x in 0 to X-1

      K_OUT_I_ENABLE : out std_logic;   -- for i in 0 to R-1 (read heads flow)
      K_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      K_OUT_K_ENABLE : out std_logic;   -- for k in 0 to W-1

      U_OUT_L_ENABLE : out std_logic;   -- for l in 0 to L-1
      U_OUT_P_ENABLE : out std_logic;   -- for p in 0 to L-1

      B_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      H_OUT_ENABLE : out std_logic;     -- for l in 0 to L-1

      -- DATA
      SIZE_X_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_W_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_L_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_R_IN : in std_logic_vector(CONTROL_SIZE-1 downto 0);

      W_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      K_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      U_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      B_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      X_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      R_IN : in std_logic_vector(DATA_SIZE-1 downto 0);
      H_IN : in std_logic_vector(DATA_SIZE-1 downto 0);

      W_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      K_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      U_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);
      B_OUT : out std_logic_vector(DATA_SIZE-1 downto 0);

      H_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

  function function_vector_controller_differentiation (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    vector_input : matrix_buffer
    ) return matrix_buffer;

  function function_matrix_controller_differentiation (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    matrix_input : tensor_buffer
    ) return tensor_buffer;

  -----------------------------------------------------------------------
  -- Controller
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
  -- CONVOLUTIONAL
  -----------------------------------------------------------------------

  function function_ntm_activation_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_input_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_output_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_forget_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_state_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_i_input : vector_buffer;
    vector_f_input : vector_buffer;
    vector_a_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_hidden_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_o_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_lstm_convolutional_controller (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  -----------------------------------------------------------------------
  -- STANDARD
  -----------------------------------------------------------------------

  function function_ntm_activation_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_input_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_output_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_forget_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_state_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_i_input : vector_buffer;
    vector_f_input : vector_buffer;
    vector_a_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_hidden_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_o_input : vector_buffer
    ) return vector_buffer;

  function function_ntm_lstm_standard_controller (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer;

  -----------------------------------------------------------------------
  -- Trainer
  -----------------------------------------------------------------------

  function function_ntm_lstm_activation_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_activation_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return array4_buffer;

  function function_ntm_lstm_activation_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_activation_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return matrix_buffer;

  function function_ntm_lstm_forget_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_forget_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return array4_buffer;

  function function_ntm_lstm_forget_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_forget_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return matrix_buffer;

  function function_ntm_lstm_input_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_input_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return array4_buffer;

  function function_ntm_lstm_input_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_input_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return matrix_buffer;

  function function_ntm_lstm_output_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_output_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return array4_buffer;

  function function_ntm_lstm_output_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return tensor_buffer;

  function function_ntm_lstm_output_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return matrix_buffer;

end ntm_lstm_controller_pkg;

package body ntm_lstm_controller_pkg is

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

  function function_vector_controller_differentiation (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    vector_input : matrix_buffer
    ) return matrix_buffer is

    variable vector_output : matrix_buffer;
  begin
    -- Data Inputs
    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        if (t = 0) then
          vector_output(t, l) := std_logic_vector(to_float((to_real(to_float(vector_input(t, l))) - to_real(to_float(vector_input(t, l))))/to_real(to_float(LENGTH_IN))));
        else
          vector_output(t, l) := std_logic_vector(to_float((to_real(to_float(vector_input(t, l))) - to_real(to_float(vector_input(t-1, l))))/to_real(to_float(LENGTH_IN))));
        end if;
      end loop;
    end loop;

    return vector_output;
  end function function_vector_controller_differentiation;

  function function_matrix_controller_differentiation (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    matrix_input : tensor_buffer
    ) return tensor_buffer is

    variable matrix_output : tensor_buffer;
  begin
    -- Data Inputs
    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
        for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          if (t = 0) then
            matrix_output(t, i, l) := std_logic_vector(to_float((to_real(to_float(matrix_input(t, i, l))) - to_real(to_float(matrix_input(t, i, l))))/to_real(to_float(LENGTH_IN))));
          else
            matrix_output(t, i, l) := std_logic_vector(to_float((to_real(to_float(matrix_input(t, i, l))) - to_real(to_float(matrix_input(t-1, i, l))))/to_real(to_float(LENGTH_IN))));
          end if;
        end loop;
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_controller_differentiation;

  -----------------------------------------------------------------------
  -- Controller
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
  -- CONVOLUTIONAL
  -----------------------------------------------------------------------

  function function_ntm_activation_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_a_output : vector_buffer;

  begin

    -- a(t;l) = tanh(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- tanh(i(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_a_output(l) := std_logic_vector(to_float(tanh(to_real(to_float(vector_adder(l))))));
    end loop;

    return vector_a_output;
  end function function_ntm_activation_convolutional_gate_vector;

  function function_ntm_input_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_i_output : vector_buffer;

  begin

    -- i(t;l) = sigmoid(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- logistic(i(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_i_output(l) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(vector_adder(l)))))));
    end loop;

    return vector_i_output;
  end function function_ntm_input_convolutional_gate_vector;

  function function_ntm_output_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_o_output : vector_buffer;

  begin

    -- o(t;l) = sigmoid(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- logistic(o(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_o_output(l) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(vector_adder(l)))))));
    end loop;

    return vector_o_output;
  end function function_ntm_output_convolutional_gate_vector;

  function function_ntm_forget_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_f_output : vector_buffer;

  begin

    -- f(t;l) = sigmoid(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- logistic(f(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_f_output(l) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(vector_adder(l)))))));
    end loop;

    return vector_f_output;
  end function function_ntm_forget_convolutional_gate_vector;

  function function_ntm_state_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_i_input : vector_buffer;
    vector_f_input : vector_buffer;
    vector_a_input : vector_buffer
    ) return vector_buffer is

    variable vector_s_output : vector_buffer;

  begin

    -- s(t;l) = f(t;l) o s(t-1;l) + i(t;l) o a(t;l)

    -- s(t=0;l) = 0

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_s_output(l) := std_logic_vector(to_float((to_real(to_float(vector_f_input(l)))*to_real(to_float(vector_s_input(l)))) + (to_real(to_float(vector_i_input(l)))*to_real(to_float(vector_a_input(l))))));
    end loop;

    return vector_s_output;
  end function function_ntm_state_convolutional_gate_vector;

  function function_ntm_hidden_convolutional_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_o_input : vector_buffer
    ) return vector_buffer is

    variable vector_h_output : vector_buffer;

  begin

    -- h(t;l) = o(t;l) o tanh(s(t;l))

    -- h(t=0;l) = 0; h(t;l=0) = 0

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_h_output(l) := std_logic_vector(to_float(to_real(to_float(vector_o_input(l)))*tanh(to_real(to_float(vector_s_input(l))))));
    end loop;

    return vector_h_output;
  end function function_ntm_hidden_convolutional_gate_vector;

  function function_ntm_lstm_convolutional_controller (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable vector_a_int : vector_buffer;
    variable vector_f_int : vector_buffer;
    variable vector_i_int : vector_buffer;
    variable vector_o_int : vector_buffer;

    variable vector_s_in_int  : vector_buffer;
    variable vector_s_out_int : vector_buffer;

    variable vector_h_output : vector_buffer;

  begin

    -- VECTOR_ACTIVATION_STATE

    -- a(t;l) = tanh(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))
    vector_a_int := function_ntm_activation_convolutional_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_FORGET_STATE

    -- f(t;l) = sigmoid(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))
    vector_f_int := function_ntm_forget_convolutional_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_INPUT_STATE

    -- i(t;l) = sigmoid(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))
    vector_i_int := function_ntm_input_convolutional_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_STATE_STATE

    -- s(t;l) = f(t;l) o s(t-1;l) + i(t;l) o a(t;l)
    -- s(t=0;l) = 0
    vector_s_out_int := function_ntm_state_convolutional_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      vector_s_input => vector_s_in_int,
      vector_i_input => vector_i_int,
      vector_f_input => vector_f_int,
      vector_a_input => vector_a_int
      );

    -- VECTOR_OUTPUT_GATE

    -- o(t;l) = sigmoid(W(l;x)*x(t;x) + K(i;l;k)*r(t;i;k) + U(l;l)*h(t-1;l) + U(l-1;l-1)*h(t;l-1) + b(t;l))
    vector_o_int := function_ntm_output_convolutional_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_HIDDEN_GATE

    -- h(t;l) = o(t;l) o tanh(s(t;l))
    -- h(t=0;l) = 0; h(t;l=0) = 0
    vector_h_output := function_ntm_hidden_convolutional_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      vector_s_input => vector_s_out_int,
      vector_o_input => vector_o_int
      );

    return vector_h_output;
  end function function_ntm_lstm_convolutional_controller;

  -----------------------------------------------------------------------
  -- STANDARD
  -----------------------------------------------------------------------

  function function_ntm_activation_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_a_output : vector_buffer;

  begin

    -- a(t;l) = tanh(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- tanh(i(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_a_output(l) := std_logic_vector(to_float(tanh(to_real(to_float(vector_adder(l))))));
    end loop;

    return vector_a_output;
  end function function_ntm_activation_standard_gate_vector;

  function function_ntm_input_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_i_output : vector_buffer;

  begin

    -- i(t;l) = sigmoid(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- logistic(i(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_i_output(l) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(vector_adder(l)))))));
    end loop;

    return vector_i_output;
  end function function_ntm_input_standard_gate_vector;

  function function_ntm_output_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_o_output : vector_buffer;

  begin

    -- o(t;l) = sigmoid(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- logistic(o(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_o_output(l) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(vector_adder(l)))))));
    end loop;

    return vector_o_output;
  end function function_ntm_output_standard_gate_vector;

  function function_ntm_forget_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable tensor_product : matrix_buffer;
    variable matrix_product : vector_buffer;
    variable vector_adder   : vector_buffer;

    variable vector_f_output : vector_buffer;

  begin

    -- f(t;l) = sigmoid(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))

    -- Data Inputs
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := ZERO_DATA;
    end loop;

    -- K(i;l;k)·r(t;i;k)
    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        tensor_product(i, l) := ZERO_DATA;

        for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
          for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
            tensor_product(i, l) := std_logic_vector(to_float(to_real(to_float(tensor_product(i, l))) + (to_real(to_float(tensor_k_input(i, l, m)))*to_real(to_float(matrix_r_input(i, m))))));
          end loop;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(tensor_product(i, l)))));
      end loop;
    end loop;

    -- W(l;x)·x(t;x)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_w_input(l, x)))*to_real(to_float(vector_x_input(x))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- U(l;l)·h(t-1;l)
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      matrix_product(l) := ZERO_DATA;

      for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        matrix_product(l) := std_logic_vector(to_float(to_real(to_float(matrix_product(l))) + (to_real(to_float(matrix_u_input(l, m)))*to_real(to_float(vector_h_input(m))))));
      end loop;
    end loop;

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_adder(l) := std_logic_vector(to_float(to_real(to_float(vector_adder(l))) + to_real(to_float(matrix_product(l)))));
    end loop;

    -- logistic(f(t;l))
    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_f_output(l) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(vector_adder(l)))))));
    end loop;

    return vector_f_output;
  end function function_ntm_forget_standard_gate_vector;

  function function_ntm_state_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_i_input : vector_buffer;
    vector_f_input : vector_buffer;
    vector_a_input : vector_buffer
    ) return vector_buffer is

    variable vector_s_output : vector_buffer;

  begin

    -- s(t;l) = f(t;l) o s(t-1;l) + i(t;l) o a(t;l)

    -- s(t=0;l) = 0

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_s_output(l) := std_logic_vector(to_float((to_real(to_float(vector_f_input(l)))*to_real(to_float(vector_s_input(l)))) + (to_real(to_float(vector_i_input(l)))*to_real(to_float(vector_a_input(l))))));
    end loop;

    return vector_s_output;
  end function function_ntm_state_standard_gate_vector;

  function function_ntm_hidden_standard_gate_vector (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_s_input : vector_buffer;
    vector_o_input : vector_buffer
    ) return vector_buffer is

    variable vector_h_output : vector_buffer;

  begin

    -- h(t;l) = o(t;l) o tanh(s(t;l))

    -- h(t=0;l) = 0; h(t;l=0) = 0

    for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
      vector_h_output(l) := std_logic_vector(to_float(to_real(to_float(vector_o_input(l)))*tanh(to_real(to_float(vector_s_input(l))))));
    end loop;

    return vector_h_output;
  end function function_ntm_hidden_standard_gate_vector;

  function function_ntm_lstm_standard_controller (
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_w_input : matrix_buffer;
    tensor_k_input : tensor_buffer;
    matrix_u_input : matrix_buffer;
    vector_b_input : vector_buffer;

    vector_x_input : vector_buffer;
    matrix_r_input : matrix_buffer;
    vector_h_input : vector_buffer
    ) return vector_buffer is

    variable vector_a_int : vector_buffer;
    variable vector_f_int : vector_buffer;
    variable vector_i_int : vector_buffer;
    variable vector_o_int : vector_buffer;

    variable vector_s_in_int  : vector_buffer;
    variable vector_s_out_int : vector_buffer;

    variable vector_h_output : vector_buffer;

  begin

    -- VECTOR_ACTIVATION_STATE

    -- a(t;l) = tanh(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))
    vector_a_int := function_ntm_activation_standard_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_FORGET_STATE

    -- f(t;l) = sigmoid(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))
    vector_f_int := function_ntm_forget_standard_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_INPUT_STATE

    -- i(t;l) = sigmoid(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))
    vector_i_int := function_ntm_input_standard_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_STATE_STATE

    -- s(t;l) = f(t;l) o s(t-1;l) + i(t;l) o a(t;l)
    -- s(t=0;l) = 0
    vector_s_out_int := function_ntm_state_standard_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      vector_s_input => vector_s_in_int,
      vector_i_input => vector_i_int,
      vector_f_input => vector_f_int,
      vector_a_input => vector_a_int
      );

    -- VECTOR_OUTPUT_GATE

    -- o(t;l) = sigmoid(W(l;x)·x(t;x) + K(i;l;k)·r(t;i;k) + U(l;l)·h(t-1;l) + U(l-1;l-1)·h(t;l-1) + b(t;l))
    vector_o_int := function_ntm_output_standard_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      matrix_w_input => matrix_w_input,
      tensor_k_input => tensor_k_input,
      matrix_u_input => matrix_u_input,
      vector_b_input => vector_b_input,

      vector_x_input => vector_x_input,
      matrix_r_input => matrix_r_input,
      vector_h_input => vector_h_input
      );

    -- VECTOR_HIDDEN_GATE

    -- h(t;l) = o(t;l) o tanh(s(t;l))
    -- h(t=0;l) = 0; h(t;l=0) = 0
    vector_h_output := function_ntm_hidden_standard_gate_vector (
      SIZE_X_IN => SIZE_X_IN,
      SIZE_W_IN => SIZE_W_IN,
      SIZE_L_IN => SIZE_L_IN,
      SIZE_R_IN => SIZE_R_IN,

      vector_s_input => vector_s_out_int,
      vector_o_input => vector_o_int
      );

    return vector_h_output;
  end function function_ntm_lstm_standard_controller;

  -----------------------------------------------------------------------
  -- Trainer
  -----------------------------------------------------------------------

  function function_ntm_lstm_activation_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_da_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable matrix_w_output : tensor_buffer;

  begin

    -- da(t;l) = ds(t;l) o i(t;l) o (1 - a(t;l)^2)

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_da_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_a_input(t, l))))*(1.0 - to_real(to_float(vector_a_input(t, l))))));
      end loop;
    end loop;

    -- dW(t;l) = summation(da(t;l) · x(t;x))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := std_logic_vector(to_float(to_real(to_float(matrix_w_output(t, l, x))) + (to_real(to_float(vector_da_int(t, l)))*to_real(to_float(vector_x_input(t, x))))));
        end loop;
      end loop;
    end loop;

    return matrix_w_output;
  end function function_ntm_lstm_activation_w_trainer;

  function function_ntm_lstm_activation_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return array4_buffer is

    variable vector_da_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable tensor_k_output : array4_buffer;

  begin

    -- da(t;l) = ds(t;l) o i(t;l) o (1 - a(t;l)^2)

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := ZERO_DATA;
          end loop;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_da_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_a_input(t, l))))*(1.0 - to_real(to_float(vector_a_input(t, l))))));
      end loop;
    end loop;

    -- dK(t;l;i;k) = summation(da(t;l) · r(t;i;k))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := std_logic_vector(to_float(to_real(to_float(tensor_k_output(t, l, i, k))) + (to_real(to_float(vector_da_int(t, l)))*to_real(to_float(matrix_r_input(t, i, k))))));
          end loop;
        end loop;
      end loop;
    end loop;

    return tensor_k_output;
  end function function_ntm_lstm_activation_k_trainer;

  function function_ntm_lstm_activation_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_da_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable matrix_u_output : tensor_buffer;

  begin

    -- da(t;l) = ds(t;l) o i(t;l) o (1 - a(t;l)^2)

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_da_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_a_input(t, l))))*(1.0 - to_real(to_float(vector_a_input(t, l))))));
      end loop;
    end loop;

    -- dU(t;l;m) = summation(da(t+1;l) · h(t;m))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := std_logic_vector(to_float(to_real(to_float(matrix_u_output(t, l, m))) + (to_real(to_float(vector_da_int(t, l)))*to_real(to_float(vector_h_input(t, m))))));
        end loop;
      end loop;
    end loop;

    return matrix_u_output;
  end function function_ntm_lstm_activation_u_trainer;

  function function_ntm_lstm_activation_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return matrix_buffer is

    variable vector_da_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable vector_b_output : matrix_buffer;

  begin

    -- da(t;l) = ds(t;l) o i(t;l) o (1 - a(t;l)^2)

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := ZERO_DATA;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_da_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_a_input(t, l))))*(1.0 - to_real(to_float(vector_a_input(t, l))))));
      end loop;
    end loop;

    -- db(t;l) = summation(da(t;l))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := std_logic_vector(to_float(to_real(to_float(vector_b_output(t, l))) + to_real(to_float(vector_da_int(t, l)))));
      end loop;
    end loop;

    return vector_b_output;
  end function function_ntm_lstm_activation_b_trainer;

  function function_ntm_lstm_forget_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_df_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable matrix_w_output : tensor_buffer;

  begin

    -- df(t;l) = ds(t;l) o s(t-1;l) o f(t;l) o (1 - f(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_df_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_s_input(t, l)))*to_real(to_float(vector_f_input(t, l)))*(1.0 - to_real(to_float(vector_f_input(t, l))))));
      end loop;
    end loop;

    -- dW(t;l;x) = summation(df(t;l) · x(t;x))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := std_logic_vector(to_float(to_real(to_float(matrix_w_output(t, l, x))) + (to_real(to_float(vector_df_int(t, l)))*to_real(to_float(vector_x_input(t, x))))));
        end loop;
      end loop;
    end loop;

    return matrix_w_output;
  end function function_ntm_lstm_forget_w_trainer;

  function function_ntm_lstm_forget_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return array4_buffer is

    variable vector_df_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable tensor_k_output : array4_buffer;

  begin

    -- df(t;l) = ds(t;l) o s(t-1;l) o f(t;l) o (1 - f(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := ZERO_DATA;
          end loop;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_df_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_s_input(t, l)))*to_real(to_float(vector_f_input(t, l)))*(1.0 - to_real(to_float(vector_f_input(t, l))))));
      end loop;
    end loop;

    -- dK(t;l;i;k) = summation(df(t;l) · r(t;i;k))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := std_logic_vector(to_float(to_real(to_float(tensor_k_output(t, l, i, k))) + (to_real(to_float(vector_df_int(t, l)))*to_real(to_float(matrix_r_input(t, i, k))))));
          end loop;
        end loop;
      end loop;
    end loop;

    return tensor_k_output;
  end function function_ntm_lstm_forget_k_trainer;

  function function_ntm_lstm_forget_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_df_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable matrix_u_output : tensor_buffer;

  begin

    -- df(t;l) = ds(t;l) o s(t-1;l) o f(t;l) o (1 - f(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_df_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_s_input(t, l)))*to_real(to_float(vector_f_input(t, l)))*(1.0 - to_real(to_float(vector_f_input(t, l))))));
      end loop;
    end loop;

    -- dU(t;l;m) = summation(df(t+1;l) · h(t;m))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := std_logic_vector(to_float(to_real(to_float(matrix_u_output(t, l, m))) + (to_real(to_float(vector_df_int(t, l)))*to_real(to_float(vector_h_input(t, m))))));
        end loop;
      end loop;
    end loop;

    return matrix_u_output;
  end function function_ntm_lstm_forget_u_trainer;

  function function_ntm_lstm_forget_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_f_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return matrix_buffer is

    variable vector_df_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable vector_b_output : matrix_buffer;

  begin

    -- df(t;l) = ds(t;l) o s(t-1;l) o f(t;l) o (1 - f(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := ZERO_DATA;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_df_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_s_input(t, l)))*to_real(to_float(vector_f_input(t, l)))*(1.0 - to_real(to_float(vector_f_input(t, l))))));
      end loop;
    end loop;

    -- db(t;l) = summation(df(t;l))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := std_logic_vector(to_float(to_real(to_float(vector_b_output(t, l))) + to_real(to_float(vector_df_int(t, l)))));
      end loop;
    end loop;

    return vector_b_output;
  end function function_ntm_lstm_forget_b_trainer;

  function function_ntm_lstm_input_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_di_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable matrix_w_output : tensor_buffer;

  begin

    -- di(t;l) = ds(t;l) o a(t;l) o i(t;l) o (1 - i(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_di_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_a_input(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_i_input(t, l))))));
      end loop;
    end loop;

    -- dW(t;l) = summation(di(t;l) · x(t;x))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := std_logic_vector(to_float(to_real(to_float(matrix_w_output(t, l, x))) + (to_real(to_float(vector_di_int(t, l)))*to_real(to_float(vector_x_input(t, x))))));
        end loop;
      end loop;
    end loop;

    return matrix_w_output;
  end function function_ntm_lstm_input_w_trainer;

  function function_ntm_lstm_input_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return array4_buffer is

    variable vector_di_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable tensor_k_output : array4_buffer;

  begin

    -- di(t;l) = ds(t;l) o a(t;l) o i(t;l) o (1 - i(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := ZERO_DATA;
          end loop;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_di_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_a_input(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_i_input(t, l))))));
      end loop;
    end loop;

    -- dK(t;l;i;k) = summation(di(t;l) · r(t;i;k))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := std_logic_vector(to_float(to_real(to_float(tensor_k_output(t, l, i, k))) + (to_real(to_float(vector_di_int(t, l)))*to_real(to_float(matrix_r_input(t, i, k))))));
          end loop;
        end loop;
      end loop;
    end loop;

    return tensor_k_output;
  end function function_ntm_lstm_input_k_trainer;

  function function_ntm_lstm_input_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_di_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable matrix_u_output : tensor_buffer;

  begin

    -- di(t;l) = ds(t;l) o a(t;l) o i(t;l) o (1 - i(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_di_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_a_input(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_i_input(t, l))))));
      end loop;
    end loop;

    -- dU(t;l;m) = summation(di(t+1;l) · h(t;m))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := std_logic_vector(to_float(to_real(to_float(matrix_u_output(t, l, m))) + (to_real(to_float(vector_di_int(t, l)))*to_real(to_float(vector_h_input(t, m))))));
        end loop;
      end loop;
    end loop;

    return matrix_u_output;
  end function function_ntm_lstm_input_u_trainer;

  function function_ntm_lstm_input_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_i_input : matrix_buffer;
    vector_s_input : matrix_buffer
    ) return matrix_buffer is

    variable vector_di_int : matrix_buffer;
    variable vector_ds_int : matrix_buffer;

    variable vector_b_output : matrix_buffer;

  begin

    -- di(t;l) = ds(t;l) o a(t;l) o i(t;l) o (1 - i(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := ZERO_DATA;
      end loop;
    end loop;

    vector_ds_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_s_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_di_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_ds_int(t, l)))*to_real(to_float(vector_a_input(t, l)))*to_real(to_float(vector_i_input(t, l)))*(1.0 - to_real(to_float(vector_i_input(t, l))))));
      end loop;
    end loop;

    -- db(t;l) = summation(di(t;l))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := std_logic_vector(to_float(to_real(to_float(vector_b_output(t, l))) + to_real(to_float(vector_di_int(t, l)))));
      end loop;
    end loop;

    return vector_b_output;
  end function function_ntm_lstm_input_b_trainer;

  function function_ntm_lstm_output_w_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_dh_int : matrix_buffer;
    variable vector_do_int : matrix_buffer;

    variable matrix_w_output : tensor_buffer;

  begin

    -- do(t;l) = dh(t;l) o tanh(a(t;l)) o o(t;l) o (1 - o(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_dh_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_h_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_do_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_dh_int(t, l)))*tanh(to_real(to_float(vector_a_input(t, l))))*to_real(to_float(vector_o_input(t, l)))*(to_real(1.0 - to_float(vector_o_input(t, l))))));
      end loop;
    end loop;

    -- dW(t;l) = summation(do(t;l) · x(t;x))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for x in 0 to to_integer(unsigned(SIZE_X_IN))-1 loop
          matrix_w_output(t, l, x) := std_logic_vector(to_float(to_real(to_float(matrix_w_output(t, l, x))) + (to_real(to_float(vector_do_int(t, l)))*to_real(to_float(vector_x_input(t, x))))));
        end loop;
      end loop;
    end loop;

    return matrix_w_output;
  end function function_ntm_lstm_output_w_trainer;

  function function_ntm_lstm_output_k_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return array4_buffer is

    variable vector_dh_int : matrix_buffer;
    variable vector_do_int : matrix_buffer;

    variable tensor_k_output : array4_buffer;

  begin

    -- do(t;l) = dh(t;l) o tanh(a(t;l)) o o(t;l) o (1 - o(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := ZERO_DATA;
          end loop;
        end loop;
      end loop;
    end loop;

    vector_dh_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_h_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_do_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_dh_int(t, l)))*tanh(to_real(to_float(vector_a_input(t, l))))*to_real(to_float(vector_o_input(t, l)))*(to_real(1.0 - to_float(vector_o_input(t, l))))));
      end loop;
    end loop;

    -- dK(t;l;i;k) = summation(do(t;l) · r(t;i;k))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for i in 0 to to_integer(unsigned(SIZE_R_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_W_IN))-1 loop
            tensor_k_output(t, l, i, k) := std_logic_vector(to_float(to_real(to_float(tensor_k_output(t, l, i, k))) + (to_real(to_float(vector_do_int(t, l)))*to_real(to_float(matrix_r_input(t, i, k))))));
          end loop;
        end loop;
      end loop;
    end loop;

    return tensor_k_output;
  end function function_ntm_lstm_output_k_trainer;

  function function_ntm_lstm_output_u_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return tensor_buffer is

    variable vector_dh_int : matrix_buffer;
    variable vector_do_int : matrix_buffer;

    variable matrix_u_output : tensor_buffer;

  begin

    -- do(t;l) = dh(t;l) o tanh(a(t;l)) o o(t;l) o (1 - o(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    vector_dh_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_h_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_do_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_dh_int(t, l)))*tanh(to_real(to_float(vector_a_input(t, l))))*to_real(to_float(vector_o_input(t, l)))*(to_real(1.0 - to_float(vector_o_input(t, l))))));
      end loop;
    end loop;

    -- dU(t;l;m) = summation(do(t+1;l) · h(t;m))[t in 0 to T-1]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        for m in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
          matrix_u_output(t, l, m) := std_logic_vector(to_float(to_real(to_float(matrix_u_output(t, l, m))) + (to_real(to_float(vector_do_int(t, l)))*to_real(to_float(vector_h_input(t, m))))));
        end loop;
      end loop;
    end loop;

    return matrix_u_output;
  end function function_ntm_lstm_output_u_trainer;

  function function_ntm_lstm_output_b_trainer (
    SIZE_T_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_X_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_W_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_L_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_R_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_x_input : matrix_buffer;
    matrix_r_input : tensor_buffer;
    vector_h_input : matrix_buffer;

    vector_a_input : matrix_buffer;
    vector_o_input : matrix_buffer
    ) return matrix_buffer is

    variable vector_dh_int : matrix_buffer;
    variable vector_do_int : matrix_buffer;

    variable vector_b_output : matrix_buffer;

  begin

    -- do(t;l) = dh(t;l) o tanh(a(t;l)) o o(t;l) o (1 - o(t;l))

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := ZERO_DATA;
      end loop;
    end loop;

    vector_dh_int := function_vector_controller_differentiation (
      SIZE_T_IN => SIZE_T_IN,
      SIZE_L_IN => SIZE_L_IN,

      LENGTH_IN => LENGTH_IN,

      vector_input => vector_h_input
      );

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_do_int(t, l) := std_logic_vector(to_float(to_real(to_float(vector_dh_int(t, l)))*tanh(to_real(to_float(vector_a_input(t, l))))*to_real(to_float(vector_o_input(t, l)))*(to_real(1.0 - to_float(vector_o_input(t, l))))));
      end loop;
    end loop;

    -- db(t;l) = summation(do(t;l))[t in 0 to T]

    for t in 0 to to_integer(unsigned(SIZE_T_IN))-1 loop
      for l in 0 to to_integer(unsigned(SIZE_L_IN))-1 loop
        vector_b_output(t, l) := std_logic_vector(to_float(to_real(to_float(vector_b_output(t, l))) + to_real(to_float(vector_do_int(t, l)))));
      end loop;
    end loop;

    return vector_b_output;
  end function function_ntm_lstm_output_b_trainer;

end ntm_lstm_controller_pkg;
