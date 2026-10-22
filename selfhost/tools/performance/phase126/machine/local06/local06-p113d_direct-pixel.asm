0000000000408800 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_>:
  408800:	f3 0f 1e fa          	endbr64 
  408804:	55                   	push   %rbp
  408805:	48 89 e5             	mov    %rsp,%rbp
  408808:	48 81 ec 28 09 00 00 	sub    $0x928,%rsp
  40880f:	53                   	push   %rbx
  408810:	41 54                	push   %r12
  408812:	41 55                	push   %r13
  408814:	41 56                	push   %r14
  408816:	41 57                	push   %r15
  408818:	4d 89 c5             	mov    %r8,%r13
  40881b:	49 89 cc             	mov    %rcx,%r12
  40881e:	48 89 fb             	mov    %rdi,%rbx
  408821:	48 89 b5 e0 f6 ff ff 	mov    %rsi,-0x920(%rbp)
  408828:	89 f0                	mov    %esi,%eax
  40882a:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  40882f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408834:	41 89 c6             	mov    %eax,%r14d
  408837:	48 89 95 e0 f6 ff ff 	mov    %rdx,-0x920(%rbp)
  40883e:	89 d0                	mov    %edx,%eax
  408840:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  408845:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40884a:	41 89 c7             	mov    %eax,%r15d
  40884d:	4c 89 b5 e0 f6 ff ff 	mov    %r14,-0x920(%rbp)
  408854:	48 c7 85 e8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x918(%rbp)
  40885f:	66 49 0f 6e c6       	movq   %r14,%xmm0
  408864:	f3 0f 11 45 d8       	movss  %xmm0,-0x28(%rbp)
  408869:	f3 0f 58 05 c7 87 02 00 	addss  0x287c7(%rip),%xmm0        # 431038 <_IO_stdin_used+0x38>
  408871:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408876:	89 c1                	mov    %eax,%ecx
  408878:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  40887c:	48 89 8d e0 f6 ff ff 	mov    %rcx,-0x920(%rbp)
  408883:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  40888a:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40888f:	66 49 0f 6e d4       	movq   %r12,%xmm2
  408894:	f3 0f 11 55 8c       	movss  %xmm2,-0x74(%rbp)
  408899:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  40889d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4088a2:	89 c0                	mov    %eax,%eax
  4088a4:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  4088a8:	48 89 85 e0 f6 ff ff 	mov    %rax,-0x920(%rbp)
  4088af:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  4088b6:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4088bb:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  4088bf:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4088c4:	89 c1                	mov    %eax,%ecx
  4088c6:	4c 89 bd e0 f6 ff ff 	mov    %r15,-0x920(%rbp)
  4088cd:	48 c7 85 e8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x918(%rbp)
  4088d8:	66 49 0f 6e df       	movq   %r15,%xmm3
  4088dd:	f3 0f 11 5d a0       	movss  %xmm3,-0x60(%rbp)
  4088e2:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  4088e6:	f3 0f 58 05 4a 87 02 00 	addss  0x2874a(%rip),%xmm0        # 431038 <_IO_stdin_used+0x38>
  4088ee:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4088f3:	89 c2                	mov    %eax,%edx
  4088f5:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  4088f9:	4c 89 ad e0 f6 ff ff 	mov    %r13,-0x920(%rbp)
  408900:	48 89 95 e8 f6 ff ff 	mov    %rdx,-0x918(%rbp)
  408907:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40890c:	f3 0f 11 4d a4       	movss  %xmm1,-0x5c(%rbp)
  408911:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  408916:	0f 57 05 f3 86 02 00 	xorps  0x286f3(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  40891d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408921:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408926:	89 c0                	mov    %eax,%eax
  408928:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  40892c:	48 89 85 e0 f6 ff ff 	mov    %rax,-0x920(%rbp)
  408933:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  40893a:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40893f:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  408943:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408948:	89 c0                	mov    %eax,%eax
  40894a:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  40894f:	f3 0f 11 55 88       	movss  %xmm2,-0x78(%rbp)
  408954:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  408958:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40895c:	f3 0f 11 45 a8       	movss  %xmm0,-0x58(%rbp)
  408961:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408966:	f3 0f 11 4d ac       	movss  %xmm1,-0x54(%rbp)
  40896b:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  40896f:	f3 0f 11 4d dc       	movss  %xmm1,-0x24(%rbp)
  408974:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408978:	f3 0f 58 05 a0 86 02 00 	addss  0x286a0(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408980:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408984:	e8 37 9b ff ff       	callq  4024c0 <sqrt@plt>
  408989:	4d 89 f1             	mov    %r14,%r9
  40898c:	4d 89 e8             	mov    %r13,%r8
  40898f:	4c 89 e1             	mov    %r12,%rcx
  408992:	48 89 df             	mov    %rbx,%rdi
  408995:	f3 0f 10 4d ac       	movss  -0x54(%rbp),%xmm1
  40899a:	f3 0f 10 55 88       	movss  -0x78(%rbp),%xmm2
  40899f:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  4089a3:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  4089a7:	66 48 0f 7e d0       	movq   %xmm2,%rax
  4089ac:	89 c6                	mov    %eax,%esi
  4089ae:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  4089b2:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  4089b6:	66 48 0f 7e c8       	movq   %xmm1,%rax
  4089bb:	41 89 c2             	mov    %eax,%r10d
  4089be:	4c 89 55 e8          	mov    %r10,-0x18(%rbp)
  4089c2:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  4089c7:	f3 0f 10 05 51 86 02 00 	movss  0x28651(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  4089cf:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  4089d4:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4089d9:	41 89 c3             	mov    %eax,%r11d
  4089dc:	4c 89 5d f0          	mov    %r11,-0x10(%rbp)
  4089e0:	48 83 ec 40          	sub    $0x40,%rsp
  4089e4:	48 89 e0             	mov    %rsp,%rax
  4089e7:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  4089ef:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  4089f7:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  4089ff:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  408a07:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  408a0f:	4c 89 58 10          	mov    %r11,0x10(%rax)
  408a13:	4c 89 50 08          	mov    %r10,0x8(%rax)
  408a17:	48 89 30             	mov    %rsi,(%rax)
  408a1a:	4d 89 ce             	mov    %r9,%r14
  408a1d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408a23:	4d 89 c5             	mov    %r8,%r13
  408a26:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408a2c:	49 89 cc             	mov    %rcx,%r12
  408a2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  408a34:	ba 09 00 00 00       	mov    $0x9,%edx
  408a39:	48 8d b5 e0 fe ff ff 	lea    -0x120(%rbp),%rsi
  408a40:	48 89 fb             	mov    %rdi,%rbx
  408a43:	e8 08 dc ff ff       	callq  406650 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408a48:	4d 89 f1             	mov    %r14,%r9
  408a4b:	4d 89 e8             	mov    %r13,%r8
  408a4e:	4c 89 e1             	mov    %r12,%rcx
  408a51:	48 89 df             	mov    %rbx,%rdi
  408a54:	4c 8b 5d f0          	mov    -0x10(%rbp),%r11
  408a58:	4c 8b 55 e8          	mov    -0x18(%rbp),%r10
  408a5c:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  408a60:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  408a64:	48 8b 95 e0 fe ff ff 	mov    -0x120(%rbp),%rdx
  408a6b:	49 89 cc             	mov    %rcx,%r12
  408a6e:	48 8b 8d e8 fe ff ff 	mov    -0x118(%rbp),%rcx
  408a75:	4d 89 c5             	mov    %r8,%r13
  408a78:	4c 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%r8
  408a7f:	48 83 ec 40          	sub    $0x40,%rsp
  408a83:	48 89 e0             	mov    %rsp,%rax
  408a86:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  408a8e:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  408a96:	4c 89 58 20          	mov    %r11,0x20(%rax)
  408a9a:	4c 89 50 18          	mov    %r10,0x18(%rax)
  408a9e:	48 89 70 10          	mov    %rsi,0x10(%rax)
  408aa2:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  408aaa:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  408ab1:	4d 89 ce             	mov    %r9,%r14
  408ab4:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408aba:	be 04 00 00 00       	mov    $0x4,%esi
  408abf:	48 89 fb             	mov    %rdi,%rbx
  408ac2:	e8 d9 e7 ff ff       	callq  4072a0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  408ac7:	4c 89 e1             	mov    %r12,%rcx
  408aca:	48 89 df             	mov    %rbx,%rdi
  408acd:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  408ad4:	49 89 cc             	mov    %rcx,%r12
  408ad7:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  408adb:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  408adf:	f3 0f 10 4d dc       	movss  -0x24(%rbp),%xmm1
  408ae4:	f3 0f 10 55 8c       	movss  -0x74(%rbp),%xmm2
  408ae9:	f3 0f 10 45 d8       	movss  -0x28(%rbp),%xmm0
  408aee:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  408af2:	4c 89 b5 e0 f6 ff ff 	mov    %r14,-0x920(%rbp)
  408af9:	48 c7 85 e8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x918(%rbp)
  408b04:	f3 0f 58 05 30 85 02 00 	addss  0x28530(%rip),%xmm0        # 43103c <_IO_stdin_used+0x3c>
  408b0c:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408b11:	48 89 fb             	mov    %rdi,%rbx
  408b14:	89 c7                	mov    %eax,%edi
  408b16:	48 89 bd 38 ff ff ff 	mov    %rdi,-0xc8(%rbp)
  408b1d:	48 89 bd e0 f6 ff ff 	mov    %rdi,-0x920(%rbp)
  408b24:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  408b2b:	66 48 0f 6e c7       	movq   %rdi,%xmm0
  408b30:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  408b34:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408b39:	89 c6                	mov    %eax,%esi
  408b3b:	48 89 b5 40 ff ff ff 	mov    %rsi,-0xc0(%rbp)
  408b42:	48 89 b5 e0 f6 ff ff 	mov    %rsi,-0x920(%rbp)
  408b49:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  408b50:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  408b55:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  408b59:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408b5e:	89 c0                	mov    %eax,%eax
  408b60:	4c 89 bd e0 f6 ff ff 	mov    %r15,-0x920(%rbp)
  408b67:	48 c7 85 e8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x918(%rbp)
  408b72:	4c 89 ad e0 f6 ff ff 	mov    %r13,-0x920(%rbp)
  408b79:	48 89 95 e8 f6 ff ff 	mov    %rdx,-0x918(%rbp)
  408b80:	48 89 8d e0 f6 ff ff 	mov    %rcx,-0x920(%rbp)
  408b87:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  408b8e:	66 48 0f 6e d0       	movq   %rax,%xmm2
  408b93:	f3 0f 11 95 30 ff ff ff 	movss  %xmm2,-0xd0(%rbp)
  408b9b:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  408b9f:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  408ba3:	f3 0f 11 85 68 ff ff ff 	movss  %xmm0,-0x98(%rbp)
  408bab:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408baf:	f3 0f 58 05 69 84 02 00 	addss  0x28469(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408bb7:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408bbb:	e8 00 99 ff ff       	callq  4024c0 <sqrt@plt>
  408bc0:	4d 89 f1             	mov    %r14,%r9
  408bc3:	4d 89 e8             	mov    %r13,%r8
  408bc6:	4c 89 e1             	mov    %r12,%rcx
  408bc9:	48 89 df             	mov    %rbx,%rdi
  408bcc:	f3 0f 10 95 30 ff ff ff 	movss  -0xd0(%rbp),%xmm2
  408bd4:	f3 0f 10 4d ac       	movss  -0x54(%rbp),%xmm1
  408bd9:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  408bdd:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  408be1:	66 48 0f 7e d0       	movq   %xmm2,%rax
  408be6:	89 c6                	mov    %eax,%esi
  408be8:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  408bec:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  408bf0:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408bf5:	41 89 c2             	mov    %eax,%r10d
  408bf8:	4c 89 55 b8          	mov    %r10,-0x48(%rbp)
  408bfc:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  408c01:	f3 0f 10 05 17 84 02 00 	movss  0x28417(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408c09:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  408c0e:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408c13:	41 89 c3             	mov    %eax,%r11d
  408c16:	4c 89 5d c0          	mov    %r11,-0x40(%rbp)
  408c1a:	48 83 ec 40          	sub    $0x40,%rsp
  408c1e:	48 89 e0             	mov    %rsp,%rax
  408c21:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  408c29:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  408c31:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  408c39:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  408c41:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  408c49:	4c 89 58 10          	mov    %r11,0x10(%rax)
  408c4d:	4c 89 50 08          	mov    %r10,0x8(%rax)
  408c51:	48 89 30             	mov    %rsi,(%rax)
  408c54:	4d 89 ce             	mov    %r9,%r14
  408c57:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408c5d:	4d 89 c5             	mov    %r8,%r13
  408c60:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408c66:	49 89 cc             	mov    %rcx,%r12
  408c69:	b9 00 00 00 00       	mov    $0x0,%ecx
  408c6e:	ba 09 00 00 00       	mov    $0x9,%edx
  408c73:	48 8d b5 e0 fe ff ff 	lea    -0x120(%rbp),%rsi
  408c7a:	48 89 fb             	mov    %rdi,%rbx
  408c7d:	e8 ce d9 ff ff       	callq  406650 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408c82:	4d 89 f1             	mov    %r14,%r9
  408c85:	4d 89 e8             	mov    %r13,%r8
  408c88:	4c 89 e1             	mov    %r12,%rcx
  408c8b:	48 89 df             	mov    %rbx,%rdi
  408c8e:	4c 8b 5d c0          	mov    -0x40(%rbp),%r11
  408c92:	4c 8b 55 b8          	mov    -0x48(%rbp),%r10
  408c96:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  408c9a:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  408c9e:	48 8b 95 e0 fe ff ff 	mov    -0x120(%rbp),%rdx
  408ca5:	49 89 cc             	mov    %rcx,%r12
  408ca8:	48 8b 8d e8 fe ff ff 	mov    -0x118(%rbp),%rcx
  408caf:	4d 89 c5             	mov    %r8,%r13
  408cb2:	4c 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%r8
  408cb9:	48 83 ec 40          	sub    $0x40,%rsp
  408cbd:	48 89 e0             	mov    %rsp,%rax
  408cc0:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  408cc8:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  408cd0:	4c 89 58 20          	mov    %r11,0x20(%rax)
  408cd4:	4c 89 50 18          	mov    %r10,0x18(%rax)
  408cd8:	48 89 70 10          	mov    %rsi,0x10(%rax)
  408cdc:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  408ce4:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  408ceb:	4d 89 ce             	mov    %r9,%r14
  408cee:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408cf4:	be 04 00 00 00       	mov    $0x4,%esi
  408cf9:	48 89 fb             	mov    %rdi,%rbx
  408cfc:	e8 9f e5 ff ff       	callq  4072a0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  408d01:	4c 89 e1             	mov    %r12,%rcx
  408d04:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  408d0b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  408d0f:	49 89 cc             	mov    %rcx,%r12
  408d12:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  408d16:	f3 0f 10 45 a8       	movss  -0x58(%rbp),%xmm0
  408d1b:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  408d20:	f3 0f 10 5d a0       	movss  -0x60(%rbp),%xmm3
  408d25:	f3 0f 10 55 8c       	movss  -0x74(%rbp),%xmm2
  408d2a:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  408d2e:	4c 89 b5 e0 f6 ff ff 	mov    %r14,-0x920(%rbp)
  408d35:	48 c7 85 e8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x918(%rbp)
  408d40:	48 89 8d e0 f6 ff ff 	mov    %rcx,-0x920(%rbp)
  408d47:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  408d4e:	48 89 85 e0 f6 ff ff 	mov    %rax,-0x920(%rbp)
  408d55:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  408d5c:	4c 89 bd e0 f6 ff ff 	mov    %r15,-0x920(%rbp)
  408d63:	48 c7 85 e8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x918(%rbp)
  408d6e:	f3 0f 58 1d c6 82 02 00 	addss  0x282c6(%rip),%xmm3        # 43103c <_IO_stdin_used+0x3c>
  408d76:	66 48 0f 7e d8       	movq   %xmm3,%rax
  408d7b:	89 c2                	mov    %eax,%edx
  408d7d:	48 89 95 48 ff ff ff 	mov    %rdx,-0xb8(%rbp)
  408d84:	4c 89 ad e0 f6 ff ff 	mov    %r13,-0x920(%rbp)
  408d8b:	48 89 95 e8 f6 ff ff 	mov    %rdx,-0x918(%rbp)
  408d92:	66 48 0f 6e da       	movq   %rdx,%xmm3
  408d97:	f3 0f 5c cb          	subss  %xmm3,%xmm1
  408d9b:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408da0:	89 c0                	mov    %eax,%eax
  408da2:	48 89 85 50 ff ff ff 	mov    %rax,-0xb0(%rbp)
  408da9:	48 89 85 e0 f6 ff ff 	mov    %rax,-0x920(%rbp)
  408db0:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  408db7:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408dbc:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  408dc0:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408dc5:	89 c0                	mov    %eax,%eax
  408dc7:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408dcc:	f3 0f 11 8d 34 ff ff ff 	movss  %xmm1,-0xcc(%rbp)
  408dd4:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  408dd8:	f3 0f 11 8d 6c ff ff ff 	movss  %xmm1,-0x94(%rbp)
  408de0:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408de4:	f3 0f 58 05 34 82 02 00 	addss  0x28234(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408dec:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408df0:	e8 cb 96 ff ff       	callq  4024c0 <sqrt@plt>
  408df5:	4d 89 f1             	mov    %r14,%r9
  408df8:	4d 89 e8             	mov    %r13,%r8
  408dfb:	4c 89 e1             	mov    %r12,%rcx
  408dfe:	48 89 df             	mov    %rbx,%rdi
  408e01:	f3 0f 10 8d 34 ff ff ff 	movss  -0xcc(%rbp),%xmm1
  408e09:	f3 0f 10 55 88       	movss  -0x78(%rbp),%xmm2
  408e0e:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  408e12:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  408e16:	66 48 0f 7e d0       	movq   %xmm2,%rax
  408e1b:	89 c6                	mov    %eax,%esi
  408e1d:	48 89 b5 70 ff ff ff 	mov    %rsi,-0x90(%rbp)
  408e24:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  408e28:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408e2d:	41 89 c2             	mov    %eax,%r10d
  408e30:	4c 89 95 78 ff ff ff 	mov    %r10,-0x88(%rbp)
  408e37:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  408e3c:	f3 0f 10 05 dc 81 02 00 	movss  0x281dc(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408e44:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  408e49:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408e4e:	41 89 c3             	mov    %eax,%r11d
  408e51:	4c 89 5d 80          	mov    %r11,-0x80(%rbp)
  408e55:	48 83 ec 40          	sub    $0x40,%rsp
  408e59:	48 89 e0             	mov    %rsp,%rax
  408e5c:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  408e64:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  408e6c:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  408e74:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  408e7c:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  408e84:	4c 89 58 10          	mov    %r11,0x10(%rax)
  408e88:	4c 89 50 08          	mov    %r10,0x8(%rax)
  408e8c:	48 89 30             	mov    %rsi,(%rax)
  408e8f:	4d 89 ce             	mov    %r9,%r14
  408e92:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408e98:	4d 89 c5             	mov    %r8,%r13
  408e9b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408ea1:	49 89 cc             	mov    %rcx,%r12
  408ea4:	b9 00 00 00 00       	mov    $0x0,%ecx
  408ea9:	ba 09 00 00 00       	mov    $0x9,%edx
  408eae:	48 8d b5 e0 fe ff ff 	lea    -0x120(%rbp),%rsi
  408eb5:	48 89 fb             	mov    %rdi,%rbx
  408eb8:	e8 93 d7 ff ff       	callq  406650 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408ebd:	4d 89 f1             	mov    %r14,%r9
  408ec0:	4d 89 e8             	mov    %r13,%r8
  408ec3:	4c 89 e1             	mov    %r12,%rcx
  408ec6:	48 89 df             	mov    %rbx,%rdi
  408ec9:	4c 8b 5d 80          	mov    -0x80(%rbp),%r11
  408ecd:	4c 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%r10
  408ed4:	48 8b b5 70 ff ff ff 	mov    -0x90(%rbp),%rsi
  408edb:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  408edf:	48 8b 95 e0 fe ff ff 	mov    -0x120(%rbp),%rdx
  408ee6:	49 89 cc             	mov    %rcx,%r12
  408ee9:	48 8b 8d e8 fe ff ff 	mov    -0x118(%rbp),%rcx
  408ef0:	4d 89 c5             	mov    %r8,%r13
  408ef3:	4c 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%r8
  408efa:	48 83 ec 40          	sub    $0x40,%rsp
  408efe:	48 89 e0             	mov    %rsp,%rax
  408f01:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  408f09:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  408f11:	4c 89 58 20          	mov    %r11,0x20(%rax)
  408f15:	4c 89 50 18          	mov    %r10,0x18(%rax)
  408f19:	48 89 70 10          	mov    %rsi,0x10(%rax)
  408f1d:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  408f25:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  408f2c:	4d 89 ce             	mov    %r9,%r14
  408f2f:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  408f35:	be 04 00 00 00       	mov    $0x4,%esi
  408f3a:	48 89 fb             	mov    %rdi,%rbx
  408f3d:	e8 5e e3 ff ff       	callq  4072a0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  408f42:	4d 89 f1             	mov    %r14,%r9
  408f45:	4d 89 e8             	mov    %r13,%r8
  408f48:	4c 89 e1             	mov    %r12,%rcx
  408f4b:	48 89 df             	mov    %rbx,%rdi
  408f4e:	48 89 c3             	mov    %rax,%rbx
  408f51:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  408f58:	48 8b 95 48 ff ff ff 	mov    -0xb8(%rbp),%rdx
  408f5f:	48 8b b5 40 ff ff ff 	mov    -0xc0(%rbp),%rsi
  408f66:	49 89 fe             	mov    %rdi,%r14
  408f69:	48 8b bd 38 ff ff ff 	mov    -0xc8(%rbp),%rdi
  408f70:	f3 0f 10 8d 6c ff ff ff 	movss  -0x94(%rbp),%xmm1
  408f78:	4c 8b a5 60 ff ff ff 	mov    -0xa0(%rbp),%r12
  408f7f:	f3 0f 10 85 68 ff ff ff 	movss  -0x98(%rbp),%xmm0
  408f87:	4c 8b ad 58 ff ff ff 	mov    -0xa8(%rbp),%r13
  408f8e:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  408f92:	4c 89 8d e0 f6 ff ff 	mov    %r9,-0x920(%rbp)
  408f99:	48 c7 85 e8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x918(%rbp)
  408fa4:	48 89 bd e0 f6 ff ff 	mov    %rdi,-0x920(%rbp)
  408fab:	48 89 8d e8 f6 ff ff 	mov    %rcx,-0x918(%rbp)
  408fb2:	48 89 b5 e0 f6 ff ff 	mov    %rsi,-0x920(%rbp)
  408fb9:	48 89 8d e8 f6 ff ff 	mov    %rcx,-0x918(%rbp)
  408fc0:	4c 89 bd e0 f6 ff ff 	mov    %r15,-0x920(%rbp)
  408fc7:	48 c7 85 e8 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x918(%rbp)
  408fd2:	4c 89 85 e0 f6 ff ff 	mov    %r8,-0x920(%rbp)
  408fd9:	48 89 95 e8 f6 ff ff 	mov    %rdx,-0x918(%rbp)
  408fe0:	48 89 85 e0 f6 ff ff 	mov    %rax,-0x920(%rbp)
  408fe7:	48 89 8d e8 f6 ff ff 	mov    %rcx,-0x918(%rbp)
  408fee:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408ff2:	f3 0f 58 05 26 80 02 00 	addss  0x28026(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408ffa:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408ffe:	e8 bd 94 ff ff       	callq  4024c0 <sqrt@plt>
  409003:	4c 89 f7             	mov    %r14,%rdi
  409006:	f3 0f 10 8d 34 ff ff ff 	movss  -0xcc(%rbp),%xmm1
  40900e:	f3 0f 10 95 30 ff ff ff 	movss  -0xd0(%rbp),%xmm2
  409016:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  40901a:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  40901e:	66 48 0f 7e d0       	movq   %xmm2,%rax
  409023:	41 89 c6             	mov    %eax,%r14d
  409026:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  40902a:	66 48 0f 7e c8       	movq   %xmm1,%rax
  40902f:	89 c6                	mov    %eax,%esi
  409031:	48 89 b5 20 ff ff ff 	mov    %rsi,-0xe0(%rbp)
  409038:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  40903d:	f3 0f 10 05 db 7f 02 00 	movss  0x27fdb(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  409045:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  40904a:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40904f:	41 89 c1             	mov    %eax,%r9d
  409052:	4c 89 8d 28 ff ff ff 	mov    %r9,-0xd8(%rbp)
  409059:	48 83 ec 40          	sub    $0x40,%rsp
  40905d:	48 89 e0             	mov    %rsp,%rax
  409060:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  409068:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  409070:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  409078:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  409080:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  409088:	4c 89 48 10          	mov    %r9,0x10(%rax)
  40908c:	48 89 70 08          	mov    %rsi,0x8(%rax)
  409090:	4c 89 30             	mov    %r14,(%rax)
  409093:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  409099:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40909f:	b9 00 00 00 00       	mov    $0x0,%ecx
  4090a4:	ba 09 00 00 00       	mov    $0x9,%edx
  4090a9:	48 8d b5 e0 fe ff ff 	lea    -0x120(%rbp),%rsi
  4090b0:	49 89 ff             	mov    %rdi,%r15
  4090b3:	e8 98 d5 ff ff       	callq  406650 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  4090b8:	4c 89 ff             	mov    %r15,%rdi
  4090bb:	4c 8b 8d 28 ff ff ff 	mov    -0xd8(%rbp),%r9
  4090c2:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
  4090c9:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  4090cd:	48 8b 95 e0 fe ff ff 	mov    -0x120(%rbp),%rdx
  4090d4:	48 8b 8d e8 fe ff ff 	mov    -0x118(%rbp),%rcx
  4090db:	4c 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%r8
  4090e2:	48 83 ec 40          	sub    $0x40,%rsp
  4090e6:	48 89 e0             	mov    %rsp,%rax
  4090e9:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  4090f1:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  4090f9:	4c 89 48 20          	mov    %r9,0x20(%rax)
  4090fd:	48 89 70 18          	mov    %rsi,0x18(%rax)
  409101:	4c 89 70 10          	mov    %r14,0x10(%rax)
  409105:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40910d:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  409114:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40911a:	be 04 00 00 00       	mov    $0x4,%esi
  40911f:	49 89 fe             	mov    %rdi,%r14
  409122:	e8 79 e1 ff ff       	callq  4072a0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  409127:	4c 89 f7             	mov    %r14,%rdi
  40912a:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40912e:	48 c7 85 e0 f6 ff ff ff 00 00 00 	movq   $0xff,-0x920(%rbp)
  409139:	4c 89 ad e0 f6 ff ff 	mov    %r13,-0x920(%rbp)
  409140:	4c 89 a5 e8 f6 ff ff 	mov    %r12,-0x918(%rbp)
  409147:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40914c:	66 49 0f 6e cc       	movq   %r12,%xmm1
  409151:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409155:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40915a:	89 c9                	mov    %ecx,%ecx
  40915c:	48 89 9d e0 f6 ff ff 	mov    %rbx,-0x920(%rbp)
  409163:	48 89 85 e8 f6 ff ff 	mov    %rax,-0x918(%rbp)
  40916a:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  40916f:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409174:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409178:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40917d:	89 c0                	mov    %eax,%eax
  40917f:	48 89 8d e0 f6 ff ff 	mov    %rcx,-0x920(%rbp)
  409186:	48 89 85 e8 f6 ff ff 	mov    %rax,-0x918(%rbp)
  40918d:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409192:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409197:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40919b:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4091a0:	89 c0                	mov    %eax,%eax
  4091a2:	48 89 85 e0 f6 ff ff 	mov    %rax,-0x920(%rbp)
  4091a9:	48 c7 85 e8 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x918(%rbp)
  4091b4:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4091b9:	f3 0f 59 05 77 7e 02 00 	mulss  0x27e77(%rip),%xmm0        # 431038 <_IO_stdin_used+0x38>
  4091c1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4091c6:	89 c0                	mov    %eax,%eax
  4091c8:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4091cd:	f3 0f 10 0d 4f 7e 02 00 	movss  0x27e4f(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  4091d5:	0f 2e c8             	ucomiss %xmm0,%xmm1
  4091d8:	0f 97 c1             	seta   %cl
  4091db:	0f b6 c9             	movzbl %cl,%ecx
  4091de:	89 ca                	mov    %ecx,%edx
  4091e0:	48 83 fa 01          	cmp    $0x1,%rdx
  4091e4:	0f 94 c1             	sete   %cl
  4091e7:	0f b6 c9             	movzbl %cl,%ecx
  4091ea:	48 c1 ea 28          	shr    $0x28,%rdx
  4091ee:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  4091f5:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  4091fc:	0f 94 c2             	sete   %dl
  4091ff:	0f b6 d2             	movzbl %dl,%edx
  409202:	09 d1                	or     %edx,%ecx
  409204:	75 68                	jne    40926e <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa6e>
  409206:	83 f1 01             	xor    $0x1,%ecx
  409209:	75 11                	jne    40921c <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa1c>
  40920b:	be 04 00 00 00       	mov    $0x4,%esi
  409210:	e8 8b 1d 02 00       	callq  42afa0 <p111_rt_fail>
  409215:	b8 00 00 00 00       	mov    $0x0,%eax
  40921a:	eb 57                	jmp    409273 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa73>
  40921c:	0f 2e 05 fd 7d 02 00 	ucomiss 0x27dfd(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  409223:	0f 97 c1             	seta   %cl
  409226:	0f b6 c9             	movzbl %cl,%ecx
  409229:	89 ca                	mov    %ecx,%edx
  40922b:	48 83 fa 01          	cmp    $0x1,%rdx
  40922f:	0f 94 c1             	sete   %cl
  409232:	0f b6 c9             	movzbl %cl,%ecx
  409235:	48 c1 ea 28          	shr    $0x28,%rdx
  409239:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  409240:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  409247:	0f 94 c2             	sete   %dl
  40924a:	0f b6 d2             	movzbl %dl,%edx
  40924d:	09 d1                	or     %edx,%ecx
  40924f:	75 16                	jne    409267 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa67>
  409251:	83 f1 01             	xor    $0x1,%ecx
  409254:	75 1d                	jne    409273 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa73>
  409256:	be 04 00 00 00       	mov    $0x4,%esi
  40925b:	e8 40 1d 02 00       	callq  42afa0 <p111_rt_fail>
  409260:	b8 00 00 00 00       	mov    $0x0,%eax
  409265:	eb 0c                	jmp    409273 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa73>
  409267:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  40926c:	eb 05                	jmp    409273 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xa73>
  40926e:	b8 00 00 00 00       	mov    $0x0,%eax
  409273:	48 c7 85 e0 f6 ff ff 00 00 7f 43 	movq   $0x437f0000,-0x920(%rbp)
  40927e:	48 89 85 e8 f6 ff ff 	mov    %rax,-0x918(%rbp)
  409285:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40928a:	f3 0f 59 05 b2 7d 02 00 	mulss  0x27db2(%rip),%xmm0        # 431044 <_IO_stdin_used+0x44>
  409292:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409297:	89 c0                	mov    %eax,%eax
  409299:	48 89 85 e0 f6 ff ff 	mov    %rax,-0x920(%rbp)
  4092a0:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4092a5:	0f 2e 05 78 7d 02 00 	ucomiss 0x27d78(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  4092ac:	0f 93 c0             	setae  %al
  4092af:	0f b6 c0             	movzbl %al,%eax
  4092b2:	f3 0f 10 0d 86 7d 02 00 	movss  0x27d86(%rip),%xmm1        # 431040 <_IO_stdin_used+0x40>
  4092ba:	0f 2e c8             	ucomiss %xmm0,%xmm1
  4092bd:	0f 97 c1             	seta   %cl
  4092c0:	0f b6 c9             	movzbl %cl,%ecx
  4092c3:	85 c1                	test   %eax,%ecx
  4092c5:	f3 48 0f 2c c0       	cvttss2si %xmm0,%rax
  4092ca:	89 c0                	mov    %eax,%eax
  4092cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  4092d1:	48 0f 44 c1          	cmove  %rcx,%rax
  4092d5:	41 5f                	pop    %r15
  4092d7:	41 5e                	pop    %r14
  4092d9:	41 5d                	pop    %r13
  4092db:	41 5c                	pop    %r12
  4092dd:	5b                   	pop    %rbx
  4092de:	c9                   	leaveq 
  4092df:	c3                   	retq   

