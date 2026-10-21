# Version05: annotate duplicated parameters on both prefilter helpers.
# Version04: conservative opcode prefilter before list-based reaching facts.
# Version03: explicitly duplicate the seed identity counter.
# Version02: respect declaration order when matching statement and scan.
# Low32 identities, not source type names. Mode0=opaque,1=constant,
# 2=logical shift,3=canonical sign predicate,4=sign-selected constant mask.
type P120WFact is Data:
  P120WFact{+bits: U32, +id: U32, +mode: U32, +root: U32, +amount: U32, +positive: Bool, +literal: U32}
type P120WBinding is Data:
  P120WBinding{+name: String, +fact: P120WFact}
type P120WScan is Data:
  P120WScan{+reversed: List<&2,P113DStmt>, +facts: List<&2,P120WBinding>, +next: U32, +hits: U32}

@unsafe
def p120w_unknown(bits: U32, id: U32) -> P120WFact:
  P120WFact{bits,id,0,0,0,True{},0}

@unsafe
def p120w_constant(value: U32) -> P120WFact:
  P120WFact{32,0,1,0,0,True{},value}

@unsafe
def p120w_get(facts: List<&2,P120WBinding>, +name: String) -> P120WFact:
  match facts:
    case Nil{}: p120w_unknown(64,0)
    case Con{P120WBinding{key,+fact},+rest}:
      nt_choose(P120WFact,String.eq(key,name),u => fact,u => p120w_get(rest,name))

@unsafe
def p120w_value(value: N111Value, facts: List<&2,P120WBinding>) -> P120WFact:
  match value:
    case N111Local{name}: p120w_get(facts,name)
    case N111Const{+lo,hi}: nt_choose(P120WFact,U32.is_eq(hi,0),u => p120w_constant(lo),u => p120w_unknown(64,0))
    case _: p120w_unknown(64,0)

@unsafe
def p120w_filter(facts: List<&2,P120WBinding>, +name: String, +reversed: List<&2,P120WBinding>) -> List<&2,P120WBinding>:
  match facts:
    case Nil{}: nt_reverse(P120WBinding,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P120WBinding{key,fact}:
          next : List<&2,P120WBinding> = nt_choose(List<&2,P120WBinding>,String.eq(key,name),u => reversed,u => Con{head,reversed})
          p120w_filter(rest,name,next)

@unsafe
def p120w_put(facts: List<&2,P120WBinding>, +name: String, fact: P120WFact) -> List<&2,P120WBinding>:
  Con{P120WBinding{name,fact},p120w_filter(facts,name,[])}

@unsafe
def p120w_limit(fact: P120WFact, width: U32) -> P120WFact:
  match fact:
    case P120WFact{bits,id,mode,root,amount,positive,literal}:
      P120WFact{U32.min(bits,width),id,mode,root,amount,positive,literal}

@unsafe
def p120w_is_const(fact: P120WFact, value: U32) -> Bool:
  match fact:
    case P120WFact{bits,id,mode,root,amount,positive,literal}:
      U32.is_eq(mode,1) && U32.is_eq(literal,value)

@unsafe
def p120w_same(a: P120WFact, b: P120WFact) -> Bool:
  match a b:
    case P120WFact{ab,ai,am,ar,aa,ap,al} P120WFact{bb,bi,bm,br,ba,bp,bl}:
      U32.is_eq(ab,bb) && U32.is_eq(ai,bi) && U32.is_eq(am,bm) && U32.is_eq(ar,br) &&
        U32.is_eq(aa,ba) && U32.is_eq(Bool.to_u32(ap),Bool.to_u32(bp)) && U32.is_eq(al,bl)

@unsafe
def p120w_known(fact: P120WFact) -> Bool:
  match fact:
    case P120WFact{bits,id,mode,root,amount,positive,literal}: U32.is_gt(id,0) || U32.is_gt(mode,0)

@unsafe
def p120w_condition(+op: String, left: P120WFact, +right: P120WFact) -> P120WFact:
  match left:
    case P120WFact{bits,id,+mode,+root,amount,+positive,literal}:
      nt_choose(P120WFact,U32.is_eq(mode,3) && (p120w_is_const(right,0) || p120w_is_const(right,1)),
        u => P120WFact{1,0,3,root,0,
          nt_choose(Bool,(String.eq(op,"eq") && p120w_is_const(right,1)) ||
            (String.eq(op,"ne") && p120w_is_const(right,0)),v => positive,v => Bool.not(positive)),0},
        u => p120w_unknown(1,0))

@unsafe
def p120w_binary(+typ: N111Type, +op: String, +left: P120WFact, +right: P120WFact, +next: U32) -> P120WFact:
  match left right:
    case P120WFact{+lb,+li,+lm,+lr,la,+lp,ll} P120WFact{rb,ri,+rm,rr,ra,rp,+rl}:
      nt_choose(P120WFact,String.eq(op,"and") && p120w_is_const(right,4294967295),
        u => p120w_limit(left,32),u =>
      nt_choose(P120WFact,String.eq(op,"shr") && U32.is_le(lb,32) && U32.is_gt(li,0) &&
          U32.is_eq(rm,1) && U32.is_gt(rl,0) && U32.is_lt(rl,32),
        u => nt_choose(P120WFact,U32.is_eq(rl,31),
          v => P120WFact{1,next,3,li,0,True{},0},v => P120WFact{32,next,2,li,rl,True{},0}),u =>
      nt_choose(P120WFact,(String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(lm,3),
        u => p120w_condition(op,left,right),u =>
      nt_choose(P120WFact,String.eq(op,"xor") && U32.is_eq(lm,3) && p120w_is_const(right,1),
        u => P120WFact{1,next,3,lr,0,Bool.not(lp),0},
        u => p120w_unknown(nt_choose(U32,p111v_comparison(op),v => 1,v => p113k_width(typ)),next)))))

@unsafe
def p120w_join_fact(+condition: P120WFact, +yes: P120WFact, +no: P120WFact) -> P120WFact:
  match condition yes no:
    case P120WFact{cb,ci,+cm,+cr,ca,+cp,cl} P120WFact{yb,yi,+ym,yr,ya,yp,+yl} P120WFact{nb,ni,+nm,nr,na,np,+nl}:
      nt_choose(P120WFact,p120w_same(yes,no),u => yes,u =>
      nt_choose(P120WFact,U32.is_eq(cm,3) && U32.is_eq(ym,1) && U32.is_eq(nm,1) &&
          ((U32.is_eq(yl,0) && U32.is_gt(nl,0)) || (U32.is_gt(yl,0) && U32.is_eq(nl,0))),
        u => P120WFact{32,0,nt_choose(U32,U32.is_eq(U32.or(yl,nl),1),v => 3,v => 4),cr,0,
          nt_choose(Bool,U32.is_gt(yl,0),v => cp,v => Bool.not(cp)),U32.or(yl,nl)},
        u => p120w_unknown(64,0)))

@unsafe
def p120w_join(+condition: P120WFact, yes: List<&2,P120WBinding>, +no: List<&2,P120WBinding>, out: List<&2,P120WBinding>) -> List<&2,P120WBinding>:
  match yes:
    case Nil{}: out
    case Con{P120WBinding{+name,fact},rest}:
      joined : P120WFact = p120w_join_fact(condition,fact,p120w_get(no,name))
      p120w_join(condition,rest,no,Con{P120WBinding{name,joined},out})

# Locate a still-initialized low32 representative of the original value ID.
# IDs denote low32 equivalence; upper-bit facts are tracked separately.
@unsafe
def p120w_origin(facts: List<&2,P120WBinding>, +root: U32) -> String:
  match facts:
    case Nil{}: ""
    case Con{P120WBinding{+name,P120WFact{bits,id,mode,r,a,p,l}},+rest}:
      nt_choose(String,U32.is_gt(root,0) && U32.is_eq(id,root) && U32.is_le(bits,32),
        u => name,u => p120w_origin(rest,root))

@unsafe
def p120w_shift_origin(shift: P120WFact, mask: P120WFact, +facts: List<&2,P120WBinding>) -> String:
  match shift mask:
    case P120WFact{sb,si,sm,+sr,+sa,sp,sl} P120WFact{mb,mi,mm,mr,ma,mp,ml}:
      nt_choose(String,U32.is_eq(sm,2) && U32.is_eq(mm,4) && mp && U32.is_eq(sr,mr) &&
        U32.is_gt(sa,0) && U32.is_lt(sa,32) &&
        U32.is_eq(ml,U32.shln(4294967295,U32.to_nat(U32.sub(32,sa)))),
        u => p120w_origin(facts,sr),u => "")

@unsafe
def p120w_amount(fact: P120WFact) -> U32:
  match fact:
    case P120WFact{bits,id,mode,root,amount,positive,literal}: amount

@unsafe
def p120w_replacement(+name: String, source: String, amount: U32) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{name,N111U64{},"shl",N111Local{source},N111Const{32,0}}},
   P113DScalar{N111Bin{name,N111U64{},"sar",N111Local{name},N111Const{U32.add(32,amount),0}}},
   P113DScalar{N111Bin{name,N111U64{},"and",N111Local{name},N111Const{4294967295,0}}}]

