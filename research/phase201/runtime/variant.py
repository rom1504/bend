"""Offline runtime overlay: avoid general destruction for known non-last shared owners."""
import argparse
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]

def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old, new)

def source(original, parent='original', mode='all'):
    assert parent in ('original', 'live')
    assert mode in ('control', 'span', 'all')
    text = original
    if parent == 'live':
        split = runpy.run_path(str(ROOT/'research/phase198/runtime/bind-facts.py'))['variant'](original, 'split')
        text = runpy.run_path(str(ROOT/'research/phase198/runtime-broad/live.py'))['variant'](original, split)
    if mode == 'control':
        return text
    helper = '''
// Phase201: only the audited single-Bend-heap-mutator configuration admits
// this reread-and-decrement shortcut. No atomics in any other mode change.
INLINE bool p201_drop_shared(Env e, Term t) {
#if P144_SINGLE_MUTATOR_RFC
  if (!term_triv(t) && term_rfc(t)) {
    DEV u32* p = a32_at(e.mem, term_loc(t));
    u32 old;
    memcpy(&old, p, sizeof old);
    if ((old & RFC_CNT) > 1) {
      u32 next = old - 1;
      memcpy(p, &next, sizeof next);
      return true;
    }
  }
#endif
  return false;
}
'''
    decl = 'FAR void term_drop(Env e, Term t);'
    if mode == 'span':
        text = once(text, decl, helper + '\n' + decl)
        anchor = '  term_drop(e, t);\n}\n\nINLINE Loc ctr_take'
        text = once(text, anchor, '  if (!p201_drop_shared(e, t)) term_drop(e, t);\n}\n\nINLINE Loc ctr_take')
    else:
        text = once(text, decl, helper + '''
FAR void p201_term_drop_slow(Env e, Term t);
INLINE void term_drop(Env e, Term t) {
  if (!p201_drop_shared(e, t)) p201_term_drop_slow(e, t);
}
''')
        text = once(text, 'FAR void term_drop(Env e, Term t) {', 'FAR void p201_term_drop_slow(Env e, Term t) {')
    return text

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, default=ROOT/'selfhost/src/runtime/qbe/runtime.c')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--parent', choices=['original','live'], default='original')
    parser.add_argument('--mode', choices=['control','span','all'], default='all')
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open('x') as out:
        out.write(source(args.input.read_text(), args.parent, args.mode))
