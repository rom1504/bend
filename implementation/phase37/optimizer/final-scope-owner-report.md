# Phase37 final proof-scope and owner results

The three new owner groups passed on the selected **checked03** compiler:
private F32 conversion, the shared DataView guard and finite selectors. The
final owner audit completed successfully in **2.513 seconds**, verifying **710
file identities and 15 pinned Git provenance blobs**. All acquisitions,
controls and audits were executed by root under the shared resource supervisor.

This report closes the new optimization owners and records their source review.
The phase index reports final performance, compilation cost, inherited
conformance, installation and release status separately. This compiler artifact
is a checked B1 derivative; this evidence does not establish a self-emitted
fixed point.

## Selected image

| Identity | SHA256 |
| --- | --- |
| checked03 selected API | `ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1` |
| Checked compiler source | `6b97ede24fd9e57101ac6f372bcae3e78a82aebb6e9cb5903d53ff0b44983201` |
| Runtime | `51bb6046a8ac116865e2b1ed94b5587d1257f951aed536da77da3e91338eac49` |
| Pinned Base | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| Attempt manifest | `7ae878dda1b75dce1655c62d8e7238e184319da1fa04a8a12a189f37badc8f85` |

The upstream reference remains commit
`018751270e800bc222a93dad7f257083ee53a5f7`. Every new-owner candidate receipt
binds this selected API, runtime, Base, driver and checked attempt. Earlier
checked02 results remain experiment history; final controls use fresh checked03
emissions.

## Retained implementation

The F32 conversion reuses `JNative` and the existing exact checked native
signature proof. Admission requires `F32.to_u32`, arity one and its original
native definition metadata. The final public descriptor and private region
call share one helper body; the original mutable descriptor remains in the
guard. Conversion returns zero for nonfinite, negative or out-of-range values
and truncates valid inputs. Arguments are evaluated once through the normal
single-argument helper call.

Finite selectors reuse the original typed `Lam`/`Mat` prefix and mandatory
complete `JPure` validation. They inspect materialized owned values inside an
existing complete scalar-root proof, preserving ordinary tagged objects and
shared fields. They introduce no new value representation or recursive direct
worker. A selector with entirely scalar inputs and result no longer justifies
opening an additional root proof by itself; selectors remain available inside
an already valid proof. This structural cost filter changes when a proof is
opened, while preserving the ownership and dependency conditions.

The DataView guard checks the shared view's exact prototype, absence of four
own methods and four captured prototype methods. Its constructor/global and
prototype-parent checks were removed after inspection established that the
current runtime creates the view only once at import. The retained checks
prevent callbacks through both altered public methods and a previously leaked
private instance. Future construction inside a guarded region would add a new
constructor obligation.

The final [scope review](checked03-scope-review.md) independently reviewed the
finite change and explicitly labels the DataView discussion as author review.
The [cast report](native-cast-prototype.md) preserves the vulnerable prototype,
its 18 failing DataView observations and the corrected experiment. Its saved-
output timings remain mechanism evidence; actual compiler timing belongs in
the phase performance report.

## Final control results

Counts below are control rows as reported. A row may compare two or three
modules; these heterogeneous groups should not be added into a language
conformance denominator.

| Owner | Final report | Completed result |
| --- | --- | --- |
| Cast | `cast-actual-controls02/report.json` | 44 oracle rows, 57 boundary rows, seven admission rows; pass |
| DataView | `cast-actual-dataview02/report.json` | 22 live prototype/instance observations, zero errors; pass |
| Finite selectors | `finite-controls02/report.json` | 154 oracle rows, nine admission rows, 76 boundaries; pass |

The cast adapter counted seven actual private native call sites in the emitted
candidate and zero in the Phase36 comparison. It changed only diagnostic call
counters; clean copies preserve checked emitted bytes. Controls covered F32
boundaries, source composition/order/unused results/delayed partial closures,
public descriptor mutation, host hooks, raw/partial entries, reentry and errors.

The finite diagnostic found 44 actual selector sites and observed all five
intended selectors. Complete tree observations preserved subtree alias identity.
The two 30,000-step self/mutual tail cycles each recorded one outer proof owner,
a terminal selector entry and no active proof after completion. Public trees,
getters, deferred work, mutated dependencies, argument errors and Error-hook
reentry retained their generic observations.

The corrected finite-v5 fixture and v2 control worker preserve the preceding
failed fixture/control versions. In particular, the first structural control
incorrectly required new finite-root markers where an older optimization had
already won dispatch. The added `leaf_scoped` composition gives a real finite
scope and visible entries; older paths remain differential controls. This was
not resolved by declaring a missing private witness successful.

Separately, `candidate-correctness02/report.json` passed **154 executions**:
45 catalog points plus 32 small application points, each run by the selected
candidate and TypeScript. This includes untimed holdout correctness and does
not expose holdout performance for tuning.

## Closure and preserved audit failure

The first closer failed before closing any owner because it resolved
`fixtures/mandelbrot.bend`, a catalog-relative identity, from the repository
root. `new-owner-close01.json` and the original producer remain preserved.
This was an audit path error; the compiler and control verdicts were unchanged.

The versioned v2 closer resolves catalog, bundle, preparation, proposal and
repository identity namespaces explicitly. It verifies pinned commit/path
provenance from local Git blobs where the sparse checkout omits benchmark
files, checking SHA256, size and Git blob ID where supplied. It also selects
the cast's TypeScript receipt by its exact source hash within the larger
catalog closure. No required identity edge is skipped. Every observed file and
Git blob is rechecked before success.

The final `new-owner-close02.json` passed all three named groups, their actual
diagnostic-parent and checked-emission links, exact producer copies and
successful supervisor commands. The selected historical Phase36 receipt also
binds its own frozen attempt, rather than relying only on an old API hash.

| Evidence, relative to `selfhost/build/phase37` | SHA256 |
| --- | --- |
| `new-owner-close02.json` | `63a049e46bef3ecf83d721c362ede91af006e50fcd6a087e144fd649e5d13ea1` |
| `new-owner-close-outer02/run.json` | `eaa2d749394db0e3217369f4800f3277857c26fe05af04da9b73b37c0cda9d91` |
| `new-owner-close01.json`, failed audit | `d33c21968390b926619ec19d3fd1dd6ee594cf2f584064670d23a81d87aca460` |
| `candidate-correctness02/report.json` | `61ce052a200ce3b6c1bc4e14551630480b9b4a36414511e52166b04065e50b4a` |

The successful producer `owner-close-v2.py` has SHA256
`6595799297f1ad4382594f4439b37f6267fa58b19d7b72d329458e453313c0b4`.
The [closure protocol](new-owner-closure.md) records invocation and exact groups.

These owner results retain their scoped meaning. They do not establish all
backend semantics, GPU/IO/native throughput, full-language coverage, general
performance parity or final installation. The broader phase evidence must
answer those separate questions.
