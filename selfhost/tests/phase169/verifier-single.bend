# Optional private Phase169 successor: original/static/adapter admission and
# private-input discipline stay unchanged. The SAME flag-only renderer view
# receives the full unchanged borrowed/direct body verifier exactly once.
# Public flags only add the existing original-wrapper ABI obligation; body
# projection and dependency-call contracts do not consume signature public bits.
# No producer certificate, body hash or trusted Boolean replaces verification.

@unsafe
def p169sv_refused(+view_error: String, +original_error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(original_error),
    u => p169s_fail("adapter imports view verification: " ++ view_error),
    u => p169s_fail("adapter renderer original final IR: " ++ original_error))

# Cold failure path deliberately repeats the frozen original checker, preserving
# its first error and old prefix even when public ABI checking fails earlier.
@unsafe
def p169sv_checked(book: List<&2,KDef>, bangs: List<&2,String>, adapters: KDef,
    +program: P113DProgram, original: P111Program, nodes: List<&2,P112SNode>,
    view: List<&2,P113DFunction>, +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169s_seeded(original,nodes,view,p167live_eligible(program)),
    u => p169sv_refused(error,p167ob_final(book,bangs,adapters,program)))

@unsafe
def p169sv_view(book: List<&2,KDef>, bangs: List<&2,String>, +adapters: KDef,
    +program: P113DProgram) -> P169Prepared:
  match program:
    case P113DProgram{P112StaticProgram{+original,nodes},functions}:
      +view = p168v_functions(functions,adapters)
      p169sv_checked(book,bangs,adapters,program,original,nodes,view,
        p118b_verify_functions(view,original))

@unsafe
def p169sv_original(book: List<&2,KDef>, bangs: List<&2,String>, adapters: KDef,
    +program: P113DProgram, +error: String) -> P169Prepared:
  match program:
    case P113DProgram{original,+functions}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => nt_choose(P169Prepared,p167v_private(functions),
          v => p169sv_view(book,bangs,adapters,program),
          v => p169s_fail("adapter renderer original final IR: observer first final worker must be private")),
        u => p169s_fail("adapter renderer original final IR: " ++ error))

@unsafe
def p169sv_prepare(+book: List<&2,KDef>, +bangs: List<&2,String>, +adapters: KDef,
    +program: P113DProgram) -> P169Prepared:
  p169sv_original(book,bangs,adapters,program,
    p167v_original(book,bangs,program,adapters))

# Sole experimental override. Lowering, scalar composition, source permission,
# exact public-view construction and streaming/registry emission are unchanged.
@unsafe
def p169s_lowered(request: NR_Request, lowered: P167Lowered) -> P169Prepared:
  match request lowered:
    case NR_Request{source,+book,names,paths,scope,bound} P167Lowered{program,adapters,+error,stats}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169sv_prepare(book,nc_bangs_names(book,names),adapters,program),
        u => p169s_fail("adapter renderer lowering: " ++ error))
