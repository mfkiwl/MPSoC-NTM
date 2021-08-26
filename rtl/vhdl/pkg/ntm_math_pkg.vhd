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

package ntm_math_pkg is

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  type std_logic_matrix is array (integer range <>) of std_logic_vector;
  type std_logic_3array is array (integer range <>) of std_logic_matrix;

  type std_logic_arithmetic_vector_vector is array (integer range <>) of std_logic_vector;
  type std_logic_arithmetic_vector_matrix is array (integer range <>) of std_logic_matrix;

  -----------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------

  constant I : integer := 64;
  constant J : integer := 64;

  constant X : integer := 64;
  constant Y : integer := 64;
  constant W : integer := 64;
  constant N : integer := 64;
  constant L : integer := 64;

  constant DATA_SIZE : integer := 512;

  -----------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
  -- MATH - ARITHMETIC
  -----------------------------------------------------------------------

  -- SCALAR
  component ntm_scalar_mod is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_adder is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      OPERATION : in std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_multiplier is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_inverter is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_divider is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_exponentiator is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO               : in  std_logic_vector(DATA_SIZE-1 downto 0);
      BASE_EXPONENTIATION  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      POWER_EXPONENTIATION : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT             : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_root is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      BASE_ROOT  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      POWER_ROOT : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT   : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_logarithm is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  -- VECTOR
  component ntm_vector_mod is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_adder is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      OPERATION : in std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_multiplier is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_inverter is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_divider is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_exponentiator is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO               : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      BASE_EXPONENTIATION  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      POWER_EXPONENTIATION : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT             : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_root is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO     : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      BASE_ROOT  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      POWER_ROOT : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT   : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_logarithm is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_vector(I-1 downto 0);

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  -- MATRIX
  component ntm_matrix_mod is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_adder is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      OPERATION : in std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_multiplier is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_inverter is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_divider is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_exponentiator is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO               : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      BASE_EXPONENTIATION  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      POWER_EXPONENTIATION : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT             : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_root is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO     : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      BASE_ROOT  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      POWER_ROOT : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT   : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_logarithm is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic_matrix(I-1 downto 0)(J-1 downto 0);

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  -----------------------------------------------------------------------
  -- MATH - ALGEBRA
  -----------------------------------------------------------------------

  component ntm_matrix_determinant is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_inversion is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_product is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_rank is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_transpose is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_product is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_product is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  -----------------------------------------------------------------------
  -- MATH - FUNCTION
  -----------------------------------------------------------------------

  -- SCALAR
  component ntm_scalar_convolution_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_cosine_similarity_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      SIZE_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_U_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_V_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_multiplication_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_cosh_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_sinh_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_tanh_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_logistic_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_softmax_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      SIZE_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_oneplus_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_scalar_summation_function is
    generic (
      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
  end component;

  -- VECTOR
  component ntm_vector_convolution_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_cosine_similarity_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      SIZE_IN   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_U_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_V_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_multiplication_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_cosh_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_sinh_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_tanh_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_logistic_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_softmax_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      SIZE_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_oneplus_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_vector_summation_function is
    generic (
      I : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_vector(I-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  -- MATRIX
  component ntm_matrix_convolution_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_cosine_similarity_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      SIZE_IN   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_U_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_V_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_multiplication_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_cosh_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_sinh_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_tanh_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_logistic_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
      );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_softmax_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      SIZE_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_oneplus_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO   : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  component ntm_matrix_summation_function is
    generic (
      I : integer := 64;
      J : integer := 64;

      DATA_SIZE : integer := 512
    );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      -- DATA
      MODULO    : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_arithmetic_vector_matrix(I-1 downto 0)(J-1 downto 0)(DATA_SIZE-1 downto 0)
    );
  end component;

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

  function to_stdlogic (input : boolean) return std_logic;

end ntm_math_pkg;

package body ntm_math_pkg is

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

  function to_stdlogic (
    input : boolean
  ) return std_logic is
  begin
    if input then
      return('1');
    else
      return('0');
    end if;
  end function to_stdlogic;

end ntm_math_pkg;
