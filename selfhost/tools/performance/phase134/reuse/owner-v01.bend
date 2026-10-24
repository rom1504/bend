# Experimental two-revision generic-owner lowering memo. No overrides.
# This fixed producer admits only a book-independent lowered-body grammar.
# Contextual entry decisions remain explicit result-valued key fields.
# Unknown bodies run the original lowering. Fresh counters must match exactly.

type P134URKey is Data:
  P134URKey{+owner: String, +body: KTerm, +fresh: U32, +bang: Bool, +arity: U32, +typed: U32, +native: Bool, +foreign: Bool, +mapped: String, +kinds: List<&2,N_WordKind>}

type P134URSlot is Data:
  P134UREmpty{}
  P134URCached{+key: P134URKey, +code: P111Code}

type P134URStats is Data:
  P134URStats{+hits: U32, +lowered: U32, +refused: U32, +freshMiss: U32, +keyMiss: U32}

type P134URResult is Data:
  P134URResult{+book: P111Book, +slots: List<&2,P134URSlot>, +stats: P134URStats}

type P134URPair is Data:
  P134URPair{+initial: P134URResult, +updated: P134URResult}

@unsafe
def p134ur_bool_eq(a: Bool, b: Bool) -> Bool:
  match a b:
    case True{} True{}: True{}
    case False{} False{}: True{}
    case _: False{}

