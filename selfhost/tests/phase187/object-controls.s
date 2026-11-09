.text
.balign 16
.globl p187_widths
.type p187_widths, @function
p187_widths:
  movq %rsi, %r8
  addq %rdx, %r8
  movq %r8, 0(%rdi)
  movq %rsi, %r9
  subq %rdx, %r9
  movq %r9, 8(%rdi)
  movq %rsi, %r10
  imulq %rdx, %r10
  movq %r10, 16(%rdi)
  movl %esi, %r11d
  addl %edx, %r11d
  movq %r11, 24(%rdi)
  movq %rsi, %rax
  xorq %rdx, %rax
  movq %rax, 32(%rdi)
  movq %rsi, %rax
  andq %rdx, %rax
  movq %rax, 40(%rdi)
  xorl %eax, %eax
  ret
.size p187_widths, .-p187_widths
.text
.balign 16
.globl p187_compare
.type p187_compare, @function
p187_compare:
  cmpq %rdx, %rsi
  setb %r8b
  setl %r9b
  sete %r10b
  movzbl %r8b, %r8d
  movzbl %r9b, %r9d
  movzbl %r10b, %r10d
  movq %r8, 0(%rdi)
  movq %r9, 8(%rdi)
  movq %r10, 16(%rdi)
  cmpl %edx, %esi
  setb %r8b
  setl %r9b
  sete %r10b
  movzbl %r8b, %r8d
  movzbl %r9b, %r9d
  movzbl %r10b, %r10d
  movq %r8, 24(%rdi)
  movq %r9, 32(%rdi)
  movq %r10, 40(%rdi)
  xorl %eax, %eax
  ret
.size p187_compare, .-p187_compare
.text
.balign 16
.globl p187_shift64
.type p187_shift64, @function
p187_shift64:
  movq %rdi, %rax
  movl %esi, %ecx
  shlq %cl, %rax
  ret
.size p187_shift64, .-p187_shift64
.text
.balign 16
.globl p187_shift32
.type p187_shift32, @function
p187_shift32:
  movl %edi, %eax
  movl %esi, %ecx
  shrl %cl, %eax
  ret
.size p187_shift32, .-p187_shift32
.text
.balign 16
.globl p187_branch
.type p187_branch, @function
p187_branch:
  xorl %eax, %eax
  jmp .Lp187_test
  movq $99, %rax
.Lp187_test:
  cmpq $0, %rdi
  je .Lp187_done
.Lp187_loop:
  addq %rdi, %rax
  subq $1, %rdi
  jne .Lp187_loop
.Lp187_done:
  ret
.size p187_branch, .-p187_branch
.text
.balign 16
.globl p187_memory
.type p187_memory, @function
p187_memory:
  pushq %rbp
  pushq %r12
  movq %rdi, %rbp
  movq %rdi, %r12
  movq $18364758544493064720, %rax
  movq %rax, -8(%rbp)
  movl $2864434397, 128(%r12)
  movl 128(%r12), %eax
  leaq 16(%r12), %r10
  movq %rax, 0(%r10)
  popq %r12
  popq %rbp
  ret
.size p187_memory, .-p187_memory
.text
.balign 16
.globl p187_call
.type p187_call, @function
p187_call:
  pushq %rbp
  movq %rsp, %rbp
  subq $16, %rsp
  movq %rdi, -8(%rbp)
  call p187_helper
  addq -8(%rbp), %rax
  movq %rbp, %rsp
  popq %rbp
  ret
.size p187_call, .-p187_call
.text
.balign 16
.globl p187_data
.type p187_data, @function
p187_data:
  leaq p187_pointer(%rip), %rax
  movq 0(%rax), %rax
  movq 0(%rax), %rax
  ret
.size p187_data, .-p187_data
.text
.balign 16
.globl p187_fp26
.type p187_fp26, @function
p187_fp26:
  movd %edi, %xmm2
  movd %esi, %xmm15
  addss %xmm15, %xmm2
  movd %xmm2, %eax
  ret
