@echo off
call ../../../../../../../settings64_ghdl.bat

ghdl -a --std=08 ../../../../../../../rtl/vhdl/pkg/ntm_arithmetic_pkg.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/pkg/ntm_math_pkg.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/pkg/ntm_core_pkg.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/scalar/ntm_scalar_float_adder.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/scalar/ntm_scalar_float_multiplier.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/scalar/ntm_scalar_float_divider.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/vector/ntm_vector_float_adder.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/vector/ntm_vector_float_multiplier.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/vector/ntm_vector_float_divider.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/matrix/ntm_matrix_float_adder.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/matrix/ntm_matrix_float_multiplier.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/matrix/ntm_matrix_float_divider.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/scalar/ntm_scalar_adder.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/scalar/ntm_scalar_multiplier.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/scalar/ntm_scalar_divider.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/vector/ntm_vector_adder.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/vector/ntm_vector_multiplier.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/vector/ntm_vector_divider.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/matrix/ntm_matrix_adder.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/matrix/ntm_matrix_multiplier.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/float/matrix/ntm_matrix_divider.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_cosh_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_cosine_similarity_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_exponentiator_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_logarithm_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_logistic_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_multiplication_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_oneplus_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_sinh_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_softmax_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_summation_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/scalar/ntm_scalar_tanh_function.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_cosh_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_cosine_similarity_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_exponentiator_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_logarithm_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_logistic_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_multiplication_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_oneplus_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_sinh_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_softmax_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_summation_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/vector/ntm_vector_tanh_function.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_cosh_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_cosine_similarity_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_exponentiator_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_logarithm_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_logistic_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_multiplication_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_oneplus_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_sinh_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_softmax_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_summation_function.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/math/function/matrix/ntm_matrix_tanh_function.vhd

ghdl -a --std=08 ../../../../../../../rtl/vhdl/ntm/memory/ntm_addressing.vhd
ghdl -a --std=08 ../../../../../../../rtl/vhdl/ntm/memory/ntm_content_based_addressing.vhd

ghdl -a --std=08 ../../../../../../../bench/vhdl/tests/ntm/memory/ntm_memory_pkg.vhd
ghdl -a --std=08 ../../../../../../../bench/vhdl/tests/ntm/memory/ntm_memory_stimulus.vhd
ghdl -a --std=08 ../../../../../../../bench/vhdl/tests/ntm/memory/ntm_memory_testbench.vhd
ghdl -m --std=08 ntm_memory_testbench
ghdl -r --std=08 ntm_memory_testbench --ieee-asserts=disable-at-0 --disp-tree=inst > ntm_memory_testbench.tree
pause