
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/memory-dependence-dependent/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040881b <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
  40881b:	push   %rbp
  40881c:	mov    %rsp,%rbp
  40881f:	sub    $0x9f0,%rsp
  408826:	mov    %r12,-0x10(%rbp)
  40882a:	mov    %rbx,-0x8(%rbp)
  40882e:	mov    %r13,-0x18(%rbp)
  408832:	mov    %r14,-0x20(%rbp)
  408836:	mov    %r15,-0x28(%rbp)
  40883a:	mov    %rdi,%rax
  40883d:	mov    %rax,%r12
  408840:	mov    %rsi,%rax
  408843:	mov    %rax,%rsi
  408846:	mov    (%r12),%r14
  40884a:	mov    %rsi,%rdi
  40884d:	shr    $0x28,%rdi
  408851:	and    $0xffff,%rdi
  408858:	movabs $0x8,%r11
  408862:	cmp    %r11,%rdi
  408865:	jne    408ae3 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2c8>
  40886b:	mov    %r12,%r10
  40886e:	mov    %r10,0x18(%rsp)
  408873:	mov    %rsi,%r10
  408876:	mov    %r10,0x20(%rsp)
  40887b:	lea    -0x830(%rbp),%r10
  408882:	mov    %r10,0x28(%rsp)
  408887:	mov    0x18(%rsp),%rdi
  40888c:	mov    0x20(%rsp),%rsi
  408891:	mov    0x28(%rsp),%rdx
  408896:	xor    %eax,%eax
  408898:	callq  41b320 <p125_rt_take2>
  40889d:	mov    %rax,-0x8a0(%rbp)
  4088a4:	lea    -0x830(%rbp),%r10
  4088ab:	mov    (%r10),%rsi
  4088ae:	lea    -0x830(%rbp),%r10
  4088b5:	mov    0x8(%r10),%r15
  4088b9:	mov    %rsi,%rdi
  4088bc:	shr    $0x28,%rdi
  4088c0:	and    $0xffff,%rdi
  4088c7:	movabs $0x8,%r11
  4088d1:	cmp    %r11,%rdi
  4088d4:	jne    408aa3 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x288>
  4088da:	mov    %r12,%r10
  4088dd:	mov    %r10,0x18(%rsp)
  4088e2:	mov    %rsi,%r10
  4088e5:	mov    %r10,0x20(%rsp)
  4088ea:	lea    -0x830(%rbp),%r10
  4088f1:	mov    %r10,0x28(%rsp)
  4088f6:	mov    0x18(%rsp),%rdi
  4088fb:	mov    0x20(%rsp),%rsi
  408900:	mov    0x28(%rsp),%rdx
  408905:	xor    %eax,%eax
  408907:	callq  41b320 <p125_rt_take2>
  40890c:	mov    %rax,-0x8a0(%rbp)
  408913:	lea    -0x830(%rbp),%r10
  40891a:	mov    (%r10),%rbx
  40891d:	lea    -0x830(%rbp),%r10
  408924:	mov    0x8(%r10),%r13
  408928:	lea    -0x830(%rbp),%r10
  40892f:	mov    %rbx,%r11
  408932:	mov    %r11,(%r10)
  408935:	lea    -0x830(%rbp),%r10
  40893c:	mov    %r13,%r11
  40893f:	mov    %r11,0x8(%r10)
  408943:	mov    %r13,%rdx
  408946:	mov    %rbx,%rdi
  408949:	shr    $0x38,%rdi
  40894d:	mov    %rdi,%rsi
  408950:	cmp    $0x4,%rsi
  408957:	sete   %sil
  40895b:	movzbl %sil,%esi
  40895f:	movabs $0xffffffffff,%r11
  408969:	mov    %rbx,%rdi
  40896c:	and    %r11,%rdi
  40896f:	mov    %rdi,%r8
  408972:	cmp    $0x3108280,%r8
  408979:	setae  %r8b
  40897d:	movzbl %r8b,%r8d
  408981:	and    %r8d,%esi
  408984:	mov    %rsi,%r10
  408987:	test   %r10d,%r10d
  40898a:	je     4089ed <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1d2>
  408990:	mov    %rbx,%rsi
  408993:	shr    $0x28,%rsi
  408997:	and    $0x1f,%rsi
  40899e:	mov    %rsi,%r11
  4089a1:	movabs $0x1,%rsi
  4089ab:	mov    %r11d,%ecx
  4089ae:	shl    %cl,%rsi
  4089b1:	sub    $0x1,%rsi
  4089b8:	and    %rsi,%rdx
  4089bb:	shl    $0x3,%rdi
  4089bf:	mov    %rdx,%rsi
  4089c2:	shl    $0x2,%rsi
  4089c6:	add    %rsi,%rdi
  4089c9:	mov    (%r14,%rdi,1),%edi
  4089cd:	lea    -0x8d0(%rbp),%r10
  4089d4:	mov    %rbx,%r11
  4089d7:	mov    %r11,(%r10)
  4089da:	lea    -0x8d0(%rbp),%r10
  4089e1:	mov    %rdi,%r11
  4089e4:	mov    %r11,0x8(%r10)
  4089e8:	jmpq   408a31 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x216>
  4089ed:	mov    %r12,%rdi
  4089f0:	movabs $0x48,%rsi
  4089fa:	mov    %esi,%esi
  4089fc:	lea    -0x830(%rbp),%rdx
  408a03:	movabs $0x2,%rcx
  408a0d:	mov    %ecx,%ecx
  408a0f:	lea    -0x8d0(%rbp),%r8
  408a16:	movabs $0x2,%r9
  408a20:	mov    %r9d,%r9d
  408a23:	xor    %eax,%eax
  408a25:	callq  4195f0 <p113_rt_array_pair>
  408a2a:	mov    %rax,-0x948(%rbp)
  408a31:	lea    -0x8d0(%rbp),%r10
  408a38:	mov    0x8(%r10),%rdi
  408a3c:	mov    %r12,%r10
  408a3f:	mov    %r10,0x28(%rsp)
  408a44:	mov    %r13,%r10
  408a47:	mov    %r10,0x30(%rsp)
  408a4c:	mov    %r15,%r10
  408a4f:	mov    %r10,0x38(%rsp)
  408a54:	mov    %rbx,%r10
  408a57:	mov    %r10,0x40(%rsp)
  408a5c:	mov    %rdi,%r10
  408a5f:	mov    %r10,0x48(%rsp)
  408a64:	mov    0x28(%rsp),%rdi
  408a69:	mov    0x30(%rsp),%rsi
  408a6e:	mov    0x38(%rsp),%rdx
  408a73:	mov    0x40(%rsp),%rcx
  408a78:	mov    0x48(%rsp),%r8
  408a7d:	xor    %eax,%eax
  408a7f:	callq  408752 <p113d_FID_36_112_114_111_100_117_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>
  408a84:	mov    %rax,%rdi
  408a87:	mov    %rdi,%rax
  408a8a:	mov    -0x10(%rbp),%r12
  408a8e:	mov    -0x8(%rbp),%rbx
  408a92:	mov    -0x18(%rbp),%r13
  408a96:	mov    -0x20(%rbp),%r14
  408a9a:	mov    -0x28(%rbp),%r15
  408a9e:	mov    %rbp,%rsp
  408aa1:	pop    %rbp
  408aa2:	retq   
  408aa3:	mov    %r12,%rdi
  408aa6:	movabs $0x4,%rsi
  408ab0:	mov    %esi,%esi
  408ab2:	xor    %eax,%eax
  408ab4:	callq  415d10 <p111_rt_fail>
  408ab9:	mov    %rax,-0x8a0(%rbp)
  408ac0:	movabs $0x0,%rax
  408aca:	mov    -0x10(%rbp),%r12
  408ace:	mov    -0x8(%rbp),%rbx
  408ad2:	mov    -0x18(%rbp),%r13
  408ad6:	mov    -0x20(%rbp),%r14
  408ada:	mov    -0x28(%rbp),%r15
  408ade:	mov    %rbp,%rsp
  408ae1:	pop    %rbp
  408ae2:	retq   
  408ae3:	mov    %r12,%rdi
  408ae6:	movabs $0x4,%rsi
  408af0:	mov    %esi,%esi
  408af2:	xor    %eax,%eax
  408af4:	callq  415d10 <p111_rt_fail>
  408af9:	mov    %rax,-0x8a0(%rbp)
  408b00:	movabs $0x0,%rax
  408b0a:	mov    -0x10(%rbp),%r12
  408b0e:	mov    -0x8(%rbp),%rbx
  408b12:	mov    -0x18(%rbp),%r13
  408b16:	mov    -0x20(%rbp),%r14
  408b1a:	mov    -0x28(%rbp),%r15
  408b1e:	mov    %rbp,%rsp
  408b21:	pop    %rbp
  408b22:	retq   

Disassembly of section .fini:
