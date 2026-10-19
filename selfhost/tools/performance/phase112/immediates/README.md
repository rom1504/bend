# Immediate keep/sink exposure

Hypothesis: generic QBE still pays an opaque helper call for immediate values
that the upstream C inliner recognizes. Root's compiler-workload profile reports
roughly 10 million keep and 11 million sink calls. Those counts do not establish
how many inputs are immediate or how much time is removable.

The exact runtime04 code is `runtime.c:824–846,882–892,1011–1015,3885–3886`:
tag extraction is `(term >> 56) & 127`, the reference-count flag is bit63, and
TAG_PAK is1. `keep` first tests RFC and may bump its count, then returns trivial
terms unchanged. `sink` tests triviality first and returns0. Therefore the common
sufficient predicate `unsigned term < 144115188075855872` (`2^57`) proves RFC
clear and tag0/1, independent of all lower56 bits. On this subset keep is exact
identity and sink is zero, with no heap or ownership side effect.

The emitter expands only the original verified U64 helpers with exact state and
argument types. It emits that unsigned comparison and branches to the fast
result or the exact original helper call. All other terms retain runtime
behavior: static boxes, heap constructors, closures, arrays, reference-counted
words and TERM_HOLE. In particular, TERM_HOLE must not use a triviality-only
keep shortcut because the original keep tests its RFC bit first. The runtime
ABI, public helpers, original N111 model/verifier, and owning graph are unchanged.
This is a backend expansion, not a new ownership proof or general raw-memory API.

Operand/result aliasing is preserved: the predicate reads the input before
either branch assigns the destination, and the fallback call retains the same
argument. The shared emitter counter reserves three fresh labels and a separate
temporary, then joins both branches before subsequent statements. Existing
nested branches and worker/fusion renderers compose through `p111q_stmt`.

Append `emit.bend` and `controls.bend`. Override `entry-accessors.bend` when the
selected renderer is both-accessors, or `entry-float.bend` after the optional
floating adapter. Export `p112i_control_report`, `p111_verify_program`, and
`p111q_chunks`. No existing candidate module is modified.

```sh
node selfhost/tools/performance/phase112/immediates/controls.mjs \
  BASELINE_API.mjs CANDIDATE_API.mjs FRESH_OUT
python3 selfhost/tools/performance/phase112/immediates/admit-v3.py \
  --source COMPOSED.bend --runtime RUNTIME04.c --float --static --liveness \
  --out FRESH_RECEIPT
```

Omit mode flags that are absent. Version3 binds the actual active immediate hook
and records exact declarations for every selected floating, accessor, and static
layer, plus the exact special-test lowerer when selected, with15 reflected-source
refusal mutations in this full composition. It
does not run the older float-only gate against a superseded hook or create a
temporary source projection. The frozen `admit.py` remains available for its
original receipts. Root must separately bind the compiled runtime object and
execute the emitted twins; worker admission also remains separate.

Controls are15 structural outcomes,512 finite predicate data cases, and28 exact
native observations. The predicate data spans every top byte with zero/maximal
lower56 bits; unsupported raw heap/reference words are never executed. Native
cases cover12 scalar/packed boundaries through both keep and sink, same-local
input/output aliases, a shared heap owner released before a replacement
allocation, unique destruction, a nested sealed shared child, and a captureless
closure. An opaque full-word `f32_bits` identity feeds scalar cases so constant
folding cannot hide every runtime guard. Expected results are frozen in
`cases.json`/`expected.stdout`; the compiler algorithms execute only in Bend.

Prediction: known scalar constants and scalar results may let QBE erase the
helper branch/call entirely, and unknown immediate values can avoid the call.
Heap-heavy sites instead add a compare/branch before the same helper; code size
and branch/register pressure can regress. No expected speed multiplier is
claimed. The cheap falsifier is paired machine runs of the same compiler-word
workload with this overlay alone, plus the complete observations above and
assembly inspection confirming helper removal at scalar sites. Measure actual
runtime before any full compiler image acquisition or policy selection.
