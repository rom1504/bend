
selfhost/build/phase194/native45-02/coverage-numeric-recurrence-256/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408304 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_>:
  408304:	push   %rbp
  408305:	mov    %rsp,%rbp
  408308:	sub    $0x950,%rsp
  40830f:	mov    %r12,-0x10(%rbp)
  408313:	mov    %rbx,-0x8(%rbp)
  408317:	mov    %rdi,%rax
  40831a:	mov    %rax,%r12
  40831d:	mov    %rsi,%rax
  408320:	mov    %rax,%rdi
  408323:	mov    %rdx,%rax
  408326:	mov    %rax,%rdx
  408329:	mov    %rcx,%rax
  40832c:	mov    %rax,%rbx
  40832f:	mov    %rdi,%rsi
  408332:	cmp    $0x0,%rsi
  408339:	sete   %sil
  40833d:	movzbl %sil,%esi
  408341:	mov    %rsi,%r10
  408344:	test   %r10d,%r10d
  408347:	je     40835d <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x59>
  40834d:	mov    %rbx,%rax
  408350:	mov    -0x10(%rbp),%r12
  408354:	mov    -0x8(%rbp),%rbx
  408358:	mov    %rbp,%rsp
  40835b:	pop    %rbp
  40835c:	retq   
  40835d:	mov    %rdi,%rsi
  408360:	cmp    $0x0,%rsi
  408367:	setne  %sil
  40836b:	movzbl %sil,%esi
  40836f:	mov    %rsi,%r10
  408372:	test   %r10d,%r10d
  408375:	je     408426 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x122>
  40837b:	mov    %rdi,%r8
  40837e:	sub    $0x1,%r8
  408385:	movd   %edx,%xmm1
  408389:	movabs $0x40700000,%r10
  408393:	movd   %r10d,%xmm2
  408398:	mulss  %xmm1,%xmm2
  40839c:	movaps %xmm2,%xmm3
  40839f:	movd   %edx,%xmm1
  4083a3:	movabs $0x3f800000,%r10
  4083ad:	movd   %r10d,%xmm2
  4083b2:	subss  %xmm1,%xmm2
  4083b6:	movaps %xmm3,%xmm0
  4083b9:	mulss  %xmm2,%xmm0
  4083bd:	movd   %xmm0,%edi
  4083c1:	mov    %rdi,%rdx
  4083c4:	mov    %ebx,%ebx
  4083c6:	mov    %rbx,%rdi
  4083c9:	imul   $0x1000193,%edi,%edi
  4083cf:	mov    %rdi,%rsi
  4083d2:	movabs $0x49742400,%r10
  4083dc:	movd   %r10d,%xmm1
  4083e1:	movd   %edx,%xmm2
  4083e5:	mulss  %xmm1,%xmm2
  4083e9:	movaps %xmm2,%xmm0
  4083ec:	pxor   %xmm1,%xmm1
  4083f0:	comiss %xmm1,%xmm0
  4083f3:	movd   %xmm0,%r10d
  4083f8:	xor    %r11d,%r11d
  4083fb:	cmp    $0x4f800000,%r10d
  408402:	cmovae %r11d,%r10d
  408406:	movd   %r10d,%xmm0
  40840b:	cvttss2si %xmm0,%r10
  408410:	mov    %r10d,%r10d
  408413:	mov    %r10,%rdi
  408416:	mov    %edi,%edi
  408418:	xor    %rsi,%rdi
  40841b:	mov    %rdi,%rbx
  40841e:	mov    %r8,%rdi
  408421:	jmpq   40832f <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x2b>
  408426:	mov    %r12,%rdi
  408429:	movabs $0x4,%rsi
  408433:	mov    %esi,%esi
  408435:	xor    %eax,%eax
  408437:	callq  4152e0 <p111_rt_fail>
  40843c:	mov    %rax,-0x900(%rbp)
  408443:	movabs $0x0,%rax
  40844d:	mov    -0x10(%rbp),%r12
  408451:	mov    -0x8(%rbp),%rbx
  408455:	mov    %rbp,%rsp
  408458:	pop    %rbp
  408459:	retq   

Disassembly of section .fini:
