# P55-003: reuse a complete no-Nat signature proof

Status: **preregistered, source implemented and statically reviewed; no candidate
measurement**.
Recorded at 2026-10-06 02:40:39 UTC, after the annotated-arity experiment's full
emission completed and before this experiment's checked build or timing result.
Root owns execution and promotion. This experiment changes compiler work, not
generated-program behavior or the public export inventory.

The independently reviewed source patch adds seven physical lines and 580 bytes
to `host.bend`; its frozen SHA-256 is
`222954163ca422add112c7560a83c2121e10d6811ec183cad4eed3c72c7643b4`.
`selfhost/build/phase55/host-signature01/host-signature.patch` retains the exact
delta. Checked compilation and the acceptance observations below remain pending.

## Observation and hypothesis

The fixed 77-root compiler-image acquisition with checked arity01 completes in
**198.494402 seconds**. Its diagnostic phases include:

| Phase | Seconds |
| --- | ---: |
| Exact emitted reachability | 22.894663 |
| Final call-graph analysis | 4.372911 |
| Definition emission | 14.109651 |
| Public export emission | **121.392051** |

The export phase emits 402,711 characters, while definitions emit 3,479,598.
These are forced, instrumented phase measurements from one successful run;
progress IO and forcing can affect timing/GC. They are not ordinary compiler
throughput or a warmed performance distribution. The separately supervised
process wall time is 198.709688 seconds, with 1,134,579,712 bytes peak tree RSS.
Do not substitute the earlier rough “130 seconds” estimate for the recorded
**121.392051 seconds**.

In [host.bend](../../selfhost/src/back/js/direct/host.bend), `jd_host` asks
`jd_marshal` independently about the result, each live input and every input's
back-conversion. Each query restarts `jd_host_nat_status` with an empty visited
set and a 1,024-visit budget. A function with `n` live inputs therefore performs
up to `2n + 1` independent top-level type walks, plus any nested marshalling work.
Compiler signatures repeatedly use recursive KTerm/KDef/list types without Nat.
This repeated work is visible in the source; its share of the export duration
has not yet been isolated by a candidate.

**Hypothesis:** one successful no-Nat proof for the complete function signature
can replace those repeated negative proofs. This should reduce export generation
cost while preserving the complete generated module byte-for-byte. No type name
or compiler-source recognizer belongs in the implementation.

## Minimal change

At `jd_host`, evaluate
`jd_host_nat_status(book, [dt(d)], Nil{}, 1024)` once. Carry a local Boolean into
the existing result/input/back printers:

- **Status 0:** the whole worklist completed without native Nat. Return the same
  empty marshalling text that each constituent query would return.
- **Status 1:** Nat exists. Use the original per-part marshalling path.
- **Status 2:** the combined proof exhausted its budget. Also use the original
  path; this is an optimization miss, not a new refusal.

Keep the existing arity, live parameter names, telescope walking, error markers,
and generated punctuation. In particular, empty conversion text still produces
`(aN),` arguments and `(aN);` back-conversion statements. Preserve input
conversion → call/`run_loop` → result conversion → input back-conversion order.
Do not alter Foreign wrappers, runtime helpers, export eligibility or the
77-root acquisition/adapter policy. All currently emitted public wrappers remain.

This is one invocation-local proof, not a cache. It adds no metadata declaration,
name-collision policy, invalidation scheme, or persistent assumption about types.
Any proposed per-type cache or once-per-library IO-shadow reuse is a separate
experiment. SCC body caching is also deferred: definition emission is no longer
the largest observed stage.

## Why status 0 is sufficient

The existing walker visits each live `All` domain and its codomain after
`j_app_type(..., Absent)` substitution. That is the same erased-slot and dependent
substitution policy used by `jd_host_args`, `jd_host_result` and `jd_host_back`.
It recursively explores constructor field telescopes and function/array element
types. Conversion direction changes how Nat is marshalled, not whether Nat is
present.

The visited set suppresses only a repeated exact specialized ADT key. Such an
expansion was already included under the same immutable checked book. Returning
0 requires completion of the entire worklist, including those expansions; it
cannot hide an unvisited Nat-bearing branch. Each constituent type graph is a
subset of that completed traversal. A successful combined proof therefore also
cannot hide a constituent's 1,024-visit failure.

The converse is unnecessary. A large combined signature can exhaust its budget
even when each independent input/result query succeeds. Status 2 must fall back
to preserve that acceptance. Malformed/unsupported formal telescopes retain the
existing printers and errors; the flag skips only proven-empty conversion text.
There is no claim of behavior for arbitrary cyclic host objects pretending to be
checked KTerms.

## Acceptance and falsifiers

Before performance interpretation, require a checked candidate and independent
static review of the implication, branch polarity and emitted ordering. Planned
controls cover:

1. Recursive no-Nat records/lists with several arguments and a result; exact
   wrapper bytes and public observations agree.
2. Nat only in an argument, only in the result, inside a function-valued
   parameter/result, and inside Array<Nat>/record fields. Existing conversions,
   aliasing, input readback and deferred invalid-Nat behavior remain intact.
3. An erased Nat formal and an erased type parameter: erasure remains exact and
   does not create a runtime conversion.
4. A complete signature whose combined scan exceeds 1,024 visits while each
   independent component fits: candidate takes the original path and retains
   success. A genuinely unsupported component keeps the original refusal.

The decisive acquisition uses the **same frozen complete compiler source**, Base,
77 requested roots, direct runtime, Node settings and serialized resource policy
as the completed arity01 run. Require **complete module byte equality**, not a
normalized body, sampled exports, a restricted public dictionary or a changed
source oracle. Baseline module identity is 3,895,592 bytes with SHA-256
`6c8055de86c34065ce7ff76a851835e039046ab23e1da707406345d9dc5cb090`.
The selected 3,056 definitions and all generated public exports must remain.

Record export-stage time, total diagnostic time and peak RSS separately. The
first bounded run is a decision probe, not a statistical speed claim. A neutral
or regressive result does not justify promotion; a promising result needs the
normal semantic/output-retention gates, and repeated timing if its interpretation
depends on a small difference. A successful emission is not yet a driver probe,
self-compilation, or byte-identical self-reproduction.

## Frozen predecessor evidence

All paths below are existing read-only Phase55 evidence. This note adds no run.

- `selfhost/build/phase55/bootstrap-full-arity0101/report.json`: complete/pass;
  SHA-256 `71449a20e264af7dbb9d98cc2aad7917ee2cfd286ea583286db3de0408b04d32`.
- `bootstrap-full-arity0101-supervisor/run.json`: successful supervised process;
  SHA-256 `b9d0a9fb5a8e452ba3e33c24a64cc76ddab992676ad1f9e2a4bcefd657ffaaf4`.
- Fixed subject source:
  `32cddcf1a970a9726a9785b30269cdd8a0047f917f769a964995fa6a0633de84`.
- Predecessor checked generator API:
  `3277b2149d97ed9ed1fcfc8d585696a75676d725845686589bce12d58fd3ad35`.
- Direct runtime:
  `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.

The predecessor uses the explicitly labeled `inherited-exact-bootstrap` source
checking lane. Current completion, specialization and emission proofs still run;
the receipt does not claim a fresh source self-check.
