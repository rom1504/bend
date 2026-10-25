# Phase140 parser prefix checkpoint

Experimental, append-only, not installed or native-qualified. The current
reviewed composition is `selfhost/build/phase140/parser-source04/manifest.json`
(source SHA `8173683feae1bfe09654f72df73f33b7e7cac698203c593796cb429e03c4c4c0`).
Its independent checked API is
`selfhost/build/phase111/p140-parser-api04/report.json`.

Use these modules, in order:

1. `types-v01.bend`
2. `top-parser-v02.bend`
3. `checkpoint-v02.bend`
4. `controls-v03.bend`
5. `bridge-v01.bend`

All original qualified Phase137 declarations, verifiers, proofs, native entry
and runtime remain unchanged. `clone-v02.py` reproduces a mechanical derivative
of the actual 34-function top-parser SCC: it threads a stop cursor and returns
either the original raw result or the actual parser continuation. Expression
parsing, lexing, contextual completion, validation and freshening call their
original implementations. This derivative adds 495 lines; it is a bounded
experiment, not a proposal to maintain two independent parser implementations.

## Interface and preserved work

`p140pl_load(seed,path,text,cache,hint)` returns either:

- `P140PLoadReady{load:FPrefixLoad,cache:Maybe<P140PCache>,hit:Bool}`;
- `P140PLoadError{error:String,cache:Maybe<P140PCache>}`.

The `seed` is the actual authenticated `P86Seed`, and `cache` is either `None`
or a checkpoint previously produced by this same checked producer. The hint
is an **absolute UTF16 source offset**, and acquisition stops at the first
actual top-level `def`, `law` or `type` boundary at or after that hint. Select
an unchanged function boundary before the intended edit; passing an interior
edit offset can instead choose a later boundary and produce a correct miss.
No host parser or host source splitting supplies the continuation.

The bridge follows the ordinary `p86_plan` path through source location,
header/import gates and prepared Base completion. Its only substitution is
contextual source parsing inside admitted indexed completion. It then invokes
original `f_graph_finish_indexed`, `f_prefix_ready_source_completed`, and
`f_prefix_graph_trace`. Full validation and global freshening remain paid.
The checker agent receives the actual post-freshening `FPrefixLoad`; parser
reuse alone authorizes no checker or backend reuse.

A warm hit avoids lexing and parsing the unchanged prefix, including rebuilding
that prefix's evolving contextual declarations. It still pays exact prefix and
initial-scope comparison, suffix lexing/parsing, completion, validation,
freshening, and all later compilation. No warm full-compiler speedup has yet
been measured by this module's tests.

## Admission and lexical boundary

The cache stores actual `FParseContext`, reverse definition/import accumulators,
pending unsafe flag, and `FParseScope`. It also retains the original source,
origin, current token, and the exact previous lexical token. A cut is admitted
only when the current token exists verbatim in the original token stream and
follows an emitted newline. The original lexer emits newlines only at nesting
depth zero. Resume seeds lexer lookbehind with the original previous token,
uses the original line/column/UTF16 origin/previousEnd, and removes only the
seeded lookbehind token from the new token output.

Warm admission requires the same source origin, complete exact initial scope
(namespace, aliases, prior definitions, name and constructor indexes), and an
exact character prefix through the cut. Structural comparisons preserve KDef
and KTerm variants, fields and source spans; hashes alone grant no reuse. The
freshly lexed first suffix token must also equal the saved token in every field.
Cuts occur only at `def`, `law` or `type`; `@unsafe` is parsed first and its
pending flag is part of the captured state.

The first-token gate is necessary. Preserved experiment `parser-boundary01`
showed five mismatches in the earlier prototype: replacing the following
`def` with `+`, `-`, `|`, `&` or `->` could extend the preceding expression.
An unchanged prefix alone therefore did not prove an unchanged parser state.
Source04 refuses these changes and falls back to fresh parsing.

This is a private, fixed-producer, in-process cache contract, not a decoder for
untrusted serialized states. The public bridge derives the current header from
source itself. Low-level seed/resume helpers assume their header and cache came
from the original scanner and this producer; forged records are outside the
contract. Failed suffix parsing retains the old checkpoint for recovery. A
prefix miss falls back and also retains the old checkpoint; it does not acquire
a new changed-prefix checkpoint automatically. Only one prefix generation is
retained, including the original full source and its shared parser objects.

