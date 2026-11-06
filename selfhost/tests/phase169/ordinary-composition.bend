# Optional bounded ordinary composition BEFORE borrowed-worker conversion.
# Seed and every retry owner remain excluded from table publication. The only
# extra work is ordinary nonblocked p113i_function plus its original table gate.
# Normal entry derives the existing certificate from the actual request; mode2
# is internal only. The public p168_request_mode still admits only modes0/1.

@unsafe
def p169o_next(+original: P113DFunction, rest: List<&2,P113DFunction>, seeds: KDef,
    blocked: KDef, targets: KDef, +table: P113ITable,
    reversed: List<&2,P113DFunction>, +function: P113DFunction) -> List<&2,P113DFunction>:
  p169o_walk(rest,seeds,blocked,targets,
    nt_choose(P113ITable,p113i_original_clean(original),
      u => p113i_table_function(function,table),u => table),Con{function,reversed})

@unsafe
def p169o_walk(functions: List<&2,P113DFunction>, +seeds: KDef, +blocked: KDef,
    +targets: KDef, +table: P113ITable, +reversed: List<&2,P113DFunction>) -> List<&2,P113DFunction>:
  match functions:
    case Nil{}: nt_reverse(P113DFunction,reversed,[])
    case Con{+head,+rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(List<&2,P113DFunction>,p113d_ready(seeds,name),
            u => p169o_walk(rest,seeds,blocked,targets,table,Con{head,reversed}),
            u => nt_choose(List<&2,P113DFunction>,p168t_has(blocked,name),
              v => p169o_walk(rest,seeds,blocked,targets,table,
                Con{nt_choose(P113DFunction,p168t_has(targets,name),
                  w => p168t_target(head,table),w => head),reversed}),
              v => p169o_next(head,rest,seeds,blocked,targets,table,reversed,
                p113i_function(head,table))))

@unsafe
def p169o_selected(functions: List<&2,P113DFunction>, seeds: KDef,
    selection: P168TSelection) -> List<&2,P113DFunction>:
  match selection:
    case P168TSelection{blocked,targets}:
      p169o_walk(functions,seeds,blocked,targets,P113IEmpty{},[])

@unsafe
def p169o_closed(source: List<&2,KDef>, +book: List<&2,KDef>, names: List<&2,String>,
    constructors: List<&2,N_Constructor>, nodes: List<&2,P112SNode>, bangs: List<&2,String>,
    stats: List<&2,U32>, helpers: List<&2,P128BRHelper>, +plans: List<&2,P169ScalarPlan>,
    seeds: KDef, functions: List<&2,P113DFunction>) -> P167Lowered:
  p169q_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,plans,
    p169o_selected(functions,seeds,p169q_selection(book,plans,missing(),missing())))

# New internal mode2 differs only at the protected ordinary-composition step.
# The old mode1 and mode0 bodies are copied exactly from the admission treatment.
@unsafe
def p168_closed(+mode: U32, +source: List<&2,KDef>, +book: List<&2,KDef>, +names: List<&2,String>,
    +constructors: List<&2,N_Constructor>, +nodes: List<&2,P112SNode>, +bangs: List<&2,String>,
    +stats: List<&2,U32>, +helpers: List<&2,P128BRHelper>, +retry: List<&2,NO_Plan>,
    +seeds: KDef, +functions: List<&2,P113DFunction>) -> P167Lowered:
  +stats = nt_append(U32,stats,[nt_count(P113DFunction,functions)])
  nt_choose(P167Lowered,U32.is_eq(mode,2),
    u => p169o_closed(source,book,names,constructors,nodes,bangs,stats,helpers,
      p169q_plans(book,retry),seeds,functions),
    u => nt_choose(P167Lowered,U32.is_eq(mode,1),
      v => p169q_closed(source,book,names,constructors,nodes,bangs,stats,helpers,
        p169q_plans(book,retry),seeds,functions),
      v => p168_inlined(source,book,names,constructors,nodes,bangs,stats,helpers,retry,functions)))

@unsafe
def p169o_certified(+mode: U32, certificate: P113ACertificate) -> U32:
  nt_choose(U32,U32.is_eq(mode,1) && p113a_enabled(certificate),u => 2,u => mode)

# Do not authorize this from the later prepared book, a workload name or a
# caller-supplied certificate. Invalid public modes fail before any lowering.
@unsafe
def p168_request_mode(+mode: U32, +request: NR_Request) -> P167Lowered:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P167Lowered,U32.is_gt(mode,1),u => p167l_fail("early scalar mode must be 0 or 1"),u =>
      nt_choose(P167Lowered,String.is_empty(error),u =>
        nt_choose(P167Lowered,p167ob_permission(request),
          v => p168_catalogued(nt_choose(U32,U32.is_eq(mode,1),
            w => p169o_certified(mode,p113a_certificate(request)),w => mode),
            source,book,names,nc_add_ctors(nc_default_ctors(),
              p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
          v => p167l_fail("early scalar source permission refused")),
        u => p167l_fail("early scalar request: " ++ error)))
