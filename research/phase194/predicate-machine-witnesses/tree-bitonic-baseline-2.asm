
/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-native45-02/tree-bitonic/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004088c4 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_>:
  4088c4:	push   %rbp
  4088c5:	mov    %rsp,%rbp
  4088c8:	sub    $0x960,%rsp
  4088cf:	mov    %r12,-0x10(%rbp)
  4088d3:	mov    %rbx,-0x8(%rbp)
  4088d7:	mov    %r13,-0x18(%rbp)
  4088db:	mov    %rdi,%rax
  4088de:	mov    %rax,%r12
  4088e1:	mov    %rsi,%rax
  4088e4:	mov    %rax,%rbx
  4088e7:	mov    %rdx,%rax
  4088ea:	mov    %rax,%r13
  4088ed:	mov    %rcx,%rax
  4088f0:	mov    %rax,%rdi
  4088f3:	mov    %rdi,%r8
  4088f6:	cmp    $0x1,%r8
  4088fd:	sete   %r8b
  408901:	movzbl %r8b,%r8d
  408905:	mov    %rdi,%rsi
  408908:	shr    $0x28,%rsi
  40890c:	and    $0x7fffff,%rsi
  408913:	movabs $0x2,%rdx
  40891d:	or     $0x10000,%rdx
  408924:	cmp    %rdx,%rsi
  408927:	sete   %sil
  40892b:	movzbl %sil,%esi
  40892f:	mov    %rsi,%r11
  408932:	mov    %r8,%rsi
  408935:	or     %r11d,%esi
  408938:	xor    $0x1,%esi
  40893e:	mov    %rsi,%r10
  408941:	test   %r10d,%r10d
  408944:	je     408a68 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x1a4>
  40894a:	mov    %rbx,%rsi
  40894d:	lea    -0x840(%rbp),%r10
  408954:	mov    %rbx,%r11
  408957:	mov    %r11,(%r10)
  40895a:	movabs $0xffffffffff,%r11
  408964:	cmp    %r11,%rbx
  408967:	ja     408990 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0xcc>
  40896d:	movabs $0xa4,%rdi
  408977:	shl    $0x28,%rdi
  40897b:	movabs $0x100000000000000,%r11
  408985:	or     %r11,%rdi
  408988:	or     %rsi,%rdi
  40898b:	jmpq   4089b0 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0xec>
  408990:	mov    %r12,%rdi
  408993:	movabs $0xa4,%rsi
  40899d:	mov    %esi,%esi
  40899f:	lea    -0x840(%rbp),%rdx
  4089a6:	xor    %eax,%eax
  4089a8:	callq  421b50 <p125_rt_ctor1>
  4089ad:	mov    %rax,%rdi
  4089b0:	mov    %rdi,%rbx
  4089b3:	mov    %r13,%rsi
  4089b6:	lea    -0x840(%rbp),%r10
  4089bd:	mov    %r13,%r11
  4089c0:	mov    %r11,(%r10)
  4089c3:	movabs $0xffffffffff,%r11
  4089cd:	cmp    %r11,%r13
  4089d0:	ja     4089f9 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x135>
  4089d6:	movabs $0xa4,%rdi
  4089e0:	shl    $0x28,%rdi
  4089e4:	movabs $0x100000000000000,%r11
  4089ee:	or     %r11,%rdi
  4089f1:	or     %rsi,%rdi
  4089f4:	jmpq   408a19 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x155>
  4089f9:	mov    %r12,%rdi
  4089fc:	movabs $0xa4,%rsi
  408a06:	mov    %esi,%esi
  408a08:	lea    -0x840(%rbp),%rdx
  408a0f:	xor    %eax,%eax
  408a11:	callq  421b50 <p125_rt_ctor1>
  408a16:	mov    %rax,%rdi
  408a19:	lea    -0x840(%rbp),%r10
  408a20:	mov    %rbx,%r11
  408a23:	mov    %r11,(%r10)
  408a26:	lea    -0x840(%rbp),%r10
  408a2d:	mov    %rdi,%r11
  408a30:	mov    %r11,0x8(%r10)
  408a34:	mov    %r12,%rdi
  408a37:	movabs $0xa5,%rsi
  408a41:	mov    %esi,%esi
  408a43:	lea    -0x840(%rbp),%rdx
  408a4a:	xor    %eax,%eax
  408a4c:	callq  421d80 <p125_rt_ctor2>
  408a51:	mov    %rax,%rdi
  408a54:	mov    %rdi,%rax
  408a57:	mov    -0x10(%rbp),%r12
  408a5b:	mov    -0x8(%rbp),%rbx
  408a5f:	mov    -0x18(%rbp),%r13
  408a63:	mov    %rbp,%rsp
  408a66:	pop    %rbp
  408a67:	retq   
  408a68:	mov    %rdi,%r8
  408a6b:	cmp    $0x1,%r8
  408a72:	sete   %r8b
  408a76:	movzbl %r8b,%r8d
  408a7a:	mov    %rdi,%rsi
  408a7d:	shr    $0x28,%rsi
  408a81:	and    $0x7fffff,%rsi
  408a88:	movabs $0x2,%rdx
  408a92:	or     $0x10000,%rdx
  408a99:	cmp    %rdx,%rsi
  408a9c:	sete   %sil
  408aa0:	movzbl %sil,%esi
  408aa4:	mov    %rsi,%r11
  408aa7:	mov    %r8,%rsi
  408aaa:	or     %r11d,%esi
  408aad:	mov    %rsi,%r10
  408ab0:	test   %r10d,%r10d
  408ab3:	je     408bd7 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x313>
  408ab9:	mov    %r13,%rsi
  408abc:	lea    -0x840(%rbp),%r10
  408ac3:	mov    %r13,%r11
  408ac6:	mov    %r11,(%r10)
  408ac9:	movabs $0xffffffffff,%r11
  408ad3:	cmp    %r11,%r13
  408ad6:	ja     408aff <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x23b>
  408adc:	movabs $0xa4,%rdi
  408ae6:	shl    $0x28,%rdi
  408aea:	movabs $0x100000000000000,%r11
  408af4:	or     %r11,%rdi
  408af7:	or     %rsi,%rdi
  408afa:	jmpq   408b1f <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x25b>
  408aff:	mov    %r12,%rdi
  408b02:	movabs $0xa4,%rsi
  408b0c:	mov    %esi,%esi
  408b0e:	lea    -0x840(%rbp),%rdx
  408b15:	xor    %eax,%eax
  408b17:	callq  421b50 <p125_rt_ctor1>
  408b1c:	mov    %rax,%rdi
  408b1f:	mov    %rdi,%r13
  408b22:	mov    %rbx,%rsi
  408b25:	lea    -0x840(%rbp),%r10
  408b2c:	mov    %rbx,%r11
  408b2f:	mov    %r11,(%r10)
  408b32:	movabs $0xffffffffff,%r11
  408b3c:	cmp    %r11,%rbx
  408b3f:	ja     408b68 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x2a4>
  408b45:	movabs $0xa4,%rdi
  408b4f:	shl    $0x28,%rdi
  408b53:	movabs $0x100000000000000,%r11
  408b5d:	or     %r11,%rdi
  408b60:	or     %rsi,%rdi
  408b63:	jmpq   408b88 <p113d_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_46_103_111_+0x2c4>
  408b68:	mov    %r12,%rdi
  408b6b:	movabs $0xa4,%rsi
  408b75:	mov    %esi,%esi
  408b77:	lea    -0x840(%rbp),%rdx
  408b7e:	xor    %eax,%eax
  408b80:	callq  421b50 <p125_rt_ctor1>
  408b85:	mov    %rax,%rdi
  408b88:	lea    -0x840(%rbp),%r10
  408b8f:	mov    %r13,%r11
  408b92:	mov    %r11,(%r10)
  408b95:	lea    -0x840(%rbp),%r10
  408b9c:	mov    %rdi,%r11
  408b9f:	mov    %r11,0x8(%r10)
  408ba3:	mov    %r12,%rdi
  408ba6:	movabs $0xa5,%rsi
  408bb0:	mov    %esi,%esi
  408bb2:	lea    -0x840(%rbp),%rdx
  408bb9:	xor    %eax,%eax
  408bbb:	callq  421d80 <p125_rt_ctor2>
  408bc0:	mov    %rax,%rdi
  408bc3:	mov    %rdi,%rax
  408bc6:	mov    -0x10(%rbp),%r12
  408bca:	mov    -0x8(%rbp),%rbx
  408bce:	mov    -0x18(%rbp),%r13
  408bd2:	mov    %rbp,%rsp
  408bd5:	pop    %rbp
  408bd6:	retq   
  408bd7:	mov    %r12,%rdi
  408bda:	movabs $0x4,%rsi
  408be4:	mov    %esi,%esi
  408be6:	xor    %eax,%eax
  408be8:	callq  41c860 <p111_rt_fail>
  408bed:	mov    %rax,-0x900(%rbp)
  408bf4:	movabs $0x0,%rax
  408bfe:	mov    -0x10(%rbp),%r12
  408c02:	mov    -0x8(%rbp),%rbx
  408c06:	mov    -0x18(%rbp),%r13
  408c0a:	mov    %rbp,%rsp
  408c0d:	pop    %rbp
  408c0e:	retq   

Disassembly of section .fini:
