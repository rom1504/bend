# Phase150 grouped lexer dispatch candidate

Initially a source-only alternative; the coordinator subsequently checked and
executed it, preserving exact token/graph behavior and measuring24.186s small-
probe acquisition versus30.766s for the first variant. The final scalar variant
is preferred. This intermediate source is retained as
`selfhost/build/phase150/variants01/grouped.bend` in the
[evidence capsule](../../implementation/phase150/evidence/README.md), avoiding a
second preferred module at HEAD. It is an exclusive module replacement with
the same entry/helper/type names, never concatenated with another variant.

The coordinator's preliminary parser-image acquisition pair was
46.506s reference versus 66.665s fast lexer; emission plus QBE was 45.04s versus
65.19s, while emitted QBE grew only about 0.69% (28.241 to 28.436MB).
The separate 34KB lexer probe cost about 30.77s to acquire. These observations
motivate investigating source compilation cost, not a confirmed attribution to
pattern desugaring. Repeats/profiles and campaign accounting remain coordinator
owned. Faster execution of the resulting lexer does not make acquisition free.

The only changed declaration spans are `p150l_other` and `p150l_symbol`.
Read-only comparison using maintained `source.py` blocks confirms identical
declaration inventory, preamble and every other declaration byte. The new module
is 218 lines / 11,688 bytes, SHA256
`abdaebbb16be9c4b32ef7183b8fccbc7ee4c3e4bec6a16c42d3a8f361a282e3b`.
Its 195-line parent is SHA256
`17d069235aea4c48909cc8d4ec62aec546988c1d9f527245c5b9ec2f34a8b98c`.
There are no new helper definitions, data types, runtime APIs or algorithms.

Both changed functions now dispatch on the first Char before matching the rest
String inside that branch. This removes their multi-column Char/String pattern
matrices and makes the intended decision tree explicit. Smaller independent
matrices may cost less to flatten/analyze during acquisition; that is the
experiment's hypothesis, not an established compiler mechanism or speed gain.

The operator audit is:

| First character | Priority and fallback |
| --- | --- |
| `.` in `p150l_other` | Exact `.&.`, `.|.`, `.^.` first; otherwise begin a word containing the dot, leaving all remaining characters for the unchanged word scanner |
| `<` in `p150l_other` | Exact `<&>` first; otherwise pass the unchanged rest to `p150l_symbol` |
| `+`, `>` in `p150l_other` | Unchanged adjacency-aware helpers; preserve `++` suppression, `+bind`, `>>op`, `>op` and `>=` |
| `-` in `p150l_symbol` | `->`, otherwise single `-` |
| `=` in `p150l_symbol` | `=>` or `==`, otherwise single `=` |
| `<` in `p150l_symbol` | `<-`, `<>`, `<=`, `<<`, otherwise single `<`; this helper alone still does not recognize a triple |
| `!`, `&`, `|` in `p150l_symbol` | `!=`, `&&`, `||` respectively, otherwise the corresponding single character |
| All other characters | Original single-character construction, depth adjustment and `dg_units` call |

All pair branches consume exactly the second character and preserve depth.
All triple branches consume exactly the second and third characters and preserve
depth. Every fallback retains the original rest, including empty input, partial
triple prefixes and real NUL. The six specialized single-character fallbacks
are ASCII nondelimiters, so literal text, unchanged depth and width one are
exactly the old generic fallback's values. Quote, word, cursor-wrap, newline,
comment, lookbehind and observation code remain byte-identical to the parent.

Reusing the existing exact token controls and full-input comparison is the
smallest semantic discriminator. Root will choose whether acquisition/profiling
evidence justifies that target cost. No production source was changed and no
target was launched while producing this alternative.
