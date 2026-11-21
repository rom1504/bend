"""Generate a bounded, source-auditable runtime ablation from the live-descriptor runtime."""
from pathlib import Path
import runpy

HERE=Path(__file__).resolve().parent
def replace(text,a,b):
    assert text.count(a)==1,a
    return text.replace(a,b)
def source(original, mode):
    cached=runpy.run_path(str(HERE.parent/'runtime/bind-facts.py'))['variant'](original,'split')
    live=runpy.run_path(str(HERE.parent/'runtime-broad/live.py'))['variant'](original,cached)
    if mode=='live':
        return live
    # Both the original Phase144 contract and this specialization are host-only
    # single-mutator. The old atomics and last-owner paths still handle other modes.
    begin=live.index('OUTLINE void span_fade')
    prefix,rest=live[:begin],live[begin:]
    replacement="""
#if P144_SINGLE_MUTATOR_RFC
// At this point all result fields were retained exactly as in the generic
// take. The caller may overlap out with the input. Inspect the parent *now*
// after these stores and increments. Count==1, malformed/non-heap references
// and any unexpected count fall back to the exact general destructor.
  if (term_rfc(t) && !term_triv(t)) {
    u32 *p = a32_at(e.mem,term_loc(t));
    u32 count;
    memcpy(&count,p,sizeof count);
    if ((count & RFC_CNT) > 1) {
      p144_rfc_sub(p,1);
      return;
    }
  }
#endif
  term_drop(e,t);
}
"""
    shared=replace(rest,'  term_drop(e, t);\n}\n\nINLINE Loc ctr_take',replacement+'\nINLINE Loc ctr_take')
    if mode=='release':
        return prefix+shared
    if mode=='specialize':
        return prefix+replace(shared,'OUTLINE void span_fade','INLINE void span_fade')
    raise ValueError(mode)
