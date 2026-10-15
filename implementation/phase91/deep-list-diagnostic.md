# Phase91: a pre-existing B2 diagnostic depth gap

The fresh installed-B2 frontend census finished all 3,174 observations in
229.828 seconds. It matches the retained, identity-verified TypeScript reference
on 3,173 observations. The only difference is the check observation for
`page/deep_list_walk.bend`: both compilers correctly reject the false proof,
but B2 loses the detailed error page. The four shared check-oracle exceptions
remain; the current check lane has 1,582 passes and five failures.

The fixture constructs a 3,000-deep `LC{...}` chain and tries to prove it equal
to `LN{}`. Its purpose is to exercise printing a deeply computed error. The
reference's diagnostic is 12,119 characters; B2 returns the 57-character
fallback `SOME PROOFS FAIL\nError: thm: reflexivity endpoints differ`.

Root then ran isolated controls with the same fixture, Node, 4 MiB stack and
1 GiB heap. [The offline audit](deep-diagnostic-audit01.json) verifies each
completed guarded command, source/API binding, report inputs and retained trace.

| Producer | API SHA prefix | Golden diagnostic | Diagnostic length | Trace |
|---|---|---|---:|---|
| Current checked B1 | `6bf8e093…` | Pass | 12,119 | No rendering overflow |
| Current installed B2 | `284f6e9b…` | Fail | 57 | Maximum call stack size exceeded |
| Preserved Phase82 B2 | `098320e8…` | Fail | 57 | Maximum call stack size exceeded |
| Pinned TypeScript | Reference source pin `0592662…` | Pass | 12,119 | No rendering overflow |

All four return a checked rejection with `typeAccepted:false` and exit1 for
the program. The harness exits0 for exact golden diagnostic passes and exits1
for mismatches. These isolated observations establish a pre-existing B2
diagnostic-fidelity gap, not a Phase90 native-backend regression or acceptance
of an invalid proof. The old and current B2 fallbacks are byte-identical; the
current B1 and TypeScript detailed diagnostics are also byte-identical.

`typed-driver.mjs:773–783` catches exceptions from provenance/diagnostic
rendering, traces the exception and returns the concise checker error. Both
B2 traces explicitly record `diagnostic rendering unavailable: Maximum call
stack size exceeded`. The full frontend run therefore stays alive, but its
golden diagnostic comparison correctly fails. This must remain a conformance
failure; increasing the stack just for this fixture would hide the measured gap.

Static inspection nominates the recursive constructor printer. `dg_expr` calls
`kp_go(strong(...))`; `graph_strong` already uses an explicit normalization-frame
stack. Rendering each ordinary constructor traverses `kp_go`, constructor
classification helpers, `kp_ctor_array`, `kp_each`, then another `kp_go` for
its child. The current B2 emits direct JS calls along these links and a
10,672-byte `kp_go$scc` body with 89 `const` declarations. B1's generated choices
include trampoline boundaries that unwind several links. These are source-shape
observations, not measured frame sizes or proof of the precise overflowing
helper. The caught trace does not include that helper's stack trace.

The kernel, normalizer, pretty-printer and three relevant diagnostic modules
audited here are byte-identical to the Phase66 Bend snapshot that passed this
fixture. That supports investigating stage-dependent generated call depth.
No compiler source or acceptance rule was changed during this refresh.

Reproduce the data-only audit into a fresh file:

```sh
taskset -c 0 python3 -B implementation/phase91/deep-diagnostic-audit.py --output /tmp/phase91-deep-diagnostic-recheck.json
```

The original strict collector remains frozen. Its failed qualification must be
retained. The separate `collect-conformance-v2.py` records `complete:true` for a
fully verified measurement and `passed:false` for the actual conformance gap;
it retains the exact differing fields and does not waive them.
