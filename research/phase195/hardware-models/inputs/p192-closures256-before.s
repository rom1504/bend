# Straight-line positive-path projection; original instruction order retained.
# Exit instructions omitted. Branch destinations are labels only; original layout is NOT reproduced.
.text
.Lloop:
.Lpc_4083f7:
  cmp    $0x0,%rdi
.Lpc_4083fe:
  je .Lpc_408404
.Lpc_408404:
  sub    $0x1,%rdi
.Lpc_40840b:
  mov    %edi,%esi
.Lpc_40840d:
  mov    %rsi,%r11
.Lpc_408410:
  movabs $0x1,%rsi
.Lpc_40841a:
  add    %r11d,%esi
.Lpc_40841d:
  mov    %edx,%edx
.Lpc_40841f:
  mov    %rsi,%r11
.Lpc_408422:
  mov    %rdx,%rsi
.Lpc_408425:
  add    %r11d,%esi
.Lpc_408428:
  mov    %rsi,%rdx
.Lpc_40842b:
  jmpq .Lpc_4083f7
