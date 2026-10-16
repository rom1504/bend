# Source03 certified-call review

No blocking certificate or lifetime defect was found in source
`3a3d9c098fc8d091e0fde08f2b02a54e6fe96e5e0705ca8195144acb4cae5ccb`
under its unchanged plain observer schemas. This is a source review, not a
formal runtime theorem. The exact
[recipe](../../selfhost/build/phase99/borrowed-calls-source03/changes.json)
adds 123 physical lines and 8,337 bytes to Phase98. The
[implementation notes](../../selfhost/tools/performance/phase99/borrowed-calls/README.md)
preserve the earlier draft and checker failure.

The root-owned [small09 qualification](../../selfhost/build/phase99/borrowed-small09/report.json)
is complete with unchanged pinned inputs: 18 finite predicate controls and
13 exact native program executions pass. Its
[emission report](../../selfhost/build/phase99/borrowed-small09/emission/report.json)
also covers actual observer routes, aliases, descendant reads, origin swap,
unchanged global representation flags and denied authority paths. These results
do not yet establish full-image self-reproduction or a whole-compiler gain.

The reviewed obligations are:

- `no_route_pair` publishes a schema only after both private worker and adapter
  admission. `no_route_plan` first checks private-name freshness. The registry
  starts empty inside the existing permission gate; raw book names and ready
  names are not certificates.
- Existing `nol_root_specs`/`nol_scalar` keep parameter types plain and
  nondependent. Consequently exact normalized owner-name comparison is adequate
  here. It must not be reused for applied or opaque types in a later extension.
- `nob_arg_word` requires each borrowed root to be an `OA` with a concrete Var,
  the exact callee parameter type, and ancestry below a matching live caller
  entry root. Callee positions can differ from caller positions. Reordered and
  aliased roots are read capabilities; owned handles remain separately counted.
- Scalar arguments preserve type checks. Results receive a fresh `OUnique`
  observation and full `Term` storage, including Nat. No child, closure or
  product result crosses the borrowed-call boundary.
- `nob_emit_call_ready` calls only `$observer.<callee>`, carries that dependency,
  checks the success flag before reading the result, and preserves error checks.
  Existing outer adapters perform owning cleanup after observation. The ordinary
  worker remains the unique-input fallback and retains its original ownership
  protocol.
- Calls occur after the existing strict argument evaluation. Helper effects,
  virtual root arguments, unknown callees and cycles cannot create certificates.
  The lazy `noa_below` guard and the existing self-loop tail-result restriction
  remain unchanged.
- Only helper-cycle/depth refusals enter one bounded retry list. Schema refusals
  are not reanalyzed; already certified owners are skipped. For the existing
  unique live-name input, analysis attempts are bounded by N+P, with P≤N.

Independent review by the proof/control collaborator reached the same source
conclusion and checked small04's actual C: the public equality worker calls
borrowed walker/finisher workers, its adapter sinks both roots afterward, and
the ordinary fallback still contains its original keeps and calls. The alias
and tail-reader C exercise duplicate read capabilities and a borrowed descendant.

Three extra negatives were introduced in
[`fixtures-v2.bend`](../../selfhost/tools/performance/phase99/borrowed-calls/fixtures-v2.bend)
and [`api-cases-v2.json`](../../selfhost/tools/performance/phase99/borrowed-calls/api-cases-v2.json):
scalar argument type mismatch, a nested child with no entry-root ancestor,
and a product-result certificate. The scalar and product cases include passing
positive counterparts, avoiding a refusal that merely reflects a missing type
descriptor. These add to the original 15 predicates. The v2 source check refused
an unannotated polymorphic List binding; v3 supplied that annotation but then
refused an unannotated `NO_Schema` constructor binding. Neither of those added
fixture sets executed. The root-owned v4 fixture supplies both annotations and
small09 executes all 18 predicates. Source03 is unchanged; earlier fixture and
qualification pins remain unchanged. Three source-bound argument-list laws
also [pass independent checking](../../selfhost/build/phase99/borrowed-args-laws01/report.json),
and their three [helper mutations are rejected](../../selfhost/build/phase99/borrowed-args-negatives01/report.json).
These are argument ordering/failure laws, not a native lifetime theorem.

The initial
[`reversed-unique.bend`](../../selfhost/tools/performance/phase99/borrowed-calls/reversed-unique.bend)
fixture placed the wrapper before its walker, which upstream checking refused.
The root-owned
[`unique-v2.bend`](../../selfhost/tools/performance/phase99/borrowed-calls/unique-v2.bend)
orders definitions before their callers and exercises newly constructed
single-owner inputs as well as held aliases. Its `unique-held` baseline and
candidate executions pass in small09. This does not establish that the retry
was exercised, and affine source use alone is not a runtime RFC-count
measurement. Neither claim follows without inspecting actual routing or C.

Two scope limits remain worth recording. The one retry pass bounds attempts,
not the depth of an already admitted acyclic call graph; the existing C inlining
heuristic has no new transitive code-size bound. Also `nh_observer_macros` sees
the expanded route entries: user-root cold eligibility can change even when
global feature flags do not. Native String is excluded from that cold inference.
The prepared
[`inspect-self-c.py`](../../selfhost/tools/performance/phase99/borrowed-calls/inspect-self-c.py)
therefore reports per-constructor cold macro changes separately from global
flag equality, and counts static admitted owners and call edges without claiming
dynamic coverage or saved CPU time. The completed
[same-source self-C inspection](../../selfhost/build/phase99/borrowed-self-c01/report.json)
passes all ten assertions: observer coverage increases from 7 to 11, adding
`f_eq`, `f_seed_text_equal`, `kp_eq` and `p88_string_eq`; all four call borrowed
workers. The public equality fallback remains byte-exact after removing its
new redirect. Global representation flags match and the per-constructor cold
macro delta is empty. This establishes emitted mechanism coverage, not a
whole-compiler timing result or B2 qualification.

The shared-root guard is a disjunction: either root with an RFC count above 1
activates the adapter. It does not require both roots to be shared. The check
precedes the original public equality wrapper's two `term_keep` calls, so two
unique dynamic roots still take that original path; its keeps subsequently
make the walker eligible for the existing borrowed route.

Static sharing has a different representation. In the inspected candidate C
(`0c84b47d9c787289f0159c7c47074ecb58b50fe6a16785836488760350feffac`),
`p98_tag_eq_read` passes `term_ctr(CID_SCON, STAT_OFF + 6601)` for `Lam`
and `STAT_OFF + 16784` for `Lit`; following those `STAT_IMG` chains decodes
the exact strings. These immortal nodes have no RFC bit. `term_triv` recognizes
their location below `HEAP_OFF`, and `term_keep` returns them unchanged, so
static nodes do not themselves satisfy the shared-root predicate. An immortal
static string must not be described as an RFC-shared or uniquely owned heap
string.

`p98_tag_eq` retains its key before calling `p98_tag_eq_read`. A nonempty dynamic
key therefore supplies the shared root for the Lam/Lit public-equality branches;
a static key paired with static Lam/Lit does not. The generic KTerm branch
already invokes `p88_string_eq_go` directly, bypassing the new public wrapper.
Consequently the unique-key hypothesis does not explain away the new mechanism,
and static tag comparisons do not establish dynamic coverage of it either.
The exact hit rate would require counters or a profile. No guard change is
justified by this inspection, and source03 remains fixed.

A later generic policy could consider routing nonrecursive certified-call
wrappers on unique or static inputs. The existing certificates and owning
adapter already provide the root lifetime boundary; an entry RFC count above
1 is a cost selection condition, not permission to dereference. However,
absence of `NO_Loop` in a wrapper is not a cost proof: its `NO_Call` may invoke
a recursive walker, and borrowing then dropping a unique root can require two
traversals where an owning walk consumes it once. Any broader policy needs a
separate structural/cost argument and shared, unique and static controls, with
the recursive owning fallback preserved. This cycle makes no such change.
