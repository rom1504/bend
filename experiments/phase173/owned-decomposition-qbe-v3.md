# Phase173: QBE-only permission variant

Prepared source experiment; execution and timing remain separate gates. Frozen
pure snapshots are unchanged. Pure snapshot06 passed16 structural controls and
found two changed `f_pattern_sub` rows and one unrelated packet row. The
eight-argument layout setter remained refused.

## Boundary and implementation

Replace **only `p168_catalogued`**, using
`owned-decomposition-qbe-v3-entry.bend`. Do not include the v2
`owned-decomposition-entry.bend` replacement. The new hook calls the original
`p112s_prepare` exactly once, then transforms its prepared static facts. The
common static-preparation function, JS/C routes, fixed runtime, ownership
lowering, fallback lowering and final verifiers remain unchanged.

The maintained caller chain is:

```text
p169n_compile -> p169n_prepared -> p86_plan
  -> p169np_plan -> p111_runtime_admission
  -> p169np_admitted -> p168_request_mode
  -> p168_catalogued -> original p112s_prepare -> p173op_prepared
  -> original p168_prepared -> unchanged lowering / final verification
```

The only maintained call of `p168_request_mode` is in `p169np_admitted`, reached
through the fixed-runtime admission above. `p168_request_mode` additionally
checks source errors, mode and the existing source/layout permission.
`p134e_plan` uses a different maintained lowering route and is not silently
modified. Direct calls to internal catalogued/prepared helpers do not establish
the checked-source or authenticated-runtime preconditions. Do not export those
helpers as a new unchecked public compiler entry.

The selected entry does **not** repeat runtime-provider admission. Initially it
retains a conservative extra `no_effect_definitions` certificate, computed with
the existing stack-safe `p118ns_effect_definitions(True{},book,names)` form. Its
per-definition predicate is identical. This permits
authenticated filled IO/File providers but rejects arbitrary foreign code and
`Rwt`. It is a representation-observation boundary, not a claim that workers are
pure. The existing fixed QBE runtime admission is broader. Finite permission
controls and the inspection API explicitly check both predicates; their timing
includes that diagnostic duplication.

The semantic argument is in [owned-decomposition-effects.md](owned-decomposition-effects.md).
The worker still executes once, at the same strict position, with the same
getter value and atomic arguments. Ordinary Data decomposition changes internal
ownership timing. Ignored replacement variants retain the original expression;
unknown summaries retain their original lowering. No uniqueness or worker
purity assumption is introduced.

## Coverage and cost caveats

The old certificate excludes `NativeHost.read/path/publish` and
`File.read_bytes/read_at/write_bytes`, even though the fixed QBE runtime supports
them. The public C CLI uses NativeHost. The selected QBE image instead starts
at `qbe-main.bend -> p111_native_args`; its ordinary request uses
`p169n_request` and ordinary File operations. Mere presence of NativeHost
declarations does not imply they are reachable. The checked reachable-name
census, including session/batch branches and rewrite terms, determines whether
the full QBE compiler passes this conservative gate.

`no_effect_definitions` walks reachable bodies to reject rewrites. This is
additional whole-request work and must be charged, along with the transformation
walk, summary inspection and fresh-ID census. It is an initial scope experiment,
not a proposed permanent repeated analysis. Do not add a second provider census
to the selected entry or report diagnostic time as pass time. If this gate
refuses the real image, preserve the refusal and decide separately whether the
already-authenticated QBE representation contract suffices for that route.

There is stronger existing reuse evidence for the actual File-based compiler:
`p167ob_permission` first tries `ns_definitions`, whose foreign list excludes
File, then calls `p118i_permission`. That calls the stack-safe
`p118ns_effect_definitions`, whose per-definition predicate is the same as
`no_effect_definitions`: native primitive, authenticated filled allowed provider,
or ordinary definition with no rewrite term. Thus when a reachable File provider
causes the first arm to fail, successful existing admission has already
established the very certificate the initial v3 wrapper repeats. A later
qualified implementation should reuse that fact rather than rescan. Do not
generalize this exact predicate equivalence to every scalar first-arm input
without checking its different annotation traversal.

## Assembly and next gates

Reuse the existing summary, transform and structural-control modules, plus the
new v3 module and permission controls. Include the existing
`owned-decomposition-prelude.bend` and new
`owned-decomposition-qbe-v3-prelude.bend` forward contracts. Use the sole
replacement `p168_catalogued`; omit the v2 `p112s_prepare` replacement. Exports
are `p173oa_controls`, `p173op_controls`, `p173op_permission` and
`p173op_inspect_request`, alongside ordinary checked request/compile exports.

First check the source, execute both finite suites and census the small ordinary
IO fixture. Test its changed row, ignored variant, aliases and independent
expected output. Only then census a larger authenticated QBE compiler request. Native
compiled-output checks and runtime measurements remain required before adopting
the wider scope. No full-image qualification is justified by admission counts
alone. No production or installed-selection change is made here.

`owned-decomposition-qbe-v3-observe.mjs` takes `--receipt`, `--assembly`,
`--source` and a fresh `--out`. It authenticates existing source/API/Base/engine
pins, requires the sole `p168_catalogued` replacement, invokes16 structural and16
permission controls, then checks one frozen source and records the three scope
rows plus bounded owner counts. Every semantic predicate and transformation
remains in checked Bend. It performs no emission, native execution or host
compiler analysis. Refused scope is preserved as diagnostic evidence.

## Rejected IO escape proposal

`owned-decomposition-qbe-v3-io.bend` is retained only as a rejected source idea.
Its proposed ordinary worker tried to turn `IO.print(...,R,k)` into a value by
matching `IO.OP` for `Emit` and `Halt`. The upstream implementation explicitly
retains an unmatched request failure in `bend2/comp.ts:1146`: a foreign request
must be interpreted by the runtime IO loop, not a user match. The predicted
five-line normal trace was withdrawn before execution. This was falsified by
source inspection, not a compiler bug or a measured optimization failure.

Use the separately reviewed `owned-decomposition-io.bend` and exact `.stdout`
instead. That gate tests the transformed pure update inside an effectful
program, with retained aliases and an independent genuine IO-worker reference
written using ordinary IO.bind. It does not claim to execute a foreign effect
inside the automatic transform's worker expression.
