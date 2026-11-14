
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/memory-dependence-sequential/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408b52 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_>:
  408b52:	push   %rbp
  408b53:	mov    %rsp,%rbp
  408b56:	sub    $0x910,%rsp
  408b5d:	mov    %r12,-0x10(%rbp)
  408b61:	mov    %rbx,-0x8(%rbp)
  408b65:	mov    %rdi,%rax
  408b68:	mov    %rax,%r12
  408b6b:	mov    %rsi,%rax
  408b6e:	mov    %rax,%rdi
  408b71:	mov    %rdx,%rax
  408b74:	mov    %rax,%rdx
  408b77:	cmp    $0x0,%rdi
  408b7e:	jne    408b94 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x42>
  408b84:	mov    %rdx,%rax
  408b87:	mov    -0x10(%rbp),%r12
  408b8b:	mov    -0x8(%rbp),%rbx
  408b8f:	mov    %rbp,%rsp
  408b92:	pop    %rbp
  408b93:	retq   
  408b94:	mov    %rdi,%rbx
  408b97:	sub    $0x1,%rbx
  408b9e:	mov    %r12,%r10
  408ba1:	mov    %r10,0x10(%rsp)
  408ba6:	mov    %rdx,%r10
  408ba9:	mov    %r10,0x18(%rsp)
  408bae:	mov    0x10(%rsp),%rdi
  408bb3:	mov    0x18(%rsp),%rsi
  408bb8:	xor    %eax,%eax
  408bba:	callq  40884a <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>
  408bbf:	mov    %rax,%rdx
  408bc2:	mov    %rbx,%rdi
  408bc5:	jmpq   408b77 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_108_111_111_112_+0x25>

Disassembly of section .fini:
