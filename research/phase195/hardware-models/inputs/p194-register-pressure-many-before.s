# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_408505:
  cmp    $0x0,%rdi
.Lpc_40850c:
  jne .Lpc_40852e
.Lpc_40852e:
  mov    %rdi,%r10
.Lpc_408531:
  sub    $0x1,%r10
.Lpc_408538:
  mov    %r10,-0x8b0(%rbp)
.Lpc_40853f:
  mov    %ebx,%ebx
.Lpc_408541:
  mov    %rbx,%r10
.Lpc_408544:
  add    $0x1,%r10d
.Lpc_40854b:
  mov    %r10,-0x8c0(%rbp)
.Lpc_408552:
  mov    %esi,%edi
.Lpc_408554:
  add    $0x1,%edi
.Lpc_40855a:
  imul   $0x3,%edi,%edi
.Lpc_408560:
  mov    %rdi,%rdx
.Lpc_408563:
  mov    %esi,%edi
.Lpc_408565:
  add    $0x2,%edi
.Lpc_40856b:
  imul   $0x5,%edi,%edi
.Lpc_408571:
  mov    %rdi,%r8
.Lpc_408574:
  mov    %esi,%edi
.Lpc_408576:
  add    $0x3,%edi
.Lpc_40857c:
  imul   $0x7,%edi,%edi
.Lpc_408582:
  mov    %rdi,%r9
.Lpc_408585:
  mov    %esi,%edi
.Lpc_408587:
  add    $0x4,%edi
.Lpc_40858d:
  imul   $0x9,%edi,%edi
.Lpc_408593:
  mov    %rdi,%rbx
.Lpc_408596:
  mov    %esi,%edi
.Lpc_408598:
  add    $0x5,%edi
.Lpc_40859e:
  imul   $0xb,%edi,%edi
.Lpc_4085a4:
  mov    %rdi,%r13
.Lpc_4085a7:
  mov    %esi,%edi
.Lpc_4085a9:
  add    $0x6,%edi
.Lpc_4085af:
  imul   $0xd,%edi,%edi
.Lpc_4085b5:
  mov    %rdi,%r14
.Lpc_4085b8:
  mov    %esi,%edi
.Lpc_4085ba:
  add    $0x7,%edi
.Lpc_4085c0:
  imul   $0xf,%edi,%edi
.Lpc_4085c6:
  mov    %rdi,%r15
.Lpc_4085c9:
  mov    %esi,%edi
.Lpc_4085cb:
  add    $0x8,%edi
.Lpc_4085d1:
  imul   $0x11,%edi,%edi
.Lpc_4085d7:
  mov    %rdi,%r10
.Lpc_4085da:
  mov    %r10,-0x910(%rbp)
.Lpc_4085e1:
  mov    %esi,%edi
.Lpc_4085e3:
  add    $0x9,%edi
.Lpc_4085e9:
  imul   $0x13,%edi,%edi
.Lpc_4085ef:
  mov    %rdi,%r10
.Lpc_4085f2:
  mov    %r10,-0x918(%rbp)
.Lpc_4085f9:
  mov    %esi,%edi
.Lpc_4085fb:
  add    $0xa,%edi
.Lpc_408601:
  imul   $0x15,%edi,%edi
.Lpc_408607:
  mov    %rdi,%r10
.Lpc_40860a:
  mov    %r10,-0x920(%rbp)
.Lpc_408611:
  mov    %esi,%edi
.Lpc_408613:
  add    $0xb,%edi
.Lpc_408619:
  imul   $0x17,%edi,%edi
.Lpc_40861f:
  mov    %rdi,%r10
.Lpc_408622:
  mov    %r10,-0x928(%rbp)
.Lpc_408629:
  mov    %esi,%edi
.Lpc_40862b:
  add    $0xc,%edi
.Lpc_408631:
  imul   $0x19,%edi,%edi
.Lpc_408637:
  mov    %rdi,%rsi
.Lpc_40863a:
  mov    %rdx,%rdi
.Lpc_40863d:
  xor    %r8,%rdi
.Lpc_408640:
  xor    %r9,%rdi
.Lpc_408643:
  xor    %rbx,%rdi
.Lpc_408646:
  xor    %r13,%rdi
.Lpc_408649:
  xor    %r14,%rdi
.Lpc_40864c:
  xor    %r15,%rdi
.Lpc_40864f:
  mov    -0x910(%rbp),%r11
.Lpc_408656:
  xor    %r11,%rdi
.Lpc_408659:
  mov    -0x918(%rbp),%r11
.Lpc_408660:
  xor    %r11,%rdi
.Lpc_408663:
  mov    -0x920(%rbp),%r11
.Lpc_40866a:
  xor    %r11,%rdi
.Lpc_40866d:
  mov    -0x928(%rbp),%r11
.Lpc_408674:
  xor    %r11,%rdi
.Lpc_408677:
  xor    %rsi,%rdi
.Lpc_40867a:
  mov    -0x8c0(%rbp),%r10
.Lpc_408681:
  mov    %r10,%rbx
.Lpc_408684:
  mov    %rdi,%rsi
.Lpc_408687:
  mov    -0x8b0(%rbp),%r10
.Lpc_40868e:
  mov    %r10,%rdi
.Lpc_408691:
  jmpq .Lpc_408505
