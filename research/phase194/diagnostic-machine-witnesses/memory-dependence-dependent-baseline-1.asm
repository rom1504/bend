
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-baseline-build04/memory-dependence-dependent/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040887c <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
  40887c:	push   %rbp
  40887d:	mov    %rsp,%rbp
  408880:	sub    $0x9f0,%rsp
  408887:	mov    %r12,-0x10(%rbp)
  40888b:	mov    %rbx,-0x8(%rbp)
  40888f:	mov    %r13,-0x18(%rbp)
  408893:	mov    %r14,-0x20(%rbp)
  408897:	mov    %r15,-0x28(%rbp)
  40889b:	mov    %rdi,%rax
  40889e:	mov    %rax,%r12
  4088a1:	mov    %rsi,%rax
  4088a4:	mov    %rax,%rsi
  4088a7:	mov    (%r12),%r14
  4088ab:	mov    %rsi,%rdi
  4088ae:	shr    $0x28,%rdi
  4088b2:	and    $0xffff,%rdi
  4088b9:	movabs $0x8,%r11
  4088c3:	cmp    %r11,%rdi
  4088c6:	jne    408b44 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2c8>
  4088cc:	mov    %r12,%r10
  4088cf:	mov    %r10,0x18(%rsp)
  4088d4:	mov    %rsi,%r10
  4088d7:	mov    %r10,0x20(%rsp)
  4088dc:	lea    -0x830(%rbp),%r10
  4088e3:	mov    %r10,0x28(%rsp)
  4088e8:	mov    0x18(%rsp),%rdi
  4088ed:	mov    0x20(%rsp),%rsi
  4088f2:	mov    0x28(%rsp),%rdx
  4088f7:	xor    %eax,%eax
  4088f9:	callq  41b3c0 <p125_rt_take2>
  4088fe:	mov    %rax,-0x8a0(%rbp)
  408905:	lea    -0x830(%rbp),%r10
  40890c:	mov    (%r10),%rsi
  40890f:	lea    -0x830(%rbp),%r10
  408916:	mov    0x8(%r10),%r15
  40891a:	mov    %rsi,%rdi
  40891d:	shr    $0x28,%rdi
  408921:	and    $0xffff,%rdi
  408928:	movabs $0x8,%r11
  408932:	cmp    %r11,%rdi
  408935:	jne    408b04 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x288>
  40893b:	mov    %r12,%r10
  40893e:	mov    %r10,0x18(%rsp)
  408943:	mov    %rsi,%r10
  408946:	mov    %r10,0x20(%rsp)
  40894b:	lea    -0x830(%rbp),%r10
  408952:	mov    %r10,0x28(%rsp)
  408957:	mov    0x18(%rsp),%rdi
  40895c:	mov    0x20(%rsp),%rsi
  408961:	mov    0x28(%rsp),%rdx
  408966:	xor    %eax,%eax
  408968:	callq  41b3c0 <p125_rt_take2>
  40896d:	mov    %rax,-0x8a0(%rbp)
  408974:	lea    -0x830(%rbp),%r10
  40897b:	mov    (%r10),%rbx
  40897e:	lea    -0x830(%rbp),%r10
  408985:	mov    0x8(%r10),%r13
  408989:	lea    -0x830(%rbp),%r10
  408990:	mov    %rbx,%r11
  408993:	mov    %r11,(%r10)
  408996:	lea    -0x830(%rbp),%r10
  40899d:	mov    %r13,%r11
  4089a0:	mov    %r11,0x8(%r10)
  4089a4:	mov    %r13,%rdx
  4089a7:	mov    %rbx,%rdi
  4089aa:	shr    $0x38,%rdi
  4089ae:	mov    %rdi,%rsi
  4089b1:	cmp    $0x4,%rsi
  4089b8:	sete   %sil
  4089bc:	movzbl %sil,%esi
  4089c0:	movabs $0xffffffffff,%r11
  4089ca:	mov    %rbx,%rdi
  4089cd:	and    %r11,%rdi
  4089d0:	mov    %rdi,%r8
  4089d3:	cmp    $0x3108280,%r8
  4089da:	setae  %r8b
  4089de:	movzbl %r8b,%r8d
  4089e2:	and    %r8d,%esi
  4089e5:	mov    %rsi,%r10
  4089e8:	test   %r10d,%r10d
  4089eb:	je     408a4e <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1d2>
  4089f1:	mov    %rbx,%rsi
  4089f4:	shr    $0x28,%rsi
  4089f8:	and    $0x1f,%rsi
  4089ff:	mov    %rsi,%r11
  408a02:	movabs $0x1,%rsi
  408a0c:	mov    %r11d,%ecx
  408a0f:	shl    %cl,%rsi
  408a12:	sub    $0x1,%rsi
  408a19:	and    %rsi,%rdx
  408a1c:	shl    $0x3,%rdi
  408a20:	mov    %rdx,%rsi
  408a23:	shl    $0x2,%rsi
  408a27:	add    %rsi,%rdi
  408a2a:	mov    (%r14,%rdi,1),%edi
  408a2e:	lea    -0x8d0(%rbp),%r10
  408a35:	mov    %rbx,%r11
  408a38:	mov    %r11,(%r10)
  408a3b:	lea    -0x8d0(%rbp),%r10
  408a42:	mov    %rdi,%r11
  408a45:	mov    %r11,0x8(%r10)
  408a49:	jmpq   408a92 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x216>
  408a4e:	mov    %r12,%rdi
  408a51:	movabs $0x48,%rsi
  408a5b:	mov    %esi,%esi
  408a5d:	lea    -0x830(%rbp),%rdx
  408a64:	movabs $0x2,%rcx
  408a6e:	mov    %ecx,%ecx
  408a70:	lea    -0x8d0(%rbp),%r8
  408a77:	movabs $0x2,%r9
  408a81:	mov    %r9d,%r9d
  408a84:	xor    %eax,%eax
  408a86:	callq  419690 <p113_rt_array_pair>
  408a8b:	mov    %rax,-0x948(%rbp)
  408a92:	lea    -0x8d0(%rbp),%r10
  408a99:	mov    0x8(%r10),%rdi
  408a9d:	mov    %r12,%r10
  408aa0:	mov    %r10,0x28(%rsp)
  408aa5:	mov    %r13,%r10
  408aa8:	mov    %r10,0x30(%rsp)
  408aad:	mov    %r15,%r10
  408ab0:	mov    %r10,0x38(%rsp)
  408ab5:	mov    %rbx,%r10
  408ab8:	mov    %r10,0x40(%rsp)
  408abd:	mov    %rdi,%r10
  408ac0:	mov    %r10,0x48(%rsp)
  408ac5:	mov    0x28(%rsp),%rdi
  408aca:	mov    0x30(%rsp),%rsi
  408acf:	mov    0x38(%rsp),%rdx
  408ad4:	mov    0x40(%rsp),%rcx
  408ad9:	mov    0x48(%rsp),%r8
  408ade:	xor    %eax,%eax
  408ae0:	callq  4087b3 <p113d_FID_36_112_114_111_100_117_99_116_46_112_49_57_52_46_114_101_97_100_95_115_116_101_112_>
  408ae5:	mov    %rax,%rdi
  408ae8:	mov    %rdi,%rax
  408aeb:	mov    -0x10(%rbp),%r12
  408aef:	mov    -0x8(%rbp),%rbx
  408af3:	mov    -0x18(%rbp),%r13
  408af7:	mov    -0x20(%rbp),%r14
  408afb:	mov    -0x28(%rbp),%r15
  408aff:	mov    %rbp,%rsp
  408b02:	pop    %rbp
  408b03:	retq   
  408b04:	mov    %r12,%rdi
  408b07:	movabs $0x4,%rsi
  408b11:	mov    %esi,%esi
  408b13:	xor    %eax,%eax
  408b15:	callq  415db0 <p111_rt_fail>
  408b1a:	mov    %rax,-0x8a0(%rbp)
  408b21:	movabs $0x0,%rax
  408b2b:	mov    -0x10(%rbp),%r12
  408b2f:	mov    -0x8(%rbp),%rbx
  408b33:	mov    -0x18(%rbp),%r13
  408b37:	mov    -0x20(%rbp),%r14
  408b3b:	mov    -0x28(%rbp),%r15
  408b3f:	mov    %rbp,%rsp
  408b42:	pop    %rbp
  408b43:	retq   
  408b44:	mov    %r12,%rdi
  408b47:	movabs $0x4,%rsi
  408b51:	mov    %esi,%esi
  408b53:	xor    %eax,%eax
  408b55:	callq  415db0 <p111_rt_fail>
  408b5a:	mov    %rax,-0x8a0(%rbp)
  408b61:	movabs $0x0,%rax
  408b6b:	mov    -0x10(%rbp),%r12
  408b6f:	mov    -0x8(%rbp),%rbx
  408b73:	mov    -0x18(%rbp),%r13
  408b77:	mov    -0x20(%rbp),%r14
  408b7b:	mov    -0x28(%rbp),%r15
  408b7f:	mov    %rbp,%rsp
  408b82:	pop    %rbp
  408b83:	retq   

Disassembly of section .fini:
