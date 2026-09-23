# P6-008 — One authoritative structured checker result

Registered 2026-09-23T05:34:23.328466+00:00 before source mutation.
Root owns the isolated candidate; baseline a6459af. Initial implementation and
focused gate timebox 90 minutes, then reassess.

The kernel already returns KChecked containing the actual failing DTrace.
String-valued definition/book wrappers discard it. The host checks first, then
its rejection-only diagnostic API repeats chronological events and checks the
failing definition again. Preserve that first result and remove replay.

Implement a single structured definition/template worker and a single chronological
book/suffix worker. Keep String check_book/check_from_exact_prefix wrappers as
projections of the same result and preserve diagnostic API layouts/book views.
Accepted books, law fills, signature_mode, event guards, open TODO checks, exact
validated prefixes, constructor/foreign checks and first-error selection must
remain identical. ADT/foreign String failures may remain generic structured
errors; do not claim newly precise diagnostics from them.

The host uses one structured check only when an explicit new compiler capability
version is present; old compiler APIs retain their existing host path. Base cache
validation remains compiler-specific and always calls authoritative checking.
No changed term ABI, source-position algorithm, failed-oracle replacement or
unchecked compilation belongs to this experiment.

Gate a genuine checked/equality candidate on maintained21cases, all pinned
negative frontend observations against frozen current release, selected accepted
programs, law/template/ADT/foreign/TODO/changed-prefix and competing-error probes.
Require unchanged acceptance, phase, checked status, errors and diagnostic output.
Compare normalized full structured results against old diagnostic APIs on direct
books; keep expected existing strict failures. Instrument call counts separately
from timing to show one definition check on the selected failure, and preserve
all failed attempts. Measure serial matched early/late rejection and accepted
core-library workloads only during a root-scheduled exclusive window. Promotion
requires independent code review and later combined frontend/fixed-point gates.

Record source line delta and removed public/internal roots honestly. Existing
public String and diagnostic APIs remain compatible; undocumented helper exports
are audited before deletion. No whole-source speed claim follows from rejection
speed, and accepted overhead must be checked before promoting.
