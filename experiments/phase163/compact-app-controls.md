# Private compact-App controls

Source: `selfhost/tests/phase163/compact-app-controls.bend`.
Entry: `p163t_controls() -> List<&2,String>`; no imports or main.
Append it to the exact maintained compiler assembly after applying the private
`compact-app.bend` replacements and adding its helpers. Root owns all checking,
native construction and execution. No target was run while preparing this file.

The file contains 36 new declarations and 16 aggregate result rows. Require all
16 exact `name:pass` rows; a short/empty result is not success. Its only candidate
APIs beyond the maintained names are KApp/KChildren and
`p163c_children`, `p163c_list`, `p163c_app`.

`p163t_equal` compares the actual raw constructor variants and every field,
recursively, including canonical child storage. It does not call the candidate
term observation helpers. `p163t_observe` separately converts only KApp to its
exact generic App observation, recursively; it preserves Lambda/literal variants,
quantity syntax, literal payload, removed names and source intervals. Therefore
structural-law checks do not silently use observational equality.

The controls cover:

* Child lengths 0, 1, 2, 3 and 4; direct projection indices 0–4 and U32 maximum.
* Quantities 0, 1 and U32 maximum; absent, point and maximum source intervals.
* Structural child put-back, all 25 first/last overwrite combinations per term,
  rebuild put-back, child-update/rebuild agreement, span put-back/overwrite and
  span/child commutation. Compact and legacy values are both exercised.
* Raw helper observations against independently inspected fields, including
  tag, name, ID, quantity, children, removed names, spans, literal data and
  Lambda quantity presence.
* Legacy noncanonical App metadata and arbitrary children, plus compact rebuild
  falling back to the exact legacy record when changed metadata requires it.
* Generic/compact substitution and beta agreement, explicit substitution output,
  argument-span retention, variable payload cells, and quantity/arity-sensitive
  substitution stability.
* Exact compact results from all six overridden producers: `app`,
  `core_apply_span`, `f_app`, `f_app_span`, `f_scope_app_span`, `j_region_app`,
  plus `p163c_app`. Empty/nonempty argument lists and lambda beta branches are
  checked. The frontend's inherited span for an unlocated substituted value is
  distinguished from core substitution's unchanged argument span.
  Source-origin walks, normalized child updates and Lambda-presence no-op also
  remain covered.
* Snapshot self-agreement, changed-span rejection, and like-variant-only
  `p152c_variant` admission.

The observer and fixture terms deliberately retain malformed generic metadata
and unusual compact child counts as compiler data. They do not execute such
terms as generated programs. These are finite semantic controls, not proof of
the universal structural laws, host/cache ABI qualification, full parser graph
equivalence, emitted-IR validity or runtime performance. Those remain distinct
gates in the root's complete experiment.

Expected rows, each suffixed `:pass`:

```text
compact-q0-shapes-and-laws
compact-q1-shapes-and-laws
compact-qmax-shapes-and-laws
compact-zero-span
compact-point-span
compact-max-span
compact-legacy-metadata-preserved
compact-changed-metadata-fallback
compact-substitution-and-variable-cell
compact-beta-preserves-argument
compact-substitution-stability
compact-direct-producers
compact-lambda-and-literal-contracts
compact-front-origin-walk
compact-normalized-children-and-presence
compact-snapshot-and-prepared-variant
```
