
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-commutative-build01/memory-dependence-sequential/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040884a <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
  40884a:	push   %rbp
  40884b:	mov    %rsp,%rbp
  40884e:	sub    $0x9f0,%rsp
  408855:	mov    %r12,-0x10(%rbp)
  408859:	mov    %rbx,-0x8(%rbp)
  40885d:	mov    %r13,-0x18(%rbp)
  408861:	mov    %r14,-0x20(%rbp)
  408865:	mov    %r15,-0x28(%rbp)
  408869:	mov    %rdi,%rax
  40886c:	mov    %rax,%r12
  40886f:	mov    %rsi,%rax
  408872:	mov    %rax,%rsi
  408875:	mov    (%r12),%r14
  408879:	mov    %rsi,%rdi
  40887c:	shr    $0x28,%rdi
  408880:	and    $0xffff,%rdi
  408887:	movabs $0x8,%r11
  408891:	cmp    %r11,%rdi
  408894:	jne    408b12 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2c8>
  40889a:	mov    %r12,%r10
  40889d:	mov    %r10,0x18(%rsp)
  4088a2:	mov    %rsi,%r10
  4088a5:	mov    %r10,0x20(%rsp)
  4088aa:	lea    -0x830(%rbp),%r10
  4088b1:	mov    %r10,0x28(%rsp)
  4088b6:	mov    0x18(%rsp),%rdi
  4088bb:	mov    0x20(%rsp),%rsi
  4088c0:	mov    0x28(%rsp),%rdx
  4088c5:	xor    %eax,%eax
  4088c7:	callq  41b350 <p125_rt_take2>
  4088cc:	mov    %rax,-0x8a0(%rbp)
  4088d3:	lea    -0x830(%rbp),%r10
  4088da:	mov    (%r10),%rsi
  4088dd:	lea    -0x830(%rbp),%r10
  4088e4:	mov    0x8(%r10),%r15
  4088e8:	mov    %rsi,%rdi
  4088eb:	shr    $0x28,%rdi
  4088ef:	and    $0xffff,%rdi
  4088f6:	movabs $0x8,%r11
  408900:	cmp    %r11,%rdi
  408903:	jne    408ad2 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x288>
  408909:	mov    %r12,%r10
  40890c:	mov    %r10,0x18(%rsp)
  408911:	mov    %rsi,%r10
  408914:	mov    %r10,0x20(%rsp)
  408919:	lea    -0x830(%rbp),%r10
  408920:	mov    %r10,0x28(%rsp)
  408925:	mov    0x18(%rsp),%rdi
  40892a:	mov    0x20(%rsp),%rsi
  40892f:	mov    0x28(%rsp),%rdx
  408934:	xor    %eax,%eax
  408936:	callq  41b350 <p125_rt_take2>
  40893b:	mov    %rax,-0x8a0(%rbp)
  408942:	lea    -0x830(%rbp),%r10
  408949:	mov    (%r10),%rbx
  40894c:	lea    -0x830(%rbp),%r10
  408953:	mov    0x8(%r10),%r13
  408957:	lea    -0x830(%rbp),%r10
  40895e:	mov    %rbx,%r11
  408961:	mov    %r11,(%r10)
  408964:	lea    -0x830(%rbp),%r10
  40896b:	mov    %r13,%r11
  40896e:	mov    %r11,0x8(%r10)
  408972:	mov    %r13,%rdx
  408975:	mov    %rbx,%rdi
  408978:	shr    $0x38,%rdi
  40897c:	mov    %rdi,%rsi
  40897f:	cmp    $0x4,%rsi
  408986:	sete   %sil
  40898a:	movzbl %sil,%esi
  40898e:	movabs $0xffffffffff,%r11
  408998:	mov    %rbx,%rdi
  40899b:	and    %r11,%rdi
  40899e:	mov    %rdi,%r8
  4089a1:	cmp    $0x3108280,%r8
  4089a8:	setae  %r8b
  4089ac:	movzbl %r8b,%r8d
  4089b0:	and    %r8d,%esi
  4089b3:	mov    %rsi,%r10
  4089b6:	test   %r10d,%r10d
  4089b9:	je     408a1c <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1d2>
  4089bf:	mov    %rbx,%rsi
  4089c2:	shr    $0x28,%rsi
  4089c6:	and    $0x1f,%rsi
  4089cd:	mov    %rsi,%r11
  4089d0:	movabs $0x1,%rsi
  4089da:	mov    %r11d,%ecx
  4089dd:	shl    %cl,%rsi
  4089e0:	sub    $0x1,%rsi
  4089e7:	and    %rsi,%rdx
  4089ea:	shl    $0x3,%rdi
  4089ee:	mov    %rdx,%rsi
  4089f1:	shl    $0x2,%rsi
  4089f5:	add    %rsi,%rdi
  4089f8:	mov    (%r14,%rdi,1),%edi
  4089fc:	lea    -0x8d0(%rbp),%r10
  408a03:	mov    %rbx,%r11
  408a06:	mov    %r11,(%r10)
  408a09:	lea    -0x8d0(%rbp),%r10
  408a10:	mov    %rdi,%r11
  408a13:	mov    %r11,0x8(%r10)
  408a17:	jmpq   408a60 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x216>
  408a1c:	mov    %r12,%rdi
  408a1f:	movabs $0x48,%rsi
  408a29:	mov    %esi,%esi
  408a2b:	lea    -0x830(%rbp),%rdx
  408a32:	movabs $0x2,%rcx
  408a3c:	mov    %ecx,%ecx
  408a3e:	lea    -0x8d0(%rbp),%r8
  408a45:	movabs $0x2,%r9
  408a4f:	mov    %r9d,%r9d
  408a52:	xor    %eax,%eax
  408a54:	callq  419620 <p113_rt_array_pair>
  408a59:	mov    %rax,-0x948(%rbp)
  408a60:	lea    -0x8d0(%rbp),%r10
  408a67:	mov    0x8(%r10),%rdi
  408a6b:	mov    %r12,%r10
  408a6e:	mov    %r10,0x28(%rsp)
  408a73:	mov    %r13,%r10
  408a76:	mov    %r10,0x30(%rsp)
  408a7b:	mov    %r15,%r10
  408a7e:	mov    %r10,0x38(%rsp)
  408a83:	mov    %rbx,%r10
  408a86:	mov    %r10,0x40(%rsp)
  408a8b:	mov    %rdi,%r10
  408a8e:	mov    %r10,0x48(%rsp)
  408a93:	mov    0x28(%rsp),%rdi
  408a98:	mov    0x30(%rsp),%rsi
  408a9d:	mov    0x38(%rsp),%rdx
  408aa2:	mov    0x40(%rsp),%rcx
  408aa7:	mov    0x48(%rsp),%r8
  408aac:	xor    %eax,%eax
  408aae:	callq  408770 <p113d_FID_36_112_114_111_100_117_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>
  408ab3:	mov    %rax,%rdi
  408ab6:	mov    %rdi,%rax
  408ab9:	mov    -0x10(%rbp),%r12
  408abd:	mov    -0x8(%rbp),%rbx
  408ac1:	mov    -0x18(%rbp),%r13
  408ac5:	mov    -0x20(%rbp),%r14
  408ac9:	mov    -0x28(%rbp),%r15
  408acd:	mov    %rbp,%rsp
  408ad0:	pop    %rbp
  408ad1:	retq   
  408ad2:	mov    %r12,%rdi
  408ad5:	movabs $0x4,%rsi
  408adf:	mov    %esi,%esi
  408ae1:	xor    %eax,%eax
  408ae3:	callq  415d40 <p111_rt_fail>
  408ae8:	mov    %rax,-0x8a0(%rbp)
  408aef:	movabs $0x0,%rax
  408af9:	mov    -0x10(%rbp),%r12
  408afd:	mov    -0x8(%rbp),%rbx
  408b01:	mov    -0x18(%rbp),%r13
  408b05:	mov    -0x20(%rbp),%r14
  408b09:	mov    -0x28(%rbp),%r15
  408b0d:	mov    %rbp,%rsp
  408b10:	pop    %rbp
  408b11:	retq   
  408b12:	mov    %r12,%rdi
  408b15:	movabs $0x4,%rsi
  408b1f:	mov    %esi,%esi
  408b21:	xor    %eax,%eax
  408b23:	callq  415d40 <p111_rt_fail>
  408b28:	mov    %rax,-0x8a0(%rbp)
  408b2f:	movabs $0x0,%rax
  408b39:	mov    -0x10(%rbp),%r12
  408b3d:	mov    -0x8(%rbp),%rbx
  408b41:	mov    -0x18(%rbp),%r13
  408b45:	mov    -0x20(%rbp),%r14
  408b49:	mov    -0x28(%rbp),%r15
  408b4d:	mov    %rbp,%rsp
  408b50:	pop    %rbp
  408b51:	retq   

Disassembly of section .fini:
