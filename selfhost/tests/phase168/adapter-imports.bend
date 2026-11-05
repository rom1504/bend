# Import-before-discovery experiment. The following registry helpers preserve
# Phase164 p164j semantics; names change to keep its frozen module independent.
# Unlike that predecessor, this module overrides no production declaration.

@unsafe
def p168j_eligible(segment: N111Segment, direct: KDef) -> Bool:
  match segment:
    case N111Segment{name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32) &&
        String.eq(dk(function),"P113Direct") && U32.is_eq(da(function),arity) &&
        U32.is_eq(dx(function),1) && U32.is_eq(ix(dv(function)),1)

@unsafe
def p168j_insert(segment: N111Segment, registry: P112RegionRegistry) -> P112RegionRegistry:
  match segment registry:
    case N111Segment{+name,+arity,result,incoming,flags,body} P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,0),
        p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,0),entries,U32.inc(workers),fusions}

@unsafe
def p168j_imports(segments: List<&2,N111Segment>, +direct: KDef, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: registry
    case Con{+head,rest}:
      p168j_imports(rest,direct,nt_choose(P112RegionRegistry,p168j_eligible(head,direct),
        u => p168j_insert(head,registry),u => registry))

@unsafe
def p168j_candidates(segments: List<&2,N111Segment>, +imports: KDef,
    +acc: List<&2,P112MultiCandidate>) -> List<&2,P112MultiCandidate>:
  match segments:
    case Nil{}: nt_reverse(P112MultiCandidate,acc,[])
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{name,arity,result,incoming,flags,body}:
          nt_choose(List<&2,P112MultiCandidate>,p112w_ready(imports,name),
            u => p168j_candidates(rest,imports,acc),u =>
              nt_choose(List<&2,P112MultiCandidate>,p112c_candidate(segment),
                v => p168j_candidates(rest,imports,Con{P112MultiCandidate{segment},acc}),
                v => p168j_candidates(rest,imports,acc)))

@unsafe
def p168j_registry(segments: List<&2,N111Segment>, +index: P112FusionIndex,
    +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      p112c_passes(p168j_candidates(segments,ready,[]),index,registry,1,6)

@unsafe
def p168j_forward(+name: String, +arity: U32) -> String:
  "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ") {\n@entry\n" ++
  "%p164_forward =l call $" ++ p113e_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\nret %p164_forward\n}\n"

@unsafe
def p168j_forward_if(function: P113DFunction, ready: KDef) -> String:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      +entry = p111v_get(ready,name)
      nt_choose(String,String.eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0),
        u => p168j_forward(name,nt_count(NC_Binding,params)),u => "")

@unsafe
def p168j_forwards(functions: List<&2,P113DFunction>, +ready: KDef,
    acc: List<&2,String>) -> List<&2,String>:
  match functions:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{head,rest}: p168j_forwards(rest,ready,Con{p168j_forward_if(head,ready),acc})

# Rank0 import names have actual QBE forwarders. The registry excludes those
# owners from region candidates, so neither missing nor duplicate p112w bodies
# are hidden by a fabricated plan. Keep the full actual fusion index.
@unsafe
def p168j_collected(+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>,
    ids: N111Ids, index: P112FusionIndex, heap: U32, mode: U32,
    tables: List<&2,P111QData>, +registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      nt_append(String,p168j_forwards(functions,ready,[]),
        p134e_collect_cursor(p134e_registered(segments,functions,ids,index,heap,mode,tables,registry),[],[]))

@unsafe
def p168j_seeded(+program: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, live: Bool) -> List<&2,String>:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,u => 1)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p168j_collected(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),
        p168j_registry(segments,index,p168j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))

@unsafe
def p168j_checked(mode: U32, +original: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, +live: Bool, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u =>
    P111Emission{nt_choose(List<&2,String>,U32.is_eq(mode,1),
      v => p168j_seeded(original,nodes,functions,live),
      v => p134e_collect_cursor(p134e_prepare(original,nodes,functions,False{},live),[],[])),""},
    u => P111Emission{[],"adapter imports view verification: " ++ error})

# Sole experimental override: p168v_lowered still runs p167ob_final on the
# original private program BEFORE entering here. Both modes now use the same
# authenticated public view and extra maintained public/borrowed verification.
@unsafe
def p168v_prepare(mode: U32, +program: P113DProgram, adapters: KDef) -> P111Emission:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p168j_checked(mode,original,nodes,view,p167live_eligible(program),p118b_verify_functions(view,original))

@unsafe
def p168j_plan(mode: U32, plan: P86Plan) -> P111Emission:
  p168v_plan(mode,plan)
