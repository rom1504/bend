# Process-local exact rendering reuse. The Bend cache retains typed inputs,
# never whole QBE text. Reuse ordinals refer only to the preceding successful
# output stream owned by the caller; transport must authenticate its bytes.
type P140RFact is Data:
  P140RFact{+name: String, +value: Maybe<&2,N111Segment>}

type P140RFacts is Data:
  P140RFacts{+valid: Bool, +facts: List<&2,P140RFact>}

type P140RKey is Data:
  P140RNone{}
  P140RPublic{+segment: N111Segment, +facts: List<&2,P140RFact>}
  P140RPrivate{+function: P113DFunction}
  P140RLegacy{+entry: P112RegionEntry}
  P140RHeader{+name: String, +alignment: U32, +exported: Bool}
  P140RData{+items: List<&2,P111QDatum>, +first: Bool}
  P140RClose{}
  P140RMain{}

type P140RSlot is Data:
  P140RSlot{+key: P140RKey, +ordinal: U32}

type P140RCache is Data:
  P140REmpty{}
  P140RCache{+context: P134Context, +slots: List<&2,P140RSlot>}

type P140RState is Data:
  P140RState{+cursor: P134Cursor, +context: P134Context, +valid: Bool,
    +prior: List<&2,P140RSlot>, +slots: List<&2,P140RSlot>,
    +ordinal: U32, +hits: U32, +misses: U32}

type P140RStep is Data:
  P140REnd{+cache: P140RCache, +hits: U32, +misses: U32}
  P140RText{+text: String, +ending: Bool, +next: P140RState}
  P140RReuse{+ordinal: U32, +next: P140RState}

@unsafe
def p140r_def(a: KDef, b: KDef) -> Bool:
  p140r_defs([a],[b])

def p140r_variant(d: KDef) -> U32:
  match d:
    case KDef{name,kind,arity,templates,typ,value,children,native,unsafe}: 0
    case KIndexLeaf{hash,bucket}: 1
    case KIndexNode{hash,mask,left,right}: 2

@unsafe
def p140r_defs(left: List<&2,KDef>, right: List<&2,KDef>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{+a,ar} Con{+b,br}:
      nt_choose(Bool,U32.is_eq(p140r_variant(a),p140r_variant(b)) && f_fresh_prefix_exact_head(a,b),
        u => p140r_defs(norm_defs_join(dc(a),ar),norm_defs_join(dc(b),br)),u => False{})
    case _ _: False{}

@unsafe
def p140r_ids(a: N111Ids, b: N111Ids) -> Bool:
  match a b:
    case N111Ids{af,ac} N111Ids{bf,bc}: p140r_def(af,bf) && p140r_def(ac,bc)

def p140r_table(a: P126ITable, b: P126ITable) -> Bool:
  match a b:
    case P126ITable{an,al} P126ITable{bn,bl}: String.eq(an,bn) && U32.is_eq(al,bl)

# The index is validated per public unit through the complete frame closure.
# Everything else is conservatively compared once for the entire request.
@unsafe
def p140r_context(a: P134Context, b: P134Context) -> Bool:
  match a b:
    case P134Context{ai,ax,ad,ar,av,at,ah,am} P134Context{bi,bx,bd,br,bv,bt,bh,bm}:
      U32.is_eq(am,bm) && U32.is_eq(ah,bh) && p140r_ids(ai,bi) &&
        p140r_def(ad,bd) && p140r_def(ar,br) && p140r_def(av,bv) &&
        p134v_list(P126ITable,p140r_table,at,bt)

@unsafe
def p140r_segment(a: N111Segment, b: N111Segment) -> Bool:
  match a b:
    case N111Segment{an,aa,ar,ai,af,ab} N111Segment{bn,ba,br,bi,bf,bb}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && U32.is_eq(ar,br) &&
        U32.is_eq(ai,bi) && U32.is_eq(af,bf) && p134v_list(N111Stmt,p134v_scalar,ab,bb)

@unsafe
def p140r_maybe(a: Maybe<&2,N111Segment>, b: Maybe<&2,N111Segment>) -> Bool:
  match a b:
    case None{} None{}: True{}
    case Some{x} Some{y}: p140r_segment(x,y)
    case _ _: False{}

@unsafe
def p140r_frame(args: List<&2,N111Arg>, acc: List<&2,String>) -> List<&2,String>:
  match args:
    case Con{state,Con{N111Arg{typ,N111FuncId{name}},rest}}: Con{name,acc}
    case _: acc

@unsafe
def p140r_frames(body: List<&2,N111Stmt>, +acc: List<&2,String>) -> List<&2,String>:
  match body:
    case Nil{}: acc
    case Con{N111If{condition,yes,no},rest}:
      p140r_frames(yes,p140r_frames(no,p140r_frames(rest,acc)))
    case Con{N111Call{name,typ,symbol,args},rest}:
      p140r_frames(rest,nt_choose(List<&2,String>,String.eq(symbol,"p111_rt_frame"),
        u => p140r_frame(args,acc),u => acc))
    case Con{stmt,rest}: p140r_frames(rest,acc)

@unsafe
def p140r_segment_frames(segment: N111Segment, acc: List<&2,String>) -> List<&2,String>:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}: p140r_frames(body,acc)

