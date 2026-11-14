
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-baseline-build04/memory-dependence-dependent/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408b84 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
  408b84:	push   %rbp
  408b85:	mov    %rsp,%rbp
  408b88:	sub    $0x910,%rsp
  408b8f:	mov    %r12,-0x10(%rbp)
  408b93:	mov    %rbx,-0x8(%rbp)
  408b97:	mov    %rdi,%rax
  408b9a:	mov    %rax,%r12
  408b9d:	mov    %rsi,%rax
  408ba0:	mov    %rax,%rdi
  408ba3:	mov    %rdx,%rax
  408ba6:	mov    %rax,%rdx
  408ba9:	cmp    $0x0,%rdi
  408bb0:	jne    408bc6 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x42>
  408bb6:	mov    %rdx,%rax
  408bb9:	mov    -0x10(%rbp),%r12
  408bbd:	mov    -0x8(%rbp),%rbx
  408bc1:	mov    %rbp,%rsp
  408bc4:	pop    %rbp
  408bc5:	retq   
  408bc6:	mov    %rdi,%rbx
  408bc9:	sub    $0x1,%rbx
  408bd0:	mov    %r12,%r10
  408bd3:	mov    %r10,0x10(%rsp)
  408bd8:	mov    %rdx,%r10
  408bdb:	mov    %r10,0x18(%rsp)
  408be0:	mov    0x10(%rsp),%rdi
  408be5:	mov    0x18(%rsp),%rsi
  408bea:	xor    %eax,%eax
  408bec:	callq  40887c <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>
  408bf1:	mov    %rax,%rdx
  408bf4:	mov    %rbx,%rdi
  408bf7:	jmpq   408ba9 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x25>

Disassembly of section .fini:
