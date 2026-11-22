#!/usr/bin/env python3
"""AGY-W2B-2: Multi-Pass Topological p114r Direct-Worker Promotion.

Extends p114h_plan / p124r_view so that recursive p114r_ workers (and small
non-recursive wrappers calling them) are discovered in topological passes
(up to 6 passes) and made directly callable by higher-level p114h_ workers
without p111_rt_keep / p111_rt_jump / p111_rt_return continuation overhead.
"""
import argparse
from pathlib import Path

DEFAULT_SRC = Path("/home/ai/bend2_agy/selfhost/build/agy/unified/compiler.bend")
DEFAULT_DST = Path("/home/ai/bend2_agy/selfhost/build/agy/wave2_bst/compiler.bend")

MP_HELPERS = r"""
# ============================================================================
# AGY-W2B-2: Multi-Pass Topological p114r Direct-Worker Promotion
# ============================================================================

@unsafe
def agy_p124r_hview(ready: KDef, direct: KDef, hready: KDef) -> KDef:
  KDef{"","P124Callables",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[ready,direct,hready],False{},False{}}

@unsafe
def agy_p124r_hready(+ready: KDef, +hready: KDef, +name: String) -> P124Callable:
  +entry = p111v_get(hready,name)
  +count = da(entry)
  nt_choose(P124Callable,String.eq(dk(entry),"AgyHReady") && U32.is_le(count,8),
    u => P124Callable{True{},count,p114r_symbol(name)},
    u => p124r_legacy(ready,name))

@unsafe
def agy_p124r_complete3(+ready: KDef, +hready: KDef, +name: String, +function: KDef) -> P124Callable:
  +count = da(function)
  nt_choose(P124Callable,String.eq(dk(function),"P113Direct") && U32.is_eq(dx(function),1) &&
    U32.is_eq(ix(dv(function)),1) && U32.is_le(count,8),
    u => P124Callable{True{},count,p113e_symbol(name)},
    u => agy_p124r_hready(ready,hready,name))

@unsafe
def agy_p124r_known_orig_children(children: List<&2,KDef>, +name: String) -> Bool:
  match children:
    case Con{ready,Con{direct,rest}}: p124r_valid(p124r_complete(ready,name,p111v_get(direct,name)))
    case _: False{}

@unsafe
def agy_p124r_known_orig(+ready: KDef, +name: String) -> Bool:
  nt_choose(Bool,p124r_is_view(ready),
    u => agy_p124r_known_orig_children(dc(ready),name),
    u => p112w_ready(ready,name))

@unsafe
def agy_p114r_nstmts_calls_h(stmts: List<&2,N111Stmt>) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{N111Call{n,t,sym,args},rest}:
      String.starts_with(sym,"p114r_") || agy_p114r_nstmts_calls_h(rest)
    case Con{N111If{c,yes,no},rest}:
      agy_p114r_nstmts_calls_h(yes) || agy_p114r_nstmts_calls_h(no) || agy_p114r_nstmts_calls_h(rest)
    case Con{_,rest}: agy_p114r_nstmts_calls_h(rest)

@unsafe
def agy_p114r_body_calls_h(stmts: List<&2,P114RStmt>) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{P114RScalar{s},rest}:
      agy_p114r_nstmts_calls_h([s]) || agy_p114r_body_calls_h(rest)
    case Con{P114RIf{c,yes,no},rest}:
      agy_p114r_body_calls_h(yes) || agy_p114r_body_calls_h(no) || agy_p114r_body_calls_h(rest)
    case Con{P114RResumeReady{p,call,r},rest}:
      agy_p114r_nstmts_calls_h(call) || agy_p114r_body_calls_h(rest)
    case Con{_,rest}: agy_p114r_body_calls_h(rest)
"""