@unsafe
def p140r_close(todo: List<&2,String>, +index: P112FusionIndex, +seen: List<&2,String>, +facts: List<&2,P140RFact>, +left: U32) -> P140RFacts:
  match todo:
    case Nil{}: P140RFacts{True{},facts}
    case Con{+name,+rest}:
      nt_choose(P140RFacts,nb_contains(seen,name),u => p140r_close(rest,index,seen,facts,left),
        u => nt_choose(P140RFacts,U32.is_eq(left,0),v => P140RFacts{False{},[]},
          v => p140r_close_found(name,rest,index,Con{name,seen},facts,U32.sub(left,1),p112f_index_get(index,name))))

@unsafe
def p140r_close_found(+name: String, rest: List<&2,String>, index: P112FusionIndex, seen: List<&2,String>, facts: List<&2,P140RFact>, left: U32, +found: Maybe<&2,N111Segment>) -> P140RFacts:
  match found:
    case None{}: p140r_close(rest,index,seen,Con{P140RFact{name,found},facts},left)
    case Some{segment}: p140r_close(p140r_segment_frames(segment,rest),index,seen,Con{P140RFact{name,found},facts},left)

@unsafe
def p140r_facts_valid(facts: List<&2,P140RFact>, +index: P112FusionIndex) -> Bool:
  match facts:
    case Nil{}: True{}
    case Con{P140RFact{+name,value},rest}:
      nt_choose(Bool,p140r_maybe(value,p112f_index_get(index,name)),u => p140r_facts_valid(rest,index),u => False{})

@unsafe
def p140r_public_key(segment: N111Segment, facts: P140RFacts) -> P140RKey:
  match facts:
    case P140RFacts{valid,items}: nt_choose(P140RKey,valid,u => P140RPublic{segment,items},u => P140RNone{})

@unsafe
def p140r_worker(a: P112WorkerStmt, b: P112WorkerStmt) -> Bool:
  match a b:
    case P112WorkerScalar{x} P112WorkerScalar{y}: p134v_scalar(x,y)
    case P112WorkerIf{ac,ay,an} P112WorkerIf{bc,by,bn}:
      p134v_value(ac,bc) && p134v_list(P112WorkerStmt,p140r_worker,ay,by) && p134v_list(P112WorkerStmt,p140r_worker,an,bn)
    case P112WorkerAgain{} P112WorkerAgain{}: True{}
    case P112WorkerResult{} P112WorkerResult{}: True{}
    case P112WorkerCall{an,aa} P112WorkerCall{bn,ba}: String.eq(an,bn) && U32.is_eq(aa,ba)
    case _ _: False{}

@unsafe
def p140r_legacy(a: P112RegionEntry, b: P112RegionEntry) -> Bool:
  match a b:
    case P112RegionEntry{as,P112WorkerPlan{av,ac,ap,ab},ar,an} P112RegionEntry{bs,P112WorkerPlan{bv,bc,bp,bb},br,bn}:
      p140r_segment(as,bs) && p134v_bool(av,bv) && U32.is_eq(ac,bc) &&
        p134v_list(String,String.eq,ap,bp) && p134v_list(P112WorkerStmt,p140r_worker,ab,bb) &&
        U32.is_eq(ar,br) && U32.is_eq(an,bn)

