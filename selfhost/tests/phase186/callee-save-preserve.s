# Observation-only SysV shim, adapted from phase181/abi-preserve.s.
# rdi holds a no-argument function pointer. The target returns 77; every one of
# the caller's six callee-saved registers must survive, including unselected
# homes and rbp. All tested prologues/epilogues are emitted by Bend.
.text
.globl p186_sv_preserve
.type p186_sv_preserve, @function
p186_sv_preserve:
  pushq %rbx
  pushq %rbp
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15
  # Entry rsp=8 mod16; six pushes then 24 bytes align the indirect call.
  # These caller-owned words remain above the target's return address/frame.
  subq $24, %rsp
  movq %rdi, 16(%rsp)
  movq %rsp, 8(%rsp)
  movabsq $0x6a5b4c3d2e1f9081, %rax
  movq %rax, 0(%rsp)
  movabsq $0x123456789abcdef0, %rbx
  movabsq $0x23456789abcdef01, %rbp
  movabsq $0x3456789abcdef012, %r12
  movabsq $0x456789abcdef0123, %r13
  movabsq $0x56789abcdef01234, %r14
  movabsq $0x6789abcdef012345, %r15
  call *16(%rsp)
  cmpq $77, %rax
  jne .Lp186_sv_fail
  movabsq $0x123456789abcdef0, %r11
  cmpq %r11, %rbx
  jne .Lp186_sv_fail
  movabsq $0x23456789abcdef01, %r11
  cmpq %r11, %rbp
  jne .Lp186_sv_fail
  movabsq $0x3456789abcdef012, %r11
  cmpq %r11, %r12
  jne .Lp186_sv_fail
  movabsq $0x456789abcdef0123, %r11
  cmpq %r11, %r13
  jne .Lp186_sv_fail
  movabsq $0x56789abcdef01234, %r11
  cmpq %r11, %r14
  jne .Lp186_sv_fail
  movabsq $0x6789abcdef012345, %r11
  cmpq %r11, %r15
  jne .Lp186_sv_fail
  movabsq $0x6a5b4c3d2e1f9081, %r11
  cmpq %r11, 0(%rsp)
  jne .Lp186_sv_fail
  cmpq %rsp, 8(%rsp)
  jne .Lp186_sv_fail
  movl $1, %eax
  jmp .Lp186_sv_restore
.Lp186_sv_fail:
  xorl %eax, %eax
.Lp186_sv_restore:
  addq $24, %rsp
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbp
  popq %rbx
  ret
.size p186_sv_preserve, .-p186_sv_preserve
.section .note.GNU-stack,"",@progbits
