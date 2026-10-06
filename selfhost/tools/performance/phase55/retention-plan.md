# Phase55 final retention gate

The current prepared selection is `checked-host02`; the earlier arity01 plan
below remains preserved and unconsumed. The same reviewed producer generated
[semantic-launch-host02.json](semantic-launch-host02.json), SHA-256
`e97cfe271e6cf51eea260494baf72e051cde91179e48199b2a37142eac9821f5`.
It binds attempt `c47c8df40ee13be2cc21bc43c2cd1348549684b5f14773781fdbd522b0d37cb0`,
API `cfde1ebf44d958e593331cfd9af77f7b6ee657441dbd582db8d27f3928815a62`,
and fresh output `build/phase55/semantic-final-host02`. Only the selected
attempt identity and selected/output paths differ from the arity01 plan;
all 18 commands, Phase54 baseline bindings, oracles and resource settings
remain the same. Neither plan is evidence that its target jobs have run.

This gate checks the annotation-guided constructor lookup against the installed
Phase54 `checked-graph02` image. It reuses the frozen source oracles and emission
comparison algorithms. It adds no runtime benchmark samples. Root owns the
execution slot, source reconciliation, installation and publication.

The candidate is `build/phase55/checked-arity01`, attempt SHA-256
`87f61624692529bc17191d2a21bf49971506fc41b36b092f047e8c8e8e644007`, API
`3277b2149d97ed9ed1fcfc8d585696a75676d725845686589bce12d58fd3ad35`.
The baseline is `build/phase54/checked-graph02`, attempt
`594381ea67444070290efeb516458997c528829f9cd4b65385109afc2d0d4a76`, API
`d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`.
Both retain legacy runtime `3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46`.
The frozen checked snapshots supply each role's driver, direct runtime and Base;
sharing a runtime hash does not substitute for the attempt/API/source joins.

The exact 18 argv rows are in [semantic-launch-arity01.json](semantic-launch-arity01.json)
(SHA-256 `ed281519460e66b6aa94d8439a1356656c1a55faf2f0bad23374b4a3789f91a3`).
Its output root is the fresh `build/phase55/semantic-final01`. The plan is not
execution evidence. Each row must finish successfully before the next begins;
the native row's `environment` must be merged into its subprocess environment.

| Scope | Mandatory result |
|---|---|
| Original source semantics | Candidate 96/96; retain pinned TS 95/96 and its unchanged failing golden |
| Numeric, bits, cold/repeated host behavior | Candidate 34/34; retain TS 28/34 |
| Composition order, captures, partial application | Both roles 18/18 |
| Genuine overapplication | Both roles 2/2 |
| Semantic output retention | All 29 source, 2 numeric, 1 composition and 1 overapplication modules exactly equal Phase54 |
| Maintained direct census | 26 semantic agreements; both original fixture judges complete; report exact agreement separately |
| Maintained legacy compatibility | All 8 suites pass using their explicit legacy selectors |
| Production JS retention | 23 fresh checked sources; all 45 point modules exactly equal Phase54, including the complete-row observer |
| Representative native contract | All 3 complete C outputs exactly equal Phase54; both roles satisfy all 3 independent CPU stdout goldens |

The native sources are U32 arithmetic, F32 arithmetic and array/closure
map/fold. Their expected stdout is respectively `63\n`, `8\n` and `690\n1\n`.
This is representative native retention, not full native conformance. The
semantic scopes overlap and must not be added into one coverage total.

The [method derivation](retention-methods-v1.derivation.json) records the exact
changes to frozen Phase54 tools: phase paths, immutable Phase54 baseline
metadata, parent-method hashes and the known Clang environment. The independent
oracles, whole-file comparisons, observer reconstruction, census selection and
guards are unchanged. All original Phase54 methods and raw outputs remain
untouched. No module text is normalized and no mismatch is excused as expected.

To materialize the same plan at a new output root, use a fresh plan filename:

```sh
python3 -B selfhost/tools/performance/phase55/semantic-launch-plan-v1.py \
  --attempt selfhost/build/phase55/checked-arity01 \
  --out-base selfhost/build/phase55/NEW_SEMANTIC_OUTPUT \
  --plan-file selfhost/build/phase55/NEW_LAUNCH_PLAN.json
```

Execute the plan rows serially from the repository root. Keep the executable
parent unpinned: acquisition, census and maintained methods select CPU3 and
own their sole `ExecutionGuard`. Standalone Node controllers have the one
outer bounded supervisor already present in their command. The shared policy
is a 1 GiB Node heap, 2 GiB process-tree RSS cap, 4 GiB available-memory floor
and one heavy job at a time. Do not add another guard or an inherited CPU0
affinity. Node is the pinned 24.18.0 executable in the plan.

The native row must run before installing the candidate: its unchanged
controller verifies that the live installed API is still the Phase54 baseline.
Use the plan's exact `CC`, `CPATH`, `LIBRARY_PATH` and `LD_LIBRARY_PATH` values
from the preserved successful Phase54 toolchain binding. The first Phase54
native attempt failed because the default environment lacked Clang; omitting
these fields would repeat a known harness failure. Sandbox permission for
Clang must be handled by root's authorized target launcher.

The equivalent completed Phase54 scopes took about seven minutes: roughly
150 seconds for source acquisition, 136 for production acquisition, 55 for
census, 17 for maintained suites, 25 for native representatives, and the
remaining time for small acquisitions/controllers/comparisons. Allow 5–8
minutes initially; these are estimates, not deadlines or measured Phase55
results. The arity-specific positive/refusal controls remain a separate
focused gate owned by the semantic agent. Successful whole-module equality
supports retaining historical runtime observations for those exact outputs;
it avoids another 45-point timing campaign but does not prove all programs
equivalent or establish compiler-throughput improvement.

After the gate, root can reconcile the selected source, install the exact
checked image and run the existing 42 legacy plus 24 default release/routing
controls and integrity/relocation/tamper checks. Those release steps are
separate from this plan and must not be marked complete by its producer.
