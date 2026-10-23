"""Derive counter-only reshape runtime source; no builds or target execution."""
import argparse
import hashlib
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
COUNTERS=['heap_alloc_calls','constructor_cells','ctr_take_calls','ctr_take_fields','ctr_take_wrapped_calls',
          'reshape_attempts','reshape_successes','reshape_refused_tag','reshape_refused_rfc','reshape_refused_static_or_same','reused_shells']
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
r=json.loads(a.runtime.read_text());assert r['complete'] and r['kind']=='phase126-local-reshape-additive-runtime'
for x in [*r['inputs'],r['source'],r['object']]:verify(x)
authority=json.loads((HERE/'manifest04.json').read_text());assert r['extension']==authority['runtime'];verify(authority['runtime'])
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
original=Path(r['source']['file']).read_text();text=original;patches=[]
ctor_sites=[dict(line=i,text=line.strip()) for i,line in enumerate(original.splitlines(),1) if 'term_ctr(' in line and not line.startswith('#define term_ctr(')]
assert len(ctor_sites)==11

def replace(label,old,new):
 global text
 assert text.count(old)==1,(label,text.count(old));text=text.replace(old,new);patches.append(dict(label=label,old=old,new=new,occurrences=1))
replace('include','#include "runtime.h"','#include "runtime.h"\n#include "p126-counts.h"')
replace('heap-allocation','INLINE Loc heap_alloc(Env e, Cls cls) {','INLINE Loc heap_alloc(Env e, Cls cls) {\n  P126C_ADD(heap_alloc_calls,1);')
replace('constructor-materialization','#define term_ctr(cid, loc) term_make(TAG_CTR, cid, loc)',
 'INLINE Term p126c_ctr(u64 cid, Loc loc) {\n  P126C_ADD(constructor_cells,1); P126C_HIT(p126c_ctor,cid,1);\n  return term_make(TAG_CTR,cid,loc);\n}\n#define term_ctr(cid, loc) p126c_ctr((cid),(loc))')
replace('consuming-take','INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {',
 'INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {\n  P126C_ADD(ctr_take_calls,1); P126C_ADD(ctr_take_fields,n);\n  P126C_ADD(ctr_take_wrapped_calls,term_rfc(t)?1:0); P126C_HIT(p126c_take,term_aux(t),1);')
replace('reshape-attempt','  if (term_tag(left) != TAG_CTR || term_tag(right) != TAG_CTR ||',
 '  P126C_ADD(reshape_attempts,1);\n  if (term_tag(left) != TAG_CTR || term_tag(right) != TAG_CTR ||')
replace('reshape-tag-rfc-refusal','      term_rfc(left) || term_rfc(right)) return 0;',
 '      term_rfc(left) || term_rfc(right)) {\n    if (term_tag(left)!=TAG_CTR || term_tag(right)!=TAG_CTR || term_aux(left)!=cid || term_aux(right)!=cid) P126C_ADD(reshape_refused_tag,1);\n    else P126C_ADD(reshape_refused_rfc,1);\n    return 0;\n  }')
replace('reshape-static-same-refusal','  if (a < HEAP_OFF || b < HEAP_OFF || a == b) return 0;',
 '  if (a < HEAP_OFF || b < HEAP_OFF || a == b) { P126C_ADD(reshape_refused_static_or_same,1); return 0; }')
replace('reshape-success','  Term outer[2] = {left, right};',
 '  P126C_ADD(reshape_successes,1); P126C_ADD(reused_shells,2); P126C_HIT(p126c_reuse,cid,2);\n  Term outer[2] = {left, right};')
replace('normal-return','  int code  = io_loop(H);\n  io_sync();\n  return code;',
 '  int code  = io_loop(H);\n  io_sync();\n  p126c_dump(code);\n  return code;')
support='\n'+(HERE/'counts-support.inc.c').read_text();derived=text+support;inverse=derived[:-len(support)]
for patch in reversed(patches):assert inverse.count(patch['new'])==1;inverse=inverse.replace(patch['new'],patch['old'])
assert inverse==original
header='#ifndef P126_COUNTS_H\n#define P126_COUNTS_H\n#include <stdint.h>\n#include <stddef.h>\n'
header+='#define P126C_SOURCE_SHA '+json.dumps(r['source']['sha256'])+'\n'
header+='enum { '+', '.join('P126C_'+name for name in COUNTERS)+', P126C_COUNT };\n'
header+='static uint64_t p126c_invalid,p126c_counts[P126C_COUNT],p126c_ctor[65536],p126c_take[65536],p126c_reuse[65536];\n'
header+='static const char *const p126c_names[] = {'+','.join(json.dumps(x) for x in COUNTERS)+'};\n'
header+='''static inline void p126c_add(uint64_t *counter,uint64_t amount) {
  uint64_t before=*counter; *counter+=amount; if (*counter<before) p126c_invalid=1;
}
#define P126C_ADD(N,V) p126c_add(&p126c_counts[P126C_##N],(V))
#define P126C_HIT(A,I,V) do { uint64_t p126c_i_=(I); if (p126c_i_<sizeof(A)/sizeof((A)[0])) p126c_add(&(A)[p126c_i_],(V)); else p126c_invalid=1; } while(0)
static void p126c_dump(int status);
#endif
'''
out.mkdir(parents=True);(out/'runtime.c').write_text(derived);(out/'p126-counts.h').write_text(header)
headers=[]
for name in ['runtime.h','primitives.h']:
 source=Path(r['source']['file']).parent/name;headers.append(pin(source));(out/name).write_bytes(source.read_bytes())
inputs=[pin(__file__),pin(HERE/'counts-support.inc.c'),pin(HERE/'manifest04.json'),pin(a.runtime),*r['inputs'],r['source'],r['object'],*headers]
for x in inputs:verify(x)
manifest=dict(kind='phase126-diagnostic-reshape-count-runtime',diagnosticOnly=True,compiled=False,targetsRun=False,source=pin(out/'runtime.c'),parent=r['source'],inputs=inputs,
 outputs=[pin(out/n) for n in ['runtime.c','runtime.h','primitives.h','p126-counts.h']],exactInverseVerified=True,patches=patches,constructorSites=ctor_sites,counters=COUNTERS,
 command=[r['command'][0],'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')],
 scope='Whole sequential runtime including wrapper/readback. Use this same additive diagnostic runtime for parent and candidate QBE; counters are not timing evidence. reused_shells=2*successes is structural work avoided, not an independent allocator measurement.',
 requires=['normal status0','unchanged complete stdout','exactly one P126_RESHAPE_COUNTS stderr record','matching parentSourceSha256','overflowOrInvalid0','attempts=successes+all refusal classes','reused_shells=2*successes','paired parent/candidate workload identity'],
 interpretation='Each success substitutes two consuming takes plus three constructor calls with reuse of two shells plus one constructor call. Confirm actual constructor_cells and ctr_take_calls delta against identically linked parent; heap_alloc_calls also includes wrapping and other runtime allocations.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(dict(out=str(out),patches=len(patches),inverseVerified=True,counterBytes=8*(1+len(COUNTERS)+3*65536))))
