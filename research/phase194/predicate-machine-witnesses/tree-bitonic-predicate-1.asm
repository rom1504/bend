
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/predicate-dev-build01/tree-bitonic/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000411f63 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_>:
  411f63:	push   %rbp
  411f64:	mov    %rsp,%rbp
  411f67:	sub    $0x1b60,%rsp
  411f6e:	mov    %r12,-0x10(%rbp)
  411f72:	mov    %rbx,-0x8(%rbp)
  411f76:	mov    %r13,-0x18(%rbp)
  411f7a:	mov    %r14,-0x20(%rbp)
  411f7e:	mov    %r15,-0x28(%rbp)
  411f82:	mov    %rdi,%rax
  411f85:	mov    %rax,%r12
  411f88:	mov    %rsi,%rax
  411f8b:	mov    %rax,%r13
  411f8e:	mov    %rdx,%rax
  411f91:	mov    %rax,%rbx
  411f94:	mov    %rcx,%rax
  411f97:	mov    %rax,%r14
  411f9a:	mov    %r8,%rax
  411f9d:	mov    %rax,%rdi
  411fa0:	mov    %r9,%rax
  411fa3:	mov    %rax,%r15
  411fa6:	mov    0x10(%rbp),%rax
  411faa:	mov    %rax,-0x58(%rbp)
  411fae:	mov    %rdi,%r10
  411fb1:	test   %r10d,%r10d
  411fb4:	je     412179 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x216>
  411fba:	cmp    $0x0,%r15
  411fc1:	je     41215c <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x1f9>
  411fc7:	sub    $0x1,%r15
  411fce:	mov    0x10(%r12),%rdi
  411fd3:	movabs $0xfffffffffffffff8,%r11
  411fdd:	add    %r11,%rdi
  411fe0:	mov    %rdi,0x10(%r12)
  411fe5:	mov    0x10(%r12),%rdi
  411fea:	mov    (%rdi),%rdi
  411fed:	movabs $0x74,%r11
  411ff7:	cmp    %r11,%rdi
  411ffa:	jne    4120b1 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x14e>
  412000:	mov    0x10(%r12),%rdi
  412005:	movabs $0xffffffffffffffe8,%r11
  41200f:	add    %r11,%rdi
  412012:	mov    %rdi,0x10(%r12)
  412017:	mov    0x10(%r12),%rdi
  41201c:	mov    (%rdi),%r13
  41201f:	mov    0x10(%r12),%rdi
  412024:	mov    0x8(%rdi),%r14
  412028:	mov    0x10(%r12),%rdi
  41202d:	mov    0x10(%rdi),%rbx
  412031:	lea    -0x10d8(%rbp),%r10
  412038:	mov    -0x58(%rbp),%r11
  41203c:	mov    %r11,(%r10)
  41203f:	mov    %r12,%rdi
  412042:	movabs $0x75,%rsi
  41204c:	mov    %esi,%esi
  41204e:	lea    -0x10d8(%rbp),%rdx
  412055:	movabs $0x1,%rcx
  41205f:	mov    %ecx,%ecx
  412061:	xor    %eax,%eax
  412063:	callq  41c610 <p111_rt_frame>
  412068:	mov    %rax,-0x1950(%rbp)
  41206f:	add    $0x1,%r15
  412076:	lea    -0x10d8(%rbp),%r10
  41207d:	mov    %r13,%r11
  412080:	mov    %r11,(%r10)
  412083:	lea    -0x10d8(%rbp),%r10
  41208a:	mov    %rbx,%r11
  41208d:	mov    %r11,0x8(%r10)
  412091:	lea    -0x10d8(%rbp),%r10
  412098:	mov    %r14,%r11
  41209b:	mov    %r11,0x10(%r10)
  41209f:	movabs $0x0,%r10
  4120a9:	mov    %r10,%rdi
  4120ac:	jmpq   411fae <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  4120b1:	movabs $0x75,%r11
  4120bb:	cmp    %r11,%rdi
  4120be:	jne    412126 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x1c3>
  4120c4:	mov    0x10(%r12),%rdi
  4120c9:	movabs $0xfffffffffffffff8,%r11
  4120d3:	add    %r11,%rdi
  4120d6:	mov    %rdi,0x10(%r12)
  4120db:	mov    0x10(%r12),%rdi
  4120e0:	mov    %rdi,%r10
  4120e3:	mov    (%r10),%r10
  4120e6:	mov    %r10,-0x1970(%rbp)
  4120ed:	mov    %r12,%rdi
  4120f0:	mov    -0x1970(%rbp),%rsi
  4120f7:	mov    -0x58(%rbp),%rdx
  4120fb:	xor    %eax,%eax
  4120fd:	callq  4088bf <p112w_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_>
  412102:	mov    %rax,-0x1978(%rbp)
  412109:	movabs $0x1,%r10
  412113:	mov    %r10,%rdi
  412116:	mov    -0x1978(%rbp),%r10
  41211d:	mov    %r10,-0x58(%rbp)
  412121:	jmpq   411fae <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  412126:	mov    %r12,%rdi
  412129:	movabs $0x4,%rsi
  412133:	mov    %esi,%esi
  412135:	xor    %eax,%eax
  412137:	callq  41c860 <p111_rt_fail>
  41213c:	mov    %rax,-0x1980(%rbp)
  412143:	mov    -0x10(%rbp),%r12
  412147:	mov    -0x8(%rbp),%rbx
  41214b:	mov    -0x18(%rbp),%r13
  41214f:	mov    -0x20(%rbp),%r14
  412153:	mov    -0x28(%rbp),%r15
  412157:	mov    %rbp,%rsp
  41215a:	pop    %rbp
  41215b:	retq   
  41215c:	mov    -0x58(%rbp),%rax
  412160:	mov    -0x10(%rbp),%r12
  412164:	mov    -0x8(%rbp),%rbx
  412168:	mov    -0x18(%rbp),%r13
  41216c:	mov    -0x20(%rbp),%r14
  412170:	mov    -0x28(%rbp),%r15
  412174:	mov    %rbp,%rsp
  412177:	pop    %rbp
  412178:	retq   
  412179:	mov    %r13,%rdi
  41217c:	shr    $0x28,%rdi
  412180:	and    $0xffff,%rdi
  412187:	movabs $0xa4,%r11
  412191:	cmp    %r11,%rdi
  412194:	jne    41253b <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x5d8>
  41219a:	mov    %r13,%r10
  41219d:	shr    $0x28,%r10
  4121a1:	mov    %r10,-0x1998(%rbp)
  4121a8:	and    $0x7fffff,%r10
  4121af:	mov    %r10,-0x19a0(%rbp)
  4121b6:	movabs $0xa4,%r10
  4121c0:	or     $0x10000,%r10
  4121c7:	mov    %r10,-0x19a8(%rbp)
  4121ce:	mov    -0x19a0(%rbp),%r10
  4121d5:	mov    -0x19a8(%rbp),%r11
  4121dc:	cmp    %r11,%r10
  4121df:	jne    412212 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x2af>
  4121e5:	mov    %r13,%r10
  4121e8:	movabs $0xffffffffff,%r11
  4121f2:	and    %r11,%r10
  4121f5:	mov    %r10,-0x19b8(%rbp)
  4121fc:	lea    -0x860(%rbp),%r10
  412203:	mov    -0x19b8(%rbp),%r11
  41220a:	mov    %r11,(%r10)
  41220d:	jmpq   41222d <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x2ca>
  412212:	mov    %r12,%rdi
  412215:	mov    %r13,%rsi
  412218:	lea    -0x860(%rbp),%rdx
  41221f:	xor    %eax,%eax
  412221:	callq  421bf0 <p125_rt_take1>
  412226:	mov    %rax,-0x19c0(%rbp)
  41222d:	lea    -0x860(%rbp),%r10
  412234:	mov    (%r10),%r10
  412237:	mov    %r10,-0x19c8(%rbp)
  41223e:	mov    %rbx,%rdi
  412241:	shr    $0x28,%rdi
  412245:	and    $0xffff,%rdi
  41224c:	movabs $0xa4,%r11
  412256:	cmp    %r11,%rdi
  412259:	jne    41238c <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x429>
  41225f:	mov    %rbx,%r10
  412262:	shr    $0x28,%r10
  412266:	mov    %r10,-0x19d0(%rbp)
  41226d:	and    $0x7fffff,%r10
  412274:	mov    %r10,-0x19d8(%rbp)
  41227b:	movabs $0xa4,%r10
  412285:	or     $0x10000,%r10
  41228c:	mov    %r10,-0x19e0(%rbp)
  412293:	mov    -0x19d8(%rbp),%r10
  41229a:	mov    -0x19e0(%rbp),%r11
  4122a1:	cmp    %r11,%r10
  4122a4:	jne    4122d7 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x374>
  4122aa:	mov    %rbx,%r10
  4122ad:	movabs $0xffffffffff,%r11
  4122b7:	and    %r11,%r10
  4122ba:	mov    %r10,-0x19f0(%rbp)
  4122c1:	lea    -0x860(%rbp),%r10
  4122c8:	mov    -0x19f0(%rbp),%r11
  4122cf:	mov    %r11,(%r10)
  4122d2:	jmpq   4122f2 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x38f>
  4122d7:	mov    %r12,%rdi
  4122da:	mov    %rbx,%rsi
  4122dd:	lea    -0x860(%rbp),%rdx
  4122e4:	xor    %eax,%eax
  4122e6:	callq  421bf0 <p125_rt_take1>
  4122eb:	mov    %rax,-0x19c0(%rbp)
  4122f2:	lea    -0x860(%rbp),%r10
  4122f9:	mov    (%r10),%rdi
  4122fc:	lea    -0x860(%rbp),%r10
  412303:	mov    -0x19c8(%rbp),%r11
  41230a:	mov    %r11,(%r10)
  41230d:	lea    -0x860(%rbp),%r10
  412314:	mov    %rdi,%r11
  412317:	mov    %r11,0x8(%r10)
  41231b:	lea    -0x860(%rbp),%r10
  412322:	mov    %r14,%r11
  412325:	mov    %r11,0x10(%r10)
  412329:	mov    %r12,%r10
  41232c:	mov    %r10,0x20(%rsp)
  412331:	mov    -0x19c8(%rbp),%r10
  412338:	mov    %r10,0x28(%rsp)
  41233d:	mov    %rdi,%r10
  412340:	mov    %r10,0x30(%rsp)
  412345:	mov    %r14,%r10
  412348:	mov    %r10,0x38(%rsp)
  41234d:	mov    0x20(%rsp),%rdi
  412352:	mov    0x28(%rsp),%rsi
  412357:	mov    0x30(%rsp),%rdx
  41235c:	mov    0x38(%rsp),%rcx
  412361:	xor    %eax,%eax
  412363:	callq  408f09 <p112w_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_>
  412368:	mov    %rax,-0x1a00(%rbp)
  41236f:	movabs $0x1,%r10
  412379:	mov    %r10,%rdi
  41237c:	mov    -0x1a00(%rbp),%r10
  412383:	mov    %r10,-0x58(%rbp)
  412387:	jmpq   411fae <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  41238c:	mov    %r12,%rdi
  41238f:	mov    -0x19c8(%rbp),%rsi
  412396:	xor    %eax,%eax
  412398:	callq  41c0d0 <p111_rt_sink>
  41239d:	mov    %rax,-0x19c0(%rbp)
  4123a4:	mov    %rbx,%rdi
  4123a7:	shr    $0x28,%rdi
  4123ab:	and    $0xffff,%rdi
  4123b2:	movabs $0xa5,%r11
  4123bc:	cmp    %r11,%rdi
  4123bf:	jne    412453 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4f0>
  4123c5:	mov    %r12,%rdi
  4123c8:	mov    %rbx,%rsi
  4123cb:	lea    -0x860(%rbp),%rdx
  4123d2:	xor    %eax,%eax
  4123d4:	callq  421e70 <p125_rt_take2>
  4123d9:	mov    %rax,-0x19c0(%rbp)
  4123e0:	lea    -0x860(%rbp),%r10
  4123e7:	mov    (%r10),%r10
  4123ea:	mov    %r10,-0x1a08(%rbp)
  4123f1:	lea    -0x860(%rbp),%r10
  4123f8:	mov    0x8(%r10),%r10
  4123fc:	mov    %r10,-0x1a10(%rbp)
  412403:	mov    %r12,%rdi
  412406:	mov    -0x1a08(%rbp),%rsi
  41240d:	xor    %eax,%eax
  41240f:	callq  41c0d0 <p111_rt_sink>
  412414:	mov    %rax,-0x19c0(%rbp)
  41241b:	mov    %r12,%rdi
  41241e:	mov    -0x1a10(%rbp),%rsi
  412425:	xor    %eax,%eax
  412427:	callq  41c0d0 <p111_rt_sink>
  41242c:	mov    %rax,-0x19c0(%rbp)
  412433:	movabs $0x1,%r10
  41243d:	mov    %r10,%rdi
  412440:	movabs $0x100a40000000000,%r10
  41244a:	mov    %r10,-0x58(%rbp)
  41244e:	jmpq   411fae <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  412453:	lea    -0x860(%rbp),%r10
  41245a:	mov    %r14,%r11
  41245d:	mov    %r11,(%r10)
  412460:	mov    %r12,%r10
  412463:	mov    0x10(%r10),%r10
  412467:	mov    %r10,-0x1a18(%rbp)
  41246e:	mov    %r14,%r11
  412471:	mov    %r11,(%r10)
  412474:	mov    -0x1a18(%rbp),%r10
  41247b:	movabs $0x72,%r11
  412485:	mov    %r11,0x8(%r10)
  412489:	mov    -0x1a18(%rbp),%r10
  412490:	add    $0x10,%r10
  412497:	mov    %r10,-0x1a20(%rbp)
  41249e:	mov    %r12,%r10
  4124a1:	mov    -0x1a20(%rbp),%r11
  4124a8:	mov    %r11,0x10(%r10)
  4124ac:	lea    -0x860(%rbp),%r10
  4124b3:	mov    %rbx,%r11
  4124b6:	mov    %r11,(%r10)
  4124b9:	mov    %r12,%r10
  4124bc:	mov    0x10(%r10),%r10
  4124c0:	mov    %r10,-0x1a28(%rbp)
  4124c7:	mov    %rbx,%r11
  4124ca:	mov    %r11,(%r10)
  4124cd:	mov    -0x1a28(%rbp),%r10
  4124d4:	movabs $0x73,%r11
  4124de:	mov    %r11,0x8(%r10)
  4124e2:	mov    -0x1a28(%rbp),%r10
  4124e9:	add    $0x10,%r10
  4124f0:	mov    %r10,-0x1a30(%rbp)
  4124f7:	mov    %r12,%r10
  4124fa:	mov    -0x1a30(%rbp),%r11
  412501:	mov    %r11,0x10(%r10)
  412505:	mov    %r12,%rdi
  412508:	movabs $0x4,%rsi
  412512:	mov    %esi,%esi
  412514:	xor    %eax,%eax
  412516:	callq  41c860 <p111_rt_fail>
  41251b:	mov    %rax,-0x1a38(%rbp)
  412522:	mov    -0x10(%rbp),%r12
  412526:	mov    -0x8(%rbp),%rbx
  41252a:	mov    -0x18(%rbp),%r13
  41252e:	mov    -0x20(%rbp),%r14
  412532:	mov    -0x28(%rbp),%r15
  412536:	mov    %rbp,%rsp
  412539:	pop    %rbp
  41253a:	retq   
  41253b:	mov    %r13,%rdi
  41253e:	shr    $0x28,%rdi
  412542:	and    $0xffff,%rdi
  412549:	movabs $0xa5,%r11
  412553:	cmp    %r11,%rdi
  412556:	jne    412918 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x9b5>
  41255c:	mov    %r12,%rdi
  41255f:	mov    %r13,%rsi
  412562:	lea    -0x860(%rbp),%rdx
  412569:	xor    %eax,%eax
  41256b:	callq  421e70 <p125_rt_take2>
  412570:	mov    %rax,-0x19c0(%rbp)
  412577:	lea    -0x860(%rbp),%r10
  41257e:	mov    (%r10),%r10
  412581:	mov    %r10,-0x1a40(%rbp)
  412588:	lea    -0x860(%rbp),%r10
  41258f:	mov    0x8(%r10),%r10
  412593:	mov    %r10,-0x1a48(%rbp)
  41259a:	mov    %rbx,%rdi
  41259d:	shr    $0x28,%rdi
  4125a1:	and    $0xffff,%rdi
  4125a8:	movabs $0xa4,%r11
  4125b2:	cmp    %r11,%rdi
  4125b5:	jne    4126c7 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x764>
  4125bb:	mov    %rbx,%r10
  4125be:	shr    $0x28,%r10
  4125c2:	mov    %r10,-0x1a50(%rbp)
  4125c9:	and    $0x7fffff,%r10
  4125d0:	mov    %r10,-0x1a58(%rbp)
  4125d7:	movabs $0xa4,%r10
  4125e1:	or     $0x10000,%r10
  4125e8:	mov    %r10,-0x1a60(%rbp)
  4125ef:	mov    -0x1a58(%rbp),%r10
  4125f6:	mov    -0x1a60(%rbp),%r11
  4125fd:	cmp    %r11,%r10
  412600:	jne    412633 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x6d0>
  412606:	mov    %rbx,%r10
  412609:	movabs $0xffffffffff,%r11
  412613:	and    %r11,%r10
  412616:	mov    %r10,-0x1a70(%rbp)
  41261d:	lea    -0x860(%rbp),%r10
  412624:	mov    -0x1a70(%rbp),%r11
  41262b:	mov    %r11,(%r10)
  41262e:	jmpq   41264e <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x6eb>
  412633:	mov    %r12,%rdi
  412636:	mov    %rbx,%rsi
  412639:	lea    -0x860(%rbp),%rdx
  412640:	xor    %eax,%eax
  412642:	callq  421bf0 <p125_rt_take1>
  412647:	mov    %rax,-0x19c0(%rbp)
  41264e:	lea    -0x860(%rbp),%r10
  412655:	mov    (%r10),%r10
  412658:	mov    %r10,-0x1a78(%rbp)
  41265f:	mov    %r12,%rdi
  412662:	mov    -0x1a40(%rbp),%rsi
  412669:	xor    %eax,%eax
  41266b:	callq  41c0d0 <p111_rt_sink>
  412670:	mov    %rax,-0x19c0(%rbp)
  412677:	mov    %r12,%rdi
  41267a:	mov    -0x1a48(%rbp),%rsi
  412681:	xor    %eax,%eax
  412683:	callq  41c0d0 <p111_rt_sink>
  412688:	mov    %rax,-0x19c0(%rbp)
  41268f:	mov    %r12,%rdi
  412692:	mov    -0x1a78(%rbp),%rsi
  412699:	xor    %eax,%eax
  41269b:	callq  41c0d0 <p111_rt_sink>
  4126a0:	mov    %rax,-0x19c0(%rbp)
  4126a7:	movabs $0x1,%r10
  4126b1:	mov    %r10,%rdi
  4126b4:	movabs $0x100a40000000000,%r10
  4126be:	mov    %r10,-0x58(%rbp)
  4126c2:	jmpq   411fae <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  4126c7:	mov    %rbx,%rdi
  4126ca:	shr    $0x28,%rdi
  4126ce:	and    $0xffff,%rdi
  4126d5:	movabs $0xa5,%r11
  4126df:	cmp    %r11,%rdi
  4126e2:	jne    412800 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x89d>
  4126e8:	mov    %r12,%rdi
  4126eb:	mov    %rbx,%rsi
  4126ee:	lea    -0x860(%rbp),%rdx
  4126f5:	xor    %eax,%eax
  4126f7:	callq  421e70 <p125_rt_take2>
  4126fc:	mov    %rax,-0x19c0(%rbp)
  412703:	lea    -0x860(%rbp),%r10
  41270a:	mov    (%r10),%rbx
  41270d:	lea    -0x860(%rbp),%r10
  412714:	mov    0x8(%r10),%r10
  412718:	mov    %r10,-0x1a88(%rbp)
  41271f:	lea    -0x860(%rbp),%r10
  412726:	mov    -0x1a48(%rbp),%r11
  41272d:	mov    %r11,(%r10)
  412730:	lea    -0x860(%rbp),%r10
  412737:	mov    %r14,%r11
  41273a:	mov    %r11,0x8(%r10)
  41273e:	lea    -0x860(%rbp),%r10
  412745:	mov    -0x1a88(%rbp),%r11
  41274c:	mov    %r11,0x10(%r10)
  412750:	mov    0x10(%r12),%rdi
  412755:	mov    %rdi,%r10
  412758:	mov    -0x1a48(%rbp),%r11
  41275f:	mov    %r11,(%r10)
  412762:	lea    -0x860(%rbp),%r10
  412769:	mov    0x8(%r10),%rsi
  41276d:	mov    %rsi,0x8(%rdi)
  412771:	lea    -0x860(%rbp),%r10
  412778:	mov    0x10(%r10),%rsi
  41277c:	mov    %rsi,0x10(%rdi)
  412780:	mov    %rdi,%r10
  412783:	movabs $0x74,%r11
  41278d:	mov    %r11,0x18(%r10)
  412791:	mov    %rdi,%r10
  412794:	add    $0x20,%r10
  41279b:	mov    %r10,-0x1aa0(%rbp)
  4127a2:	mov    %r12,%r10
  4127a5:	mov    -0x1aa0(%rbp),%r11
  4127ac:	mov    %r11,0x10(%r10)
  4127b0:	add    $0x1,%r15
  4127b7:	lea    -0x860(%rbp),%r10
  4127be:	mov    -0x1a40(%rbp),%r11
  4127c5:	mov    %r11,(%r10)
  4127c8:	lea    -0x860(%rbp),%r10
  4127cf:	mov    %rbx,%r11
  4127d2:	mov    %r11,0x8(%r10)
  4127d6:	lea    -0x860(%rbp),%r10
  4127dd:	mov    %r14,%r11
  4127e0:	mov    %r11,0x10(%r10)
  4127e4:	mov    -0x1a40(%rbp),%r10
  4127eb:	mov    %r10,%r13
  4127ee:	movabs $0x0,%r10
  4127f8:	mov    %r10,%rdi
  4127fb:	jmpq   411fae <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  412800:	mov    %r12,%rdi
  412803:	mov    -0x1a40(%rbp),%rsi
  41280a:	xor    %eax,%eax
  41280c:	callq  41c0d0 <p111_rt_sink>
  412811:	mov    %rax,-0x19c0(%rbp)
  412818:	mov    %r12,%rdi
  41281b:	mov    -0x1a48(%rbp),%rsi
  412822:	xor    %eax,%eax
  412824:	callq  41c0d0 <p111_rt_sink>
  412829:	mov    %rax,-0x19c0(%rbp)
  412830:	lea    -0x860(%rbp),%r10
  412837:	mov    %r14,%r11
  41283a:	mov    %r11,(%r10)
  41283d:	mov    %r12,%r10
  412840:	mov    0x10(%r10),%r10
  412844:	mov    %r10,-0x1aa8(%rbp)
  41284b:	mov    %r14,%r11
  41284e:	mov    %r11,(%r10)
  412851:	mov    -0x1aa8(%rbp),%r10
  412858:	movabs $0x76,%r11
  412862:	mov    %r11,0x8(%r10)
  412866:	mov    -0x1aa8(%rbp),%r10
  41286d:	add    $0x10,%r10
  412874:	mov    %r10,-0x1ab0(%rbp)
  41287b:	mov    %r12,%r10
  41287e:	mov    -0x1ab0(%rbp),%r11
  412885:	mov    %r11,0x10(%r10)
  412889:	lea    -0x860(%rbp),%r10
  412890:	mov    %rbx,%r11
  412893:	mov    %r11,(%r10)
  412896:	mov    %r12,%r10
  412899:	mov    0x10(%r10),%r10
  41289d:	mov    %r10,-0x1ab8(%rbp)
  4128a4:	mov    %rbx,%r11
  4128a7:	mov    %r11,(%r10)
  4128aa:	mov    -0x1ab8(%rbp),%r10
  4128b1:	movabs $0x77,%r11
  4128bb:	mov    %r11,0x8(%r10)
  4128bf:	mov    -0x1ab8(%rbp),%r10
  4128c6:	add    $0x10,%r10
  4128cd:	mov    %r10,-0x1ac0(%rbp)
  4128d4:	mov    %r12,%r10
  4128d7:	mov    -0x1ac0(%rbp),%r11
  4128de:	mov    %r11,0x10(%r10)
  4128e2:	mov    %r12,%rdi
  4128e5:	movabs $0x4,%rsi
  4128ef:	mov    %esi,%esi
  4128f1:	xor    %eax,%eax
  4128f3:	callq  41c860 <p111_rt_fail>
  4128f8:	mov    %rax,-0x1a38(%rbp)
  4128ff:	mov    -0x10(%rbp),%r12
  412903:	mov    -0x8(%rbp),%rbx
  412907:	mov    -0x18(%rbp),%r13
  41290b:	mov    -0x20(%rbp),%r14
  41290f:	mov    -0x28(%rbp),%r15
  412913:	mov    %rbp,%rsp
  412916:	pop    %rbp
  412917:	retq   
  412918:	lea    -0x860(%rbp),%r10
  41291f:	mov    %r14,%r11
  412922:	mov    %r11,(%r10)
  412925:	mov    %r12,%r10
  412928:	mov    0x10(%r10),%r10
  41292c:	mov    %r10,-0x1ac8(%rbp)
  412933:	mov    %r14,%r11
  412936:	mov    %r11,(%r10)
  412939:	mov    -0x1ac8(%rbp),%r10
  412940:	movabs $0x78,%r11
  41294a:	mov    %r11,0x8(%r10)
  41294e:	mov    -0x1ac8(%rbp),%r10
  412955:	add    $0x10,%r10
  41295c:	mov    %r10,-0x1ad0(%rbp)
  412963:	mov    %r12,%r10
  412966:	mov    -0x1ad0(%rbp),%r11
  41296d:	mov    %r11,0x10(%r10)
  412971:	lea    -0x860(%rbp),%r10
  412978:	mov    %rbx,%r11
  41297b:	mov    %r11,(%r10)
  41297e:	mov    %r12,%r10
  412981:	mov    0x10(%r10),%r10
  412985:	mov    %r10,-0x1ad8(%rbp)
  41298c:	mov    %rbx,%r11
  41298f:	mov    %r11,(%r10)
  412992:	mov    -0x1ad8(%rbp),%r10
  412999:	movabs $0x79,%r11
  4129a3:	mov    %r11,0x8(%r10)
  4129a7:	mov    -0x1ad8(%rbp),%r10
  4129ae:	add    $0x10,%r10
  4129b5:	mov    %r10,-0x1ae0(%rbp)
  4129bc:	mov    %r12,%r10
  4129bf:	mov    -0x1ae0(%rbp),%r11
  4129c6:	mov    %r11,0x10(%r10)
  4129ca:	lea    -0x860(%rbp),%r10
  4129d1:	mov    %r13,%r11
  4129d4:	mov    %r11,(%r10)
  4129d7:	mov    %r12,%r10
  4129da:	mov    0x10(%r10),%r10
  4129de:	mov    %r10,-0x1ae8(%rbp)
  4129e5:	mov    %r13,%r11
  4129e8:	mov    %r11,(%r10)
  4129eb:	mov    -0x1ae8(%rbp),%r10
  4129f2:	movabs $0x7a,%r11
  4129fc:	mov    %r11,0x8(%r10)
  412a00:	mov    -0x1ae8(%rbp),%r10
  412a07:	add    $0x10,%r10
  412a0e:	mov    %r10,-0x1af0(%rbp)
  412a15:	mov    %r12,%r10
  412a18:	mov    -0x1af0(%rbp),%r11
  412a1f:	mov    %r11,0x10(%r10)
  412a23:	mov    %r12,%rdi
  412a26:	movabs $0x4,%rsi
  412a30:	mov    %esi,%esi
  412a32:	xor    %eax,%eax
  412a34:	callq  41c860 <p111_rt_fail>
  412a39:	mov    %rax,-0x1a38(%rbp)
  412a40:	mov    -0x10(%rbp),%r12
  412a44:	mov    -0x8(%rbp),%rbx
  412a48:	mov    -0x18(%rbp),%r13
  412a4c:	mov    -0x20(%rbp),%r14
  412a50:	mov    -0x28(%rbp),%r15
  412a54:	mov    %rbp,%rsp
  412a57:	pop    %rbp
  412a58:	retq   

Disassembly of section .fini:
