# Multiline quoted-word cursor repair

The isolated P6-004 lexer candidate repairs the confirmed physical-newline
location defect. Its checked build and selected gates pass; root owns integration.
The production/default compiler is unchanged by this report.

The old lexer records a quoted word's starting line and column correctly, then
advances only the column by the scanned word size. The candidate counts actual
newline characters in that already scanned word before lexing the suffix. A
physical newline advances line and resets column; the two characters `\\n` simply
advance column. Non-quoted word scanning keeps its existing path. The change adds
18 physical lines and changes one existing line in `front/lexer.bend`.

The maintained checked/equality build produces derivative
`6203276543e224a50a21cf3510194b629d4e4506a22b71865ffaaa94c6fb38cf`.
Its initial ten-fixture parse/check gate completes all 20 observations against
fresh pinned TypeScript. A separate baseline run uses the genuine unchanged
final Phase 5 B1. All reference observations agree between runs; all acceptance,
phase, checked-status and exit-code observations remain unchanged. Exact matches
improve **6→18/20**, with **12 gained and zero lost**.

The two residual observations are the same escaped-physical-newline fixture in
both lanes. Upstream rejects the invalid escape inside the string before a later
malformed top-level token. Both old and candidate Bend select the later token;
the candidate now places that selected token on its actual physical line. This
is a preexisting first-error precedence defect with changed presentation, not an
exact diagnostic pass. The original observations are preserved. The cursor patch
does not claim to repair escape validation or first-error selection.

Thirty-six direct token controls independently derive suffix coordinates from
source codepoints. They cover both quotation kinds, literal/escaped/multiple
newlines, non-BMP text, escaped physical newlines, escaped quotes/backslashes and
same/next-line suffixes. All pass. Cases without physical newlines reproduce the
old token stream exactly. The first direct-tool attempt called unexported
`f_lex` and failed before executing a control; its tool and failure are preserved.
The corrected tool appends only internal exports to disposable API copies.

A separate maintained 21-case default validation passes all declared
acceptance/phase controls and retains the same seven exact diagnostic differences.
No full frontend or controlled timing was run for this isolated patch. Its extra
quoted-word scan is linear; common-path overhead remains unmeasured.

Inputs, actual commands, failed setup, checked lineage, raw paired observations,
direct controls and patch are retained in the evidence archive. The initial plan
write failed because of its working directory, after which the shell launched the
build. The registered plan explicitly records this ordering; its final bytes are
not described as preregistered before that launch.

- [Patch](lexer-cursor-candidate.patch)
- [Plan](../../experiments/phase6/P6-004-source-provenance.md)
- [Evidence manifest](lexer-cursor-evidence/manifest.json)
