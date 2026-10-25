# Exact static-preparation PREFIX checkpoints. Never rebase static addresses.
# First differing input disables all subsequent reuse for this request.
type P140SPEntry is Data:
  P140SPEntry{+name: String, +active: Bool, +fact: KDef, +state: P112SDefs}

type P140SPCache is Data:
  P140SPCache{+constructors: List<&2,N_Constructor>, +blocked: KDef, +entries: List<&2,P140SPEntry>}

type P140SPWalk is Data:
  P140SPWalk{+state: P112SDefs, +entries: List<&2,P140SPEntry>, +stats: List<&2,U32>}

type P140SPResult is Data:
  P140SPResult{+prepared: P112SPrepared, +cache: P140SPCache, +stats: List<&2,U32>}

def p140sp_empty() -> P140SPCache:
  P140SPCache{[],missing(),[]}

@unsafe
def p140sp_active(+d: KDef) -> Bool:
  String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d))

@unsafe
def p140sp_direct(+fact: KDef) -> Bool:
  String.eq(dk(fact),"NativeErasedBody") || String.eq(dk(fact),"NativeStaticBody")

@unsafe
def p140sp_hit(name: String, +active: Bool, +fact: KDef, prior: P140SPEntry) -> Bool:
  match prior:
    case P140SPEntry{old,was,before,state}:
      String.eq(name,old) && p134v_bool(active,was) &&
        nt_choose(Bool,active,u => p140sp_direct(fact) && p140eq_def(before,fact),u => True{})

@unsafe
def p140sp_prepare(+book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>, +previous: P140SPCache) -> P140SPResult:
  nt_choose(P140SPResult,nc_pack_foreign(book),u => P140SPResult{P112SPrepared{book,[],""},previous,[]},u =>
    nt_choose(P140SPResult,String.eq(dk(index_first(book)),"BookCache"),
      u => p140sp_context(book,names,constructors,previous,
        p112s_block_effects(ns_ctor_index(constructors,missing()),p111_effects(book,names))),
      u => P140SPResult{P112SPrepared{book,[],"static preparation requires a fresh cached request"},previous,[]}))

@unsafe
def p140sp_context(+book: List<&2,KDef>, names: List<&2,String>, +constructors: List<&2,N_Constructor>, +previous: P140SPCache, +blocked: KDef) -> P140SPResult:
  match previous:
    case P140SPCache{old,old_blocked,entries}:
      p140sp_finish(book,constructors,blocked,previous,
        p140sp_walk(book,blocked,names,entries,p134v_list(N_Constructor,p140v_ctor,old,constructors) && p140eq_def(old_blocked,blocked),
          P112SDefs{[],P112SImage{0,[],missing(),""}},[],0,0,0,0))

@unsafe
def p140sp_finish(+book: List<&2,KDef>, +constructors: List<&2,N_Constructor>, blocked: KDef, previous: P140SPCache, built: P140SPWalk) -> P140SPResult:
  match built:
    case P140SPWalk{state,entries,stats}:
      p140sp_publish(constructors,blocked,entries,previous,stats,p112s_attach(book,constructors,state))

@unsafe
def p140sp_publish(constructors: List<&2,N_Constructor>, blocked: KDef, entries: List<&2,P140SPEntry>, previous: P140SPCache,
    stats: List<&2,U32>, +prepared: P112SPrepared) -> P140SPResult:
  match prepared:
    case P112SPrepared{book,nodes,+error}:
      P140SPResult{prepared,nt_choose(P140SPCache,String.is_empty(error),
        u => P140SPCache{constructors,blocked,entries},u => previous),stats}

