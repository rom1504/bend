
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/variation-ray-active-64-2440/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407bd0 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_>:
  407bd0:	endbr64 
  407bd4:	push   %rbp
  407bd5:	mov    %rsp,%rbp
  407bd8:	sub    $0xd8,%rsp
  407bdf:	push   %rbx
  407be0:	push   %r12
  407be2:	push   %r13
  407be4:	push   %r14
  407be6:	push   %r15
  407be8:	mov    0x40(%rbp),%r15
  407bec:	mov    0x38(%rbp),%rax
  407bf0:	mov    0x30(%rbp),%r10
  407bf4:	mov    %rax,%r11
  407bf7:	mov    0x28(%rbp),%rax
  407bfb:	mov    0x20(%rbp),%r14
  407bff:	mov    0x18(%rbp),%r13
  407c03:	mov    0x10(%rbp),%r12
  407c07:	mov    %r9,%rbx
  407c0a:	xchg   %rcx,%rdx
  407c0d:	xchg   %r8,%rsi
  407c10:	mov    %rdi,-0x50(%rbp)
  407c14:	mov    %rdx,%r9
  407c17:	mov    %r14,%rdx
  407c1a:	mov    %rbx,%r14
  407c1d:	xchg   %rdi,%r15
  407c20:	cs cs cs mov %r13,%rbx
  407c26:	cmp    $0x0,%r8
  407c2a:	mov    %rsi,%r13
  407c2d:	sete   %sil
  407c31:	movzbl %sil,%esi
  407c35:	movq   %r9,%xmm1
  407c3a:	movq   %rdx,%xmm5
  407c3f:	movss  %xmm5,-0x20(%rbp)
  407c44:	movss  %xmm1,%xmm0
  407c48:	mulss  %xmm5,%xmm0
  407c4c:	movq   %r14,%xmm2
  407c51:	movss  %xmm0,%xmm3
  407c55:	addss  %xmm2,%xmm3
  407c59:	movss  %xmm3,-0x78(%rbp)
  407c5e:	mov    %r8,%r14
  407c61:	movq   %xmm3,%r8
  407c66:	movq   %rax,%xmm0
  407c6b:	movss  %xmm0,-0x1c(%rbp)
  407c70:	mulss  %xmm1,%xmm0
  407c74:	movq   %r12,%xmm2
  407c79:	movss  %xmm0,%xmm5
  407c7d:	addss  %xmm2,%xmm5
  407c81:	movss  %xmm5,-0x74(%rbp)
  407c86:	movq   %xmm5,%rdx
  407c8b:	movq   %r10,%xmm0
  407c90:	movss  %xmm0,-0x18(%rbp)
  407c95:	mulss  %xmm1,%xmm0
  407c99:	movq   %rbx,%xmm1
  407c9e:	addss  %xmm0,%xmm1
  407ca2:	movq   %xmm1,%rax
  407ca7:	movss  0x12381(%rip),%xmm2        # 41a030 <_IO_stdin_used+0x30>
  407caf:	subss  %xmm3,%xmm2
  407cb3:	movss  %xmm2,-0x84(%rbp)
  407cbb:	movss  0x12369(%rip),%xmm3        # 41a02c <_IO_stdin_used+0x2c>
  407cc3:	subss  %xmm5,%xmm3
  407cc7:	movss  %xmm3,-0x80(%rbp)
  407ccc:	movss  %xmm2,%xmm0
  407cd0:	movss  0x12348(%rip),%xmm2        # 41a020 <_IO_stdin_used+0x20>
  407cd8:	subss  %xmm1,%xmm2
  407cdc:	movss  %xmm2,-0x7c(%rbp)
  407ce1:	mulss  %xmm0,%xmm0
  407ce5:	mulss  %xmm3,%xmm3
  407ce9:	addss  %xmm3,%xmm0
  407ced:	mulss  %xmm2,%xmm2
  407cf1:	addss  %xmm2,%xmm0
  407cf5:	cvtss2sd %xmm0,%xmm0
  407cf9:	mov    %r8d,%r8d
  407cfc:	movq   %r8,%xmm8
  407d01:	movss  %xmm8,-0x70(%rbp)
  407d07:	mov    %edx,%edx
  407d09:	movq   %rdx,%xmm6
  407d0e:	movss  %xmm6,-0x6c(%rbp)
  407d13:	mov    %eax,%eax
  407d15:	movq   %rax,%xmm4
  407d1a:	movss  %xmm4,-0x68(%rbp)
  407d1f:	movq   %rdi,%xmm2
  407d24:	movss  %xmm2,-0x90(%rbp)
  407d2c:	movq   %r11,%xmm3
  407d31:	movss  %xmm3,-0x8c(%rbp)
  407d39:	cmp    $0x1,%rcx
  407d3d:	mov    %rcx,%rax
  407d40:	sete   %cl
  407d43:	movzbl %cl,%ecx
  407d46:	shr    $0x28,%rax
  407d4a:	and    $0x7fffff,%rax
  407d50:	cmp    $0x10002,%rax
  407d56:	sete   %dl
  407d59:	movzbl %dl,%edx
  407d5c:	mov    %ecx,%eax
  407d5e:	or     %edx,%eax
  407d60:	cmp    $0x0,%esi
  407d63:	jne    4081a6 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x5d6>
  407d69:	or     %edx,%ecx
  407d6b:	jne    40819e <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x5ce>
  407d71:	xor    $0x1,%eax
  407d74:	je     408187 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x5b7>
  407d7a:	cmp    $0x8,%r13
  407d7e:	mov    $0x8,%eax
  407d83:	cmovb  %r13,%rax
  407d87:	mov    %rax,%rcx
  407d8a:	shl    $0x3,%rcx
  407d8e:	lea    0x18573(%rip),%rax        # 420308 <p126s_table_FID_36_100_105_114_101_99_116_46_115_114_>
  407d95:	mov    (%rax,%rcx,1),%rax
  407d99:	cmp    $0x8,%r13
  407d9d:	mov    $0x8,%ecx
  407da2:	cmovb  %r13,%rcx
  407da6:	mov    %rcx,%rdx
  407da9:	shl    $0x3,%rdx
  407dad:	lea    0x1862c(%rip),%rcx        # 4203e0 <p126s_table_FID_36_100_105_114_101_99_116_46_115_120_>
  407db4:	mov    (%rcx,%rdx,1),%r12
  407db8:	cmp    $0x8,%r13
  407dbc:	mov    $0x8,%ecx
  407dc1:	cmovb  %r13,%rcx
  407dc5:	mov    %rcx,%rdx
  407dc8:	shl    $0x3,%rdx
  407dcc:	lea    0x185c5(%rip),%rcx        # 420398 <p126s_table_FID_36_100_105_114_101_99_116_46_115_121_>
  407dd3:	mov    (%rcx,%rdx,1),%rbx
  407dd7:	cmp    $0x8,%r13
  407ddb:	mov    $0x8,%ecx
  407de0:	cmovb  %r13,%rcx
  407de4:	mov    %rcx,%rdx
  407de7:	shl    $0x3,%rdx
  407deb:	lea    0x1855e(%rip),%rcx        # 420350 <p126s_table_FID_36_100_105_114_101_99_116_46_115_122_>
  407df2:	mov    (%rcx,%rdx,1),%rcx
  407df6:	movq   %rcx,%xmm2
  407dfb:	subss  %xmm2,%xmm1
  407dff:	movq   %rax,%xmm9
  407e04:	movss  %xmm9,-0x14(%rbp)
  407e0a:	divss  %xmm9,%xmm1
  407e0f:	movq   %xmm1,%rax
  407e14:	mov    %eax,%ecx
  407e16:	mov    %rcx,-0x10(%rbp)
  407e1a:	callq  402500 <sqrt@plt>
  407e1f:	mov    %r15,%rax
  407e22:	mov    %r14,%r8
  407e25:	mov    %r13,%rsi
  407e28:	movsd  %xmm0,%xmm7
  407e2c:	movss  -0x74(%rbp),%xmm5
  407e31:	movss  -0x78(%rbp),%xmm3
  407e36:	mov    -0x10(%rbp),%rcx
  407e3a:	movss  -0x68(%rbp),%xmm4
  407e3f:	movss  -0x6c(%rbp),%xmm6
  407e44:	movss  -0x70(%rbp),%xmm8
  407e4a:	movss  -0x7c(%rbp),%xmm0
  407e4f:	movss  -0x80(%rbp),%xmm1
  407e54:	movss  -0x84(%rbp),%xmm2
  407e5c:	movss  -0x14(%rbp),%xmm9
  407e62:	cvtsd2ss %xmm7,%xmm7
  407e66:	movss  %xmm7,-0x30(%rbp)
  407e6b:	divss  %xmm7,%xmm2
  407e6f:	divss  %xmm7,%xmm1
  407e73:	divss  %xmm7,%xmm0
  407e77:	movq   %r12,%xmm7
  407e7c:	subss  %xmm7,%xmm3
  407e80:	divss  %xmm9,%xmm3
  407e85:	movq   %xmm3,%rdx
  407e8a:	mov    %edx,%edx
  407e8c:	movq   %rdx,%xmm7
  407e91:	movss  %xmm7,-0x2c(%rbp)
  407e96:	movss  %xmm2,%xmm3
  407e9a:	mulss  %xmm7,%xmm3
  407e9e:	movq   %rbx,%xmm10
  407ea3:	subss  %xmm10,%xmm5
  407ea8:	divss  %xmm9,%xmm5
  407ead:	movq   %xmm5,%rdx
  407eb2:	mov    %edx,%edx
  407eb4:	movq   %rdx,%xmm5
  407eb9:	movss  %xmm5,-0x28(%rbp)
  407ebe:	movss  %xmm1,%xmm9
  407ec3:	mulss  %xmm5,%xmm9
  407ec8:	addss  %xmm3,%xmm9
  407ecd:	movq   %rcx,%xmm3
  407ed2:	movss  %xmm3,-0x24(%rbp)
  407ed7:	movss  %xmm0,%xmm10
  407edc:	mulss  %xmm3,%xmm10
  407ee1:	addss  %xmm10,%xmm9
  407ee6:	movss  0x12135(%rip),%xmm10        # 41a024 <_IO_stdin_used+0x24>
  407eef:	ucomiss %xmm9,%xmm10
  407ef3:	seta   %cl
  407ef6:	movzbl %cl,%ecx
  407ef9:	mov    %ecx,%ecx
  407efb:	movq   %xmm9,%rdx
  407f00:	mov    %edx,%edx
  407f02:	cmp    $0x1,%rcx
  407f06:	mov    $0x0,%ecx
  407f0b:	cmove  %rcx,%rdx
  407f0f:	mov    %rdx,-0x38(%rbp)
  407f13:	mulss  0x1210d(%rip),%xmm7        # 41a028 <_IO_stdin_used+0x28>
  407f1b:	addss  %xmm8,%xmm7
  407f20:	movq   %xmm7,%rcx
  407f25:	mov    %ecx,%ebx
  407f27:	mulss  0x120f9(%rip),%xmm5        # 41a028 <_IO_stdin_used+0x28>
  407f2f:	addss  %xmm6,%xmm5
  407f33:	movq   %xmm5,%rcx
  407f38:	mov    %ecx,%r12d
  407f3b:	mulss  0x120e5(%rip),%xmm3        # 41a028 <_IO_stdin_used+0x28>
  407f43:	addss  %xmm4,%xmm3
  407f47:	movq   %xmm3,%rcx
  407f4c:	mov    %ecx,%r13d
  407f4f:	movq   %xmm2,%rcx
  407f54:	mov    %ecx,%r9d
  407f57:	movq   %xmm1,%rcx
  407f5c:	mov    %ecx,%ecx
  407f5e:	movq   %xmm0,%rdx
  407f63:	mov    %edx,%edi
  407f65:	sub    $0x30,%rsp
  407f69:	mov    %rsp,%rdx
  407f6c:	movq   $0x0,0x20(%rdx)
  407f74:	movq   $0x4e6e6b28,0x18(%rdx)
  407f7c:	movq   $0x4e6e6b28,0x10(%rdx)
  407f84:	mov    %rdi,0x8(%rdx)
  407f88:	mov    %rcx,(%rdx)
  407f8b:	mov    %r8,%r15
  407f8e:	mov    %r13,%r8
  407f91:	mov    %r12,%rcx
  407f94:	mov    %rbx,%rdx
  407f97:	mov    %rsi,%r14
  407f9a:	mov    $0x9,%esi
  407f9f:	mov    %rax,%rdi
  407fa2:	callq  4077b0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  407fa7:	mov    %r15,%r8
  407faa:	mov    %r14,%rsi
  407fad:	mov    %rax,%rcx
  407fb0:	mov    -0x38(%rbp),%rdx
  407fb4:	movss  -0x24(%rbp),%xmm1
  407fb9:	movss  -0x28(%rbp),%xmm4
  407fbe:	movss  -0x2c(%rbp),%xmm6
  407fc3:	movss  -0x30(%rbp),%xmm7
  407fc8:	movss  -0x18(%rbp),%xmm0
  407fcd:	movss  -0x1c(%rbp),%xmm3
  407fd2:	movss  -0x20(%rbp),%xmm5
  407fd7:	mov    -0x50(%rbp),%rax
  407fdb:	sub    $0xffffffffffffffd0,%rsp
  407fdf:	movq   %rcx,%xmm2
  407fe4:	movq   %xmm7,%rcx
  407fe9:	mov    %ecx,%ecx
  407feb:	movq   %rcx,%xmm7
  407ff0:	ucomiss %xmm2,%xmm7
  407ff3:	seta   %cl
  407ff6:	movzbl %cl,%ecx
  407ff9:	mov    %ecx,%ecx
  407ffb:	cmp    $0x1,%rcx
  407fff:	mov    $0x0,%ecx
  408004:	mov    %rcx,%r9
  408007:	cmovne %rdx,%r9
  40800b:	mov    %r9,-0x40(%rbp)
  40800f:	cmp    $0x8,%rsi
  408013:	mov    $0x8,%ecx
  408018:	cmovb  %rsi,%rcx
  40801c:	mov    %rcx,%rdx
  40801f:	shl    $0x3,%rdx
  408023:	lea    0x18296(%rip),%rcx        # 4202c0 <p126s_table_FID_36_100_105_114_101_99_116_46_115_107_114_>
  40802a:	mov    (%rcx,%rdx,1),%rdi
  40802e:	mov    %rdi,-0x48(%rbp)
  408032:	movss  %xmm5,%xmm2
  408036:	mulss  %xmm6,%xmm2
  40803a:	movss  %xmm3,%xmm7
  40803e:	mulss  %xmm4,%xmm7
  408042:	addss  %xmm7,%xmm2
  408046:	movss  %xmm0,%xmm7
  40804a:	mulss  %xmm1,%xmm7
  40804e:	addss  %xmm7,%xmm2
  408052:	mulss  0x11fe2(%rip),%xmm2        # 41a03c <_IO_stdin_used+0x3c>
  40805a:	mulss  %xmm2,%xmm6
  40805e:	subss  %xmm6,%xmm5
  408062:	movq   %xmm5,%rcx
  408067:	mov    %ecx,%r14d
  40806a:	mulss  %xmm2,%xmm4
  40806e:	subss  %xmm4,%xmm3
  408072:	movq   %xmm3,%rcx
  408077:	mov    %ecx,%r10d
  40807a:	mov    %r10,-0x60(%rbp)
  40807e:	mulss  %xmm2,%xmm1
  408082:	subss  %xmm1,%xmm0
  408086:	movq   %xmm0,%rcx
  40808b:	mov    %ecx,%r11d
  40808e:	mov    %r11,-0x58(%rbp)
  408092:	sub    $0x40,%rsp
  408096:	mov    %rsp,%rcx
  408099:	movq   $0x0,0x38(%rcx)
  4080a1:	movq   $0x9,0x30(%rcx)
  4080a9:	movq   $0x4e6e6b28,0x28(%rcx)
  4080b1:	movq   $0x9,0x20(%rcx)
  4080b9:	movq   $0x4e6e6b28,0x18(%rcx)
  4080c1:	mov    %r11,0x10(%rcx)
  4080c5:	mov    %r10,0x8(%rcx)
  4080c9:	mov    %r14,(%rcx)
  4080cc:	mov    %r13,%r9
  4080cf:	mov    %r8,%r15
  4080d2:	mov    %r12,%r8
  4080d5:	mov    %rbx,%rcx
  4080d8:	mov    $0x9,%edx
  4080dd:	lea    -0xd0(%rbp),%rsi
  4080e4:	mov    %rax,%rdi
  4080e7:	callq  407000 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>
  4080ec:	mov    %r15,%r8
  4080ef:	mov    -0x40(%rbp),%r9
  4080f3:	mov    -0x58(%rbp),%r10
  4080f7:	mov    -0x60(%rbp),%rax
  4080fb:	movss  -0x8c(%rbp),%xmm3
  408103:	movss  -0x90(%rbp),%xmm0
  40810b:	mov    -0x48(%rbp),%rdi
  40810f:	mov    -0x50(%rbp),%r15
  408113:	sub    $0xffffffffffffffc0,%rsp
  408117:	mov    -0xd0(%rbp),%rcx
  40811e:	mov    -0xc8(%rbp),%rdx
  408125:	mov    -0xc0(%rbp),%rsi
  40812c:	movq   %r9,%xmm1
  408131:	mulss  0x11eff(%rip),%xmm1        # 41a038 <_IO_stdin_used+0x38>
  408139:	addss  0x11ef3(%rip),%xmm1        # 41a034 <_IO_stdin_used+0x34>
  408141:	movss  %xmm0,%xmm2
  408145:	mulss  %xmm1,%xmm2
  408149:	movq   %rdi,%xmm1
  40814e:	movss  0x11eca(%rip),%xmm4        # 41a020 <_IO_stdin_used+0x20>
  408156:	subss  %xmm1,%xmm4
  40815a:	mulss  %xmm4,%xmm2
  40815e:	addss  %xmm3,%xmm2
  408162:	movq   %xmm2,%rdi
  408167:	mov    %edi,%r11d
  40816a:	mulss  %xmm1,%xmm0
  40816e:	movq   %xmm0,%rdi
  408173:	mov    %edi,%edi
  408175:	sub    $0x1,%r8
  408179:	mov    %rdx,%r9
  40817c:	mov    %r14,%rdx
  40817f:	mov    %rbx,%r14
  408182:	jmpq   407c20 <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x50>
  408187:	mov    %r15,%rdi
  40818a:	mov    $0x4,%esi
  40818f:	callq  413ed0 <p111_rt_fail>
  408194:	mov    $0x0,%eax
  408199:	jmpq   40844d <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x87d>
  40819e:	mov    %r11,%rax
  4081a1:	jmpq   40844d <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x87d>
  4081a6:	mov    %r13,%rsi
  4081a9:	mov    %ecx,%r8d
  4081ac:	mov    %eax,%ecx
  4081ae:	mov    %r11,%rax
  4081b1:	mov    %r15,%rdi
  4081b4:	or     %r8d,%edx
  4081b7:	jne    40844d <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x87d>
  4081bd:	mov    %ecx,%eax
  4081bf:	xor    $0x1,%eax
  4081c2:	jne    4081db <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x60b>
  4081c4:	mov    $0x4,%esi
  4081c9:	mov    %rdi,%r14
  4081cc:	callq  413ed0 <p111_rt_fail>
  4081d1:	mov    $0x0,%eax
  4081d6:	jmpq   40844d <p113d_FID_36_112_114_111_100_117_99_116_46_116_114_97_99_101_+0x87d>
  4081db:	mov    %rdi,%r14
  4081de:	cmp    $0x8,%rsi
  4081e2:	mov    $0x8,%eax
  4081e7:	cmovb  %rsi,%rax
  4081eb:	mov    %rax,%rcx
  4081ee:	shl    $0x3,%rcx
  4081f2:	lea    0x1810f(%rip),%rax        # 420308 <p126s_table_FID_36_100_105_114_101_99_116_46_115_114_>
  4081f9:	mov    (%rax,%rcx,1),%rax
  4081fd:	cmp    $0x8,%rsi
  408201:	mov    $0x8,%ecx
  408206:	cmovb  %rsi,%rcx
  40820a:	mov    %rcx,%rdx
  40820d:	shl    $0x3,%rdx
  408211:	lea    0x181c8(%rip),%rcx        # 4203e0 <p126s_table_FID_36_100_105_114_101_99_116_46_115_120_>
  408218:	mov    (%rcx,%rdx,1),%r13
  40821c:	cmp    $0x8,%rsi
  408220:	mov    $0x8,%ecx
  408225:	cmovb  %rsi,%rcx
  408229:	mov    %rcx,%rdx
  40822c:	shl    $0x3,%rdx
  408230:	lea    0x18161(%rip),%rcx        # 420398 <p126s_table_FID_36_100_105_114_101_99_116_46_115_121_>
  408237:	mov    (%rcx,%rdx,1),%r12
  40823b:	cmp    $0x8,%rsi
  40823f:	mov    $0x8,%ecx
  408244:	cmovb  %rsi,%rcx
  408248:	mov    %rcx,%rdx
  40824b:	shl    $0x3,%rdx
  40824f:	lea    0x180fa(%rip),%rcx        # 420350 <p126s_table_FID_36_100_105_114_101_99_116_46_115_122_>
  408256:	mov    (%rcx,%rdx,1),%rcx
  40825a:	movq   %rcx,%xmm2
  40825f:	subss  %xmm2,%xmm1
  408263:	movq   %rax,%xmm9
  408268:	movss  %xmm9,-0x64(%rbp)
  40826e:	divss  %xmm9,%xmm1
  408273:	movq   %xmm1,%rax
  408278:	mov    %eax,%ebx
  40827a:	callq  402500 <sqrt@plt>
  40827f:	mov    %r14,%rdi
  408282:	movss  -0x74(%rbp),%xmm5
  408287:	movss  -0x78(%rbp),%xmm3
  40828c:	movss  -0x68(%rbp),%xmm4
  408291:	movss  -0x6c(%rbp),%xmm6
  408296:	movss  -0x70(%rbp),%xmm8
  40829c:	movss  -0x7c(%rbp),%xmm7
  4082a1:	movss  -0x80(%rbp),%xmm1
  4082a6:	movss  -0x84(%rbp),%xmm2
  4082ae:	movss  -0x64(%rbp),%xmm9
  4082b4:	cvtsd2ss %xmm0,%xmm0
  4082b8:	movss  %xmm0,-0x88(%rbp)
  4082c0:	divss  %xmm0,%xmm2
  4082c4:	divss  %xmm0,%xmm1
  4082c8:	movss  %xmm0,%xmm15
  4082cd:	movss  %xmm7,%xmm0
  4082d1:	divss  %xmm15,%xmm0
  4082d6:	movq   %r13,%xmm7
  4082db:	subss  %xmm7,%xmm3
  4082df:	divss  %xmm9,%xmm3
  4082e4:	movq   %xmm3,%rax
  4082e9:	mov    %eax,%eax
  4082eb:	movq   %rax,%xmm7
  4082f0:	movss  %xmm2,%xmm3
  4082f4:	mulss  %xmm7,%xmm3
  4082f8:	movq   %r12,%xmm10
  4082fd:	subss  %xmm10,%xmm5
  408302:	divss  %xmm9,%xmm5
  408307:	movq   %xmm5,%rax
  40830c:	mov    %eax,%eax
  40830e:	movq   %rax,%xmm5
  408313:	movss  %xmm1,%xmm9
  408318:	mulss  %xmm5,%xmm9
  40831d:	addss  %xmm3,%xmm9
  408322:	movq   %rbx,%xmm3
  408327:	movss  %xmm0,%xmm10
  40832c:	mulss  %xmm3,%xmm10
  408331:	addss  %xmm10,%xmm9
  408336:	movss  0x11ce5(%rip),%xmm10        # 41a024 <_IO_stdin_used+0x24>
  40833f:	ucomiss %xmm9,%xmm10
  408343:	seta   %al
  408346:	movzbl %al,%eax
  408349:	mov    %eax,%eax
  40834b:	movq   %xmm9,%rcx
  408350:	mov    %ecx,%ecx
  408352:	cmp    $0x1,%rax
  408356:	mov    $0x0,%eax
  40835b:	mov    %rax,%rbx
  40835e:	cmovne %rcx,%rbx
  408362:	mulss  0x11cbe(%rip),%xmm7        # 41a028 <_IO_stdin_used+0x28>
  40836a:	addss  %xmm8,%xmm7
  40836f:	movq   %xmm7,%rax
  408374:	mov    %eax,%edx
  408376:	mulss  0x11caa(%rip),%xmm5        # 41a028 <_IO_stdin_used+0x28>
  40837e:	addss  %xmm6,%xmm5
  408382:	movq   %xmm5,%rax
  408387:	mov    %eax,%ecx
  408389:	mulss  0x11c97(%rip),%xmm3        # 41a028 <_IO_stdin_used+0x28>
  408391:	addss  %xmm4,%xmm3
  408395:	movq   %xmm3,%rax
  40839a:	mov    %eax,%r8d
  40839d:	movq   %xmm2,%rax
  4083a2:	mov    %eax,%r9d
  4083a5:	movq   %xmm1,%rax
  4083aa:	mov    %eax,%eax
  4083ac:	movq   %xmm0,%rsi
  4083b1:	mov    %esi,%r10d
  4083b4:	sub    $0x30,%rsp
  4083b8:	mov    %rsp,%rsi
  4083bb:	movq   $0x0,0x20(%rsi)
  4083c3:	movq   $0x4e6e6b28,0x18(%rsi)
  4083cb:	movq   $0x4e6e6b28,0x10(%rsi)
  4083d3:	mov    %r10,0x8(%rsi)
  4083d7:	mov    %rax,(%rsi)
  4083da:	mov    $0x9,%esi
  4083df:	callq  4077b0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>
  4083e4:	movss  -0x8c(%rbp),%xmm3
  4083ec:	movss  -0x90(%rbp),%xmm2
  4083f4:	movss  -0x88(%rbp),%xmm1
  4083fc:	sub    $0xffffffffffffffd0,%rsp
  408400:	movq   %rax,%xmm0
  408405:	movq   %xmm1,%rax
  40840a:	mov    %eax,%eax
  40840c:	movq   %rax,%xmm1
  408411:	ucomiss %xmm0,%xmm1
  408414:	seta   %al
  408417:	movzbl %al,%eax
  40841a:	mov    %eax,%eax
  40841c:	cmp    $0x1,%rax
  408420:	mov    $0x0,%eax
  408425:	cmovne %rbx,%rax
  408429:	movq   %rax,%xmm0
  40842e:	mulss  0x11c02(%rip),%xmm0        # 41a038 <_IO_stdin_used+0x38>
  408436:	addss  0x11bf6(%rip),%xmm0        # 41a034 <_IO_stdin_used+0x34>
  40843e:	mulss  %xmm2,%xmm0
  408442:	addss  %xmm3,%xmm0
  408446:	movq   %xmm0,%rax
  40844b:	mov    %eax,%eax
  40844d:	pop    %r15
  40844f:	pop    %r14
  408451:	pop    %r13
  408453:	pop    %r12
  408455:	pop    %rbx
  408456:	leaveq 
  408457:	retq   

Disassembly of section .fini:
