# Independent source review of fixed product shells

Reviewed frozen P68-007 v1 patch
`e46d3b9305d132501385202461b0479ace95efd54b7bde01e9ce2996800edbbc`
and all ten candidate hashes from its manifest. This is source review only;
no compiler, C compiler, or program was executed in this lane.

**Verdict:** no remaining source-level blocker found for the checked-program
prototype. Proceed to the checked build and discriminating controls. This is
not a proof of implementation correctness or arbitrary raw-book equivalence.

## Representation and ownership

- The typed query establishes only a constructor shell and field count. Calls
  enter a private product variant only with actual matching `NQBundle` values.
  An unknown boxed parameter is never destructured by a new entry adapter.
- The constructor catalogue is safe as producer evidence: it accepts an actual
  `Ctr`/`NCtr` with exact native identity and live field count. Each field remains
  one owned `Term`; it does not infer a field representation from erased types.
- Product fields use fresh synthetic bindings. The initial opaque parameter
  IDs and product-field IDs are disjoint, and local destinations reserve their
  IDs before lowering either side of a let. The earlier zero-based parameter
  ID bug has been corrected to `nc_id(i)`.
- A single-use let substitution retains the existing scalar environment's
  sharing and dead-value drops. `nq_uses` takes a maximum across mutually
  exclusive matcher arms. Repeated sequential uses stay boxed, so the existing
  product reference-count ownership operation remains available.
- Matching an actual bundle selects the known constructor arm and transfers
  its fields through normal lowering. Unused fields are dropped by the normal
  environment partition. Mismatched/unsupported matching and opaque consumers
  materialize the original constructor. An unused source binding stays on the
  boxed path; the new query is not permission to unpack it early.
- Array pair producers preserve their reads, writes, `blk_keep`, atomic
  operations and ordering. Only the result shell changes. Product destinations
  are fresh locals or an output vector, so sequential assignments cannot
  overwrite the array argument before its second result is evaluated.

## Control flow and admission

- Source call arguments still pass through the existing ordered sequencing.
  Bundle fields have already been evaluated. Self-tail calls stage every word
  before overwriting parameters; local joins clear tail position.
- `NC_Code.calls` composes both matcher arms and both sides of lets, and survives
  `nc_prepend`. The only ordinary worker call emitter records the exact chosen
  boxed or product name. Self-tail gotos have no external edge; non-tail self
  calls still fail admission.
- Admission requires all generated nonself edges to be ready. Thus cycles
  involving boxed and product variants cannot become recursive host calls.
  An unusable speculative variant can reduce worker coverage, but does not
  create a call to an absent worker: its dependants also remain unadmitted.
- Ordinary scheduler entries keep boxed inputs and one-word results. Their
  adapter names refer to the original boxed worker family. Product variants
  have distinct internal names and cannot intercept an ordinary source entry.
  Scheduler/device fallback remains present; no GPU validation is claimed.
- Status and result remain separate. A valid zero value is success; failure
  returns zero status before the caller reads its result vector. Polling and
  the existing nonsequential error checkpoints remain.

## Qualifications for validation

The query can demand additional type normalization, including field domains,
on malformed or unsafe raw books. Eager Boolean conjunction also evaluates
bounded field checks after an earlier condition is false. Do not describe this
as preserving normalization demand for every arbitrary raw input. The raw
unused-mistyped-product control tests the specific no-eager-unboxing boundary.

Run the independent record, owned Array transport, shared aggregate, escaping
callback, tail-field swap, raw unused product and prior error-order controls.
Inspect the admitted active product path: a passing program entirely on its
boxed fallback does not validate the intended optimization. Record code size
and C build time because both worker families can be emitted.

## V2 raw-boundary correction

V1 remains frozen. Its extra normalization demand is a release blocker for the
raw-input contract, even though the checked-program prototype review above was
clear. V2 replaces the layout helper with syntax-only query
`efe70c3e7221fa31bf51531a654df0123839273b76cb79f333d92a98932dac42`.
It strips annotations and reduces only constant syntactic lambda applications,
with explicit fuel. Direct constructor telescope specialization uses a separate
nonreducing structural substitution: ordinary `subst` would invoke
`core_rebuild` and could perform unbounded beta reduction. Global definitions
are never unfolded; nullary ADT references need only a declaration lookup.
Final owner equality is structural. Unsupported aliases remain boxed.

The product owner also tightened local use to minimum=maximum=one, retained
held-environment-before-fields order at known matcher success, and added a
fuelled parameter-demand check. Its branch exclusions use only the actual
unconditional scalar conditions or exact Boolean/Nat complements. Source
affinity and those complement rules were reviewed; the demand scan now also
uses nonreducing substitution. V2 still requires the parent's checked build
and runtime controls.

The frozen V2 patch is
`692d89e94cec1057d5a53b172e4e024741925324966272910532cfadbb6ff7f3`.
Before freeze, parameter demand was tightened from at-least-one to exactly one
use on each inspected path, preventing fieldwise sharing from replacing a
whole-parent retain. The correctness peer independently approved the bounded
query and this sharing refinement. These remain source-review conclusions.

The later checked products10 signature diagnostic reached the actual annotated
book without rebuilding a compiler image. It showed all four fold helpers'
product types were `App(Pair, ...)`, which V2 conservatively declined, and
showed outer ADT quantity metadata differing after nullary reference handling.
V3 therefore introduces a general bounded alias head/argument machine, visited
definition names and a 4096-node pre-substitution expansion guard, including
constructor specialization. It compares exact ADT arguments after the existing
owner/name/removed checks; outer quantity omission agrees with the core ADT
comparison rule. Helper
`cb6cbae52b41128538c3f422be71d7ccc1f863930dc118508cbdcb8dfe7904c4`
was reviewed without executing targets. This broadens useful syntax coverage;
it does not invoke the global normalizer or promise arbitrary alias unfolding.