@unsafe
def p134ur_strings_eq(a: List<&2,String>, b: List<&2,String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{+x,+xs} Con{+y,+ys}:
      nt_choose(Bool,String.eq(x,y),u => p134ur_strings_eq(xs,ys),u => False{})
    case _: False{}

@unsafe
def p134ur_terms_eq(a: List<&2,KTerm>, b: List<&2,KTerm>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{+x,+xs} Con{+y,+ys}:
      nt_choose(Bool,p134ur_term_eq(x,y),u => p134ur_terms_eq(xs,ys),u => False{})
    case _: False{}

@unsafe
def p134ur_term_eq(a: KTerm, b: KTerm) -> Bool:
  match a b:
    case KTerm{+at,+an,+ai,+aq,+ak,+ar,+ab,+ae} KTerm{+bt,+bn,+bi,+bq,+bk,+br,+bb,+be}:
      nt_choose(Bool,String.eq(at,bt) && String.eq(an,bn) && U32.is_eq(ai,bi) && U32.is_eq(aq,bq) && U32.is_eq(ab,bb) && U32.is_eq(ae,be),
        u => p134ur_strings_eq(ar,br) && p134ur_terms_eq(ak,bk),u => False{})
    case KLambda{+an,+ai,+aq,+ak,+ar,+ab,+ae,+ap} KLambda{+bn,+bi,+bq,+bk,+br,+bb,+be,+bp}:
      nt_choose(Bool,String.eq(an,bn) && U32.is_eq(ai,bi) && U32.is_eq(aq,bq) && U32.is_eq(ab,bb) && U32.is_eq(ae,be) && p134ur_bool_eq(ap,bp),
        u => p134ur_strings_eq(ar,br) && p134ur_terms_eq(ak,bk),u => False{})
    case KLiteral{ak,an,at,ab,ae} KLiteral{bk,bn,bt,bb,be}:
      String.eq(ak,bk) && U32.is_eq(an,bn) && String.eq(at,bt) && U32.is_eq(ab,bb) && U32.is_eq(ae,be)
    case _: False{}

@unsafe
def p134ur_kind_eq(a: N_WordKind, b: N_WordKind) -> Bool:
  match a b:
    case N_W32{} N_W32{}: True{}
    case N_W64{} N_W64{}: True{}
    case N_Box{} N_Box{}: True{}
    case N_Imm64{} N_Imm64{}: True{}
    case _: False{}

@unsafe
def p134ur_kinds_eq(a: List<&2,N_WordKind>, b: List<&2,N_WordKind>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{+x,+xs} Con{+y,+ys}:
      nt_choose(Bool,p134ur_kind_eq(x,y),u => p134ur_kinds_eq(xs,ys),u => False{})
    case _: False{}

# Ref, Mat/NMatch, constructors and NStatic are deliberately refused: their
# current lowering can inspect native provenance, layouts or private workers.
# NCall already carries its explicit callee identity; no callee analysis is
# performed for that node. App can only contain admitted non-Ref heads.
@unsafe
def p134ur_closed(todo: List<&2,KTerm>) -> Bool:
  match todo:
    case Nil{}: True{}
    case Con{+head,+rest}:
      nt_choose(Bool,nb_contains(["NWord","Var","Lam","App","Let","NSeqLet","NOp","NApply","NCall","Ann","Loc","Src","Cut","Slf","Ins","Rfl","Typ","All","Qua","ADT","Eql","Efq","Rwt","NNatAdd","NNatSum"],tg(head)),
        u => p134ur_closed(nt_append(KTerm,ks(head),rest)),u => False{})

@unsafe
def p134ur_key(+book: List<&2,KDef>, +name: String, +body: KTerm, +n: U32, +bang: Bool) -> P134URKey:
  +d = lookup(book,name)
  +arity = nd_arity(book,name)
  P134URKey{name,body,n,bang,arity,jd_live_arity(book,dt(d),jd_arity(book,d)),
    nc_native_def(d),nc_foreign(d),nc_ref_name(book,name),nf_worker_kinds(book,name,arity)}

@unsafe
def p134ur_key_eq(a: P134URKey, b: P134URKey) -> Bool:
  match a b:
    case P134URKey{+an,+ab,+af,+ag,+aa,+at,+ap,+ax,+am,+ak} P134URKey{+bn,+bb,+bf,+bg,+ba,+bt,+bp,+bx,+bm,+bk}:
      nt_choose(Bool,String.eq(an,bn) && U32.is_eq(af,bf) && p134ur_bool_eq(ag,bg) && U32.is_eq(aa,ba) && U32.is_eq(at,bt) && p134ur_bool_eq(ap,bp) && p134ur_bool_eq(ax,bx) && String.eq(am,bm),
        u => p134ur_kinds_eq(ak,bk) && p134ur_term_eq(ab,bb),u => False{})

@unsafe
def p134ur_fresh(key: P134URKey) -> U32:
  match key:
    case P134URKey{name,body,fresh,bang,arity,typed,native,foreign,mapped,kinds}: fresh

@unsafe
def p134ur_step_stats(stats: P134URStats, +hit: Bool, +refused: Bool, +fresh: Bool, +key: Bool) -> P134URStats:
  match stats:
    case P134URStats{hits,lowered,refusals,freshMiss,keyMiss}:
      P134URStats{U32.add(hits,nt_bool(hit)),U32.add(lowered,nt_bool(Bool.not(hit))),U32.add(refusals,nt_bool(refused)),U32.add(freshMiss,nt_bool(fresh)),U32.add(keyMiss,nt_bool(key))}

# Cache order mirrors the requested owner order. Changed order safely misses;
# there is no quadratic per-owner scan or full-book equality test.
@unsafe
def p134ur_slot(prior: List<&2,P134URSlot>) -> P134URSlot:
  match prior:
    case Nil{}: P134UREmpty{}
    case Con{head,rest}: head

@unsafe
def p134ur_tail(prior: List<&2,P134URSlot>) -> List<&2,P134URSlot>:
  match prior:
    case Nil{}: []
    case Con{head,rest}: rest

@unsafe
def p134ur_continue(+book: List<&2,KDef>, +name: String, +names: List<&2,String>, +bangs: List<&2,String>, +prior: List<&2,P134URSlot>, +slots: List<&2,P134URSlot>, +acc: List<&2,N111Segment>, +stats: P134URStats, code: P111Code) -> P134URResult:
  match code:
    case P111Code{+body,+segments,+fresh,+error}:
      nt_choose(P134URResult,String.is_empty(error),u =>
        p134ur_loop(book,names,bangs,fresh,prior,slots,
          nt_reverse(N111Segment,p111_mark_segments(Con{p111_segment(nc_ref_name(book,name),[],0,0,body),segments},nb_contains(bangs,name)),acc),stats),
        u => P134URResult{P111Book{[],fresh,error},nt_reverse(P134URSlot,slots,[]),stats})

@unsafe
def p134ur_miss(+book: List<&2,KDef>, +name: String, +names: List<&2,String>, +bangs: List<&2,String>, +n: U32, +prior: List<&2,P134URSlot>, +slots: List<&2,P134URSlot>, +acc: List<&2,N111Segment>, +stats: P134URStats, +key: P134URKey, +body: KTerm) -> P134URResult:
  +code = p111_entry(book,body,name,U32.add(n,1024),nb_contains(bangs,name))
  p134ur_continue(book,name,names,bangs,prior,Con{P134URCached{key,code},slots},acc,stats,code)

@unsafe
def p134ur_choose(+book: List<&2,KDef>, +name: String, +names: List<&2,String>, +bangs: List<&2,String>, +n: U32, +prior: List<&2,P134URSlot>, +slots: List<&2,P134URSlot>, +acc: List<&2,N111Segment>, +stats: P134URStats, +key: P134URKey, +body: KTerm, old: P134URSlot) -> P134URResult:
  match old:
    case P134UREmpty{}:
      p134ur_miss(book,name,names,bangs,n,prior,slots,acc,p134ur_step_stats(stats,False{},False{},False{},False{}),key,body)
    case P134URCached{+oldKey,+code}:
      nt_choose(P134URResult,p134ur_key_eq(key,oldKey),
        u => p134ur_continue(book,name,names,bangs,prior,Con{P134URCached{key,code},slots},acc,p134ur_step_stats(stats,True{},False{},False{},False{}),code),
        u => p134ur_miss(book,name,names,bangs,n,prior,slots,acc,
          p134ur_step_stats(stats,False{},False{},Bool.not(U32.is_eq(n,p134ur_fresh(oldKey))),U32.is_eq(n,p134ur_fresh(oldKey))),key,body))

@unsafe
def p134ur_owner(+book: List<&2,KDef>, +name: String, +names: List<&2,String>, +bangs: List<&2,String>, +n: U32, +prior: List<&2,P134URSlot>, +slots: List<&2,P134URSlot>, +acc: List<&2,N111Segment>, +stats: P134URStats, +body: KTerm) -> P134URResult:
  nt_choose(P134URResult,p134ur_closed([body]),
    u => p134ur_choose(book,name,names,bangs,n,p134ur_tail(prior),slots,acc,stats,
      p134ur_key(book,name,body,n,nb_contains(bangs,name)),body,p134ur_slot(prior)),
    u => p134ur_continue(book,name,names,bangs,p134ur_tail(prior),Con{P134UREmpty{},slots},acc,
      p134ur_step_stats(stats,False{},True{},False{},False{}),p111_entry(book,body,name,U32.add(n,1024),nb_contains(bangs,name))))

@unsafe
def p134ur_loop(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +n: U32, +prior: List<&2,P134URSlot>, +slots: List<&2,P134URSlot>, +acc: List<&2,N111Segment>, +stats: P134URStats) -> P134URResult:
  match names:
    case Nil{}: P134URResult{P111Book{nt_reverse(N111Segment,acc,[]),n,""},nt_reverse(P134URSlot,slots,[]),stats}
    case Con{+name,+rest}:
      +d = lookup(book,name)
      nt_choose(P134URResult,String.eq(dk(d),"Absent"),
        u => P134URResult{P111Book{[],n,"native definition not found: " ++ name_key(name)},nt_reverse(P134URSlot,slots,[]),stats},
        u => p134ur_owner(book,name,rest,bangs,n,prior,slots,acc,stats,nc_compact_definition(book,d,n)))

@unsafe
def p134ur_run(+book: List<&2,KDef>, +names: List<&2,String>, +bangs: List<&2,String>, +n: U32, prior: List<&2,P134URSlot>) -> P134URResult:
  p134ur_loop(book,names,bangs,n,prior,[],[],P134URStats{0,0,0,0,0})

@unsafe
def p134ur_slots(result: P134URResult) -> List<&2,P134URSlot>:
  match result:
    case P134URResult{book,slots,stats}: slots

@unsafe
def p134ur_book(result: P134URResult) -> P111Book:
  match result:
    case P134URResult{book,slots,stats}: book

@unsafe
def p134ur_batch(+a: List<&2,KDef>, +an: List<&2,String>, +b: List<&2,KDef>, +bn: List<&2,String>) -> P134URPair:
  +first = p134ur_run(a,an,nc_bangs_names(a,an),0,[])
  P134URPair{first,p134ur_run(b,bn,nc_bangs_names(b,bn),0,p134ur_slots(first))}

# Eligibility inventory performs no native lowering. It is intentionally only
# a ceiling: actual hits additionally require matching entry facts and fresh.
@unsafe
def p134ur_inventory(+book: List<&2,KDef>, names: List<&2,String>, +eligible: U32, +refused: U32) -> List<&2,U32>:
  match names:
    case Nil{}: [eligible,refused]
    case Con{+name,+rest}:
      +admitted = p134ur_closed([nc_compact_definition(book,lookup(book,name),0)])
      p134ur_inventory(book,rest,U32.add(eligible,nt_bool(admitted)),U32.add(refused,nt_bool(Bool.not(admitted))))