def p140r_datum(a: P111QDatum, b: P111QDatum) -> Bool:
  match a b:
    case P111QByte{x} P111QByte{y}: U32.is_eq(x,y)
    case P111QWord{x} P111QWord{y}: U32.is_eq(x,y)
    case P111QLong{al,ah} P111QLong{bl,bh}: U32.is_eq(al,bl) && U32.is_eq(ah,bh)
    case P111QReloc{an,ao} P111QReloc{bn,bo}: String.eq(an,bn) && U32.is_eq(ao,bo)
    case P111QZeros{x} P111QZeros{y}: U32.is_eq(x,y)
    case _ _: False{}

@unsafe
def p140r_take(items: List<&2,P111QDatum>, +left: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{head,rest}:
      nt_choose(List<&2,P111QDatum>,U32.is_eq(left,0),u => [],u => Con{head,p140r_take(rest,U32.sub(left,1))})

@unsafe
def p140r_drop(+items: List<&2,P111QDatum>, +left: U32) -> List<&2,P111QDatum>:
  nt_choose(List<&2,P111QDatum>,U32.is_eq(left,0),u => items,u => p140r_drop_next(items,left))

@unsafe
def p140r_drop_next(items: List<&2,P111QDatum>, left: U32) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: []
    case Con{head,rest}: p140r_drop(rest,U32.sub(left,1))

@unsafe
def p140r_key(cursor: P134Cursor) -> P140RKey:
  match cursor:
    case P134Private{Con{head,rest},context,next}: P140RPrivate{head}
    case P134Public{Con{+head,rest},P134Context{ids,index,direct,ready,view,lookups,heap,mode},next}:
      p140r_public_key(head,p140r_close(p140r_segment_frames(head,[]),index,[],[],64))
    case P134Legacy{Con{head,rest},context,next}: P140RLegacy{head}
    case P134Tables{Con{P111QData{name,alignment,exported,items},rest}}: P140RHeader{name,alignment,exported}
    case P134Data{Nil{},first,rest}: P140RClose{}
    case P134Data{items,first,rest}: P140RData{p140r_take(items,128),first}
    case P134Main{}: P140RMain{}
    case _: P140RNone{}

@unsafe
def p140r_hit(cursor: P134Cursor, key: P140RKey) -> Bool:
  match cursor key:
    case P134Private{Con{head,rest},context,next} P140RPrivate{old}: p134v_function(head,old)
    case P134Public{Con{head,rest},P134Context{ids,index,direct,ready,view,lookups,heap,mode},next} P140RPublic{old,facts}:
      nt_choose(Bool,p140r_segment(head,old),u => p140r_facts_valid(facts,index),u => False{})
    case P134Legacy{Con{head,rest},context,next} P140RLegacy{old}: p140r_legacy(head,old)
    case P134Tables{Con{P111QData{name,alignment,exported,items},rest}} P140RHeader{on,oa,oe}:
      String.eq(name,on) && U32.is_eq(alignment,oa) && p134v_bool(exported,oe)
    case P134Data{Nil{},first,rest} P140RClose{}: True{}
    case P134Data{items,first,rest} P140RData{old,of}:
      p134v_bool(first,of) && p134v_list(P111QDatum,p140r_datum,p140r_take(items,128),old)
    case P134Main{} P140RMain{}: True{}
    case _ _: False{}

@unsafe
def p140r_begin(plan: P134EmissionPlan, cache: P140RCache) -> P140RState:
  p140r_begin_cursor(p134e_begin(plan),cache)

@unsafe
def p140r_begin_cursor(+cursor: P134Cursor, cache: P140RCache) -> P140RState:
  match cursor:
    case P134Private{functions,+context,next}: p140r_begin_context(cursor,context,cache)
    case _: P140RState{cursor,P134Context{N111Ids{missing(),missing()},P112FusionEmpty{},missing(),missing(),missing(),[],0,0},False{},[],[],0,0,0}

@unsafe
def p140r_begin_context(cursor: P134Cursor, +context: P134Context, cache: P140RCache) -> P140RState:
  match cache:
    case P140REmpty{}: P140RState{cursor,context,False{},[],[],0,0,0}
    case P140RCache{old,slots}: P140RState{cursor,context,p140r_context(context,old),slots,[],0,0,0}

@unsafe
def p140r_next(state: P140RState) -> P140RStep:
  match state:
    case P140RState{P134Private{Nil{},ctx,next},context,valid,prior,slots,ordinal,hits,misses}:
      p140r_next(P140RState{next,context,valid,prior,slots,ordinal,hits,misses})
    case P140RState{P134Legacy{Nil{},ctx,next},context,valid,prior,slots,ordinal,hits,misses}:
      p140r_next(P140RState{next,context,valid,prior,slots,ordinal,hits,misses})
    case P140RState{P134Public{Nil{},ctx,next},context,valid,prior,slots,ordinal,hits,misses}:
      p140r_next(P140RState{next,context,valid,prior,slots,ordinal,hits,misses})
    case P140RState{P134Tables{Nil{}},context,valid,prior,slots,ordinal,hits,misses}:
      p140r_next(P140RState{P134Main{},context,valid,prior,slots,ordinal,hits,misses})
    case P140RState{+cursor,+context,+valid,prior,+slots,+ordinal,+hits,+misses}:
      p140r_slot(cursor,context,valid,prior,slots,ordinal,hits,misses)

@unsafe
def p140r_slot(+cursor: P134Cursor, +context: P134Context, +valid: Bool, prior: List<&2,P140RSlot>, +slots: List<&2,P140RSlot>, +ordinal: U32, +hits: U32, +misses: U32) -> P140RStep:
  match prior:
    case Nil{}: p140r_fresh(cursor,context,valid,[],slots,ordinal,hits,misses)
    case Con{P140RSlot{+key,old},+rest}:
      nt_choose(P140RStep,valid && p140r_hit(cursor,key),
        u => P140RReuse{old,P140RState{p140r_skip(cursor),context,valid,rest,Con{P140RSlot{key,ordinal},slots},U32.inc(ordinal),U32.inc(hits),misses}},
        u => p140r_fresh(cursor,context,valid,rest,slots,ordinal,hits,misses))

@unsafe
def p140r_skip(cursor: P134Cursor) -> P134Cursor:
  match cursor:
    case P134Private{Con{head,rest},context,next}: P134Private{rest,context,next}
    case P134Public{Con{head,rest},context,next}: P134Public{rest,context,next}
    case P134Legacy{Con{head,rest},context,next}: P134Legacy{rest,context,next}
    case P134Tables{Con{P111QData{name,alignment,exported,items},rest}}: P134Data{items,True{},rest}
    case P134Data{Nil{},first,rest}: P134Tables{rest}
    case P134Data{items,first,rest}: P134Data{p140r_drop(items,128),False{},rest}
    case P134Main{}: P134End{}
    case _: cursor

@unsafe
def p140r_fresh(+cursor: P134Cursor, context: P134Context, valid: Bool, prior: List<&2,P140RSlot>, slots: List<&2,P140RSlot>, +ordinal: U32, hits: U32, misses: U32) -> P140RStep:
  p140r_fresh_step(p134e_next(cursor),p140r_key(cursor),context,valid,prior,slots,ordinal,hits,misses)

@unsafe
def p140r_fresh_step(step: P134Step, key: P140RKey, context: P134Context, valid: Bool, prior: List<&2,P140RSlot>, slots: List<&2,P140RSlot>, +ordinal: U32, hits: U32, misses: U32) -> P140RStep:
  match step:
    case P134Done{}: P140REnd{P140RCache{context,nt_reverse(P140RSlot,slots,[])},hits,misses}
    case P134Piece{text,ending,next}:
      P140RText{text,ending,P140RState{next,context,valid,prior,Con{P140RSlot{key,ordinal},slots},U32.inc(ordinal),hits,U32.inc(misses)}}
