# Observation-only SysV shim. The tested nested eight-argument computation is
# generated from p181k by Bend. Save our caller's six callee-saved registers,
# seed independent full-width values, then test them after the emitted call.
.text
.globl p181_preserve
.type p181_preserve, @function
p181_preserve:
  pushq %rbx
  pushq %rbp
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15
  # Entry rsp=8 mod16; six pushes and 40 bytes make the call site aligned.
  # Three spilled user arguments occupy offsets 0,8,16. The canary is separate.
  subq $40, %rsp
  movq $6, 0(%rsp)
  movq $7, 8(%rsp)
  movq $8, 16(%rsp)
  movabsq $0x6a5b4c3d2e1f9081, %rax
  movq %rax, 24(%rsp)
  movabsq $0x123456789abcdef0, %rbx
  movabsq $0x23456789abcdef01, %rbp
  movabsq $0x3456789abcdef012, %r12
  movabsq $0x456789abcdef0123, %r13
  movabsq $0x56789abcdef01234, %r14
  movabsq $0x6789abcdef012345, %r15
  # rdi already contains state. Hidden state plus eight users = nine arguments.
  movq $1, %rsi
  movq $2, %rdx
  movq $3, %rcx
  movq $4, %r8
  movq $5, %r9
  call p113d_FID_112_49_56_49_107_
  cmpq $213, %rax
  jne .Lp181_preserve_fail
  movabsq $0x123456789abcdef0, %r11
  cmpq %r11, %rbx
  jne .Lp181_preserve_fail
  movabsq $0x23456789abcdef01, %r11
  cmpq %r11, %rbp
  jne .Lp181_preserve_fail
  movabsq $0x3456789abcdef012, %r11
  cmpq %r11, %r12
  jne .Lp181_preserve_fail
  movabsq $0x456789abcdef0123, %r11
  cmpq %r11, %r13
  jne .Lp181_preserve_fail
  movabsq $0x56789abcdef01234, %r11
  cmpq %r11, %r14
  jne .Lp181_preserve_fail
  movabsq $0x6789abcdef012345, %r11
  cmpq %r11, %r15
  jne .Lp181_preserve_fail
  movabsq $0x6a5b4c3d2e1f9081, %r11
  cmpq %r11, 24(%rsp)
  jne .Lp181_preserve_fail
  movl $1, %eax
  jmp .Lp181_preserve_restore
.Lp181_preserve_fail:
  xorl %eax, %eax
.Lp181_preserve_restore:
  addq $40, %rsp
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbp
  popq %rbx
  ret
.size p181_preserve, .-p181_preserve
.section .note.GNU-stack,"",@progbits