## Evidence

All paths below are under `selfhost/build/phase140/` unless specified.

- `parser-api-guard04`: independently checked source04, 10.20 seconds,
  1.14GB peak process-tree RSS; API in Phase111 as linked above.
- `parser-bridge02`: 20 Bend finite controls pass; three frozen real programs
  each pass cold acquisition and no-op/body-edit/prefix-edit/recovery comparisons
  against the original loader. Equality observes the complete FPrefixLoad object
  graph, including spans, current source metadata and freshened identifiers.
  Four malformed header/import/suffix cases match original P86 error plans.
  Guard cost 7.74 seconds, 262MB peak.
- `parser-boundary02`: all nine adversarial boundary changes match fresh parsing;
  changed initial token is refused. Additional actual checkpoints across
  `@unsafe`, comments with non-BMP text, nested newlines, and a multiline quoted
  string all hit and agree with fresh results. Guard cost 0.61 seconds,118MB.
- `parser-boundary01`: retained negative evidence from the old first-token-free
  prototype. Do not use source02/03 for integration.
- `parser-api-guard01`: an early checker failure, fixed by explicit String
  annotations in controls-v02; original failed modules remain preserved.

The three small-program observations are correctness screens, not balanced
performance trials. Some warm loads are slower than fresh loads because exact
Base-scope checking is larger than the skipped short prefix. The experiment is
motivated by the approximately44-second full-source parser cost, not these
small-program timings. Charge scope/prefix comparisons, cache acquisition and
retained memory in the eventual large edit experiment. No target/native build
or production selection was changed by this lane.

## Remaining tests and possible simplification

The root integration must compare the complete checked/compiler output for a
real compiler edit and preserve the independent final backend verifier. It
must measure actual prefix size skipped and warm/cold cost separately. Native
stack use and peak retention have not been qualified by hosted API tests.

A next small improvement could choose a lexical declaration landmark at or
before an edit hint during the existing cold token scan, then require the
actual top parser to reach a cut no later than the hint. This would improve
hint usability without treating lexical landmarks as semantic certificates.
Longer term a parser callback/checkpoint interface could remove the mechanically
cloned SCC, but changing the production parser is outside this experiment.

## Optional edit-offset landmark extension

`parser-source05` (SHA
`4414a5033474fcb6340d762d0d55b9a64346eba93a7bf8502327014a3b6d010a`)
adds `hint-v01.bend` and replaces only experimental `bridge-v01.bend` with
`bridge-v02.bend`. No qualified declarations change. Its checked API is
`selfhost/build/phase111/p140-parser-api05/report.json` (9.67s,1.19GB).

In this composition the bridge's `hint` is an **absolute edit position**.
The already-produced cold lexer stream is scanned for the last column-zero
`def`/`law`/`type` landmark at or before that position. The ordinary top-parser
continuation still certifies the checkpoint. If it reaches a real boundary only
after the edit position, acquisition finishes normally without retaining that
checkpoint. There is no second lex and no host source splitting. Zero continues
to disable checkpoint acquisition. Low-level `p140p_seed` retains its original
first-boundary-at-or-after interface; `p140p_seed_before` is the new explicit API.

`parser-hint03` passes six actual parse/reuse cases (body offset, unsafe state,
Unicode, exact keyword offset, disabled and no useful prefix) plus four lexical
landmark controls. Failed `parser-hint01/02` expose host-only malformed synthetic
FToken fixtures: field names must be `f_line/f_col/f_kind`, not guessed names.
All six actual parsed-source cases already passed in those attempts. The method
was fixed and the failures retained; no Bend source fix was needed.

`parser-bridge04` repeats the20 finite controls, all three actual prepared-Base
loader comparisons with **interior body edit positions**, and four original
P86 diagnostic comparisons. `parser-bridge03` already passed every real program
but its final tiny error fixture requested a point in the first declaration,
where no useful preceding newline checkpoint exists; the harness now requests
the actual second-body edit. This remains a correct conservative miss.

The extension improves caller usability, not the exact matching or lifetime
contract. The same large-edit cost and native qualification gates still apply.