MP_DISCOVER = r"""
@unsafe
def agy_p114h_plan_hygiene_ok(+name: String, +params: List<&2,String>, +body: List<&2,P114RStmt>,
    +cases: List<&2,P114HCase>, +available: KDef) -> Bool:
  +fparams = x192h_formals(params)
  +setup : List<&2,P113DStmt> = Con{P113DScalar{N111Alloca{"scratch",2048,8}},x192h_buffers(cases,0)}
  +wbody = x192h_worker_body(params,body,cases)
  +adapter = x192h_adapter(name,params)
  String.is_empty(p111_first(x181_program_stmts(setup,available),p111_first(x181_program_stmts(wbody,available),
    p111_first(x181_program_stmts(adapter,available),p111_first(x181_hygiene_names(fparams),
      p111_first(x181_hygiene_stmts(setup),p111_first(x181_hygiene_stmts(wbody),x181_hygiene_stmts(adapter))))))))

@unsafe
def agy_p114h_plan_hygiene(+name: String, +available: KDef, plan: P114HPlan) -> Bool:
  match plan:
    case P114HPlan{valid,params,body,cases}:
      nt_choose(Bool,valid,u => agy_p114h_plan_hygiene_ok(name,params,body,cases,available),u => False{})

@unsafe
def agy_p114h_seg_eligible(+segment: N111Segment, +direct: KDef, +hready: KDef) -> Bool:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      Bool.not(String.starts_with(name,"p111.k.")) &&
      Bool.not(String.eq(dk(function),"P113Direct") && U32.is_eq(ix(dv(function)),1)) &&
      Bool.not(String.eq(dk(p111v_get(hready,name)),"AgyHReady"))

type AgyHPass is Data:
  AgyHPass{+hready: KDef, +added: Bool}

@unsafe
def agy_p114h_scan_segs(segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +view: KDef, +available: KDef, +hready: KDef, +added: Bool) -> AgyHPass:
  match segs:
    case Nil{}: AgyHPass{hready,added}
    case Con{+seg,+rest}:
      match seg:
        case N111Segment{+name,+arity,result,incoming,flags,body}:
          nt_choose(AgyHPass,agy_p114h_seg_eligible(seg,direct,hready) &&
              agy_p114h_plan_hygiene(name,available,p114h_plan(seg,index,view)),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,p111v_put(hready,name,"AgyHReady",arity,1),True{}),
            u => agy_p114h_scan_segs(rest,index,direct,view,available,hready,added))

law agy_p114h_fixpoint:
  for +segs: List<&2,N111Segment>
  for +index: P112FusionIndex
  for +direct: KDef
  for +ready: KDef
  for +available: KDef
  for +hready: KDef
  for +fuel: U32
  KDef

@unsafe
def agy_p114h_fixpoint_next(+segs: List<&2,N111Segment>, +index: P112FusionIndex, +direct: KDef,
    +ready: KDef, +available: KDef, +fuel: U32, pass: AgyHPass) -> KDef:
  match pass:
    case AgyHPass{+hready2,added}:
      nt_choose(KDef,added,
        u => agy_p114h_fixpoint(segs,index,direct,ready,available,hready2,U32.sub(fuel,1)),
        u => hready2)

@unsafe
def agy_p114h_fixpoint(segs,index,direct,ready,available,hready,fuel):
  nt_choose(KDef,U32.is_eq(fuel,0),u => hready,u =>
    agy_p114h_fixpoint_next(segs,index,direct,ready,available,fuel,
      agy_p114h_scan_segs(segs,index,direct,agy_p124r_hview(ready,direct,hready),available,hready,False{})))

@unsafe
def agy_enrich_cursor(cursor: P134Cursor, +available: KDef) -> P134Cursor:
  match cursor:
    case P134Private{fns,ctx,next}: P134Private{fns,ctx,agy_enrich_cursor(next,available)}
    case P134Legacy{es,ctx,next}: P134Legacy{es,ctx,agy_enrich_cursor(next,available)}
    case P134Public{+segs,P134Context{+ids,+index,+direct,+ready,+view,+lookups,+heap,+mode},+next}:
      nt_choose(P134Cursor,Bool.not(U32.is_eq(mode,0)) && x192h_regions_enabled(),
        u => P134Public{segs,P134Context{ids,index,direct,ready,
          agy_p124r_hview(ready,direct,agy_p114h_fixpoint(segs,index,direct,ready,available,missing(),6)),
          lookups,heap,mode},next},
        u => P134Public{segs,P134Context{ids,index,direct,ready,view,lookups,heap,mode},next})
    case other: other
"""

