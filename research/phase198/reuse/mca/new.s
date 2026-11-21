.text
# LLVM-MCA-BEGIN descend
  leaq 8(%r12,%rdx,8), %rdi
  leaq 8(%r12,%rcx,8), %rsi
  movq %rdi, 64(%rsp,%r13,1)
  movq %rsi, 72(%rsp,%r13,1)
  leaq 0(%r12,%rdx,8), %rdi
  leaq 0(%r12,%rcx,8), %rsi
  movq %rdi, 80(%rsp,%r13,1)
  movq %rsi, 88(%rsp,%r13,1)
  addq $32, %r13
# LLVM-MCA-END descend
