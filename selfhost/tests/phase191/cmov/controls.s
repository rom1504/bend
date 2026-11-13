.text
.globl p191mc_bytes_0
.type p191mc_bytes_0, @function
p191mc_bytes_0:
  cmovel %r10d, %r9d
.size p191mc_bytes_0, .-p191mc_bytes_0
.globl p191mc_bytes_1
.type p191mc_bytes_1, @function
p191mc_bytes_1:
  cmovnel %r10d, %r9d
.size p191mc_bytes_1, .-p191mc_bytes_1
.globl p191mc_bytes_2
.type p191mc_bytes_2, @function
p191mc_bytes_2:
  cmovbl %r10d, %r9d
.size p191mc_bytes_2, .-p191mc_bytes_2
.globl p191mc_bytes_3
.type p191mc_bytes_3, @function
p191mc_bytes_3:
  cmovbel %r10d, %r9d
.size p191mc_bytes_3, .-p191mc_bytes_3
.globl p191mc_bytes_4
.type p191mc_bytes_4, @function
p191mc_bytes_4:
  cmoval %r10d, %r9d
.size p191mc_bytes_4, .-p191mc_bytes_4
.globl p191mc_bytes_5
.type p191mc_bytes_5, @function
p191mc_bytes_5:
  cmovael %r10d, %r9d
.size p191mc_bytes_5, .-p191mc_bytes_5
.globl p191mc_bytes_6
.type p191mc_bytes_6, @function
p191mc_bytes_6:
  cmovll %r10d, %r9d
.size p191mc_bytes_6, .-p191mc_bytes_6
.globl p191mc_bytes_7
.type p191mc_bytes_7, @function
p191mc_bytes_7:
  cmovlel %r10d, %r9d
.size p191mc_bytes_7, .-p191mc_bytes_7
.globl p191mc_bytes_8
.type p191mc_bytes_8, @function
p191mc_bytes_8:
  cmovgl %r10d, %r9d
.size p191mc_bytes_8, .-p191mc_bytes_8
.globl p191mc_bytes_9
.type p191mc_bytes_9, @function
p191mc_bytes_9:
  cmovgel %r10d, %r9d
.size p191mc_bytes_9, .-p191mc_bytes_9
.globl p191mc_bytes_10
.type p191mc_bytes_10, @function
p191mc_bytes_10:
  cmoveq %r10, %r9
.size p191mc_bytes_10, .-p191mc_bytes_10
.globl p191mc_bytes_11
.type p191mc_bytes_11, @function
p191mc_bytes_11:
  cmovneq %r10, %r9
.size p191mc_bytes_11, .-p191mc_bytes_11
.globl p191mc_bytes_12
.type p191mc_bytes_12, @function
p191mc_bytes_12:
  cmovbq %r10, %r9
.size p191mc_bytes_12, .-p191mc_bytes_12
.globl p191mc_bytes_13
.type p191mc_bytes_13, @function
p191mc_bytes_13:
  cmovbeq %r10, %r9
.size p191mc_bytes_13, .-p191mc_bytes_13
.globl p191mc_bytes_14
.type p191mc_bytes_14, @function
p191mc_bytes_14:
  cmovaq %r10, %r9
.size p191mc_bytes_14, .-p191mc_bytes_14
.globl p191mc_bytes_15
.type p191mc_bytes_15, @function
p191mc_bytes_15:
  cmovaeq %r10, %r9
.size p191mc_bytes_15, .-p191mc_bytes_15
.globl p191mc_bytes_16
.type p191mc_bytes_16, @function
p191mc_bytes_16:
  cmovlq %r10, %r9
.size p191mc_bytes_16, .-p191mc_bytes_16
.globl p191mc_bytes_17
.type p191mc_bytes_17, @function
p191mc_bytes_17:
  cmovleq %r10, %r9
.size p191mc_bytes_17, .-p191mc_bytes_17
.globl p191mc_bytes_18
.type p191mc_bytes_18, @function
p191mc_bytes_18:
  cmovgq %r10, %r9
.size p191mc_bytes_18, .-p191mc_bytes_18
.globl p191mc_bytes_19
.type p191mc_bytes_19, @function
p191mc_bytes_19:
  cmovgeq %r10, %r9
.size p191mc_bytes_19, .-p191mc_bytes_19
.globl p191mc_bytes_20
.type p191mc_bytes_20, @function
p191mc_bytes_20:
  cmovel %ecx, %eax
