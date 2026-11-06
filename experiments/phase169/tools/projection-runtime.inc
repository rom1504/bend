/* Private saved-IR ceiling ABI. count/index/mask/kind are frozen literals from
 * the complete terminal-block matcher, not a public compiler intrinsic. */
#ifndef P169_PROJECT_FAST
#define P169_PROJECT_FAST 0
#endif

static Term p169_project_previous(P111State *s, Term t, u32 n, u32 index,
                                  u32 mask, u32 kind) {
  Term fields[32];
  switch (kind) {
    case 1: p125_rt_take1(s,t,fields); break;
    case 2: p125_rt_take2(s,t,fields); break;
    case 3: p125_rt_take3(s,t,fields); break;
    case 4: p125_rt_take4(s,t,fields); break;
    default: p111_rt_take(s,t,fields,n); break;
  }
  for (u32 j=0;j<n;++j) if (mask & (1u<<j)) p111_rt_sink(s,fields[j]);
  return fields[index];
}

uint64_t p169_rt_project(P111State *s, Term t, u32 n, u32 index,
                         u32 mask, u32 kind) {
  p111_require(n>=1 && n<=32 && index<n && !(mask & (1u<<index)) &&
    (kind==0 || (kind<=4 && kind==n)), "phase169: private projection literals");
#if P169_PROJECT_FAST && P144_SINGLE_MUTATOR_RFC && !DEVICE
  u32 cid=(u32)term_aux(t);
  if (cid < p111_program_active->constructor_count && cid_arity(cid)==n &&
      term_tag(t)==TAG_CTR && term_rfc(t) && !term_triv(t)) {
    Env e=s->e;
    u64 cell=rfc_view(e,term_loc(t));
    if ((cell & RFC_CNT)>1 && (cell>>24)>=HEAP_OFF) {
      Loc at=cell>>24;
      bool safe=true;
      for (u32 j=0;j<n;++j) {
        Term f=e.mem[at+j];
        if (term_rfc(f)) {
          if (term_triv(f) || (j!=index && !(mask & (1u<<j)))) {safe=false;break;}
          u32 count=(u32)(rfc_view(e,term_loc(f)) & RFC_CNT);
          if (!count || count>RFC_CNT-n-1) {safe=false;break;}
        } else if (!term_triv(f)) {safe=false;break;}
      }
      if (safe) {
        Term result=term_keep(e,e.mem[at+index]);
        term_drop(e,t);
        return result;
      }
    }
  }
#endif
  return p169_project_previous(s,t,n,index,mask,kind);
}
