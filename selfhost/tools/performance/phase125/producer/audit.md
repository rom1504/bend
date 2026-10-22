# Phase125: guarded append without intermediate-spine reconstruction

Status: source prototype, not qualified or selected. Parent is Phase124 `ready-source02/compiler.bend`; root owns all executable validation and the additive runtime implementation.

## Why this experiment

The checked RLE function is exactly `lconcat(lrepeat(count,value),expand(rest))`. Phase124 can keep the recursion and helper returns in a private explicit continuation table, but its append still consumes the first spine and allocates another spine. Changing to a producer that fills an already evaluated suffix would reorder producer and suffix evaluation; the independent source ceiling does that only under its stated pure witness assumptions. This prototype preserves the original call order and removes a different category: reconstruction of an already unique left spine.

## Source certificate and integration

`model.bend` overrides only `p121f_selected`, `p113e_scalar_safe`, and `p113e_stmt`. Their previous bodies are copied as delegates, so existing pipeline/callback/TRMC choice priority is retained. Admission first requires an ordinary arity-two definition and bounded checked syntax, then exactly these equations:

```
append Empty ys = ys
append (Link head tail) ys = Link head (append tail ys)
```

Function and constructor names are derived, not workload selected. No extra effects, callbacks, head conversion, duplicate tail, changed recursive argument, or alternative base expression is admitted. Both parameters and result must have the same closed type, checked with the existing bounded `j_pure_same_closed`; the actual owner must have exactly an arity-zero constructor and an arity-two constructor, and the latter's tail/result must have that same type. Constructor runtime fields have quantity one. This supports existing native `List<&2,String>` as well as `List<&2,U32>`; heads are opaque. Unsupported/dependent type equality falls back conservatively.

The first prototype only augments an already successful public two-parameter forwarding `P113DFunction` whose name is `p113d_public(book,source_name)`. This is the actual private direct callable (`p113d_$direct.lconcat` after emission), not the register-bank export. It retains the original private TRMC function and dependency, plus the *exact* old forwarding body on refusal. Requiring a single-result call immediately followed by that same result, and checking both parameter names and the result name against the reserved prefix, establishes scratch/local namespace separation without scanning an arbitrary body.

The original generic graph and its verifier are unchanged. The new derived wrapper passes the original direct-function verifier with one additive import contract. That contract requires `(Ptr state,U64 left,U64 right,U32 emptyCID,U32 linkCID,Ptr out) -> U64`, real distinct constructor IDs of arity zero/two, and at least eight bytes of definitely allocated output storage. New code never treats a compiler/native error as an admission success.

## Runtime contract owned by root

`p125_rt_concat` returns exactly zero or one. Zero means no input was consumed, retained, sealed, or mutated, and the output slot is unread. One consumes both logical inputs and places one owning output in the slot. Empty-left returns the existing right input. Otherwise it first walks the *entire* left spine without mutation, requiring exact raw dynamic unique link cells and exact terminal empty value. RFC, shared, static, wrong constructor, or unsupported representation must refuse before mutation. Successful linking makes one tail store and returns the existing left root.

The link store must use the unchanged capability-eight / constructor-hot sealing policy. Heads are neither inspected nor duplicated, and no old left-head objects are dropped. The old terminal empty field is trivial. Raw ownership is the existing runtime uniqueness invariant; an externally retained alias requires the normal shared representation and must refuse. The same holds when right aliases a suffix of left: that alias makes the relevant spine shared, so the complete probe refuses before changing anything. No count-one RFC inference is included in the first experiment.

This does not guarantee a gain. Hot constructor policy can seal every tail and prevent raw-only admission. The probe also adds one read-only scan on successful inputs and some refusal work on shared inputs. Admission counters and the unrelated String/alias controls determine whether broadening the runtime contract is worth investigating; they do not justify weakening it.

## Controls and required measurements

`p125pc_controls()` exercises exact equations, arbitrary constructor spelling, changed head/tail/suffix/base/callee rejection, and forwarding/namespace/effect refusal. These fabricated terms are pure analysis inputs only. `p125p_inspect(request,name)` checks actual checked requests. The root should independently verify complete outputs on the ordinary RLE and varying String append controls, including retained input/tail aliases, empty/static inputs, and deep list ownership. Existing complete graph/direct verification, exact parent comparisons, and original benchmark definitions remain the gates.

Measure whole caller cost and hot append native code, helper success/refusal counts, allocation/take/seal counts, and compilation overhead. A faster source ceiling is not a measurement of this transformation. No dynamic share or speed prediction is claimed by this audit.
