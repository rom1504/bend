# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_4084dd:
  cmp    $0x0,%rdi
.Lpc_4084e4:
  jne .Lpc_4084fa
.Lpc_4084fa:
  mov    %rdi,%r8
.Lpc_4084fd:
  sub    $0x1,%r8
.Lpc_408504:
  mov    %ebx,%ebx
.Lpc_408506:
  add    $0x1,%ebx
.Lpc_40850c:
  mov    %esi,%edi
.Lpc_40850e:
  add    $0x1,%edi
.Lpc_408514:
  imul   $0x3,%edi,%edi
.Lpc_40851a:
  mov    %rdi,%rdx
.Lpc_40851d:
  mov    %esi,%edi
.Lpc_40851f:
  add    $0x2,%edi
.Lpc_408525:
  imul   $0x5,%edi,%edi
.Lpc_40852b:
  mov    %rdi,%r11
.Lpc_40852e:
  mov    %rdx,%rdi
.Lpc_408531:
  xor    %r11,%rdi
.Lpc_408534:
  mov    %rdi,%rdx
.Lpc_408537:
  mov    %esi,%edi
.Lpc_408539:
  add    $0x3,%edi
.Lpc_40853f:
  imul   $0x7,%edi,%edi
.Lpc_408545:
  mov    %rdi,%r11
.Lpc_408548:
  mov    %rdx,%rdi
.Lpc_40854b:
  xor    %r11,%rdi
.Lpc_40854e:
  mov    %rdi,%rdx
.Lpc_408551:
  mov    %esi,%edi
.Lpc_408553:
  add    $0x4,%edi
.Lpc_408559:
  imul   $0x9,%edi,%edi
.Lpc_40855f:
  mov    %rdi,%r11
.Lpc_408562:
  mov    %rdx,%rdi
.Lpc_408565:
  xor    %r11,%rdi
.Lpc_408568:
  mov    %rdi,%rdx
.Lpc_40856b:
  mov    %esi,%edi
.Lpc_40856d:
  add    $0x5,%edi
.Lpc_408573:
  imul   $0xb,%edi,%edi
.Lpc_408579:
  mov    %rdi,%r11
.Lpc_40857c:
  mov    %rdx,%rdi
.Lpc_40857f:
  xor    %r11,%rdi
.Lpc_408582:
  mov    %rdi,%rdx
.Lpc_408585:
  mov    %esi,%edi
.Lpc_408587:
  add    $0x6,%edi
.Lpc_40858d:
  imul   $0xd,%edi,%edi
.Lpc_408593:
  mov    %rdi,%r11
.Lpc_408596:
  mov    %rdx,%rdi
.Lpc_408599:
  xor    %r11,%rdi
.Lpc_40859c:
  mov    %rdi,%rdx
.Lpc_40859f:
  mov    %esi,%edi
.Lpc_4085a1:
  add    $0x7,%edi
.Lpc_4085a7:
  imul   $0xf,%edi,%edi
.Lpc_4085ad:
  mov    %rdi,%r11
.Lpc_4085b0:
  mov    %rdx,%rdi
.Lpc_4085b3:
  xor    %r11,%rdi
.Lpc_4085b6:
  mov    %rdi,%rdx
.Lpc_4085b9:
  mov    %esi,%edi
.Lpc_4085bb:
  add    $0x8,%edi
.Lpc_4085c1:
  imul   $0x11,%edi,%edi
.Lpc_4085c7:
  mov    %rdi,%r11
.Lpc_4085ca:
  mov    %rdx,%rdi
.Lpc_4085cd:
  xor    %r11,%rdi
.Lpc_4085d0:
  mov    %rdi,%rdx
.Lpc_4085d3:
  mov    %esi,%edi
.Lpc_4085d5:
  add    $0x9,%edi
.Lpc_4085db:
  imul   $0x13,%edi,%edi
.Lpc_4085e1:
  mov    %rdi,%r11
.Lpc_4085e4:
  mov    %rdx,%rdi
.Lpc_4085e7:
  xor    %r11,%rdi
.Lpc_4085ea:
  mov    %rdi,%rdx
.Lpc_4085ed:
  mov    %esi,%edi
.Lpc_4085ef:
  add    $0xa,%edi
.Lpc_4085f5:
  imul   $0x15,%edi,%edi
.Lpc_4085fb:
  mov    %rdi,%r11
.Lpc_4085fe:
  mov    %rdx,%rdi
.Lpc_408601:
  xor    %r11,%rdi
.Lpc_408604:
  mov    %rdi,%rdx
.Lpc_408607:
  mov    %esi,%edi
.Lpc_408609:
  add    $0xb,%edi
.Lpc_40860f:
  imul   $0x17,%edi,%edi
.Lpc_408615:
  mov    %rdi,%r11
.Lpc_408618:
  mov    %rdx,%rdi
.Lpc_40861b:
  xor    %r11,%rdi
.Lpc_40861e:
  mov    %rdi,%rdx
.Lpc_408621:
  mov    %esi,%edi
.Lpc_408623:
  add    $0xc,%edi
.Lpc_408629:
  imul   $0x19,%edi,%edi
.Lpc_40862f:
  mov    %rdi,%r11
.Lpc_408632:
  mov    %rdx,%rdi
.Lpc_408635:
  xor    %r11,%rdi
.Lpc_408638:
  mov    %rdi,%rsi
.Lpc_40863b:
  mov    %r8,%rdi
.Lpc_40863e:
  jmpq .Lpc_4084dd
