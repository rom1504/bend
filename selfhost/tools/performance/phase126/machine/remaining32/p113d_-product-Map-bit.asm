
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer32-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407f90 <p113d_FID_36_112_114_111_100_117_99_116_46_77_97_112_46_98_105_116_>:
  407f90:	f3 0f 1e fa          	endbr64 
  407f94:	55                   	push   %rbp
  407f95:	48 89 e5             	mov    %rsp,%rbp
  407f98:	48 83 ec 58          	sub    $0x58,%rsp
  407f9c:	53                   	push   %rbx
  407f9d:	41 54                	push   %r12
  407f9f:	41 55                	push   %r13
  407fa1:	49 89 f4             	mov    %rsi,%r12
  407fa4:	48 89 ce             	mov    %rcx,%rsi
  407fa7:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
  407fab:	49 89 d5             	mov    %rdx,%r13
  407fae:	ba 21 00 00 00       	mov    $0x21,%edx
  407fb3:	48 89 fb             	mov    %rdi,%rbx
  407fb6:	e8 35 d5 02 00       	callq  4354f0 <p126_rt_nat_divmod>
  407fbb:	4c 89 ea             	mov    %r13,%rdx
  407fbe:	4c 89 e6             	mov    %r12,%rsi
  407fc1:	48 89 df             	mov    %rbx,%rdi
  407fc4:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  407fc8:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  407fcc:	48 89 f3             	mov    %rsi,%rbx
  407fcf:	48 8d 75 c0          	lea    -0x40(%rbp),%rsi
  407fd3:	e8 f8 fe ff ff       	callq  407ed0 <p113d_FID_36_112_114_111_100_117_99_116_46_77_97_112_46_98_105_116_46_97_116_>
  407fd8:	48 89 de             	mov    %rbx,%rsi
  407fdb:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  407fdf:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  407fe3:	48 89 0e             	mov    %rcx,(%rsi)
  407fe6:	48 89 46 08          	mov    %rax,0x8(%rsi)
  407fea:	b8 00 00 00 00       	mov    $0x0,%eax
  407fef:	41 5d                	pop    %r13
  407ff1:	41 5c                	pop    %r12
  407ff3:	5b                   	pop    %rbx
  407ff4:	c9                   	leaveq 
  407ff5:	c3                   	retq   

Disassembly of section .fini:
