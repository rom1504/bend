# Private successor of this request's ORIGINAL p140v_open. A nonempty opened
# cache was published only after raw, static-image and direct verification.
# The sole production caller is p140b_lowered below. It cannot import a cache
# independently of p140b_opened/p140b_optimized. Diagnostic APIs are test-only.
# The optimizer supplies only functions/certificate; the original bundle is
# taken from the held first judgment, never from the successor argument.

@unsafe
def p142sr_array(+program: P113AProgram, opened: P140VCache, +previous: P140VCache) -> P140VArrayChecked:
  match opened:
    case P140VEmpty{}: p140v_array(program,previous)
    case P140VCache{P113DProgram{original,functions},metadata}:
      p142sr_held(program,original,metadata,previous)

@unsafe
def p142sr_held(program: P113AProgram, original: P112StaticProgram, metadata: P140VMetadata, previous: P140VCache) -> P140VArrayChecked:
  match program:
    case P113AProgram{P113DProgram{discarded,functions},certificate}:
      p142sr_current(P113AProgram{P113DProgram{original,functions},certificate},metadata,previous)

@unsafe
def p142sr_current(+program: P113AProgram, metadata: P140VMetadata, previous: P140VCache) -> P140VArrayChecked:
  match program:
    case P113AProgram{direct,certificate}:
      p142sr_reuse(program,metadata,p140v_reuse(direct,previous))

# Keep the previous ARRAY cache's exact ordered raw-context/direct-header
# admission. First-check direct bodies need not equal optimized warm bodies.
# Metadata and IDs are current first-check products, not prior-request facts.
@unsafe
def p142sr_reuse(+program: P113AProgram, +metadata: P140VMetadata, reuse: P140VReuse) -> P140VArrayChecked:
  match program metadata reuse:
    case P113AProgram{P113DProgram{original,+functions},certificate}
      P140VMetadata{P111VScan{fs,fe,count},cs,+ids}
      P140VReuse{segments,old,raw,direct,prior_metadata}:
        p140v_array_done(program,p140v_publish(P113DProgram{original,functions},metadata,ids,count,0,
          p140v_direct_walk(old,functions,ids,missing(),direct,0,0)))

# The downstream emitter also receives the held original. No successor
# original is verified and then substituted independently during emission.
@unsafe
def p142sr_successor(+program: P113AProgram, opened: P140VCache) -> P113AProgram:
  match opened:
    case P140VEmpty{}: program
    case P140VCache{P113DProgram{original,prior},metadata}:
      p142sr_attach(program,original)

@unsafe
def p142sr_attach(program: P113AProgram, original: P112StaticProgram) -> P113AProgram:
  match program:
    case P113AProgram{P113DProgram{discarded,functions},certificate}:
      P113AProgram{P113DProgram{original,functions},certificate}

@unsafe
def p142sr_closed(request: NR_Request, raw: List<&2,P113DCandidate>, +opened: P140VCache,
    optimized: P134UCache, array: P140VCache, late: P140LCache, stats: List<&2,U32>, +program: P113AProgram) -> P140BResult:
  p140b_array(request,raw,program,opened,optimized,late,stats,p142sr_array(program,opened,array))

# This is the only override. Both lowering-error and absent-first-judgment
# fallbacks retain the old path. The first verifier, direct verifier, array
# and transport namespace checks, late hooks and final gate are unchanged.
@unsafe
def p140b_lowered(+request: NR_Request, +raw: List<&2,P113DCandidate>, +opened: P140VCache,
    +optimized: P134UCache, +array: P140VCache, +late: P140LCache, +stats: List<&2,U32>, lowered: P113ALowering) -> P140BResult:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P140BResult,String.is_empty(error),
        u => p142sr_closed(request,raw,opened,optimized,array,late,stats,p142sr_successor(program,opened)),
        u => P140BResult{P111Emission{[],"array native lowering: " ++ error},P140BCache{opened,optimized,array,late},stats})
