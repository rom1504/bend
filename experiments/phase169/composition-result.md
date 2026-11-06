# Ordinary composition recovers editdist runtime

Four balanced rounds in
`selfhost/build/phase169/ordinary-editdist-timing01/report.json` pass all eight
independent output observations. The generated executable takes1.003953× the
retained Phase152 runtime: medians1.05833ms versus1.05417ms per measured
invocation. This supports parity in this screen, not a measurable regression
of0.4% and not broad-program qualification. Earlier screens were19.19246× for
the initial fast route and14.89764× after array-mode restoration alone.

The [offline census](composition-census02.json), reproduced by
[`composition-census-v2.py`](tools/composition-census-v2.py), identifies the
restored computation directly:

| Product | `$product.row` QBE bytes | QBE body identity | Real assembly calls |
| --- | ---: | --- | --- |
| Phase152 |64,068|`69a17f18…`|Versioned `p117v` fallback|
| Initial early route |6,049|`c6f9ca51…`|`$product.cell`|
| Array mode only |6,049|`c6f9ca51…`|`$product.cell`|
| Arrays plus protected ordinary composition |64,068|`69a17f18…`|Versioned `p117v` fallback|

The entire new row QBE body, including the final newline, is byte-identical to
the qualified reference. It again contains157 array-template name references.
The real assembly instruction count in that function returns from58 to175,
matching the reference; the shorter old candidate hid work behind the cell
call. Assembly bytes still differ because local labels shift, so this is not
an exact full-assembly claim. The first census omitted multiline mode when
counting assembly calls; its immutable result remains retained and version2
corrects that metadata-only error.

The new executable still has266 total QBE functions versus927 in the reference,
and capability word7 versus15: cold metadata has not been restored in this
treatment. Matching hot-loop composition did not require restoring the entire
old lowering pipeline. Static counts are descriptive, not dynamic attribution.

The single observed complete hosted editdist build grows from7.048s arrays-only
to8.760s with ordinary composition (use the raw reports for exact phase clocks).
These are single observations with larger emitted code, not a native compiler
throughput comparison. The source certificate excludes the full compiler from
this extra inlining work, but that exclusion itself must be verified and timed.

## False-certificate full-compiler path

[`false-certificate-audit.json`](false-certificate-audit.json) pins the inspected
sources and records three offline checks:

1. Replacing the new internal-mode expression with the original `mode` makes
   the complete `p168_request_mode` body identical after whitespace removal.
   Existing public mode rejection, diagnostics, permission and catalogue
   construction are preserved.
2. The old `p168_closed` mode1/mode0 branch is retained verbatim apart from its
   bound thunk-variable names. The new branch is selected only by internal2.
3. A false final array certificate still calls the exact original
   `p169s_seeded(original,nodes,view,p167live_eligible(program))`.

The actual original request supplies both certificate computations. In the
maintained authority, a reachable foreign File effect fails `ns_definitions`:
the accepted filled foreign names are IO.args, IO.print and IO.now only. The
canonical compiler reaches File.open/read/size/write/close; its retained native
descriptor already has capability5 and no cold constructors. Thus this source
audit predicts the same lowering/rendering path for the full compiler, with
additional predicate traversal cost. It does not replace the forthcoming exact
full-source QBE gate or establish zero compilation-time cost.

The independently checked API's current144 finite observations all pass in
`selfhost/build/phase169/ordinary-controls01/report.json`. Candidate native
extraction and broader runtime tests remain separate gates; the installed
compiler is unchanged.
