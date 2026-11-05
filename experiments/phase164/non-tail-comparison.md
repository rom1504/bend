# Non-tail recursion: bendc mechanism and cheapest transfer

**bendc accepts native recursive calls; it does not make arbitrary non-tail
recursion stack-safe. Our opportunity is wider coverage and earlier construction
of stack-safe regions, not inventing a missing non-tail region mechanism. No
evidence establishes this as the dominant remaining cost or a route to five
seconds.** This audit ran no targets.

In pinned bendc `56edcc65b3527a75838011682c231072d5b46097`,
`selfhost/build/phase158/current/bendc.bend:8595` (`GSCallFull`) emits saturated
calls through `RC.wrap`, whose ordinary form is `F_name(args)` (:5732).
Recognized self **tail** calls instead assign parameters and `goto top` (:8810;
`Gen.is_tail` :4968). DPS recognizes tail/constructor-tail edges (:13141), not
every call with work afterward. RC wrappers can add post-call drops (:5728).

There is direct same-implementation evidence. Retained Phase160
`request-c02/program.c:51766–51774` has `L13852`/`L13855` call
`F_p131i__insert`, then construct the parent with `C4`. At :136765–136770,
`L58672`/`L58674` similarly call `F_p147v__insert` inside the parent constructor.
These are native call-stack continuations, sometimes reached through ordinary
closure application; they are not our scheduler continuations. C02 is the
documented boxed, no-early-free policy, not bendc's default optimization policy.

The exact vendor runtime `selfhost/build/phase157/vendor/rt/bendrt.h:2641–2669`
maps an approximately **4 GiB virtual stack per worker**, aligned with guard and
thread metadata. That raises the practical recursion limit; it is not unbounded
stack safety and is not 4 GiB resident allocation. Its fault handler explicitly
mentions possible machine-stack overflow (:2601). GC roots include saved
registers and conservatively scanned thread stacks (`setjmp`/`gc_scan`,
:2492–2522). Our RC ownership/continuation contracts cannot be replaced by that
root strategy without a different runtime contract. Iterative RC destruction
also does not make generated recursion iterative.

Our active `back/qbe/local-continuations.bend` already has `p114h_plan` (:894),
continuation closure (:823), descent and explicit unwind dispatch (:1054–1069).
It preserves pending frames on the Bend stack and loops inside a private
worker. It is reached through `region-policy.bend:34` / `helper-resume.bend:131`
and direct public fallback in `verify-direct.bend:378`. Current admission limits
include arity/captures ≤8, body size ≤512, at most eight distinct continuation
cases, known helper dependencies and recognized scalar/transition shapes.
These are coverage limits, not a bound on recursive depth. Persistent insertion
can be blocked by shape/dependency exposure; this audit has not identified its
first failing predicate and does not claim merely raising a numeric limit fixes
it. Native non-tail cycles remain forbidden in the separate direct DAG.

The 47,360 public segments include **39,460 continuations**, 3,960
factories/other and 3,940 source workers; they are not 47,360 independent
non-tail functions. Existing local regions are also recovered *after* generic
construction, so improving their execution alone does not eliminate acquisition
of the generic reference. Source-level zippers can expose a tail loop early;
moving equivalent region construction before generic lowering would need a new
independently checked source/ownership contract, not just accepting recursion.

**Cheapest decisive transfer:** use the current zipper as the execution witness,
then test its principle on the separately typed `p147v_insert` reconstruction
kernel (`verify-compact.bend:85`) using the existing verifier-table controls and
one complete checker request with exact QBE. First inspect the existing
`p114h_plan` refusal on those exact original segments; if it is a narrow shape
gap, extending the existing explicit continuation machine is cheaper and safer
than a new depth-guarded native recursion/fallback ABI. Keep malformed trees,
collision buckets, ordering and ownership outcomes in the controls. A gain only
in tiny insertion loops, or no complete-request gain, falsifies treating this
category as the main five-second lever. Do not launch another compiler acquisition
until this same-request transfer shows material economics.

Pins: bendc main SHA256 `72be729fb5a27c528acc4d232314ac44c4595a86dc67d9dde47197956edabb99`;
C02 `9d90a1c2e28d9b58f61ea6aa39b779e02de2657cc055aea59b36f0e03384fb89`;
runtime header `b99a4c3d186b233b5ebbc70fe6923f2de422827ee1a1a22eaddcc768d340167a`.
