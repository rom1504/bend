# Map discriminator implementation

This owner prepared tools and source patches; root executed saved-JS controls and
timing serially. Python syntax compilation and saved-module generation attempts
were performed by this owner without target execution, builds or profiling.
The first three static attempts exposed dependency resolution issues: runtime
native definitions precede conditional generated fallbacks; the final preparer
resolves those native overrides and the dynamic scalar native families. Retain
raw static attempts in Phase43. Historical files remain unchanged. Root controls
and mechanism timing results below concern saved output, not compiler admission.

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

The initial helpers were unintegrated; source04 now wires them into JPure,
JSPlanContext instance rows and existing covered stack emission.
Their explicit original identity and complete slot rows must key contextual
instances; residual callees each need their own exact substitution and original
G guard. Ordinary name lookup/exact_def cannot authorize a specialized body.
Production qualification must audit actual emitted closure, cap distinct instances
with shared aggregate fuel, then run supported-host/deep controls. This is a
concrete partial implementation, not a completed whole-Map compiler optimization.

Root controls-v2 completed in 1.710s at 170,037,248-byte peak tree RSS. Exact
command preserved in `selfhost/build/phase43/run-map-controls02/run.json`:

```sh
taskset -c 3 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  --stack-size=4096 --max-old-space-size=768 \
  selfhost/tools/performance/phase43/map/controls-v2.mjs \
  selfhost/build/phase43/map-whole01 selfhost/build/phase43/map-controls02
```

Controls PASS 15 values and 259 boundaries. Supplemental screen completed in
21.709s, with 32/128 whole medians 6.43196/27.4923ms versus original
16.9928/75.7497ms. Consumed runner and full configuration are preserved in
`selfhost/build/phase43/map-screen01`; see experiment report for comparator table.

`build-prototype.py` freezes current production baselines, source hashes, complete
staged files and a coherent patch into a fresh directory. `source03/prototype.patch`
is the first coherent artifact. `source03-fixes.patch` additionally requires the
root worker capability, uses the canonical source Def rather than the annotated
emitted Def, and derives erased prefix ABI from formal All qty0 rather than raw
Lam quantity. Driver contextBook retains raw default Lam qty1; annotation derives
Lam qty0, while existing JS lambda emission erases according to the All type.
Exact formal proof and runtime binder absence remain mandatory.

Private instance arity is live-slot arity; source calls strip proven erased slots
once and generic residual calls reattach their original slots. Full exact original
G closure guards include source constructors inlined away, preserving nullary
constructor allocation timing. Unsupported helper SCCs remain original generic
residual calls. Instances never replace canonical book definitions and no missing
private target may become G[clone]. Scalar roots alone own fresh internal graphs;
public externally owned Map inputs and exposed Map results are refused.

Source03 and its fixes await root's checked build, actual activation audit and
semantic controls. Source04 adds 702 lines and removes 21 (net +681) justify subsequent extraction
into an explicit instances module only if qualified; no source reduction or
compiler performance gain is claimed yet.

Versioned `source04/prototype.patch` is regenerated against current Bool-v3,
callback-v2 and String-v5 production sources. It includes all source03 fixes and
the review-mandated exact Sigma quantity equality: qa and qb must independently
match before field-type equality. `sigma-witness.bend` supplies four positive
self-equalities and six negative cross-quantity witnesses for root qualification.
Source04 net change is +681 lines (702 added, 21 removed), including net +678
in jpure; the earlier ~865 estimate described patch length, not source growth.

Review successor `source05/prototype.patch` additionally fences both traversal
fuel counters with kc and stops positive erased-call search immediately. Private
edge/emission metadata uses fixed slots, reserved names and exact kinds; malformed
rows and unexpected SCC edge kinds refuse. Source05 net growth is +693 lines
(714 added, 21 removed). All previous frozen versions remain available.

Actual checked08 emitted no private contextual instance root. Quick trace completed
in 5.94s; v2 identifies the first refusal exactly: Map.set is a builtin/source-flagged
Def (native=true), arity5/dx0/bodybound=true, so the original !db gate rejects it.
`source-origin-v1.patch` uses the actual emitter rule instead: j_def unconditionally
emits nonintrinsic source definitions, including Map methods; runtime intrinsics
retain their override path and are excluded from source-body instancing. Shared
source-origin admission now governs erased facts, ordinary source traversal, root
selection and final source assignment snapshots. Qualification remains pending.

Handed-off trace-v2 is restored byte-for-byte from consumed job input; subsequent
Sigma ABI witnesses are frozen in trace-v3. Every handed-off tool version is now
immutable. Prior consumed raw output and all source03/04/05 snapshots remain intact.
