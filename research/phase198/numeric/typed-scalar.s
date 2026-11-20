.text
.globl p113d_FID_36_100_105_114_101_99_116_46_109_105_116_
.type p113d_FID_36_100_105_114_101_99_116_46_109_105_116_, @function
p113d_FID_36_100_105_114_101_99_116_46_109_105_116_:
  pushq %rbx
  pushq %r12
  pushq %r13
  movl 32(%rsp), %ebx
  movl 40(%rsp), %edi
  testq %rsi, %rsi
  jz .Lp198_done
.Lp198_loop:
  movl %r8d, %r10d
  imull %r8d, %r10d
  sarl $8, %r10d
  movl %r9d, %r11d
  imull %r9d, %r11d
  sarl $8, %r11d
  movl %r10d, %eax
  addl %r11d, %eax
  cmpl $1024, %eax
  seta %r13b
  movzbl %r13b, %r13d
  orl %r13d, %ebx
  movl %r10d, %r12d
  subl %r11d, %r12d
  addl %edx, %r12d
  movl %r8d, %eax
  imull %r9d, %eax
  addl %eax, %eax
  sarl $8, %eax
  addl %ecx, %eax
  testl %ebx, %ebx
  cmovzl %r12d, %r8d
  cmovzl %eax, %r9d
  setz %r13b
  movzbl %r13b, %r13d
  addl %r13d, %edi
  subq $1, %rsi
  jne .Lp198_loop
.Lp198_done:
  movl %edi, %eax
  popq %r13
  popq %r12
  popq %rbx
  ret
.size p113d_FID_36_100_105_114_101_99_116_46_109_105_116_, .-p113d_FID_36_100_105_114_101_99_116_46_109_105_116_
.section .note.GNU-stack,"",@progbits
