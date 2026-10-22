0000000000408870 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_>:
  408870:	f3 0f 1e fa          	endbr64 
  408874:	55                   	push   %rbp
  408875:	48 89 e5             	mov    %rsp,%rbp
  408878:	48 81 ec f8 08 00 00 	sub    $0x8f8,%rsp
  40887f:	53                   	push   %rbx
  408880:	41 54                	push   %r12
  408882:	41 55                	push   %r13
  408884:	41 56                	push   %r14
  408886:	41 57                	push   %r15
  408888:	4d 89 c5             	mov    %r8,%r13
  40888b:	49 89 cc             	mov    %rcx,%r12
  40888e:	48 89 fb             	mov    %rdi,%rbx
  408891:	48 89 b5 10 f7 ff ff 	mov    %rsi,-0x8f0(%rbp)
  408898:	89 f0                	mov    %esi,%eax
  40889a:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  40889f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4088a4:	41 89 c6             	mov    %eax,%r14d
  4088a7:	48 89 95 10 f7 ff ff 	mov    %rdx,-0x8f0(%rbp)
  4088ae:	89 d0                	mov    %edx,%eax
  4088b0:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  4088b5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4088ba:	41 89 c7             	mov    %eax,%r15d
  4088bd:	4c 89 b5 10 f7 ff ff 	mov    %r14,-0x8f0(%rbp)
  4088c4:	48 c7 85 18 f7 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x8e8(%rbp)
  4088cf:	66 49 0f 6e c6       	movq   %r14,%xmm0
  4088d4:	f3 0f 11 45 dc       	movss  %xmm0,-0x24(%rbp)
  4088d9:	f3 0f 58 05 6b 87 02 00 	addss  0x2876b(%rip),%xmm0        # 43104c <_IO_stdin_used+0x4c>
  4088e1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4088e6:	89 c1                	mov    %eax,%ecx
  4088e8:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  4088ec:	48 89 8d 10 f7 ff ff 	mov    %rcx,-0x8f0(%rbp)
  4088f3:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  4088fa:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  4088ff:	66 49 0f 6e d4       	movq   %r12,%xmm2
  408904:	f3 0f 11 55 ac       	movss  %xmm2,-0x54(%rbp)
  408909:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  40890d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408912:	89 c0                	mov    %eax,%eax
  408914:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  408918:	48 89 85 10 f7 ff ff 	mov    %rax,-0x8f0(%rbp)
  40891f:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  408926:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40892b:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  40892f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408934:	89 c1                	mov    %eax,%ecx
  408936:	4c 89 bd 10 f7 ff ff 	mov    %r15,-0x8f0(%rbp)
  40893d:	48 c7 85 18 f7 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x8e8(%rbp)
  408948:	66 49 0f 6e df       	movq   %r15,%xmm3
  40894d:	f3 0f 11 5d c0       	movss  %xmm3,-0x40(%rbp)
  408952:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  408956:	f3 0f 58 05 ee 86 02 00 	addss  0x286ee(%rip),%xmm0        # 43104c <_IO_stdin_used+0x4c>
  40895e:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408963:	89 c2                	mov    %eax,%edx
  408965:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  408969:	4c 89 ad 10 f7 ff ff 	mov    %r13,-0x8f0(%rbp)
  408970:	48 89 95 18 f7 ff ff 	mov    %rdx,-0x8e8(%rbp)
  408977:	66 49 0f 6e cd       	movq   %r13,%xmm1
  40897c:	f3 0f 11 4d c4       	movss  %xmm1,-0x3c(%rbp)
  408981:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  408986:	0f 57 05 83 86 02 00 	xorps  0x28683(%rip),%xmm0        # 431010 <_IO_stdin_used+0x10>
  40898d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408991:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408996:	89 c0                	mov    %eax,%eax
  408998:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  40899c:	48 89 85 10 f7 ff ff 	mov    %rax,-0x8f0(%rbp)
  4089a3:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  4089aa:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4089af:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  4089b3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4089b8:	89 c0                	mov    %eax,%eax
  4089ba:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  4089bf:	f3 0f 11 55 a8       	movss  %xmm2,-0x58(%rbp)
  4089c4:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  4089c8:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  4089cc:	f3 0f 11 45 c8       	movss  %xmm0,-0x38(%rbp)
  4089d1:	66 48 0f 6e c8       	movq   %rax,%xmm1
  4089d6:	f3 0f 11 4d d8       	movss  %xmm1,-0x28(%rbp)
  4089db:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  4089df:	f3 0f 11 4d f0       	movss  %xmm1,-0x10(%rbp)
  4089e4:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  4089e8:	f3 0f 58 05 30 86 02 00 	addss  0x28630(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  4089f0:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  4089f4:	e8 c7 9a ff ff       	callq  4024c0 <sqrt@plt>
  4089f9:	4d 89 f1             	mov    %r14,%r9
  4089fc:	4d 89 e8             	mov    %r13,%r8
  4089ff:	4c 89 e1             	mov    %r12,%rcx
  408a02:	48 89 df             	mov    %rbx,%rdi
  408a05:	f3 0f 10 4d d8       	movss  -0x28(%rbp),%xmm1
  408a0a:	f3 0f 10 55 a8       	movss  -0x58(%rbp),%xmm2
  408a0f:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  408a13:	f3 0f 10 e2          	movss  %xmm2,%xmm4
  408a17:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  408a1b:	f3 0f 11 65 f4       	movss  %xmm4,-0xc(%rbp)
  408a20:	f3 0f 10 e9          	movss  %xmm1,%xmm5
  408a24:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  408a28:	f3 0f 11 6d f8       	movss  %xmm5,-0x8(%rbp)
  408a2d:	f3 0f 10 35 eb 85 02 00 	movss  0x285eb(%rip),%xmm6        # 431020 <_IO_stdin_used+0x20>
  408a35:	f3 0f 5e f0          	divss  %xmm0,%xmm6
  408a39:	f3 0f 11 75 fc       	movss  %xmm6,-0x4(%rbp)
  408a3e:	48 83 ec 10          	sub    $0x10,%rsp
  408a42:	48 89 e0             	mov    %rsp,%rax
  408a45:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  408a4d:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  408a54:	4d 89 ce             	mov    %r9,%r14
  408a57:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  408a5d:	4d 89 c5             	mov    %r8,%r13
  408a60:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  408a66:	49 89 cc             	mov    %rcx,%r12
  408a69:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  408a6e:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  408a72:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  408a76:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  408a7a:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  408a7e:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  408a82:	f3 0f 10 15 9a 85 02 00 	movss  0x2859a(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408a8a:	f3 0f 10 0d 92 85 02 00 	movss  0x28592(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408a92:	f3 0f 10 05 8a 85 02 00 	movss  0x2858a(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  408a9a:	ba 09 00 00 00       	mov    $0x9,%edx
  408a9f:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  408aa6:	48 89 fb             	mov    %rdi,%rbx
  408aa9:	e8 52 dd ff ff       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408aae:	4d 89 e8             	mov    %r13,%r8
  408ab1:	4c 89 e1             	mov    %r12,%rcx
  408ab4:	48 89 df             	mov    %rbx,%rdi
  408ab7:	f3 0f 10 75 fc       	movss  -0x4(%rbp),%xmm6
  408abc:	f3 0f 10 6d f8       	movss  -0x8(%rbp),%xmm5
  408ac1:	f3 0f 10 65 f4       	movss  -0xc(%rbp),%xmm4
  408ac6:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  408aca:	48 8b 95 10 ff ff ff 	mov    -0xf0(%rbp),%rdx
  408ad1:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  408ad8:	49 89 cc             	mov    %rcx,%r12
  408adb:	48 8b 8d 20 ff ff ff 	mov    -0xe0(%rbp),%rcx
  408ae2:	66 48 0f 6e c0       	movq   %rax,%xmm0
  408ae7:	f3 0f 10 3d 31 85 02 00 	movss  0x28531(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  408aef:	4d 89 c5             	mov    %r8,%r13
  408af2:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408af8:	f3 0f 10 1d 24 85 02 00 	movss  0x28524(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  408b00:	f3 0f 10 15 1c 85 02 00 	movss  0x2851c(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408b08:	f3 0f 10 0d 14 85 02 00 	movss  0x28514(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408b10:	be 04 00 00 00       	mov    $0x4,%esi
  408b15:	48 89 fb             	mov    %rdi,%rbx
  408b18:	e8 93 e8 ff ff       	callq  4073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  408b1d:	4c 89 e1             	mov    %r12,%rcx
  408b20:	48 89 df             	mov    %rbx,%rdi
  408b23:	48 89 45 88          	mov    %rax,-0x78(%rbp)
  408b27:	49 89 cc             	mov    %rcx,%r12
  408b2a:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  408b2e:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  408b32:	f3 0f 10 4d f0       	movss  -0x10(%rbp),%xmm1
  408b37:	f3 0f 10 55 ac       	movss  -0x54(%rbp),%xmm2
  408b3c:	f3 0f 10 45 dc       	movss  -0x24(%rbp),%xmm0
  408b41:	4c 89 b5 10 f7 ff ff 	mov    %r14,-0x8f0(%rbp)
  408b48:	48 c7 85 18 f7 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x8e8(%rbp)
  408b53:	f3 0f 58 05 f5 84 02 00 	addss  0x284f5(%rip),%xmm0        # 431050 <_IO_stdin_used+0x50>
  408b5b:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408b60:	48 89 fb             	mov    %rdi,%rbx
  408b63:	89 c7                	mov    %eax,%edi
  408b65:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  408b6c:	48 89 bd 10 f7 ff ff 	mov    %rdi,-0x8f0(%rbp)
  408b73:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  408b7a:	66 48 0f 6e c7       	movq   %rdi,%xmm0
  408b7f:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  408b83:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408b88:	89 c6                	mov    %eax,%esi
  408b8a:	48 89 b5 70 ff ff ff 	mov    %rsi,-0x90(%rbp)
  408b91:	48 89 b5 10 f7 ff ff 	mov    %rsi,-0x8f0(%rbp)
  408b98:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  408b9f:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  408ba4:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  408ba8:	66 48 0f 7e c0       	movq   %xmm0,%rax
  408bad:	89 c0                	mov    %eax,%eax
  408baf:	4c 89 bd 10 f7 ff ff 	mov    %r15,-0x8f0(%rbp)
  408bb6:	48 c7 85 18 f7 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x8e8(%rbp)
  408bc1:	4c 89 ad 10 f7 ff ff 	mov    %r13,-0x8f0(%rbp)
  408bc8:	48 89 95 18 f7 ff ff 	mov    %rdx,-0x8e8(%rbp)
  408bcf:	48 89 8d 10 f7 ff ff 	mov    %rcx,-0x8f0(%rbp)
  408bd6:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  408bdd:	66 48 0f 6e d0       	movq   %rax,%xmm2
  408be2:	f3 0f 11 95 5c ff ff ff 	movss  %xmm2,-0xa4(%rbp)
  408bea:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  408bee:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  408bf2:	f3 0f 11 85 64 ff ff ff 	movss  %xmm0,-0x9c(%rbp)
  408bfa:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408bfe:	f3 0f 58 05 1a 84 02 00 	addss  0x2841a(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408c06:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408c0a:	e8 b1 98 ff ff       	callq  4024c0 <sqrt@plt>
  408c0f:	4d 89 f1             	mov    %r14,%r9
  408c12:	4d 89 e8             	mov    %r13,%r8
  408c15:	4c 89 e1             	mov    %r12,%rcx
  408c18:	48 89 df             	mov    %rbx,%rdi
  408c1b:	f3 0f 10 95 5c ff ff ff 	movss  -0xa4(%rbp),%xmm2
  408c23:	f3 0f 10 4d d8       	movss  -0x28(%rbp),%xmm1
  408c28:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  408c2c:	f3 0f 10 e2          	movss  %xmm2,%xmm4
  408c30:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  408c34:	f3 0f 11 65 cc       	movss  %xmm4,-0x34(%rbp)
  408c39:	f3 0f 10 e9          	movss  %xmm1,%xmm5
  408c3d:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  408c41:	f3 0f 11 6d d0       	movss  %xmm5,-0x30(%rbp)
  408c46:	f3 0f 10 35 d2 83 02 00 	movss  0x283d2(%rip),%xmm6        # 431020 <_IO_stdin_used+0x20>
  408c4e:	f3 0f 5e f0          	divss  %xmm0,%xmm6
  408c52:	f3 0f 11 75 d4       	movss  %xmm6,-0x2c(%rbp)
  408c57:	48 83 ec 10          	sub    $0x10,%rsp
  408c5b:	48 89 e0             	mov    %rsp,%rax
  408c5e:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  408c66:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  408c6d:	4d 89 ce             	mov    %r9,%r14
  408c70:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  408c76:	4d 89 c5             	mov    %r8,%r13
  408c79:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  408c7f:	49 89 cc             	mov    %rcx,%r12
  408c82:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  408c87:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  408c8b:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  408c8f:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  408c93:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  408c97:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  408c9b:	f3 0f 10 15 81 83 02 00 	movss  0x28381(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408ca3:	f3 0f 10 0d 79 83 02 00 	movss  0x28379(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408cab:	f3 0f 10 05 71 83 02 00 	movss  0x28371(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  408cb3:	ba 09 00 00 00       	mov    $0x9,%edx
  408cb8:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  408cbf:	48 89 fb             	mov    %rdi,%rbx
  408cc2:	e8 39 db ff ff       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408cc7:	4d 89 e8             	mov    %r13,%r8
  408cca:	4c 89 e1             	mov    %r12,%rcx
  408ccd:	48 89 df             	mov    %rbx,%rdi
  408cd0:	f3 0f 10 75 d4       	movss  -0x2c(%rbp),%xmm6
  408cd5:	f3 0f 10 6d d0       	movss  -0x30(%rbp),%xmm5
  408cda:	f3 0f 10 65 cc       	movss  -0x34(%rbp),%xmm4
  408cdf:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  408ce3:	48 8b 95 10 ff ff ff 	mov    -0xf0(%rbp),%rdx
  408cea:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  408cf1:	49 89 cc             	mov    %rcx,%r12
  408cf4:	48 8b 8d 20 ff ff ff 	mov    -0xe0(%rbp),%rcx
  408cfb:	66 48 0f 6e c0       	movq   %rax,%xmm0
  408d00:	f3 0f 10 3d 18 83 02 00 	movss  0x28318(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  408d08:	4d 89 c5             	mov    %r8,%r13
  408d0b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408d11:	f3 0f 10 1d 0b 83 02 00 	movss  0x2830b(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  408d19:	f3 0f 10 15 03 83 02 00 	movss  0x28303(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408d21:	f3 0f 10 0d fb 82 02 00 	movss  0x282fb(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408d29:	be 04 00 00 00       	mov    $0x4,%esi
  408d2e:	48 89 fb             	mov    %rdi,%rbx
  408d31:	e8 7a e6 ff ff       	callq  4073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  408d36:	4c 89 e1             	mov    %r12,%rcx
  408d39:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  408d3d:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  408d41:	49 89 cc             	mov    %rcx,%r12
  408d44:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  408d48:	f3 0f 10 45 c8       	movss  -0x38(%rbp),%xmm0
  408d4d:	f3 0f 10 4d c4       	movss  -0x3c(%rbp),%xmm1
  408d52:	f3 0f 10 5d c0       	movss  -0x40(%rbp),%xmm3
  408d57:	f3 0f 10 55 ac       	movss  -0x54(%rbp),%xmm2
  408d5c:	4c 89 b5 10 f7 ff ff 	mov    %r14,-0x8f0(%rbp)
  408d63:	48 c7 85 18 f7 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x8e8(%rbp)
  408d6e:	48 89 8d 10 f7 ff ff 	mov    %rcx,-0x8f0(%rbp)
  408d75:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  408d7c:	48 89 85 10 f7 ff ff 	mov    %rax,-0x8f0(%rbp)
  408d83:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  408d8a:	4c 89 bd 10 f7 ff ff 	mov    %r15,-0x8f0(%rbp)
  408d91:	48 c7 85 18 f7 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x8e8(%rbp)
  408d9c:	f3 0f 58 1d ac 82 02 00 	addss  0x282ac(%rip),%xmm3        # 431050 <_IO_stdin_used+0x50>
  408da4:	66 48 0f 7e d8       	movq   %xmm3,%rax
  408da9:	89 c2                	mov    %eax,%edx
  408dab:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
  408db2:	4c 89 ad 10 f7 ff ff 	mov    %r13,-0x8f0(%rbp)
  408db9:	48 89 95 18 f7 ff ff 	mov    %rdx,-0x8e8(%rbp)
  408dc0:	66 48 0f 6e da       	movq   %rdx,%xmm3
  408dc5:	f3 0f 5c cb          	subss  %xmm3,%xmm1
  408dc9:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408dce:	89 c0                	mov    %eax,%eax
  408dd0:	48 89 45 80          	mov    %rax,-0x80(%rbp)
  408dd4:	48 89 85 10 f7 ff ff 	mov    %rax,-0x8f0(%rbp)
  408ddb:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  408de2:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408de7:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  408deb:	66 48 0f 7e c8       	movq   %xmm1,%rax
  408df0:	89 c0                	mov    %eax,%eax
  408df2:	66 48 0f 6e c8       	movq   %rax,%xmm1
  408df7:	f3 0f 11 8d 60 ff ff ff 	movss  %xmm1,-0xa0(%rbp)
  408dff:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  408e03:	f3 0f 11 4d 98       	movss  %xmm1,-0x68(%rbp)
  408e08:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408e0c:	f3 0f 58 05 0c 82 02 00 	addss  0x2820c(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408e14:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408e18:	e8 a3 96 ff ff       	callq  4024c0 <sqrt@plt>
  408e1d:	4d 89 f1             	mov    %r14,%r9
  408e20:	4d 89 e8             	mov    %r13,%r8
  408e23:	4c 89 e1             	mov    %r12,%rcx
  408e26:	48 89 df             	mov    %rbx,%rdi
  408e29:	f3 0f 10 8d 60 ff ff ff 	movss  -0xa0(%rbp),%xmm1
  408e31:	f3 0f 10 55 a8       	movss  -0x58(%rbp),%xmm2
  408e36:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  408e3a:	f3 0f 10 e2          	movss  %xmm2,%xmm4
  408e3e:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  408e42:	f3 0f 11 65 9c       	movss  %xmm4,-0x64(%rbp)
  408e47:	f3 0f 10 e9          	movss  %xmm1,%xmm5
  408e4b:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  408e4f:	f3 0f 11 6d a0       	movss  %xmm5,-0x60(%rbp)
  408e54:	f3 0f 10 35 c4 81 02 00 	movss  0x281c4(%rip),%xmm6        # 431020 <_IO_stdin_used+0x20>
  408e5c:	f3 0f 5e f0          	divss  %xmm0,%xmm6
  408e60:	f3 0f 11 75 a4       	movss  %xmm6,-0x5c(%rbp)
  408e65:	48 83 ec 10          	sub    $0x10,%rsp
  408e69:	48 89 e0             	mov    %rsp,%rax
  408e6c:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  408e74:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  408e7b:	4d 89 ce             	mov    %r9,%r14
  408e7e:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  408e84:	4d 89 c5             	mov    %r8,%r13
  408e87:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  408e8d:	49 89 cc             	mov    %rcx,%r12
  408e90:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  408e95:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  408e99:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  408e9d:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  408ea1:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  408ea5:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  408ea9:	f3 0f 10 15 73 81 02 00 	movss  0x28173(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408eb1:	f3 0f 10 0d 6b 81 02 00 	movss  0x2816b(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408eb9:	f3 0f 10 05 63 81 02 00 	movss  0x28163(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  408ec1:	ba 09 00 00 00       	mov    $0x9,%edx
  408ec6:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  408ecd:	48 89 fb             	mov    %rdi,%rbx
  408ed0:	e8 2b d9 ff ff       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  408ed5:	4d 89 e8             	mov    %r13,%r8
  408ed8:	4c 89 e1             	mov    %r12,%rcx
  408edb:	48 89 df             	mov    %rbx,%rdi
  408ede:	f3 0f 10 75 a4       	movss  -0x5c(%rbp),%xmm6
  408ee3:	f3 0f 10 6d a0       	movss  -0x60(%rbp),%xmm5
  408ee8:	f3 0f 10 65 9c       	movss  -0x64(%rbp),%xmm4
  408eed:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  408ef1:	48 8b 95 10 ff ff ff 	mov    -0xf0(%rbp),%rdx
  408ef8:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  408eff:	49 89 cc             	mov    %rcx,%r12
  408f02:	48 8b 8d 20 ff ff ff 	mov    -0xe0(%rbp),%rcx
  408f09:	66 48 0f 6e c0       	movq   %rax,%xmm0
  408f0e:	f3 0f 10 3d 0a 81 02 00 	movss  0x2810a(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  408f16:	4d 89 c5             	mov    %r8,%r13
  408f19:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  408f1f:	f3 0f 10 1d fd 80 02 00 	movss  0x280fd(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  408f27:	f3 0f 10 15 f5 80 02 00 	movss  0x280f5(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  408f2f:	f3 0f 10 0d ed 80 02 00 	movss  0x280ed(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  408f37:	be 04 00 00 00       	mov    $0x4,%esi
  408f3c:	48 89 fb             	mov    %rdi,%rbx
  408f3f:	e8 6c e4 ff ff       	callq  4073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  408f44:	4d 89 f1             	mov    %r14,%r9
  408f47:	4d 89 e8             	mov    %r13,%r8
  408f4a:	4c 89 e1             	mov    %r12,%rcx
  408f4d:	48 89 df             	mov    %rbx,%rdi
  408f50:	48 89 c3             	mov    %rax,%rbx
  408f53:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  408f57:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  408f5e:	48 8b b5 70 ff ff ff 	mov    -0x90(%rbp),%rsi
  408f65:	49 89 fe             	mov    %rdi,%r14
  408f68:	48 8b bd 68 ff ff ff 	mov    -0x98(%rbp),%rdi
  408f6f:	f3 0f 10 4d 98       	movss  -0x68(%rbp),%xmm1
  408f74:	4c 8b 65 90          	mov    -0x70(%rbp),%r12
  408f78:	f3 0f 10 85 64 ff ff ff 	movss  -0x9c(%rbp),%xmm0
  408f80:	4c 8b 6d 88          	mov    -0x78(%rbp),%r13
  408f84:	4c 89 8d 10 f7 ff ff 	mov    %r9,-0x8f0(%rbp)
  408f8b:	48 c7 85 18 f7 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x8e8(%rbp)
  408f96:	48 89 bd 10 f7 ff ff 	mov    %rdi,-0x8f0(%rbp)
  408f9d:	48 89 8d 18 f7 ff ff 	mov    %rcx,-0x8e8(%rbp)
  408fa4:	48 89 b5 10 f7 ff ff 	mov    %rsi,-0x8f0(%rbp)
  408fab:	48 89 8d 18 f7 ff ff 	mov    %rcx,-0x8e8(%rbp)
  408fb2:	4c 89 bd 10 f7 ff ff 	mov    %r15,-0x8f0(%rbp)
  408fb9:	48 c7 85 18 f7 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x8e8(%rbp)
  408fc4:	4c 89 85 10 f7 ff ff 	mov    %r8,-0x8f0(%rbp)
  408fcb:	48 89 95 18 f7 ff ff 	mov    %rdx,-0x8e8(%rbp)
  408fd2:	48 89 85 10 f7 ff ff 	mov    %rax,-0x8f0(%rbp)
  408fd9:	48 89 8d 18 f7 ff ff 	mov    %rcx,-0x8e8(%rbp)
  408fe0:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  408fe4:	f3 0f 58 05 34 80 02 00 	addss  0x28034(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  408fec:	f3 0f 5a c0          	cvtss2sd %xmm0,%xmm0
  408ff0:	e8 cb 94 ff ff       	callq  4024c0 <sqrt@plt>
  408ff5:	4c 89 f7             	mov    %r14,%rdi
  408ff8:	f3 0f 10 8d 60 ff ff ff 	movss  -0xa0(%rbp),%xmm1
  409000:	f3 0f 10 95 5c ff ff ff 	movss  -0xa4(%rbp),%xmm2
  409008:	f2 0f 5a c0          	cvtsd2ss %xmm0,%xmm0
  40900c:	f3 0f 10 e2          	movss  %xmm2,%xmm4
  409010:	f3 0f 5e e0          	divss  %xmm0,%xmm4
  409014:	f3 0f 11 a5 50 ff ff ff 	movss  %xmm4,-0xb0(%rbp)
  40901c:	f3 0f 10 e9          	movss  %xmm1,%xmm5
  409020:	f3 0f 5e e8          	divss  %xmm0,%xmm5
  409024:	f3 0f 11 ad 54 ff ff ff 	movss  %xmm5,-0xac(%rbp)
  40902c:	f3 0f 10 35 ec 7f 02 00 	movss  0x27fec(%rip),%xmm6        # 431020 <_IO_stdin_used+0x20>
  409034:	f3 0f 5e f0          	divss  %xmm0,%xmm6
  409038:	f3 0f 11 b5 58 ff ff ff 	movss  %xmm6,-0xa8(%rbp)
  409040:	48 83 ec 10          	sub    $0x10,%rsp
  409044:	48 89 e0             	mov    %rsp,%rax
  409047:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40904f:	48 c7 00 09 00 00 00 	movq   $0x9,(%rax)
  409056:	41 b9 28 6b 6e 4e    	mov    $0x4e6e6b28,%r9d
  40905c:	41 b8 09 00 00 00    	mov    $0x9,%r8d
  409062:	b9 28 6b 6e 4e       	mov    $0x4e6e6b28,%ecx
  409067:	f3 0f 10 cd          	movss  %xmm5,%xmm1
  40906b:	f3 0f 10 ee          	movss  %xmm6,%xmm5
  40906f:	f3 0f 10 c4          	movss  %xmm4,%xmm0
  409073:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  409077:	f3 0f 10 d8          	movss  %xmm0,%xmm3
  40907b:	f3 0f 10 15 a1 7f 02 00 	movss  0x27fa1(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  409083:	f3 0f 10 0d 99 7f 02 00 	movss  0x27f99(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  40908b:	f3 0f 10 05 91 7f 02 00 	movss  0x27f91(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  409093:	ba 09 00 00 00       	mov    $0x9,%edx
  409098:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  40909f:	49 89 fe             	mov    %rdi,%r14
  4090a2:	e8 59 d7 ff ff       	callq  406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  4090a7:	4c 89 f7             	mov    %r14,%rdi
  4090aa:	f3 0f 10 b5 58 ff ff ff 	movss  -0xa8(%rbp),%xmm6
  4090b2:	f3 0f 10 ad 54 ff ff ff 	movss  -0xac(%rbp),%xmm5
  4090ba:	f3 0f 10 a5 50 ff ff ff 	movss  -0xb0(%rbp),%xmm4
  4090c2:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  4090c6:	48 8b 95 10 ff ff ff 	mov    -0xf0(%rbp),%rdx
  4090cd:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  4090d4:	48 8b 8d 20 ff ff ff 	mov    -0xe0(%rbp),%rcx
  4090db:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4090e0:	f3 0f 10 3d 38 7f 02 00 	movss  0x27f38(%rip),%xmm7        # 431020 <_IO_stdin_used+0x20>
  4090e8:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  4090ee:	f3 0f 10 1d 2e 7f 02 00 	movss  0x27f2e(%rip),%xmm3        # 431024 <_IO_stdin_used+0x24>
  4090f6:	f3 0f 10 15 26 7f 02 00 	movss  0x27f26(%rip),%xmm2        # 431024 <_IO_stdin_used+0x24>
  4090fe:	f3 0f 10 0d 1e 7f 02 00 	movss  0x27f1e(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  409106:	be 04 00 00 00       	mov    $0x4,%esi
  40910b:	49 89 fe             	mov    %rdi,%r14
  40910e:	e8 9d e2 ff ff       	callq  4073b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  409113:	4c 89 f7             	mov    %r14,%rdi
  409116:	48 c7 85 10 f7 ff ff ff 00 00 00 	movq   $0xff,-0x8f0(%rbp)
  409121:	4c 89 ad 10 f7 ff ff 	mov    %r13,-0x8f0(%rbp)
  409128:	4c 89 a5 18 f7 ff ff 	mov    %r12,-0x8e8(%rbp)
  40912f:	66 49 0f 6e c5       	movq   %r13,%xmm0
  409134:	66 49 0f 6e cc       	movq   %r12,%xmm1
  409139:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40913d:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  409142:	89 c9                	mov    %ecx,%ecx
  409144:	48 89 9d 10 f7 ff ff 	mov    %rbx,-0x8f0(%rbp)
  40914b:	48 89 85 18 f7 ff ff 	mov    %rax,-0x8e8(%rbp)
  409152:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  409157:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40915c:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409160:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409165:	89 c0                	mov    %eax,%eax
  409167:	48 89 8d 10 f7 ff ff 	mov    %rcx,-0x8f0(%rbp)
  40916e:	48 89 85 18 f7 ff ff 	mov    %rax,-0x8e8(%rbp)
  409175:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40917a:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40917f:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409183:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409188:	89 c0                	mov    %eax,%eax
  40918a:	48 89 85 10 f7 ff ff 	mov    %rax,-0x8f0(%rbp)
  409191:	48 c7 85 18 f7 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x8e8(%rbp)
  40919c:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4091a1:	f3 0f 59 05 a3 7e 02 00 	mulss  0x27ea3(%rip),%xmm0        # 43104c <_IO_stdin_used+0x4c>
  4091a9:	66 48 0f 7e c0       	movq   %xmm0,%rax
  4091ae:	89 c0                	mov    %eax,%eax
  4091b0:	66 48 0f 6e c0       	movq   %rax,%xmm0
  4091b5:	f3 0f 10 0d 67 7e 02 00 	movss  0x27e67(%rip),%xmm1        # 431024 <_IO_stdin_used+0x24>
  4091bd:	0f 2e c8             	ucomiss %xmm0,%xmm1
  4091c0:	0f 97 c1             	seta   %cl
  4091c3:	0f b6 c9             	movzbl %cl,%ecx
  4091c6:	89 ca                	mov    %ecx,%edx
  4091c8:	48 83 fa 01          	cmp    $0x1,%rdx
  4091cc:	0f 94 c1             	sete   %cl
  4091cf:	0f b6 c9             	movzbl %cl,%ecx
  4091d2:	48 c1 ea 28          	shr    $0x28,%rdx
  4091d6:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  4091dd:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  4091e4:	0f 94 c2             	sete   %dl
  4091e7:	0f b6 d2             	movzbl %dl,%edx
  4091ea:	09 d1                	or     %edx,%ecx
  4091ec:	75 68                	jne    409256 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x9e6>
  4091ee:	83 f1 01             	xor    $0x1,%ecx
  4091f1:	75 11                	jne    409204 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x994>
  4091f3:	be 04 00 00 00       	mov    $0x4,%esi
  4091f8:	e8 a3 1d 02 00       	callq  42afa0 <p111_rt_fail>
  4091fd:	b8 00 00 00 00       	mov    $0x0,%eax
  409202:	eb 57                	jmp    40925b <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x9eb>
  409204:	0f 2e 05 15 7e 02 00 	ucomiss 0x27e15(%rip),%xmm0        # 431020 <_IO_stdin_used+0x20>
  40920b:	0f 97 c1             	seta   %cl
  40920e:	0f b6 c9             	movzbl %cl,%ecx
  409211:	89 ca                	mov    %ecx,%edx
  409213:	48 83 fa 01          	cmp    $0x1,%rdx
  409217:	0f 94 c1             	sete   %cl
  40921a:	0f b6 c9             	movzbl %cl,%ecx
  40921d:	48 c1 ea 28          	shr    $0x28,%rdx
  409221:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  409228:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  40922f:	0f 94 c2             	sete   %dl
  409232:	0f b6 d2             	movzbl %dl,%edx
  409235:	09 d1                	or     %edx,%ecx
  409237:	75 16                	jne    40924f <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x9df>
  409239:	83 f1 01             	xor    $0x1,%ecx
  40923c:	75 1d                	jne    40925b <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x9eb>
  40923e:	be 04 00 00 00       	mov    $0x4,%esi
  409243:	e8 58 1d 02 00       	callq  42afa0 <p111_rt_fail>
  409248:	b8 00 00 00 00       	mov    $0x0,%eax
  40924d:	eb 0c                	jmp    40925b <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x9eb>
  40924f:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  409254:	eb 05                	jmp    40925b <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0x9eb>
  409256:	b8 00 00 00 00       	mov    $0x0,%eax
  40925b:	48 c7 85 10 f7 ff ff 00 00 7f 43 	movq   $0x437f0000,-0x8f0(%rbp)
  409266:	48 89 85 18 f7 ff ff 	mov    %rax,-0x8e8(%rbp)
  40926d:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409272:	f3 0f 59 05 de 7d 02 00 	mulss  0x27dde(%rip),%xmm0        # 431058 <_IO_stdin_used+0x58>
  40927a:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40927f:	89 c0                	mov    %eax,%eax
  409281:	48 89 85 10 f7 ff ff 	mov    %rax,-0x8f0(%rbp)
  409288:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40928d:	0f 2e 05 90 7d 02 00 	ucomiss 0x27d90(%rip),%xmm0        # 431024 <_IO_stdin_used+0x24>
  409294:	0f 93 c0             	setae  %al
  409297:	0f b6 c0             	movzbl %al,%eax
  40929a:	f3 0f 10 0d b2 7d 02 00 	movss  0x27db2(%rip),%xmm1        # 431054 <_IO_stdin_used+0x54>
  4092a2:	0f 2e c8             	ucomiss %xmm0,%xmm1
  4092a5:	0f 97 c1             	seta   %cl
  4092a8:	0f b6 c9             	movzbl %cl,%ecx
  4092ab:	85 c1                	test   %eax,%ecx
  4092ad:	f3 48 0f 2c c0       	cvttss2si %xmm0,%rax
  4092b2:	89 c0                	mov    %eax,%eax
  4092b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  4092b9:	48 0f 44 c1          	cmove  %rcx,%rax
  4092bd:	41 5f                	pop    %r15
  4092bf:	41 5e                	pop    %r14
  4092c1:	41 5d                	pop    %r13
  4092c3:	41 5c                	pop    %r12
  4092c5:	5b                   	pop    %rbx
  4092c6:	c9                   	leaveq 
  4092c7:	c3                   	retq   
  4092c8:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)

