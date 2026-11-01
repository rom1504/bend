# Phase150: direct lexer production

The standalone native lexer experiment passes exact token controls and improves
the measured lexer-plus-observer region from roughly 4.48s to 0.85s on the same
current compiler source. The graph differential also passes, **hosted**: fifteen
complete `FLoadTrace` products are byte-identical after JSON observation and
satisfy independent Bend verdict/count expectations. This is a promising local
compiler optimization, not a qualified compiler release or a demonstrated 2x
complete-parser improvement.

This addendum reads completed receipts and current source. It launches no new
targets and makes no production edit. The coordinator owns aggregate costs,
full-parser measurements, integration, qualification and promotion decisions.
The separate full native parser ABBA campaign was still running when this
addendum was requested; its result must be reported independently.

## Exact experiment and clocks

The input is the 3,068,721-byte maintained compiler snapshot
[`source-baseline01/compiler.bend`](../../selfhost/build/phase150/source-baseline01/compiler.bend),
SHA256 `21657b5844c3168ad16acbe0de8096c7a3e7623ff3efbe8c710a09a97d091074`.
The [assembly receipt](../../selfhost/build/phase150/lexer-source01/assembly.json)
pins the extracted reference declarations and both candidate/probe modules.
The source passed the independent
[checked API acquisition](../../selfhost/build/phase150/lexer-check01/report.json),
and the same probe containing both implementations was built through the
[explicit native producer/runtime](../../selfhost/build/phase150/lexer-native01/report.json).

Each timing invocation reads the file and constructs its initial String before
the local clock. `lex_ms` ends after producing the complete token list.
`observe_ms` consumes the result, including all token text and six scalar fields,
into a token count and tagged checksum. `region_ms` covers both. No packed input
conversion, saved tokens, source cache or tokenizer result is supplied. The
outer guard's process wall also charges input, startup, reporting and any final
destruction not captured by the local interval.

| Invocation order | Role | Lex ms | Observe ms | Region ms | Guard process wall s |
| --- | --- | ---: | ---: | ---: | ---: |
| 1 | reference | 4554 | 65 | 4619 | 4.697462 |
| 2 | candidate | 796 | 63 | 859 | 0.942075 |
| 3 | candidate | 778 | 61 | 839 | 0.919924 |
| 4 | reference | 4285 | 61 | 4346 | 4.433857 |

Receipts: [1](../../selfhost/build/phase150/lexer-timing01-guard/process.json),
[2](../../selfhost/build/phase150/lexer-timing02-guard/process.json),
[3](../../selfhost/build/phase150/lexer-timing03-guard/process.json),
[4](../../selfhost/build/phase150/lexer-timing04-guard/process.json), with local
clock outputs in each sibling `stdout.log`.

The two-observation medians give 5.62x lex throughput and 5.28x complete observed
region throughput; the region difference is 3.6335s. These are two observations
per role in ABBA order, not confidence bounds. Observation cost stays near
61–65ms and cannot explain the several-second producer difference. The process
wall confirms that the gain survives ordinary input/reporting overhead in this
standalone executable. It does not establish the same magnitude inside a full
compiler image with different layout and ownership context.

## Correctness evidence and its limits

* [Native finite controls](../../selfhost/build/phase150/lexer-controls01-guard/stdout.log)
  pass 315 exact reference/candidate token-list comparisons: 63 texts under
  five cursor/lookbehind/depth configurations. Ten comparator controls include
  a positive token, seven independently changed fields and two list-shape
  mismatches. Coverage includes disabled cursors, U32 wraparound, seeded
  accumulators, comments, exponents, operator adjacency, malformed quotes,
  raw NUL and non-BMP characters.
* [Native full-input comparison](../../selfhost/build/phase150/lexer-compare01-guard/stdout.log)
  compares all seven token fields and complete list shape for **850,068 tokens**.
  Both consumed observations report checksum **3795131990**. The equality walk,
  rather than the checksum alone, establishes the finite native token parity.
* Both separately
  [checked reference](../../selfhost/build/phase150/parser-graph-reference-api06/report.json)
  and [checked candidate](../../selfhost/build/phase150/parser-graph-candidate-api06/report.json)
  graph APIs execute the fifteen Bend fixtures. Both calls to
  `p150g_expected(graphs)` return true. Eight cases require success and exact
  declaration-event counts; seven require independently specified error
  fragments. They cover ordinary definitions, datatypes/patterns, law filling,
  templates, module namespaces, two aliases of one module, Unicode/multiline
  literals, duplicates, incomplete headers, first-error order, bad escapes and
  missing imports.
* The [hosted graph runs](../../selfhost/build/phase150/parser-graphs01.json)
  produce identical **34,193-byte** JSON stdout, SHA256
  `d93530512f1a6da75b759f7be224175e76b0a0ec72aed3a90ee35a3e795b0552`.
  Complete values include result definitions/terms, diagnostics, import/load
  information and supplied located sources. Host code only invokes checked
  Bend, observes its values and compares bytes.

The complete graph oracle is hosted, not native. The native exact oracle covers
tokens, not complete graph objects. These finite checks do not independently
prove parser equivalence for all Strings/states, typechecker correctness,
generated-program behavior, or self-reproduction. String/Char references in two
raw literal fixtures need not be defined at this parse boundary; those cases
make no typechecking claim. No installed compiler, runtime ABI, public verifier
or proof declaration changed.

The earlier graph acquisition attempts remain retained. Their costs and failures
belong in the coordinator's campaign ledger; the successful API06 result does
not erase them. This addendum does not estimate the aggregate research cost.

## What changed

