# Phase163 private compact-App experiment

The private source overlay and its finite controls now pass hosted acquisition
and all 16 expected control rows. No native build or frontend performance workload
was executed by this preparation task. Production modules and the public host/cache
ABI are unchanged. Apply `compact-app-overlay.json` to the maintained assembly by exact
`(kind,name)`; its original-body hashes guard the source boundary. Preserve the
same-name `law` declarations. The manifest lists 33 replacements and 13 additions,
with no protected declaration overlap.

## Representation and unchanged contracts

The overlay adds `KApp{quant,children,begin,end}` to KTerm and adds canonical
`KChildren`: zero, one, two, or at least three children (`KCMany` stores its first
three and a remaining list). Distinct constructors have disjoint lengths; every
finite list has one representation. The old three KTerm variants and explicit
records remain accepted. `kt` and `kt_span` still construct legacy records.
The new variant observes exactly tag App, empty name, ID zero, empty removed
names, its quantity, arbitrary children and exact source interval.

`k_with_children` always retains the outer KApp variant, for every child count.
Thus a temporary empty update followed by two children does not accidentally
switch to legacy storage. Canonical pack/unpack supports structural put-back and
last-write laws; the controls compare physical variants, not merely tag/field
observations. Span updates retain children and quantity. `k_rebuild` retains
KApp when its implicit name/ID/removed fields remain canonical; when those fields
change, it constructs the exact requested legacy record. Existing generic,
Lambda and literal branches retain their operations.

The existing checked representation proof package remains pinned to the old
three-variant datatype. This experiment preserves its law meanings and tests
new cases; it does not claim the package already proves the extended datatype.
A maintained promotion needs new canonical-container roundtrip lemmas and the
additional constructor cases, without weakening old laws.

## Real producers and consumers

Six actual App-producing declarations now pass operands directly to a compact
constructor: `app`, `core_apply_span`, `f_app`, `f_app_span`, `f_scope_app_span`,
and `j_region_app`. They do not first construct a compatibility child list.
Binary construction uses two objects (KApp and KCTwo) instead of a generic record
and two list cells. This is a source-level allocation difference, not a measured
QBE saving or speed forecast.

`kid` directly projects compact children, with exact Absent results for missing
indices. Substitution, substitution-stability analysis and both frontend origin
walks traverse compact fields directly. Other generic consumers can still call
`ks`; it materializes a compatibility list for compact values. That remaining
allocation and the wider term match can offset the saving and must be measured.
Substitution still visits malformed extra children before App canonicalization.
Parser quantity 1 remains distinct from core quantity 0: only quantity-0 binary
Apps with stable children and a non-Lambda function are substitution-stable.
Beta reduction retains the existing core and frontend paths.

Both exact snapshot variant discriminators assign KApp a new code 3; they do not
pretend it is physically identical to generic storage. Prepared-body pairing
admits KApp/KApp only and leaves all field/child authentication intact. Generic
constructor-fact readers retain their wildcard refusals.

## Admission and integration boundaries

The pinned upstream checker explicitly declares ADTs whole before checking their
fields and permits families to name each other in any order
(`selfhost/.bootstrap/upstream-phase66/bend2/bend.ts:3780`). This supports the
mutual KTerm/KChildren declaration shape; actual source checking is still required.

Append `compact-app-controls.bend` and invoke `p163t_controls()`. Require all 16
exact named pass rows. The independent raw structural equality covers variants
and all fields; a separate observer projects compact storage to legacy semantic
records. Cases include child counts 0/1/2/3/4, every pair of child overwrites,
quantity 0/1/max, spans, metadata changes, substitution/beta, missing children,
normalization and snapshot refusal. See `compact-app-controls.md` for the oracle.

Then compare complete parser/checker products through an explicit semantic graph
observer and exact diagnostics, and ordinary generated-QBE requests through the
unchanged verifier. The altered compiler's own KTerm datatype necessarily changes
its generated QBE identity. A reproduction gate must compare identical candidate
sources across candidate generations, not demand the old compiler QBE bytes.

This first experiment is native/Bend-only. The old typed-driver and cache graph
adapters enumerate three term variants; they are not qualified to transport
KApp. The existing wire decoder remains unchanged and accepts old carriers as
legacy terms. Do not widen freshness, preparation authentication or host admission
just to make a mixed representation pass. Public promotion requires an explicit
ABI/projection decision and its independent gates.


Checked finite-control receipts are
`selfhost/build/phase163/compact-controls-api03/report.json` and
`selfhost/build/phase163/compact-controls-run03/report.json`. Earlier API01/02
failures are retained: one missing shared binding and missing constructor-let
type annotations in the test module were repaired. They did not require an
algorithm change to the compact overlay. `compact-preparation-receipts.json`
pins the final modules, both frontend acquisitions and the exact 16 named rows.
