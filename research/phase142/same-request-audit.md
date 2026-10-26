# Same-request raw/static judgment transport

Independent source review of Phase141 source02 (`f5bfca6d…a06a`) and
`phase142/same-request/{core-v01,diagnostic-v01}.bend`. No compiler or target
execution by this reviewer. The independent finite fixture module is
`same-request/controls-v01.bend` (`p142srt_controls`,26 rows).

**No source-semantic blocker found for this separate bounded prototype.** It
can avoid repeating raw-body and static-image checks because the exact checked
bundle survives the intervening transformations. This is a source construction
argument with finite falsifiers, not a newly proved theorem or a permission to
trust arbitrary `P140VCache` values.

## Actual conservation path

1. Original `p140v_open` performs its existing context, raw, static and direct
   checks. `p140v_publish` produces a nonempty cache only after all succeed.
   Its metadata contains the current raw maps and `p114s_ids(original)`.
2. `p134u_inline` and `p134u_ranges` operate on lists of direct functions.
   Their caches store function-level inputs/outputs, not replacement raw bundles.
3. Both `p134v_commit` and its `p114s_commit` fallback preserve the incoming
   `original` and `ids` on success, rejected-candidate rollback and invalid-input
   fallback. Only the direct-function list can change.
4. `p114s_close` projects that same original into `P113DProgram`.
   `p113a_finish` adds the current certificate; it does not rewrite the bundle.
5. The sole changed caller, `p140b_lowered`, reconstructs the successor from
   the held successful first judgment plus current functions/certificate.
   That successor goes to both second-boundary checking and `p140b_array`/late
   emission. It does not verify one original and emit a different one.

The first draft rebuilt the original inside the checker but passed the incoming
product downstream. The current v01 source corrects that split through
`p142sr_successor`/`p142sr_closed`. Current source already conserves the original;
the explicit reconstruction makes the intended interface harder to misuse.

## What is removed and what remains

On an actual successful first judgment, the candidate removes the second raw
body equality/verification walk and second `p112s_image_error` traversal.
It still calls `p140v_reuse` against the previous array cache, retaining its
ordered raw-context and direct-header checks. This is not elimination of every
second-boundary scan.

Current first-check metadata/IDs remain valid because the original is identical.
Unchanged direct functions may reuse the existing previous-array judgment;
changed functions pass the unchanged `p140v_direct_walk`, with signatures
published in the original order. `p140v_array_done` still runs private-array and
transport namespace checks. Late observer processing and `p126bp_complete`
remain unchanged. If the first judgment is absent/failed, the exact original
second-check route runs, preserving original diagnostics.

The second raw/static check is deliberately no longer an independent recheck
on this successful path: it is a duplicate judgment over the held immutable
object. The original first checker remains the authority. In particular, this
candidate must not silently combine with the earlier cross-revision raw-owner
witness experiment: doing so would also remove that experiment's independent
second raw-check safeguard. Any combination needs a separate joint argument
and differential qualification.

## Necessary semantic distinctions

`p134v_boundary_same` compares only validity and direct functions. It ignores
both `original` and `ids`; it cannot prove this conservation property. The new
diagnostic comparator checks complete raw segments, constructor metadata, show
words/names, effects, purity and static nodes/words. Effects matter because
`p112s_image_error` uses them to block foreign/effect constructors in the static
image. Equal headers and nodes alone are insufficient.

The stage-owned judgment is valid only through the audited internal callgraph.
An arbitrary external caller could forge a Data cache or combine an unrelated
successful cache with another program. The private helper is not an admission
API for such inputs. If a future transformation legitimately changes raw bodies,
headers, effects or static placement, it must invalidate this transport contract
and receive fresh checking; it must not have its changes silently discarded.

## Independent finite controls and remaining evidence

The26 controls use genuine first-check caches and compare exact second-check
errors plus complete published caches, including metadata/ID maps. They cover:

* Cold and warm second checks; absent first judgment; raw/static first failures.
* Valid/invalid direct-body edits, changed headers and invalid forward order.
* Private-array namespace failures and both raw/direct transport namespaces,
  which the first checker alone does not establish.
* The actual first-open and optimizer path: cold, warm, reuse of an optimization
  cache with a different current original, and invalid-candidate rollback.
  These compare the full original and both ID maps, not `boundary_same`.
* Diagnostic refusal after changes to raw bodies, wrapper flags, constructors,
  static offsets/words, effect blocking, show words/names and purity.

These controls are authored but not executed by this reviewer. Root owns source
checking, complete fresh-versus-candidate products, actual edited-source recovery
and timings. The diagnostic path's full comparison is an oracle, not part of the
timed optimized path. Existing second raw-hit counters now include transported
same-request judgments; they must not all be reported as cross-revision hits.

No cold or warm speed gain, native qualification, proof or installed selection
change follows from this source audit alone.
