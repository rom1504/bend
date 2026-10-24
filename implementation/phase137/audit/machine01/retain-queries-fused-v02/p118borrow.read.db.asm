
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004072c0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_>:
  4072c0:	endbr64 
  4072c4:	push   %rbp
  4072c5:	mov    %rsp,%rbp
  4072c8:	sub    $0x808,%rsp
  4072cf:	push   %rbx
  4072d0:	mov    %rsi,%rax
  4072d3:	shr    $0x28,%rax
  4072d7:	mov    %rax,%r9
  4072da:	and    $0xffff,%r9
  4072e1:	cmp    $0x99,%r9
  4072e8:	je     40746b <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x1ab>
  4072ee:	cmp    $0x9a,%r9
  4072f5:	sete   %r10b
  4072f9:	movzbl %r10b,%r10d
  4072fd:	mov    %rsi,%rax
  407300:	shr    $0x38,%rax
  407304:	and    $0x7f,%rax
  407308:	cmp    $0x2,%rax
  40730c:	sete   %r8b
  407310:	movzbl %r8b,%r8d
  407314:	mov    %rsi,%rcx
  407317:	shr    $0x3f,%rcx
  40731b:	movabs $0xffffffffff,%rax
  407325:	and    %rsi,%rax
  407328:	mov    %rax,%rdx
  40732b:	shl    $0x3,%rdx
  40732f:	cmp    $0x0,%r10d
  407333:	jne    4073f0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x130>
  407339:	cmp    $0x9b,%r9
  407340:	sete   %r9b
  407344:	movzbl %r9b,%r9d
  407348:	je     40735e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x9e>
  40734a:	mov    $0x4,%esi
  40734f:	callq  432730 <p111_rt_fail>
  407354:	mov    $0x0,%eax
  407359:	jmpq   407489 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x1c9>
  40735e:	xchg   %ax,%ax
  407360:	test   %r8d,%r9d
  407363:	jne    407384 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0xc4>
  407365:	mov    $0x4,%r8d
  40736b:	mov    $0x9b,%ecx
  407370:	lea    -0x800(%rbp),%rdx
  407377:	mov    %rdi,%rbx
  40737a:	callq  4369d0 <p118_rt_borrow_fields>
  40737f:	mov    %rbx,%rdi
  407382:	jmp    4073d5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x115>
  407384:	mov    %rcx,%rsi
  407387:	mov    (%rdi),%rcx
  40738a:	cmp    $0x0,%rsi
  40738e:	je     4073a2 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0xe2>
  407390:	mov    (%rdx,%rcx,1),%eax
  407393:	mov    0x4(%rdx,%rcx,1),%edx
  407397:	shl    $0x20,%rdx
  40739b:	or     %rdx,%rax
  40739e:	shr    $0x18,%rax
  4073a2:	shl    $0x3,%rax
  4073a6:	mov    (%rax,%rcx,1),%rdx
  4073aa:	mov    %rdx,-0x800(%rbp)
  4073b1:	mov    0x8(%rax,%rcx,1),%rdx
  4073b6:	mov    %rdx,-0x7f8(%rbp)
  4073bd:	mov    0x10(%rax,%rcx,1),%rdx
  4073c2:	mov    %rdx,-0x7f0(%rbp)
  4073c9:	mov    0x18(%rax,%rcx,1),%rax
  4073ce:	mov    %rax,-0x7e8(%rbp)
  4073d5:	mov    $0x0,%ecx
  4073da:	lea    -0x800(%rbp),%rdx
  4073e1:	mov    $0x2,%esi
  4073e6:	callq  4338d0 <p111_rt_special_ctor>
  4073eb:	jmpq   407489 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x1c9>
  4073f0:	mov    %r10d,%r9d
  4073f3:	test   %r8d,%r9d
  4073f6:	jne    407417 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x157>
  4073f8:	mov    $0x2,%r8d
  4073fe:	mov    $0x9a,%ecx
  407403:	lea    -0x800(%rbp),%rdx
  40740a:	mov    %rdi,%rbx
  40740d:	callq  4369d0 <p118_rt_borrow_fields>
  407412:	mov    %rbx,%rdi
  407415:	jmp    407453 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x193>
  407417:	cs cs cs mov %rcx,%rsi
  40741d:	mov    (%rdi),%rcx
  407420:	cmp    $0x0,%rsi
  407424:	je     407438 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x178>
  407426:	mov    (%rdx,%rcx,1),%eax
  407429:	mov    0x4(%rdx,%rcx,1),%edx
  40742d:	shl    $0x20,%rdx
  407431:	or     %rdx,%rax
  407434:	shr    $0x18,%rax
  407438:	shl    $0x3,%rax
  40743c:	mov    (%rax,%rcx,1),%rdx
  407440:	mov    %rdx,-0x800(%rbp)
  407447:	mov    0x8(%rax,%rcx,1),%rax
  40744c:	mov    %rax,-0x7f8(%rbp)
  407453:	mov    $0x0,%ecx
  407458:	lea    -0x800(%rbp),%rdx
  40745f:	mov    $0x2,%esi
  407464:	callq  4338d0 <p111_rt_special_ctor>
  407469:	jmp    407489 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_100_98_+0x1c9>
  40746b:	mov    $0x9,%r8d
  407471:	mov    $0x99,%ecx
  407476:	lea    -0x800(%rbp),%rdx
  40747d:	callq  4369d0 <p118_rt_borrow_fields>
  407482:	mov    -0x7c8(%rbp),%rax
  407489:	pop    %rbx
  40748a:	leaveq 
  40748b:	retq   

Disassembly of section .fini:
