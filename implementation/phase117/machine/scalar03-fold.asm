
selfhost/build/phase111/p117-scalar03-variation-local-fold-128-0-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004056a0 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_>:
  4056a0:	endbr64 
  4056a4:	push   %rbp
  4056a5:	mov    %rsp,%rbp
  4056a8:	sub    $0x78,%rsp
  4056ac:	push   %rbx
  4056ad:	push   %r12
  4056af:	push   %r13
  4056b1:	push   %r14
  4056b3:	push   %r15
  4056b5:	mov    %rsi,-0x30(%rbp)
  4056b9:	mov    %rdi,-0x18(%rbp)
  4056bd:	mov    (%rdi),%rax
  4056c0:	mov    %rax,-0x28(%rbp)
  4056c4:	data16 nopw %cs:0x0(%rax,%rax,1)
  4056cf:	nop
  4056d0:	mov    %r9,-0x10(%rbp)
  4056d4:	cmp    $0x0,%rdx
  4056d8:	je     405813 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x173>
  4056de:	mov    %r8,-0x68(%rbp)
  4056e2:	mov    %rcx,-0x60(%rbp)
  4056e6:	mov    %r8,%rsi
  4056e9:	shr    $0x38,%rsi
  4056ed:	cmp    $0x6,%rsi
  4056f1:	sete   %r12b
  4056f5:	movzbl %r12b,%r12d
  4056f9:	movabs $0xffffffffff,%rsi
  405703:	mov    %r8,%r11
  405706:	and    %rsi,%r11
  405709:	cmp    $0x3108280,%r11
  405710:	setae  %r13b
  405714:	movzbl %r13b,%r13d
  405718:	mov    %r12d,%r10d
  40571b:	and    %r13d,%r10d
  40571e:	mov    %rcx,%rbx
  405721:	mov    %r8,%rcx
  405724:	shr    $0x28,%rcx
  405728:	and    $0x1f,%rcx
  40572c:	mov    $0x1,%esi
  405731:	shl    %cl,%rsi
  405734:	mov    %rbx,%rcx
  405737:	sub    $0x1,%rsi
  40573b:	and    %rcx,%rsi
  40573e:	add    %r11,%rsi
  405741:	shl    $0x3,%rsi
  405745:	mov    %rsi,-0x20(%rbp)
  405749:	cmp    $0x0,%r10d
  40574d:	jne    405790 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0xf0>
  40574f:	mov    $0x2,%r9d
  405755:	mov    %r8,%r15
  405758:	lea    -0x58(%rbp),%r8
  40575c:	mov    %rcx,%r14
  40575f:	mov    $0x2,%ecx
  405764:	mov    %rdx,%rbx
  405767:	lea    -0x68(%rbp),%rdx
  40576b:	mov    $0x48,%esi
  405770:	callq  41a950 <p113_rt_array_pair>
  405775:	mov    %r15,%r8
  405778:	mov    %r14,%rcx
  40577b:	mov    %rbx,%rdx
  40577e:	mov    -0x10(%rbp),%r9
  405782:	mov    -0x20(%rbp),%rsi
  405786:	mov    -0x28(%rbp),%rax
  40578a:	mov    -0x18(%rbp),%rdi
  40578e:	jmp    40579c <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0xfc>
  405790:	mov    (%rax,%rsi,1),%r10
  405794:	mov    %r8,-0x58(%rbp)
  405798:	mov    %r10,-0x50(%rbp)
  40579c:	mov    %r9,%rbx
  40579f:	mov    -0x50(%rbp),%r9
  4057a3:	mov    %r8,%r14
  4057a6:	mov    %ebx,%r8d
  4057a9:	mov    %r9d,%r9d
  4057ac:	add    %r9d,%r8d
  4057af:	mov    %r8d,%r15d
  4057b2:	mov    %ecx,%ebx
  4057b4:	mov    %rcx,%r8
  4057b7:	mov    %rbx,%rcx
  4057ba:	xor    %r15,%rcx
  4057bd:	mov    %r14,-0x48(%rbp)
  4057c1:	mov    %r8,-0x40(%rbp)
  4057c5:	mov    %rcx,-0x38(%rbp)
  4057c9:	test   %r12d,%r13d
  4057cc:	jne    4057f9 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x159>
  4057ce:	mov    $0x3,%ecx
  4057d3:	mov    %rdx,%r13
  4057d6:	lea    -0x48(%rbp),%rdx
  4057da:	mov    $0x49,%esi
  4057df:	mov    %rdi,%r12
  4057e2:	callq  417650 <p111_rt_op>
  4057e7:	mov    %r15,%r9
  4057ea:	mov    %r14,%r8
  4057ed:	mov    %r13,%rdx
  4057f0:	mov    %r12,%rdi
  4057f3:	mov    -0x28(%rbp),%rax
  4057f7:	jmp    405803 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x163>
  4057f9:	mov    %r14,%r8
  4057fc:	mov    %r15,%r9
  4057ff:	mov    %rcx,(%rax,%rsi,1)
  405803:	sub    $0x1,%rdx
  405807:	mov    %ebx,%ecx
  405809:	add    $0x1,%ecx
  40580c:	mov    %ecx,%ecx
  40580e:	jmpq   4056d0 <p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_+0x30>
  405813:	mov    -0x30(%rbp),%rsi
  405817:	mov    %r8,(%rsi)
  40581a:	mov    %r9,0x8(%rsi)
  40581e:	mov    $0x0,%eax
  405823:	pop    %r15
  405825:	pop    %r14
  405827:	pop    %r13
  405829:	pop    %r12
  40582b:	pop    %rbx
  40582c:	leaveq 
  40582d:	retq   

Disassembly of section .fini:
