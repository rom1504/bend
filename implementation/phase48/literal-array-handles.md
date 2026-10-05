# Literal array handle entry checkpoint

The follow-on to typed array effects is implemented in `array-literals.bend` and
an explicit mode of the shared `array-view.bend` audit. It keeps original Array
constructor handles and lazy `arraydata`; it does not flatten a literal tree or
change its public identity. Canonical ALeaf/ANode admission is confined to a
typed planning context with bounded variable/literal/nested-constructor fields.
All existing raw consumers fix the new audit mode to false.

The scalar entry supports a demanded nullary root and ordinary leading-lambda
scalar roots after the original region selector declines them. It preserves a
complete generic fallback and uses the established zero-formal exactCode wrapper
for nullary definitions. Every entry revalidates the complete host/dependency
contract; repeated nullary loads rerun the computation. Private helpers retain
handles and the original constructor/field order. No runtime changes or host
cache were introduced.

Independent static source review passed this contract. The additive controls in
`selfhost/tools/performance/phase48/controls/array-literals-*` separately check
nullary ABI, missing argument vectors, raw code and construct calls, repeated
fresh storage, helper mutation/error/reentry, FloatView/iterator observations,
positive entry, zero-demand branch, and public/computed-field refusal. Controller
syntax and Bend delimiter checks passed locally; no target was executed here.

The optional controller argument accepts the actual maintained Evening module
from the identical candidate compiler. It requires `fpart() == 8`,
`main.out() == 81111` and real new `fpart` entry on both calls. This is the intended
consumer test, not an executed result or a performance claim. Root-owned checked
build, acquisition, activation and semantic observations remain pending.

See the [design](../../design/phase48/literal-array-handles.md) for the exact
scope, falsifiers and remaining unsupported producer/callee boundaries.
