# Test-only full conservation check. Do not use p134v_boundary_same: it ignores
# original/IDs. Include bodies, every metadata list, effects and static words.
type P142SRDiagnostic is Data:
  P142SRDiagnostic{+checked: P140VArrayChecked, +original_same: Bool}

@unsafe
def p142sr_original(a: P112StaticProgram, b: P112StaticProgram) -> Bool:
  match a b:
    case P112StaticProgram{P111Program{as,ac,ash,asn,ae,ap},an}
      P112StaticProgram{P111Program{bs,bc,bsh,bsn,be,bp},bn}:
        p134v_list(~N111Segment,~p140v_segment,as,bs) &&
        p134v_list(~N_Constructor,~p140v_ctor,ac,bc) &&
        p134v_list(~U32,~U32.is_eq,ash,bsh) &&
        p134v_list(~String,~String.eq,asn,bsn) &&
        p134v_list(~String,~String.eq,ae,be) &&
        p134v_bool(ap,bp) && p140or_nodes(an,bn)

@unsafe
def p142sr_diagnose(+program: P113AProgram, +opened: P140VCache, previous: P140VCache) -> P142SRDiagnostic:
  match opened:
    case P140VEmpty{}: P142SRDiagnostic{p142sr_array(program,opened,previous),True{}}
    case P140VCache{P113DProgram{original,functions},metadata}:
      p142sr_diagnostic_original(program,opened,previous,original)

@unsafe
def p142sr_diagnostic_original(+program: P113AProgram, +opened: P140VCache, +previous: P140VCache, original: P112StaticProgram) -> P142SRDiagnostic:
  match program:
    case P113AProgram{P113DProgram{now,functions},certificate}:
      nt_choose(P142SRDiagnostic,p142sr_original(original,now),
        u => P142SRDiagnostic{p142sr_array(program,opened,previous),True{}},
        u => P142SRDiagnostic{P140VArrayChecked{P140VEmpty{},"same-request original conservation mismatch",[0,0,0,0]},False{}})

# Exercise actual original first-check/optimization transport, including its
# rollback choices. This is a diagnostic root, not an alternate admission API.
@unsafe
def p142sr_optimize_diagnostic(program: P113DProgram, previous: P140VCache, optimized: P134UCache, certificate: P113ACertificate) -> P142SRDiagnostic:
  p142sr_diagnostic_opened(optimized,certificate,p140v_open(program,previous))

@unsafe
def p142sr_diagnostic_opened(optimized: P134UCache, certificate: P113ACertificate, opened: P140VOpened) -> P142SRDiagnostic:
  match opened:
    case P140VOpened{boundary,cache,counts}:
      p142sr_diagnostic_optimized(cache,certificate,p134u_optimize(boundary,optimized))

@unsafe
def p142sr_diagnostic_optimized(opened: P140VCache, certificate: P113ACertificate, optimized: P134UOptimized) -> P142SRDiagnostic:
  match optimized:
    case P134UOptimized{boundary,cache,stats}:
      p142sr_diagnose(P113AProgram{p114s_close(boundary),certificate},opened,P140VEmpty{})
