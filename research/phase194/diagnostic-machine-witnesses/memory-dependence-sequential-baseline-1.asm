
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-baseline-build04/memory-dependence-sequential/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004088a4 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
  4088a4:	push   %rbp
  4088a5:	mov    %rsp,%rbp
  4088a8:	sub    $0x9f0,%rsp
  4088af:	mov    %r12,-0x10(%rbp)
  4088b3:	mov    %rbx,-0x8(%rbp)
  4088b7:	mov    %r13,-0x18(%rbp)
  4088bb:	mov    %r14,-0x20(%rbp)
  4088bf:	mov    %r15,-0x28(%rbp)
  4088c3:	mov    %rdi,%rax
  4088c6:	mov    %rax,%r12
  4088c9:	mov    %rsi,%rax
  4088cc:	mov    %rax,%rsi
  4088cf:	mov    (%r12),%r14
  4088d3:	mov    %rsi,%rdi
  4088d6:	shr    $0x28,%rdi
  4088da:	and    $0xffff,%rdi
  4088e1:	movabs $0x8,%r11
  4088eb:	cmp    %r11,%rdi
  4088ee:	jne    408b6c <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2c8>
  4088f4:	mov    %r12,%r10
  4088f7:	mov    %r10,0x18(%rsp)
  4088fc:	mov    %rsi,%r10
  4088ff:	mov    %r10,0x20(%rsp)
  408904:	lea    -0x830(%rbp),%r10
  40890b:	mov    %r10,0x28(%rsp)
  408910:	mov    0x18(%rsp),%rdi
  408915:	mov    0x20(%rsp),%rsi
  40891a:	mov    0x28(%rsp),%rdx
  40891f:	xor    %eax,%eax
  408921:	callq  41b3e0 <p125_rt_take2>
  408926:	mov    %rax,-0x8a0(%rbp)
  40892d:	lea    -0x830(%rbp),%r10
  408934:	mov    (%r10),%rsi
  408937:	lea    -0x830(%rbp),%r10
  40893e:	mov    0x8(%r10),%r15
  408942:	mov    %rsi,%rdi
  408945:	shr    $0x28,%rdi
  408949:	and    $0xffff,%rdi
  408950:	movabs $0x8,%r11
  40895a:	cmp    %r11,%rdi
  40895d:	jne    408b2c <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x288>
  408963:	mov    %r12,%r10
  408966:	mov    %r10,0x18(%rsp)
  40896b:	mov    %rsi,%r10
  40896e:	mov    %r10,0x20(%rsp)
  408973:	lea    -0x830(%rbp),%r10
  40897a:	mov    %r10,0x28(%rsp)
  40897f:	mov    0x18(%rsp),%rdi
  408984:	mov    0x20(%rsp),%rsi
  408989:	mov    0x28(%rsp),%rdx
  40898e:	xor    %eax,%eax
  408990:	callq  41b3e0 <p125_rt_take2>
  408995:	mov    %rax,-0x8a0(%rbp)
  40899c:	lea    -0x830(%rbp),%r10
  4089a3:	mov    (%r10),%rbx
  4089a6:	lea    -0x830(%rbp),%r10
  4089ad:	mov    0x8(%r10),%r13
  4089b1:	lea    -0x830(%rbp),%r10
  4089b8:	mov    %rbx,%r11
  4089bb:	mov    %r11,(%r10)
  4089be:	lea    -0x830(%rbp),%r10
  4089c5:	mov    %r13,%r11
  4089c8:	mov    %r11,0x8(%r10)
  4089cc:	mov    %r13,%rdx
  4089cf:	mov    %rbx,%rdi
  4089d2:	shr    $0x38,%rdi
  4089d6:	mov    %rdi,%rsi
  4089d9:	cmp    $0x4,%rsi
  4089e0:	sete   %sil
  4089e4:	movzbl %sil,%esi
  4089e8:	movabs $0xffffffffff,%r11
  4089f2:	mov    %rbx,%rdi
  4089f5:	and    %r11,%rdi
  4089f8:	mov    %rdi,%r8
  4089fb:	cmp    $0x3108280,%r8
  408a02:	setae  %r8b
  408a06:	movzbl %r8b,%r8d
  408a0a:	and    %r8d,%esi
  408a0d:	mov    %rsi,%r10
  408a10:	test   %r10d,%r10d
  408a13:	je     408a76 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1d2>
  408a19:	mov    %rbx,%rsi
  408a1c:	shr    $0x28,%rsi
  408a20:	and    $0x1f,%rsi
  408a27:	mov    %rsi,%r11
  408a2a:	movabs $0x1,%rsi
  408a34:	mov    %r11d,%ecx
  408a37:	shl    %cl,%rsi
  408a3a:	sub    $0x1,%rsi
  408a41:	and    %rsi,%rdx
  408a44:	shl    $0x3,%rdi
  408a48:	mov    %rdx,%rsi
  408a4b:	shl    $0x2,%rsi
  408a4f:	add    %rsi,%rdi
  408a52:	mov    (%r14,%rdi,1),%edi
  408a56:	lea    -0x8d0(%rbp),%r10
  408a5d:	mov    %rbx,%r11
  408a60:	mov    %r11,(%r10)
  408a63:	lea    -0x8d0(%rbp),%r10
  408a6a:	mov    %rdi,%r11
  408a6d:	mov    %r11,0x8(%r10)
  408a71:	jmpq   408aba <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x216>
  408a76:	mov    %r12,%rdi
  408a79:	movabs $0x48,%rsi
  408a83:	mov    %esi,%esi
  408a85:	lea    -0x830(%rbp),%rdx
  408a8c:	movabs $0x2,%rcx
  408a96:	mov    %ecx,%ecx
  408a98:	lea    -0x8d0(%rbp),%r8
  408a9f:	movabs $0x2,%r9
  408aa9:	mov    %r9d,%r9d
  408aac:	xor    %eax,%eax
  408aae:	callq  4196b0 <p113_rt_array_pair>
  408ab3:	mov    %rax,-0x948(%rbp)
  408aba:	lea    -0x8d0(%rbp),%r10
  408ac1:	mov    0x8(%r10),%rdi
  408ac5:	mov    %r12,%r10
  408ac8:	mov    %r10,0x28(%rsp)
  408acd:	mov    %r13,%r10
  408ad0:	mov    %r10,0x30(%rsp)
  408ad5:	mov    %r15,%r10
  408ad8:	mov    %r10,0x38(%rsp)
  408add:	mov    %rbx,%r10
  408ae0:	mov    %r10,0x40(%rsp)
  408ae5:	mov    %rdi,%r10
  408ae8:	mov    %r10,0x48(%rsp)
  408aed:	mov    0x28(%rsp),%rdi
  408af2:	mov    0x30(%rsp),%rsi
  408af7:	mov    0x38(%rsp),%rdx
  408afc:	mov    0x40(%rsp),%rcx
  408b01:	mov    0x48(%rsp),%r8
  408b06:	xor    %eax,%eax
  408b08:	callq  4087ca <p113d_FID_36_112_114_111_100_117_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>
  408b0d:	mov    %rax,%rdi
  408b10:	mov    %rdi,%rax
  408b13:	mov    -0x10(%rbp),%r12
  408b17:	mov    -0x8(%rbp),%rbx
  408b1b:	mov    -0x18(%rbp),%r13
  408b1f:	mov    -0x20(%rbp),%r14
  408b23:	mov    -0x28(%rbp),%r15
  408b27:	mov    %rbp,%rsp
  408b2a:	pop    %rbp
  408b2b:	retq   
  408b2c:	mov    %r12,%rdi
  408b2f:	movabs $0x4,%rsi
  408b39:	mov    %esi,%esi
  408b3b:	xor    %eax,%eax
  408b3d:	callq  415dd0 <p111_rt_fail>
  408b42:	mov    %rax,-0x8a0(%rbp)
  408b49:	movabs $0x0,%rax
  408b53:	mov    -0x10(%rbp),%r12
  408b57:	mov    -0x8(%rbp),%rbx
  408b5b:	mov    -0x18(%rbp),%r13
  408b5f:	mov    -0x20(%rbp),%r14
  408b63:	mov    -0x28(%rbp),%r15
  408b67:	mov    %rbp,%rsp
  408b6a:	pop    %rbp
  408b6b:	retq   
  408b6c:	mov    %r12,%rdi
  408b6f:	movabs $0x4,%rsi
  408b79:	mov    %esi,%esi
  408b7b:	xor    %eax,%eax
  408b7d:	callq  415dd0 <p111_rt_fail>
  408b82:	mov    %rax,-0x8a0(%rbp)
  408b89:	movabs $0x0,%rax
  408b93:	mov    -0x10(%rbp),%r12
  408b97:	mov    -0x8(%rbp),%rbx
  408b9b:	mov    -0x18(%rbp),%r13
  408b9f:	mov    -0x20(%rbp),%r14
  408ba3:	mov    -0x28(%rbp),%r15
  408ba7:	mov    %rbp,%rsp
  408baa:	pop    %rbp
  408bab:	retq   

Disassembly of section .fini:
