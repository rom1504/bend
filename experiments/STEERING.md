# Current frontier: Phase106 native IR research loop

[Report and diagrams](../implementation/phase106/README.md) ·
[Design](../design/phase106/native-ir-research-loop.md) ·
[Replay](../selfhost/tools/performance/phase106/README.md) ·
[Evidence](../implementation/phase106/evidence/README.md).

All five requested bounded experiments are complete. The installed native compiler
and candidate04 selection are unchanged. A Bend-written typed IR, verifier, folding
and C/JSON emitters now drive C and pinned Cranelift AOT consumers. This is directly
constructed workload IR, including two real lexical algorithms, not full KTerm
lowering or a new production backend. The public CLI remains native Bend.

Current full-self sampling:142.160s, exact output. `term_drop`, shared-field
ownership (`span_fade`) and string equality total72.94% of leaf samples. A separate
clean current-recipe Clang image build takes375.644s and reproduces selected B2.
These are single observations, not new repeated compiler-latency ratios.

The8-workload/5-profile/3-round matrix finds10–17× faster Cranelift object generation,
but runtime ranges from parity to5.6× C O2. Linking narrows the construction gain.
The training-selected k=1 policy fails to improve repeated-batch cost at new training
sizes (1.024×), while held-outs improve (0.767×). Fresh one-shot build/check component
cost estimates are0.476×/0.504× training/held-out; supervision and reusable-tool
acquisition are separate. Ten/hundred-batch training selects C O2. No general
policy promotion and no claim of recursive research acceleration.

Thirteen named laws constrain the actual safe folding helper and pass independent
checking; four admitted semantic mutants fail unchanged source contracts. Final
controls include1992 native outputs and996 independent interpreter observations.
Recursive traversal, memory, emitters, runtime and full compiler correctness remain
outside the theorem. Source checks are cheap; the accepted independent kernel run
is41.440s. Authenticate/reuse unchanged proof evidence instead of repeating it for
backend-only edits.

## Best next bounded investigation, when requested

The planned [Phase107 three-hour ambition ladder](../design/phase107/native-ir-ambition-ladder.md)
defines 1× real-source integration, 10× reusable native compilation, and 100×
incremental self-hosting/research goals. It includes bounded extensions and
evidence gates; implementation has not started. Ambition labels are not speedups.

Implement size/depth-bounded inlining of small pure direct helpers in Bend IR,
with a semantic contract and unrelated held-out helpers. Static inspection finds
128 retained helper boundaries and two classifier calls per scanned character
that Clang removes. This is concrete evidence for inexpensive shared optimization;
it does not justify implementing an entire new machine backend immediately.

Separately design borrow summaries for live owners, following the full compiler's
ownership profile. The synthetic shared/borrowed pair alone cannot justify a
production ownership transformation. Persistent/batched supervision and eventually
JIT/link reuse address now-visible fixed experiment costs. Keep defaults and exact
results until real lowering, ABI, conformance and self-hosting gates are met.

Root serializes substantial target work on CPU3 under guards. Offline agents can
prepare/review disjoint work; avoid parallel large builds, disk exhaustion and
repeating full-self/broad45 gates for small IR changes. Preserve every failed
attempt, tool cost, selection input and held-out distinction. No PR comments
without explicit authorization.

## Established production comparisons remain separate

[Phase105](../implementation/phase105/README.md) remains the current B1/B2-versus-
upstream comparison: prepared broad45 ratios0.499×/0.517×, live-Base2.384×/2.231×;
full-source prepared2.602×/2.965×. Phase106 does not replace those metrics or the
existing generated-program/conformance qualification. See the
[preceding steering](https://github.com/rom1504/bend/blob/c2ef383/experiments/STEERING.md)
for exact historical scope and the [ledger](ledger.md) for earlier phases.
