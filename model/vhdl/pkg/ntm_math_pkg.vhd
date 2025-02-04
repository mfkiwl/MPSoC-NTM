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

package ntm_math_pkg is

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

  -----------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------

  -- Buffer
  type vector_buffer is array (CONTROL_SIZE-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);
  type matrix_buffer is array (CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);
  type tensor_buffer is array (CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0, CONTROL_SIZE-1 downto 0) of std_logic_vector(DATA_SIZE-1 downto 0);

  -----------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
  -- MATH - ALGEBRA
  -----------------------------------------------------------------------

  -- VECTOR
  component ntm_dot_product is
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

      DATA_A_IN_ENABLE : in std_logic;
      DATA_B_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_convolution is
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

      DATA_A_IN_ENABLE : in std_logic;
      DATA_B_IN_ENABLE : in std_logic;

      DATA_ENABLE : out std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_cosine_similarity is
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

      DATA_A_IN_ENABLE : in std_logic;
      DATA_B_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_A_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_multiplication is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_summation is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_module is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_ENABLE : out std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- MATRIX
  component ntm_matrix_convolution is
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

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_A_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_A_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_A_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT    : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_inverse is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_multiplication is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_product is
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

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_A_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_A_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_A_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT    : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_summation is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_transpose is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- TENSOR
  component ntm_tensor_convolution is
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
      DATA_A_IN_K_ENABLE : in std_logic;
      DATA_B_IN_I_ENABLE : in std_logic;
      DATA_B_IN_J_ENABLE : in std_logic;
      DATA_B_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_A_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_A_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_A_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_A_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT    : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_tensor_inverse is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;
      DATA_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_tensor_multiplication is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;
      DATA_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_tensor_product is
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
      DATA_A_IN_K_ENABLE : in std_logic;
      DATA_B_IN_I_ENABLE : in std_logic;
      DATA_B_IN_J_ENABLE : in std_logic;
      DATA_B_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_A_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_A_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_A_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_B_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_A_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_B_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT    : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_tensor_summation is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;
      DATA_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_tensor_transpose is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;
      DATA_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -----------------------------------------------------------------------
  -- MATH - SERIES
  -----------------------------------------------------------------------

  -- SCALAR
  component ntm_scalar_cosh_function is
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
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_scalar_exponentiator_function is
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
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_scalar_logarithm_function is
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
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_scalar_sinh_function is
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
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_scalar_tanh_function is
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
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- VECTOR
  component ntm_vector_cosh_function is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_exponentiator_function is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_logarithm_function is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_sinh_function is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_tanh_function is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- MATRIX
  component ntm_matrix_cosh_function is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_exponentiator_function is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_logarithm_function is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_sinh_function is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_tanh_function is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -----------------------------------------------------------------------
  -- MATH - FUNCTION
  -----------------------------------------------------------------------

  -- SCALAR
  component ntm_scalar_logistic_function is
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
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_scalar_oneplus_function is
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
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- VECTOR
  component ntm_vector_logistic_function is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_oneplus_function is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- MATRIX
  component ntm_matrix_logistic_function is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_oneplus_function is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -----------------------------------------------------------------------
  -- MATH - CALCULUS
  -----------------------------------------------------------------------

  -- VECTOR
  component ntm_vector_differentiation is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_ENABLE : out std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN   : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_integration is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_ENABLE : out std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN   : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_vector_softmax is
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

      DATA_IN_ENABLE : in std_logic;

      DATA_ENABLE : out std_logic;

      DATA_OUT_ENABLE : out std_logic;

      -- DATA
      SIZE_IN  : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN  : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- MATRIX
  component ntm_matrix_differentiation is
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

      CONTROL : in std_logic;

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN   : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN   : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      LENGTH_I_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      LENGTH_J_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT    : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_integration is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_matrix_softmax is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -- TENSOR
  component ntm_tensor_differentiation is
    generic (
      DATA_SIZE    : integer := 32;
      CONTROL_SIZE : integer := 64
      );
    port (
      -- GLOBAL
      CLK : in std_logic;
      RST : in std_logic;

      CONTROL : in std_logic_vector(1 downto 0);

      -- CONTROL
      START : in  std_logic;
      READY : out std_logic;

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;
      DATA_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN   : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN   : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_K_IN   : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      LENGTH_I_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      LENGTH_J_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      LENGTH_K_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN     : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT    : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_tensor_integration is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;
      DATA_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      LENGTH_IN : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  component ntm_tensor_softmax is
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

      DATA_IN_I_ENABLE : in std_logic;
      DATA_IN_J_ENABLE : in std_logic;
      DATA_IN_K_ENABLE : in std_logic;

      DATA_I_ENABLE : out std_logic;
      DATA_J_ENABLE : out std_logic;
      DATA_K_ENABLE : out std_logic;

      DATA_OUT_I_ENABLE : out std_logic;
      DATA_OUT_J_ENABLE : out std_logic;
      DATA_OUT_K_ENABLE : out std_logic;

      -- DATA
      SIZE_I_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_J_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      SIZE_K_IN : in  std_logic_vector(CONTROL_SIZE-1 downto 0);
      DATA_IN   : in  std_logic_vector(DATA_SIZE-1 downto 0);
      DATA_OUT  : out std_logic_vector(DATA_SIZE-1 downto 0)
      );
  end component;

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
  -- MATH - ALGEBRA
  -----------------------------------------------------------------------

  -- VECTOR
  function function_dot_product (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_a_input : vector_buffer;
    vector_b_input : vector_buffer

    ) return vector_buffer;

  function function_vector_convolution (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_a_input : vector_buffer;
    vector_b_input : vector_buffer

    ) return vector_buffer;

  function function_vector_cosine_similarity (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_a_input : vector_buffer;
    vector_b_input : vector_buffer

    ) return vector_buffer;

  function function_vector_module (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  function function_vector_multiplication (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  function function_vector_summation (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  -- MATRIX
  function function_matrix_convolution (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_a_input : matrix_buffer;
    matrix_b_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_inverse (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_multiplication (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_product (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_a_input : matrix_buffer;
    matrix_b_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_summation (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_transpose (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  -- TENSOR
  function function_tensor_convolution (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_a_input : tensor_buffer;
    tensor_b_input : tensor_buffer

    ) return tensor_buffer;

  function function_tensor_inverse (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer

    ) return tensor_buffer;

  function function_tensor_multiplication (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer

    ) return tensor_buffer;

  function function_tensor_product (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_a_input : tensor_buffer;
    tensor_b_input : tensor_buffer

    ) return tensor_buffer;

  function function_tensor_summation (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer

    ) return tensor_buffer;

  function function_tensor_transpose (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer

    ) return tensor_buffer;

  -----------------------------------------------------------------------
  -- MATH - SERIES
  -----------------------------------------------------------------------

  -- SCALAR
  function function_scalar_cosh (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector;

  function function_scalar_exponentiator (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector;

  function function_scalar_logarithm (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector;

  function function_scalar_sinh (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector;

  function function_scalar_tanh (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector;

  -- VECTOR
  function function_vector_cosh (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  function function_vector_exponentiator (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  function function_vector_logarithm (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  function function_vector_sinh (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  function function_vector_tanh (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer;

  -- MATRIX
  function function_matrix_cosh (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_exponentiator (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_logarithm (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_sinh (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  function function_matrix_tanh (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer

    ) return matrix_buffer;

  -----------------------------------------------------------------------
  -- MATH - FUNCTION
  -----------------------------------------------------------------------

  -- SCALAR
  function function_scalar_logistic (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector;

  function function_scalar_oneplus (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector;

  -- VECTOR
  function function_vector_logistic (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer;

  function function_vector_oneplus (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer;

  -- MATRIX
  function function_matrix_logistic (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer;

  function function_matrix_oneplus (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer;

  -----------------------------------------------------------------------
  -- MATH - CALCULUS
  -----------------------------------------------------------------------

  -- VECTOR
  function function_vector_differentiation (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer;

  function function_vector_integration (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer;

  function function_vector_softmax (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer;

  -- MATRIX
  function function_matrix_differentiation (
    CONTROL : std_logic;

    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer;

  function function_matrix_integration (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer;

  function function_matrix_softmax (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer;

  -- TENSOR
  function function_tensor_differentiation (
    CONTROL : std_logic_vector(1 downto 0);

    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer;

  function function_tensor_integration (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer;

  function function_tensor_softmax (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer;

end ntm_math_pkg;

package body ntm_math_pkg is

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------
  -- MATH - ALGEBRA
  -----------------------------------------------------------------------

  -- VECTOR
  function function_dot_product (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_a_input : vector_buffer;
    vector_b_input : vector_buffer

    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := ZERO_DATA;
    end loop;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(to_real(to_float(vector_output(i))) + (to_real(to_float(vector_a_input(i)))*to_real(to_float(vector_a_input(i))))));
    end loop;

    return vector_output;
  end function function_dot_product;

  function function_vector_convolution (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_a_input : vector_buffer;
    vector_b_input : vector_buffer

    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := ZERO_DATA;

      for m in 0 to i loop
        vector_output(i) := std_logic_vector(to_float(to_real(to_float(vector_output(i))) + (to_real(to_float(vector_a_input(m)))*to_real(to_float(vector_b_input(i-m))))));
      end loop;
    end loop;

    return vector_output;
  end function function_vector_convolution;

  function function_vector_cosine_similarity (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_a_input : vector_buffer;
    vector_b_input : vector_buffer

    ) return vector_buffer is

    variable data_a_int : std_logic_vector(DATA_SIZE-1 downto 0);
    variable data_b_int : std_logic_vector(DATA_SIZE-1 downto 0);

    variable data_p_int : vector_buffer;

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    data_a_int := ZERO_DATA;
    data_b_int := ZERO_DATA;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      data_p_int(i) := ZERO_DATA;
    end loop;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      data_a_int := std_logic_vector(to_float(to_real(to_float(data_a_int)) + (to_real(to_float(vector_a_input(i)))*to_real(to_float(vector_a_input(i))))));
      data_b_int := std_logic_vector(to_float(to_real(to_float(data_b_int)) + (to_real(to_float(vector_b_input(i)))*to_real(to_float(vector_b_input(i))))));

      data_p_int(i) := std_logic_vector(to_float(to_real(to_float(data_p_int(i))) + (to_real(to_float(data_a_int))*to_real(to_float(data_b_int)))));
    end loop;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(to_real(to_float(data_p_int(i)))/(sqrt(to_real(to_float(data_a_int)))*sqrt(to_real(to_float(data_b_int))))));
    end loop;

    return vector_output;
  end function function_vector_cosine_similarity;

  function function_vector_module (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := ZERO_DATA;
    end loop;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(to_real(to_float(vector_output(i))) + (to_real(to_float(vector_input(i)))*to_real(to_float(vector_input(i))))));
    end loop;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(sqrt(to_real(to_float(vector_output(i))))));
    end loop;

    return vector_output;
  end function function_vector_module;

  function function_vector_multiplication (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := ONE_DATA;
    end loop;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(to_real(to_float(vector_output(i)))*to_real(to_float(vector_input(i)))));
    end loop;

    return vector_output;
  end function function_vector_multiplication;

  function function_vector_summation (
    LENGTH_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer

    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := ZERO_DATA;
    end loop;

    for i in 0 to to_integer(unsigned(LENGTH_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(to_real(to_float(vector_output(i))) + to_real(to_float(vector_input(i)))));
    end loop;

    return vector_output;
  end function function_vector_summation;

  -- MATRIX
  function function_matrix_convolution (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_a_input : matrix_buffer;
    matrix_b_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_A_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_B_J_IN))-1 loop
        matrix_output(i, j) := ZERO_DATA;

        for m in 0 to i loop
          for n in 0 to j loop
            matrix_output(i, j) := std_logic_vector(to_float(to_real(to_float(matrix_output(i, j))) + (to_real(to_float(matrix_a_input(m, n)))*to_real(to_float(matrix_b_input(i-m, j-n))))));
          end loop;
        end loop;
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_convolution;

  function function_matrix_inverse (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;

    variable matrix_in_int : matrix_buffer;

    variable data_interchange_in_int  : vector_buffer;
    variable data_interchange_out_int : vector_buffer;

    variable data_quotient_int : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    matrix_in_int := matrix_input;

    for m in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      if (matrix_in_int(m, m) = ZERO_DATA) then
        for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
          if (matrix_in_int(i, m) /= ZERO_DATA) then
            for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
              data_interchange_in_int(j)  := matrix_in_int(m, j);
              data_interchange_out_int(j) := matrix_output(m, j);

              matrix_in_int(m, j) := matrix_in_int(i, j);
              matrix_output(m, j) := matrix_output(i, j);

              matrix_in_int(i, j) := data_interchange_in_int(j);
              matrix_output(i, j) := data_interchange_out_int(j);
            end loop;
          end if;
        end loop;
      end if;

      for i in m+1 to to_integer(unsigned(SIZE_I_IN))-1 loop
        data_quotient_int := std_logic_vector(to_float(to_real(to_float(matrix_in_int(i, m)))/to_real(to_float(matrix_in_int(m, m)))));

        for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
          matrix_in_int(i, j) := std_logic_vector(to_float(to_real(to_float(matrix_in_int(i, j))) - (to_real(to_float(data_quotient_int))*to_real(to_float(matrix_in_int(m, j))))));
          matrix_output(i, j) := std_logic_vector(to_float(to_real(to_float(matrix_output(i, j))) - (to_real(to_float(data_quotient_int))*to_real(to_float(matrix_output(m, j))))));
        end loop;
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_inverse;

  function function_matrix_multiplication (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := ONE_DATA;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(to_real(to_float(matrix_output(i, j)))*to_real(to_float(matrix_input(i, j)))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_multiplication;

  function function_matrix_product (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_a_input : matrix_buffer;
    matrix_b_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_A_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_B_J_IN))-1 loop
        matrix_output(i, j) := ZERO_DATA;

        for m in 0 to to_integer(unsigned(SIZE_A_J_IN))-1 loop
          matrix_output(i, j) := std_logic_vector(to_float(to_real(to_float(matrix_output(i, j))) + (to_real(to_float(matrix_a_input(i, m)))*to_real(to_float(matrix_b_input(m, j))))));
        end loop;
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_product;

  function function_matrix_summation (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := ZERO_DATA;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(to_real(to_float(matrix_output(i, j))) + to_real(to_float(matrix_input(i, j)))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_summation;

  function function_matrix_transpose (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := matrix_input(j, i);
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_transpose;

  -- TENSOR
  function function_tensor_convolution (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_a_input : tensor_buffer;
    tensor_b_input : tensor_buffer
    ) return tensor_buffer is

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_A_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_B_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_B_K_IN))-1 loop
          tensor_output(i, j, k) := ZERO_DATA;

          for m in 0 to i loop
            for n in 0 to j loop
              for p in 0 to k loop
                tensor_output(i, j, k) := std_logic_vector(to_float(to_real(to_float(tensor_output(i, j, k))) + (to_real(to_float(tensor_a_input(m, n, p)))*to_real(to_float(tensor_b_input(i-m, j-n, k-p))))));
              end loop;
            end loop;
          end loop;
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_convolution;

  function function_tensor_inverse (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer is

    variable tensor_output : tensor_buffer;

    variable tensor_in_int : tensor_buffer;

    variable data_interchange_in_int  : vector_buffer;
    variable data_interchange_out_int : vector_buffer;

    variable data_quotient_int : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    tensor_in_int := tensor_input;

    for m in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      if (tensor_in_int(m, m, m) = ZERO_DATA) then
        for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
          if (tensor_in_int(i, m, m) /= ZERO_DATA) then
            for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
              if (tensor_in_int(i, j, m) /= ZERO_DATA) then
                for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
                  data_interchange_in_int(k)  := tensor_in_int(m, m, k);
                  data_interchange_out_int(k) := tensor_output(m, m, k);

                  tensor_in_int(m, m, k) := tensor_in_int(i, j, k);
                  tensor_output(m, m, k) := tensor_output(i, j, k);

                  tensor_in_int(i, j, k) := data_interchange_in_int(k);
                  tensor_output(i, j, k) := data_interchange_out_int(k);
                end loop;
              end if;
            end loop;
          end if;
        end loop;
      end if;

      for i in m+1 to to_integer(unsigned(SIZE_I_IN))-1 loop
        data_quotient_int := std_logic_vector(to_float(to_real(to_float(tensor_in_int(i, m, m)))/to_real(to_float(tensor_in_int(m, m, m)))));

        for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
          for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
            tensor_in_int(i, j, k) := std_logic_vector(to_float(to_real(to_float(tensor_in_int(i, j, k))) - (to_real(to_float(data_quotient_int))*to_real(to_float(tensor_in_int(m, j, k))))));
            tensor_output(i, j, k) := std_logic_vector(to_float(to_real(to_float(tensor_output(i, j, k))) - (to_real(to_float(data_quotient_int))*to_real(to_float(tensor_output(m, j, k))))));
          end loop;
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_inverse;

  function function_tensor_multiplication (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer is

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          tensor_output(i, j, k) := ONE_DATA;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          tensor_output(i, j, k) := std_logic_vector(to_float(to_real(to_float(tensor_output(i, j, k)))*to_real(to_float(tensor_input(i, j, k)))));
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_multiplication;

  function function_tensor_product (
    SIZE_A_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_A_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_B_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_a_input : tensor_buffer;
    tensor_b_input : tensor_buffer
    ) return tensor_buffer is

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_A_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_B_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_B_K_IN))-1 loop
          tensor_output(i, j, k) := ZERO_DATA;

          for m in 0 to to_integer(unsigned(SIZE_A_J_IN))-1 loop
            tensor_output(i, j, k) := std_logic_vector(to_float(to_real(to_float(tensor_output(i, j, k))) + (to_real(to_float(tensor_a_input(i, j, m)))*to_real(to_float(tensor_b_input(i, m, k))))));
          end loop;
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_product;

  function function_tensor_summation (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer is

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          tensor_output(i, j, k) := ZERO_DATA;
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
          tensor_output(i, j, k) := std_logic_vector(to_float(to_real(to_float(tensor_output(i, j, k))) + to_real(to_float(tensor_input(i, j, k)))));
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_summation;

  function function_tensor_transpose (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer is

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          tensor_output(i, j, k) := tensor_input(k, j, i);
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_transpose;

  -----------------------------------------------------------------------
  -- MATH - SERIES
  -----------------------------------------------------------------------

  -- SCALAR
  function function_scalar_cosh (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector is

    variable scalar_output : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    scalar_output := std_logic_vector(to_float(cosh(to_real(to_float(scalar_input)))));

    return scalar_output;
  end function function_scalar_cosh;

  function function_scalar_exponentiator (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector is

    variable scalar_output : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    scalar_output := std_logic_vector(to_float(exp(to_real(to_float(scalar_input)))));

    return scalar_output;
  end function function_scalar_exponentiator;

  function function_scalar_logarithm (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector is

    variable scalar_output : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    scalar_output := std_logic_vector(to_float(log(to_real(to_float(scalar_input)))));

    return scalar_output;
  end function function_scalar_logarithm;

  function function_scalar_sinh (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector is

    variable scalar_output : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    scalar_output := std_logic_vector(to_float(sinh(to_real(to_float(scalar_input)))));

    return scalar_output;
  end function function_scalar_sinh;

  function function_scalar_tanh (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector is

    variable scalar_output : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    scalar_output := std_logic_vector(to_float(tanh(to_real(to_float(scalar_input)))));

    return scalar_output;
  end function function_scalar_tanh;

  -- VECTOR
  function function_vector_cosh (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(cosh(to_real(to_float(vector_input(i))))));
    end loop;

    return vector_output;
  end function function_vector_cosh;

  function function_vector_exponentiator (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(exp(to_real(to_float(vector_input(i))))));
    end loop;

    return vector_output;
  end function function_vector_exponentiator;

  function function_vector_logarithm (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(log(to_real(to_float(vector_input(i))))));
    end loop;

    return vector_output;
  end function function_vector_logarithm;

  function function_vector_sinh (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(sinh(to_real(to_float(vector_input(i))))));
    end loop;

    return vector_output;
  end function function_vector_sinh;

  function function_vector_tanh (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(tanh(to_real(to_float(vector_input(i))))));
    end loop;

    return vector_output;
  end function function_vector_tanh;

  -- MATRIX
  function function_matrix_cosh (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(cosh(to_real(to_float(matrix_input(i, j))))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_cosh;

  function function_matrix_exponentiator (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(exp(to_real(to_float(matrix_input(i, j))))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_exponentiator;

  function function_matrix_logarithm (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(log(to_real(to_float(matrix_input(i, j))))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_logarithm;

  function function_matrix_sinh (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(sinh(to_real(to_float(matrix_input(i, j))))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_sinh;

  function function_matrix_tanh (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(tanh(to_real(to_float(matrix_input(i, j))))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_tanh;

  -----------------------------------------------------------------------
  -- MATH - FUNCTION
  -----------------------------------------------------------------------

  -- SCALAR
  function function_scalar_logistic (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector is

    variable scalar_output : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    scalar_output := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(scalar_input))))));

    return scalar_output;
  end function function_scalar_logistic;

  function function_scalar_oneplus (
    scalar_input : std_logic_vector(DATA_SIZE-1 downto 0)

    ) return std_logic_vector is

    variable scalar_output : std_logic_vector(DATA_SIZE-1 downto 0);
  begin
    -- Data Inputs
    scalar_output := std_logic_vector(to_float(1.0+log(1.0+1.0+exp(to_real(to_float(scalar_input))))));

    return scalar_output;
  end function function_scalar_oneplus;

  -- VECTOR
  function function_vector_logistic (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(vector_input(i)))))));
    end loop;

    return vector_output;
  end function function_vector_logistic;

  function function_vector_oneplus (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(1.0+log(1.0+1.0+exp(to_real(to_float(vector_input(i)))))));
    end loop;

    return vector_output;
  end function function_vector_oneplus;

  -- MATRIX
  function function_matrix_logistic (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(1.0/(1.0+1.0/exp(to_real(to_float(matrix_input(i, j)))))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_logistic;

  function function_matrix_oneplus (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(1.0+log(1.0+1.0+exp(to_real(to_float(matrix_input(i, j)))))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_oneplus;

  -----------------------------------------------------------------------
  -- MATH - CALCULUS
  -----------------------------------------------------------------------

  -- VECTOR
  function function_vector_differentiation (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      if (i = 0) then
        vector_output(i) := std_logic_vector(to_float((to_real(to_float(vector_input(i))) - to_real(to_float(vector_input(i))))/to_real(to_float(LENGTH_IN))));
      else
        vector_output(i) := std_logic_vector(to_float((to_real(to_float(vector_input(i))) - to_real(to_float(vector_input(i-1))))/to_real(to_float(LENGTH_IN))));
      end if;
    end loop;

    return vector_output;
  end function function_vector_differentiation;

  function function_vector_integration (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable data_summation_int : std_logic_vector(DATA_SIZE-1 downto 0);

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    data_summation_int := ZERO_DATA;

    for m in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      data_summation_int := std_logic_vector(to_float(to_real(to_float(data_summation_int)) + to_real(to_float(vector_input(m)))));
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(to_real(to_float(vector_input(i)))*to_real(to_float(LENGTH_IN))));
    end loop;

    return vector_output;
  end function function_vector_integration;

  function function_vector_softmax (
    SIZE_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    vector_input : vector_buffer
    ) return vector_buffer is

    variable data_summation_int : std_logic_vector(DATA_SIZE-1 downto 0);

    variable vector_output : vector_buffer;
  begin
    -- Data Inputs
    data_summation_int := ZERO_DATA;

    for m in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      data_summation_int := std_logic_vector(to_float(to_real(to_float(data_summation_int)) + exp(to_real(to_float(vector_input(m))))));
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_IN))-1 loop
      vector_output(i) := std_logic_vector(to_float(exp(to_real(to_float(vector_input(i))))/to_real(to_float(data_summation_int))));
    end loop;

    return vector_output;
  end function function_vector_softmax;

  -- MATRIX
  function function_matrix_differentiation (
    CONTROL : std_logic;

    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        if (CONTROL = '0') then
          if (i = 0) then
            matrix_output(i, j) := std_logic_vector(to_float((to_real(to_float(matrix_input(i, j))) - to_real(to_float(matrix_input(i, j))))/to_real(to_float(LENGTH_IN))));
          else
            matrix_output(i, j) := std_logic_vector(to_float((to_real(to_float(matrix_input(i, j))) - to_real(to_float(matrix_input(i-1, j))))/to_real(to_float(LENGTH_IN))));
          end if;
        elsif (CONTROL = '1') then
          if (j = 0) then
            matrix_output(i, j) := std_logic_vector(to_float((to_real(to_float(matrix_input(i, j))) - to_real(to_float(matrix_input(i, j))))/to_real(to_float(LENGTH_IN))));
          else
            matrix_output(i, j) := std_logic_vector(to_float((to_real(to_float(matrix_input(i, j))) - to_real(to_float(matrix_input(i, j-1))))/to_real(to_float(LENGTH_IN))));
          end if;
        end if;
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_differentiation;

  function function_matrix_integration (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable data_summation_int : std_logic_vector(DATA_SIZE-1 downto 0);

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    data_summation_int := ZERO_DATA;

    for m in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for n in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        data_summation_int := std_logic_vector(to_float(to_real(to_float(data_summation_int)) + to_real(to_float(matrix_input(m, n)))));
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(to_real(to_float(matrix_input(i, j)))*to_real(to_float(LENGTH_IN))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_integration;

  function function_matrix_softmax (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    matrix_input : matrix_buffer
    ) return matrix_buffer is

    variable data_summation_int : std_logic_vector(DATA_SIZE-1 downto 0);

    variable matrix_output : matrix_buffer;
  begin
    -- Data Inputs
    data_summation_int := ZERO_DATA;

    for m in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for n in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        data_summation_int := std_logic_vector(to_float(to_real(to_float(data_summation_int)) + exp(to_real(to_float(matrix_input(m, n))))));
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        matrix_output(i, j) := std_logic_vector(to_float(exp(to_real(to_float(matrix_input(i, j))))/to_real(to_float(data_summation_int))));
      end loop;
    end loop;

    return matrix_output;
  end function function_matrix_softmax;

  -- TENSOR
  function function_tensor_differentiation (
    CONTROL : std_logic_vector(1 downto 0);

    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer is

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          if (CONTROL = "01") then
            if (i = 0) then
              tensor_output(i, j, k) := std_logic_vector(to_float((to_real(to_float(tensor_input(i, j, k))) - to_real(to_float(tensor_input(i, j, k))))/to_real(to_float(LENGTH_IN))));
            else
              tensor_output(i, j, k) := std_logic_vector(to_float((to_real(to_float(tensor_input(i, j, k))) - to_real(to_float(tensor_input(i-1, j, k))))/to_real(to_float(LENGTH_IN))));
            end if;
          elsif (CONTROL = "10") then
            if (j = 0) then
              tensor_output(i, j, k) := std_logic_vector(to_float((to_real(to_float(tensor_input(i, j, k))) - to_real(to_float(tensor_input(i, j, k))))/to_real(to_float(LENGTH_IN))));
            else
              tensor_output(i, j, k) := std_logic_vector(to_float((to_real(to_float(tensor_input(i, j, k))) - to_real(to_float(tensor_input(i, j-1, k))))/to_real(to_float(LENGTH_IN))));
            end if;
          elsif (CONTROL = "11") then
            if (k = 0) then
              tensor_output(i, j, k) := std_logic_vector(to_float((to_real(to_float(tensor_input(i, j, k))) - to_real(to_float(tensor_input(i, j, k))))/to_real(to_float(LENGTH_IN))));
            else
              tensor_output(i, j, k) := std_logic_vector(to_float((to_real(to_float(tensor_input(i, j, k))) - to_real(to_float(tensor_input(i, j, k-1))))/to_real(to_float(LENGTH_IN))));
            end if;
          end if;
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_differentiation;

  function function_tensor_integration (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    LENGTH_IN : std_logic_vector(DATA_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer is

    variable data_summation_int : std_logic_vector(DATA_SIZE-1 downto 0);

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    data_summation_int := ZERO_DATA;

    for m in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for n in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for p in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          data_summation_int := std_logic_vector(to_float(to_real(to_float(data_summation_int)) + to_real(to_float(tensor_input(m, n, p)))));
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          tensor_output(i, j, k) := std_logic_vector(to_float(to_real(to_float(tensor_input(i, j, k)))*to_real(to_float(LENGTH_IN))));
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_integration;

  function function_tensor_softmax (
    SIZE_I_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_J_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);
    SIZE_K_IN : std_logic_vector(CONTROL_SIZE-1 downto 0);

    tensor_input : tensor_buffer
    ) return tensor_buffer is

    variable data_summation_int : std_logic_vector(DATA_SIZE-1 downto 0);

    variable tensor_output : tensor_buffer;
  begin
    -- Data Inputs
    data_summation_int := ZERO_DATA;

    for m in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for n in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for p in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          data_summation_int := std_logic_vector(to_float(to_real(to_float(data_summation_int)) + exp(to_real(to_float(tensor_input(m, n, p))))));
        end loop;
      end loop;
    end loop;

    for i in 0 to to_integer(unsigned(SIZE_I_IN))-1 loop
      for j in 0 to to_integer(unsigned(SIZE_J_IN))-1 loop
        for k in 0 to to_integer(unsigned(SIZE_K_IN))-1 loop
          tensor_output(i, j, k) := std_logic_vector(to_float(exp(to_real(to_float(tensor_input(i, j, k))))/to_real(to_float(data_summation_int))));
        end loop;
      end loop;
    end loop;

    return tensor_output;
  end function function_tensor_softmax;

end ntm_math_pkg;
