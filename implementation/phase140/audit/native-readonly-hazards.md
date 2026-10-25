# Source audit: native cost hazards in Phase140 cache queries

No target execution. These are source-grounded hypotheses and work-count
observations, not new native measurements. The active session candidate and
its original verifiers are unchanged.

1. **Duplicate full declaration equality is certain.** `p140o_admitted` calls
   both `p140o_changed` and `p140o_refresh`; each compares every complete old/new
   declaration with `f_fresh_prefix_exact_defs([a],[b])`. The second scan is not
   needed to discover whether its edge list changes. A combined ordered delta
   walk could return refreshed edges and the initial dirty set from one equality
   result. Dirty propagation must still use the old immutable graph. This is
   the first source change to test if owner analysis dominates warm time.
2. **Index equality traverses a synthesized representation.** `p140r_context`
   compares five KDef maps through `p140r_def` and generic declaration accessors.
   For every physical KIndexNode, `dc` constructs a two-element list; head
   comparison counts it and traversal retrieves and joins it again. The new
   isolated25-line [comparator](../../../selfhost/tools/performance/phase140/compare/README.md)
   avoids these adapters with explicit physical constructors. It is untested;
   generated code may already eliminate some of the source-level operations.
3. **Membership returns an owned row before asking one scalar question.**
   `p140o_has` calls `index_find`, then `dk`, then compares with `P140Dirty`.
   This runs for owner checks and many dependency edges in every fixpoint
   sweep. A complete held-index membership predicate can avoid producing a
   KDef result. Existing indexes already exist: do not propose another hashmap.
   First inspect the actual borrowed-call path and matched behavior on hash
   collisions, absent names and BookCache/index variants.
4. **Frame-target facts may compare the same body repeatedly.** Each
   `p140r_facts_valid` looks up and compares complete continuation segments;
   registry planning repeats this for candidates across up to six rounds,
   and rendered public units check their facts again. A request-local memo of
   `(old-index epoch,current-index epoch,name) -> exact same Maybe<Segment>`
   could share that result across users of the same authenticated index pair.
   Absence is a fact; arbitrary prior fact values cannot be mixed under one key.
   Count repeated target names/body comparisons before adding this machinery.
5. **Dirty closure scales with sweeps, not just changed owners.** `p140o_fix`
   scans all edges until the dirty count stops growing. Long dependency chains
   can cause repeated scans and retained-index queries. Instrument sweep and
   edge-query counts. A retained reverse-dependency index plus dirty queue is a
   stronger algorithmic alternative if those counts dominate; merely borrowing
   the existing walks would not remove their multiplicity.

## Small shared borrowed query contract

The useful capability is a complete scalar predicate over two held immutable
roots, with variant/layout/alias checks and an owning fallback, such as exact
KDef/map equality or dirty-index membership. Match each record once, compare
stored fields directly, and keep the scalar result through the caller. This
avoids the Phase137 pattern of owned field extraction followed by a separate
predicate. A future owner relation could return scalar flag bits for
`headers equal` and `complete bodies equal`, avoiding newly constructed
`declared` records and singleton lists.

No raw-pointer interface, weaker ownership guard or global reference-count
change is justified. Existing observer plans, private helper calls, width16
layouts and final verification should be reused. Confirm actual call-site
reachability: earlier phases emitted valid borrowed readers that inlining made
unreachable. Higher-order `p134v_list` callbacks may already specialize, so
source appearance alone is insufficient to blame them.

Before a new compiler acquisition, use the exact existing native image/profile
and one bounded proxy to establish which operation remains. Removing one of the
certain repeated traversals is preferable to a speculative borrow pass over
the whole optimizer.
