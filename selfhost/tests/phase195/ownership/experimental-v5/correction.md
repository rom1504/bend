# V5 correction: use the selected source's actual lowering result

Preserved API03 failure:
`selfhost/build/phase195/owned-diagnostic-api03/stderr` rejects P113ALowered at
frozen `owned-diagnostic-api-source03/compiler.bend:53198`. The constructor is
real in maintained `src/back/qbe/model.bend`, but it and its legacy diagnostic
entry were removed from the selected Phase194 compiler closure. The earlier
prototype incorrectly assumed that full maintained-source declarations remained
available when appending modules to that selected snapshot.

Static resolution found exactly five unavailable references in v4:
P113ALowering, P113ALowered, p113a_lower_request, p128br_summaries and
p128bs_original. V5 removes that bridge rather than copying historical helpers.
It calls the selected source's p168_request_mode(1,request), matches the actual
P167Lowered{P113DProgram{static,functions},adapters,error,stats}, and uses the
existing p128br_scan / P128BROpen interface to obtain checked observer summaries.
Original runtime admission remains in p195od_checked; original lowering and
observer errors both terminate the diagnostic without admitting a plan. All
outcomes still retain the original implementation; there is no emitter hook.

Only proof.bend changes among the four Bend source files. This adds one small
bridge helper and changes no ownership/layout/origin admission rule. V1–v4 and
all acquisition failures remain immutable.

`audit-symbols.py` checks references against exact selected-source02 plus pinned
Base and local declarations. Its receipt reports277 distinct references,
1,340 lexical call sites and365 constructor sites, with no unknown references or
explicit argument-count mismatches. Constructor/type/function declaration origins
and input hashes are recorded. It includes the unrelated BST fixture as a
separate source book. This preflight is lexical, not a substitute for compiler
name resolution or type/affine checking.

The additional preflights report149 declarations with balanced delimiters and
valid header/annotation adjacency, and89 parameter/field match sites with zero
flags. No compiler or target jobs ran in this subagent. Checked API acceptance
and actual Map/BST proof outcomes remain outstanding.
