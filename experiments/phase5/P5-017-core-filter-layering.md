# P5-017 — remove a duplicate filter and restore frontend isolation

Preregistered 2026-09-22 during the P5-015 timing hold; no compiler run yet.

The standalone loader component found a pre-existing layering error:
`core/index.bend::book_final_legacy` calls `book_without`, whose implementation
is in `check/kernel.bend`. The frontend-only component therefore needs an
unrelated checker module. P5-011 reproduced the failure on its unmodified
baseline and passed by appending the exact missing helper; those attempts stay
separate from this repair.

`book_without` and core `index_remove` have alpha-identical laws and definitions.
Both compare the same head name, recurse through every matching element, retain
nonmatching definitions in order, and use the same lazy `kc` branches. Replace
the five external calls with `index_remove` and remove the duplicate law/body.
Do not modify filtering, caching, last-definition ordering or malformed-name
comparison demand. Independent static review by compact_index agrees.

Neither helper is among the maintained 54 public bootstrap roots. Historical
all-root libraries and Phase4 scripts that extract the old helper remain tied
to their frozen source snapshots; this is not an arbitrary internal-root API
compatibility promise.

The cheapest decisive gate is the ordinary 22-module frontend component with
no appended checker helper or diagnostics. Its synchronous pipe capture failed
with EPERM in this environment; use captured file descriptors and preserve the
actual spawn error/signal/status, source identities and output. Then run a fresh
normal checked bootstrap, the existing definition-selection controls and the
combined frontend inventory. Require the moved callers to produce identical
filtering/order/demand observations. Final checked self-reproduction covers the
assembled compiler. No timing gain is claimed for deleting duplicate code.