.size p191mc_bytes_20, .-p191mc_bytes_20
.globl p191mc_bytes_21
.type p191mc_bytes_21, @function
p191mc_bytes_21:
  cmoveq 0(%rbp), %rax
.size p191mc_bytes_21, .-p191mc_bytes_21
.globl p191mc_bytes_22
.type p191mc_bytes_22, @function
p191mc_bytes_22:
  cmovneq 0(%r13,%r12,8), %r10
.size p191mc_bytes_22, .-p191mc_bytes_22
.globl p191mc_bytes_23
.type p191mc_bytes_23, @function
p191mc_bytes_23:
  cmovgel -129(%r12), %r8d
.size p191mc_bytes_23, .-p191mc_bytes_23
.globl p191mc_e_32
.type p191mc_e_32, @function
p191mc_e_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovel %edx, %eax
  ret
.size p191mc_e_32, .-p191mc_e_32
.globl p191mc_ne_32
.type p191mc_ne_32, @function
p191mc_ne_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovnel %edx, %eax
  ret
.size p191mc_ne_32, .-p191mc_ne_32
.globl p191mc_b_32
.type p191mc_b_32, @function
p191mc_b_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovbl %edx, %eax
  ret
.size p191mc_b_32, .-p191mc_b_32
.globl p191mc_be_32
.type p191mc_be_32, @function
p191mc_be_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovbel %edx, %eax
  ret
.size p191mc_be_32, .-p191mc_be_32
.globl p191mc_a_32
.type p191mc_a_32, @function
p191mc_a_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmoval %edx, %eax
  ret
.size p191mc_a_32, .-p191mc_a_32
.globl p191mc_ae_32
.type p191mc_ae_32, @function
p191mc_ae_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovael %edx, %eax
  ret
.size p191mc_ae_32, .-p191mc_ae_32
.globl p191mc_l_32
.type p191mc_l_32, @function
p191mc_l_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovll %edx, %eax
  ret
.size p191mc_l_32, .-p191mc_l_32
.globl p191mc_le_32
.type p191mc_le_32, @function
p191mc_le_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovlel %edx, %eax
  ret
.size p191mc_le_32, .-p191mc_le_32
.globl p191mc_g_32
.type p191mc_g_32, @function
p191mc_g_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovgl %edx, %eax
  ret
.size p191mc_g_32, .-p191mc_g_32
.globl p191mc_ge_32
.type p191mc_ge_32, @function
p191mc_ge_32:
  movq %rcx, %rax
  cmpl %esi, %edi
  cmovgel %edx, %eax
  ret
.size p191mc_ge_32, .-p191mc_ge_32
.globl p191mc_e_64
.type p191mc_e_64, @function
p191mc_e_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmoveq %rdx, %rax
  ret
.size p191mc_e_64, .-p191mc_e_64
.globl p191mc_ne_64
.type p191mc_ne_64, @function
p191mc_ne_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovneq %rdx, %rax
  ret
.size p191mc_ne_64, .-p191mc_ne_64
.globl p191mc_b_64
.type p191mc_b_64, @function
p191mc_b_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovbq %rdx, %rax
  ret
.size p191mc_b_64, .-p191mc_b_64
.globl p191mc_be_64
.type p191mc_be_64, @function
p191mc_be_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovbeq %rdx, %rax
  ret
.size p191mc_be_64, .-p191mc_be_64
.globl p191mc_a_64
.type p191mc_a_64, @function
p191mc_a_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovaq %rdx, %rax
  ret
.size p191mc_a_64, .-p191mc_a_64
.globl p191mc_ae_64
.type p191mc_ae_64, @function
p191mc_ae_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovaeq %rdx, %rax
  ret
.size p191mc_ae_64, .-p191mc_ae_64
.globl p191mc_l_64
.type p191mc_l_64, @function
p191mc_l_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovlq %rdx, %rax
  ret
.size p191mc_l_64, .-p191mc_l_64
.globl p191mc_le_64
.type p191mc_le_64, @function
p191mc_le_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovleq %rdx, %rax
  ret
.size p191mc_le_64, .-p191mc_le_64
.globl p191mc_g_64
.type p191mc_g_64, @function
p191mc_g_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovgq %rdx, %rax
  ret
.size p191mc_g_64, .-p191mc_g_64
.globl p191mc_ge_64
.type p191mc_ge_64, @function
p191mc_ge_64:
  movq %rcx, %rax
  cmpq %rsi, %rdi
  cmovgeq %rdx, %rax
  ret
.size p191mc_ge_64, .-p191mc_ge_64
.section .note.GNU-stack,"",@progbits
