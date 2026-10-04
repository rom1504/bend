# Map discriminator implementation

Prepared tools only. Python syntax compilation and four saved-module generation
attempts were performed without executing target JS, compiling Bend or profiling.
The first three static attempts exposed dependency resolution issues: runtime
native definitions precede conditional generated fallbacks; the final preparer
resolves those native overrides and the dynamic scalar native families. Retain
raw static attempts in Phase43 if recording tool transcripts. No historical file
was modified and no performance/correctness pass is claimed.

Files: `selfhost/tools/performance/phase43/map/prepare.py`, `worker.mjs`,
`controls.mjs`, `fixture.bend`. Fresh output directory required. Three modules
contain an unchanged original public G API and diagnostic exports. Saturated
internal Map calls are rewritten; the selected scalar root is wrapped once.
The whole role replaces set/del internal graphs with iterative seek/put/ins/pop;
the amortized role only replaces Map.bit callsites. Off-path Map constructor
reconstruction and full key tuples are retained. Generic String.cmp/Map.diff
remain residual. Every wrapper closes its active state in finally.

Root commands (NODE is root's pinned Node executable):

```sh
python3 selfhost/tools/performance/phase43/map/prepare.py \
  selfhost/build/phase42/map-native-ablation01/baseline.mjs \
  selfhost/build/phase43/map-whole01 --root bench
NODE --max-old-space-size=256 selfhost/tools/performance/phase43/map/controls.mjs \
  selfhost/build/phase43/map-whole01 selfhost/build/phase43/map-controls01
```

Run controls serially under root's60s resource limit; expected10–40s, unmeasured.
Controls compare eight complete ordered content/pop results including literal
empty/prefix/NUL/update/absent/delete keys, five full benchmark scalar results,
one12000-node deep seek/put/pop result, all reachable binding/getter/throw/bounded
reentry boundaries, and native codePointAt/slice/fromCodePoint return/throw/reentry
traces. All hostile boundaries require zero new entries and identical complete
observations, and all paths require regionProof inactive. Admission counters must
show active bit and whole-operation paths. Raw report captures module identities,
checksums, complete counts and dependency closure. Only after controls pass use
root's existing exact Map32/128 timing commands serially for all three roles,
retaining every sample under a fresh Phase43 directory. Preparation/manifests and
controls are small durable tools; generated modules are regenerable from the
specified preserved Phase42 input and hashes.

JS syntax checking could not use bare `node` because it is absent from PATH;
root must use the pinned runtime. This remains unchecked saved-output research.
Source integration, B1, broad conformance and promotion remain separate gates.

Independent review found a String.prototype marker hole in the first worker.
Repaired before execution: admission now compares the entire own-name/descriptor
snapshot and prototype chain, not just selected String methods. Eighteen
request/bounce/build/code/io/typeName getter/throw/reentry controls were added.
The latest static preparation also succeeds; target controls remain root-owned.

Root's first actual controls fail in the original module at12000-node
`Map.seek.go` non-tail descent, despite4MiB native stack. Preserve
`selfhost/build/phase43/run-map-controls01/stderr.log` and unchanged
`controls-v1.mjs`. `controls-v2.mjs` keeps all ordinary cases strict and adds
strict128-depth threeway comparison. The12000stress separately requires whole
completion against a complete independent oracle; original/amortized may record
only the exact named RangeError as unsupported generic depth. Successful stress
results must also match the independent oracle. No normal mismatch is waived.

Concrete unchecked source artifacts now exist in
`selfhost/tools/performance/phase43/map/source02/map-ground.patch`; generator
`make-source-patch.py` and literal helper `map-ground.bend` retain regeneration.
They add exact native Map<&2,scalar> owner/constructor/full-field/terminal type
proofs, specialization equality, private local admission and generic Map matcher
admission. They preserve existing ctor ABI and do not select benchmark names.
This patch is a reusable typed prerequisite, not complete whole-Map admission:
Map helpers retain two erased prefixes which current JPure/component checks
refuse. Generic bounded contextual erased specialization is the next required
implementation; source String, exact qty2 Sigma and Maybe support also precede
whole graph qualification. No build or runtime pass is claimed for these bytes.

Bounded erased-specialization implementation is staged as actual Bend helpers in
`erased-instance.bend` and append-only `erased-instance.patch`. It produces a
separate `JErasedInstance` fact from a saturated original source call and checks
at most4 concrete erased prefix arguments, their exact kinds, and no uses of
those binders in runtime value positions. The runtime scan ignores annotations'
type children and only known saturated callees' erased slots. Operational body
normalization is forbidden; substitution keeps the original body/evaluation
order. Facts retain the canonical original Def, full exact argument/domain and
both binder identities, residual body/type and original null-prefix ABI offset.
Shared8192fuel bounds the scan across prefix arguments.

These helpers are not wired into JPure, JSPlanContext or actual clone emission.
Their explicit original identity and complete slot rows must key contextual
instances; residual callees each need their own exact substitution and original
G guard. Ordinary name lookup/exact_def cannot authorize a specialized body.
Production qualification must audit actual emitted closure, cap distinct instances
with shared aggregate fuel, then run supported-host/deep controls. This is a
concrete partial implementation, not a completed whole-Map compiler optimization.
