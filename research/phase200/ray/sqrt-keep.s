.text
.globl p200_rt_f32_sqrt_keep
.type p200_rt_f32_sqrt_keep,@function
p200_rt_f32_sqrt_keep:
  pxor %xmm1,%xmm1
  ucomiss %xmm0,%xmm1
  ja .Lnegative
  sqrtss %xmm0,%xmm0
  ret
.Lnegative:
  push %rax
  push %rcx
  push %rdx
  push %rsi
  push %rdi
  push %r8
  push %r9
  sub $224,%rsp
  movdqu %xmm2,0(%rsp)
  movdqu %xmm3,16(%rsp)
  movdqu %xmm4,32(%rsp)
  movdqu %xmm5,48(%rsp)
  movdqu %xmm6,64(%rsp)
  movdqu %xmm7,80(%rsp)
  movdqu %xmm8,96(%rsp)
  movdqu %xmm9,112(%rsp)
  movdqu %xmm10,128(%rsp)
  movdqu %xmm11,144(%rsp)
  movdqu %xmm12,160(%rsp)
  movdqu %xmm13,176(%rsp)
  movdqu %xmm14,192(%rsp)
  movdqu %xmm15,208(%rsp)
  call sqrtf@PLT
  movdqu 0(%rsp),%xmm2
  movdqu 16(%rsp),%xmm3
  movdqu 32(%rsp),%xmm4
  movdqu 48(%rsp),%xmm5
  movdqu 64(%rsp),%xmm6
  movdqu 80(%rsp),%xmm7
  movdqu 96(%rsp),%xmm8
  movdqu 112(%rsp),%xmm9
  movdqu 128(%rsp),%xmm10
  movdqu 144(%rsp),%xmm11
  movdqu 160(%rsp),%xmm12
  movdqu 176(%rsp),%xmm13
  movdqu 192(%rsp),%xmm14
  movdqu 208(%rsp),%xmm15
  add $224,%rsp
  pop %r9
  pop %r8
  pop %rdi
  pop %rsi
  pop %rdx
  pop %rcx
  pop %rax
  ret
.size p200_rt_f32_sqrt_keep,.-p200_rt_f32_sqrt_keep
.section .note.GNU-stack,"",@progbits
