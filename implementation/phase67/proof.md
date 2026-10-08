# Native immediate-let proof pilot

**Bend typechecking and safe elaboration pass; independent proof validation is
blocked on the required Lean 4.34.0 toolchain. No kernel-checked compiler proof
is claimed.** The available Lean 4.32.0 cannot elaborate the unmodified upstream
kernel because it lacks `ite_eq_left` at lines 3530 and 3537. The bounded
attempt ended in 91.87 seconds, exit 1, peak tree RSS 1.05 GiB. No download,
kernel patch, assumed lemma or deadline expansion was used.

The [71-line Bend file](../../selfhost/proofs/phase67/immediate-let.bend) states
and typechecks a semantic rule behind the native optimization: transporting an
already computed word through a saved sequential continuation yields the same
ordered environment and result as a direct local binding. A second theorem
composes this for any finite sequence by structural induction. It is generic
in word and result types, and has no imports, unsafe declarations, foreign code,
axioms, arithmetic primitives or assumed lemmas. Safe elaboration retains all
13 definitions, including both theorem statements and bodies, without any
out-of-scope omission.

The [production mapping and boundary](../../selfhost/proofs/phase67/README.md)
were independently reviewed against `nc_let`, `ne_frame` and `ne_take_params`:
held slots come first and the result is appended. This is a model of the
sequential immediate-word rule, **not a mechanically proved correspondence to
the unsafe emitter or generated C**. Variable lookup, ownership/refcounts, C
local-name freshness, scheduler/error polling, parallel task execution and
allocation failure remain outside it. In particular, the separate native
review found a real error-poll obligation that this proof cannot waive.

| Attempt | Outcome |
| --- | --- |
| `proof-check01` | Node strip-only cannot load a TypeScript parameter property; proof not read |
| `proof-check02` | Upstream CLI refuses Node; proof not read |
| `proof-check03` | Pinned Bun 1.4.2: `ALL PROOFS CHECK`, 0.104 s |
| `proof-b1-check01` | Installed compiler written in Bend: `ALL PROOFS CHECK`, 0.329 s |
| `proof-elaboration01` | All 13 safe definitions emitted, 3,147 bytes, 0.105 s |
| `proof-kernel01` | Lean 4.32.0 lacks `ite_eq_left`; independent checking not reached |
| False-equality kernel control | Prepared; not run while kernel cannot compile |

The installed Phase66 B1 also accepts the proof. Exact identities and outcomes
are bound in the [compact evidence receipt](evidence/proof01.json). Type acceptance by either Bend
checker does not substitute for independent kernel validation.

Exact identities:

- Proof source: `bf19656db55113adbde68559167a88d08f2ba4146460039b8e56268d0850061e`.
- BendTT output: `0e1b7e61e7b4acb849f455ff4f14f5c0498e730a02b087c923a1772974b0d589`.
- Unmodified upstream kernel: `83cdd36e66dcd2cabcc3d10556c9c874f8d823956feab88f8bb5a81473d51be3`.
- Lean executable: `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.
- Lean shared library: `52c37024db38569f7e8911cfbc6819a2d97d0a8c336e74c3da8590e2cc1e099b`.

`selfhost/tools/performance/phase67/proof/collect.py` only reads and hashes the
closed process receipts, logs, source, elaborated definitions and tools. Its
status remains `independent-validation-blocked`; it never marks a failed kernel
invocation as a proof.

## Replay and next boundary

Run targets one at a time under the maintained Phase46 CPU3/process-tree guard.
The successful upstream commands use `env BEND_NO_TELEMETRY=1` and the captured
`selfhost/build/phase66/bun-toolchain01/bun`, followed by `bend2/main.ts`, the
proof source, and either `--check-only` or `-o <fresh-path>.bendtt`. Disabling
telemetry avoids the CLI's unrelated update request and home-directory writes.
The exact failed independent command is in `proof-kernel01/process.json`.

After provisioning the **actual Lean 4.34.0** toolchain in a future scoped task,
run `lean -M1400 --run bend2/bendtt.lean <emitted-proof>.bendtt` under the same
180-second guard with `LEAN_STACK_SIZE_KB=4096`. Require successful exit and
exact `ALL PROOFS CHECK`, then run the same kernel on
[`reject-unequal-labels.bendtt`](../../selfhost/proofs/phase67/reject-unequal-labels.bendtt)
and require `SOME PROOFS FAIL` with nonzero exit. Only both successful controls
justify upgrading the model's independent-validation status. A later formal
emitter correspondence remains a separate, larger task.
