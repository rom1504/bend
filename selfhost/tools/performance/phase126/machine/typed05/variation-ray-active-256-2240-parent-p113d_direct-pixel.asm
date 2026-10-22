0000000000409c20 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_>:
  409c20:	f3 0f 1e fa          	endbr64 
  409c24:	55                   	push   %rbp
  409c25:	48 89 e5             	mov    %rsp,%rbp
  409c28:	48 81 ec a8 09 00 00 	sub    $0x9a8,%rsp
  409c2f:	53                   	push   %rbx
  409c30:	41 54                	push   %r12
  409c32:	41 55                	push   %r13
  409c34:	41 56                	push   %r14
  409c36:	41 57                	push   %r15
  409c38:	4d 89 c7             	mov    %r8,%r15
  409c3b:	48 89 cb             	mov    %rcx,%rbx
  409c3e:	4c 89 bd 70 ff ff ff 	mov    %r15,-0x90(%rbp)
  409c45:	48 89 b5 60 f6 ff ff 	mov    %rsi,-0x9a0(%rbp)
  409c4c:	89 f0                	mov    %esi,%eax
  409c4e:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  409c53:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409c58:	89 c6                	mov    %eax,%esi
  409c5a:	48 89 b5 08 ff ff ff 	mov    %rsi,-0xf8(%rbp)
  409c61:	48 89 95 60 f6 ff ff 	mov    %rdx,-0x9a0(%rbp)
  409c68:	89 d0                	mov    %edx,%eax
  409c6a:	f3 48 0f 2a c0       	cvtsi2ss %rax,%xmm0
  409c6f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409c74:	41 89 c1             	mov    %eax,%r9d
  409c77:	4c 89 8d 10 ff ff ff 	mov    %r9,-0xf0(%rbp)
  409c7e:	48 89 b5 60 f6 ff ff 	mov    %rsi,-0x9a0(%rbp)
  409c85:	48 c7 85 68 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x998(%rbp)
  409c90:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  409c95:	f3 0f 11 45 d8       	movss  %xmm0,-0x28(%rbp)
  409c9a:	f3 0f 58 05 96 83 02 00 	addss  0x28396(%rip),%xmm0        # 432038 <_IO_stdin_used+0x38>
  409ca2:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409ca7:	89 c2                	mov    %eax,%edx
  409ca9:	48 89 55 80          	mov    %rdx,-0x80(%rbp)
  409cad:	48 89 95 60 f6 ff ff 	mov    %rdx,-0x9a0(%rbp)
  409cb4:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  409cbb:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409cc0:	66 48 0f 6e d3       	movq   %rbx,%xmm2
  409cc5:	f3 0f 11 95 7c ff ff ff 	movss  %xmm2,-0x84(%rbp)
  409ccd:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  409cd1:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409cd6:	89 c0                	mov    %eax,%eax
  409cd8:	48 89 45 88          	mov    %rax,-0x78(%rbp)
  409cdc:	48 89 85 60 f6 ff ff 	mov    %rax,-0x9a0(%rbp)
  409ce3:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  409cea:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409cef:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  409cf3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409cf8:	41 89 c4             	mov    %eax,%r12d
  409cfb:	4c 89 8d 60 f6 ff ff 	mov    %r9,-0x9a0(%rbp)
  409d02:	48 c7 85 68 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x998(%rbp)
  409d0d:	66 49 0f 6e d9       	movq   %r9,%xmm3
  409d12:	f3 0f 11 5d 98       	movss  %xmm3,-0x68(%rbp)
  409d17:	f3 0f 10 c3          	movss  %xmm3,%xmm0
  409d1b:	f3 0f 58 05 15 83 02 00 	addss  0x28315(%rip),%xmm0        # 432038 <_IO_stdin_used+0x38>
  409d23:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409d28:	89 c2                	mov    %eax,%edx
  409d2a:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  409d2e:	4c 89 bd 60 f6 ff ff 	mov    %r15,-0x9a0(%rbp)
  409d35:	48 89 95 68 f6 ff ff 	mov    %rdx,-0x998(%rbp)
  409d3c:	66 49 0f 6e cf       	movq   %r15,%xmm1
  409d41:	f3 0f 11 4d 9c       	movss  %xmm1,-0x64(%rbp)
  409d46:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  409d4b:	0f 57 05 be 82 02 00 	xorps  0x282be(%rip),%xmm0        # 432010 <_IO_stdin_used+0x10>
  409d52:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409d56:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409d5b:	89 c1                	mov    %eax,%ecx
  409d5d:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
  409d61:	48 89 8d 60 f6 ff ff 	mov    %rcx,-0x9a0(%rbp)
  409d68:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  409d6f:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409d74:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  409d78:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409d7d:	41 89 c5             	mov    %eax,%r13d
  409d80:	4c 89 a5 60 fe ff ff 	mov    %r12,-0x1a0(%rbp)
  409d87:	4c 89 a5 68 fe ff ff 	mov    %r12,-0x198(%rbp)
  409d8e:	66 49 0f 6e d4       	movq   %r12,%xmm2
  409d93:	f3 0f 11 95 78 ff ff ff 	movss  %xmm2,-0x88(%rbp)
  409d9b:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  409d9f:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  409da3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409da8:	89 c1                	mov    %eax,%ecx
  409daa:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
  409dae:	4c 89 ad 60 fe ff ff 	mov    %r13,-0x1a0(%rbp)
  409db5:	4c 89 ad 68 fe ff ff 	mov    %r13,-0x198(%rbp)
  409dbc:	66 49 0f 6e cd       	movq   %r13,%xmm1
  409dc1:	f3 0f 11 4d a4       	movss  %xmm1,-0x5c(%rbp)
  409dc6:	f3 0f 10 c1          	movss  %xmm1,%xmm0
  409dca:	f3 0f 59 c1          	mulss  %xmm1,%xmm0
  409dce:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409dd3:	89 c0                	mov    %eax,%eax
  409dd5:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  409dd9:	48 89 8d 60 fe ff ff 	mov    %rcx,-0x1a0(%rbp)
  409de0:	48 89 85 68 fe ff ff 	mov    %rax,-0x198(%rbp)
  409de7:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  409dec:	f3 0f 11 45 a0       	movss  %xmm0,-0x60(%rbp)
  409df1:	66 48 0f 6e c8       	movq   %rax,%xmm1
  409df6:	f3 0f 11 4d dc       	movss  %xmm1,-0x24(%rbp)
  409dfb:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  409dff:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409e04:	89 c0                	mov    %eax,%eax
  409e06:	48 c7 85 60 fe ff ff 01 00 00 00 	movq   $0x1,-0x1a0(%rbp)
  409e11:	48 89 85 60 fe ff ff 	mov    %rax,-0x1a0(%rbp)
  409e18:	48 c7 85 68 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x198(%rbp)
  409e23:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409e28:	f3 0f 58 05 f0 81 02 00 	addss  0x281f0(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  409e30:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409e35:	89 c0                	mov    %eax,%eax
  409e37:	48 89 85 60 fe ff ff 	mov    %rax,-0x1a0(%rbp)
  409e3e:	b9 01 00 00 00       	mov    $0x1,%ecx
  409e43:	48 8d 95 60 fe ff ff 	lea    -0x1a0(%rbp),%rdx
  409e4a:	be 24 00 00 00       	mov    $0x24,%esi
  409e4f:	49 89 fe             	mov    %rdi,%r14
  409e52:	e8 69 2a 02 00       	callq  42c8c0 <p111_rt_op>
  409e57:	4d 89 f8             	mov    %r15,%r8
  409e5a:	4c 89 f7             	mov    %r14,%rdi
  409e5d:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  409e62:	f3 0f 10 95 78 ff ff ff 	movss  -0x88(%rbp),%xmm2
  409e6a:	4c 89 a5 60 fe ff ff 	mov    %r12,-0x1a0(%rbp)
  409e71:	48 89 85 68 fe ff ff 	mov    %rax,-0x198(%rbp)
  409e78:	66 48 0f 6e c0       	movq   %rax,%xmm0
  409e7d:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  409e81:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  409e86:	89 ce                	mov    %ecx,%esi
  409e88:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  409e8c:	4c 89 ad 60 fe ff ff 	mov    %r13,-0x1a0(%rbp)
  409e93:	48 89 85 68 fe ff ff 	mov    %rax,-0x198(%rbp)
  409e9a:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  409e9e:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  409ea3:	41 89 c9             	mov    %ecx,%r9d
  409ea6:	4c 89 4d e8          	mov    %r9,-0x18(%rbp)
  409eaa:	48 c7 85 60 fe ff ff 01 00 00 00 	movq   $0x1,-0x1a0(%rbp)
  409eb5:	48 c7 85 60 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x1a0(%rbp)
  409ec0:	48 89 85 68 fe ff ff 	mov    %rax,-0x198(%rbp)
  409ec7:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  409ecc:	f3 0f 10 05 4c 81 02 00 	movss  0x2814c(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  409ed4:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  409ed9:	66 48 0f 7e c0       	movq   %xmm0,%rax
  409ede:	41 89 c2             	mov    %eax,%r10d
  409ee1:	4c 89 55 f0          	mov    %r10,-0x10(%rbp)
  409ee5:	48 c7 85 60 fe ff ff 00 00 00 00 	movq   $0x0,-0x1a0(%rbp)
  409ef0:	48 c7 85 60 fe ff ff 00 00 00 00 	movq   $0x0,-0x1a0(%rbp)
  409efb:	48 c7 85 60 fe ff ff 00 00 00 00 	movq   $0x0,-0x1a0(%rbp)
  409f06:	48 c7 85 60 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x1a0(%rbp)
  409f11:	48 c7 85 60 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x1a0(%rbp)
  409f1c:	48 83 ec 40          	sub    $0x40,%rsp
  409f20:	48 89 e0             	mov    %rsp,%rax
  409f23:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  409f2b:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  409f33:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  409f3b:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  409f43:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  409f4b:	4c 89 50 10          	mov    %r10,0x10(%rax)
  409f4f:	4c 89 48 08          	mov    %r9,0x8(%rax)
  409f53:	48 89 30             	mov    %rsi,(%rax)
  409f56:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  409f5c:	4d 89 c7             	mov    %r8,%r15
  409f5f:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  409f65:	b9 00 00 00 00       	mov    $0x0,%ecx
  409f6a:	ba 09 00 00 00       	mov    $0x9,%edx
  409f6f:	48 8d b5 a0 fe ff ff 	lea    -0x160(%rbp),%rsi
  409f76:	49 89 fe             	mov    %rdi,%r14
  409f79:	e8 62 cb ff ff       	callq  406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  409f7e:	4d 89 f8             	mov    %r15,%r8
  409f81:	4c 89 f7             	mov    %r14,%rdi
  409f84:	4c 8b 55 f0          	mov    -0x10(%rbp),%r10
  409f88:	4c 8b 4d e8          	mov    -0x18(%rbp),%r9
  409f8c:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  409f90:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  409f94:	48 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%rdx
  409f9b:	48 8b 8d a8 fe ff ff 	mov    -0x158(%rbp),%rcx
  409fa2:	4d 89 c7             	mov    %r8,%r15
  409fa5:	4c 8b 85 b0 fe ff ff 	mov    -0x150(%rbp),%r8
  409fac:	48 c7 85 60 fe ff ff 00 00 00 00 	movq   $0x0,-0x1a0(%rbp)
  409fb7:	48 c7 85 60 fe ff ff 00 00 00 00 	movq   $0x0,-0x1a0(%rbp)
  409fc2:	48 c7 85 60 fe ff ff 00 00 00 00 	movq   $0x0,-0x1a0(%rbp)
  409fcd:	48 c7 85 60 fe ff ff 00 00 00 00 	movq   $0x0,-0x1a0(%rbp)
  409fd8:	48 c7 85 60 fe ff ff 01 00 00 00 	movq   $0x1,-0x1a0(%rbp)
  409fe3:	48 83 ec 40          	sub    $0x40,%rsp
  409fe7:	48 89 e0             	mov    %rsp,%rax
  409fea:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  409ff2:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  409ffa:	4c 89 50 20          	mov    %r10,0x20(%rax)
  409ffe:	4c 89 48 18          	mov    %r9,0x18(%rax)
  40a002:	48 89 70 10          	mov    %rsi,0x10(%rax)
  40a006:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40a00e:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  40a015:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40a01b:	be 04 00 00 00       	mov    $0x4,%esi
  40a020:	49 89 fe             	mov    %rdi,%r14
  40a023:	e8 98 d7 ff ff       	callq  4077c0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40a028:	4d 89 f8             	mov    %r15,%r8
  40a02b:	4c 89 f7             	mov    %r14,%rdi
  40a02e:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  40a035:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  40a039:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  40a03d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  40a041:	4c 8b 8d 10 ff ff ff 	mov    -0xf0(%rbp),%r9
  40a048:	48 8b b5 08 ff ff ff 	mov    -0xf8(%rbp),%rsi
  40a04f:	f3 0f 10 4d dc       	movss  -0x24(%rbp),%xmm1
  40a054:	f3 0f 10 95 7c ff ff ff 	movss  -0x84(%rbp),%xmm2
  40a05c:	f3 0f 10 45 d8       	movss  -0x28(%rbp),%xmm0
  40a061:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40a065:	48 89 b5 60 f6 ff ff 	mov    %rsi,-0x9a0(%rbp)
  40a06c:	48 c7 85 68 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x998(%rbp)
  40a077:	f3 0f 58 05 bd 7f 02 00 	addss  0x27fbd(%rip),%xmm0        # 43203c <_IO_stdin_used+0x3c>
  40a07f:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40a084:	41 89 f3             	mov    %esi,%r11d
  40a087:	4c 89 9d 18 ff ff ff 	mov    %r11,-0xe8(%rbp)
  40a08e:	4c 89 9d 60 f6 ff ff 	mov    %r11,-0x9a0(%rbp)
  40a095:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a09c:	66 49 0f 6e c3       	movq   %r11,%xmm0
  40a0a1:	f3 0f 5c c2          	subss  %xmm2,%xmm0
  40a0a5:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40a0aa:	41 89 f2             	mov    %esi,%r10d
  40a0ad:	4c 89 95 20 ff ff ff 	mov    %r10,-0xe0(%rbp)
  40a0b4:	4c 89 95 60 f6 ff ff 	mov    %r10,-0x9a0(%rbp)
  40a0bb:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a0c2:	66 49 0f 6e c2       	movq   %r10,%xmm0
  40a0c7:	f3 0f 5e c2          	divss  %xmm2,%xmm0
  40a0cb:	66 48 0f 7e c6       	movq   %xmm0,%rsi
  40a0d0:	41 89 f6             	mov    %esi,%r14d
  40a0d3:	4c 89 8d 60 f6 ff ff 	mov    %r9,-0x9a0(%rbp)
  40a0da:	48 c7 85 68 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x998(%rbp)
  40a0e5:	4c 89 85 60 f6 ff ff 	mov    %r8,-0x9a0(%rbp)
  40a0ec:	48 89 95 68 f6 ff ff 	mov    %rdx,-0x998(%rbp)
  40a0f3:	48 89 8d 60 f6 ff ff 	mov    %rcx,-0x9a0(%rbp)
  40a0fa:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a101:	4c 89 b5 70 fe ff ff 	mov    %r14,-0x190(%rbp)
  40a108:	4c 89 b5 78 fe ff ff 	mov    %r14,-0x188(%rbp)
  40a10f:	66 49 0f 6e d6       	movq   %r14,%xmm2
  40a114:	f3 0f 11 95 f8 fe ff ff 	movss  %xmm2,-0x108(%rbp)
  40a11c:	f3 0f 10 c2          	movss  %xmm2,%xmm0
  40a120:	f3 0f 59 c2          	mulss  %xmm2,%xmm0
  40a124:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40a129:	89 c9                	mov    %ecx,%ecx
  40a12b:	48 89 8d 38 ff ff ff 	mov    %rcx,-0xc8(%rbp)
  40a132:	4c 89 ad 70 fe ff ff 	mov    %r13,-0x190(%rbp)
  40a139:	4c 89 ad 78 fe ff ff 	mov    %r13,-0x188(%rbp)
  40a140:	48 89 8d 70 fe ff ff 	mov    %rcx,-0x190(%rbp)
  40a147:	48 89 85 78 fe ff ff 	mov    %rax,-0x188(%rbp)
  40a14e:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40a153:	f3 0f 11 85 50 ff ff ff 	movss  %xmm0,-0xb0(%rbp)
  40a15b:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a15f:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a164:	89 c0                	mov    %eax,%eax
  40a166:	48 c7 85 70 fe ff ff 01 00 00 00 	movq   $0x1,-0x190(%rbp)
  40a171:	48 89 85 70 fe ff ff 	mov    %rax,-0x190(%rbp)
  40a178:	48 c7 85 78 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x188(%rbp)
  40a183:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a188:	f3 0f 58 05 90 7e 02 00 	addss  0x27e90(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40a190:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a195:	89 c0                	mov    %eax,%eax
  40a197:	48 89 85 70 fe ff ff 	mov    %rax,-0x190(%rbp)
  40a19e:	b9 01 00 00 00       	mov    $0x1,%ecx
  40a1a3:	48 8d 95 70 fe ff ff 	lea    -0x190(%rbp),%rdx
  40a1aa:	be 24 00 00 00       	mov    $0x24,%esi
  40a1af:	49 89 ff             	mov    %rdi,%r15
  40a1b2:	e8 09 27 02 00       	callq  42c8c0 <p111_rt_op>
  40a1b7:	4c 89 ff             	mov    %r15,%rdi
  40a1ba:	f3 0f 10 95 f8 fe ff ff 	movss  -0x108(%rbp),%xmm2
  40a1c2:	f3 0f 10 4d a4       	movss  -0x5c(%rbp),%xmm1
  40a1c7:	4c 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%r8
  40a1ce:	4c 89 b5 70 fe ff ff 	mov    %r14,-0x190(%rbp)
  40a1d5:	48 89 85 78 fe ff ff 	mov    %rax,-0x188(%rbp)
  40a1dc:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a1e1:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  40a1e5:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a1ea:	89 ce                	mov    %ecx,%esi
  40a1ec:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  40a1f0:	4c 89 ad 70 fe ff ff 	mov    %r13,-0x190(%rbp)
  40a1f7:	48 89 85 78 fe ff ff 	mov    %rax,-0x188(%rbp)
  40a1fe:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  40a202:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a207:	41 89 c9             	mov    %ecx,%r9d
  40a20a:	4c 89 4d b0          	mov    %r9,-0x50(%rbp)
  40a20e:	48 c7 85 70 fe ff ff 01 00 00 00 	movq   $0x1,-0x190(%rbp)
  40a219:	48 c7 85 70 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x190(%rbp)
  40a224:	48 89 85 78 fe ff ff 	mov    %rax,-0x188(%rbp)
  40a22b:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  40a230:	f3 0f 10 05 e8 7d 02 00 	movss  0x27de8(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40a238:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  40a23d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a242:	41 89 c2             	mov    %eax,%r10d
  40a245:	4c 89 55 b8          	mov    %r10,-0x48(%rbp)
  40a249:	48 c7 85 70 fe ff ff 00 00 00 00 	movq   $0x0,-0x190(%rbp)
  40a254:	48 c7 85 70 fe ff ff 00 00 00 00 	movq   $0x0,-0x190(%rbp)
  40a25f:	48 c7 85 70 fe ff ff 00 00 00 00 	movq   $0x0,-0x190(%rbp)
  40a26a:	48 c7 85 70 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x190(%rbp)
  40a275:	48 c7 85 70 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x190(%rbp)
  40a280:	48 83 ec 40          	sub    $0x40,%rsp
  40a284:	48 89 e0             	mov    %rsp,%rax
  40a287:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  40a28f:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  40a297:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  40a29f:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  40a2a7:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  40a2af:	4c 89 50 10          	mov    %r10,0x10(%rax)
  40a2b3:	4c 89 48 08          	mov    %r9,0x8(%rax)
  40a2b7:	48 89 30             	mov    %rsi,(%rax)
  40a2ba:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40a2c0:	4d 89 c7             	mov    %r8,%r15
  40a2c3:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40a2c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  40a2ce:	ba 09 00 00 00       	mov    $0x9,%edx
  40a2d3:	48 8d b5 a0 fe ff ff 	lea    -0x160(%rbp),%rsi
  40a2da:	49 89 fd             	mov    %rdi,%r13
  40a2dd:	e8 fe c7 ff ff       	callq  406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40a2e2:	4d 89 f8             	mov    %r15,%r8
  40a2e5:	4c 89 ef             	mov    %r13,%rdi
  40a2e8:	4c 8b 55 b8          	mov    -0x48(%rbp),%r10
  40a2ec:	4c 8b 4d b0          	mov    -0x50(%rbp),%r9
  40a2f0:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40a2f4:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40a2f8:	48 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%rdx
  40a2ff:	48 8b 8d a8 fe ff ff 	mov    -0x158(%rbp),%rcx
  40a306:	4d 89 c7             	mov    %r8,%r15
  40a309:	4c 8b 85 b0 fe ff ff 	mov    -0x150(%rbp),%r8
  40a310:	48 c7 85 70 fe ff ff 00 00 00 00 	movq   $0x0,-0x190(%rbp)
  40a31b:	48 c7 85 70 fe ff ff 00 00 00 00 	movq   $0x0,-0x190(%rbp)
  40a326:	48 c7 85 70 fe ff ff 00 00 00 00 	movq   $0x0,-0x190(%rbp)
  40a331:	48 c7 85 70 fe ff ff 00 00 00 00 	movq   $0x0,-0x190(%rbp)
  40a33c:	48 c7 85 70 fe ff ff 01 00 00 00 	movq   $0x1,-0x190(%rbp)
  40a347:	48 83 ec 40          	sub    $0x40,%rsp
  40a34b:	48 89 e0             	mov    %rsp,%rax
  40a34e:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  40a356:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  40a35e:	4c 89 50 20          	mov    %r10,0x20(%rax)
  40a362:	4c 89 48 18          	mov    %r9,0x18(%rax)
  40a366:	48 89 70 10          	mov    %rsi,0x10(%rax)
  40a36a:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40a372:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  40a379:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40a37f:	be 04 00 00 00       	mov    $0x4,%esi
  40a384:	49 89 fd             	mov    %rdi,%r13
  40a387:	e8 34 d4 ff ff       	callq  4077c0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40a38c:	4d 89 f8             	mov    %r15,%r8
  40a38f:	4c 89 ef             	mov    %r13,%rdi
  40a392:	48 89 85 00 ff ff ff 	mov    %rax,-0x100(%rbp)
  40a399:	48 8b 4d 90          	mov    -0x70(%rbp),%rcx
  40a39d:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  40a3a1:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  40a3a5:	4c 8b 8d 10 ff ff ff 	mov    -0xf0(%rbp),%r9
  40a3ac:	48 8b b5 08 ff ff ff 	mov    -0xf8(%rbp),%rsi
  40a3b3:	f3 0f 10 45 a0       	movss  -0x60(%rbp),%xmm0
  40a3b8:	f3 0f 10 4d 9c       	movss  -0x64(%rbp),%xmm1
  40a3bd:	f3 0f 10 5d 98       	movss  -0x68(%rbp),%xmm3
  40a3c2:	f3 0f 10 95 7c ff ff ff 	movss  -0x84(%rbp),%xmm2
  40a3ca:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40a3ce:	48 89 b5 60 f6 ff ff 	mov    %rsi,-0x9a0(%rbp)
  40a3d5:	48 c7 85 68 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x998(%rbp)
  40a3e0:	48 89 95 60 f6 ff ff 	mov    %rdx,-0x9a0(%rbp)
  40a3e7:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a3ee:	48 89 85 60 f6 ff ff 	mov    %rax,-0x9a0(%rbp)
  40a3f5:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a3fc:	4c 89 8d 60 f6 ff ff 	mov    %r9,-0x9a0(%rbp)
  40a403:	48 c7 85 68 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x998(%rbp)
  40a40e:	f3 0f 58 1d 26 7c 02 00 	addss  0x27c26(%rip),%xmm3        # 43203c <_IO_stdin_used+0x3c>
  40a416:	66 48 0f 7e d8       	movq   %xmm3,%rax
  40a41b:	89 c6                	mov    %eax,%esi
  40a41d:	48 89 b5 28 ff ff ff 	mov    %rsi,-0xd8(%rbp)
  40a424:	4c 89 85 60 f6 ff ff 	mov    %r8,-0x9a0(%rbp)
  40a42b:	48 89 b5 68 f6 ff ff 	mov    %rsi,-0x998(%rbp)
  40a432:	66 48 0f 6e de       	movq   %rsi,%xmm3
  40a437:	f3 0f 5c cb          	subss  %xmm3,%xmm1
  40a43b:	66 48 0f 7e c8       	movq   %xmm1,%rax
  40a440:	89 c2                	mov    %eax,%edx
  40a442:	48 89 95 30 ff ff ff 	mov    %rdx,-0xd0(%rbp)
  40a449:	48 89 95 60 f6 ff ff 	mov    %rdx,-0x9a0(%rbp)
  40a450:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a457:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  40a45c:	f3 0f 5e ca          	divss  %xmm2,%xmm1
  40a460:	66 48 0f 7e c8       	movq   %xmm1,%rax
  40a465:	41 89 c7             	mov    %eax,%r15d
  40a468:	4c 89 a5 80 fe ff ff 	mov    %r12,-0x180(%rbp)
  40a46f:	4c 89 a5 88 fe ff ff 	mov    %r12,-0x178(%rbp)
  40a476:	4c 89 bd 80 fe ff ff 	mov    %r15,-0x180(%rbp)
  40a47d:	4c 89 bd 88 fe ff ff 	mov    %r15,-0x178(%rbp)
  40a484:	66 49 0f 6e cf       	movq   %r15,%xmm1
  40a489:	f3 0f 11 8d fc fe ff ff 	movss  %xmm1,-0x104(%rbp)
  40a491:	f3 0f 59 c9          	mulss  %xmm1,%xmm1
  40a495:	66 48 0f 7e c8       	movq   %xmm1,%rax
  40a49a:	89 c0                	mov    %eax,%eax
  40a49c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  40a4a3:	48 89 8d 80 fe ff ff 	mov    %rcx,-0x180(%rbp)
  40a4aa:	48 89 85 88 fe ff ff 	mov    %rax,-0x178(%rbp)
  40a4b1:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40a4b6:	f3 0f 11 8d 54 ff ff ff 	movss  %xmm1,-0xac(%rbp)
  40a4be:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a4c2:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a4c7:	89 c0                	mov    %eax,%eax
  40a4c9:	48 c7 85 80 fe ff ff 01 00 00 00 	movq   $0x1,-0x180(%rbp)
  40a4d4:	48 89 85 80 fe ff ff 	mov    %rax,-0x180(%rbp)
  40a4db:	48 c7 85 88 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x178(%rbp)
  40a4e6:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a4eb:	f3 0f 58 05 2d 7b 02 00 	addss  0x27b2d(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40a4f3:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a4f8:	89 c0                	mov    %eax,%eax
  40a4fa:	48 89 85 80 fe ff ff 	mov    %rax,-0x180(%rbp)
  40a501:	b9 01 00 00 00       	mov    $0x1,%ecx
  40a506:	48 8d 95 80 fe ff ff 	lea    -0x180(%rbp),%rdx
  40a50d:	be 24 00 00 00       	mov    $0x24,%esi
  40a512:	49 89 fd             	mov    %rdi,%r13
  40a515:	e8 a6 23 02 00       	callq  42c8c0 <p111_rt_op>
  40a51a:	4c 89 ef             	mov    %r13,%rdi
  40a51d:	f3 0f 10 8d fc fe ff ff 	movss  -0x104(%rbp),%xmm1
  40a525:	f3 0f 10 95 78 ff ff ff 	movss  -0x88(%rbp),%xmm2
  40a52d:	4c 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%r8
  40a534:	4c 89 a5 80 fe ff ff 	mov    %r12,-0x180(%rbp)
  40a53b:	48 89 85 88 fe ff ff 	mov    %rax,-0x178(%rbp)
  40a542:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a547:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  40a54b:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a550:	89 ce                	mov    %ecx,%esi
  40a552:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  40a559:	4c 89 bd 80 fe ff ff 	mov    %r15,-0x180(%rbp)
  40a560:	48 89 85 88 fe ff ff 	mov    %rax,-0x178(%rbp)
  40a567:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  40a56b:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a570:	41 89 c9             	mov    %ecx,%r9d
  40a573:	4c 89 8d 60 ff ff ff 	mov    %r9,-0xa0(%rbp)
  40a57a:	48 c7 85 80 fe ff ff 01 00 00 00 	movq   $0x1,-0x180(%rbp)
  40a585:	48 c7 85 80 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x180(%rbp)
  40a590:	48 89 85 88 fe ff ff 	mov    %rax,-0x178(%rbp)
  40a597:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  40a59c:	f3 0f 10 05 7c 7a 02 00 	movss  0x27a7c(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40a5a4:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  40a5a9:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a5ae:	41 89 c2             	mov    %eax,%r10d
  40a5b1:	4c 89 95 68 ff ff ff 	mov    %r10,-0x98(%rbp)
  40a5b8:	48 c7 85 80 fe ff ff 00 00 00 00 	movq   $0x0,-0x180(%rbp)
  40a5c3:	48 c7 85 80 fe ff ff 00 00 00 00 	movq   $0x0,-0x180(%rbp)
  40a5ce:	48 c7 85 80 fe ff ff 00 00 00 00 	movq   $0x0,-0x180(%rbp)
  40a5d9:	48 c7 85 80 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x180(%rbp)
  40a5e4:	48 c7 85 80 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x180(%rbp)
  40a5ef:	48 83 ec 40          	sub    $0x40,%rsp
  40a5f3:	48 89 e0             	mov    %rsp,%rax
  40a5f6:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  40a5fe:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  40a606:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  40a60e:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  40a616:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  40a61e:	4c 89 50 10          	mov    %r10,0x10(%rax)
  40a622:	4c 89 48 08          	mov    %r9,0x8(%rax)
  40a626:	48 89 30             	mov    %rsi,(%rax)
  40a629:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40a62f:	4d 89 c5             	mov    %r8,%r13
  40a632:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40a638:	b9 00 00 00 00       	mov    $0x0,%ecx
  40a63d:	ba 09 00 00 00       	mov    $0x9,%edx
  40a642:	48 8d b5 a0 fe ff ff 	lea    -0x160(%rbp),%rsi
  40a649:	49 89 fc             	mov    %rdi,%r12
  40a64c:	e8 8f c4 ff ff       	callq  406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40a651:	4d 89 e8             	mov    %r13,%r8
  40a654:	4c 89 e7             	mov    %r12,%rdi
  40a657:	4c 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%r10
  40a65e:	4c 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%r9
  40a665:	48 8b b5 58 ff ff ff 	mov    -0xa8(%rbp),%rsi
  40a66c:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40a670:	48 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%rdx
  40a677:	48 8b 8d a8 fe ff ff 	mov    -0x158(%rbp),%rcx
  40a67e:	4d 89 c5             	mov    %r8,%r13
  40a681:	4c 8b 85 b0 fe ff ff 	mov    -0x150(%rbp),%r8
  40a688:	48 c7 85 80 fe ff ff 00 00 00 00 	movq   $0x0,-0x180(%rbp)
  40a693:	48 c7 85 80 fe ff ff 00 00 00 00 	movq   $0x0,-0x180(%rbp)
  40a69e:	48 c7 85 80 fe ff ff 00 00 00 00 	movq   $0x0,-0x180(%rbp)
  40a6a9:	48 c7 85 80 fe ff ff 00 00 00 00 	movq   $0x0,-0x180(%rbp)
  40a6b4:	48 c7 85 80 fe ff ff 01 00 00 00 	movq   $0x1,-0x180(%rbp)
  40a6bf:	48 83 ec 40          	sub    $0x40,%rsp
  40a6c3:	48 89 e0             	mov    %rsp,%rax
  40a6c6:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  40a6ce:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  40a6d6:	4c 89 50 20          	mov    %r10,0x20(%rax)
  40a6da:	4c 89 48 18          	mov    %r9,0x18(%rax)
  40a6de:	48 89 70 10          	mov    %rsi,0x10(%rax)
  40a6e2:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40a6ea:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  40a6f1:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40a6f7:	be 04 00 00 00       	mov    $0x4,%esi
  40a6fc:	49 89 fc             	mov    %rdi,%r12
  40a6ff:	e8 bc d0 ff ff       	callq  4077c0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40a704:	4d 89 e8             	mov    %r13,%r8
  40a707:	4c 89 e7             	mov    %r12,%rdi
  40a70a:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
  40a711:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
  40a718:	48 8b 8d 38 ff ff ff 	mov    -0xc8(%rbp),%rcx
  40a71f:	48 8b 95 30 ff ff ff 	mov    -0xd0(%rbp),%rdx
  40a726:	48 8b b5 28 ff ff ff 	mov    -0xd8(%rbp),%rsi
  40a72d:	4c 8b 95 20 ff ff ff 	mov    -0xe0(%rbp),%r10
  40a734:	4c 8b 9d 18 ff ff ff 	mov    -0xe8(%rbp),%r11
  40a73b:	4c 8b 8d 10 ff ff ff 	mov    -0xf0(%rbp),%r9
  40a742:	4c 8b a5 08 ff ff ff 	mov    -0xf8(%rbp),%r12
  40a749:	f3 0f 10 8d 54 ff ff ff 	movss  -0xac(%rbp),%xmm1
  40a751:	f3 0f 10 85 50 ff ff ff 	movss  -0xb0(%rbp),%xmm0
  40a759:	4c 8b ad 48 ff ff ff 	mov    -0xb8(%rbp),%r13
  40a760:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40a764:	4c 89 a5 60 f6 ff ff 	mov    %r12,-0x9a0(%rbp)
  40a76b:	4c 8b a5 00 ff ff ff 	mov    -0x100(%rbp),%r12
  40a772:	48 c7 85 68 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x998(%rbp)
  40a77d:	4c 89 9d 60 f6 ff ff 	mov    %r11,-0x9a0(%rbp)
  40a784:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a78b:	4c 89 95 60 f6 ff ff 	mov    %r10,-0x9a0(%rbp)
  40a792:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a799:	4c 89 8d 60 f6 ff ff 	mov    %r9,-0x9a0(%rbp)
  40a7a0:	48 c7 85 68 f6 ff ff 00 00 40 3f 	movq   $0x3f400000,-0x998(%rbp)
  40a7ab:	4c 89 85 60 f6 ff ff 	mov    %r8,-0x9a0(%rbp)
  40a7b2:	48 89 b5 68 f6 ff ff 	mov    %rsi,-0x998(%rbp)
  40a7b9:	48 89 95 60 f6 ff ff 	mov    %rdx,-0x9a0(%rbp)
  40a7c0:	48 89 9d 68 f6 ff ff 	mov    %rbx,-0x998(%rbp)
  40a7c7:	4c 89 b5 90 fe ff ff 	mov    %r14,-0x170(%rbp)
  40a7ce:	4c 89 b5 98 fe ff ff 	mov    %r14,-0x168(%rbp)
  40a7d5:	4c 89 bd 90 fe ff ff 	mov    %r15,-0x170(%rbp)
  40a7dc:	4c 89 bd 98 fe ff ff 	mov    %r15,-0x168(%rbp)
  40a7e3:	48 89 8d 90 fe ff ff 	mov    %rcx,-0x170(%rbp)
  40a7ea:	48 89 85 98 fe ff ff 	mov    %rax,-0x168(%rbp)
  40a7f1:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40a7f5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a7fa:	89 c0                	mov    %eax,%eax
  40a7fc:	48 c7 85 90 fe ff ff 01 00 00 00 	movq   $0x1,-0x170(%rbp)
  40a807:	48 89 85 90 fe ff ff 	mov    %rax,-0x170(%rbp)
  40a80e:	48 c7 85 98 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x168(%rbp)
  40a819:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a81e:	f3 0f 58 05 fa 77 02 00 	addss  0x277fa(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40a826:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a82b:	89 c0                	mov    %eax,%eax
  40a82d:	48 89 85 90 fe ff ff 	mov    %rax,-0x170(%rbp)
  40a834:	b9 01 00 00 00       	mov    $0x1,%ecx
  40a839:	48 8d 95 90 fe ff ff 	lea    -0x170(%rbp),%rdx
  40a840:	be 24 00 00 00       	mov    $0x24,%esi
  40a845:	48 89 fb             	mov    %rdi,%rbx
  40a848:	e8 73 20 02 00       	callq  42c8c0 <p111_rt_op>
  40a84d:	48 89 df             	mov    %rbx,%rdi
  40a850:	48 8b 9d f0 fe ff ff 	mov    -0x110(%rbp),%rbx
  40a857:	f3 0f 10 8d fc fe ff ff 	movss  -0x104(%rbp),%xmm1
  40a85f:	f3 0f 10 95 f8 fe ff ff 	movss  -0x108(%rbp),%xmm2
  40a867:	4c 89 b5 90 fe ff ff 	mov    %r14,-0x170(%rbp)
  40a86e:	48 89 85 98 fe ff ff 	mov    %rax,-0x168(%rbp)
  40a875:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40a87a:	f3 0f 5e d0          	divss  %xmm0,%xmm2
  40a87e:	66 48 0f 7e d1       	movq   %xmm2,%rcx
  40a883:	41 89 ce             	mov    %ecx,%r14d
  40a886:	4c 89 bd 90 fe ff ff 	mov    %r15,-0x170(%rbp)
  40a88d:	48 89 85 98 fe ff ff 	mov    %rax,-0x168(%rbp)
  40a894:	f3 0f 5e c8          	divss  %xmm0,%xmm1
  40a898:	66 48 0f 7e c9       	movq   %xmm1,%rcx
  40a89d:	89 ce                	mov    %ecx,%esi
  40a89f:	48 89 b5 e0 fe ff ff 	mov    %rsi,-0x120(%rbp)
  40a8a6:	48 c7 85 90 fe ff ff 01 00 00 00 	movq   $0x1,-0x170(%rbp)
  40a8b1:	48 c7 85 90 fe ff ff 00 00 80 3f 	movq   $0x3f800000,-0x170(%rbp)
  40a8bc:	48 89 85 98 fe ff ff 	mov    %rax,-0x168(%rbp)
  40a8c3:	f3 44 0f 10 f8       	movss  %xmm0,%xmm15
  40a8c8:	f3 0f 10 05 50 77 02 00 	movss  0x27750(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40a8d0:	f3 41 0f 5e c7       	divss  %xmm15,%xmm0
  40a8d5:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40a8da:	41 89 c1             	mov    %eax,%r9d
  40a8dd:	4c 89 8d e8 fe ff ff 	mov    %r9,-0x118(%rbp)
  40a8e4:	48 c7 85 90 fe ff ff 00 00 00 00 	movq   $0x0,-0x170(%rbp)
  40a8ef:	48 c7 85 90 fe ff ff 00 00 00 00 	movq   $0x0,-0x170(%rbp)
  40a8fa:	48 c7 85 90 fe ff ff 00 00 00 00 	movq   $0x0,-0x170(%rbp)
  40a905:	48 c7 85 90 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x170(%rbp)
  40a910:	48 c7 85 90 fe ff ff 00 ca 9a 3b 	movq   $0x3b9aca00,-0x170(%rbp)
  40a91b:	48 83 ec 40          	sub    $0x40,%rsp
  40a91f:	48 89 e0             	mov    %rsp,%rax
  40a922:	48 c7 40 38 00 00 00 00 	movq   $0x0,0x38(%rax)
  40a92a:	48 c7 40 30 09 00 00 00 	movq   $0x9,0x30(%rax)
  40a932:	48 c7 40 28 28 6b 6e 4e 	movq   $0x4e6e6b28,0x28(%rax)
  40a93a:	48 c7 40 20 09 00 00 00 	movq   $0x9,0x20(%rax)
  40a942:	48 c7 40 18 28 6b 6e 4e 	movq   $0x4e6e6b28,0x18(%rax)
  40a94a:	4c 89 48 10          	mov    %r9,0x10(%rax)
  40a94e:	48 89 70 08          	mov    %rsi,0x8(%rax)
  40a952:	4c 89 30             	mov    %r14,(%rax)
  40a955:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40a95b:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  40a961:	b9 00 00 00 00       	mov    $0x0,%ecx
  40a966:	ba 09 00 00 00       	mov    $0x9,%edx
  40a96b:	48 8d b5 a0 fe ff ff 	lea    -0x160(%rbp),%rsi
  40a972:	49 89 ff             	mov    %rdi,%r15
  40a975:	e8 66 c1 ff ff       	callq  406ae0 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  40a97a:	4c 89 ff             	mov    %r15,%rdi
  40a97d:	4c 8b 8d e8 fe ff ff 	mov    -0x118(%rbp),%r9
  40a984:	48 8b b5 e0 fe ff ff 	mov    -0x120(%rbp),%rsi
  40a98b:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40a98f:	48 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%rdx
  40a996:	48 8b 8d a8 fe ff ff 	mov    -0x158(%rbp),%rcx
  40a99d:	4c 8b 85 b0 fe ff ff 	mov    -0x150(%rbp),%r8
  40a9a4:	48 c7 85 90 fe ff ff 00 00 00 00 	movq   $0x0,-0x170(%rbp)
  40a9af:	48 c7 85 90 fe ff ff 00 00 00 00 	movq   $0x0,-0x170(%rbp)
  40a9ba:	48 c7 85 90 fe ff ff 00 00 00 00 	movq   $0x0,-0x170(%rbp)
  40a9c5:	48 c7 85 90 fe ff ff 00 00 00 00 	movq   $0x0,-0x170(%rbp)
  40a9d0:	48 c7 85 90 fe ff ff 01 00 00 00 	movq   $0x1,-0x170(%rbp)
  40a9db:	48 83 ec 40          	sub    $0x40,%rsp
  40a9df:	48 89 e0             	mov    %rsp,%rax
  40a9e2:	48 c7 40 30 00 00 80 3f 	movq   $0x3f800000,0x30(%rax)
  40a9ea:	48 c7 40 28 00 00 00 00 	movq   $0x0,0x28(%rax)
  40a9f2:	4c 89 48 20          	mov    %r9,0x20(%rax)
  40a9f6:	48 89 70 18          	mov    %rsi,0x18(%rax)
  40a9fa:	4c 89 70 10          	mov    %r14,0x10(%rax)
  40a9fe:	48 c7 40 08 00 00 00 00 	movq   $0x0,0x8(%rax)
  40aa06:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
  40aa0d:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  40aa13:	be 04 00 00 00       	mov    $0x4,%esi
  40aa18:	49 89 fe             	mov    %rdi,%r14
  40aa1b:	e8 a0 cd ff ff       	callq  4077c0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>
  40aa20:	4c 89 f7             	mov    %r14,%rdi
  40aa23:	48 83 ec c0          	sub    $0xffffffffffffffc0,%rsp
  40aa27:	48 c7 85 60 f6 ff ff ff 00 00 00 	movq   $0xff,-0x9a0(%rbp)
  40aa32:	4c 89 ad 60 f6 ff ff 	mov    %r13,-0x9a0(%rbp)
  40aa39:	4c 89 a5 68 f6 ff ff 	mov    %r12,-0x998(%rbp)
  40aa40:	66 49 0f 6e c5       	movq   %r13,%xmm0
  40aa45:	66 49 0f 6e cc       	movq   %r12,%xmm1
  40aa4a:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aa4e:	66 48 0f 7e c1       	movq   %xmm0,%rcx
  40aa53:	89 c9                	mov    %ecx,%ecx
  40aa55:	48 89 9d 60 f6 ff ff 	mov    %rbx,-0x9a0(%rbp)
  40aa5c:	48 89 85 68 f6 ff ff 	mov    %rax,-0x998(%rbp)
  40aa63:	66 48 0f 6e c3       	movq   %rbx,%xmm0
  40aa68:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40aa6d:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aa71:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aa76:	89 c0                	mov    %eax,%eax
  40aa78:	48 89 8d 60 f6 ff ff 	mov    %rcx,-0x9a0(%rbp)
  40aa7f:	48 89 85 68 f6 ff ff 	mov    %rax,-0x998(%rbp)
  40aa86:	66 48 0f 6e c1       	movq   %rcx,%xmm0
  40aa8b:	66 48 0f 6e c8       	movq   %rax,%xmm1
  40aa90:	f3 0f 58 c1          	addss  %xmm1,%xmm0
  40aa94:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aa99:	89 c0                	mov    %eax,%eax
  40aa9b:	48 89 85 60 f6 ff ff 	mov    %rax,-0x9a0(%rbp)
  40aaa2:	48 c7 85 68 f6 ff ff 00 00 80 3e 	movq   $0x3e800000,-0x998(%rbp)
  40aaad:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40aab2:	f3 0f 59 05 7e 75 02 00 	mulss  0x2757e(%rip),%xmm0        # 432038 <_IO_stdin_used+0x38>
  40aaba:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40aabf:	89 c0                	mov    %eax,%eax
  40aac1:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40aac6:	f3 0f 10 0d 56 75 02 00 	movss  0x27556(%rip),%xmm1        # 432024 <_IO_stdin_used+0x24>
  40aace:	0f 2e c8             	ucomiss %xmm0,%xmm1
  40aad1:	0f 97 c1             	seta   %cl
  40aad4:	0f b6 c9             	movzbl %cl,%ecx
  40aad7:	89 ca                	mov    %ecx,%edx
  40aad9:	48 83 fa 01          	cmp    $0x1,%rdx
  40aadd:	0f 94 c1             	sete   %cl
  40aae0:	0f b6 c9             	movzbl %cl,%ecx
  40aae3:	48 c1 ea 28          	shr    $0x28,%rdx
  40aae7:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  40aaee:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  40aaf5:	0f 94 c2             	sete   %dl
  40aaf8:	0f b6 d2             	movzbl %dl,%edx
  40aafb:	09 d1                	or     %edx,%ecx
  40aafd:	75 6a                	jne    40ab69 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xf49>
  40aaff:	83 f1 01             	xor    $0x1,%ecx
  40ab02:	75 11                	jne    40ab15 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xef5>
  40ab04:	be 04 00 00 00       	mov    $0x4,%esi
  40ab09:	e8 92 1d 02 00       	callq  42c8a0 <p111_rt_fail>
  40ab0e:	b8 00 00 00 00       	mov    $0x0,%eax
  40ab13:	eb 59                	jmp    40ab6e <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xf4e>
  40ab15:	0f 2e 05 04 75 02 00 	ucomiss 0x27504(%rip),%xmm0        # 432020 <_IO_stdin_used+0x20>
  40ab1c:	0f 97 c1             	seta   %cl
  40ab1f:	0f b6 c9             	movzbl %cl,%ecx
  40ab22:	89 ca                	mov    %ecx,%edx
  40ab24:	48 83 fa 01          	cmp    $0x1,%rdx
  40ab28:	0f 94 c1             	sete   %cl
  40ab2b:	0f b6 c9             	movzbl %cl,%ecx
  40ab2e:	48 c1 ea 28          	shr    $0x28,%rdx
  40ab32:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  40ab39:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  40ab40:	0f 94 c2             	sete   %dl
  40ab43:	0f b6 d2             	movzbl %dl,%edx
  40ab46:	09 d1                	or     %edx,%ecx
  40ab48:	75 18                	jne    40ab62 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xf42>
  40ab4a:	83 f1 01             	xor    $0x1,%ecx
  40ab4d:	75 1f                	jne    40ab6e <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xf4e>
  40ab4f:	2e 2e be 04 00 00 00 	cs cs mov $0x4,%esi
  40ab56:	e8 45 1d 02 00       	callq  42c8a0 <p111_rt_fail>
  40ab5b:	b8 00 00 00 00       	mov    $0x0,%eax
  40ab60:	eb 0c                	jmp    40ab6e <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xf4e>
  40ab62:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  40ab67:	eb 05                	jmp    40ab6e <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_+0xf4e>
  40ab69:	b8 00 00 00 00       	mov    $0x0,%eax
  40ab6e:	48 c7 85 60 f6 ff ff 00 00 7f 43 	movq   $0x437f0000,-0x9a0(%rbp)
  40ab79:	48 89 85 68 f6 ff ff 	mov    %rax,-0x998(%rbp)
  40ab80:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40ab85:	f3 0f 59 05 b7 74 02 00 	mulss  0x274b7(%rip),%xmm0        # 432044 <_IO_stdin_used+0x44>
  40ab8d:	66 48 0f 7e c0       	movq   %xmm0,%rax
  40ab92:	89 c0                	mov    %eax,%eax
  40ab94:	48 89 85 60 f6 ff ff 	mov    %rax,-0x9a0(%rbp)
  40ab9b:	66 48 0f 6e c0       	movq   %rax,%xmm0
  40aba0:	0f 2e 05 7d 74 02 00 	ucomiss 0x2747d(%rip),%xmm0        # 432024 <_IO_stdin_used+0x24>
  40aba7:	0f 93 c0             	setae  %al
  40abaa:	0f b6 c0             	movzbl %al,%eax
  40abad:	f3 0f 10 0d 8b 74 02 00 	movss  0x2748b(%rip),%xmm1        # 432040 <_IO_stdin_used+0x40>
  40abb5:	0f 2e c8             	ucomiss %xmm0,%xmm1
  40abb8:	0f 97 c1             	seta   %cl
  40abbb:	0f b6 c9             	movzbl %cl,%ecx
  40abbe:	85 c1                	test   %eax,%ecx
  40abc0:	f3 48 0f 2c c0       	cvttss2si %xmm0,%rax
  40abc5:	89 c0                	mov    %eax,%eax
  40abc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  40abcc:	48 0f 44 c1          	cmove  %rcx,%rax
  40abd0:	41 5f                	pop    %r15
  40abd2:	41 5e                	pop    %r14
  40abd4:	41 5d                	pop    %r13
  40abd6:	41 5c                	pop    %r12
  40abd8:	5b                   	pop    %rbx
  40abd9:	c9                   	leaveq 
  40abda:	c3                   	retq   
  40abdb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

