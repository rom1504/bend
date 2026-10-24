# Go package-reuse evidence

This archive retains the small Go 1.22.2 diagnostic experiment and the separate
Go 1.27.3/development source research. It contains text only: no executable,
compiled package archive, binary export payload, downloaded toolchain or cache
tree. See [the research assessment](../../../../research/phase132/go-build-reuse.md).

- [Successful experiment](go-cache02/report.json), [resource guard](go-cache02-guard/process.json),
  [exact toolchain output](go-cache02/version.stdout).
- [Artifact comparison](analysis/report.json), with action/content IDs and
  export-payload hashes after removing only the known textual build-ID header.
- [Initial failed attempt](go-cache01/report.json), [failure traceback](go-cache01-guard/stderr.log),
  [resource receipt](go-cache01-guard/process.json). Cold Go compilation succeeded;
  the Python harness then lost executable permissions while copying the binary.
  V02 corrected that copy. This was not a Go compiler or semantics failure.
- [Primary-source receipts](primary-sources.json) pin release/development commits,
  Git blob IDs, URLs, inspected line ranges and exact retained source excerpts.
  Go source excerpts are copyright the Go Authors under the [Go license](GO-LICENSE).
- [Archive index](archive-index.json) maps original paths to 107 exact retained
  copies and their SHA256 values, totaling 220,383 bytes. It deliberately leaves
  original absolute provenance paths inside the receipts unchanged. The README,
  primary-source receipts and license are additional tracked files.

Every experiment stage directory retains its complete small source tree,
`go build -x` stdout/stderr, execution stdout/stderr and package-list output.
There are seven successful stages. The interface-constant variant is defined
relative to baseline but follows the inline-body variant, also undoing that
previous edit; it is not an isolated constant-only transition.

The key reproducible observations are command invocations and content identities,
not the single-run wall times:

| Stage | Local packages compiled | Link |
|---|---|---|
| Cold | leaf, mid, side, main | Yes |
| No-op | none | No |
| Comment | leaf | No |
| Private body | leaf, mid | Yes |
| Revert | none | Yes |
| Inline body | leaf, mid, main | Yes |
| Interface-constant variant | leaf, mid, main | Yes |

The complete successful guarded campaign took 6.35s and peaked at 254.1MiB.
Required runtime packages are included in the cold compilation. The private
body changes leaf's object content but leaves its normalized export payload
unchanged; mid recompiles under this older toolchain's whole-archive dependency,
then its unchanged content stops the wave before main. The independent sibling
package stays reused. Each ordinary executable result matches its frozen
integer expectation.

Reproduce with the tracked
[V02 method](../../../../selfhost/tools/performance/phase132/go/cache-experiment-v02.py)
using a fresh output directory and the same installed Go version. The original
CPU5/RSS guard command is in the successful process receipt. The method forces
one build worker and `GOMAXPROCS=1`, disables toolchain/module downloads and cgo,
and uses its own fresh build cache. Other Go versions may produce different
invalidation sets; no equivalence with current Go releases is assumed.

The archive is sufficient to audit the observed command sets, sources, outputs,
comparison receipts and resource use offline. Recomputing binary/export hashes
requires rerunning the experiment or retaining the original local build tree;
those bulky or binary products are intentionally not included here. Neither
this experiment nor its new source survey benchmarks Bend incrementality.
