
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004076f0 <p113d_FID_36_100_105_114_101_99_116_46_100_99_>:
  4076f0:	endbr64 
  4076f4:	push   %rbp
  4076f5:	mov    %rsp,%rbp
  4076f8:	sub    $0x828,%rsp
  4076ff:	push   %rbx
  407700:	push   %r12
  407702:	push   %r13
  407704:	push   %r14
  407706:	push   %r15
  407708:	mov    %rsi,%rax
  40770b:	shr    $0x28,%rax
  40770f:	and    $0xffff,%rax
  407715:	cmp    $0x99,%rax
  40771b:	sete   %cl
  40771e:	movzbl %cl,%ecx
  407721:	cmp    $0x0,%ecx
  407724:	jne    4077dd <p113d_FID_36_100_105_114_101_99_116_46_100_99_+0xed>
  40772a:	cmp    $0x9a,%rax
  407730:	je     4077c5 <p113d_FID_36_100_105_114_101_99_116_46_100_99_+0xd5>
  407736:	cmp    $0x9b,%rax
  40773c:	je     407752 <p113d_FID_36_100_105_114_101_99_116_46_100_99_+0x62>
  40773e:	mov    $0x4,%esi
  407743:	callq  432730 <p111_rt_fail>
  407748:	mov    $0x0,%eax
  40774d:	jmpq   4078bd <p113d_FID_36_100_105_114_101_99_116_46_100_99_+0x1cd>
  407752:	lea    -0x820(%rbp),%rdx
  407759:	mov    %rdi,%rbx
  40775c:	callq  437c20 <p125_rt_take4>
  407761:	mov    %rbx,%rdi
  407764:	mov    -0x810(%rbp),%rbx
  40776b:	mov    -0x808(%rbp),%rax
  407772:	mov    %rax,-0x820(%rbp)
  407779:	movabs $0x100110000000000,%rax
  407783:	mov    %rax,-0x818(%rbp)
  40778a:	lea    -0x820(%rbp),%rdx
  407791:	mov    $0x12,%esi
  407796:	mov    %rdi,%r12
  407799:	callq  437660 <p125_rt_ctor2>
  40779e:	mov    %r12,%rdi
  4077a1:	mov    %rbx,-0x820(%rbp)
  4077a8:	mov    %rax,-0x818(%rbp)
  4077af:	lea    -0x820(%rbp),%rdx
  4077b6:	mov    $0x12,%esi
  4077bb:	callq  437660 <p125_rt_ctor2>
  4077c0:	jmpq   4078bd <p113d_FID_36_100_105_114_101_99_116_46_100_99_+0x1cd>
  4077c5:	lea    -0x820(%rbp),%rdx
  4077cc:	callq  437750 <p125_rt_take2>
  4077d1:	mov    -0x818(%rbp),%rax
  4077d8:	jmpq   4078bd <p113d_FID_36_100_105_114_101_99_116_46_100_99_+0x1cd>
  4077dd:	mov    $0x9,%ecx
  4077e2:	lea    -0x820(%rbp),%rdx
  4077e9:	mov    %rdi,%rbx
  4077ec:	callq  432190 <p111_rt_take>
  4077f1:	mov    %rbx,%rdi
  4077f4:	mov    -0x820(%rbp),%rsi
  4077fb:	mov    -0x818(%rbp),%r15
  407802:	mov    -0x810(%rbp),%r12
  407809:	mov    -0x808(%rbp),%r14
  407810:	mov    -0x800(%rbp),%r13
  407817:	mov    -0x7f8(%rbp),%rbx
  40781e:	mov    %rbx,-0x8(%rbp)
  407822:	mov    -0x7f0(%rbp),%rbx
  407829:	mov    %rbx,-0x10(%rbp)
  40782d:	mov    -0x7e8(%rbp),%rbx
  407834:	mov    %rbx,-0x18(%rbp)
  407838:	mov    -0x7e0(%rbp),%rbx
  40783f:	mov    %rbx,-0x20(%rbp)
  407843:	mov    %rdi,%rbx
  407846:	callq  431fa0 <p111_rt_sink>
  40784b:	mov    %r15,%rsi
  40784e:	mov    %rbx,%rdi
  407851:	mov    -0x8(%rbp),%r15
  407855:	mov    %rdi,%rbx
  407858:	callq  431fa0 <p111_rt_sink>
  40785d:	mov    %r12,%rsi
  407860:	mov    %rbx,%rdi
  407863:	mov    -0x10(%rbp),%rbx
  407867:	mov    %rdi,%r12
  40786a:	callq  431fa0 <p111_rt_sink>
  40786f:	mov    %r14,%rsi
  407872:	mov    %r12,%rdi
  407875:	mov    -0x18(%rbp),%r14
  407879:	mov    %rdi,%r12
  40787c:	callq  431fa0 <p111_rt_sink>
  407881:	mov    %r13,%rsi
  407884:	mov    %r12,%rdi
  407887:	mov    -0x20(%rbp),%r13
  40788b:	mov    %rdi,%r12
  40788e:	callq  431fa0 <p111_rt_sink>
  407893:	mov    %r15,%rsi
  407896:	mov    %r12,%rdi
  407899:	mov    %rdi,%r12
  40789c:	callq  431fa0 <p111_rt_sink>
  4078a1:	mov    %r14,%rsi
  4078a4:	mov    %r12,%rdi
  4078a7:	mov    %rdi,%r12
  4078aa:	callq  431fa0 <p111_rt_sink>
  4078af:	mov    %r13,%rsi
  4078b2:	mov    %r12,%rdi
  4078b5:	callq  431fa0 <p111_rt_sink>
  4078ba:	mov    %rbx,%rax
  4078bd:	pop    %r15
  4078bf:	pop    %r14
  4078c1:	pop    %r13
  4078c3:	pop    %r12
  4078c5:	pop    %rbx
  4078c6:	leaveq 
  4078c7:	retq   

Disassembly of section .fini:
