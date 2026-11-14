# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_408447:
  cmp    $0x0,%rdi
.Lpc_40844e:
  jne .Lpc_408464
.Lpc_408464:
  mov    %rdi,%r8
.Lpc_408467:
  sub    $0x1,%r8
.Lpc_40846e:
  mov    %ebx,%ebx
.Lpc_408470:
  add    $0x1,%ebx
.Lpc_408476:
  mov    %esi,%edi
.Lpc_408478:
  add    $0x1,%edi
.Lpc_40847e:
  imul   $0x3,%edi,%edi
.Lpc_408484:
  mov    %rdi,%rdx
.Lpc_408487:
  mov    %esi,%edi
.Lpc_408489:
  add    $0x2,%edi
.Lpc_40848f:
  imul   $0x5,%edi,%edi
.Lpc_408495:
  xor    %rdx,%rdi
.Lpc_408498:
  mov    %rdi,%rdx
.Lpc_40849b:
  mov    %esi,%edi
.Lpc_40849d:
  add    $0x3,%edi
.Lpc_4084a3:
  imul   $0x7,%edi,%edi
.Lpc_4084a9:
  xor    %rdx,%rdi
.Lpc_4084ac:
  mov    %rdi,%rdx
.Lpc_4084af:
  mov    %esi,%edi
.Lpc_4084b1:
  add    $0x4,%edi
.Lpc_4084b7:
  imul   $0x9,%edi,%edi
.Lpc_4084bd:
  xor    %rdx,%rdi
.Lpc_4084c0:
  mov    %rdi,%rdx
.Lpc_4084c3:
  mov    %esi,%edi
.Lpc_4084c5:
  add    $0x5,%edi
.Lpc_4084cb:
  imul   $0xb,%edi,%edi
.Lpc_4084d1:
  xor    %rdx,%rdi
.Lpc_4084d4:
  mov    %rdi,%rdx
.Lpc_4084d7:
  mov    %esi,%edi
.Lpc_4084d9:
  add    $0x6,%edi
.Lpc_4084df:
  imul   $0xd,%edi,%edi
.Lpc_4084e5:
  xor    %rdx,%rdi
.Lpc_4084e8:
  mov    %rdi,%rdx
.Lpc_4084eb:
  mov    %esi,%edi
.Lpc_4084ed:
  add    $0x7,%edi
.Lpc_4084f3:
  imul   $0xf,%edi,%edi
.Lpc_4084f9:
  xor    %rdx,%rdi
.Lpc_4084fc:
  mov    %rdi,%rdx
.Lpc_4084ff:
  mov    %esi,%edi
.Lpc_408501:
  add    $0x8,%edi
.Lpc_408507:
  imul   $0x11,%edi,%edi
.Lpc_40850d:
  xor    %rdx,%rdi
.Lpc_408510:
  mov    %rdi,%rdx
.Lpc_408513:
  mov    %esi,%edi
.Lpc_408515:
  add    $0x9,%edi
.Lpc_40851b:
  imul   $0x13,%edi,%edi
.Lpc_408521:
  xor    %rdx,%rdi
.Lpc_408524:
  mov    %rdi,%rdx
.Lpc_408527:
  mov    %esi,%edi
.Lpc_408529:
  add    $0xa,%edi
.Lpc_40852f:
  imul   $0x15,%edi,%edi
.Lpc_408535:
  xor    %rdx,%rdi
.Lpc_408538:
  mov    %rdi,%rdx
.Lpc_40853b:
  mov    %esi,%edi
.Lpc_40853d:
  add    $0xb,%edi
.Lpc_408543:
  imul   $0x17,%edi,%edi
.Lpc_408549:
  xor    %rdx,%rdi
.Lpc_40854c:
  mov    %rdi,%rdx
.Lpc_40854f:
  mov    %esi,%edi
.Lpc_408551:
  add    $0xc,%edi
.Lpc_408557:
  imul   $0x19,%edi,%edi
.Lpc_40855d:
  xor    %rdx,%rdi
.Lpc_408560:
  mov    %rdi,%rsi
.Lpc_408563:
  mov    %r8,%rdi
.Lpc_408566:
  jmpq .Lpc_408447
