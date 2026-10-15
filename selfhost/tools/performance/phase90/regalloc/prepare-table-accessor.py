#!/usr/bin/env python3
"""Offline exact-C two-edit diagnostic and bounded synthetic dispatch controls."""
import hashlib, json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
OUT = Path(sys.argv[1]).resolve(); OUT.mkdir(parents=True, exist_ok=False)
SOURCE = ROOT/'selfhost/build/phase90/js-self11/program.c'
PARENT_SHA = '81ca2837d2f274a23aeab7addf40cbef0e62a96a5ff7026c62a5112b1be0361e'
def pin(p):
    b = p.read_bytes(); return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))
s = SOURCE.read_text(); assert pin(SOURCE)['sha256'] == PARENT_SHA
edits = [
 ('#define WL_DYN(F)  __attribute__((musttail)) return wl_tab[F](WL_ALL)',
  '#define WL_DYN(F)  __attribute__((musttail)) return wl_target(F)(WL_ALL)'),
 ('static const WlFn wl_tab[] = { WL_TABLE };\n#undef WL_X',
  'static const WlFn wl_tab[] = { WL_TABLE };\n#undef WL_X\n'
  'FAR PRESERVE(preserve_most) WlFn wl_target(Fid id) { return wl_tab[id]; }')]
for old,new in edits:
    assert s.count(old) == 1; s = s.replace(old,new,1)
p = OUT/'program-accessor.c'; p.write_text(s)
for old,new in reversed(edits):
    assert s.count(new) == 1; s = s.replace(new,old,1)
assert s.encode() == SOURCE.read_bytes()
abi = (ROOT/'selfhost/tools/performance/phase90/regalloc/preserve-tail-padding.c').read_text()
wl = '\n'.join(l for l in abi.splitlines() if l.startswith(('#define WL_SIG ', '#define WL_ALL ')))
head = r"""// Synthetic dispatch-table scaling/ABI diagnostic, not a compiler image.
#include <stdio.h>
typedef unsigned long long u64;
typedef unsigned int u32;
typedef u64 Term;
typedef Term Reply;
typedef Term *Stk;
typedef u32 Fid;
typedef struct { u64 *mem; u64 *alc; } Env;
#define CC __attribute__((preserve_none))
#define FN static CC __attribute__((noinline)) Reply
"""+wl+r"""
typedef Reply (CC *WlFn)(WL_SIG);
#ifndef USE_ACCESSOR
#define USE_ACCESSOR 0
#endif
"""
sumargs = '+'.join('r'+str(i) for i in range(21))
rows = []
for n in [512,2048]:
    text = head+f'#define N {n}u\n'
    text += ''.join(f'FN f{i}(WL_SIG);\n' for i in range(n))
    text += 'static const WlFn wl_tab[] = {'+','.join('f'+str(i) for i in range(n))+'};\n'
    text += r"""#if USE_ACCESSOR
static __attribute__((noinline,preserve_most)) WlFn wl_target(Fid id) { return wl_tab[id]; }
#define DYN(F) __attribute__((musttail)) return wl_target(F)(WL_ALL)
#else
#define DYN(F) __attribute__((musttail)) return wl_tab[F](WL_ALL)
#endif
"""
    for i in range(n):
        text += f'FN f{i}(WL_SIG) {{ if (!rn) return e.mem[0]+e.alc[0]+sp[0]+seq+rn+{sumargs}+{i}u; rn--; r0+={i+1}u; {{ Term rp; DYN((Fid)((r0+r1)%N)); }} }}\n'
    text += r"""int main(void) {
  u64 mem=7,alc=11,stack=13,total=0;
  Env e={&mem,&alc};
  for (u32 i=0;i<N;i++) {
    u64 expected_r0=1; u32 id=i;
    for (u32 k=0;k<3;k++) { expected_r0+=id+1; id=(u32)((expected_r0+2)%N); }
    u64 expected=278+expected_r0+id;
    u64 got=wl_tab[i](e,&stack,17,3,1,2,3,4,5,6,99,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21);
    if(got!=expected) { fprintf(stderr,"id=%u got=%llu expected=%llu\n",i,got,expected); return 1; }
    total+=got;
  }
  printf("%llu\n",total); return 0;
}
"""
    # The Python raw string above needs literal C backslash-n, not double slash.
    text = text.replace('\\\\n','\\n')
    p=OUT/f'table-{n}.c'; p.write_text(text)
    total=0
    for i in range(n):
        v=1; idx=i
        for _ in range(3): v+=idx+1; idx=(v+2)%n
        total+=278+v+idx
    for accessor in [0,1]:
        rows.append(dict(size=n, accessor=bool(accessor), source=pin(p), flags=['-O1',f'-DUSE_ACCESSOR={accessor}'], expectedStdout=str(total)+'\n', expectedExitCode=0))
receipt=dict(kind='phase90-native-C-table-accessor-diagnostic', targetExecuted=False,
  parent=pin(SOURCE), output=pin(OUT/'program-accessor.c'), recipe=pin(Path(__file__)),
  edits=[dict(old=o,new=n) for o,n in edits], exactInverse=True,
  claims=['Only host dynamic lookup changes; DEVICE path unchanged.',
          'No canonical source, runtime template, or compiler image admission changed.',
          'Added noinline preserve_most lookup can change execution cost; gates and timing remain required.'],
  controls=rows)
(OUT/'derivation.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(dict(out=str(OUT), derivative=receipt['output'], controls=len(rows))))