[`lexer-candidate.bend`](../../selfhost/tests/phase150/lexer-candidate.bend)
replaces one complete producer while retaining `FToken`, token lists, the input
String representation and every parser consumer. It uses direct `SCon` character
patterns for punctuation and bounded lookahead instead of building temporary
two/three-character Strings to compare. Word scanning retains direct head/tail
fields and its previous character. Quote scanning collects UTF-16 width and
final physical line/column during production, avoiding the old width and
physical-position walks over the completed quote. A small lookbehind scan
obtains the stored previous token's end column and final character together.

The candidate still materializes token/name character lists, reverses word and
token accumulators, and pays their ownership/destruction costs. It is not a lazy
parser, name-interning scheme, packed array adapter or global String ABI change.
The measured effect belongs to this combined producer change. There is no
isolated ablation assigning a percentage to quote fusion, punctuation dispatch,
lookbehind or fewer projections.

Legality details remain explicit in the
[source audit](parser-audit.md): actual NUL is not EOF; cursor zero disables
metadata; comments do not advance physical columns; previousEnd skips newline
advances; depth is modular; exponent signs also attach to names ending e/E;
`++`, `+bind`, `>` and `>>op` use stored previous text and physical adjacency.
Quote widths are added to the opening cursor once, preserving wrap-to-zero
behavior. Unterminated quotes retain their original opening error position.

The experiment adds **195 candidate lines** (23 definitions, two private types),
**212 probe lines** (26 definitions including `main`, two diagnostic types), and
**108 graph-fixture lines** (12 definitions), **515 lines total**. The JSON
dependency inventory is additional metadata. Only the 195-line candidate is a
production-integration candidate; probes, observers and graph fixtures stay
outside ordinary compiler roots. These are experimental physical line counts,
not a claimed net production source reduction.

## Transfer ceiling

The demonstrated standalone opportunity is about **3.6 seconds per complete
scan of this input**. Even deleting the reference scan entirely would remove
only its roughly 4.4s local producer cost in this executable. This scale cannot
support a forecast of halving a roughly 32s parse/load region by lexer work alone.

Do not subtract 3.6s from the historical Phase147 32.025s parse interval or its
246.173s cold build and present the arithmetic as a result. The source snapshot,
image layout, invocation count, surrounding ownership/cleanup and diagnostic
clock boundaries differ. Header scanning can invoke the lexer on a separate
prefix, and the full loader also contextualizes, validates and freshens syntax.
The current whole-parser pair must determine actual transfer; a subsequent
matched full compiler request must determine cold-build transfer. The expected
scale is a few seconds if the standalone effect transfers, with no evidence yet
for tens of seconds or a 2x full-parser result.

## Smallest safe integration and cleanup

First keep the proven boundary narrow: move the candidate declarations into one
maintained frontend module, register that module in the canonical source recipe,
and make the existing `f_lex_cursor` entry delegate with the same seven arguments
and `List<FToken>` result. Keep the old helper definitions and law declarations
unchanged for this first integration. Preserve the original extracted producer
as the independent test reference. No loader/parser call site or public data
layout needs to change.

This entry has five non-lexer maintained consumers: `f_header_next`,
`f_body_header`, `p140p_seed`, `p140p_relex`, and `p140p_seed_before`. Header/body
paths are therefore covered by the same entry switch. The incremental relex
path passes a seeded previous token, so its behavior must remain compatible;
the finite seeded-token tests are useful but do not constitute full incremental
qualification. Keep any existing qualification scope explicit.

The read-only current-source inventory finds:

| Definitions/type | Current dependency status | Cleanup implication |
| --- | --- | --- |
| `f_scan_word`, `f_scan_quote`, `f_lex_scanned`, `f_lex_quote_end`, `f_lex_symbol`, `f_lex_comment` | Called only within the old lexer family | Can become cold compatibility/reference code after entry replacement; do not silently remove public names |
| `f_two`, `f_pair_op`, `f_three`, `f_triple_op`, `f_symbol_text` | Called only by that old family; `load/imports.bend` mentions symbol spelling in a comment | Same later-removal candidate, subject to external export/test inventory |
| `f_ascii_char_eq` | Its current callers are the old scanner family | Can become cold, but its original law/signature remains part of the compatibility audit |
| `FScanned` | Used by `f_header_line` and `f_header_next` outside the lexer; also by the candidate word scanner | **Keep** the type and fields |
| `FToken`, `FInput`, raw token projections | Parser, diagnostics and incremental checkpoints depend on them | **Keep** their exact representations and APIs |
| `f_head`, `f_tail`, `f_ident`, ASCII classifiers | Reused by parser, validation, imports/header scanning, or retained public helper chains | **Keep**; lexical ownership of the source file does not imply a lexer-only dependency |
| `f_cursor_add`, `dg_units`, `dg_width`, `f_eq`, `f_choose` | Shared by parsing, synthetic tokens, diagnostics, source positions and other frontend logic | **Keep** |

In particular `f_raw_col` has no direct call outside its source file, but the
retained `f_col` accessor delegates to it. `f_ascii_ident_code` and
`f_ascii_space_code` similarly serve shared classifiers. A file-level grep is
insufficient to authorize their deletion. `FScanned` is a loader carrier even
though its declaration lives in the lexer module.

After successful integrated source checks, complete-product comparisons and the
coordinator's required native qualification, a separate cleanup can audit
unreachable implementation names against maintained API export manifests,
source tests, checkpoint adapters and protected declaration inventories. Preserve
any named helper contract and every original law body unless an explicitly
scoped compatibility change is intended. Removing a definition while leaving
its law or a frozen source-recipe entry is not a valid cleanup. The first
integration needs no such removal, and ordinary reachability can already avoid
emitting unused old helpers. Keep source checking, native correctness, timing
and promotion as separate decisions.