OLD_LOOKUP = """@unsafe
def p124r_lookup_children(children: List<&2,KDef>, +name: String) -> P124Callable:
  match children:
    case Con{ready,Con{direct,Nil{}}}: p124r_complete(ready,name,p111v_get(direct,name))
    case _: P124Callable{False{},0,""}"""

NEW_LOOKUP = MP_HELPERS + """
@unsafe
def p124r_lookup_children(children: List<&2,KDef>, +name: String) -> P124Callable:
  match children:
    case Con{ready,Con{direct,Nil{}}}: p124r_complete(ready,name,p111v_get(direct,name))
    case Con{ready,Con{direct,Con{hready,Nil{}}}}: agy_p124r_complete3(ready,hready,name,p111v_get(direct,name))
    case _: P124Callable{False{},0,""}"""

OLD_CALL_NODES = """@unsafe
def p124r_call_nodes(body: List<&2,N111Stmt>, +count: U32, symbol: String) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p114r_without_transition(body),nt_append(N111Stmt,p114h_call_loads(count,0),[
    N111Call{"p114h_call_result",N111U64{},symbol,Con{p111_state(),p114h_call_args(count,0)}}]))"""

NEW_CALL_NODES = """@unsafe
def agy_p124r_call_args(+count: U32, +symbol: String) -> List<&2,N111Arg>:
  +base = p114h_call_args(count,0)
  nt_choose(List<&2,N111Arg>,String.starts_with(symbol,"p114r_"),
    u => nt_append(N111Arg,base,[N111Arg{N111U64{},N111Const{0,0}},N111Arg{N111U64{},N111Const{0,0}},N111Arg{N111U64{},N111Const{0,0}}]),
    u => base)

@unsafe
def p124r_call_nodes(body: List<&2,N111Stmt>, +count: U32, +symbol: String) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,p114r_without_transition(body),nt_append(N111Stmt,p114h_call_loads(count,0),[
    N111Call{"p114h_call_result",N111U64{},symbol,Con{p111_state(),agy_p124r_call_args(count,symbol)}}]))"""

OLD_FINISH = """@unsafe
def p114h_finish(+params: List<&2,String>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, scanned: P114GBody) -> P114HPlan:
  match scanned:
    case P114GBody{valid,+frames,body}:
      nt_choose(P114HPlan,valid && U32.is_gt(nt_count(P114GFrame,frames),0),
        u => p114h_closed(params,body,p114h_close(frames,owner,arity,index,ready,[],8)),u => p114h_refused())"""

NEW_FINISH = """law agy_p114r_body_calls_h:
  for stmts: List<&2,P114RStmt>
  Bool

law agy_p124r_known_orig:
  for +ready: KDef
  for +name: String
  Bool

@unsafe
def p114h_finish(+params: List<&2,String>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, scanned: P114GBody) -> P114HPlan:
  match scanned:
    case P114GBody{valid,+frames,+body}:
      nt_choose(P114HPlan,valid && (U32.is_gt(nt_count(P114GFrame,frames),0) || agy_p114r_body_calls_h(body)),
        u => p114h_closed(params,body,p114h_close(frames,owner,arity,index,ready,[],8)),u => p114h_refused())"""

OLD_PLAN_KNOWN = "u => nt_choose(P114HPlan,p124r_known(ready,name),v => p114h_refused(),"
NEW_PLAN_KNOWN = "u => nt_choose(P114HPlan,agy_p124r_known_orig(ready,name),v => p114h_refused(),"

