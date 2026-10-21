
selfhost/build/phase111/p117-packed01-variation-local-fold-128-0-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000405730 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_>:
  405730:	endbr64 
  405734:	push   %rbp
  405735:	mov    %rsp,%rbp
  405738:	sub    $0x78,%rsp
  40573c:	push   %rbx
  40573d:	push   %r12
  40573f:	push   %r13
  405741:	push   %r14
  405743:	push   %r15
  405745:	mov    %rsi,-0x30(%rbp)
  405749:	mov    %rdi,-0x18(%rbp)
  40574d:	mov    (%rdi),%rax
  405750:	mov    %rax,-0x28(%rbp)
  405754:	data16 nopw %cs:0x0(%rax,%rax,1)
  40575f:	nop
  405760:	mov    %r9,-0x10(%rbp)
  405764:	cmp    $0x0,%rdx
  405768:	je     4058a4 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x174>
  40576e:	mov    %r8,-0x68(%rbp)
  405772:	mov    %rcx,-0x60(%rbp)
  405776:	mov    %r8,%rsi
  405779:	shr    $0x38,%rsi
  40577d:	cmp    $0x4,%rsi
  405781:	sete   %r12b
  405785:	movzbl %r12b,%r12d
  405789:	movabs $0xffffffffff,%rsi
  405793:	and    %r8,%rsi
  405796:	cmp    $0x3108280,%rsi
  40579d:	setae  %r13b
  4057a1:	movzbl %r13b,%r13d
  4057a5:	mov    %r12d,%r10d
  4057a8:	and    %r13d,%r10d
  4057ab:	mov    %rcx,%rbx
  4057ae:	mov    %r8,%rcx
  4057b1:	shr    $0x28,%rcx
  4057b5:	and    $0x1f,%rcx
  4057b9:	mov    $0x1,%r11d
  4057bf:	shl    %cl,%r11
  4057c2:	mov    %rbx,%rcx
  4057c5:	sub    $0x1,%r11
  4057c9:	shl    $0x3,%rsi
  4057cd:	and    %rcx,%r11
  4057d0:	shl    $0x2,%r11
  4057d4:	add    %r11,%rsi
  4057d7:	mov    %rsi,-0x20(%rbp)
  4057db:	cmp    $0x0,%r10d
  4057df:	jne    405822 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0xf2>
  4057e1:	mov    $0x2,%r9d
  4057e7:	mov    %r8,%r15
  4057ea:	lea    -0x58(%rbp),%r8
  4057ee:	mov    %rcx,%r14
  4057f1:	mov    $0x2,%ecx
  4057f6:	mov    %rdx,%rbx
  4057f9:	lea    -0x68(%rbp),%rdx
  4057fd:	mov    $0x48,%esi
  405802:	callq  41ab50 <p113_rt_array_pair>
  405807:	mov    %r15,%r8
  40580a:	mov    %r14,%rcx
  40580d:	mov    %rbx,%rdx
  405810:	mov    -0x10(%rbp),%r9
  405814:	mov    -0x20(%rbp),%rsi
  405818:	mov    -0x28(%rbp),%rax
  40581c:	mov    -0x18(%rbp),%rdi
  405820:	jmp    40582e <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0xfe>
  405822:	mov    (%rax,%rsi,1),%r10d
  405826:	mov    %r8,-0x58(%rbp)
  40582a:	mov    %r10,-0x50(%rbp)
  40582e:	mov    %r9,%rbx
  405831:	mov    -0x50(%rbp),%r9
  405835:	mov    %r8,%r14
  405838:	mov    %ebx,%r8d
  40583b:	mov    %r9d,%r9d
  40583e:	add    %r9d,%r8d
  405841:	mov    %r8d,%r15d
  405844:	mov    %ecx,%ebx
  405846:	mov    %rcx,%r8
  405849:	mov    %rbx,%rcx
  40584c:	xor    %r15,%rcx
  40584f:	mov    %r14,-0x48(%rbp)
  405853:	mov    %r8,-0x40(%rbp)
  405857:	mov    %rcx,-0x38(%rbp)
  40585b:	test   %r12d,%r13d
  40585e:	jne    40588b <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x15b>
  405860:	mov    $0x3,%ecx
  405865:	mov    %rdx,%r13
  405868:	lea    -0x48(%rbp),%rdx
  40586c:	mov    $0x49,%esi
  405871:	mov    %rdi,%r12
  405874:	callq  417880 <p111_rt_op>
  405879:	mov    %r15,%r9
  40587c:	mov    %r14,%r8
  40587f:	mov    %r13,%rdx
  405882:	mov    %r12,%rdi
  405885:	mov    -0x28(%rbp),%rax
  405889:	jmp    405894 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x164>
  40588b:	mov    %r14,%r8
  40588e:	mov    %r15,%r9
  405891:	mov    %ecx,(%rax,%rsi,1)
  405894:	sub    $0x1,%rdx
  405898:	mov    %ebx,%ecx
  40589a:	add    $0x1,%ecx
  40589d:	mov    %ecx,%ecx
  40589f:	jmpq   405760 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x30>
  4058a4:	mov    -0x30(%rbp),%rsi
  4058a8:	mov    %r8,(%rsi)
  4058ab:	mov    %r9,0x8(%rsi)
  4058af:	mov    $0x0,%eax
  4058b4:	pop    %r15
  4058b6:	pop    %r14
  4058b8:	pop    %r13
  4058ba:	pop    %r12
  4058bc:	pop    %rbx
  4058bd:	leaveq 
  4058be:	retq   

Disassembly of section .fini:
