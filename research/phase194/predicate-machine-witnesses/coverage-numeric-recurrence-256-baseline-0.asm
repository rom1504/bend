
/home/ai/bend2/build/publish/bend/selfhost/build/phase193/budget-native45-02/coverage-numeric-recurrence-256/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408358 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_>:
  408358:	push   %rbp
  408359:	mov    %rsp,%rbp
  40835c:	sub    $0x940,%rsp
  408363:	mov    %r12,-0x10(%rbp)
  408367:	mov    %rbx,-0x8(%rbp)
  40836b:	mov    %rdi,%rax
  40836e:	mov    %rax,%r12
  408371:	mov    %rsi,%rax
  408374:	mov    %rax,%rdi
  408377:	mov    %rdx,%rax
  40837a:	mov    %rax,%rdx
  40837d:	mov    %rcx,%rax
  408380:	mov    %rax,%rbx
  408383:	mov    %rdi,%rsi
  408386:	cmp    $0x0,%rsi
  40838d:	sete   %sil
  408391:	movzbl %sil,%esi
  408395:	mov    %rsi,%r10
  408398:	test   %r10d,%r10d
  40839b:	je     4083b1 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x59>
  4083a1:	mov    %rbx,%rax
  4083a4:	mov    -0x10(%rbp),%r12
  4083a8:	mov    -0x8(%rbp),%rbx
  4083ac:	mov    %rbp,%rsp
  4083af:	pop    %rbp
  4083b0:	retq   
  4083b1:	mov    %rdi,%rsi
  4083b4:	cmp    $0x0,%rsi
  4083bb:	setne  %sil
  4083bf:	movzbl %sil,%esi
  4083c3:	mov    %rsi,%r10
  4083c6:	test   %r10d,%r10d
  4083c9:	je     408492 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x13a>
  4083cf:	mov    %rdi,%r8
  4083d2:	sub    $0x1,%r8
  4083d9:	movd   %edx,%xmm1
  4083dd:	movabs $0x40700000,%r10
  4083e7:	movd   %r10d,%xmm0
  4083ec:	mulss  %xmm1,%xmm0
  4083f0:	movd   %xmm0,%edi
  4083f4:	movd   %edi,%xmm2
  4083f8:	movd   %edx,%xmm1
  4083fc:	movabs $0x3f800000,%r10
  408406:	movd   %r10d,%xmm0
  40840b:	subss  %xmm1,%xmm0
  40840f:	movd   %xmm0,%edi
  408413:	movd   %edi,%xmm1
  408417:	movaps %xmm2,%xmm0
  40841a:	mulss  %xmm1,%xmm0
  40841e:	movd   %xmm0,%edi
  408422:	mov    %rdi,%rdx
  408425:	mov    %ebx,%ebx
  408427:	mov    %rbx,%rdi
  40842a:	imul   $0x1000193,%edi,%edi
  408430:	mov    %rdi,%rsi
  408433:	movabs $0x49742400,%r10
  40843d:	movd   %r10d,%xmm1
  408442:	movd   %edx,%xmm0
  408446:	mulss  %xmm1,%xmm0
  40844a:	movd   %xmm0,%edi
  40844e:	movd   %edi,%xmm0
  408452:	pxor   %xmm1,%xmm1
  408456:	comiss %xmm1,%xmm0
  408459:	movd   %xmm0,%r10d
  40845e:	xor    %r11d,%r11d
  408461:	cmp    $0x4f800000,%r10d
  408468:	cmovae %r11d,%r10d
  40846c:	movd   %r10d,%xmm0
  408471:	cvttss2si %xmm0,%r10
  408476:	mov    %r10d,%r10d
  408479:	mov    %r10,%rdi
  40847c:	mov    %edi,%edi
  40847e:	mov    %rdi,%r11
  408481:	mov    %rsi,%rdi
  408484:	xor    %r11,%rdi
  408487:	mov    %rdi,%rbx
  40848a:	mov    %r8,%rdi
  40848d:	jmpq   408383 <p113d_FID_36_100_105_114_101_99_116_46_112_51_55_46_110_117_109_101_114_105_99_+0x2b>
  408492:	mov    %r12,%rdi
  408495:	movabs $0x4,%rsi
  40849f:	mov    %esi,%esi
  4084a1:	xor    %eax,%eax
  4084a3:	callq  415370 <p111_rt_fail>
  4084a8:	mov    %rax,-0x8e8(%rbp)
  4084af:	movabs $0x0,%rax
  4084b9:	mov    -0x10(%rbp),%r12
  4084bd:	mov    -0x8(%rbp),%rbx
  4084c1:	mov    %rbp,%rsp
  4084c4:	pop    %rbp
  4084c5:	retq   

Disassembly of section .fini:
