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
use work.ntm_dnc_core_pkg.all;

entity ntm_memory_testbench is
end ntm_memory_testbench;

architecture ntm_memory_testbench_architecture of ntm_memory_testbench is

  -----------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------

  -- GLOBAL
  signal CLK : std_logic;
  signal RST : std_logic;

  -- ALLOCATION WEIGHTING
  -- CONTROL
  signal start_allocation_weighting : std_logic;
  signal ready_allocation_weighting : std_logic;

  -- DATA
  signal modulo_allocation_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal phi_in_allocation_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal u_in_allocation_weighting   : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal a_out_allocation_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- BACKWARD WEIGHTING
  -- CONTROL
  signal start_backward_weighting : std_logic;
  signal ready_backward_weighting : std_logic;

  -- DATA
  signal modulo_backward_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal l_in_backward_weighting   : std_logic_arithmetic_vector_matrix(X-1 downto 0)(Y-1 downto 0)(DATA_SIZE-1 downto 0);
  signal w_in_backward_weighting   : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal b_out_backward_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- FORWARD WEIGHTING
  -- CONTROL
  signal start_forward_weighting : std_logic;
  signal ready_forward_weighting : std_logic;

  -- DATA
  signal l_in_forward_weighting : std_logic_arithmetic_vector_matrix(X-1 downto 0)(Y-1 downto 0)(DATA_SIZE-1 downto 0);

  signal w_in_forward_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_forward_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal f_out_forward_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- MEMORY MATRIX
  -- CONTROL
  signal start_memory_matrix : std_logic;
  signal ready_memory_matrix : std_logic;

  -- DATA
  signal m_in_memory_matrix : std_logic_arithmetic_vector_matrix(X-1 downto 0)(Y-1 downto 0)(DATA_SIZE-1 downto 0);

  signal w_in_memory_matrix : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal e_in_memory_matrix : std_logic_arithmetic_vector_vector(Y-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_memory_matrix : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal r_out_memory_matrix  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- MEMORY RETENTION VECTOR
  -- CONTROL
  signal start_memory_retention_vector : std_logic;
  signal ready_memory_retention_vector : std_logic;

  -- DATA
  signal f_in_memory_retention_vector : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal w_in_memory_retention_vector : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_memory_retention_vector  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal PSI_OUT_memory_retention_vector : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- PRECEDENCE WEIGHTING
  -- CONTROL
  signal start_precedence_weighting : std_logic;
  signal ready_precedence_weighting : std_logic;

  -- DATA
  signal w_in_precedence_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal p_in_precedence_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_precedence_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal P_OUT_precedence_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- READ CONTENT WEIGHTING
  -- CONTROL
  signal start_read_content_weighting : std_logic;
  signal ready_read_content_weighting : std_logic;

  -- DATA
  signal k_in_read_content_weighting    : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal m_in_read_content_weighting    : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal beta_in_read_content_weighting : std_logic_vector(DATA_SIZE-1 downto 0);

  signal modulo_read_content_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal c_out_read_content_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- READ VECTORS
  -- CONTROL
  signal start_read_vectors : std_logic;
  signal ready_read_vectors : std_logic;

  -- DATA
  signal m_in_read_vectors : std_logic_arithmetic_vector_matrix(X-1 downto 0)(Y-1 downto 0)(DATA_SIZE-1 downto 0);

  signal w_in_read_vectors : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_read_vectors : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal r_out_read_vectors  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- READ WEIGHTING
  -- CONTROL
  signal start_read_weighting : std_logic;
  signal ready_read_weighting : std_logic;

  -- DATA
  signal PI_IN_read_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal b_in_read_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal c_in_read_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal f_in_read_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_read_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal w_out_read_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- TEMPORAL LINK MATRIX
  -- CONTROL
  signal start_temporal_link_matrix : std_logic;
  signal ready_temporal_link_matrix : std_logic;

  -- DATA
  signal l_in_temporal_link_matrix : std_logic_arithmetic_vector_matrix(X-1 downto 0)(Y-1 downto 0)(DATA_SIZE-1 downto 0);

  signal wr_in_temporal_link_matrix : std_logic_arithmetic_vector_vector(Y-1 downto 0)(DATA_SIZE-1 downto 0);
  signal ww_in_temporal_link_matrix : std_logic_arithmetic_vector_vector(Y-1 downto 0)(DATA_SIZE-1 downto 0);
  signal p_in_temporal_link_matrix  : std_logic_arithmetic_vector_vector(Y-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_temporal_link_matrix : std_logic_arithmetic_vector_matrix(X-1 downto 0)(Y-1 downto 0)(DATA_SIZE-1 downto 0);
  signal l_out_temporal_link_matrix  : std_logic_arithmetic_vector_matrix(X-1 downto 0)(Y-1 downto 0)(DATA_SIZE-1 downto 0);

  -- USAGE VECTOR
  -- CONTROL
  signal start_usage_vector : std_logic;
  signal ready_usage_vector : std_logic;

  -- DATA
  signal u_in_usage_vector   : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal w_in_usage_vector   : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal psi_in_usage_vector : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_usage_vector : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal u_out_usage_vector  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- WRITE CONTENT WEIGHTING
  -- CONTROL
  signal start_write_content_weighting : std_logic;
  signal ready_write_content_weighting : std_logic;

  -- DATA
  signal k_in_write_content_weighting    : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal m_in_write_content_weighting    : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal beta_in_write_content_weighting : std_logic_vector(DATA_SIZE-1 downto 0);

  signal modulo_write_content_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal c_out_write_content_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- WRITE WEIGHTING
  -- CONTROL
  signal start_write_weighting : std_logic;
  signal ready_write_weighting : std_logic;

  -- DATA
  signal a_in_write_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal c_in_write_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal ga_in_write_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal gw_in_write_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  signal modulo_write_weighting : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);
  signal w_out_write_weighting  : std_logic_arithmetic_vector_vector(X-1 downto 0)(DATA_SIZE-1 downto 0);

  -- ADDRESSING
  -- CONTROL
  signal start_addressing : std_logic;
  signal ready_addressing : std_logic;

begin

  -----------------------------------------------------------------------
  -- Body
  -----------------------------------------------------------------------

  -- ALLOCATION WEIGHTING
  allocation_weighting : ntm_allocation_weighting
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_allocation_weighting,
      READY => ready_allocation_weighting,

      -- DATA
      PHI_IN => phi_in_allocation_weighting,
      U_IN   => u_in_allocation_weighting,

      MODULO => modulo_allocation_weighting,
      A_OUT  => a_out_allocation_weighting
    );

  -- BACKWARD WEIGHTING
  backward_weighting : ntm_backward_weighting
    generic map (
      X => X,
      Y => Y,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_backward_weighting,
      READY => ready_backward_weighting,

      -- DATA
      L_IN => l_in_backward_weighting,

      W_IN => w_in_backward_weighting,

      MODULO => modulo_backward_weighting,
      B_OUT  => b_out_backward_weighting
    );

  -- FORWARD WEIGHTING
  forward_weighting : ntm_forward_weighting
    generic map (
      X => X,
      Y => Y,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_forward_weighting,
      READY => ready_forward_weighting,

      -- DATA
      L_IN => l_in_forward_weighting,

      W_IN => w_in_forward_weighting,

      MODULO => modulo_forward_weighting,
      F_OUT  => f_out_forward_weighting
    );

  -- MEMORY MATRIX
  memory_matrix : ntm_memory_matrix
    generic map (
      X => X,
      Y => Y,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_memory_matrix,
      READY => ready_memory_matrix,

      -- DATA
      M_IN => m_in_memory_matrix,

      W_IN => w_in_memory_matrix,
      E_IN => e_in_memory_matrix,

      MODULO => modulo_memory_matrix,
      R_OUT  => r_out_memory_matrix
    );

  -- MEMORY RETENTION VECTOR
  memory_retention_vector : ntm_memory_retention_vector
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_memory_retention_vector,
      READY => ready_memory_retention_vector,

      -- DATA
      F_IN => f_in_memory_retention_vector,
      W_IN => w_in_memory_retention_vector,

      MODULO  => modulo_memory_retention_vector,
      PSI_OUT => psi_out_memory_retention_vector
    );

  -- PRECEDENCE WEIGHTING
  precedence_weighting : ntm_precedence_weighting
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_precedence_weighting,
      READY => ready_precedence_weighting,

      -- DATA
      W_IN => w_in_precedence_weighting,
      P_IN => p_in_precedence_weighting,

      MODULO => modulo_precedence_weighting,
      P_OUT  => p_out_precedence_weighting
    );

  -- READ CONTENT WEIGHTING
  read_content_weighting : ntm_read_content_weighting
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_read_content_weighting,
      READY => ready_read_content_weighting,

      -- DATA
      K_IN    => k_in_read_content_weighting,
      M_IN    => m_in_read_content_weighting,
      BETA_IN => beta_in_read_content_weighting,

      MODULO => modulo_read_content_weighting,
      C_OUT  => c_out_read_content_weighting
    );

  -- READ VECTORS
  read_vectors : ntm_read_vectors
    generic map (
      X => X,
      Y => Y,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_read_vectors,
      READY => ready_read_vectors,

      -- DATA
      M_IN => m_in_read_vectors,

      W_IN => w_in_read_vectors,

      MODULO => modulo_read_vectors,
      R_OUT  => r_out_read_vectors
    );

  -- READ WEIGHTING
  read_weighting : ntm_read_weighting
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_read_weighting,
      READY => ready_read_weighting,

      -- DATA
      PI_IN => pi_in_read_weighting,

      B_IN => b_in_read_weighting,
      C_IN => c_in_read_weighting,
      F_IN => f_in_read_weighting,

      MODULO => modulo_read_weighting,
      W_OUT  => w_out_read_weighting
    );

  -- TEMPORAL LINK MATRIX
  temporal_link_matrix : ntm_temporal_link_matrix
    generic map (
      X => X,
      Y => Y,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_temporal_link_matrix,
      READY => ready_temporal_link_matrix,

      -- DATA
      L_IN => l_in_temporal_link_matrix,

      WR_IN => wr_in_temporal_link_matrix,
      WW_IN => ww_in_temporal_link_matrix,
      P_IN  => p_in_temporal_link_matrix,

      MODULO => modulo_temporal_link_matrix,
      L_OUT  => l_out_temporal_link_matrix
    );

  -- USAGE VECTOR
  usage_vector : ntm_usage_vector
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_usage_vector,
      READY => ready_usage_vector,

      -- DATA
      U_IN   => u_in_usage_vector,
      W_IN   => w_in_usage_vector,
      PSI_IN => psi_in_usage_vector,

      MODULO => modulo_usage_vector,
      U_OUT  => u_out_usage_vector
    );

  -- WRITE CONTENT WEIGHTING
  write_content_weighting : ntm_write_content_weighting
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_write_content_weighting,
      READY => ready_write_content_weighting,

      -- DATA
      K_IN    => k_in_write_content_weighting,
      M_IN    => m_in_write_content_weighting,
      BETA_IN => beta_in_write_content_weighting,

      MODULO => modulo_write_content_weighting,
      C_OUT  => c_out_write_content_weighting
    );

  -- WRITE WEIGHTING
  write_weighting : ntm_write_weighting
    generic map (
      X => X,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_write_weighting,
      READY => ready_write_weighting,

      -- DATA
      A_IN => a_in_write_weighting,
      C_IN => c_in_write_weighting,

      -- DATA
      GA_IN => ga_in_write_weighting,
      GW_IN => gw_in_write_weighting,

      MODULO => modulo_write_weighting,
      W_OUT  => w_out_write_weighting
    );

  -- ADDRESSING
  addressing : ntm_addressing
    generic map (
      X => X,
      Y => Y,

      DATA_SIZE => DATA_SIZE
    )
    port map (
      -- GLOBAL
      CLK => CLK,
      RST => RST,

      -- CONTROL
      START => start_addressing,
      READY => ready_addressing
    );

end ntm_memory_testbench_architecture;
