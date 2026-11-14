
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-baseline-build04/memory-dependence-sequential/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408bac <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
  408bac:	push   %rbp
  408bad:	mov    %rsp,%rbp
  408bb0:	sub    $0x910,%rsp
  408bb7:	mov    %r12,-0x10(%rbp)
  408bbb:	mov    %rbx,-0x8(%rbp)
  408bbf:	mov    %rdi,%rax
  408bc2:	mov    %rax,%r12
  408bc5:	mov    %rsi,%rax
  408bc8:	mov    %rax,%rdi
  408bcb:	mov    %rdx,%rax
  408bce:	mov    %rax,%rdx
  408bd1:	cmp    $0x0,%rdi
  408bd8:	jne    408bee <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x42>
  408bde:	mov    %rdx,%rax
  408be1:	mov    -0x10(%rbp),%r12
  408be5:	mov    -0x8(%rbp),%rbx
  408be9:	mov    %rbp,%rsp
  408bec:	pop    %rbp
  408bed:	retq   
  408bee:	mov    %rdi,%rbx
  408bf1:	sub    $0x1,%rbx
  408bf8:	mov    %r12,%r10
  408bfb:	mov    %r10,0x10(%rsp)
  408c00:	mov    %rdx,%r10
  408c03:	mov    %r10,0x18(%rsp)
  408c08:	mov    0x10(%rsp),%rdi
  408c0d:	mov    0x18(%rsp),%rsi
  408c12:	xor    %eax,%eax
  408c14:	callq  4088a4 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>
  408c19:	mov    %rax,%rdx
  408c1c:	mov    %rbx,%rdi
  408c1f:	jmpq   408bd1 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x25>

Disassembly of section .fini:
