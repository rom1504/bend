# Optional restoration of the maintained source-authorized mode2 renderer.
# The actual request derives its certificate; no workload/name selects a mode.

@unsafe
def p169a_seeded(+program: P111Program, +nodes: List<&2,P112SNode>,
    +functions: List<&2,P113DFunction>, +live: Bool, arrays: Bool) -> P169Prepared:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +enabled = arrays && Bool.not(List.is_empty(&2,P113DFunction,functions))
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,
        u => nt_choose(U32,enabled,v => 2,v => 1))
      +tables = nt_choose(List<&2,P111QData>,enabled,u => p117p_tables(tables,[]),u => tables)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p169s_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,p118c_tables(tables),
        p168j_registry(segments,index,p168j_imports(segments,p113e_signatures(functions,missing()),
          P112RegionRegistry{missing(),missing(),[],0,0})))

@unsafe
def p169a_namespace(+original: P111Program, +nodes: List<&2,P112SNode>,
    +view: List<&2,P113DFunction>, +certificate: P113ACertificate) -> String:
  +direct : P113DProgram = P113DProgram{P112StaticProgram{original,nodes},view}
  p114t_verify_done(P113AProgram{direct,certificate},p113a_verify_after(direct,certificate,""))

@unsafe
def p169a_emitted(original: P111Program, nodes: List<&2,P112SNode>,
    view: List<&2,P113DFunction>, live: Bool, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169a_seeded(original,nodes,view,live,True{}),
    u => p169s_fail("adapter imports view verification: " ++ error))

@unsafe
def p169a_checked(request: NR_Request, adapters: KDef, +program: P113DProgram,
    +original: P111Program, +nodes: List<&2,P112SNode>, +view: List<&2,P113DFunction>,
    +certificate: P113ACertificate, +error: String) -> P169Prepared:
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}:
      nt_choose(P169Prepared,String.is_empty(error),u =>
        nt_choose(P169Prepared,p113a_enabled(certificate),
          v => p169a_emitted(original,nodes,view,p167live_eligible(program),
            p169a_namespace(original,nodes,view,certificate)),
          v => p169s_seeded(original,nodes,view,p167live_eligible(program))),
        u => p169sv_refused(error,p167ob_final(book,nc_bangs_names(book,names),adapters,program)))

@unsafe
def p169a_view(+request: NR_Request, +adapters: KDef, +program: P113DProgram) -> P169Prepared:
  match program:
    case P113DProgram{P112StaticProgram{+original,+nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p169a_checked(request,adapters,program,original,nodes,view,p113a_certificate(request),
        p118b_verify_functions(view,original))

@unsafe
def p169a_original(request: NR_Request, adapters: KDef, +program: P113DProgram,
    +error: String) -> P169Prepared:
  match program:
    case P113DProgram{original,+functions}:
      nt_choose(P169Prepared,String.is_empty(error),u =>
        nt_choose(P169Prepared,p167v_private(functions),
          v => p169a_view(request,adapters,program),
          v => p169s_fail("adapter renderer original final IR: observer first final worker must be private")),
        u => p169s_fail("adapter renderer original final IR: " ++ error))

# Sole override. Keep actual source/generic/static/adapter/private and complete
# borrowed/direct verification. Extra namespace checks precede mode2 emission.
@unsafe
def p169s_lowered(+request: NR_Request, lowered: P167Lowered) -> P169Prepared:
  match request lowered:
    case NR_Request{source,+book,names,paths,scope,bound} P167Lowered{+program,+adapters,+error,stats}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169a_original(request,adapters,program,
          p167v_original(book,nc_bangs_names(book,names),program,adapters)),
        u => p169s_fail("adapter renderer lowering: " ++ error))
