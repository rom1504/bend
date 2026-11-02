# Phase154 pre-lowering capture

`prepare-capture.py --out selfhost/build/phase154/capture-planNN` assembles the
current maintained source and requires exact equality with the qualified Phase152
source. It extracts a small real compiler workload from `p111_verify_program` and
`p111_empty`, and pairs it with the ordinary `coverage-map-churn-128` source. It
prepares one guarded capture job; it does not run a compiler or acquire an image.

The job imports the existing checked **composite-api01**, whose source is the
qualified `027e1504…` version. The earlier candidate-api02 is a different source.
The complete acquisition/source/API/Base input identities are rechecked before
and after capture. It calls `p86_prepare`, `p86_plan` and `ns_body` to capture
pre-lowering owners, then `p134e_plan` once per small family for exact original
program metadata. No source compiler/image acquisition or machine build runs.
The acquisition's older `hosted.mjs` and `compiler.json` metadata bytes are
recovered from the verified Phase152 evidence capsule and exact Git object,
respectively, and checked against their original receipt hashes. This exception
does not apply to the API, compiler source, Base, engine or runtime inputs.

Each family preserves the entire `NR_Request`, including source and prepared
erased-definition context, plus selected original `KDef`/`KTerm` owners. These are
genuine inputs before N111/P113D production. They are **not yet** the statically
prepared book at `p144o_lower_bangs`: `p112s_prepare` and constructor preparation
still lie between this request and that narrower producer boundary. Subsequent
preparation must call the original checked Bend helpers for those operations.
The original final emission plan is retained in the same graph; companion
`*-headers.json` packets preserve raw segment, constructor and private-function
header order, stripping bodies only in that companion representation.

Selection takes two greatest source branch counts, two greatest source call
counts, declaration-order spread, then earliest remaining owners. The default
is eight; six through twelve are supported. Compiler owners come from the exact
extracted source; Map owners have the declared `Map.`/`Map:`/`p37.map.` prefixes
or are `main`. Every reached name and exclusion reason is recorded. This census
describes erased source terms, not lowered statement counts. No owner is filtered
because a proposed producer succeeds or fails on it.

The full request is an identity-preserving JSON object graph, avoiding repeated
serialization of shared cache/index subtrees. `graph.mjs` provides the generic
encoder/decoder. It does not interpret or lower compiler data. Primitive values
remain literal; object references use explicit node indices. Files are bounded
to one million graph nodes and128 MiB per family. A bound failure preserves the
incomplete receipt; it does not silently shrink the owner set. Decoding and
fixture construction belong outside repeated measurements, with fixed setup and
final cleanup reported. Mutable candidate units must be newly produced per
iteration; capturing this request does not authorize caching those units.

`book-fixture.mjs --capture CAPTURE/report.json --schema CHECKED/compiler.bend
--out selfhost/build/phase154/book-fixturesNN` converts the complete captured
book to the existing P88 typed-record format. It emits node and string counts,
codepoint-length-prefixed strings, identity-deduplicated postorder records
(tags 0–7), and the final book root ID. Every cache, index and declaration remains.
The bounds are 262,144 nodes, 8,192 strings and 16 MiB per book. A host decoder
rereads the file and checks all fields and the identity-sharing correspondence;
this is distinct from the checked Bend decoder's independent equality gate.
The accompanying header-only Bend fixtures are bounded to 200 KB. Each family
uses the same `p154h_headers`, `p154h_constructors` and `p154h_direct_headers`
names, so a combined executable must give each family's declarations its own
namespace before selecting the family at runtime.

Run `check-input.mjs --api CHECKED-API/report.json --books
BOOK-FIXTURES/report.json --out selfhost/build/phase154/check-inputNN` only under
the parent target guard. It calls the actual checked `p154r_read` on both files
and compares every decoded field with the captured complete book using an
iterative walk. Both family checks and the final input rehash must pass. The
decoder clock is descriptive; this is not a native timing or producer test.

The selected capture is `capture-plan05`: the full compiler and Map books are
2,979,167 and 2,364,782 bytes in P88 text, with 66,193- and 40,654-byte header
fixtures. `book-fixtures01/report.json` records their exact pins and host
roundtrips. The earlier ordinary-literal estimate (`book-estimate02`) measured
4.51 MB and 3.86 MB and was rejected as an unnecessarily large compiled fixture.
Capture01's historical-method mismatch and capture04's incorrect host metadata
field access are retained with the consumed method snapshots. Capture05 fixes
the latter using the actual `P113AProgram.original` field and saves the complete
graph before metadata unwrapping. None of these attempts is counted as a passed
compiler or candidate-performance test.

The Phase148 small checked API/native build/timing workflow is reusable, but its
old `shared.py` pins Phase147 and its packets begin after lowering. Do not run it
unchanged for Phase154. Use the explicit qualified Phase152 N2 and maintained
native builder. The eventual same-executable comparison must start at the chosen
real KTerm producer, retain numeric representation through its consumers, charge
any conversion needed by the independent verifier, render exact old bytes, and
include cleanup. A late `p148_pack` of an already-produced P113 function repeats
the rejected experiment and cannot establish the proposed producer saving.

## Completed producer experiment

Use `prepare.py` to make the extracted old/new checked API, then `controls.mjs`
with the capture and API receipts. `controls03` is the final authentic prefix
gate. `native.py` combines both complete external books, header fixtures and
`native-harness.bend` into one checked executable built by Phase152 N2. Each
prepared plan records frozen inputs and exact guarded jobs; execute those jobs
serially in fresh roots. `time-native.py` takes the native manifest and either
`--family compiler` or `--family map`, four alternating pairs. It authenticates
whole-output oracles before and after timing. Its `performanceQualified` flag
means sufficient timing duration, not success at the near-2x optimization gate.

`../profile-unit.py` prepares the short same-image physical sampling job.
`../summarize.py` derives committed metrics and cost accounting without running
a compiler. The [report](../../../implementation/phase154/README.md) limits
the result to the tested legacy direct producer and nine admitted helpers.
The full fresh-run commands and frozen methods are in the evidence capsule.
This prototype is not imported by the maintained compiler source manifest.
