# Independent imports-only ablation. Use ORIGINAL p134e_plan/p128raw lowering
# and verification; do not load the mixed lowerer or hybrid renderer overrides.
# A public final direct function already implements its checked original ABI.
@unsafe
def p164j_eligible(segment: N111Segment, direct: KDef) -> Bool:
  match segment:
    case N111Segment{name,+arity,result,incoming,flags,body}:
      +function = p111v_get(direct,name)
      U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32) &&
        String.eq(dk(function),"P113Direct") && U32.is_eq(da(function),arity) &&
        U32.is_eq(dx(function),1) && U32.is_eq(ix(dv(function)),1)

@unsafe
def p164j_insert(segment: N111Segment, registry: P112RegionRegistry) -> P112RegionRegistry:
  match segment registry:
    case N111Segment{+name,+arity,result,incoming,flags,body} P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,0),
        p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,0),entries,U32.inc(workers),fusions}

@unsafe
def p164j_imports(segments: List<&2,N111Segment>, +direct: KDef, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: registry
    case Con{+head,rest}:
      p164j_imports(rest,direct,nt_choose(P112RegionRegistry,p164j_eligible(head,direct),
        u => p164j_insert(head,registry),u => registry))

# Imported symbols have real forwarders, not fabricated worker plans. Exclude
# only those owners from candidate construction; retain the FULL fusion index.
@unsafe
def p164j_candidates(segments: List<&2,N111Segment>, +imports: KDef, +acc: List<&2,P112MultiCandidate>) -> List<&2,P112MultiCandidate>:
  match segments:
    case Nil{}: nt_reverse(P112MultiCandidate,acc,[])
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{name,arity,result,incoming,flags,body}:
          nt_choose(List<&2,P112MultiCandidate>,p112w_ready(imports,name),
            u => p164j_candidates(rest,imports,acc),u =>
              nt_choose(List<&2,P112MultiCandidate>,p112c_candidate(segment),
                v => p164j_candidates(rest,imports,Con{P112MultiCandidate{segment},acc}),
                v => p164j_candidates(rest,imports,acc)))

@unsafe
def p164j_registry(segments: List<&2,N111Segment>, +index: P112FusionIndex, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      p112c_passes(p164j_candidates(segments,ready,[]),index,registry,1,6)

# This override changes only the registry seed/candidates. Original segments,
# original fusion index, direct bodies, static image and capability policy stay.
@unsafe
def p134e_prepare(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, +arrays: Bool, +live: Bool) -> P134Cursor:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,
        u => nt_choose(U32,arrays,v => 2,v => 1))
      +tables = nt_choose(List<&2,P111QData>,arrays,u => p117p_tables(tables,[]),u => tables)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p134e_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),
        p164j_registry(segments,index,p164j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))

@unsafe
def p164j_forward(+name: String, +arity: U32) -> String:
  "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ") {\n@entry\n" ++
  "%p164_forward =l call $" ++ p113e_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\nret %p164_forward\n}\n"

@unsafe
def p164j_forward_if(function: P113DFunction, ready: KDef) -> String:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      +entry = p111v_get(ready,name)
      nt_choose(String,String.eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0),
        u => p164j_forward(name,nt_count(NC_Binding,params)),u => "")

@unsafe
def p134e_private(+function: P113DFunction, context: P134Context) -> String:
  match context:
    case P134Context{+ids,index,direct,ready,view,+lookups,+heap,mode}:
      p164j_forward_if(function,ready) ++
        nt_choose(String,U32.is_eq(mode,2),u => p126i_emit_one(function,lookups,ids,heap),u => p113e_private(function,ids))

@unsafe
def p164j_summary(emission: P111Emission) -> String:
  match emission:
    case P111Emission{chunks,error}: "error=" ++ error
    case P134Planned{P134Admitted{P113AProgram{P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,names,effects,pure},nodes},+functions},certificate}}}:
      "segments=" ++ U32.show(nt_count(N111Segment,segments)) ++
        ";direct=" ++ U32.show(nt_count(P113DFunction,functions)) ++
        ";imports=" ++ U32.show(p164j_import_count(p164j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))
    case _: "error=unexpected plan"

def p164j_import_count(registry: P112RegionRegistry) -> U32:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}: workers
