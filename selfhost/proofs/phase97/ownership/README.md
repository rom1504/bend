# Compositional ownership pilot

This is a **safe, universal proof over an explicit ownership model**, not a proof
of the native runtime. It proves that replacing `Keep; Read; Drop` with `Read`
preserves the complete result in any sequential prefix and suffix.

All seven proof bodies passed the upstream source checker, safe elaboration,
and the independent BendTT kernel hosted by Lean 4.34. The accepted closure is
frozen in [ownership-proof02/report.json](../../../build/phase97/ownership-proof02/report.json).
That report inventories **26 elaborated definitions**, including all seven law
bodies, the model, protocol, datatype machinery, and actual Base list append;
**no definitions are opaque**. The unequal-label
kernel negative also rejected. The earlier three-law check is retained in
[ownership-proof01/report.json](../../../build/phase97/ownership-proof01/report.json).

## Observed checking cost and identity

The four source files total 203 lines, including comments and blank lines. The
local module and later composition extension each passed on their first
submitted check. The full run observed these guarded process times:

| Stage | Wall time |
| --- | ---: |
| Source check | 0.534 s |
| Safe BendTT emission | 0.554 s |
| Independent kernel acceptance | 0.370 s |
| Unequal-label kernel rejection control | 0.289 s |

These are single observed process times with the existing audited kernel and
toolchain, excluding toolchain construction and orchestration. They are not a
scalability benchmark or an estimate of proof authoring effort.

The emitted BendTT is 9,592 bytes. Raw source and elaboration identities were
rechecked against the accepted report after mutation execution:

| Artifact | SHA-256 |
| --- | --- |
| `model.bend` | `a7c07f3d53a1f2c69d98ca20c904eef70e52fdc5c2d3775de17813de0b20ac68` |
| `protocol.bend` | `24a63956e60deb404197f4ce05d3fed385cd0a71c33eda18c6340900e3427954` |
| `local.bend` | `aec6090fe030d5571070ca26076b41be90f079b489dd9736fa866c0ad1a74089` |
| `composition.bend` | `683bbf44be8f50d495b8d8d8bbd6aaedabd47bc6a7756e5061b202cd2f6a2e3c` |
| [Emitted laws.bendtt](../../../build/phase97/ownership-proof02/laws.bendtt) | `b5db0bffd4e856876bc90ca8aea19b353dbf09c854b57c421250499b65dff05a` |

## Exact claim

For every Data payload type `A`, initial cell, operation prefix and operation
suffix, the following executions are equal as full `OwnResult<A>` values:

```text
execute(prefix ++ [Keep, Read, Drop] ++ suffix, cell)
execute(prefix ++ [Read] ++ suffix, cell)
```

The result includes every read payload in chronological order, the complete
final cell on success, and an explicit dead-root fault with its prior trace on
failure. Final roots are zero for `OwnDead` or fault, and `1 + extra` for
`OwnLive{extra, value}`. Structural `Nat` counts do not wrap. `Keep` on a dead
cell faults; it cannot resurrect a root. An arbitrary prefix may already fault,
and an arbitrary suffix may destroy the final root or fault later.

## Files and proof inventory

| File | Role |
| --- | --- |
| [model.bend](model.bend) | Executable sequential single-cell semantics, result sequencing, root observation |
| [protocol.bend](protocol.bend) | Original and replacement operation sequences |
| [local.bend](local.bend) | Local preservation and two semantic anchors |
| [composition.bend](composition.bend) | Sequencing induction and contextual preservation; full proof entry |
| [mutations.json](mutations.json) | Three semantic helper mutations and explicit witnesses |
| [prepare-negatives.py](prepare-negatives.py) | Authenticated snapshot preparation only; executes no compiler or target |

Four public laws:

| Law | Claim |
| --- | --- |
| `temporary_read_preserves` | Local replacement preserves full outcomes for arbitrary cell and continuation |
| `dead_root_fault` | Every operation faults when applied to a dead cell |
| `drop_last_then_read_fault` | Destroying the final owner before a read faults |
| `temporary_read_in_context` | The replacement preserves full outcomes after any prefix and before any suffix |

Three support lemmas, counted separately:

| Lemma | Role |
| --- | --- |
| `resume_read` | A prior read survives sequencing, including a later fault |
| `execute_append` | Structural induction relates Base append to result sequencing |
| `resume_temporary_read` | Lifts local preservation through any previous result, including a fault |

## Semantic rejection controls

Preparation authenticates the accepted proof closure and copies it into fresh
build directories. Only the `borrowed_read` body changes. Each mutant must first
pass a standalone check of `protocol.bend`, then fail the unchanged complete
proof entry. A parser, usage, resource, or import failure is not a semantic
rejection. Expected proof mismatch: `temporary_read_preserves`.

| Mutant | Distinguishing observation for one root, payload `7n`, empty suffix |
| --- | --- |
| `drop-before-read` | Original succeeds and reads `7n`; mutant faults before any read |
| `omit-read` | Final roots agree, but the mutant loses the read |
| `retain-without-release` | Read traces agree, but the mutant ends with two roots |

All **three helpers passed standalone source checking**, then the unchanged
composition entry (including the local laws) rejected all three with
expected/observed semantic mismatches in `temporary_read_preserves`.
Evidence: [ownership-negatives01/report.json](../../../build/phase97/ownership-negatives01/report.json).
Each source check took 0.493–0.514 seconds. These are frontend semantic controls,
distinct from the independent positive kernel result.

The recorded first mismatches were a changed continuation after early drop,
skipping the dead-cell fault for omitted read, and a changed root count for an
unreleased retain. Thus the live-cell trace witness in the table is an explicit
counterexample from the model definition, not the first diagnostic observed
for `omit-read`. No syntax, usage, import or resource failure was counted.
Diagnostics are in the retained **stderr** logs; inspect both output channels.

Offline verification checked the report and snapshot hashes, raw logs, exact
unchanged model/local/composition bytes, and the three protocol-only mutations.
The positive source files remain byte-for-byte identical to the accepted closure.

Root-run preparation, which executes no targets:

```sh
python3 -B selfhost/proofs/phase97/ownership/prepare-negatives.py \
  --proof-report selfhost/build/phase97/ownership-proof02/report.json \
  --out selfhost/build/phase97/ownership-negative-source01
```

The retained [plan.json](../../../build/phase97/ownership-negative-source01/plan.json)
contains exact hashes and serial guarded check jobs. For a rerun, choose a fresh
output directory; the example directory already holds the accepted preparation.

## Production boundary

The [semantic pilot analysis](../../../../implementation/phase97/semantic-pilot.md)
maps operations to runtime sites and specifies the missing bridge. In particular,
`Read` produces an abstract immutable value, not an escaping runtime pointer.
The model has one cell and aggregate root counts, not named handles or child
ownership. It cannot justify deleting child retains in `span_fade`, which
transfers ownership of fields from a parent into separate live roots.

The separate [runtime boundary control](../../../build/phase97/ownership-boundary01/report.json)
replayed one mutation in actual generated C: changing the child retain count
from one to zero in `span_fade`. The candidate compiled, then exited with a
runtime error after eight correct prefix lines; the baseline produced all 32
expected lines. The model proof sources stayed unchanged. This demonstrates
the need for the production bridge; it is not a failed model theorem.

No native implementation, lowering pass, generated C, concurrency behavior, or
production optimization is proved or changed by this package.
