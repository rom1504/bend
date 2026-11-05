# Explicit adapter imports have rank zero; normal registry entries start at one.
# No invented worker plan or generic segment is supplied to the old analyzers.
@unsafe
def p164r_imports(segments: List<&2,N111Segment>, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: registry
    case Con{+head,rest}:
      p164r_imports(rest,nt_choose(P112RegionRegistry,p164a_shape(head),
        u => p164r_import(head,registry),u => registry))

@unsafe
def p164r_import(segment: N111Segment, registry: P112RegionRegistry) -> P112RegionRegistry:
  match segment registry:
    case N111Segment{+name,+arity,result,incoming,flags,body} P112RegionRegistry{ready,symbols,entries,workers,fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,0),
        p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,0),entries,U32.inc(workers),fusions}

# Experimental override, used only after p164h's final mixed gate.
@unsafe
def p134e_prepare(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>, +arrays: Bool, live: Bool) -> P134Cursor:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +generic = p164a_generic(segments,[])
      +index = p112f_index(generic)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,
        u => nt_choose(U32,arrays,v => 2,v => 1))
      +tables = nt_choose(List<&2,P111QData>,arrays,u => p117p_tables(tables,[]),u => tables)
      +tables = nt_choose(List<&2,P111QData>,Bool.not(List.is_empty(&2,P113DFunction,functions)) && p118z_segments(generic) && p118z_functions(functions),
        u => p118z_tables(tables),u => tables)
      p134e_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),
        p112c_passes(p112c_candidates(generic,[]),index,
          p164r_imports(segments,P112RegionRegistry{missing(),missing(),[],0,0}),1,6))

@unsafe
def p164r_forward(+name: String, +arity: U32) -> String:
  "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ") {\n@entry\n" ++
  "%p164_forward =l call $" ++ p113e_symbol(name) ++ "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\nret %p164_forward\n}\n"

@unsafe
def p164r_forward_if(function: P113DFunction, ready: KDef) -> String:
  match function:
    case P113DFunction{+name,+params,result,public,body}:
      +entry = p111v_get(ready,name)
      nt_choose(String,String.eq(dk(entry),"P112Worker") && U32.is_eq(dx(entry),0),
        u => p164r_forward(name,nt_count(NC_Binding,params)),u => "")

# Imported p112w symbols are real ordinary-call forwarders, not scheduler calls.
# The final boxed body still uses the existing array/lookup-aware emitter.
@unsafe
def p134e_private(+function: P113DFunction, context: P134Context) -> String:
  match context:
    case P134Context{+ids,index,direct,ready,view,+lookups,+heap,mode}:
      p164r_forward_if(function,ready) ++
        nt_choose(String,U32.is_eq(mode,2),u => p126i_emit_one(function,lookups,ids,heap),u => p113e_private(function,ids))
