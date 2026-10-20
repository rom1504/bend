# Recursive constructor-spine source review

This record covers the optional local descent/unwind prototype in
`selfhost/tools/performance/phase114/recursive/`, through `modules04.json`
(SHA256 `c7bc8e699135db160551e8310acdd6f22e1e4e600c70bf0e7d4d60451196f871`).
Its unchanged selected compiler baseline is `wide-source31/compiler.bend`
(`287c85558f3eb40d5576b51a4f7c0238100a9c4c93fc36ee52e3b8bc4e2ac303`);
the reviewed runtime04 C source is
`c0fc18aabb2749cc85b5040c29756d8d73d90b73bb954d10ed1d0d410528aa50`.
Inventory hashes were checked against current files without running a compiler
or program. The coordinator owns target qualification.

The planner accepts an original verified entry with one result, one recursive
frame site and one captured field. Its continuation must construct exactly two
fields, with the recursive result last, and return that constructor immediately.
It retains scalar operations, ownership calls, argument stores and the original
frame call in order. Existing direct functions retain precedence. Other shapes
use the original public renderer. The plan is derived internally; its reflected
`valid` flag is not an external ownership certificate.

The local state relation is `sp = entry_sp + 2 * depth`. Every descent retains
the original `[head, FID]` frame and increments depth. Base results transfer into
the private result local. Each unwind decrements depth and performs `pop2/get0`,
which restores the same head as the original return's FID pop followed by the
continuation's `pop1/get0`. It then runs the exact renamed constructor stores and
call. At depth zero, the public wrapper invokes the original return once, leaving
the caller's pending frame intact. Omitted intermediate register, `rn` and `next`
updates cannot be observed by the accepted ordinary helper whitelist or the exact
constructor continuation. The omitted pop-result assignment is likewise unused.

Argument slots are snapshotted before parameter reassignment. The captured head
and recursive result have distinct original locals; continuation locals and
scratch receive a separate reserved namespace. Namespace checks cover original
and continuation locals. No new recursive machine call is introduced: one public
wrapper calls one worker whose descent and unwind are loops. Ownership transfer,
constructor sealing and allocation order remain with the original helpers. This
does not introduce uninitialized constructor fields or destination passing.

Independent source review by the IR agent found no concrete alias, stack-pointer
or unwind defect in modules02; modules03/04 change checker annotations only.
The first acquisition rejected an inline match position; v2 extracted the same
test into a helper. The second rejected an affine tail captured by both choice
arms; v3 marks that tail and the emitter's similarly shared chunk list with `+`.
The third rejected mutually recursive namespace checks without `@unsafe`; v4
annotates both functions. Prior source bytes and inventories are preserved.
These fixes do not change the accepted graph language or generated instructions.

Limits remain explicit. The prototype retains two worklist words per recursive
level and two fixed scratch buffers, so it is neither constant-space output
construction nor an unbounded-memory guarantee. Exact failure suffixes rely on
the pinned sequential CPU fail-stop behavior; recoverable errors, GPU execution
and concurrent execution are outside this review. Full-suffix failure recognition
still runs at each scalar scan step and can cost quadratic planner time: no
cached failure-scan change is present in modules04. This is a source argument for
one finite transformation, not a general ownership proof or measured speedup.

Qualification must establish actual admission on ordinary list reconstruction
and String append, complete output and retained-alias behavior, and fallback for
two recursive children, a non-final recursive field and post-call projection.
No successful API, inspection or native result is asserted by this source record.
