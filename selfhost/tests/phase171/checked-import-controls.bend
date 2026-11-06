# Compiler-data refusals only. No generated malformed runtime is executed.
# A nonempty real import set is required; absence is an explicit coverage gap.

@unsafe
def p171c_plan_false(plan: P114HPlan) -> P114HPlan:
  match plan:
    case P114HPlan{valid,params,body,cases}: P114HPlan{False{},params,body,cases}

@unsafe
def p171c_segment_bad(segment: N111Segment) -> N111Segment:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      N111Segment{name,U32.inc(arity),result,incoming,flags,body}

@unsafe
def p171c_import(+item: P171Import, mode: U32) -> P171Import:
  match item mode:
    case P171Import{source,segment,family,plan,dependencies,rank} 1:
      P171Import{source,segment,family,plan,dependencies,0}
    case P171Import{source,segment,family,plan,dependencies,rank} 2:
      P171Import{source,segment,[],plan,dependencies,rank}
    case P171Import{source,segment,family,plan,dependencies,rank} 3:
      P171Import{source,segment,family,p171c_plan_false(plan),dependencies,rank}
    case P171Import{source,segment,family,plan,dependencies,rank} 4:
      P171Import{source,p171c_segment_bad(segment),family,plan,dependencies,rank}
    case P171Import{source,segment,family,plan,dependencies,rank} 5:
      P171Import{source ++ "!p171_missing",segment,family,plan,dependencies,rank}
    case P171Import{source,segment,family,plan,dependencies,rank} _:
      P171Import{source,segment,family,plan,dependencies,rank}

@unsafe
def p171c_bad_call(item: P171Import) -> P113DFunction:
  match item:
    case P171Import{source,N111Segment{name,arity,result,incoming,flags,body},family,plan,dependencies,rank}:
      P113DFunction{"p171_negative_caller",[],1,False{},
        [P113DCall{["p171_out"],name,[]},P113DResult{[N111Local{"p171_out"}]}]}

@unsafe
def p171c_one(+request: NR_Request, program: P171Program, +mode: U32) -> String:
  match program:
    case P171Program{base,adapters,Nil{},added,error}: "coverage gap: no closed self-recursive import"
    case P171Program{+base,+adapters,Con{+item,+rest},+added,+error}:
      +imports = nt_choose(List<&2,P171Import>,U32.is_eq(mode,6),
        u => Con{item,Con{item,rest}},u => Con{p171c_import(item,mode),rest})
      +workers = nt_choose(List<&2,P113DFunction>,U32.is_eq(mode,7),
        u => nt_append(P113DFunction,added,[p171c_bad_call(item)]),u => added)
      p171_verify(request,P171Program{base,adapters,imports,workers,error})

@unsafe
def p171c_rows(+request: NR_Request, +program: P171Program) -> List<&2,String>:
  [p171c_one(request,program,0),p171c_one(request,program,1),p171c_one(request,program,2),
   p171c_one(request,program,3),p171c_one(request,program,4),p171c_one(request,program,5),
   p171c_one(request,program,6),p171c_one(request,program,7),p171c_one(request,program,8)]

@unsafe
def p171_controls(+request: NR_Request) -> List<&2,String>:
  p171c_rows(request,p171_request(request))
