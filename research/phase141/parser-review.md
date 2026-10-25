# Independent review: one top-declaration parser

Reviewed source, not target execution. The proposed implementation is
`selfhost/tools/performance/phase141/parser/core-v01.bend`, SHA256
`18f7e8ffe2d0614190e01700cedc2953063931728f0cd750565e7e9ecc9b117a`, with
`deletion-v01.json`. Its parent is Phase140 source18,
`c9ded5523c4d4c3ca9b700c4aff12cd77e02043684f0472ed2f8ec8c412b6313`.

**Conclusion:** no source-semantic blocker found for retaining the stop-aware
SCC as the sole implementation and preserving `f_tops`/`f_top` as zero-stop
compatibility entries. Source checking, independent result comparisons and native
cost remain required. This is not a proved parser-equivalence theorem.

## Actual deletion boundary

The frozen Phase140 derivative contains34 mutually recursive parser functions.
An independent source18 call census finds only these external inbound edges:

| Retained entry | Callers outside the original SCC |
|---|---|
| `f_tops` | `f_header_next`, `f_body_header` |
| `f_top` | `p140p_seed_stopped`, `p140p_resume_lexed`, `p140p_before_stopped` |

Thus the proposed32 internal definitions and17 corresponding forward `law`
declarations can be deleted from this assembled candidate. The original
`f_tops` and `f_top` law signatures must remain. Do not delete their callers,
`f_result`, expression/lexer/context helpers, or the stop-aware declarations.

A repository tool search found historical Phase16/20 source-rewrite scripts
naming some removed internals; those frozen methods/snapshots stay unchanged.
No current Phase140 runtime/API entry requiring those32 names was found. This
is not a promise that an arbitrary historical tool exporting an undocumented
internal parser helper will work against the new image. Public source parsing,
loading and compiler entrypoints are the compatibility target.

## Independent mechanical bridge

The derivative was originally produced by `phase140/parser/clone-v02.py` from
qualified Phase137. I independently compared the actual Phase140 source18
definitions with `top-parser-v02.bend` by reversing:

* the34 internal name replacements;
* the threaded stop argument and corresponding law parameter;
* `P140PStop` transport and `p140p_result` wrapper;
* only the additional outer stop branch in `p140p_top`.

All34 function bodies **and their associated law signatures** matched after
whitespace/comment normalization. No remaining expression difference was found.
This is a source correspondence check, not compiler execution, an AST theorem,
or evidence about runtime performance.

The only cut-producing branch requires `U32.is_gt(stop,0)`. Every recursive call
inside the derivative passes the same stop value. With stop0, the cut cannot be
chosen, and terminal/error results become `P140PDone{f_result(...)}`. The adapter
unwraps exactly that raw result. Its defensive cut arm resumes all five actual
continuation fields using stop0; it does not fabricate a diagnostic or reset
parser state.

`f_tops` still invokes the skip-aware `p140p_tops`; `f_top` invokes
`p140p_top` directly. Interchanging them could change whitespace/boundary
behavior. The current19-line module preserves this distinction.

## Semantic contracts preserved by the proposed source

* Definition/import accumulators remain reversed until the original `f_result`
  reverses them once. The adapter must neither reverse nor reconstruct them.
* `FRawResult.error` stays a full `KTerm`, including diagnostic variants and
  source spans. `fpe_finish_indexed` and `f_context_result` remain outside the
  parser at their original call sites, preserving rendering and contextual
  completion order.
* Current `FParseContext` carries scope, environment and fresh identifier state;
  `FParseScope` carries prior declarations, both indexes, namespace and aliases.
  The derivative delegates to the exact original context helpers.
* Pending `@unsafe`, law filling, constructor publication, duplicate checks,
  import aliases and error precedence are unchanged expressions. No malformed
  input is newly accepted merely because it cannot reach a checkpoint.
