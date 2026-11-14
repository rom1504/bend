
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/memory-dependence-dependent/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408b23 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
  408b23:	push   %rbp
  408b24:	mov    %rsp,%rbp
  408b27:	sub    $0x910,%rsp
  408b2e:	mov    %r12,-0x10(%rbp)
  408b32:	mov    %rbx,-0x8(%rbp)
  408b36:	mov    %rdi,%rax
  408b39:	mov    %rax,%r12
  408b3c:	mov    %rsi,%rax
  408b3f:	mov    %rax,%rdi
  408b42:	mov    %rdx,%rax
  408b45:	mov    %rax,%rdx
  408b48:	cmp    $0x0,%rdi
  408b4f:	jne    408b65 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x42>
  408b55:	mov    %rdx,%rax
  408b58:	mov    -0x10(%rbp),%r12
  408b5c:	mov    -0x8(%rbp),%rbx
  408b60:	mov    %rbp,%rsp
  408b63:	pop    %rbp
  408b64:	retq   
  408b65:	mov    %rdi,%rbx
  408b68:	sub    $0x1,%rbx
  408b6f:	mov    %r12,%r10
  408b72:	mov    %r10,0x10(%rsp)
  408b77:	mov    %rdx,%r10
  408b7a:	mov    %r10,0x18(%rsp)
  408b7f:	mov    0x10(%rsp),%rdi
  408b84:	mov    0x18(%rsp),%rsi
  408b89:	xor    %eax,%eax
  408b8b:	callq  40881b <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>
  408b90:	mov    %rax,%rdx
  408b93:	mov    %rbx,%rdi
  408b96:	jmpq   408b48 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x25>

Disassembly of section .fini:
