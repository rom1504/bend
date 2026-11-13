# Retain exact integer predicates through pure copy diamonds before allocation.
# Facts describe values, never aliases: each write replaces its destination fact.
# Calls and unresolved joins forget facts. No load/store/call is moved or deleted.
# Reuse the checked select shape so every original destination is still written.

def x192_predicate_enabled() -> Bool: True{}

@unsafe
def x192_p_boolean(value: N111Value, facts: KDef) -> Bool:
  match value:
    case N111Const{lo,hi}: U32.is_eq(hi,0) && U32.is_le(lo,1)
    case N111Local{name}: U32.is_eq(da(p111v_get(facts,name)),1)
    case _: False{}

@unsafe
def x192_p_write(facts: KDef, name: String, known: Bool) -> KDef:
  p111v_put(facts,name,"X192Predicate",nt_choose(U32,known,u => 1,u => 0),0)

@unsafe
def x192_p_scalar_facts(stmt: N111Stmt, +facts: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: x192_p_write(facts,name,x190_branch_width(typ) && x192_p_boolean(value,facts))
    case N111Bin{+name,typ,+op,+left,+right}:
      x192_p_write(facts,name,x190_branch_width(typ) &&
        (p111v_comparison(op) || ((String.eq(op,"and") || String.eq(op,"or") || String.eq(op,"xor")) &&
          x192_p_boolean(left,facts) && x192_p_boolean(right,facts))))
    case N111Load{name,typ,base,offset}: x192_p_write(facts,name,False{})
    case N111Offset{name,base,bytes}: x192_p_write(facts,name,False{})
    case N111Alloca{name,bytes,align}: x192_p_write(facts,name,False{})
    case N111Store{typ,base,offset,value}: facts
    case _: missing()

@unsafe
def x192_p_constant(value: N111Value, wanted: U32) -> Bool:
  match value:
    case N111Const{lo,hi}: U32.is_eq(hi,0) && U32.is_eq(lo,wanted)
    case _: False{}

# A boolean comparison with 0/1 is a copy or complement. Both original
# operands have already been evaluated; no floating predicate is admitted.
@unsafe
def x192_p_binary(+stmt: N111Stmt, +facts: KDef) -> N111Stmt:
  match stmt:
    case N111Bin{+name,typ,+op,+left,+right}:
      nt_choose(N111Stmt,x190_branch_width(typ) && (String.eq(op,"eq") || String.eq(op,"ne")) &&
          x192_p_boolean(left,facts) && (x192_p_constant(right,0) || x192_p_constant(right,1)),
        u => nt_choose(N111Stmt,Bool.xor(String.eq(op,"eq"),x192_p_constant(right,0)),
          v => N111Set{name,N111U32{},left},v => N111Bin{name,N111U32{},"xor",left,N111Const{1,0}}),
        u => stmt)
    case _: stmt

@unsafe
def x192_p_chain(names: List<&2,String>, +typ: N111Type, +value: N111Value, invert: Bool) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{P113DScalar{nt_choose(N111Stmt,invert,
      u => N111Bin{name,typ,"xor",value,N111Const{1,0}},u => N111Set{name,typ,value})},
      x192_p_chain(rest,typ,N111Local{name},False{})}

# Certificate result is the exact replacement rows. None keeps the branch.
@unsafe
def x192_p_plan(+condition: N111Value, facts: KDef, plan: Maybe<&2,X191SelectPlan>) -> Maybe<&2,List<&2,P113DStmt>>:
  match plan:
    case Some{X191SelectPlan{+typ,+yes,+no,+names}}:
      nt_choose(Maybe<&2,List<&2,P113DStmt>>,x186_e_equal(yes,no),
        u => Some{x192_p_chain(names,typ,yes,False{})},u =>
          nt_choose(Maybe<&2,List<&2,P113DStmt>>,x192_p_boolean(condition,facts) &&
              ((x192_p_constant(yes,1) && x192_p_constant(no,0)) ||
               (x192_p_constant(yes,0) && x192_p_constant(no,1))),
            v => Some{x192_p_chain(names,typ,condition,x192_p_constant(yes,0))},v => None{}))
    case None{}: None{}

law x192_p_body:
  for body: List<&2,P113DStmt>
  for facts: KDef
  List<&2,P113DStmt>

@unsafe
def x192_p_if_chosen(chosen: Maybe<&2,List<&2,P113DStmt>>, condition: N111Value,
    yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  match chosen:
    case Some{rows}: x192_p_body(nt_append(P113DStmt,rows,rest),facts)
    case None{}: Con{P113DIf{condition,x192_p_body(yes,facts),x192_p_body(no,facts)},x192_p_body(rest,missing())}

@unsafe
def x192_p_if(+condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  x192_p_if_chosen(x192_p_plan(condition,facts,x191_select_plan(yes,no)),condition,yes,no,rest,facts)

@unsafe
def x192_p_scalar(stmt: N111Stmt, rest: List<&2,P113DStmt>, +facts: KDef) -> List<&2,P113DStmt>:
  +ready = x192_p_binary(stmt,facts)
  Con{P113DScalar{ready},x192_p_body(rest,x192_p_scalar_facts(ready,facts))}

@unsafe
def x192_p_body(body,facts):
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}: x192_p_if(condition,yes,no,rest,facts)
    case Con{P113DScalar{N111If{condition,yes,no}},rest}:
      x192_p_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),rest,facts)
    case Con{P113DScalar{stmt},rest}: x192_p_scalar(stmt,rest,facts)
    case Con{head,rest}: Con{head,x192_p_body(rest,missing())}

@unsafe
def x192_predicate_body(+body: List<&2,P113DStmt>) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x192_predicate_enabled() && U32.is_le(p113i_size(body),4096),
    u => x192_p_body(body,missing()),u => body)
