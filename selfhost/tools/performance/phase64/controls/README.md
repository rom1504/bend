# Phase64 focused correctness controls

These are exact successors of the closed Phase63 controls. The adjacent
`derivation.json` records parent/output identities and every text edit. Existing
differential assertions and runtime oracles are unchanged; output directories
move to Phase64 and optional canonical-path/byte metadata is validated before
using the file identity. Phase63 fixtures and evidence remain read-only.

Only root executes the following commands, inside its serial CPU3 resource
supervisor with the existing 1 GiB heap, 2 GiB RSS and 4 GiB available-memory
limits. Use a new output directory for every attempt.

```sh
node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase64/controls/prefix-world-todos-v3.mjs \
  CHECKED_ATTEMPT \
  selfhost/tools/performance/phase37/fixtures-new/numeric-recurrence.bend \
  selfhost/build/phase64/NEW_PREFIX_OUTPUT

node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase64/controls/backend-context-v1.mjs \
  CHECKED_ATTEMPT selfhost/build/phase64/NEW_CONTEXT_OUTPUT \
  recursive-host-alias scc-alias erased-demand

node --max-old-space-size=1024 --stack-size=4096 \
  selfhost/tools/performance/phase64/controls/host-signature-v2.mjs \
  CHECKED_ATTEMPT selfhost/build/phase64/NEW_HOST_OUTPUT \
  recursive-host-alias numeric-recurrence
```

The prefix fast selector accepts one source; add the maintained MapSet source
before integration to reuse the same frozen world across different requests.
It compares the entire checker world and complete driver result with ordinary
checking and original prefix replay. It also covers bounds, changed prefixes,
constructor/name capture, invalid state and a full FNV hash collision.
The TODO successors additionally call the actual optimized completion entry
on every original case. Nine new cases cover nonzero original-prefix counts,
suffix holes, law/fill resolution, competing checker errors and two maintained
parser fixtures. Instrumentation requires zero TODO queries after a failed
check, and exactly one suffix-only query after successful admitted checking.
State01 removes the unused old private world-only function. The consumed v2
control therefore failed its symbol preflight, before semantic execution. V3
captures the actual checker world passed by the exported program entry to its
existing completion functions. It passes their arguments through unchanged and
retains every v2 assertion. The failed receipt and exact successor derivation
remain separate.

The checked-context candidate uses `prefix-world-context-v4.mjs` with the same
arguments, after its new private API has been built. This exact TODO-v3
successor retains the earlier assertions and compares complete context objects,
including their indexes and exact maximum binder bounds. Diagnostic query inputs
must consist only of the original suffix for admission and the assembled checked
suffix for context construction. Maintained dependent and nested template
sources must produce actual generated instances; inherited high-floor cases
and explicit unready/error/short/cached/refused fallbacks remain covered. This
does not promise admission for arbitrary same-length forged private books.

`cache-world-context-v3.mjs DRIVER FRAME3 BASE OUT.json` exercises host admission
without importing a compiler image. It retains the earlier TODO, identity,
coupling, corruption and persistence controls; the world capability now requires
version three and both unsigned facts. Older valid rows retain independent
checked/frontend acceleration while losing the world capability. Malformed
`checkedBound` values invalidate the optional graph. The driver, imported graph
helper and all inputs are bound by hashes. Use an actual prepared version-three
frame and run this under the same root supervisor.

The backend fast selector above covers recursive Nat host conversion, unequal
mutual SCCs and erased/dead computation. Omit its final case arguments to run all
six maintained real sources. It checks full emitted bytes for pruned-context,
canonical-context and saved-plan routes and executes independent value oracles.
These candidate-internal comparisons complement baseline/candidate byte gates;
they do not replace them.

The host-signature controller compares every actual wrapper with the old
result/arguments/write-back reconstruction. It compares each stored normalized
head and terminal result with the unchanged helpers, then recompiles with old
wrappers and requires complete module byte equality. Each source also gets 32
primitive controls: zero arity, Nat, borrowed and erased slots, dependent erased
types, premature non-function heads, nonzero parameter offsets and both
marshalling modes. Runtime values remain the separate context controller's job.
State02 removes four unused old argument/write-back helpers from its compiled
image, so v1 failed symbol preflight. V2 restores exactly those four declarations
from pinned checked State01, verifies their dependency closure and unchanged
Bend bodies, and retains every original oracle. The original failure remains.

Creating a controller is not a passing result. Preserve each controller after
its first target consumption and use a new successor for any needed correction.
The existing maintained semantic, self-hosting, performance and release
qualification factories remain authoritative for final integration.
