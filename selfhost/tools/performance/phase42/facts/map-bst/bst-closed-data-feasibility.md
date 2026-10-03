# BST closed private data screen

> Contract clarification: [the executed preimport BigInt witness](returning-host-callback-assessment.md) falls outside the published standard-intrinsics-at-initialization contract (docs/BEND-IN-BEND-PERFORMANCE.md405–416, pre-Phase42). The earlier blanket promotion stop is superseded; retain the exact witness as boundary evidence. All43 static native-domain assertions passed, but supported postimport mutation, bounds and complete-value controls remain required.


The original benchmark is `phase37/fixtures-new/bst.bend`, retained in the
Phase41 portable catalog at size/seed 32/0 and 64/17. The historical ~152–209×
Phase37 gap is motivation, not a new Phase41 measurement. This screen changes
no production source and executes no compiler or benchmark. Its falsifiable
mechanism is reuse of the existing single-self component workers after a
bounded, exact proof for native independent Sigma and `List<closed ADT>` data
created inside an already checked scalar-root graph.

## Exact graph and existing blockers

Ignoring primitive edges, the source graph is:

| Owner | Direct edges | Existing worker obstacle |
| --- | --- | --- |
| `bst.pick` | none | List-frame/Sigma signature; nonrecursive ADT wrapper has no recursive callee |
| `bst.step` | `bst.pick` | Sigma input/output; native Sigma direct-prefix match refused |
| `bst.down` | `bst.down`, `bst.step` | Sigma state/result and helper signatures; otherwise one Nat-child self call |
| `bst.up` | `bst.up` | List-frame type and native List match; otherwise one rest-child self call |
| `insert.fin` | `bst.up` | Sigma prefix; scalar-first wrapper and direct graph contains up's self cycle |
| `insert`, `p37.bst.insert` | `insert.fin`, `bst.down` | wrapper selection/direct cycle refusal; can remain residual generic |
| `p37.bst.build` | `p37.bst.build`, `p37.bst.insert` | helper closure's Sigma/List types; otherwise one Nat-child self call |
| `inorder` | `inorder` twice | dependent sequential child traversals, not independent parallel let |
| `bench` | `inorder`, `p37.bst.build` | scalar root exists; its entire residual graph currently fails |

There is no mutual SCC and no helper backedge to down, up or build. The current
`j_component_backedges` rule should remain unchanged: it checks all completed
proof members for references back to the component root, not all helper self
cycles. `j_direct_visit` must continue refusing recursive graphs. Acyclic direct
workers for pick/step could become separately eligible only with exact native
match admission; no cycle whitelist is justified.

BST and BFrame individually satisfy current closed recursive user-ADT purity.
The native Sigma state and List<BFrame> are refused by `j_pure_type_head`.
`j_region_local_type` is not a substitute: its broader Array domain and single
constructor record checks have different scope, and recursive BST has two
constructors. Its native Sigma header/constructor specialization utilities are
useful building blocks only.

A type whitelist alone does **not** enable the intended graph. Current
`j_region_same_type` requires exactly List<U32> whenever either side is List.
For Sigma it compares only owner spelling, so two distinct instantiations would
compare equal. Current pure admission quarantines that weakness. New admission
must first compare the full normalized admitted shape, both quantities and
closed field types, including the Sigma family binder's independence; arbitrary
name equality cannot be reused. Exact constructor result identity must use the
same relation. Native List match admission in `j_component_match` and native
Sigma match admission in `j_direct_match` are separate checks.

Inorder remains excluded even if all types pass. Its right call receives an
accumulator computed by completing the left call, multiplying by ten and adding
v. `j_component_leaf` accepts two calls only as a three-child parallel Let with
independent proper children. A sequential continuation worker would be a new
recursion shape and is outside the first type-proof experiment.

## Smallest credible source experiment

1. Introduce a separate bounded private closed-data predicate, called only for
   the graph of a scalar-input/scalar-result root. Reuse the current all-ctor
   recursive user-ADT check with shared residual fuel, constructor and field
   limits. Do not change public ADT argument ownership or local Array admission.
2. Admit exact native List ABI only with quantity 2, an independently proved
   closed first-order element, original Nil/Con owner and specialized constructor
   signatures, and the exact quantity-1 head/tail fields. Track the complete
   specialization in active recursion, not merely the string `List`.
