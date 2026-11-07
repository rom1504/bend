# Bounded superseded-helper audit

Read-only audit at HEAD `5a5624b`, with root's pending parser/recipe cleanup
present. No production edit or compiler execution. This is a small deletion
recommendation, not an automatic dead-code pass.

The strongest remaining candidate is the declaration lookup/signature pair in
`selfhost/src/front/declarations.bend`:

| Declaration | Source line | Physical block lines | Nonblank/noncomment lines |
| --- | ---: | ---: | ---: |
| `law f_def_signature` | 58 | 9 | 7 |
| `def f_def_signature` | 260 | 5 | 3 |
| `def f_decl_find` | 420 | 7 | 4 |
| Total | | 21 | 14 |

Physical counts use existing `selfhost/tools/build/source.py:blocks` boundaries,
including attached comments/blank lines; code counts include `@unsafe`.
Audited module SHA256:
`1c57cfd6ff767f5258c042f036f4aeddc57839b79fc595bd9f58f6e05da05c7c`.

After the six old parser continuations are removed, exact-token search of all
maintained source finds these names only in their own declarations and the
recipe's declaration order. The selected `p177dr_resolve` already performs the
local/prior lookup, and `p177dr_type` constructs the signature from the carried
raw local result. Removing these two helpers adds no replacement computation.
The three corresponding recipe-order rows must be removed together.

The lexical reference audit includes every recipe module, the preamble, and all
five profiles' explicit entry modules. Neither name occurs in profile settings
or protected declarations. Exact-token searches found no occurrences in active
build/conformance tools, manifests, self-hosting documentation, host/driver
modules, or `selfhost/src/runtime.mjs`. A broader scan covered 15,722 text source,
test, tool, manifest and documentation files. Remaining hits are frozen compiler
snapshots, historical source-shape inventory, the preserved pre-cleanup parser,
and Phase177 review prose; no direct maintained test calls either helper.

Recommendation: these three blocks are suitable for the same bounded deletion
and five-profile closure audit as the selected parser cleanup. Preserve frozen
artifacts. Exact source closure after deletion remains the appropriate gate;
absence of callers is not a measured runtime gain.

## Other findings, excluded from this recommendation

The legacy lexer cluster (`f_scan_word`, `f_scan_quote`, `f_lex_scanned`,
`f_lex_quote_end`, `f_lex_symbol`, `f_lex_comment`, `f_two`, `f_pair_op`,
`f_symbol_text`, `f_triple_op`) has no incoming maintained calls outside itself.
Its listed ten definitions and two laws occupy 112 physical block lines /86
nonblank noncomment lines; this is a bounded named set, not its full transitive
cleanup. `f_lex_cursor` now calls `p150l_cursor`. However, its Phase152 comment
explicitly says old helper laws were preserved, so resolve that historical
compatibility intent before deleting this larger set. The native-focused
`lexer-scan.bend` fixture defines its own scanner copies; its references do not
call the maintained scanner. Historical performance fixtures also embed their
own copies. Keep the live `FScanned` datatype: current lexer and import-header
paths still use it.

Several checker adapters also have no incoming maintained calls
(`tele_check_head`, `tele_fill_head`, `check_event_install`), but they are not
needed to complete the selected parser cleanup. No broader deletion is proposed.
In particular, `mat_lhs` has a direct historical component export and
`core_rebuild` remains named in the production-law catalogue and direct tests;
their lack of current production callers is insufficient reason to delete them.
Public annotation, checking, prepared-Base, checkpoint, ABI and lookup entrypoints
were likewise excluded rather than treating source-call reachability as their
whole API contract.
