
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p126-observer32-coverage-record-aggregation-256-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407f10 <p113d_FID_36_100_105_114_101_99_116_46_77_97_112_46_98_105_116_>:
  407f10:	f3 0f 1e fa          	endbr64 
  407f14:	55                   	push   %rbp
  407f15:	48 89 e5             	mov    %rsp,%rbp
  407f18:	48 81 ec 50 08 00 00 	sub    $0x850,%rsp
  407f1f:	53                   	push   %rbx
  407f20:	41 54                	push   %r12
  407f22:	48 87 d6             	xchg   %rdx,%rsi
  407f25:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
  407f29:	49 89 d4             	mov    %rdx,%r12
  407f2c:	ba 21 00 00 00       	mov    $0x21,%edx
  407f31:	48 89 fb             	mov    %rdi,%rbx
  407f34:	e8 b7 d5 02 00       	callq  4354f0 <p126_rt_nat_divmod>
  407f39:	4c 89 e2             	mov    %r12,%rdx
  407f3c:	48 89 df             	mov    %rbx,%rdi
  407f3f:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  407f43:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  407f47:	48 8d 75 c0          	lea    -0x40(%rbp),%rsi
  407f4b:	48 89 fb             	mov    %rdi,%rbx
  407f4e:	e8 7d ff ff ff       	callq  407ed0 <p113d_FID_36_112_114_111_100_117_99_116_46_77_97_112_46_98_105_116_46_97_116_>
  407f53:	48 89 df             	mov    %rbx,%rdi
  407f56:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  407f5a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  407f5e:	48 89 8d b0 f7 ff ff 	mov    %rcx,-0x850(%rbp)
  407f65:	48 89 85 b8 f7 ff ff 	mov    %rax,-0x848(%rbp)
  407f6c:	48 8d 95 b0 f7 ff ff 	lea    -0x850(%rbp),%rdx
  407f73:	be 08 00 00 00       	mov    $0x8,%esi
  407f78:	e8 13 ce 02 00       	callq  434d90 <p125_rt_ctor2>
  407f7d:	41 5c                	pop    %r12
  407f7f:	5b                   	pop    %rbx
  407f80:	c9                   	leaveq 
  407f81:	c3                   	retq   

Disassembly of section .fini:
