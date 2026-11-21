# Independent Phase200 headroom review

The best supported first experiment is the caller-side immediate ownership fast path, implemented separately by `../abi/fast-ownership.bend`. The independent audit here authenticates all 45 actual Phase199 objects and finds ownership-call relocations in all 23 manifest family labels. Static presence is not dynamic reach. Historical Phase198 ownership observations identify useful first test cases: raytrace had 2,097,150 high-byte-zero external keeps/sinks in the second repeated-work difference; symreg 6,145 of 7,745; Map128 5,452 of 6,387; record256 4,708 of 6,511; Unicode64 768 of 1,155. These counts are explicitly **historical**, not observations of the new Phase199 objects. Some first/second differences were unstable; the audit retains that flag. No speedup is inferred from counts.

Phase199 already includes word primitive specialization, reciprocal quotient selection and public tail transfer. Repeating those as a new discovery would be misleading. Earlier runtime-only release specialization, fixed-arity inlining and host PGO screens were flat overall, and forcing all verified borrow readers regressed several cases. Those results do not falsify removing immediate ownership calls in the generated caller: that removes an ABI boundary and argument setup instead of merely changing the callee.

## Independent legality review

The actual runtime `term_keep` checks the reference-count bit **before** checking triviality. The masked tag alone is therefore insufficient: high bytes `0x80` and `0x81` must retain the original keep call. The candidate's unsigned `(term >> 57) == 0` admits exactly complete high bytes 0 and 1. Those have no RFC bit and masked tag <= TAG_PAK, so keep returns the original full 64-bit word without memory effects; sink returns zero without memory effects. All other words take the exact original runtime call, including heap owners, reference-counted owners, static objects and the hole sentinel. This conservative guard intentionally misses some safe sink/static cases.

`audit.py` checks all 256 possible high bytes against that ordering and authenticates the runtime source used for this argument. This is a finite source-semantics partition check, not a machine execution test or full formal proof. The ABI still requires a valid state; skipping an otherwise unused dereference does not authorize invalid foreign states.

The maintained allocator must continue treating the operation as a call. Removing its call-clobber/liveness classification while preserving a slow call is unsound. RAX/R10 must be reserved or otherwise proven dead; all original argument snapshot staging must remain on the slow edge. Flags can change because the original call already clobbered them. The fast path must publish RAX through the same destination store. Label allocation must remain fresh, including exhaustion fallback.

## Cheap falsifier before broad timing

Use two separate ordinary programs and actual generated machine probes:

1. A scalar-heavy recursive numerical program (raytrace) and a mixed scalar/heap Map or record consumer. Compare exact whole-program output against mature C and the authenticated Phase199 product at catalog and alternate inputs. Include a no-ownership-hotloop sentinel such as local-fold. Count actual fast and slow edges in a separately instrumented binary; do not time the counter binary.
2. A minimal generated worker where a result from keep survives a subsequent call and where another live value occupies each permitted allocator home. Test words at full-high-byte boundaries 0, 1, 2, 127, 128, 129, 130, 255. Construct valid RFC-backed owners for 0x82 rather than dereferencing manufactured invalid pointers. Verify count increment and exact subsequent release, shared aliases and static/zero owners, original full64 keep result and zero sink result. A shifted-tag-only mutant must fail the 0x80/0x81 routing assertion even when no fabricated heap dereference is executed.
3. Freeze a forwarding/no-fast-path control with the same call classification and labels. Compare stock/forwarding/guard in two link layouts and position-balanced pairs. A heap-heavy negative case must not acquire an unacceptable regression from the extra guard. Reject a gain that follows only layout or disappears against forwarding. Keep mature-C ratios separate from within-object attribution.

Productabi owns the actual compiler implementation and physical controls. This directory does not duplicate them or occupy the shared physical lane.

## Alternative: bounded-period loops

A runtime period detector is not the first portfolio candidate. The existing F32 recurrence observes each rounded state in a U32 rolling hash; recurrence of the float alone does not permit skipping the hash updates. Tracking the complete state generally gives a much longer period. The Phase198 never-converging control already demonstrates the cost of a detector on a non-converging path.

A narrowly provable alternative is a *static* involution certificate for a pure recurrence, e.g. `x' = x xor constant`, plus a U32 additive accumulator whose per-step delta depends only on that state and loop-invariant parameters. Two successive state steps return x; the accumulator gains `d(x)+d(x xor constant)` modulo 2^32. For fuel n, advance by `floor(n/2)` times that pair sum, followed by the odd step. This is constant work, needs no speculative cycle detector, and preserves full-width fuel arithmetic before final modular multiplication. Two distinct independently authored uses could be alternating signed-phase accumulation and a parity-switched tariff counter. A near-miss `x' = x+odd`, an extra state-dependent observation, memory update, floating arithmetic, or a changing xor mask must refuse. Counts 0/1/2/3, odd/even large values and >2^32 fuel are essential.

No current catalog example was established for that restricted theorem, so it is a future targeted experiment rather than a claim of broad Phase199 headroom. Closed pure-subterm evaluation is being investigated by the parent; it is not implemented here.

Run the read-only audit from repository root with `python3 -B research/phase200/discover/audit.py`. It writes `audit.json`, including current object pins, exact relocation counts, the historical count provenance and all 256 guard cases. No compiler, model or benchmark process is launched.
