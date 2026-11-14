
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/variation-ray-active-64-2440/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004077b0 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_>:
  4077b0:	endbr64 
  4077b4:	push   %rbp
  4077b5:	mov    %rsp,%rbp
  4077b8:	sub    $0x38,%rsp
  4077bc:	push   %rbx
  4077bd:	push   %r12
  4077bf:	push   %r13
  4077c1:	push   %r14
  4077c3:	push   %r15
  4077c5:	mov    0x30(%rbp),%rbx
  4077c9:	mov    0x28(%rbp),%r11
  4077cd:	mov    0x20(%rbp),%r10
  4077d1:	mov    0x18(%rbp),%r12
  4077d5:	mov    0x10(%rbp),%r13
  4077d9:	mov    %r9,%r14
  4077dc:	mov    %r8,%r15
  4077df:	mov    %rcx,%rax
  4077e2:	mov    %rdx,%rcx
  4077e5:	mov    %rbx,%rdx
  4077e8:	mov    %rsi,%rbx
  4077eb:	mov    %rdi,-0x30(%rbp)
  4077ef:	xchg   %r10,%r11
  4077f2:	data16 nopw %cs:0x0(%rax,%rax,1)
  4077fd:	nopl   (%rax)
  407800:	mov    %rcx,-0x20(%rbp)
  407804:	mov    %rax,-0x28(%rbp)
  407808:	mov    %r11,-0x8(%rbp)
  40780c:	mov    %r10,-0x18(%rbp)
  407810:	cmp    $0x0,%rbx
  407814:	sete   %r8b
  407818:	movzbl %r8b,%r8d
  40781c:	cmp    $0x1,%rdx
  407820:	mov    %rdx,%rsi
  407823:	sete   %dl
  407826:	movzbl %dl,%edx
  407829:	shr    $0x28,%rsi
  40782d:	and    $0x7fffff,%rsi
  407834:	cmp    $0x10002,%rsi
  40783b:	sete   %sil
  40783f:	movzbl %sil,%esi
  407843:	mov    %edx,%edi
  407845:	or     %esi,%edi
  407847:	cmp    $0x0,%r8d
  40784b:	jne    407b8d <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x3dd>
  407851:	sub    $0x1,%rbx
  407855:	movq   %rcx,%xmm2
  40785a:	movq   %rax,%xmm4
  40785f:	movq   %r15,%xmm3
  407864:	movq   %r14,%xmm0
  407869:	movq   %r13,%xmm5
  40786e:	movq   %r12,%xmm1
  407873:	xor    $0x1,%edi
  407876:	jne    407a16 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x266>
  40787c:	mov    %r11,%r10
  40787f:	or     %esi,%edx
  407881:	je     4079fe <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x24e>
  407887:	cmp    $0x8,%rbx
  40788b:	mov    $0x8,%edx
  407890:	cmovb  %rbx,%rdx
  407894:	mov    %rdx,%rsi
  407897:	shl    $0x3,%rsi
  40789b:	lea    0x18b3e(%rip),%rdx        # 4203e0 <p126s_table_FID_36_100_105_114_101_99_116_46_115_120_>
  4078a2:	mov    (%rdx,%rsi,1),%r8
  4078a6:	cmp    $0x8,%rbx
  4078aa:	mov    $0x8,%edx
  4078af:	cmovb  %rbx,%rdx
  4078b3:	mov    %rdx,%rsi
  4078b6:	shl    $0x3,%rsi
  4078ba:	lea    0x18ad7(%rip),%rdx        # 420398 <p126s_table_FID_36_100_105_114_101_99_116_46_115_121_>
  4078c1:	mov    (%rdx,%rsi,1),%rdi
  4078c5:	cmp    $0x8,%rbx
  4078c9:	mov    $0x8,%edx
  4078ce:	cmovb  %rbx,%rdx
  4078d2:	mov    %rdx,%rsi
  4078d5:	shl    $0x3,%rsi
  4078d9:	lea    0x18a70(%rip),%rdx        # 420350 <p126s_table_FID_36_100_105_114_101_99_116_46_115_122_>
  4078e0:	mov    (%rdx,%rsi,1),%rsi
  4078e4:	cmp    $0x8,%rbx
  4078e8:	mov    $0x8,%edx
  4078ed:	cmovb  %rbx,%rdx
  4078f1:	mov    %rdx,%r9
  4078f4:	shl    $0x3,%r9
  4078f8:	lea    0x18a09(%rip),%rdx        # 420308 <p126s_table_FID_36_100_105_114_101_99_116_46_115_114_>
  4078ff:	mov    (%rdx,%r9,1),%rdx
  407903:	movq   %r8,%xmm6
  407908:	subss  %xmm6,%xmm2
  40790c:	movq   %rdi,%xmm6
  407911:	subss  %xmm6,%xmm4
  407915:	movq   %rsi,%xmm6
  40791a:	subss  %xmm6,%xmm3
  40791e:	mulss  %xmm2,%xmm0
  407922:	mulss  %xmm4,%xmm5
  407926:	addss  %xmm5,%xmm0
  40792a:	mulss  %xmm3,%xmm1
  40792e:	addss  %xmm0,%xmm1
  407932:	movss  %xmm1,%xmm0
  407936:	mulss  %xmm1,%xmm0
  40793a:	mulss  %xmm2,%xmm2
  40793e:	mulss  %xmm4,%xmm4
  407942:	addss  %xmm4,%xmm2
  407946:	mulss  %xmm3,%xmm3
  40794a:	addss  %xmm3,%xmm2
  40794e:	movq   %rdx,%xmm3
  407953:	mulss  %xmm3,%xmm3
  407957:	subss  %xmm3,%xmm2
  40795b:	subss  %xmm2,%xmm0
  40795f:	movss  0x126bd(%rip),%xmm2        # 41a024 <_IO_stdin_used+0x24>
  407967:	ucomiss %xmm0,%xmm2
  40796a:	seta   %dl
  40796d:	movzbl %dl,%edx
  407970:	mov    %edx,%edx
  407972:	cmp    $0x1,%rdx
  407976:	je     4079de <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x22e>
  407978:	xorps  0x12691(%rip),%xmm1        # 41a010 <_IO_stdin_used+0x10>
  40797f:	addss  0x1269d(%rip),%xmm1        # 41a024 <_IO_stdin_used+0x24>
  407987:	movss  %xmm1,-0xc(%rbp)
  40798c:	cvtss2sd %xmm0,%xmm0
  407990:	callq  402500 <sqrt@plt>
  407995:	movsd  %xmm0,%xmm1
  407999:	mov    -0x20(%rbp),%rcx
  40799d:	mov    -0x28(%rbp),%rax
  4079a1:	mov    -0x8(%rbp),%r10
  4079a5:	movss  -0xc(%rbp),%xmm0
  4079aa:	cvtsd2ss %xmm1,%xmm1
  4079ae:	subss  %xmm1,%xmm0
  4079b2:	movss  0x1266e(%rip),%xmm1        # 41a028 <_IO_stdin_used+0x28>
  4079ba:	ucomiss %xmm0,%xmm1
  4079bd:	seta   %dl
  4079c0:	movzbl %dl,%edx
  4079c3:	mov    %edx,%edx
  4079c5:	movq   %xmm0,%rsi
  4079ca:	mov    %esi,%esi
  4079cc:	cmp    $0x1,%rdx
  4079d0:	mov    $0x4e6e6b28,%edx
  4079d5:	mov    %rdx,%r11
  4079d8:	cmovne %rsi,%r11
  4079dc:	jmp    4079e4 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x234>
  4079de:	mov    $0x4e6e6b28,%r11d
  4079e4:	movq   %r11,%xmm0
  4079e9:	movq   %r10,%xmm1
  4079ee:	ucomiss %xmm0,%xmm1
  4079f1:	seta   %dl
  4079f4:	movzbl %dl,%edx
  4079f7:	mov    %edx,%edx
  4079f9:	jmpq   407800 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x50>
  4079fe:	mov    -0x30(%rbp),%rdi
  407a02:	mov    $0x4,%esi
  407a07:	callq  413ed0 <p111_rt_fail>
  407a0c:	mov    $0x0,%eax
  407a11:	jmpq   407bbb <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x40b>
  407a16:	cmp    $0x8,%rbx
  407a1a:	mov    $0x8,%edx
  407a1f:	cmovb  %rbx,%rdx
  407a23:	mov    %rdx,%rsi
  407a26:	shl    $0x3,%rsi
  407a2a:	lea    0x189af(%rip),%rdx        # 4203e0 <p126s_table_FID_36_100_105_114_101_99_116_46_115_120_>
  407a31:	mov    (%rdx,%rsi,1),%r8
  407a35:	cmp    $0x8,%rbx
  407a39:	mov    $0x8,%edx
  407a3e:	cmovb  %rbx,%rdx
  407a42:	mov    %rdx,%rsi
  407a45:	shl    $0x3,%rsi
  407a49:	lea    0x18948(%rip),%rdx        # 420398 <p126s_table_FID_36_100_105_114_101_99_116_46_115_121_>
  407a50:	mov    (%rdx,%rsi,1),%rdi
  407a54:	cmp    $0x8,%rbx
  407a58:	mov    $0x8,%edx
  407a5d:	cmovb  %rbx,%rdx
  407a61:	mov    %rdx,%rsi
  407a64:	shl    $0x3,%rsi
  407a68:	lea    0x188e1(%rip),%rdx        # 420350 <p126s_table_FID_36_100_105_114_101_99_116_46_115_122_>
  407a6f:	mov    (%rdx,%rsi,1),%rsi
  407a73:	cmp    $0x8,%rbx
  407a77:	mov    $0x8,%edx
  407a7c:	cmovb  %rbx,%rdx
  407a80:	mov    %rdx,%r9
  407a83:	shl    $0x3,%r9
  407a87:	lea    0x1887a(%rip),%rdx        # 420308 <p126s_table_FID_36_100_105_114_101_99_116_46_115_114_>
  407a8e:	mov    (%rdx,%r9,1),%rdx
  407a92:	movq   %r8,%xmm6
  407a97:	subss  %xmm6,%xmm2
  407a9b:	movq   %rdi,%xmm6
  407aa0:	subss  %xmm6,%xmm4
  407aa4:	movq   %rsi,%xmm6
  407aa9:	subss  %xmm6,%xmm3
  407aad:	mulss  %xmm2,%xmm0
  407ab1:	mulss  %xmm4,%xmm5
  407ab5:	addss  %xmm5,%xmm0
  407ab9:	mulss  %xmm3,%xmm1
  407abd:	addss  %xmm0,%xmm1
  407ac1:	movss  %xmm1,%xmm0
  407ac5:	mulss  %xmm1,%xmm0
  407ac9:	mulss  %xmm2,%xmm2
  407acd:	mulss  %xmm4,%xmm4
  407ad1:	addss  %xmm4,%xmm2
  407ad5:	mulss  %xmm3,%xmm3
  407ad9:	addss  %xmm3,%xmm2
  407add:	movq   %rdx,%xmm3
  407ae2:	mulss  %xmm3,%xmm3
  407ae6:	subss  %xmm3,%xmm2
  407aea:	subss  %xmm2,%xmm0
  407aee:	movss  0x1252e(%rip),%xmm2        # 41a024 <_IO_stdin_used+0x24>
  407af6:	ucomiss %xmm0,%xmm2
  407af9:	seta   %dl
  407afc:	movzbl %dl,%edx
  407aff:	mov    %edx,%edx
  407b01:	cmp    $0x1,%rdx
  407b05:	je     407b6d <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x3bd>
  407b07:	xorps  0x12502(%rip),%xmm1        # 41a010 <_IO_stdin_used+0x10>
  407b0e:	addss  0x1250e(%rip),%xmm1        # 41a024 <_IO_stdin_used+0x24>
  407b16:	movss  %xmm1,-0x10(%rbp)
  407b1b:	cvtss2sd %xmm0,%xmm0
  407b1f:	callq  402500 <sqrt@plt>
  407b24:	movsd  %xmm0,%xmm1
  407b28:	mov    -0x20(%rbp),%rcx
  407b2c:	mov    -0x28(%rbp),%rax
  407b30:	mov    -0x18(%rbp),%r10
  407b34:	movss  -0x10(%rbp),%xmm0
  407b39:	cvtsd2ss %xmm1,%xmm1
  407b3d:	subss  %xmm1,%xmm0
  407b41:	movss  0x124df(%rip),%xmm1        # 41a028 <_IO_stdin_used+0x28>
  407b49:	ucomiss %xmm0,%xmm1
  407b4c:	seta   %dl
  407b4f:	movzbl %dl,%edx
  407b52:	mov    %edx,%edx
  407b54:	movq   %xmm0,%rsi
  407b59:	mov    %esi,%esi
  407b5b:	cmp    $0x1,%rdx
  407b5f:	mov    $0x4e6e6b28,%edx
  407b64:	mov    %rdx,%r11
  407b67:	cmovne %rsi,%r11
  407b6b:	jmp    407b73 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x3c3>
  407b6d:	mov    $0x4e6e6b28,%r11d
  407b73:	movq   %r11,%xmm0
  407b78:	movq   %r10,%xmm1
  407b7d:	ucomiss %xmm0,%xmm1
  407b80:	seta   %dl
  407b83:	movzbl %dl,%edx
  407b86:	mov    %edx,%edx
  407b88:	jmpq   407800 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x50>
  407b8d:	mov    %r10,%rax
  407b90:	mov    %r11,%r10
  407b93:	mov    %edi,%ecx
  407b95:	mov    -0x30(%rbp),%rdi
  407b99:	xor    $0x1,%ecx
  407b9c:	jne    407bbb <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x40b>
  407b9e:	mov    %r10,%rax
  407ba1:	mov    %edx,%ecx
  407ba3:	or     %esi,%ecx
  407ba5:	jne    407bb8 <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x408>
  407ba7:	mov    $0x4,%esi
  407bac:	callq  413ed0 <p111_rt_fail>
  407bb1:	mov    $0x0,%eax
  407bb6:	jmp    407bbb <p113d_FID_36_100_105_114_101_99_116_46_110_101_97_114_101_115_116_46_116_+0x40b>
  407bb8:	mov    %rax,%r11
  407bbb:	pop    %r15
  407bbd:	pop    %r14
  407bbf:	pop    %r13
  407bc1:	pop    %r12
  407bc3:	pop    %rbx
  407bc4:	leaveq 
  407bc5:	retq   

Disassembly of section .fini:
