# Phase150 maintained literal-pattern screen

The frozen [canonical baseline](../../selfhost/build/phase150/source-baseline01/compiler.bend) contains **96 numeric-leading case rows in 27 functions**. Every numeric scrutinee in this inventory is **U32**, not Nat: 25 explicit definition signatures and two separate laws (`j_escape_char_on`, `p90_fork_round`). All 27 return fixed types, so they are potentially nondependent dispatch rewrites, not automatically legal transformations.

After separating eight control helpers (16 rows) and two protected proof helpers (3 rows), **17 ordinary compiler functions / 77 rows** remain. The current owning declarations match the frozen baseline after comment/whitespace normalization. Exact ownership, pattern text and type evidence are in the [inventory](literal-pattern-audit.json). Source SHA256: `21657b5844c3168ad16acbe0de8096c7a3e7623ff3efbe8c710a09a97d091074`.

| Function | Owning module under selfhost/src | U32 argument → fixed result | Rows |
| --- | --- | --- | ---: |
| `sk_char` | [check/specialize.bend](../../selfhost/src/check/specialize.bend#L130) | `n` → `String` | 7 |
| `j_escape_char_on` | [back/js/shared-text.bend](../../selfhost/src/back/js/shared-text.bend#L35) | `key` → `String` | 6 |
| `nb_regs` | [back/native/tables.bend](../../selfhost/src/back/native/tables.bend#L52) | `n` → `List<&2,String>` | 1 |
| `p90_fork_round` | [back/native/fork-index.bend](../../selfhost/src/back/native/fork-index.bend#L39) | `fuel` → `List<&2,String>` | 1 |
| `nct_within_work` | [back/native/text-tree.bend](../../selfhost/src/back/native/text-tree.bend#L52) | `remaining` → `Bool` | 1 |
| `p88_text_chars` | [host/prepared-base.bend](../../selfhost/src/host/prepared-base.bend#L87) | `size` → `P88TextRead` | 2 |
| `p88_roles` | [host/prepared-base.bend](../../selfhost/src/host/prepared-base.bend#L121) | `tag` → `List<&2,U32>` | 12 |
| `p88_role_empty` | [host/prepared-base.bend](../../selfhost/src/host/prepared-base.bend#L139) | `role` → `P88Node` | 3 |
| `p88_field_number` | [host/prepared-base.bend](../../selfhost/src/host/prepared-base.bend#L153) | `role` → `P88Step` | 4 |
| `p88_bool_value` | [host/prepared-base.bend](../../selfhost/src/host/prepared-base.bend#L166) | `n` → `P88Step` | 2 |
| `p88_build` | [host/prepared-base.bend](../../selfhost/src/host/prepared-base.bend#L212) | `tag` → `P88Node` | 17 |
| `p88_records` | [host/prepared-base.bend](../../selfhost/src/host/prepared-base.bend#L268) | `left` → `P88Decoded` | 1 |
| `p111q_segment_datum` | [back/qbe/emit.bend](../../selfhost/src/back/qbe/emit.bend#L255) | `kind` → `P111QDatum` | 3 |
| `p112s_descriptor_item` | [back/qbe/static-data.bend](../../selfhost/src/back/qbe/static-data.bend#L390) | `index` → `P111QDatum` | 2 |
| `p112fp_binary` | [back/qbe/fused-regions.bend](../../selfhost/src/back/qbe/fused-regions.bend#L3) | `id` → `String` | 10 |
| `p113p_array_arity` | [back/qbe/flat-products.bend](../../selfhost/src/back/qbe/flat-products.bend#L71) | `id` → `U32` | 4 |
| `p126sc_zeros` | [back/qbe/product-composition.bend](../../selfhost/src/back/qbe/product-composition.bend#L585) | `count` → `List<&2,N111Value>` | 1 |

Six excluded helpers live in `tests/compiler/native-controls.bend`: `p113wt_op`, `p114st_functions`, and the four `p118nsc_*` builders. Two more, `p118np_flat/nested`, live in `back/qbe/native-transport.bend` but feed its scale controls. `p131a_low/high` in `core/index-laws.bend` are explicitly protected proof declarations. Their fixed U32 signatures do not authorize changing them.

Start with **`p88_roles` alone** (12 rows): it maps a U32 tag to an exact fixed list with an empty-list fallback. Then consider **`p112fp_binary`** (10 rows), preserving its invalid-operation string. **`sk_char` and `j_escape_char_on`** supply 13 more fixed-result escape cases, with distinct JSON/JS fallbacks that must remain exact. Compare a scalar-equality spelling using the same parent/assets, exact table/fallback outputs, source acquisition and resulting function runtime before transferring any change.

**`p88_build`** has 17 numeric-leading rows and is a larger later candidate. Its tag dispatch is coupled to field constructors: tag1 has several shapes, malformed forms return `P88Bad`, and spans/literal validity are checked. A tag-first rewrite must retain all of those decisions and affine consumption. The prepared-base module totals 41 such rows across seven functions; this is source concentration, not measured cost attribution.

A quote-aware case-head scan corrects the broad grep counts: there are **two genuine Char-pattern rows** (newline in `p88_digits` and `p88_text_chars`) and **25 genuine String-pattern rows**, all in the three Phase147 runtime-name classifiers in [ownership.bend](../../selfhost/src/back/qbe/ownership.bend#L480). Two prefix patterns there additionally contain 16 numeric `Chr{…}` fields. Those classifiers deliberately improved runtime; a source rewrite could reverse that gain, so test acquisition and classifier runtime together with existing closed-name/suffix-refusal controls.

The numeric-leading inventory is not exhaustive: a secondary scan found **44 additional case-start lines in 40 functions** with numeric fields later in the pattern. That untyped secondary inventory is retained in JSON; multiline continuation fields are not fully counted. Most are structured QBE recognizers, where shape guards and continuation semantics require a separate audit.

The scalar lexer probe is strong transfer motivation, not evidence of a fixed cost per pattern. No whole-compiler saving follows from these counts. A general compact-literal-pattern implementation must preserve dependent constructor refinement, substitutions, typing refusals, quantities/ownership, fresh IDs, spans/errors and proof/kernel interfaces. This audit ran no targets and changed no compiler source.