@unsafe
def p140sp_walk(+book: List<&2,KDef>, +blocked: KDef, names: List<&2,String>, +prior: List<&2,P140SPEntry>, +allowed: Bool,
    +state: P112SDefs, +entries: List<&2,P140SPEntry>, +hits: U32, +steps: U32, +body_hits: U32, +body_steps: U32) -> P140SPWalk:
  match names:
    case Nil{}: P140SPWalk{state,nt_reverse(P140SPEntry,entries,[]),[hits,steps,body_hits,body_steps]}
    case Con{+name,rest}:
      +definition = lookup(book,name)
      p140sp_choose(book,blocked,name,rest,prior,allowed,state,entries,hits,steps,body_hits,body_steps,
        definition,p140sp_active(definition),ns_body(book,name))

@unsafe
def p140sp_choose(+book: List<&2,KDef>, +blocked: KDef, +name: String, +names: List<&2,String>, prior: List<&2,P140SPEntry>, allowed: Bool,
    +state: P112SDefs, +entries: List<&2,P140SPEntry>, +hits: U32, +steps: U32, +body_hits: U32, +body_steps: U32,
    +definition: KDef, +active: Bool, +fact: KDef) -> P140SPWalk:
  match prior:
    case Nil{}:
      p140sp_fresh(book,blocked,name,names,[],state,entries,hits,steps,body_hits,body_steps,definition,active,fact)
    case Con{+entry,+rest}:
      nt_choose(P140SPWalk,allowed && p140sp_hit(name,active,fact,entry),
        u => p140sp_reused(book,blocked,names,rest,entries,hits,steps,body_hits,body_steps,entry),
        u => p140sp_fresh(book,blocked,name,names,rest,state,entries,hits,steps,body_hits,body_steps,definition,active,fact))

@unsafe
def p140sp_reused(book: List<&2,KDef>, blocked: KDef, names: List<&2,String>, prior: List<&2,P140SPEntry>, entries: List<&2,P140SPEntry>,
    hits: U32, steps: U32, body_hits: U32, body_steps: U32, +entry: P140SPEntry) -> P140SPWalk:
  match entry:
    case P140SPEntry{name,active,fact,state}:
      p140sp_walk(book,blocked,names,prior,True{},state,Con{entry,entries},U32.inc(hits),steps,U32.add(body_hits,Bool.to_u32(active)),body_steps)

@unsafe
def p140sp_fresh(+book: List<&2,KDef>, +blocked: KDef, +name: String, +names: List<&2,String>, +prior: List<&2,P140SPEntry>,
    +state: P112SDefs, +entries: List<&2,P140SPEntry>, +hits: U32, +steps: U32, +body_hits: U32, +body_steps: U32,
    +definition: KDef, +active: Bool, +fact: KDef) -> P140SPWalk:
  p140sp_next(book,blocked,name,names,prior,entries,hits,U32.inc(steps),body_hits,U32.add(body_steps,Bool.to_u32(active)),active,fact,
    nt_choose(P112SDefs,active,u => p140sp_transform(name,fact,state,p112s_term(blocked,nc_compact(nc_definition(book,definition,0)),p140sp_image(state))),u => state))

def p140sp_image(state: P112SDefs) -> P112SImage:
  match state:
    case P112SDefs{facts,image}: image

@unsafe
def p140sp_transform(name: String, +prior: KDef, before: P112SDefs, transformed: P112STerm) -> P112SDefs:
  match before transformed:
    case P112SDefs{facts,old_image} P112STerm{body,image}:
      P112SDefs{Con{KDef{name,"NativeStaticBody",da(prior),dx(prior),atom("Absent"),body,[prior],False{},False{}},facts},image}

@unsafe
def p140sp_next(book: List<&2,KDef>, blocked: KDef, +name: String, names: List<&2,String>, prior: List<&2,P140SPEntry>, entries: List<&2,P140SPEntry>,
    hits: U32, steps: U32, body_hits: U32, body_steps: U32, +active: Bool, +fact: KDef, +state: P112SDefs) -> P140SPWalk:
  p140sp_walk(book,blocked,names,prior,False{},state,Con{P140SPEntry{name,active,fact,state},entries},hits,steps,body_hits,body_steps)
