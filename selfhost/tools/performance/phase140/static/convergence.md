# Optional exact-image convergence

`core-v03.bend` is separate from the frozen prefix-only candidate 15. It keeps
the same cache, result and four-counter interface; the counters now describe
reused steps/bodies, which can occur after a miss, rather than only a prefix.
Source checking, executable controls, real-request comparisons and native
measurements are still required for this optional version.

The global constructor/effect admission and current image alignment are two
different facts. After a missed owner, the new implementation compares its
complete resulting image against the prior checkpoint at the same name/ordinal:
size, ordered nodes and fields, interning index, and error. Only full equality
can restore alignment. A different global catalogue never becomes admissible
merely because images happen to match. There is no address rebasing or
size-only shortcut.

A hit restores the old after-image, but **not** the old accumulated fact list.
An active hit prepends that owner's single retained emitted fact to the current
facts; an inactive hit retains current facts. The new checkpoint contains this
newly composed current state. This distinction prevents a resumed hit from
silently undoing the changed owner's output.

The proof is an induction on traversal position: aligned incoming image,
identical global constructor/effect input, and identical active/name/full-fact
inputs yield the same owner result. A miss executes the original operation and
can establish alignment directly by complete image equality. Fact lists remain
the ordered current outputs independently of alignment. The original current-
book attachment and all later verification remain unchanged.

`controls-v04.bend` adds first/middle scalar edits, two edits, reverted edits,
unchanged-image scalar edits followed by boxed allocations, every image field,
explicit current-fact-prefix preservation, and scalar active/inactive changes
that alter fact-list length without altering the image. It retains the 20
preceding controls, for 35 total; these are not marked executed until receipts
exist.

Image comparison is charged work. Version 3 attempts it only when incoming
alignment was already established. If that comparison fails, the remainder of
the request stays fresh; it does not repeatedly scan unequal images. This still
handles immediately converging scalar edits and multiple separated scalar
edits. Version 2 is preserved as the unmeasured variant that could repeatedly
attempt failed convergence; it is not the proposed candidate. The first useful
measurement is whether actual numeric compiler-policy edits rejoin immediately,
followed by an image-changing case to bound the negative cost.
