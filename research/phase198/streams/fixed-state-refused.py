"""Isolated source counterfactual. The general compiler candidate is separate."""
def source(text):
    begin='def mit(n: Nat, +cr: U32, +ci: U32, +zr: U32, +zi: U32, esc: U32,'
    end='mit(p, cr, ci, sr, si, e2, U32.add(it, b2u(U32.is_zero(e2))))'
    assert text.count(begin)==1 and text.count(end)==1
    spec="""law probe.stable:
  for stable: Bool
  for p: Nat
  for cr: U32
  for ci: U32
  for zr: U32
  for zi: U32
  for esc: U32
  for it: U32
  for delta: U32
  U32

"""
    route="""probe.stable(U32.is_eq(sr, zr) && U32.is_eq(si, zi) && U32.is_eq(e2, esc),
        p, cr, ci, sr, si, e2, it, b2u(U32.is_zero(e2)))

def probe.stable(stable, p, cr, ci, zr, zi, esc, it, delta):
  match stable:
    case True{}:
      U32.add(it, U32.mul(U32.inc(U32.from_nat(p)), delta))
    case False{}:
      mit(p, cr, ci, zr, zi, esc, U32.add(it, delta))"""
    text=text.replace(begin,spec+begin.replace(' esc:',' +esc:')).replace(end,route)
    for name in ('sr','si'):
        prefix='      '+name+' = sel'
        assert text.count(prefix)==1
        text=text.replace(prefix,'      +'+name+' = sel')
    return text
