# Portable publication and full-corpus queue review

Static PASS on the prepared tools below. This review performed no compiler,
generated-program, benchmark, compression or publication execution. Passing
source review does not assert that the future corpus run, publication, compiler
installation or release qualification has completed.

| Tool | Reviewed SHA256 |
| --- | --- |
| `selfhost/tools/performance/phase47/freeze-current.py` | `b4e8956bbcf861934c36cafdd02f2b8f1acb264f3e3d543b37d4be11af53320b` |
| `selfhost/tools/performance/phase47/run-corpus.py` | `9abc7ad1124ab7433835f4077f4d0115ea148b5dd75df6234a5d2c529ff05b94` |

## Publication identity and preservation

The [publication tool](../../selfhost/tools/performance/phase47/freeze-current.py)
requires explicit expected API and runtime hashes and checks both against the
actual checked attempt and the original frozen candidate manifest. The unchanged
Phase44 freezer supplies the deeper join: exact source snapshot, bootstrap and
driver identity, complete checked acquisition receipts, all 45 catalog points,
and the complete-row observation adapter. An API hash alone cannot substitute
for this binding.

The original method directory remains intact. Published candidate files copy its
archive and provenance byte-for-byte and retain the original manifest under a
separate name. The derived manifest changes only the candidate label and adds a
label-derivation pointer; reconstructing the original manifest must give exact
object equality. The historical Phase44 provenance kind remains truthful as the
identity of the consumed method, not a claim that this candidate is Phase44.

The worker23 and TypeScript baseline must already pass the maintained reader for
all 45 points, with the exact worker23 API/runtime and pinned upstream revision.
Its manifest, archive and provenance are copied byte-for-byte. Candidate archive
creation and independent streamed reopening/hash verification are delegated to
the unchanged freezer. Both final bundles then pass the maintained reader for
all points. This read-only reader mode does not extract into source directories.

Destinations must be fresh, distinct and nonoverlapping, outside acquisition and
baseline source directories, and outside the Phase45 portable bundle tree.
Existing Phase45 bundle-directory inventories are captured and rehashed after
publication. The tool does not overwrite or relabel those closed bundles.
The intended command uses only new Phase47 destinations. CPU0 affinity is
mandatory, and the documented procedure waits for timing to finish before
compression. Publication writes its own final receipt; it does not install a
compiler or assert installation status.

## Complete runtime comparison

The [corpus queue](../../selfhost/tools/performance/phase47/run-corpus.py) partitions
the maintained 45 catalog entries into three consecutive groups of 15. It runs
each group serially through the unchanged program runner with budget 600, Node
24.18.0, CPU3, 1024 MiB heap, 2048 MiB process-tree RSS and 4096 MiB available
memory. Each runner owns its existing execution lock; the queue adds no nested
lock or parallel target execution.

The existing 600-second protocol retains five fresh rotated rounds per role,
except the existing three-round raytrace policy. All three batches must succeed
before the unchanged full-corpus summarizer runs. That summarizer requires exact
45-point/669-sample coverage, identical role/compiler/module bindings and common
protocol/resources across batches. It checks the actual raw sample and process
receipts, configuration/tool/module hashes, rotation order, valid timings,
nonoverlapping sample intervals and recomputed per-point summaries. Changed,
missing, duplicate or partial data cannot produce a passing aggregate.

The queue is parameterized by a candidate manifest; the eventual report must
still identify the actual selected array04 attempt rather than infer selection
from the queue filename. Publication independently requires its explicit API
and runtime pins. The [portable README](../../selfhost/tools/performance/phase47/README.md)
correctly distinguishes the old worker23 aggregate from a new paired
denominator, gives 20/60/300/600-second replay commands and documents that a single
600-second run cannot complete the entire 669-sample protocol.
