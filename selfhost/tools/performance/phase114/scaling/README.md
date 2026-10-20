# Reuse verification across immutable optimization stages

This optional candidate changes the placement of redundant checks. Product
planning, the inliner, bottom-up range processing, the final range pass, array
certification, and machine emission retain their selected source31 bodies.
There is no new unchecked public renderer or caller-supplied certificate path.

The factory first checks the original generic/static program and the direct
functions. It retains that immutable original and the exact original-function
and constructor indices. An optimization can supply only a new function list.
The existing direct verifier checks that list against the retained indices;
rejection restores the previous valid list. Closing the session produces an
ordinary `P113DProgram`. The existing final `p113a_verify` still checks the whole
program and private array namespace before any admitted rendering.

On the valid two-pass path, checks inside lowering change as follows:

| Check | Source31 | Candidate |
| --- | ---: | ---: |
| Original generic/static program | 4 | 1 |
| Direct function lists | 4 | 3 |
| Final public whole-program gate | 1 | 1 |

The initial direct check and both transformation postchecks remain. The input
to the range pass is precisely the list accepted by the inliner postcheck, or
the previously accepted list after rollback. Neither transformation changes
the original generic program, static image, or identifier tables.

An initially invalid program is returned unchanged, as in source31; the final
gate retains its diagnostic. A pre-existing lowering error is preserved and
skips session validation/transformation. Failure of an optimizer postcheck
retains the prior valid program, then allows the next original pass to run.
This is source reasoning about existing fallback behavior, not a new custom
failure experiment.

`P114SBoundary` is an internal data record, not an unforgeable proof type. Its
constructor and diagnostic exports do not authorize emission. Production only
constructs it through the factory, and the final normal verifier accepts the
resulting ordinary program. Serialized sessions, mutable host records,
cross-request session reuse, and arbitrary certificate claims are not supported.

## Compose and qualify

Append `model.bend`, `boundary.bend`, `stages.bend`; optionally append
`controls.bend`. The only production replacement is `overrides.bend`, replacing
`p113d_lower_request` with `p114s_lower_request`. Do not replace any verifier or
renderer. `modules.json` pins these files and the exact source31 entry replaced.

Useful exports are `p114s_control_report` (18 positive finite observations),
`p114s_control_request`, and the four `p114s_*_lowered` stage functions below.
The finite examples cover empty/identity graphs, scalar and vector ordinary
calls, branches, self-tail loops, and a public main wrapper. They compare the
complete QBE text of original and cached pipelines and check both whole
programs. They are structural examples, not a source ownership proof. Separate
ordinary checked-source controls cover actual compiler lowering and stdout.

No target result or speedup is claimed by this source snapshot. First compare
exact QBE and complete ordinary-source outputs; then time the same sources.
The first bottleneck may still be product planning before any verification.

## Split baseline without changing source31

`staged-emit.mjs` derives from the frozen Phase113 staged emitter. Run it with
an API built from unchanged source31 and additional exported existing helpers:

```
staged-emit.mjs API INPUT FRESH_OUT cache array baseline
```

Required common exports: `p88_cache_prepare`, `p86_prepare`, `p86_plan`,
`p111_runtime_admission`, `p113pl_lower_request`, `p113a_certificate`,
`p113a_finish`, `p113a_verify`, `p113a_admitted_chunks`.
Baseline additionally needs `p113i_lowered`, `p113k_lowered`.

It runs the frontend once and separately times array certification, product
lowering, inlining including its existing checks, and ranges including their
existing checks. It then uses the unchanged final verifier and admitted
renderer on the same in-memory program. No graph is serialized between stages.
Function counts are metadata observations outside the compiler-stage timers.

After compiling the optional modules, substitute `cached` as the last argument.
Its extra exports are `p114s_open_lowered`, `p114s_inline_lowered`,
`p114s_ranges_lowered`, `p114s_close_lowered`. It records the factory separately
and times each pass with its remaining direct-function postcheck. The same
normal final verifier and renderer follow. Fresh outputs under phase111 or
phase114 are accepted; each output preserves a method snapshot and report.

The host implements transport, timestamps, metadata counts, authentication,
and exact chunk writes only. All planning, transformation, and validation
remain Bend. Root owns API acquisition and target execution.
