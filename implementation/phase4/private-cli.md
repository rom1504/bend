# Verified private compiler CLI and finite focused batches

The canonical implementation is [selfhost/tools/private-compiler](../../selfhost/tools/private-compiler/README.md). It builds a separate compiler image from a real completed checked self-host proof, exposes only data requests, and preserves ordinary emitted program/library code and public runtime behavior. No compiler algorithm was rewritten in the host. The exact runtime fingerprint is required; a runtime revision needs a new ownership, projection and primitive-semantics review.

The final package is `selfhost/build/phase4/private/release8`. Its private image SHA is `1905c283551d4ad93c129549f8c540d8d21b47eb0486d88036f0afa9a0d4f9ab`, identical to the measured earlier releases. Release8 adds supervisor and provenance hardening; timings below retain the exact earlier consumed-tool identities rather than assigning old measurements to new launcher bytes. The final build took 1.017 s inside the builder. The immediately preceding release7 build took 0.981 s inside the builder and 1.067 s including Node startup. These costs specialize an **already proven H**; they exclude creating that proof.

## Measured user-facing workflow

Three alternating fresh-process rounds on CPU0 used the same 21 actual frontend witnesses, frozen source/API/runtime/host identities and separately primed, verified Base caches. All 252 observations in the four-way matrix agreed exactly. A separate three-round private-single follow-up added 63 observations and compared each to the retained hashed reference report.

| Workflow for 21 cases | Median complete wall |
| --- | ---: |
| Private H, one finite batch | 17.524 s |
| Public H, one reused process | 19.263 s |
| Checked B1, one reused process | **7.850 s** |
| Checked B1, separate processes | 14.179 s |
| Private H, separate CLI processes | 43.023 s |

Finite batching is 2.46× faster than invoking the private CLI separately for each case, and about 9% faster than the reused public H control. **Checked B1 remains the fastest measured focused development workflow.** Reference hosts perform fewer supervision checks; their lower overhead is included, not subtracted. These are selected focused checks, not full-corpus timings.

The separate 18-observation warm single-CLI comparison shows why batching matters:

| Compile/check input | Public H process wall | Private CLI process wall | Public/private compiler request |
| --- | ---: | ---: | ---: |
| Tree | 3.459 s | 3.660 s | 3.250 / 2.487 s |
| List sort | 6.080 s | 5.491 s | 5.880 / 4.285 s |
| Rejected bytes operations | 2.495 s | 2.953 s | 2.253 / 1.772 s |

The private compiler request is faster, but verification/startup makes the shortest complete CLI workflows slower. An instrumented diagnostic worker spent about 434 ms hashing 148 MB over 75 hash updates; this is attribution, not a timing benchmark. Finite batches hash Node/image before and after each worker lifetime rather than per request.

The prior [private-image experiment](private-image.md) measured the internal specialization separately: the real 312-declaration compiler-core library request improved from 52.212 s to 34.651 s (1.51×). This is a compiler subset, not full compiler self-emission or a TypeScript comparison.

## Boundary and correctness gates

- 23 named automated tests pass, including partial/overapplication, tail calls, zero-arity effects, primitive corners, public getter counterexample, exact projection/constant proofs, input/symlink drift, proof/helper identities, resources and publication.
- 22 selected real CLI/public-H observations agree exactly, including imports, Unicode, libraries, parse/type/TODO rejection and foreign-source handling. Emitted programs are tested separately; compilation never executes user foreign code.
- Four single-launcher failure gates pass: timeout, existing-output protection, unsupported mode and runtime drift.
- Four real finite-batch behavior gates pass: timeout recovery plus rejection continuation, recycling/resource propagation, crash recovery and changed-input publication refusal.
- A reused real worker parses modified source freshly; two successive observations produce distinct source hashes/output. Public finite batches additionally require inputs to remain stable through their worker lifetime.
- Two fast-exit transport regressions write just over the combined 2 MiB stdout/stderr limit after creating valid pending output. The final file-size check catches both single and batch workers; neither publishes output. These synthetic workers test transport only and do not establish compiler proof.

The batch accepts at most 256 sequential requests and recycles after at most 32. A deadline/crash remains a failed observation; the next request uses a fresh worker. Completed observations remain pending until that worker lifetime's identity/input checks finish. An overflowing lifetime publishes none of its pending output. Earlier verified lifetimes may remain available when a later lifetime fails; the complete batch remains failed. The explicit heap option supports full-source experiments without changing the 3 GiB focused default.

## Evidence and reproduction

[private-cli.json](private-cli.json) retains compact observations, summaries, actual tool/input hashes, final manifest and the full named-test output. Raw file-backed reports are under `selfhost/build/phase4/private/{cli-warm,cli-validation3,batch-compare,batch-single,cli-failures,batch-behavior,fresh-graphs}`. Measurement directories also retain the exact consumed tool snapshots, including older supervisor bytes. The final package and test commands are in the canonical guide. Broad frontend/final combined-source results are separate root-owned evidence; none are inferred from these selected gates.
