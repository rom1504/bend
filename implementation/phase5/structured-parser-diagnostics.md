# Structured parser diagnostics (P5-011)

The isolated candidate repairs six upstream parse diagnostics without changing
any of the 167 selected observations' acceptance, phase or checked status. Every
other diagnostic remains unchanged. This is a narrow transport and presentation
change, not a claim of complete parser conformance. Root authorized narrow production promotion after the final audit; the exact
overlay was applied after the timing hold. The combined integration gate remains
root-owned.

The genuine checked baseline is integration attempt02, API
`c3c2ac7b14566e3d50f8f8dd121068cd7a1b59f6a39f44213fd538ff03fdc7e1`,
source `bc9d7b136463ab4bd75ee7470f725506ea8b2f4da5c54b95e7b6dfaa5bd262fb`.
The final isolated attempt03 API is
`1d4e8450b71536fbf518ddf43b159cea772c65b680c832fef0937d6fa6d0be03`,
source `31c2055c5f683e9db82fbcbec5864936f409d0c2ef83b6bab1b0ecd70030106d`.
Its genuine bootstrap report is retained beside the API. The exact source and
host diff is `selfhost/build/phase5/parser-errors/attempt-03/overlay.patch`.

## What changed

Private `FRawResult` carries the selected Error term through declaration/import
parsing. Public `f_parse` still returns `FResult{book,error:String,imports}` and
renders at that boundary using the original source. Five Bend files change:
declarations, parser, validate, imports, and the forwarding `f_law_where` result
law in sugar. No core term ABI or App metadata changes. Existing error selection
and token consumption are preserved. Successful parsing only converts the absent
error to an empty string; source rendering runs on rejected inputs.

The initial structured family is closing `)`, `}` and `]` expectations and
adjacent duplicate-constructor freshness errors. Each structured Error retains
the original legacy text for refusal. Rendering verifies the actual source
character against the retained token; zero/unknown positions, mislocated comment
cursors, spaced freshness cases and an offending non-BMP scalar retain the old
diagnostic. This avoids inventing locations or constructing the isolated UTF-16
surrogate that the reference may display. A non-BMP prefix is supported and
tested. Rendering scans source text linearly on the rejected path; there is no
reparsing or extraction from legacy error strings.

Two isolated typed-driver presentation guards preserve a complete Bend-produced
`Error:` diagnostic instead of prepending another prefix. They do not parse or
reinterpret diagnostics. The catch guard checks that `error.message` is a string,
preserving behavior for other thrown values. Native bundle transport already
passes this text through, and the native graph adapter already has the prefix
guard; this was a static audit, not a fresh native build.

## Evidence and retained failures

All paths below are under `selfhost/build/phase5/parser-errors/`. These are
correctness observations; no controlled latency or speedup claim is made.

| Gate | Result |
| --- | --- |
| Attempt01 genuine bootstrap | Retained failure: forwarding `f_law_where` law still named FResult; corrected in the next isolated attempt. |
| Attempt02 / gate-01 | Found a real wrong-location counterexample for spaced duplicate names; also retained an incorrectly classified fixture that exposes an existing swallowed-error gap. |
| Attempt03 / gate-02 | 25 controls pass, eight newly exact diagnostics, no changed mismatch. Includes accepted syntax, first-error order, imports, comments, tabs, EOF and Unicode refusals. |
| raw-01 | Entire raw results exactly equal for pinned Base, frozen compiler source and list_sort; both malformed UTF-16 controls throw the same scalar-value error. |
| negatives-01 | 167 selected live-reference cases: six newly exact, 161 unchanged, zero classification changes or new mismatches. Two pre-existing acceptance gaps remain. |
| lines-01 | CRLF, line-number width at least ten, and CRLF plus wide line numbers and tabs all exactly match the live reference. Finished 23:07:35 UTC. |
| component-01/02 | Retained initial subprocess pipe EPERM, then a genuine missing `book_without` dependency. |
| component-baseline-failure | The unchanged baseline reproduces the same missing helper under the same file-backed launcher. |
| component-03 | Standalone frontend passes after adding the exact unchanged helper as an explicit component-only module; no diagnostic backend dependency was added. Root handles the separate production layer fix. |

The three raw-result JSON identities are Base
`083faef1a24aeeed2c80bcb6a113b67b9ecd063c2fc5e461ccf57b2551a81e28`
(2,053,560 bytes), compiler
`c4dd7a5ef9bc556070765d96017e54560520be7fe2e33c308a5eb90d1e87bddd`
(13,192,232 bytes), and list_sort
`da06b06f14c1f5421265f884440f9bcfc54b664ecffe2f606883014605cbf5a1`
(116,780 bytes). Equality covers every serialized term field, removal metadata,
definition order and imports, not merely acceptance.

The six upstream repairs are `check/book_prefix_arity`,
`check/ctor_shared_tag`, `compile/ctor_tag_dispatch_000`,
`compile/ctor_tag_dispatch_001`, `page/ambiguous_ctor_error`, and
`parse/duplicate_ctor_name` (all `.bend`). The paired runner retains its failing
overall conformance verdict because other differences remain. The separate
comparison gate checks unchanged-or-exact behavior; it does not rewrite that
historical verdict.

Independent static review by compact_index and root found no blocker in this
bounded scope. The normal public parser/loader ABI is unchanged; incidental
internal raw-parser helpers have a deliberately changed internal result type.
No full self-host fixed-point or full native gate was run for this isolated
candidate. Those belong to the later combined source proof.

## Reproduction and archival scope

The preregistered contract is
[P5-011](../../experiments/phase5/P5-011-structured-parser-errors.md) and the design
is [structured parser diagnostics](../../design/phase5/structured_parser_diagnostics.md).
Tools `selfhost/tools/performance/phase5/parser-errors-*` retain the initial
preparer, failed first probe, corrected probe, token guard, raw-result and
line-format gates. The final overlay is authoritative: the initial renderer
fragment alone predates the refusal fixes. Historical inputs and exact tool
versions must be replayed together, not silently replaced with later revisions.
The [main evidence manifest](structured-parser-evidence/manifest.json) preserves
4,510 historical file identities in 2,978 verified gzip objects (4,944,634 compressed
bytes). The first archival attempt deliberately failed on three changed paths;
[retained before-source snapshots](structured-parser-history/manifest.json)
supplied all three exact historical versions. The failed attempt remains in
`structured-parser-archive-attempt01`; no missing version was fabricated.

After the timing hold, the exact overlay applied cleanly as narrow hunks to the
current source, preserving the separate matcher, sugar and core-layer changes.
The [promotion record](structured-parser-promotion/manifest.json) and
[before-source archive](structured-parser-promotion-sources/manifest.json) retain
both identities. The tracked [exact overlay](../../experiments/phase5/P5-011-structured-parser-errors.patch)
is reviewable independently of generated artifacts. No production change or
archival workload ran during the controlled timing window.