3. Admit exact native Sigma/Tuple ABI only with admitted field quantities,
   independent first/second closed fields, no free family binder, no removed
   fields or unspecialized parameters. Reuse Sigma header checks plus stronger
   independence and complete result checks. A beta-normalized family at one
   sample value is not an independence proof.
4. Thread the private domain to signatures, constructor proof, and exact type
   equality before extending the native match cases. Preserve original ordered
   graph discovery, fuel, failures, wrapper selection and graph coverage guards.
   Start with down; build may remain generic because its computed alias is separately refused; add up only after its List prefix can be proved.
5. Keep original tuples/tagged values, field thunks, reconstruction order,
   generic residual helpers and existing private component runtime. No new
   layout, native host operation, mutual recursion IR or public fast API.

This is more than a one-line whitelist, but requires no new runtime mechanism.
A scoped domain argument or dedicated private predicate is preferable to making
all current `j_pure_type` callers accept Sigma/List globally. Original canonical
source definitions remain the basis for graph proofs and request-cache facts;
never use a transformed graph as evidence for this extension.

## Root-run diagnostic and rejection controls

`bst-plan-probe.mjs` appends instrumentation to an actual verified API in a fresh
folder and invokes the ordinary library request. It observes original canonical
signatures, source edges, capture eligibility, prefix/ref counts, pure graph
order/fuel, component plans, and direct plans. Every query records its own error.
It retains no emission and overrides no proof predicate. The checked source/API
is an unchanged prefix. Syntax validation passed with Node 24; execution is
pending root. Use a fresh output for every retry:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase42/facts/map-bst/bst-plan-probe.mjs \
  selfhost/build/phase42/checked05 \
  selfhost/tools/performance/phase37/fixtures-new/bst.bend NEW_OUT
```

Independent synthetic observations include valid BST/BFrame; currently refused
List<BFrame>/Sigma; List<function>; List<Array<U32>>; a Sigma family returning
its bound variable; and separate single-constructor user records containing a
function, vector, or dependent Sigma. The last three are intentionally distinct
from one another: enabling records must not smuggle a forbidden field into a
closed List or Sigma. Mismatched List<BST>/List<BFrame> and distinct Sigma
instantiations query exact type equality separately. A current true Sigma
name-only equality is recorded as a quarantined hazard, never a pass.

For a future implemented predicate, rerun these negatives through the *new
private predicate*; existing false answers do not establish its safety. Also
require negative controls for changed native constructor metadata, removed
fields, quantity mismatch, erased function fields, mutual recursive record
fields containing a forbidden sibling, and shared-fuel exhaustion. Every
rejection must retain byte-exact ordinary generic emission.

## Complete-value and ownership validation

Before timing, compare complete ordered tree shapes and every node value after
insertion, including duplicates and both skew directions. Compare the complete
(state tree, ordered frame list) result for each descent fuel, full reconstruction
from each path, and the final wrapped U32 fold. Retain the original 32/0 and
64/17 catalog cases plus size 0/1, repeated keys, zero/partial/exact fuel and a
sufficient-depth skewed tree; digest equality alone is insufficient.

Private entry must require the existing clean host/descriptor guard and the
complete scalar-root graph coverage. Mutating pick/step/up/insert/inorder/build
G descriptors requires zero private entries and full generic results. Externally
supplied lazy ADT fields, proxies/getters and arrays with altered protocol
identities must never enter this root-created-data path. Throwing generic field
forcing must keep its original order and proof cleanup in finally. These are
ownership controls, distinct from the compiler's closed-type negatives.

The static payoff is removal of repeated down/build/up matcher and self-call
wrappers; residual insertion helpers and inorder costs remain. Rank this above
String SCC lowering for initial feasibility because it has no String host-hook
obstacle and needs no mutual SCC machinery. It has moderate proof/implementation
risk, a cheap original-predicate probe, and an unmeasured partial runtime payoff.
No claim covers the full historical BST gap or aggregate parity.

Root probe02 is now complete on checked07. Its original predicates confirm the
container/type and inorder-prefix findings. Build's prefix also fails on its
computed scalar alias even though its signature/capture pass; this is a new
independent obstacle, so the earlier prospective build-worker claim is
conditional on an additional alias proof. See bst-probe02-summary.json and the
matched-set design for exact observations and retained activation limitations.
