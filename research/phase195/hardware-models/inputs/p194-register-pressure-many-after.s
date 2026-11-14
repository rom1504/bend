# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_4084b1:
  cmp    $0x0,%rdi
.Lpc_4084b8:
  jne .Lpc_4084da
.Lpc_4084da:
  mov    %rdi,%r10
.Lpc_4084dd:
  sub    $0x1,%r10
.Lpc_4084e4:
  mov    %r10,-0x8b0(%rbp)
.Lpc_4084eb:
  mov    %ebx,%ebx
.Lpc_4084ed:
  mov    %rbx,%r10
.Lpc_4084f0:
  add    $0x1,%r10d
.Lpc_4084f7:
  mov    %r10,-0x8c0(%rbp)
.Lpc_4084fe:
  mov    %esi,%edi
.Lpc_408500:
  add    $0x1,%edi
.Lpc_408506:
  imul   $0x3,%edi,%edi
.Lpc_40850c:
  mov    %rdi,%rdx
.Lpc_40850f:
  mov    %esi,%edi
.Lpc_408511:
  add    $0x2,%edi
.Lpc_408517:
  imul   $0x5,%edi,%edi
.Lpc_40851d:
  mov    %rdi,%r8
.Lpc_408520:
  mov    %esi,%edi
.Lpc_408522:
  add    $0x3,%edi
.Lpc_408528:
  imul   $0x7,%edi,%edi
.Lpc_40852e:
  mov    %rdi,%r9
.Lpc_408531:
  mov    %esi,%edi
.Lpc_408533:
  add    $0x4,%edi
.Lpc_408539:
  imul   $0x9,%edi,%edi
.Lpc_40853f:
  mov    %rdi,%rbx
.Lpc_408542:
  mov    %esi,%edi
.Lpc_408544:
  add    $0x5,%edi
.Lpc_40854a:
  imul   $0xb,%edi,%edi
.Lpc_408550:
  mov    %rdi,%r13
.Lpc_408553:
  mov    %esi,%edi
.Lpc_408555:
  add    $0x6,%edi
.Lpc_40855b:
  imul   $0xd,%edi,%edi
.Lpc_408561:
  mov    %rdi,%r14
.Lpc_408564:
  mov    %esi,%edi
.Lpc_408566:
  add    $0x7,%edi
.Lpc_40856c:
  imul   $0xf,%edi,%edi
.Lpc_408572:
  mov    %rdi,%r15
.Lpc_408575:
  mov    %esi,%edi
.Lpc_408577:
  add    $0x8,%edi
.Lpc_40857d:
  imul   $0x11,%edi,%edi
.Lpc_408583:
  mov    %rdi,%r10
.Lpc_408586:
  mov    %r10,-0x910(%rbp)
.Lpc_40858d:
  mov    %esi,%edi
.Lpc_40858f:
  add    $0x9,%edi
.Lpc_408595:
  imul   $0x13,%edi,%edi
.Lpc_40859b:
  mov    %rdi,%r10
.Lpc_40859e:
  mov    %r10,-0x918(%rbp)
.Lpc_4085a5:
  mov    %esi,%edi
.Lpc_4085a7:
  add    $0xa,%edi
.Lpc_4085ad:
  imul   $0x15,%edi,%edi
.Lpc_4085b3:
  mov    %rdi,%r10
.Lpc_4085b6:
  mov    %r10,-0x920(%rbp)
.Lpc_4085bd:
  mov    %esi,%edi
.Lpc_4085bf:
  add    $0xb,%edi
.Lpc_4085c5:
  imul   $0x17,%edi,%edi
.Lpc_4085cb:
  mov    %rdi,%r10
.Lpc_4085ce:
  mov    %r10,-0x928(%rbp)
.Lpc_4085d5:
  mov    %esi,%edi
.Lpc_4085d7:
  add    $0xc,%edi
.Lpc_4085dd:
  imul   $0x19,%edi,%edi
.Lpc_4085e3:
  mov    %rdi,%rsi
.Lpc_4085e6:
  mov    %rdx,%rdi
.Lpc_4085e9:
  xor    %r8,%rdi
.Lpc_4085ec:
  xor    %r9,%rdi
.Lpc_4085ef:
  xor    %rbx,%rdi
.Lpc_4085f2:
  xor    %r13,%rdi
.Lpc_4085f5:
  xor    %r14,%rdi
.Lpc_4085f8:
  xor    %r15,%rdi
.Lpc_4085fb:
  mov    -0x910(%rbp),%r11
.Lpc_408602:
  xor    %r11,%rdi
.Lpc_408605:
  mov    -0x918(%rbp),%r11
.Lpc_40860c:
  xor    %r11,%rdi
.Lpc_40860f:
  mov    -0x920(%rbp),%r11
.Lpc_408616:
  xor    %r11,%rdi
.Lpc_408619:
  mov    -0x928(%rbp),%r11
.Lpc_408620:
  xor    %r11,%rdi
.Lpc_408623:
  xor    %rsi,%rdi
.Lpc_408626:
  mov    -0x8c0(%rbp),%r10
.Lpc_40862d:
  mov    %r10,%rbx
.Lpc_408630:
  mov    %rdi,%rsi
.Lpc_408633:
  mov    -0x8b0(%rbp),%r10
.Lpc_40863a:
  mov    %r10,%rdi
.Lpc_40863d:
  jmpq .Lpc_4084b1