@unsafe
def p120w_emit_bin(+stmt: N111Stmt, +facts: List<&2,P120WBinding>, +next: U32, +hits: U32, +out: List<&2,P113DStmt>) -> P120WScan:
  match stmt:
    case N111Bin{+name,+typ,+op,+left,+right}:
      +lf = p120w_value(left,facts)
      +rf = p120w_value(right,facts)
      +origin = nt_choose(String,String.eq(op,"or"),u => p120w_shift_origin(lf,rf,facts),u => "")
      +reverse_origin = nt_choose(String,String.eq(op,"or"),u => p120w_shift_origin(rf,lf,facts),u => "")
      +source = nt_choose(String,String.is_empty(origin),u => reverse_origin,u => origin)
      +amount = nt_choose(U32,String.is_empty(origin),u => p120w_amount(rf),u => p120w_amount(lf))
      +replacement = Bool.not(String.is_empty(source))
      P120WScan{nt_choose(List<&2,P113DStmt>,replacement,
        u => nt_reverse(P113DStmt,p120w_replacement(name,source,amount),out),
        u => Con{P113DScalar{stmt},out}),
        p120w_put(facts,name,nt_choose(P120WFact,replacement,u => p120w_unknown(32,next),
          u => p120w_limit(p120w_binary(typ,op,lf,rf,next),p113k_width(typ)))),
        U32.inc(next),U32.add(hits,Bool.to_u32(replacement))}
    case _: P120WScan{Con{P113DScalar{stmt},out},[],U32.inc(next),hits}

law p120w_walk:
  List<&2,P113DStmt> -> P120WScan -> P120WScan

@unsafe
def p120w_join_scan(+original: P113DStmt, +condition: N111Value, +cf: P120WFact,
    +scalar: Bool, yes: P120WScan, no: P120WScan, out: List<&2,P113DStmt>) -> P120WScan:
  match yes no:
    case P120WScan{yb,yf,yn,yh} P120WScan{nb,nf,nn,nh}:
      P120WScan{Con{nt_choose(P113DStmt,scalar,u => original,
        u => P113DIf{condition,nt_reverse(P113DStmt,yb,[]),nt_reverse(P113DStmt,nb,[])}),out},
        p120w_join(cf,yf,nf,[]),nn,U32.add(yh,nh)}

@unsafe
def p120w_branch_no(+original: P113DStmt, +condition: N111Value, +cf: P120WFact,
    +scalar: Bool, +yes: P120WScan, no: List<&2,P113DStmt>, facts: List<&2,P120WBinding>, out: List<&2,P113DStmt>) -> P120WScan:
  match yes:
    case P120WScan{body,env,next,hits}:
      p120w_join_scan(original,condition,cf,scalar,yes,p120w_walk(no,P120WScan{[],facts,next,0}),out)

@unsafe
def p120w_branch(+original: P113DStmt, +condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, +scalar: Bool,
    +facts: List<&2,P120WBinding>, next: U32, hits: U32, out: List<&2,P113DStmt>) -> P120WScan:
  p120w_branch_no(original,condition,p120w_value(condition,facts),scalar,
    p120w_walk(yes,P120WScan{[],facts,next,hits}),no,facts,out)

@unsafe
def p120w_scalar(+stmt: N111Stmt, +facts: List<&2,P120WBinding>, +next: U32, +hits: U32, +out: List<&2,P113DStmt>) -> P120WScan:
  match stmt:
    case N111Set{+name,typ,value}:
      P120WScan{Con{P113DScalar{stmt},out},p120w_put(facts,name,p120w_limit(p120w_value(value,facts),p113k_width(typ))),U32.inc(next),hits}
    case N111Bin{name,typ,op,left,right}: p120w_emit_bin(stmt,facts,next,hits,out)
    case N111If{+condition,yes,no}:
      p120w_branch(P113DScalar{stmt},condition,p113d_scalars(yes),p113d_scalars(no),True{},facts,next,hits,out)
    case N111Load{+name,typ,base,offset}:
      P120WScan{Con{P113DScalar{stmt},out},p120w_put(facts,name,p120w_unknown(p113k_width(typ),next)),U32.inc(next),hits}
    case N111Alloca{+name,bytes,align}:
      P120WScan{Con{P113DScalar{stmt},out},p120w_put(facts,name,p120w_unknown(64,next)),U32.inc(next),hits}
    case _: P120WScan{Con{P113DScalar{stmt},out},[],U32.inc(next),hits}

