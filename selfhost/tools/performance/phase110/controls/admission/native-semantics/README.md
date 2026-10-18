# Native closed-entry semantic controls

Frozen at 20:07:51 UTC, before the four native-produced entry workers were run.
The source is the unchanged parent `closure-source.bend`. Each native invocation
exports one requested source root as `nx_entry`. Compile this harness with
`-DP110_CLOSURE_ROOT=0`, `1`, `2`, or `3` for the List chain, String chain,
mixed String/List constructor, or diamond respectively. The harness only builds
and observes graphs through the established Phase109 runtime ABI.

Eighteen small graphs produce thirty-six full JSON observations. Empty, unique,
root-shared and static inputs cover all roots. Mixed and diamond also use
physically overlapping inputs. In result-first order every external alias is
observed after releasing the result. In aliases-first order the result is
observed again after releasing all external aliases. Both require empty pending
scratch and zero remaining dynamic words. Unicode includes NUL, combining,
supplementary and maximum scalar values.

`reference.py` independently states the four source-level results. It does not
read compiler output or execute a graph worker. `prepare.py --out FRESH_DIR`
authenticates all frozen inputs and writes harness/ABI/case/oracle files.
`check.py --root N --stdout CAPTURE` authenticates the same inputs and compares
the saved output exactly. With no stdout argument it checks preparation only.
The initial prepared directory is `selfhost/build/phase110/closure-native-semantics01`.

`unreachable.bend` is a separate valid source whose canonical requested entry
is absent from main's dependency closure. The current mature request only
contains main-reachable erased facts, so requesting `p110_close_unreachable`
must refuse with a missing/mismatched erased-fact error. This is an explicit
current capability limit, not an ill-typed-source example.

Preparation performed no compiler or target execution and makes no timing or
compiler-workload hotness claim.
