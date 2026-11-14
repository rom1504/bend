# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_408379:
  cmp    $0x0,%rdi
.Lpc_408380:
  jne .Lpc_408396
.Lpc_408396:
  mov    %rdi,%rdx
.Lpc_408399:
  sub    $0x1,%rdx
.Lpc_4083a0:
  mov    %ebx,%edi
.Lpc_4083a2:
  mov    %rdi,%r8
.Lpc_4083a5:
  add    $0x1,%r8d
.Lpc_4083ac:
  mov    %esi,%edi
.Lpc_4083ae:
  mov    %ebx,%ebx
.Lpc_4083b0:
  add    %ebx,%edi
.Lpc_4083b2:
  movabs $0x9e3779b9,%r11
.Lpc_4083bc:
  xor    %r11,%rdi
.Lpc_4083bf:
  imul   $0x19660d,%edi,%edi
.Lpc_4083c5:
  mov    %esi,%ebx
.Lpc_4083c7:
  add    %ebx,%edi
.Lpc_4083c9:
  mov    %r8,%rbx
.Lpc_4083cc:
  mov    %rdi,%rsi
.Lpc_4083cf:
  mov    %rdx,%rdi
.Lpc_4083d2:
  jmpq .Lpc_408379