OLD_X193F_PUBLIC = """@unsafe
def x193f_public(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +available: KDef) -> X181Output:
  nt_choose(X181Output,x192h_regions_enabled(),u =>
    x193f_after_h(segment,index,ids,ready,available,p114h_plan(segment,index,ready)),
    u => x193f_fallback(segment,index,ids,ready,available))"""

NEW_X193F_PUBLIC = """@unsafe
def x193f_public(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +view: KDef, +available: KDef) -> X181Output:
  nt_choose(X181Output,x192h_regions_enabled(),u =>
    x193f_after_h(segment,index,ids,ready,available,p114h_plan(segment,index,view)),
    u => x193f_fallback(segment,index,ids,ready,available))"""

OLD_PROG_PUBLIC = "u => x193f_public(segment,index,ids,ready,available),u => x181_segment(segment,ids)))"
NEW_PROG_PUBLIC = "u => x193f_public(segment,index,ids,ready,view,available),u => x181_segment(segment,ids)))"

OLD_X187_PREP = """@unsafe
def x187_prepared(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor(cursor,x181_cursor_index(cursor,missing()),x187_build_empty()),
        u => X187ObjectResult{[],error})"""

NEW_X187_PREP = MP_DISCOVER + """
@unsafe
def x187_prepared(+prepared: P169Prepared) -> X187ObjectResult:
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(X187ObjectResult,String.is_empty(error),u => x187_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty()),
        u => X187ObjectResult{[],error})"""

OLD_X202P_PREP = """@unsafe
def x202p_x187_prepared(+prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => x202p_x187_cursor(cursor,x181_cursor_index(cursor,missing()),x187_build_empty()),
        u => IO.die(U32,1,error))"""

NEW_X202P_PREP = """@unsafe
def x202p_x187_prepared(+prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      +avail = x181_cursor_index(cursor,missing())
      nt_choose(IO(U32),String.is_empty(error),u => x202p_x187_cursor(agy_enrich_cursor(cursor,avail),avail,x187_build_empty()),
        u => IO.die(U32,1,error))"""

def once(s: str, old: str, new: str, label: str) -> str:
    n = s.count(old)
    assert n == 1, f"{label}: expected 1 match, got {n}"
    return s.replace(old, new, 1)

def patch(text: str) -> str:
    text = once(text, OLD_FINISH, NEW_FINISH, "OLD_FINISH")
    text = once(text, OLD_PLAN_KNOWN, NEW_PLAN_KNOWN, "OLD_PLAN_KNOWN")
    text = once(text, OLD_LOOKUP, NEW_LOOKUP, "OLD_LOOKUP")
    text = once(text, OLD_CALL_NODES, NEW_CALL_NODES, "OLD_CALL_NODES")
    # Update agy_p124r_known_orig and agy_p114r_body_calls_h definitions to match their forward laws
    text = once(text, "def agy_p124r_known_orig(+ready: KDef, +name: String) -> Bool:", "def agy_p124r_known_orig(ready,name):", "known_orig def")
    text = once(text, "def agy_p114r_body_calls_h(stmts: List<&2,P114RStmt>) -> Bool:", "def agy_p114r_body_calls_h(stmts):", "body_calls_h def")
    text = once(text, OLD_X193F_PUBLIC, NEW_X193F_PUBLIC, "OLD_X193F_PUBLIC")
    text = once(text, OLD_PROG_PUBLIC, NEW_PROG_PUBLIC, "OLD_PROG_PUBLIC")
    text = once(text, OLD_X187_PREP, NEW_X187_PREP, "OLD_X187_PREP")
    text = once(text, OLD_X202P_PREP, NEW_X202P_PREP, "OLD_X202P_PREP")
    return text

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--dst", type=Path, default=DEFAULT_DST)
    a = ap.parse_args()
    out = patch(a.src.read_text())
    a.dst.parent.mkdir(parents=True, exist_ok=True)
    a.dst.write_text(out)
    print(f"Patched AGY-W2B-2 (multi-pass p114h) -> {a.dst} ({len(out)} bytes)")

if __name__ == "__main__":
    main()
