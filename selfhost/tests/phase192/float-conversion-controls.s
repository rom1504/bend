# Independently written branch-based semantic baseline. No candidate masking,
# allocation, typed encoder or XMM planner is used. The C observer runs unchanged.
.text
.macro f32word name, pointer
.globl \name
.type \name,@function
\name:
.if \pointer
  movd (%rdi), %xmm0
.else
  movd %edi, %xmm0
.endif
  pxor %xmm1, %xmm1
  comiss %xmm1, %xmm0
  jb 1f
  movl $0x4f800000, %r10d
  movd %r10d, %xmm1
  comiss %xmm0, %xmm1
  jbe 1f
  cvttss2siq %xmm0, %rax
  movl %eax, %eax
  ret
1:
  xorl %eax, %eax
  ret
.size \name, .-\name
.endm
.macro wordf32 name, pointer
.globl \name
.type \name,@function
\name:
.if \pointer
  movl (%rdi), %eax
.else
  movl %edi, %eax
.endif
  pxor %xmm0, %xmm0
  cvtsi2ssq %rax, %xmm0
  movd %xmm0, %eax
  ret
.size \name, .-\name
.endm
f32word p192fc_f58, 0
f32word p192fc_x58, 0
f32word p192fc_b58, 1
f32word p192fc_a58, 1
wordf32 p192fc_u23, 0
wordf32 p192fc_x23, 0
wordf32 p192fc_b23, 1
wordf32 p192fc_a23, 1
.section .note.GNU-stack,"",@progbits
