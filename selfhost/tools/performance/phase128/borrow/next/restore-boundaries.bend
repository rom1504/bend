# A verified observer can be unreachable after an earlier tiny wrapper was
# inlined. Recover that boundary from its exact original call/result equation.
# No SCC/name recognition: target + constants + bijective parameter permutation.
# Rules enter the index only AFTER the selected wrapper's original position.
# Inserted reader/adapter/fallback groups are never traversed by this rewrite.

@unsafe
def p128bi_parameter(+word: String, params: List<&2,NC_Binding>, +i: U32) -> KTerm:
  match params:
    case Nil{}: atom("Absent")
    case Con{NC_Binding{id,name,kind},rest}:
      nt_choose(KTerm,String.eq(word,name),u => var("",i),u => p128bi_parameter(word,rest,U32.inc(i)))

@unsafe
def p128bi_pattern(value: N111Value, params: List<&2,NC_Binding>) -> KTerm:
  match value:
    case N111Local{name}: p128bi_parameter(name,params,0)
    case N111Const{lo,hi}: kt("P128BIConstant","",lo,hi,[])
    case _: atom("Absent")

@unsafe
def p128bi_patterns(values: List<&2,N111Value>, +params: List<&2,NC_Binding>) -> List<&2,KTerm>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p128bi_pattern(head,params),p128bi_patterns(rest,params)}

@unsafe
def p128bi_all_patterns(patterns: List<&2,KTerm>) -> Bool:
  match patterns:
    case Nil{}: True{}
    case Con{+head,rest}:
      (String.eq(tg(head),"Var") || String.eq(tg(head),"P128BIConstant")) && p128bi_all_patterns(rest)

@unsafe
def p128bi_once(+patterns: KTerm, +count: U32, +i: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(i,count),u => True{},
    u => U32.is_eq(nq_uses(patterns,i),1) && p128bi_once(patterns,count,U32.inc(i)))

# Each rule is immutable source-derived semantic metadata in the existing
# hash index: name=old public entry, type=callee identity, value=argument pattern.
# Constant low/high words remain exact; variables name original parameter slots.
@unsafe
def p128bi_rule(function: P113DFunction) -> KDef:
  match function:
    case P113DFunction{+name,+params,+result,+public,body}:
      match body:
        case Con{P113DCall{Con{+out,Nil{}},+target,args},Con{P113DResult{Con{N111Local{reply},Nil{}}},Nil{}}}:
          +patterns = kt("P128BIPattern","",0,0,p128bi_patterns(args,params))
          +arity = nt_count(NC_Binding,params)
          nt_choose(KDef,public && U32.is_eq(result,1) && String.eq(out,reply) &&
            U32.is_le(arity,4) && U32.is_le(terms_len(ks(patterns)),8) &&
            p128bi_all_patterns(ks(patterns)) && p128bi_once(patterns,arity,0),
            u => KDef{name,"P128BIRule",arity,1,ref(target),patterns,[],False{},False{}},u => missing())
        case _: missing()

@unsafe
def p128bi_index(+index: KDef, +rule: KDef) -> KDef:
  +target = nm(dt(rule))
  +old = index_find(index,target,index_hash(target,2166136261),32)
  nt_choose(KDef,String.eq(dk(rule),"P128BIRule"),
    u => p113e_insert(index,KDef{target,"P128BIRules",0,0,atom("Absent"),atom("Absent"),Con{rule,dc(old)},False{},False{}}),
    u => index)

@unsafe
def p128bi_match_value(+pattern: KTerm, value: N111Value) -> Bool:
  nt_choose(Bool,String.eq(tg(pattern),"Var"),u => True{},
    u => p128bi_match_constant(pattern,value))

@unsafe
def p128bi_match_constant(+pattern: KTerm, value: N111Value) -> Bool:
  match value:
    case N111Const{lo,hi}: String.eq(tg(pattern),"P128BIConstant") && U32.is_eq(ix(pattern),lo) && U32.is_eq(qt(pattern),hi)
    case _: False{}

