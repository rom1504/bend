# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_4083cd:
  cmp    $0x0,%rdi
.Lpc_4083d4:
  jne .Lpc_4083ea
.Lpc_4083ea:
  mov    %rdi,%rdx
.Lpc_4083ed:
  sub    $0x1,%rdx
.Lpc_4083f4:
  mov    %ebx,%edi
.Lpc_4083f6:
  mov    %rdi,%r8
.Lpc_4083f9:
  add    $0x1,%r8d
.Lpc_408400:
  mov    %esi,%edi
.Lpc_408402:
  mov    %ebx,%ebx
.Lpc_408404:
  add    %ebx,%edi
.Lpc_408406:
  movabs $0x9e3779b9,%r11
.Lpc_408410:
  xor    %r11,%rdi
.Lpc_408413:
  imul   $0x19660d,%edi,%edi
.Lpc_408419:
  mov    %esi,%ebx
.Lpc_40841b:
  add    %ebx,%edi
.Lpc_40841d:
  mov    %r8,%rbx
.Lpc_408420:
  mov    %rdi,%rsi
.Lpc_408423:
  mov    %rdx,%rdi
.Lpc_408426:
  jmpq .Lpc_4083cd
