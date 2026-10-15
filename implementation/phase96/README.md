# Phase96: a reusable compiler law foundation

Added **31 public universal laws and seven supporting lemmas**, with complete
Bend proof bodies checked by the unchanged upstream BendTT kernel in Lean.
Added **226 finite production cases in 16 families**, plus **32 generated-C
witnesses**. The integrated audit passes all positive checks, 16 proof rejection
controls and ten executable semantic mutants.

The fast replay takes **15.48 seconds**; the full audit takes **90.72 seconds**
on this checkout with existing authenticated compiler/toolchain artifacts.
Production compiler source, installed images and the five established metrics
are unchanged. This phase supplies constraints for future optimization; it does
not claim a speedup or whole-compiler verification.

[Design](../../design/phase96/compiler-law-foundation.md) ·
[Run guide](../../docs/self_hosted/COMPILER_LAWS.md) ·
[Law catalog](../../selfhost/proofs/phase96/README.md) ·
[Upstream proof study](../../research/phase96/upstream-proof-method.md) ·
[Independent source/evidence review](proof-inventory-review.md) ·
[Evidence summary](../../selfhost/tools/laws/phase96/evidence01/summary.json).

## What the laws cover

| Package | Universal public laws | Supporting lemmas | Actual connection |
| --- | ---: | ---: | --- |
| List, reverse, membership, filter, environment algebra | 14 | 7 | Actual Base operations; byte-exact copies of the unpromoted Phase94 helper/reference. Generic parameters remain explicit. |
| Term representation | 17 | 0 | Exact KTerm declaration and 15 maintained helper bodies; only leading unsafe annotations removed in the proof extraction. |
| Production executable contracts | Not proofs | Not counted | 141 exact declarations from eight maintained source modules, exercised through genuine JS-hosted B2. |

The 38 theorem declarations all have emitted nonopaque bodies. The algebra
elaboration has 61 definitions and nine opaque generic parameters; the
representation elaboration has 79 definitions and no opaque definitions.
Source checking, elaboration and independent kernel acceptance are separate
receipts. Each positive kernel invocation is paired with rejection of a known
false equality. We did not change the upstream kernel, add axioms or admit proof
bodies. The unchanged cached module and key Lean/Bun/frontend identities are
reauthenticated against the audited Phase94 installation.

The representation laws specify update identity/composition, full metadata
preservation, child/span observations, literal behavior, lambda quantity
presence and ordinary-node projections. They respect real representation
exceptions: literal leaves ignore child updates. `core_literal` is safely
admitted but its result is not universally specified here. Arbitrary replacement
fields in `k_rebuild` have additional finite coverage beyond its narrower formal
put-back and child-update laws.

The executable families cover children, spans, projections, rebuilds,
beta-producing substitution, sound stability certificates, membership,
first-match lookup, cached lookup, book updates, final-event order,
occurrence sets/scanning, environment selection, live/drop partition,
constructor encoding and text assembly. Full values include payloads,
variant, source ranges, quantity-presence flags, duplicate/order information
and preserved aliases where the harness explicitly retains them.

## Results and negative controls

| Check | Result |
| --- | --- |
| Safe public laws and supporting lemmas | 38/38 independently accepted |
| Actual helper-body inventory | All selected representation bodies present and nonopaque; generic algebra parameters documented |
| Proof rejection controls | 16/16 expected semantic law-body rejections |
| Standalone bad-helper checks | 11/11 well-formed helper modules accepted before their laws reject |
| Production JS cases | 226/226 complete expected values match |
| Native C witnesses | 32/32 output lines match exact expected bytes; empty stderr |
| Executable semantic mutants | 10/10 compile successfully, execute and mismatch the named expected value |
| Fast command | 15.479 seconds |
| Audit command | 90.722 seconds |

The 16 proof negatives comprise four false statements, two altered environment
helpers, two constant observers, and eight representation-helper faults. Their
frontend rejections occur inside the intended law bodies, with expected/observed
type diagnostics. They are not claimed as independent kernel verdicts for those
mutants. The separate false-equality control tests the kernel's rejection path.

The ten executable mutants lose lambda presence or a literal endpoint, change
substitution IDs, mishandle a hash collision, discard a membership hit, reverse
drop order, remove all duplicate environment entries, drop join separators,
skip the first shadowing definition, or lose an encoding prefix. Compilation
refusal, serialization failure and timeouts receive no mutation-detection credit.
All ten produced an actual full-value semantic mismatch after successful
compilation/execution. No production source was mutated.

The native witnesses cover two selected cases per family, including collisions,
beta reduction with an absent target ID, threshold boundaries, duplicate bindings,
Unicode and empty join pieces. Their C was emitted by **JS-hosted B2**, then built
with the established Clang22 `-O3` configuration. This checks generated C behavior;
it is not a fresh native B1/B2 compiler-chain qualification or a program-speed
measurement.

