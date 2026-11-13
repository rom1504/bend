.text
.globl p191ac_bytes_0
.type p191ac_bytes_0, @function
p191ac_bytes_0:
  movq 0(%rax,%rcx,1), %rdx
.size p191ac_bytes_0, .-p191ac_bytes_0
.globl p191ac_bytes_1
.type p191ac_bytes_1, @function
p191ac_bytes_1:
  movq 0(%rax,%rcx,2), %rdx
.size p191ac_bytes_1, .-p191ac_bytes_1
.globl p191ac_bytes_2
.type p191ac_bytes_2, @function
p191ac_bytes_2:
  movq 0(%rax,%rcx,4), %rdx
.size p191ac_bytes_2, .-p191ac_bytes_2
.globl p191ac_bytes_3
.type p191ac_bytes_3, @function
p191ac_bytes_3:
  movq 0(%rax,%rcx,8), %rdx
.size p191ac_bytes_3, .-p191ac_bytes_3
.globl p191ac_bytes_4
.type p191ac_bytes_4, @function
p191ac_bytes_4:
  movq 0(%rsp,%rcx,8), %rdx
.size p191ac_bytes_4, .-p191ac_bytes_4
.globl p191ac_bytes_5
.type p191ac_bytes_5, @function
p191ac_bytes_5:
  movq 0(%rbp,%rcx,8), %rdx
.size p191ac_bytes_5, .-p191ac_bytes_5
.globl p191ac_bytes_6
.type p191ac_bytes_6, @function
p191ac_bytes_6:
  movq 0(%r13,%r12,8), %r15
.size p191ac_bytes_6, .-p191ac_bytes_6
.globl p191ac_bytes_7
.type p191ac_bytes_7, @function
p191ac_bytes_7:
  movq 0(%rax,%r12,4), %rax
.size p191ac_bytes_7, .-p191ac_bytes_7
.globl p191ac_bytes_8
.type p191ac_bytes_8, @function
p191ac_bytes_8:
  movl 0(%r12,%rcx,2), %eax
.size p191ac_bytes_8, .-p191ac_bytes_8
.globl p191ac_bytes_9
.type p191ac_bytes_9, @function
p191ac_bytes_9:
  movl 127(%rdi,%rsi,4), %r8d
.size p191ac_bytes_9, .-p191ac_bytes_9
.globl p191ac_bytes_10
.type p191ac_bytes_10, @function
p191ac_bytes_10:
  movl 128(%rdi,%rsi,4), %r8d
.size p191ac_bytes_10, .-p191ac_bytes_10
.globl p191ac_bytes_11
.type p191ac_bytes_11, @function
p191ac_bytes_11:
  movl -128(%rdi,%rsi,4), %r8d
.size p191ac_bytes_11, .-p191ac_bytes_11
.globl p191ac_bytes_12
.type p191ac_bytes_12, @function
p191ac_bytes_12:
  movl -129(%rdi,%rsi,4), %r8d
.size p191ac_bytes_12, .-p191ac_bytes_12
.globl p191ac_bytes_13
.type p191ac_bytes_13, @function
p191ac_bytes_13:
  movl -2147483648(%rdi,%rsi,4), %r8d
.size p191ac_bytes_13, .-p191ac_bytes_13
.globl p191ac_bytes_14
.type p191ac_bytes_14, @function
p191ac_bytes_14:
  movl 2147483647(%rdi,%rsi,4), %r8d
.size p191ac_bytes_14, .-p191ac_bytes_14
.globl p191ac_bytes_15
.type p191ac_bytes_15, @function
p191ac_bytes_15:
  movb %sil, 0(%rdi,%rcx,1)
.size p191ac_bytes_15, .-p191ac_bytes_15
.globl p191ac_bytes_16
.type p191ac_bytes_16, @function
p191ac_bytes_16:
  movb 0(%rax,%rcx,1), %dil
.size p191ac_bytes_16, .-p191ac_bytes_16
.globl p191ac_bytes_17
.type p191ac_bytes_17, @function
p191ac_bytes_17:
  movb %r15b, 8(%r12,%r13,2)
.size p191ac_bytes_17, .-p191ac_bytes_17
.globl p191ac_bytes_18
.type p191ac_bytes_18, @function
p191ac_bytes_18:
  movzbl 0(%r12,%r13,2), %r8d
.size p191ac_bytes_18, .-p191ac_bytes_18
.globl p191ac_bytes_19
.type p191ac_bytes_19, @function
p191ac_bytes_19:
  movd %xmm9, 0(%r12,%r13,4)
.size p191ac_bytes_19, .-p191ac_bytes_19
.globl p191ac_bytes_20
.type p191ac_bytes_20, @function
p191ac_bytes_20:
  addss 0(%r12,%r13,4), %xmm9
.size p191ac_bytes_20, .-p191ac_bytes_20
.globl p191ac_bytes_21
.type p191ac_bytes_21, @function
p191ac_bytes_21:
  leaq 0(%r13,%r12,8), %r10
.size p191ac_bytes_21, .-p191ac_bytes_21
.globl p191ac_bytes_22
.type p191ac_bytes_22, @function
p191ac_bytes_22:
  imulq -8(%r13,%r12,8), %r10
.size p191ac_bytes_22, .-p191ac_bytes_22
.globl p191ac_bytes_23
.type p191ac_bytes_23, @function
p191ac_bytes_23:
  addl 0(%rdi,%rsi,4), %eax
.size p191ac_bytes_23, .-p191ac_bytes_23
.globl p191ac_bytes_24
.type p191ac_bytes_24, @function
p191ac_bytes_24:
  movl $305419896, 128(%r12,%r13,4)
.size p191ac_bytes_24, .-p191ac_bytes_24
.globl p191ac_bytes_25
.type p191ac_bytes_25, @function
p191ac_bytes_25:
  setne 0(%r13,%r12,1)
.size p191ac_bytes_25, .-p191ac_bytes_25
.globl p191ac_bytes_26
.type p191ac_bytes_26, @function
p191ac_bytes_26:
  movq 0(%r12), %r9
.size p191ac_bytes_26, .-p191ac_bytes_26
.globl p191ac_load64
.type p191ac_load64, @function
p191ac_load64:
  movq -8(%rdi,%rsi,8), %rax
  ret
.size p191ac_load64, .-p191ac_load64
.globl p191ac_load32
.type p191ac_load32, @function
p191ac_load32:
  movl 4(%rdi,%rsi,4), %eax
  ret
.size p191ac_load32, .-p191ac_load32
.globl p191ac_store64
.type p191ac_store64, @function
p191ac_store64:
  movq %rdx, 0(%rdi,%rsi,8)
  ret
.size p191ac_store64, .-p191ac_store64
.globl p191ac_load8
.type p191ac_load8, @function
p191ac_load8:
  movzbl 0(%rdi,%rsi,1), %eax
  ret
.size p191ac_load8, .-p191ac_load8
.globl p191ac_load_r12
.type p191ac_load_r12, @function
p191ac_load_r12:
  pushq %r12
  movq %rsi, %r12
  movq 0(%rdi,%r12,8), %rax
  popq %r12
  ret
.size p191ac_load_r12, .-p191ac_load_r12
.section .note.GNU-stack,"",@progbits
