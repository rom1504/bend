# Bounded audit: QBE text construction and native output

There is real avoidable materialization, but the existing data do not support
calling it a 2x whole-request opportunity. The compiler already returns a list
of strings and writes those chunks individually. The best first experiment is
to remove one known extra join, then measure actual rendering separately from
preparation and lowering.

## Current implementation

Source: `combined-literals-source01/compiler.bend`, SHA256
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.

- `P111Emission` stores `List<&2,String>` and an error, not one module string.
  `p111_print_emission` checks the error before `p111_print_chunks` calls
  `IO.print` on each chunk. The convenience `p111q_text` performs a whole-module
  join, but the native request path does not use it.
- `P111QCode` accumulates lines in reverse order. `p111q_body_text` calls
  `nt_text_finish`; that helper appends each new line on the left of a growing
  suffix. It is linear in total text, not repeated copying of a growing prefix.
- Each private/public function is still flattened to one String. There are
  further header/body/footer concatenations. `p111q_args` flattens argument
  fragments, and `p111q_data` flattens each entire data table.
- A concrete extra copy survives: `p113a_registered` and `p113e_registered`
  `nt_join` **all old private-worker function strings**, then `p112c_attach`
  appends the entire joined block to the first public function string. This
  preserves an older one-chunk-per-original-segment convention. The active
  `p118z_bundle` path still reaches these registered emitters.
- The full list of rendered strings is constructed before the IO consumer
  receives `P111Emission`. Existing chunked output therefore does not mean
  incremental function rendering with a bounded live output buffer.

The selected runtime `runtime-borrow01/runtime.c` implements `IO.print` by
consuming the Bend String into a UTF-8 C buffer (`io_cbuf`), then writing the
buffer and one newline. The buffer grows geometrically from 64 bytes and is
freed after writing. Thus it already avoids a second retained Bend String at
the output boundary, but it still needs a per-chunk UTF-8 materialization.

`IO.write` exists in the pinned upstream Base, but is **not** in the selected
native runtime admission catalogue/provider list. It cannot simply be used
without a runtime capability update. `File.write` is available and can write
fragments without inserting newlines to an explicitly opened output file.
Fabricating a stdout File handle is not a valid existing interface.

## What the profiles establish

`identity/render-profile01.json` aggregates the existing Phase131 profiles of
the selected **Phase130** compiler. These are not final N2 profiles. Physical
caller recovery was unavailable; active dispatch owners are not an inclusive
emission call tree.

| Active context | Lexer | Closures | Map |
|---|---:|---:|---:|
| `String.append` sample fraction | 4.81% | 3.62% | 5.82% |
| `nt_text_finish` sample fraction | 0.84% | 0.12% | 1.23% |
| `nt_join` sample fraction | 0.24% | 0.23% | 0.25% |
| `nt_join` + `p112c_attach` allocation calls | 257,843 | 74,779 | 402,495 |
| Same calls / all allocation calls | 1.09% | 0.86% | 1.19% |

`String.append` accounts for 7.19 million lexer, 1.11 million closure and
10.86 million Map allocation calls. These include names, mangling, frontend
operations and other compiler text; attributing all of them to QBE rendering
would be false. Runtime conversion/writing has almost no directly observed
samples (one `io_cbuf` closure sample, one Map write sample), so a write-only
optimization is poorly supported by this campaign.

The join/attach counts show concrete removable work, but their small aggregate
share suggests a low-single-digit complete-request gain, not parity by itself.
No defensible bound on *all* function/line rendering follows from these profiles.
The final N2 profile should identify append/reclamation callers or measure an
explicit verified-program-to-emission interval before assigning a larger gain.

## Small decisive experiment

1. Freeze an actual final verified `P113AProgram` for lexer and Map using a
   checked diagnostic API. Reuse that immutable value across rounds; do not
   include source preparation or optimizer work in the render interval.
2. Baseline: run the existing admitted renderer and force/consume every emitted
   byte. Alternative: retain the already existing old-private String list
   instead of `nt_join` plus `p112c_attach`. Keep function renderers unchanged.
   Compare exact concatenated bytes under the original newline protocol.
3. Count rendered bytes, maximum chunk bytes, old-private block bytes and
   allocations. Alternate render-only timings. This cheaply falsifies the
   hypothesis that this particular historical boundary is worth changing.
4. If promising, extract one real large private function and one real data table
   with their frozen IDs. Compare existing String rendering with fragment
   rendering and consume both through the same native `File.write` endpoint to
   a fresh temporary file. Verify exact bytes with an independent oracle.
   Preserve the existing verification before any output is published.
5. Only after measured benefit consider a native CLI render-and-write interface
   for already verified functions. Preserve complete error checks, ordering,
   exact bytes and stack safety; use immutable IDs and the existing runtime.

The newline protocol is a real constraint: `IO.print` adds a newline to every
chunk, while old private workers currently share one enclosing chunk. Naively
splitting that list changes frozen output bytes. One possible native-only
adapter is to render old-private functions without their final newline and let
`IO.print` restore exactly that byte; headers/bodies need not be split yet.
Do not silently change `P111Emission`'s transport interpretation or ordinary
error/publication behavior.

A checked API render-only discriminator is economical and useful for rejecting
the idea, but its hosted timing is not native speed evidence. It should precede
another full compiler acquisition. No prototype or runtime change was made in
this audit.

## Comparison with upstream

The pinned upstream C emitter also accumulates arrays of lines and joins them
per segment and eventually across the module (`bend2/comp.ts`, `c_compile`).
Its joins operate on native JavaScript strings. This is evidence against
assuming that one final text buffer is inherently bad; Bend's linked String
representation, runtime transitions, ownership and copying cost make the same
surface algorithm more expensive. The useful comparison is bytes traversed,
allocated and reclaimed under the actual representation, not the count of
`.join` calls in TypeScript.

The source-grounded priority is therefore: measure final N2 rendering exposure;
first remove the old-private double join if profitable; then consider retaining
line fragments through a verified output interface. Avoid a new string runtime
or broad emitter rewrite before those small experiments establish a ceiling.