* Positive-stop parsing remains unchanged. The checkpoint's newline provenance,
  exact previous/current token, UTF16 origin, lookbehind, source-prefix and
  initial-scope checks remain in `checkpoint-v02.bend`.
* The first suffix-token gate is essential: replacing a following declaration
  with `+`, `-`, `|`, `&` or `->` can extend the previous expression. Parser
  unification does not justify removing this already-demonstrated guard.
* Failed suffix parsing retains the prior checkpoint for recovery; ordinary
  prefix misses still use fresh parsing. This experiment does not change those
  cache publication/invalidation rules.

All34 original SCC definitions were already `@unsafe`; this refactor should
not add opacity, weaken source checking, or describe parser forward type laws
as new semantic proofs. Preserve the existing independent compiler proofs and
verifiers byte-for-byte. Check declaration-order admission explicitly: the early
compatibility definitions now refer to later stop-aware declarations. A complete
checked-source build is required rather than assuming `@unsafe` excuses a
missing or unfilled law.

## Main risk: ordinary native parsing cost

The original ordinary parser did not thread stop or return `P140PDone`. The
additional result box is terminal/error transport, not necessarily one new box
per declaration. However, stop0 is not guaranteed to propagate as a constant
through the recursive SCC in the generated native compiler.

Six functions cross from eight to nine source parameters:

* `f_context_law_open`
* `f_def_body`
* `f_def_prior`
* `f_law_where`
* `f_type_ctor_header`
* `f_type_ctors`

Several current private-worker/region/call-resume admission paths explicitly
limit arity to eight (`p112c`, `p114r/g/h`, `p124r`). Other direct/generic routes
have different bounds, so a regression is a **risk**, not a demonstrated result.
Inspect actual admitted workers and scheduler transitions if ordinary native
parsing slows down. Do not immediately introduce a second zero-stop parser or a
large context record to repair an unmeasured problem; that could reverse the
mechanism deletion or add allocation costs.

A hosted API check alone cannot establish this performance contract. Measure
same-input ordinary parsing and one warm checkpoint resume with the same native
toolchain policy; use the existing stage harness rather than a full bootstrap
for the first discriminator. Full compiler image output naturally changes when
its source loses definitions; that is not a user-program semantic regression.

## High-value adversarial comparisons

Compare against the independent original Phase140 API, not just two calls routed
through the new adapter. Observe complete raw/result graphs, partial declaration
and import lists, diagnostics, spans and fresh IDs, not only success or final
printed values.

1. **Terminal and first-error behavior:** empty input, trailing whitespace,
   malformed first/later definition, and an earlier error followed by another
   malformed declaration. Preserve partial books/imports and exact first error.
2. **Pending state:** `@unsafe` before a valid def, law/type, import and EOF;
   law declaration then body fill; missing/duplicate law fills; constructor
   duplicate and imported-alias collisions.
3. **Declaration grammar:** parameterized ADTs, multiple constructors, erased
   parameters, `where` clauses, foreign import paths, and imports appearing
   after declarations. These exercise multiple members of the deleted SCC.
4. **Cursor/context:** nonzero source origin, non-BMP text before the failure,
   comments and multiline strings, namespace/alias scope, and nested expression
   newlines. Preserve all span fields, not just the rendered message.
5. **Actual checkpoint paths:** seed/resume, suffix failure then recovery,
   prefix miss, `@unsafe` across the cut, and the existing operator/lookahead
   negatives. Both original external parser entries are exercised here.
6. **Complete compiler products:** existing frozen Lexer/Map/closure requests
   with exact QBE, plus retained JS/C frontend or product controls where their
   entrypoints are assembled. No backend changes are intended.

Reuse the existing Phase140 boundary and loader controls; add missing tests
because they probe a changed boundary, not to mirror every parser function.
Source checking and these finite comparisons support promotion decisions but
do not constitute whole-parser correctness. Native qualification remains a
separate step from this bounded simplification.
