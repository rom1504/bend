# Remove a complete function-body String copy

The smallest promising change is **suffix fusion at the existing function
renderer boundary**. It avoids flattening an instruction body and then copying
that entire linked String again just to attach `}\n`. It retains the existing
per-function streaming cursor and one ordinary write of each function. It needs
no runtime, QBE ABI, verifier or global String representation change.

The isolated implementation is prepared, not yet checked or measured in this
audit. Root owns compiler execution and native comparisons. The fresh Phase144
profile remains the authority for prioritizing this against other stages.

Follow-up: original real-function capture passed, but the native extracted
fixture did not produce a binary. See the acquisition failures below. The
body-tail change itself remains suitable for complete-program byte comparisons;
these fixture failures are not evidence of a compiler-output mismatch.

## What remains after previous streaming work

The exact source is Phase143 integrated-source03, SHA-256
`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
Relevant assembled-source locations:

| Location | Actual work |
|---|---|
| 30447–30450, `nt_text_finish` | Append each reversed fragment onto the accumulated suffix. This is linear in fragment characters, not quadratic in the growing result. |
| 40199–40204, `p111q_body_text` | Select the exact error marker or flatten all body fragments with empty suffix. |
| 40207–40210, `p111q_segment` | Compose the header, the flattened body and the closing brace/newline. |
| 44702–44708, `p113e_private` | Same whole-body boundary for private direct workers. |
| 53973–53981, `p126i_private` | Same boundary on the selected mode-two private path. |
| 57405–57426 | Actual private, legacy and public renderer selection. |
| 57428–57446 | Existing cursor holds structured IR and emits one function or bounded data slice. |
| 57537–57579 | Selected no-copy writer sends the text and legacy newline separately, with checked write failures. |

`++` is right-associative in the parser. Thus `header ++ body ++ footer`
contains an actual `String.append(body,footer)`. This is not an inference from
source line count alone: selected QBE
`selfhost/build/phase130/p143-reproduce01/program.ssa`, SHA-256
`99e0fc89b0c9c0f4fa85e7795183c31d452c366cedd6194b40cd20c33517e0c5`,
contains the following concrete paths:

- Line49248: the61-line `$p118.trmc.$direct.String.append` worker takes a
  two-field input node and calls `p118_rt_extend1` for the new destination.
- Line132953: the51-line `$direct.nt_text_finish` calls that append worker.
- Line397580: `$direct.p111q_body_text` calls `nt_text_finish` on success.

The selected Phase128 runtime's destination implementation explicitly states
that it does not infer unique input ownership or reuse input storage
(`runtime-borrow01/runtime.c:4578`). It allocates the new node before filling its
private link. A uniqueness-aware append is therefore a possible later runtime
experiment, not an optimization already eliminating this body copy.

## Bounded source change and legality

The helper [body-tail-v01.bend](../../selfhost/tools/performance/phase144/emission/body-tail-v01.bend)
accepts the existing `P111QCode` plus a suffix. Its success branch is
`nt_text_finish(chunks,tail)`. Its two failure branches return the same existing
marker followed by the same suffix, preserving error precedence.

For finite Strings, associativity and identity of append establish
`nt_text_finish(chunks,tail) = nt_text_finish(chunks,"") ++ tail`. No ordering,
ownership admission, numeric-name allocation or QBE instruction changes are
introduced. This is an equational argument, not a newly checked Bend law. The
allocation/reclamation schedule changes; native measurement must establish the
benefit.

The source-only preparation records **16 production call sites** whose complete
body renderer is immediately followed by the literal `}\n`. It replaces only
those expressions, and reversing each recorded edit restores every original
declaration byte. Existing `p128bf_oracle_function` remains unchanged as an
independent oracle. Two body-only diagnostic calls remain unchanged. No broad
pattern substitution, function-name benchmark recognizer or new optimization
pass is introduced.

Prepared source02 is
`selfhost/build/phase144/body-tail-source02/compiler.bend`, SHA-256
`7fb6564797c7c8ba51730c5e183609f3e9f9e4dc550fc86a35d7e121cc5bf781`.
The existing composer authenticates the parent and preserves all its protected
verifier/proof declarations. The production addition is one helper; the other
two new declarations are ten finite control rows and their observer. Source01
is retained as unexecuted preparation history: it also transformed an existing
oracle renderer, which source02 deliberately leaves independent.

## Complete native function experiment

The prepared [fixture tools](../../selfhost/tools/performance/phase144/emission/README.md)
avoid a full compiler-image acquisition:

1. Use the existing checked parent API to compile an ordinary frozen workload.
   Capture actual private, legacy and public cursor inputs. Require the complete
   emitted QBE to match its independent frozen product, not only sampled text.
2. Select actual small, middle and large wrapper outputs by byte size. Preserve
   the exact IR/context and the parent's complete function bytes as the oracle.
   The host only observes and serializes data.
3. Extract the dependency-closed **actual** `p134e_private`, `p134e_legacy` and
   `p134e_public` implementations:682 declarations, about242KB before fixture
   data. Build ordinary baseline and candidate Bend programs with the same
   qualified native producer/runtime. Only the candidate's body-tail expressions
   differ. This source closure has not yet been checked; a missing typing
   dependency must be repaired before calling it executable evidence.
4. First require both native programs to output the exact parent function bytes.
   Then time complete function rendering, File.write and output reclamation to
   `/dev/null`. Build retained immutable input before timing; each iteration
   regenerates its output. Do not add a String length/checksum traversal to the
   measured boundary. Calibrate to at least200ms per sample, alternate variants,
   and compare multiple sizes plus an unrelated workload family.

This is a complete function-render/write experiment, not a shared-String append
microbenchmark or a complete compiler-speed result. It excludes frontend,
optimization, registry preparation, fixture acquisition and machine build from
its timed kernel; report those costs separately. It retains shared immutable IR
across repetitions, so the complete cold request remains the eventual transfer
gate. Outer cursor legacy separators are excluded from both fixture variants;
the exact final function body and closing brace are included.

## Why not repeat batching or promise packed buffers now

Phase134 already removed whole-output retention and the per-piece `text ++ LF`
copy. Its [bounded packet experiment](../../selfhost/tools/performance/phase134/emission/BATCHING.md)
added length scans and String joins. A native request screen remained1.29%
slower than the same-block parent; no full-build improvement was established.
The isolated writer fixture also exposed the cost of per-effect helper-thread
round trips. Writing every instruction fragment separately would multiply them.

`File.write` already consumes String into a native UTF-8 buffer once, then
performs its queued write (`runtime.c:2499`, `:3448`). `File.write_bytes` consumes
a linked byte list through the same converter; it is **not** an existing packed
Array output API. Replacing String with List bytes alone would retain the
linked-node problem. A later `File.write_fragments` or packed-byte-buffer effect
would require an explicit typed runtime/provider contract, independent UTF-8 and
error tests, and admission/ABI work. Runtime byte marshalling could remain
generic; QBE formatting must stay in Bend. That larger change is deferred until
this smaller experiment establishes saveable work.

The historical Phase142 incremental render/close observation was53.362s, with
String.append owning20.50% of samples in that interval; those are overlapping
active contexts, not exclusive whole-build percentages. Earlier ordinary
rendering was also a significant stage. Neither implies that suffix fusion
removes the entire render stage, nor that emission alone can turn a315s build
into50s. Its value is a cheap, broad elimination of one repeated representation
pass. Larger gains require additional stage-level changes supported by the
fresh profile.

## Executed acquisition results and stopping decision

The root ran the following; this audit agent did not execute compiler targets:

- Capture01 matched the entire original Lexer product before failing the8MiB
  pretty-printed fixture cap. Evidence remains at
  `selfhost/build/phase144/render-capture-lexer01/report.json`.
- Corrected capture02 uses lossless compact JSON with an explicit16MiB cap.
  It passed in8.833s, observing980 pieces and the complete independent Lexer
  QBE. One input shrank8,183,185→1,276,970 bytes solely by removing JSON
  formatting; no compiler data changed.
- Native acquisition01 rejected `index_child_list`: the extractor retained
  its final untyped definition and lost its associated law. Version02 discovers
  dependencies from all same-name declarations and emits every selected source
  span in original order. This is a necessary fixture-factory contract, not an
  exception to source checking.
- Native acquisition02 of the787KB baseline timed out at150s before producing
  QBE. The guard records150.582s and160,026,624 bytes peak tree RSS:
  `selfhost/build/phase144/render-lexer-baseline-emit02-guard/process.json`.
  No native baseline or candidate timing is available.

Stop this fixture path for the current cycle. Do not increase its timeout or
attribute the delay to the candidate, which had not run. Complete real-program
QBE comparisons exercise the small source change more economically.

A later private-only fixture has a precise possible shrink: `p134e_private`
reads only `ids`, `lookups`, `heap` and `mode`. Its `index`, `direct`, `ready`
and `view` fields are discarded and never passed to a callee. For the captured
largest private function, those unread fields occupy about1.046MB of1.277MB
compact context JSON. Replacing them with typed empty values preserves the pure
String result on valid inputs, while changing irrelevant reclamation work. A
private-only closure could also omit public/legacy dependencies. This projection
and acquisition were **not implemented or measured** here.

## Direct compact names: bounded negative result

Phase132's reversible dense local-name experiment removed about46% of QBE text
and preserved allocated machine sections, but its host rewriting cost exceeded
the machine-build saving. That is not evidence for a Bend emitter speedup. A
source-only audit tested a cheaper possibility: encode three known generated
name grammars at `p111q_local` into a disjoint reserved `%Z…` namespace, with no
lookup table on emitted tokens.

The static census of the current116,477,541-byte full QBE found:

| Grammar | Occurrences | Potential bytes removed |
|---|---:|---:|
| `v_p113i_<site>_local_<rest>` |266,285|3,195,420|
| `v_p113p_move_<rest>` |65,397|719,367|
| `v_p113p_call_<rest>` |16,269|178,959|
| Total |347,951|4,093,746 (3.51%)|

The artifact has no existing `%Z` local names. The hypothetical mapping is
injective on observed variables; its classes retain the complete remainder and
have disjoint prefixes. This remains a static ceiling, not an implemented
encoder or native speed claim. Receipt:
`selfhost/tools/performance/phase144/emission/names/census-v01.json`.

Do not implement this narrow recognizer merely because the old dense-renaming
number was large. Its byte opportunity is much smaller, and prefix inspection
would add String work on millions of references. Assigning compact handles once
when names are created is more promising in principle, but current semantic
names encode admission/provenance information: `p113i_name` excludes a reserved
prefix, `p113j_buffer_peel` recognizes inlining origin by that grammar, and
`p113a_local_name` reserves another namespace. A creation-time change must retain
those facts explicitly. Renderer temporaries also bypass semantic name
creation, so changing one binding helper cannot realize the46% ceiling.

## Larger structural output options, not implementations

The fresh stage split reports18.284s in registry preparation and51.845s in
rendering; String.append owns22.3% of rendering samples. These are distinct
boundaries, and active-owner samples are not exclusive allocation counts. Even
eliminating all rendering would leave most of the315s build.

If suffix fusion passes its exact-output and native gates, the next serious
output design is a **generic typed fragment-write boundary**. Keep QBE formatting
and instruction selection in Bend. Carry the existing ordered instruction
Strings, header and footer into one runtime effect that encodes them into one
bounded native byte buffer and performs one write. This removes whole-body
flattening without the per-line effect round trips of a naive fragment writer.
The pure compatibility API can still materialize a String from the same
fragments for independent byte comparison.

This requires a new IO/provider contract, not a reinterpretation of File.write's
String argument. Fragment ownership, UTF-8 boundaries, empty pieces, partial
writes, errors, close behavior and bounded buffering all need controls. A linked
List of bytes is not a packed buffer. The runtime must perform generic byte
marshalling only, without QBE rules or optimization decisions. This larger
design is deferred, not added silently to the current experiment.

A uniqueness-aware String append/splice could transfer beyond emission, but
root uniqueness does not prove that every interior tail is unshared. It needs
a shared-suffix fallback and a precise RFC/ownership contract. Earlier rejected
generic cell-credit work does not establish such a whole-list operation. Prefer
the fragment-write boundary unless profiles show sufficient append work outside
rendering to justify the wider runtime risk.


## 2026-10-26 consolidation update

The18.284s/51.845s stage budgets and315s whole-build example above describe the
earlier compiler. Source01's fresh diagnostic measures17.400s registry and
47.831s rendering/output, with output-tail String.append samples350→240.
That supports the suffix-copy elimination but leaves construction and flattening
costs; it does not profile the later final03 append/predicate/serial composition.
The generic fragment-write boundary remains a proposal.
[Current profile](integrated-profile.md) and [append experiment](string-append.md)
retain the newer measured scope separately.
