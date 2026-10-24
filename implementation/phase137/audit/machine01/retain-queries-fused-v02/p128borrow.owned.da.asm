
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004078d0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_>:
  4078d0:	endbr64 
  4078d4:	push   %rbp
  4078d5:	mov    %rsp,%rbp
  4078d8:	sub    $0x828,%rsp
  4078df:	push   %rbx
  4078e0:	push   %r12
  4078e2:	push   %r13
  4078e4:	push   %r14
  4078e6:	push   %r15
  4078e8:	mov    %rsi,%rax
  4078eb:	shr    $0x28,%rax
  4078ef:	and    $0xffff,%rax
  4078f5:	cmp    $0x99,%rax
  4078fb:	sete   %cl
  4078fe:	movzbl %cl,%ecx
  407901:	cmp    $0x0,%ecx
  407904:	jne    40799d <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_+0xcd>
  40790a:	cmp    $0x9a,%rax
  407910:	je     407970 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_+0xa0>
  407912:	cmp    $0x9b,%rax
  407918:	je     40792e <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_+0x5e>
  40791a:	mov    $0x4,%esi
  40791f:	callq  432730 <p111_rt_fail>
  407924:	mov    $0x0,%eax
  407929:	jmpq   407a7d <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_+0x1ad>
  40792e:	lea    -0x820(%rbp),%rdx
  407935:	mov    %rdi,%rbx
  407938:	callq  437c20 <p125_rt_take4>
  40793d:	mov    %rbx,%rdi
  407940:	mov    -0x820(%rbp),%rbx
  407947:	mov    -0x810(%rbp),%rsi
  40794e:	mov    -0x808(%rbp),%r13
  407955:	mov    %rdi,%r12
  407958:	callq  431fa0 <p111_rt_sink>
  40795d:	mov    %r13,%rsi
  407960:	mov    %r12,%rdi
  407963:	callq  431fa0 <p111_rt_sink>
  407968:	mov    %rbx,%rax
  40796b:	jmpq   407a7d <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_+0x1ad>
  407970:	lea    -0x820(%rbp),%rdx
  407977:	mov    %rdi,%rbx
  40797a:	callq  437750 <p125_rt_take2>
  40797f:	mov    %rbx,%rdi
  407982:	mov    -0x820(%rbp),%rbx
  407989:	mov    -0x818(%rbp),%rsi
  407990:	callq  431fa0 <p111_rt_sink>
  407995:	mov    %rbx,%rax
  407998:	jmpq   407a7d <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_97_+0x1ad>
  40799d:	mov    $0x9,%ecx
  4079a2:	lea    -0x820(%rbp),%rdx
  4079a9:	mov    %rdi,%rbx
  4079ac:	callq  432190 <p111_rt_take>
  4079b1:	mov    %rbx,%rdi
  4079b4:	mov    -0x820(%rbp),%rsi
  4079bb:	mov    -0x818(%rbp),%r13
  4079c2:	mov    -0x810(%rbp),%rbx
  4079c9:	mov    -0x808(%rbp),%r15
  4079d0:	mov    -0x800(%rbp),%r14
  4079d7:	mov    -0x7f8(%rbp),%r12
  4079de:	mov    %r12,-0x8(%rbp)
  4079e2:	mov    -0x7f0(%rbp),%r12
  4079e9:	mov    %r12,-0x10(%rbp)
  4079ed:	mov    -0x7e8(%rbp),%r12
  4079f4:	mov    %r12,-0x18(%rbp)
  4079f8:	mov    -0x7e0(%rbp),%r12
  4079ff:	mov    %r12,-0x20(%rbp)
  407a03:	mov    %rdi,%r12
  407a06:	callq  431fa0 <p111_rt_sink>
  407a0b:	mov    %r13,%rsi
  407a0e:	mov    %r12,%rdi
  407a11:	mov    -0x8(%rbp),%r13
  407a15:	mov    %rdi,%r12
  407a18:	callq  431fa0 <p111_rt_sink>
  407a1d:	mov    %r15,%rsi
  407a20:	mov    %r12,%rdi
  407a23:	mov    -0x10(%rbp),%r15
  407a27:	mov    %rdi,%r12
  407a2a:	callq  431fa0 <p111_rt_sink>
  407a2f:	mov    %r14,%rsi
  407a32:	mov    %r12,%rdi
  407a35:	mov    -0x18(%rbp),%r14
  407a39:	mov    %rdi,%r12
  407a3c:	callq  431fa0 <p111_rt_sink>
  407a41:	mov    %r13,%rsi
  407a44:	mov    %r12,%rdi
  407a47:	mov    -0x20(%rbp),%r13
  407a4b:	mov    %rdi,%r12
  407a4e:	callq  431fa0 <p111_rt_sink>
  407a53:	mov    %r15,%rsi
  407a56:	mov    %r12,%rdi
  407a59:	mov    %rdi,%r12
  407a5c:	callq  431fa0 <p111_rt_sink>
  407a61:	mov    %r14,%rsi
  407a64:	mov    %r12,%rdi
  407a67:	mov    %rdi,%r12
  407a6a:	callq  431fa0 <p111_rt_sink>
  407a6f:	mov    %r13,%rsi
  407a72:	mov    %r12,%rdi
  407a75:	callq  431fa0 <p111_rt_sink>
  407a7a:	mov    %rbx,%rax
  407a7d:	pop    %r15
  407a7f:	pop    %r14
  407a81:	pop    %r13
  407a83:	pop    %r12
  407a85:	pop    %rbx
  407a86:	leaveq 
  407a87:	retq   

Disassembly of section .fini:
