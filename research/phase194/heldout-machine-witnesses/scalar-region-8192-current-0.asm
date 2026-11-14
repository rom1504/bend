
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/scalar-region-8192/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004085f2 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_>:
  4085f2:	push   %rbp
  4085f3:	mov    %rsp,%rbp
  4085f6:	sub    $0xa80,%rsp
  4085fd:	mov    %r12,-0x10(%rbp)
  408601:	mov    %rbx,-0x8(%rbp)
  408605:	mov    %r13,-0x18(%rbp)
  408609:	mov    %r14,-0x20(%rbp)
  40860d:	mov    %r15,-0x28(%rbp)
  408611:	mov    %rdi,%rax
  408614:	mov    %rax,%r12
  408617:	mov    %rsi,%rax
  40861a:	mov    %rax,%rdi
  40861d:	mov    %rdx,%rax
  408620:	mov    %rax,%r15
  408623:	mov    %rcx,%rax
  408626:	mov    %rax,-0x40(%rbp)
  40862a:	mov    %r8,%rax
  40862d:	mov    %rax,%r8
  408630:	mov    %r9,%rax
  408633:	mov    %rax,%r9
  408636:	mov    0x10(%rbp),%rax
  40863a:	mov    %rax,%rbx
  40863d:	mov    0x18(%rbp),%rax
  408641:	mov    %rax,%r14
  408644:	cmp    $0x0,%rdi
  40864b:	jne    40866d <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_+0x7b>
  408651:	mov    %r14,%rax
  408654:	mov    -0x10(%rbp),%r12
  408658:	mov    -0x8(%rbp),%rbx
  40865c:	mov    -0x18(%rbp),%r13
  408660:	mov    -0x20(%rbp),%r14
  408664:	mov    -0x28(%rbp),%r15
  408668:	mov    %rbp,%rsp
  40866b:	pop    %rbp
  40866c:	retq   
  40866d:	mov    %rdi,%r10
  408670:	sub    $0x1,%r10
  408677:	mov    %r10,-0x8f0(%rbp)
  40867e:	mov    %r8d,%edi
  408681:	mov    %r8d,%edx
  408684:	imul   %edx,%edi
  408687:	mov    %rdi,%rsi
  40868a:	shr    $0x8,%rsi
  40868e:	mov    %rsi,%rdx
  408691:	mov    %rdi,%rsi
  408694:	shr    $0x1f,%rsi
  408698:	mov    %rsi,%r10
  40869b:	movabs $0x0,%r11
  4086a5:	cmp    %r11,%r10
  4086a8:	movabs $0x0,%rax
  4086b2:	movabs $0xff000000,%r11
  4086bc:	cmove  %rax,%r11
  4086c0:	mov    %r11,%rdi
  4086c3:	mov    %rdx,%rsi
  4086c6:	or     %rdi,%rsi
  4086c9:	mov    %rsi,%r13
  4086cc:	mov    %r9d,%edi
  4086cf:	mov    %r9d,%edx
  4086d2:	imul   %edx,%edi
  4086d5:	mov    %rdi,%rsi
  4086d8:	shr    $0x8,%rsi
  4086dc:	mov    %rsi,%rdx
  4086df:	mov    %rdi,%rsi
  4086e2:	shr    $0x1f,%rsi
  4086e6:	mov    %rsi,%r10
  4086e9:	movabs $0x0,%r11
  4086f3:	cmp    %r11,%r10
  4086f6:	movabs $0x0,%rax
  408700:	movabs $0xff000000,%r11
  40870a:	cmove  %rax,%r11
  40870e:	mov    %r11,%rdi
  408711:	mov    %rdx,%rsi
  408714:	or     %rdi,%rsi
  408717:	mov    %rsi,%rdx
  40871a:	mov    %r13,%rdi
  40871d:	add    %esi,%edi
  40871f:	mov    %rdi,%r10
  408722:	movabs $0x400,%r11
  40872c:	cmp    %r11,%r10
  40872f:	movabs $0x1,%rax
  408739:	movabs $0x0,%r11
  408743:	cmova  %rax,%r11
  408747:	mov    %r11,%rsi
  40874a:	mov    %ebx,%edi
  40874c:	or     %rsi,%rdi
  40874f:	mov    %rdi,%rbx
  408752:	mov    %r13,%rdi
  408755:	sub    %edx,%edi
  408757:	mov    %r15d,%edx
  40875a:	add    %edx,%edi
  40875c:	mov    %rdi,%r10
  40875f:	mov    %r10,-0x998(%rbp)
  408766:	mov    %r8d,%edi
  408769:	mov    %r9d,%edx
  40876c:	imul   %edx,%edi
  40876f:	mov    %rdi,%r11
  408772:	movabs $0x2,%rdi
  40877c:	imul   %r11d,%edi
  408780:	mov    %rdi,%rsi
  408783:	shr    $0x8,%rsi
  408787:	mov    %rsi,%r10
  40878a:	mov    %r10,-0x9a8(%rbp)
  408791:	mov    %rdi,%rsi
  408794:	shr    $0x1f,%rsi
  408798:	mov    %rsi,%r10
  40879b:	movabs $0x0,%r11
  4087a5:	cmp    %r11,%r10
  4087a8:	movabs $0x0,%rax
  4087b2:	movabs $0xff000000,%r11
  4087bc:	cmove  %rax,%r11
  4087c0:	mov    %r11,-0x9c0(%rbp)
  4087c7:	mov    -0x9a8(%rbp),%rsi
  4087ce:	or     %r11,%rsi
  4087d1:	mov    -0x40(%rbp),%edx
  4087d4:	mov    %rsi,%rdi
  4087d7:	add    %edx,%edi
  4087d9:	mov    %rdi,%r10
  4087dc:	mov    %r10,-0x9c8(%rbp)
  4087e3:	mov    %rbx,%r10
  4087e6:	movabs $0x0,%r11
  4087f0:	cmp    %r11,%r10
  4087f3:	mov    -0x998(%rbp),%rax
  4087fa:	mov    %r8,%r11
  4087fd:	cmove  %rax,%r11
  408801:	mov    %r11,-0x9e0(%rbp)
  408808:	mov    %r11,%r10
  40880b:	mov    %r10,-0x9e8(%rbp)
  408812:	mov    %rbx,%r10
  408815:	movabs $0x0,%r11
  40881f:	cmp    %r11,%r10
  408822:	mov    -0x9c8(%rbp),%rax
  408829:	mov    %r9,%r11
  40882c:	cmove  %rax,%r11
  408830:	mov    %r11,-0xa00(%rbp)
  408837:	mov    %r11,%r10
  40883a:	mov    %r10,-0xa08(%rbp)
  408841:	mov    %rbx,%r10
  408844:	movabs $0x0,%r11
  40884e:	cmp    %r11,%r10
  408851:	movabs $0x1,%rax
  40885b:	movabs $0x0,%r11
  408865:	cmove  %rax,%r11
  408869:	mov    %r11,-0xa20(%rbp)
  408870:	mov    %r14d,%edi
  408873:	mov    -0xa20(%rbp),%r11
  40887a:	add    %r11d,%edi
  40887d:	mov    -0x9e8(%rbp),%r10
  408884:	mov    %r10,%r8
  408887:	mov    -0xa08(%rbp),%r10
  40888e:	mov    %r10,%r9
  408891:	mov    %rdi,%r14
  408894:	mov    -0x8f0(%rbp),%r10
  40889b:	mov    %r10,%rdi
  40889e:	jmpq   408644 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_+0x52>

Disassembly of section .fini:
