# Phase155 ID18 full-parser transfer

Stopped after the final bounded retry. Source03's 557,308-byte checked source
passed acquisition, but hosted controls rejected the full-Base harness with a
stack overflow. Independent parse success never passed; no native transfer
image was built and no native parser-transfer gain was measured. This is a
harness/observation stack limitation, not evidence that the candidate's
semantics fail or that compiler performance regresses.

This follow-up tests whether ID18's scalar name predicate helps the actual
current parser and source loader. The earlier lexer/name-consumer screen called
the predicate on every token and reported a 0.362× ratio; this transfer invokes
it only where the maintained parser does. No transfer timing has run.

`p155t_old(n: U32) -> String` and `p155t_new(n: U32) -> String` each perform
`n` complete paired source-graph loads through `f_load_graph_trace`. Each graph
contains the pinned full Base source and the requested source at disjoint
located intervals. The production loader parses Base first and builds its real
constructor/name scope before parsing the source, then performs normal
declaration completion and freshening. The candidate substitutes `p155x_valid`
only at real `f_valid_name` call sites. No scope metadata is fabricated.

Each repetition freshly constructs the 15,463-byte dependency-closed current
compiler verifier slice rooted at `p111v_functions` (49 declarations), and the
complete 1,662-byte ordinary expression-interpreter benchmark
`coverage-expression-128.bend`. Both graphs separately receive the exact
75,064-byte pinned Base payload. A changing iteration comment precedes each
source and Base. Source preparation, complete graph loading and cleanup remain
inside the operation. This does not perform source typechecking or code emission.

The return value concatenates complete `FResult` serializations for both inputs
at every repetition, including every Base definition. The independent existing `p155p_defs`, `p155p_terms` and
`p155p_string` serializers consume all AST fields, spans, errors and imports.
There is no checksum or discarded earlier parse. Both roles must match exactly
at counts 0, 1, 2, 7. `p155t_controls(0)` must independently return `"ok"`: both roles
must have empty errors and retain the source-ground `p111v_functions`/`eval` definitions.
This prevents matching errors from being accepted as successful transfer.
The 42 exact predicate controls remain in the original frontend screen. The
complete `FResult` is serialized; trace provenance records are not part of this
observer.

The retained offline transport script reuses the maintained source assembler
and existing Phase147 declaration extractor. It clones only the function/law
ancestors of `f_valid_name` reachable from the loader root: 254 declarations
for 180 functions, 99,696 bytes. Datatypes and unaffected helpers stay shared.
Literal/comment bytes are excluded from identifier renaming; inverse renaming
of every cloned declaration reproduces the original bytes exactly. The report
records the canonical identity, closure, complete name mapping and input pins.
The canonical global `main` is removed before extraction, matching the existing
tournament preparer; otherwise a local argument named `main` conservatively
pulls in unrelated compiler entry dependencies. The transport implements no
compiler semantics or runtime orchestration.

The generated files are under
`selfhost/build/phase155/parser-transfer-source03/`; the spec pins them. This
offline preparation already completed, with no target execution:

```sh
python3 -B experiments/phase155/parser-transfer/prepare.py --out selfhost/build/phase155/parser-transfer-source03
```

The retained root-owned screen preparation used this command:

```sh
python3 -B experiments/phase155/prepare.py --families parser-transfer --out selfhost/build/phase155/parser-transfer-prepare03
```

The planned native comparison required the original and cloned parser in the
same image, alternating old/new whole-child runs on the same CPU and count,
with complete output equality and independent success controls required first.
That gate was not met, so native preparation and timing were not started.
Complete serialization, printing and process
cleanup remain in the clock and may dilute a name-predicate improvement.
Both complete Base parses are also charged, so this workload is broader than a
parse of the two source bodies with an already prepared Base. Do not report its
ratio as a standalone source-parser or whole-compiler ratio. The final extracted
source must remain about 600 KB or less; no larger image campaign is authorized.

No production source, compiler manifest, runtime or qualification tool changed.
Two fixed sources cannot establish broad parser equivalence, a whole-cold
compiler improvement or a production promotion. This is a bounded transfer
screen after a promising local result.

The first source check at `parser-transfer-prepare01` failed with
`RangeError: Maximum call stack size exceeded` after 2.55 seconds; no native
build started. Its single long fixture literals are retained unchanged in
`parser-transfer-source01`. Source02 represents the identical fixture bytes as
named literals of at most 256 characters, joined through balanced named helpers
(37 chunks/6 join levels for compiler source, 7 chunks/3 levels for ordinary
source). The transport verifies literal decoding round-trips exactly. This
fixture preparation is the same in both roles and remains inside timing.
Source02's checked acquisition passed, but its independent success control
failed despite old/new output equality: the isolated validation module failed
on `unknown constructor pattern: Nil`, and the ordinary fixture on
`unknown constructor pattern: Zero`. The empty initial scope lacked Base's
constructor context. These controls are retained as a counterexample to treating
matching error outputs as a successful transfer. Source03 is the final bounded
retry, using the real loader, full Base and a dependency-closed compiler fixture.
No engine or toolchain flags changed.

The final [checked acquisition receipt](../../../selfhost/build/phase155/parser-transfer-prepare03/checked-api/report.json)
records `checked: true` for source03, 557,308 bytes, SHA256
`7910026bb02e43841e7b023951f5da59a6c445f9a4ef6498410b8360014124cd`.
The [hosted controls02 rejection](../../../selfhost/build/phase155/parser-controls02/report.json)
records `passed: false`: count 0 returned the expected `"done"`, while counts
1, 2 and 7 and the independent `p155t_controls(0)` all raised
`RangeError: Maximum call stack size exceeded` in `dg_width`. This is the
full-Base harness path's recursive source-width traversal; a complete successful
parse observation was never established. The
[guard receipt](../../../selfhost/build/phase155/parser-controls02-guard/process.json)
records normal supervisor completion; that does not override the failed control
report. All source and failed-control artifacts remain retained unchanged.
The investigation stops here under its bounded budget, with no further retry,
native build, candidate semantic rejection or transfer speed claim.
