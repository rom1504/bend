# Missing declared imports retain their parse phase

The isolated P6-011 host patch tags the original ENOENT Error only when
canonicalizing a recursively declared import, and only if that Error has no
existing phase. It preserves its message, identity, checked status and exit code.
No compiler-source or generated-API bytes change.

Five pinned import fixtures have ten parse/check observations. All ten change
from the old load phase to the reference parse phase, with every other normalized
observation byte unchanged. This repairs ten phase differences. It does not repair
their diagnostic text: all five strict check failures and all ten exact differences
remain. The genuine checked/equality workflow reports complete=true/pass=false;
the inner candidate and paired selectedComplete flags are false because their
strict diagnostic oracles fail. Two initially overstrong audit assertions on
those flags failed and are retained in the corrected comparison audit. No oracle
or report status was changed to convert that gate to a pass.

Eight filesystem regression groups cover missing root, relative/absolute/nested
imports, all 24 combinations of error code and preexisting phase, read failures,
real directories, symlink loops/broken links, first-error traversal, canonical
deduplication, source mutation between requests and module collisions. These
use a deliberately tiny API stub only to isolate the host filesystem boundary.
They all pass. Two additional probes using the actual checked compiler confirm
that missing root input and missing Base preflight both remain load-phase,
unchecked failures. Direct legacy discoverSources callers without modern Base
preflight treat missing recursively imported Base like other declared imports;
this is separate from the measured released inspect path.

A fresh paired 25-observation neighbor gate passes: the 21 maintained controls,
actual relative-import checking/JS execution, and parse/check observations of a
competing malformed body and missing import. It retains nine exact differences,
including that existing body-before-import first-error discrepancy. The patch
preserves this order; repairing it requires a separate parser/loader design.

Both fresh selected APIs are byte-identical to the release: checked B1 SHA-256
`5969c53d34a0…`, equality derivative `e2b5463678a2…`. No speed gain is claimed.
The production/default host remains unchanged until the reviewed integration batch.

- [Plan](../../experiments/phase6/P6-011-declared-import-phase.md)
- [Patch](import-phase-candidate.patch)
- [Independent review](import-phase-independent-review.md)
- [Evidence manifest](import-phase-evidence/manifest.json)