## What we learned from upstream

The study reads pinned upstream `059266225b77c8ca256ac6b25ee5c21449bab151`.
Its `bend2/bendtt.lean` is byte-identical to the checked-out file, SHA256
`83cdd36e66dcd2cabcc3d10556c9c874f8d823956feab88f8bb5a81473d51be3`.

The most useful pattern is `subk_sub`/`sub_subz`: prove an optimized executable
substitution equal to the simpler specification, then use that equality to
justify the implementation replacement. Upstream's cached-book lookup proofs
similarly require a relation between the cache and definition list. We applied
that style to exact helper bodies, complete reference results and explicit
production connections. Upstream's de Bruijn substitution equations cannot be
copied directly onto our named-ID, beta-rebuilding representation.

Three concrete lessons shaped the suite:

1. **Algebraic identities alone can be too weak.** Constant false membership and
   constant empty filtering can satisfy some identities. Added singleton/cons
   decision laws connect the result to the predicate, and their bad observers
   are rejected.
2. **An apparently obvious substitution law is false.** An absent substitution
   ID does not guarantee an unchanged raw App: production rebuilding may beta
   reduce it. The independent finite reference models that behavior; the
   stability certificate is checked only in its sound direction.
3. **A signature is not a proved semantic property.** Bend's `law` syntax is also
   used for declarations. We count stated equalities with real bodies and audit
   their emitted definitions, rather than counting every `law` token or trusting
   a success string from a possibly incomplete elaboration.

## Failed attempts and repairs

All attempts remain in the evidence archive, including failures:

- `algebra-all01`: affine proof construction reused a list rest. Explicit
  constructor duplication repaired the proof without changing its statement or
  helper implementation.
- `algebra-all02`: source checking/elaboration passed, but the inventory matcher
  expected an unspecialized name. The repaired matcher recognizes actual emitted
  quantity specializations; `algebra-all03` passes the full chain.
- `representation-check01`: the positive kernel verdict passed, but the first
  runner incorrectly expected a rejection process's `complete` flag to be true.
  The guard uses that flag for exit zero. The corrected runner requires the
  intended exit code, diagnostic and absence of resource stops.
- `representation-mutants01`: one splice was ambiguous in two constructor
  branches. A branch-specific splice repaired preparation; no semantic result
  was attributed to the failed preparation.
- `production-minimal01`: mutually recursive test serialization needed explicit
  unsafe annotations. These observers are outside the proof claim.
- `production-full01`: constructor-valued local lets needed type annotations.
  Full02 adds annotations to 133 bindings while preserving every case input and
  expected value. All 226 pass.
- Review found that the first production worker could retain a true `passed`
  flag after a late input-verification exception. Its parent already required
  `inputsUnchanged`; subsequent workers clear both success flags on exceptions.
  The integrated audit and fast run use the corrected worker. Frozen earlier
  methods remain unchanged.

No production semantic defect was exposed by the accepted corpus. Fixes were
to proof construction, test wrappers, inventory recognition and result handling;
the expected production results were not weakened to manufacture agreement.

## Cost, evidence and remaining boundaries

Three agents worked on algebra, production specifications and independent source
review; root owned integration and all target execution. Across the retained
campaign there are 108 guarded jobs, **103.27 seconds of target occupancy** over
a **23.61-minute first-to-last target span**, with no overlap or resource stop.
Peak process-tree RSS was **621.34MiB**. The span includes writing, review,
preparation and tool orchestration; it is not a quota or token measurement.
No full compiler image, broad conformance suite or performance campaign was
rebuilt/repeated for these proof-only changes.

The [evidence capsule](../../selfhost/tools/laws/phase96/evidence01/raw-evidence.zip)
contains 1,752 files /18.29MB uncompressed, about3.13MB compressed. Every member
was read back and hashed. It includes failures, source snapshots, full expected
and actual results, emitted BendTT, generated products and raw receipts. External
toolchain/compiler installations are bound by recorded identities rather than
duplicated in this archive. See the [method and restoration notes](../../selfhost/tools/laws/phase96/README.md).

The maintained compiler and installed release remain unchanged. New authored
proof/contract code totals 1,511 lines across 19 Bend/Python/JS files; the five
current orchestration/collection tools add 459 lines, separate from production
complexity and excluding the preserved old runner. Existing latency, runtime
and conformance scoreboards remain the established measurements, not fresh
results from this phase.

These proofs do not cover arbitrary unsafe callbacks, all substitution/binder
preservation, parser/checker soundness, generated-code correctness, reference
counting, parallel scheduling or GPU execution. The finite corpus supplies
counterexample checks across some of those boundaries, not a theorem closing
them. The next optimization can use this foundation immediately: choose a
measured costly operation, freeze its precise specification, prove or test the
candidate at the stated boundary, then measure real compiler benefit.

Phase96 is complete. No production optimization or PR comment was made.