@unsafe
def p128bi_matches(patterns: List<&2,KTerm>, args: List<&2,N111Value>) -> Bool:
  match patterns args:
    case Nil{} Nil{}: True{}
    case Con{pattern,rest} Con{value,more}: p128bi_match_value(pattern,value) && p128bi_matches(rest,more)
    case _ _: False{}

@unsafe
def p128bi_argument(+i: U32, patterns: List<&2,KTerm>, args: List<&2,N111Value>) -> N111Value:
  match patterns args:
    case Con{+pattern,rest} Con{+value,more}:
      nt_choose(N111Value,String.eq(tg(pattern),"Var") && U32.is_eq(ix(pattern),i),
        u => value,u => p128bi_argument(i,rest,more))
    case _ _: N111Const{0,0}

@unsafe
def p128bi_arguments(+count: U32, +i: U32, +patterns: List<&2,KTerm>, +args: List<&2,N111Value>) -> List<&2,N111Value>:
  nt_choose(List<&2,N111Value>,U32.is_eq(i,count),u => [],
    u => Con{p128bi_argument(i,patterns,args),p128bi_arguments(count,U32.inc(i),patterns,args)})

@unsafe
def p128bi_pick(rules: List<&2,KDef>, +destinations: List<&2,String>, +args: List<&2,N111Value>, +original: P113DStmt, +candidate: P113DStmt, +count: U32) -> P113DStmt:
  match rules:
    case Nil{}: nt_choose(P113DStmt,U32.is_eq(count,1),u => candidate,u => original)
    case Con{+rule,+rest}:
      nt_choose(P113DStmt,p128bi_matches(ks(dv(rule)),args),
        u => p128bi_pick(rest,destinations,args,original,
          P113DCall{destinations,dn(rule),p128bi_arguments(da(rule),0,ks(dv(rule)),args)},U32.inc(count)),
        u => p128bi_pick(rest,destinations,args,original,candidate,count))

@unsafe
def p128bi_call(+stmt: P113DStmt, +index: KDef) -> P113DStmt:
  match stmt:
    case P113DCall{+destinations,+target,+args}:
      +bucket = index_find(index,target,index_hash(target,2166136261),32)
      nt_choose(P113DStmt,String.eq(dk(bucket),"P128BIRules") && U32.is_eq(nt_count(String,destinations),1),
        u => p128bi_pick(dc(bucket),destinations,args,stmt,stmt,0),u => stmt)
    case _: stmt

@unsafe
def p128bi_body(body: List<&2,P113DStmt>, +index: KDef) -> List<&2,P113DStmt>:
  match body:
    case Nil{}: []
    case Con{P113DIf{condition,yes,no},rest}:
      Con{P113DIf{condition,p128bi_body(yes,index),p128bi_body(no,index)},p128bi_body(rest,index)}
    case Con{head,rest}: Con{p128bi_call(head,index),p128bi_body(rest,index)}

@unsafe
def p128bi_function(function: P113DFunction, index: KDef) -> P113DFunction:
  match function:
    case P113DFunction{name,params,result,public,body}: P113DFunction{name,params,result,public,p128bi_body(body,index)}

@unsafe
def p128bi_walk(functions: List<&2,P113DFunction>, +patches: List<&2,P128BRPatch>, +index: KDef, reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,rest}:
      match head:
        case P113DFunction{name,params,result,public,body}:
          p128bi_step(head,rest,patches,index,reversed,p128br_replacement(name,patches))

@unsafe
def p128bi_step(+original: P113DFunction, +rest: List<&2,P113DFunction>, +patches: List<&2,P128BRPatch>, +index: KDef, reversed: List<&2,P113DFunction>, replacement: Maybe<&2,List<&2,P113DFunction>>) -> List<&2,P113DFunction>:
  match replacement:
    case None{}: p128bi_walk(rest,patches,index,Con{p128bi_function(original,index),reversed})
    case Some{functions}: p128bi_walk(rest,patches,p128bi_index(index,p128bi_rule(original)),nt_reverse(P113DFunction,functions,reversed))

@unsafe
def p128br_apply(functions: List<&2,P113DFunction>, patches: List<&2,P128BRPatch>) -> List<&2,P113DFunction>:
  p128bi_walk(functions,patches,missing(),[])
