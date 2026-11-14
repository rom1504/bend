
/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-native45-02/scalar-region-8192/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000409240 <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_>:
  409240:	push   %rbp
  409241:	mov    %rsp,%rbp
  409244:	sub    $0x9e0,%rsp
  40924b:	mov    %r12,-0x10(%rbp)
  40924f:	mov    %rbx,-0x8(%rbp)
  409253:	mov    %r13,-0x18(%rbp)
  409257:	mov    %r14,-0x20(%rbp)
  40925b:	mov    %r15,-0x28(%rbp)
  40925f:	mov    %rdi,%rax
  409262:	mov    %rax,%r12
  409265:	mov    %rsi,%rax
  409268:	mov    %rax,%rdi
  40926b:	mov    %rdx,%rax
  40926e:	mov    %rax,%r14
  409271:	mov    %rcx,%rax
  409274:	mov    %rax,%rbx
  409277:	mov    %r8,%rax
  40927a:	mov    %rax,%r13
  40927d:	cmp    $0x0,%rdi
  409284:	jne    4092a6 <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_+0x66>
  40928a:	mov    %r13,%rax
  40928d:	mov    -0x10(%rbp),%r12
  409291:	mov    -0x8(%rbp),%rbx
  409295:	mov    -0x18(%rbp),%r13
  409299:	mov    -0x20(%rbp),%r14
  40929d:	mov    -0x28(%rbp),%r15
  4092a1:	mov    %rbp,%rsp
  4092a4:	pop    %rbp
  4092a5:	retq   
  4092a6:	mov    %rdi,%r15
  4092a9:	sub    $0x1,%r15
  4092b0:	mov    %ebx,%edi
  4092b2:	and    $0x3ff,%rdi
  4092b9:	sub    $0x200,%edi
  4092bf:	mov    %rdi,%rsi
  4092c2:	mov    %ebx,%edi
  4092c4:	shr    $0xa,%rdi
  4092c8:	and    $0x3ff,%rdi
  4092cf:	sub    $0x200,%edi
  4092d5:	mov    %r12,%r10
  4092d8:	mov    %r10,0x40(%rsp)
  4092dd:	mov    %r14,%r10
  4092e0:	mov    %r10,0x48(%rsp)
  4092e5:	mov    %rsi,%r10
  4092e8:	mov    %r10,0x50(%rsp)
  4092ed:	mov    %rdi,%r10
  4092f0:	mov    %r10,0x58(%rsp)
  4092f5:	movabs $0x0,%r10
  4092ff:	mov    %r10,0x60(%rsp)
  409304:	movabs $0x0,%r10
  40930e:	mov    %r10,0x68(%rsp)
  409313:	movabs $0x0,%r10
  40931d:	mov    %r10,0x70(%rsp)
  409322:	movabs $0x0,%r10
  40932c:	mov    %r10,0x78(%rsp)
  409331:	mov    0x40(%rsp),%rdi
  409336:	mov    0x48(%rsp),%rsi
  40933b:	mov    0x50(%rsp),%rdx
  409340:	mov    0x58(%rsp),%rcx
  409345:	mov    0x60(%rsp),%r8
  40934a:	mov    0x68(%rsp),%r9
  40934f:	mov    0x70(%rsp),%r10
  409354:	mov    %r10,(%rsp)
  409358:	mov    0x78(%rsp),%r10
  40935d:	mov    %r10,0x8(%rsp)
  409362:	xor    %eax,%eax
  409364:	callq  408670 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_>
  409369:	mov    %rax,%rdi
  40936c:	mov    %edi,%edi
  40936e:	cmp    $0x2000,%rdi
  409375:	sete   %dil
  409379:	movzbl %dil,%edi
  40937d:	mov    %edi,%edi
  40937f:	xor    $0x1,%edi
  409385:	mov    %rdi,%rax
  409388:	movabs $0x0,%r10
  409392:	movabs $0x1,%r11
  40939c:	test   %eax,%eax
  40939e:	cmovne %r10,%r11
  4093a2:	mov    %r11,%rsi
  4093a5:	mov    %r13d,%edi
  4093a8:	mov    %rdi,%r13
  4093ab:	add    %esi,%r13d
  4093ae:	mov    %r15,%rdi
  4093b1:	jmpq   40927d <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
