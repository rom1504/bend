# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_408379:
  cmp    $0x0,%rdi
.Lpc_408380:
  je .Lpc_408386
.Lpc_408386:
  sub    $0x1,%rdi
.Lpc_40838d:
  mov    %edi,%esi
.Lpc_40838f:
  mov    %rsi,%r11
.Lpc_408392:
  movabs $0x1,%rsi
.Lpc_40839c:
  add    %r11d,%esi
.Lpc_40839f:
  mov    %edx,%edx
.Lpc_4083a1:
  mov    %rsi,%r11
.Lpc_4083a4:
  mov    %rdx,%rsi
.Lpc_4083a7:
  add    %r11d,%esi
.Lpc_4083aa:
  mov    %rsi,%rdx
.Lpc_4083ad:
  jmpq .Lpc_408379
