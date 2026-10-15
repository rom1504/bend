# Compiler laws: fast checks before optimization

The [Phase96 foundation](../../selfhost/proofs/phase96/README.md) contains
31 public universal laws, seven supporting lemmas, and 226 finite production
contract cases in 16 families. The universal laws have complete Bend proof bodies
checked by the unchanged upstream BendTT kernel implemented in Lean. The finite
contracts exercise exact maintained compiler helpers through genuine JS B2;
32 selected cases also execute as generated C.

These are constraints for future changes, not a proof of the whole compiler.
The distinction matters: most production algorithms remain unsafe, and the
compiler's generated code, runtime and scheduler are not verified by BendTT.

The [Phase97 experiments](../../implementation/phase97/README.md) test usefulness
with independently selected faults and legitimate rewrites. The original suite
detects five semantic faults, rejects one ill-formed mutant before execution,
and lacks extraction coverage for two helpers. The supplemental campaign adds
those two frozen witnesses: 228 JS cases and 34 native witnesses pass. These are
a separate Phase97 extension, not a silent change to Phase96's 226-case count.
Both equivalent finite controls pass; a literal corruption also fails an unchanged
formal representation law after standalone helper admission.

Phase97 additionally contributes four public ownership-model laws and three
support lemmas, all independently checked. They prove a temporary retain/read/
release replacement in arbitrary modeled contexts. They do not verify concrete
handles or escaped child ownership: a separate missing-retain C mutation compiles
and then fails at runtime. See the [proof boundary](../../implementation/phase97/semantic-pilot.md)
and [supplemental commands](../../selfhost/tools/laws/phase97/README.md).

## Run the suite

From the repository root, use a fresh output directory each time:

```sh
python3 -B selfhost/tools/laws/phase96/run.py \
  --out selfhost/build/phase96/my-fast-check --tier fast

python3 -B selfhost/tools/laws/phase96/run.py \
  --out selfhost/build/phase96/my-audit --tier audit
```

`fast` checks both complete proof packages, including independent kernel rejection
of a false equality, and all 226 finite JS cases. `audit` adds the 16 proof
rejection controls, ten executable semantic mutants, and 32 generated-C cases.
Targets run serially on CPU3 with a 2GiB process-tree RSS limit and 4GiB available
memory floor; each target has a deadline. It does not rebuild the compiler or
rerun the large runtime benchmark. Measured durations are in the
[implementation report](../../implementation/phase96/README.md).

This checkout needs the authenticated Phase94 Lean4.34.0 installation and cached
unchanged BendTT module, Phase66 Bun, Phase90 genuine JS B2 and host files, and
the Phase91 continuity plan. Native checks additionally need the established
Clang22 installation. Missing or changed prerequisites fail; the runner never
silently substitutes another compiler or downloads a toolchain. The
[Phase94 toolchain method](../../selfhost/tools/performance/phase94/README.md)
and [native restoration guide](NATIVE_HOST.md) describe the retained installations.
The suite is a reusable workspace command, not yet a standalone fresh-clone CI
installer.

Each run writes `report.json`, raw process receipts, source snapshots, elaborated
proofs, full expected and actual values, and identities of the tools used. A
source-check failure, resource stop or compilation error is distinct from a
semantic counterexample. Read the failed step's raw log before changing a law.

## What is constrained

| Group | Constraints and connection |
| --- | --- |
| Ordered list algebra | Actual Base append/reverse/filter/membership operations: composition, length, accumulator behavior, idempotence and semantic anchors. Generic callbacks are typed pure total parameters; no comparator equivalence assumptions are invented. |
| Environment preparation | Exact Phase94 safe candidate and reference: prefix chunking and ordered live/drop results. This helper remains unpromoted; its proof does not cover the production unsafe adapter. |
| Term representation | Exact maintained KTerm type and 15 helper bodies, with only leading unsafe annotations removed in a proof extraction. Seventeen laws constrain metadata preservation, update composition, constructor observations and span/children behavior. |
| Finite production contracts | Full-value results for term operations, beta-producing substitution, stability certificates, first-match and cached lookup, book updates, last events, occurrences, environment selection/partition, constructor encoding and text assembly. |

See the [public law catalog](../../selfhost/proofs/phase96/README.md) and
[finite contract catalog](../../selfhost/proofs/phase96/production/catalog.json)
for individual statements, cases and domains. Native execution covers two
selected witnesses per family, not all 226 cases. Its compiler is JS-hosted B2
emitting C; this is not a new native B1/B2 compiler-chain qualification.

There are deliberate limits. `core_literal` is safely admitted but has no
result-specific universal law here. `k_rebuild` has put-back and child-update
laws, not a full universal specification of arbitrary replacement fields; finite
cases exercise additional changes. Representation observation records named
`Semantics` describe stored fields, not an operational semantics. Raw malformed
unsafe values, arbitrary callbacks, general binding preservation, machine memory
safety, GPU and parallel schedules remain outside the proof boundary.

## Use laws to make the next optimization safer

1. Pick a measured costly operation and name its observable result and premises.
2. Freeze a small specification and a distinguishing counterexample. Use complete
   payloads, order and metadata where they matter, not only a tag or checksum.
3. Implement the candidate behind the same interface. The representation and
   finite suites re-extract current source, so actual helper changes are tested.
4. Run `fast` during development and `audit` before promoting a candidate. Add a
   well-typed bad implementation that the relevant property actually rejects.
5. Where the operation is safe, prove candidate/reference equality for all
   admitted inputs and independently check the emitted theorem and helper bodies.
   Where it is unsafe, keep the finite-test label and state the missing bridge.
6. Only after correctness checks, measure the helper and real compilation. Keep
   compiler latency, program runtime, conformance and source complexity separate.

The strongest lesson from the [upstream proof study](../../research/phase96/upstream-proof-method.md)
is its `subk_sub`/`sub_subz` bridge: an optimized executable operation is proved
equal to a simpler specification. Its cache lookup theorems likewise rely on an
explicit relation between the index and definition list. Our different term
representation needs its own premises and proof; upstream theorems do not transfer
automatically.

Two practical traps surfaced while writing these laws. An always-false membership
function can satisfy some composition identities, so singleton/decision laws are
also needed. And our production substitution beta-rebuilds applications: an
absent variable ID does **not** imply that every raw term remains unchanged.
The stable-substitution contract asserts only the sound direction of its
certificate. Good laws capture these details before an optimization relies on
the wrong assumption.
