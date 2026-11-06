# Optional same-request cold metadata restoration after the existing full
# verifier and array/transport namespace gates. No emitted body or ID changes.
@unsafe
def p169c_scalar(certificate: P113ACertificate) -> Bool:
  match certificate:
    case P113ACertificate{scalar,unshared}: scalar

@unsafe
def p169c_selected(+request: NR_Request, +admitted: P113AProgram) -> P113AProgram:
  match admitted:
    case P113AProgram{program,certificate}:
      nt_choose(P113AProgram,p169c_scalar(certificate),
        u => p118c_apply_plan(admitted,p118c_plan(request)),u => admitted)

@unsafe
def p169c_output(admitted: P113AProgram, +live: Bool) -> P169Prepared:
  match admitted:
    case P113AProgram{P113DProgram{P112StaticProgram{+original,+nodes},+view},certificate}:
      nt_choose(P169Prepared,p113a_enabled(certificate),
        u => p169a_seeded(original,nodes,view,live,True{}),
        u => p169s_seeded(original,nodes,view,live))

@unsafe
def p169c_emitted(request: NR_Request, admitted: P113AProgram, live: Bool,
    +error: String) -> P169Prepared:
  nt_choose(P169Prepared,String.is_empty(error),
    u => p169c_output(p169c_selected(request,admitted),live),
    u => p169s_fail("adapter imports view verification: " ++ error))

# The certificate is constructed by unchanged p169a_view from this exact
# request. scalar=False implies p118c_plan's ns_definitions permission=False;
# skip only that redundant failed derivation. unshared is not cold authority.
@unsafe
def p169a_checked(+request: NR_Request, +adapters: KDef, +program: P113DProgram,
    +original: P111Program, +nodes: List<&2,P112SNode>, +view: List<&2,P113DFunction>,
    +certificate: P113ACertificate, +error: String) -> P169Prepared:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      nt_choose(P169Prepared,String.is_empty(error),
        u => p169c_emitted(request,P113AProgram{P113DProgram{P112StaticProgram{original,nodes},view},certificate},
          p167live_eligible(program),nt_choose(String,p113a_enabled(certificate),
            v => p169a_namespace(original,nodes,view,certificate),v => "")),
        u => p169sv_refused(error,p167ob_final(book,nc_bangs_names(book,names),adapters,program)))