@unsafe
def p120w_step(+stmt: P113DStmt, scan: P120WScan) -> P120WScan:
  match stmt scan:
    case P113DScalar{scalar} P120WScan{out,facts,next,hits}:
      p120w_scalar(scalar,facts,next,hits,out)
    case P113DIf{+condition,yes,no} P120WScan{out,facts,next,hits}:
      p120w_branch(stmt,condition,yes,no,False{},facts,next,hits,out)
    case _ P120WScan{out,facts,next,hits}:
      P120WScan{Con{stmt,out},[],U32.inc(next),hits}

@unsafe
def p120w_walk(body, scan):
  match body:
    case Nil{}: scan
    case Con{stmt,rest}: p120w_walk(rest,p120w_step(stmt,scan))

@unsafe
def p120w_seed(params: List<&2,NC_Binding>, +next: U32, out: List<&2,P120WBinding>) -> List<&2,P120WBinding>:
  match params:
    case Nil{}: out
    case Con{NC_Binding{id,+word,kind},rest}:
      p120w_seed(rest,U32.inc(next),Con{P120WBinding{word,p120w_unknown(64,next)},out})

@unsafe
def p120w_finish(name: String, params: List<&2,NC_Binding>, result: U32, public: Bool, scan: P120WScan) -> P113DFunction:
  match scan:
    case P120WScan{reversed,facts,next,hits}: P113DFunction{name,params,result,public,nt_reverse(P113DStmt,reversed,[])}

# Version04: no fact-table construction unless both necessary opcode families
# occur. Counts may be aliased locals, so this deliberately does not demand a
# literal 31. A successful replacement must derive a sign fact from shr and
# rewrite an or; these are the only two producers/consumers in this model.
law p120w_prefilter_scalars:
  List<&2,N111Stmt> -> U32 -> U32
law p120w_prefilter_body:
  List<&2,P113DStmt> -> U32 -> U32

@unsafe
def p120w_prefilter_scalar(stmt: N111Stmt, +flags: U32) -> U32:
  match stmt:
    case N111Bin{name,typ,+op,left,right}:
      U32.or(flags,U32.add(Bool.to_u32(String.eq(op,"shr")),
        U32.mul(2,Bool.to_u32(String.eq(op,"or")))))
    case N111If{condition,yes,no}:
      p120w_prefilter_scalars(no,p120w_prefilter_scalars(yes,flags))
    case _: flags

@unsafe
def p120w_prefilter_scalars(+body: List<&2,N111Stmt>, +flags: U32) -> U32:
  nt_choose(U32,U32.is_eq(flags,3),u => flags,u =>
    match body:
      case Nil{}: flags
      case Con{stmt,rest}: p120w_prefilter_scalars(rest,p120w_prefilter_scalar(stmt,flags)))

@unsafe
def p120w_prefilter_stmt(stmt: P113DStmt, flags: U32) -> U32:
  match stmt:
    case P113DScalar{scalar}: p120w_prefilter_scalar(scalar,flags)
    case P113DIf{condition,yes,no}:
      p120w_prefilter_body(no,p120w_prefilter_body(yes,flags))
    case _: flags

@unsafe
def p120w_prefilter_body(+body: List<&2,P113DStmt>, +flags: U32) -> U32:
  nt_choose(U32,U32.is_eq(flags,3),u => flags,u =>
    match body:
      case Nil{}: flags
      case Con{stmt,rest}: p120w_prefilter_body(rest,p120w_prefilter_stmt(stmt,flags)))

@unsafe
def p120w_function(+function: P113DFunction) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,U32.is_lt(p113i_size(body),1024),u =>
        nt_choose(P113DFunction,U32.is_eq(p120w_prefilter_body(body,0),3),
          v => p120w_finish(name,params,result,public,p120w_walk(body,
            P120WScan{[],p120w_seed(params,1,[]),U32.inc(nt_count(NC_Binding,params)),0})),
          v => function),u => function)

@unsafe
def p120w_functions(functions: List<&2,P113DFunction>, reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{function,rest}: p120w_functions(rest,Con{p120w_function(function),reversed})

@unsafe
def p120w_boundary(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,u => p114s_commit(boundary,p120w_functions(functions,[])),u => boundary)

# Original verified range result is the fallback if the derived body fails.
@unsafe
def p114s_ranges(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,u => p120w_boundary(p114s_commit(boundary,p113k_functions(functions))),u => boundary)