.size p187_fp26, .-p187_fp26
.text
.balign 16
.globl p187_fp27
.type p187_fp27, @function
p187_fp27:
  movd %edi, %xmm2
  movd %esi, %xmm15
  subss %xmm15, %xmm2
  movd %xmm2, %eax
  ret
.size p187_fp27, .-p187_fp27
.text
.balign 16
.globl p187_fp28
.type p187_fp28, @function
p187_fp28:
  movd %edi, %xmm2
  movd %esi, %xmm15
  mulss %xmm15, %xmm2
  movd %xmm2, %eax
  ret
.size p187_fp28, .-p187_fp28
.text
.balign 16
.globl p187_fp29
.type p187_fp29, @function
p187_fp29:
  movd %edi, %xmm2
  movd %esi, %xmm15
  divss %xmm15, %xmm2
  movd %xmm2, %eax
  ret
.size p187_fp29, .-p187_fp29
.text
.balign 16
.globl p187_fp30
.type p187_fp30, @function
p187_fp30:
  movd %edi, %xmm2
  movd %esi, %xmm15
  ucomiss %xmm15, %xmm2
  sete %r10b
  setnp %r11b
  andb %r11b, %r10b
  movzbl %r10b, %eax
  ret
.size p187_fp30, .-p187_fp30
.text
.balign 16
.globl p187_fp31
.type p187_fp31, @function
p187_fp31:
  movd %edi, %xmm2
  movd %esi, %xmm15
  ucomiss %xmm15, %xmm2
  setne %r10b
  setp %r11b
  orb %r11b, %r10b
  movzbl %r10b, %eax
  ret
.size p187_fp31, .-p187_fp31
.text
.balign 16
.globl p187_fp32
.type p187_fp32, @function
p187_fp32:
  movd %edi, %xmm2
  movd %esi, %xmm15
  ucomiss %xmm15, %xmm2
  setb %r10b
  setnp %r11b
  andb %r11b, %r10b
  movzbl %r10b, %eax
  ret
.size p187_fp32, .-p187_fp32
.text
.balign 16
.globl p187_fp33
.type p187_fp33, @function
p187_fp33:
  movd %edi, %xmm2
  movd %esi, %xmm15
  ucomiss %xmm15, %xmm2
  setbe %r10b
  setnp %r11b
  andb %r11b, %r10b
  movzbl %r10b, %eax
  ret
.size p187_fp33, .-p187_fp33
.text
.balign 16
.globl p187_fp34
.type p187_fp34, @function
p187_fp34:
  movd %edi, %xmm2
  movd %esi, %xmm15
  ucomiss %xmm15, %xmm2
  seta %r10b
  movzbl %r10b, %eax
  ret
.size p187_fp34, .-p187_fp34
.text
.balign 16
.globl p187_fp35
.type p187_fp35, @function
p187_fp35:
  movd %edi, %xmm2
  movd %esi, %xmm15
  ucomiss %xmm15, %xmm2
  setae %r10b
  movzbl %r10b, %eax
  ret
.size p187_fp35, .-p187_fp35
.text
.balign 16
.globl p187_convert
.type p187_convert, @function
p187_convert:
  movl %edi, %r10d
  pxor %xmm0, %xmm0
  cvtsi2ssq %r10, %xmm0
  movd %xmm0, %eax
  ret
.size p187_convert, .-p187_convert
.data
.balign 8
.globl p187_words
.type p187_words, @object
p187_words:
.quad 4294967297
.quad 9223372036854775808
.size p187_words, .-p187_words
.balign 8
.globl p187_pointer
.type p187_pointer, @object
p187_pointer:
.quad p187_words+8
.size p187_pointer, .-p187_pointer
.globl p187_external_pointer
.type p187_external_pointer, @object
p187_external_pointer:
.quad p187_external+8
.size p187_external_pointer, .-p187_external_pointer
.globl p187_function_pointer
.type p187_function_pointer, @object
p187_function_pointer:
.quad p187_call+0
.size p187_function_pointer, .-p187_function_pointer
.balign 8
.globl p187_bytes
.type p187_bytes, @object
p187_bytes:
.byte 17
.byte 34
.long 2864434397
.zero 10
.size p187_bytes, .-p187_bytes
.section .note.GNU-stack,"",@progbits
