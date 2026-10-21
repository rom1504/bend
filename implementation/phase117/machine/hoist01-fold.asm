
selfhost/build/phase111/p117-hoist01-variation-local-fold-128-0-build/program:     file format elf64-x86-64


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
  405749:	mov    (%rdi),%rax
  40574c:	mov    %rax,-0x28(%rbp)
  405750:	mov    %r8,%rsi
  405753:	shr    $0x38,%rsi
  405757:	cmp    $0x4,%rsi
  40575b:	sete   %sil
  40575f:	movzbl %sil,%esi
  405763:	mov    %esi,-0x20(%rbp)
  405766:	movabs $0xffffffffff,%r10
  405770:	mov    %r8,%rbx
  405773:	and    %r10,%rbx
  405776:	cmp    $0x3108280,%rbx
  40577d:	setae  %r10b
  405781:	movzbl %r10b,%r10d
  405785:	mov    %r10d,-0x1c(%rbp)
  405789:	mov    %rcx,%r12
  40578c:	mov    %r8,%rcx
  40578f:	shr    $0x28,%rcx
  405793:	and    $0x1f,%rcx
  405797:	mov    $0x1,%r11d
  40579d:	shl    %cl,%r11
  4057a0:	mov    %r12,%rcx
  4057a3:	sub    $0x1,%r11
  4057a7:	mov    %r11,-0x18(%rbp)
  4057ab:	shl    $0x3,%rbx
  4057af:	add    %rax,%rbx
  4057b2:	mov    %rbx,-0x10(%rbp)
  4057b6:	nopw   %cs:0x0(%rax,%rax,1)
  4057c0:	cmp    $0x0,%rdx
  4057c4:	je     40591d <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x1ed>
  4057ca:	mov    %r8,-0x68(%rbp)
  4057ce:	mov    %rcx,-0x60(%rbp)
  4057d2:	mov    %r8,%r12
  4057d5:	shr    $0x38,%r12
  4057d9:	cmp    $0x4,%r12
  4057dd:	sete   %r13b
  4057e1:	movzbl %r13b,%r13d
  4057e5:	movabs $0xffffffffff,%r12
  4057ef:	and    %r8,%r12
  4057f2:	cmp    $0x3108280,%r12
  4057f9:	setae  %r14b
  4057fd:	movzbl %r14b,%r14d
  405801:	test   %r13d,%r14d
  405804:	jne    405856 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x126>
  405806:	mov    %r9,%r15
  405809:	mov    $0x2,%r9d
  40580f:	mov    %r8,%r14
  405812:	lea    -0x58(%rbp),%r8
  405816:	mov    %rcx,%r13
  405819:	mov    $0x2,%ecx
  40581e:	mov    %rdx,%r12
  405821:	lea    -0x68(%rbp),%rdx
  405825:	mov    $0x48,%esi
  40582a:	mov    %rdi,%rbx
  40582d:	callq  41abd0 <p113_rt_array_pair>
  405832:	mov    %r15,%r9
  405835:	mov    %r14,%r8
  405838:	mov    %r13,%rcx
  40583b:	mov    %r12,%rdx
  40583e:	mov    %rbx,%rdi
  405841:	mov    -0x10(%rbp),%rbx
  405845:	mov    -0x18(%rbp),%r11
  405849:	mov    -0x1c(%rbp),%r10d
  40584d:	mov    -0x20(%rbp),%esi
  405850:	mov    -0x28(%rbp),%rax
  405854:	jmp    40588e <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x15e>
  405856:	mov    %rcx,%r14
  405859:	mov    %r8,%rcx
  40585c:	shr    $0x28,%rcx
  405860:	and    $0x1f,%rcx
  405864:	mov    $0x1,%r13d
  40586a:	shl    %cl,%r13
  40586d:	mov    %r14,%rcx
  405870:	sub    $0x1,%r13
  405874:	and    %rcx,%r13
  405877:	shl    $0x3,%r12
  40587b:	shl    $0x2,%r13
  40587f:	add    %r13,%r12
  405882:	mov    (%rax,%r12,1),%r12d
  405886:	mov    %r8,-0x58(%rbp)
  40588a:	mov    %r12,-0x50(%rbp)
  40588e:	mov    %r9,%r12
  405891:	mov    -0x50(%rbp),%r9
  405895:	mov    %r8,%r14
  405898:	mov    %r12d,%r8d
  40589b:	mov    %r9d,%r9d
  40589e:	add    %r9d,%r8d
  4058a1:	mov    %r8d,%r15d
  4058a4:	mov    %ecx,%r12d
  4058a7:	mov    %rcx,%r13
  4058aa:	mov    %r12,%rcx
  4058ad:	xor    %r15,%rcx
  4058b0:	mov    %r14,-0x48(%rbp)
  4058b4:	mov    %r13,-0x40(%rbp)
  4058b8:	mov    %rcx,-0x38(%rbp)
  4058bc:	test   %esi,%r10d
  4058bf:	jne    4058fb <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x1cb>
  4058c1:	mov    $0x3,%ecx
  4058c6:	mov    %rdx,%r13
  4058c9:	lea    -0x48(%rbp),%rdx
  4058cd:	mov    $0x49,%esi
  4058d2:	mov    %rdi,%rbx
  4058d5:	callq  417900 <p111_rt_op>
  4058da:	mov    %r15,%r9
  4058dd:	mov    %r14,%r8
  4058e0:	mov    %r13,%rdx
  4058e3:	mov    %rbx,%rdi
  4058e6:	mov    -0x10(%rbp),%rbx
  4058ea:	mov    -0x18(%rbp),%r11
  4058ee:	mov    -0x1c(%rbp),%r10d
  4058f2:	mov    -0x20(%rbp),%esi
  4058f5:	mov    -0x28(%rbp),%rax
  4058f9:	jmp    40590c <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x1dc>
  4058fb:	mov    %r14,%r8
  4058fe:	mov    %r15,%r9
  405901:	and    %r11,%r13
  405904:	shl    $0x2,%r13
  405908:	mov    %ecx,(%rbx,%r13,1)
  40590c:	sub    $0x1,%rdx
  405910:	mov    %r12d,%ecx
  405913:	add    $0x1,%ecx
  405916:	mov    %ecx,%ecx
  405918:	jmpq   4057c0 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x90>
  40591d:	mov    -0x30(%rbp),%rsi
  405921:	mov    %r8,(%rsi)
  405924:	mov    %r9,0x8(%rsi)
  405928:	mov    $0x0,%eax
  40592d:	pop    %r15
  40592f:	pop    %r14
  405931:	pop    %r13
  405933:	pop    %r12
  405935:	pop    %rbx
  405936:	leaveq 
  405937:	retq   

Disassembly of section .fini:
