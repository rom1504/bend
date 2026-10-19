# Phase112: dynamic runtime counts identify missing semantic lowering

The strongest compiler finding is a representation cliff: U32 pattern matching
materializes a 32-cell Word list even when the source only compares a character
or numeric literal. On the actual compiler's `lexer-scan` request, that mechanism
accounts for **102,416,202 of 124,677,389 allocation-helper invocations (82.14%)**.
This is a source-level allocation identity, **not an 82% CPU-time share or a
promised speedup**. The fraction safely removable by a guarded pattern rewrite
still needs to be measured.

The strongest generated-program finding is different: ray tracing makes
**1,957,364 primitive calls**, of which **1,902,684 (97.21%)** are operations
covered by the prepared F32 expansion. It makes only 4,235 allocation calls.
Its immediate priorities are scalar lowering and ordinary-call transport, not
heap tuning.

## Evidence and scope

Root executed and qualified both
[`profile-batch01/report.json`](../../selfhost/build/phase112/profile-batch01/report.json)
and [`profile-compiler01/report.json`](../../selfhost/build/phase112/profile-compiler01/report.json).
The independent three-segment counter control passed before either workload.
All six generated programs retained their complete frozen output and requested
success counts. The compiler emitted exactly the prior **204,540 SSA bytes**;
its diagnostics decode against the existing **44,349,671-byte compiler QBE**.
The original runtime04 and program objects were unchanged; only a separately
instrumented runtime was linked. No additional targets were run for this analysis.

[`profile-counts.json`](profile-counts.json) pins the complete observations and
records the extracted counts, percentages and exact generated-function shapes.
The tooling and frozen plans are in
[`profile/README.md`](../../selfhost/tools/performance/phase112/profile/README.md).

The six program processes use one repetition and zero warmups. The unchanged
wrapper evaluates the workload once to print the reference answer and once
inside the repetition loop: **two workload evaluations**, plus setup, IO and
readback. These whole-process counts are not per-kernel costs. The compiler
profile is one ordinary prepared `lexer-scan` request, including live Base/carrier
reads and frontend/backend work; it is not a full self-emission profile.

Counters record source helper invocations, even when the C compiler inlines
them. Nested counts overlap. Register counts describe requested copies/zeros,
not necessarily physical memory traffic. `public_calls_fid` attributes calls to
the most recently dispatched segment; a private worker called inside that segment
shares its attribution. It is not a native stack sample. Instrumented elapsed
values were checked for valid output format only and supply **no performance
ratios**.

## Whole-process counts

| Workload | Dispatches | Public runtime calls | Primitive calls | Heap allocations | Continuation frames |
|---|---:|---:|---:|---:|---:|
| Lexer | 507,698 | 2,303,823 | 19,585 | 120,999 | 236,562 |
| Ray | 817,566 | 8,730,810 | 1,957,364 | 4,235 | 334,018 |
| Closures | 7,961 | 17,639 | 546 | 1,779 | 2,639 |
| Unicode text | 20,189 | 81,345 | 803 | 18,076 | 7,663 |
| Map churn | 157,486 | 645,890 | 18,598 | 149,163 | 54,391 |
| Numeric recurrence | 286 | 17,173 | 10,291 | 255 | 77 |
| Compiler, lexer-scan request | 28,422,884 | 170,233,886 | 2,754,250 | 124,677,389 | 13,652,223 |

Allocation and free invocation totals match within every observation. This is
useful consistency evidence; it is not a proof of memory safety or absence of leaks.

## Compiler: recover scalar pattern information before it becomes a Word

The compiler executes **1,625,654 U32 special-takes**. In exact runtime04,
`p111_rt_special_take(..., P111_SPECIAL_U32, ...)` calls `p111_native_word`.
That helper always allocates 32 `WCon` cells. It seals the previous child on each
iteration; the first child is immediate `WNil`, while the other 31 are fresh
heap constructors and each requires an RFC wrapper allocation. Therefore:

```text
1,625,654 × (32 cells + 31 wrappers) = 102,416,202 heap_alloc calls
1,625,654 × 31 wrappers            =  50,395,274 rfc_wrap calls
```

The second quantity is **85.36%** of the observed 59,036,946 RFC-wrap calls.
There are also **23,670,366 explicit WCon takes**, or **62.19%** of all public
constructor takes. A failed partial bit match can drop the remaining list,
so explicit takes need not equal 32 times materializations.

The generated code explains where this enters:

| Source operation | Observed entries | Generated public QBE body |
|---|---:|---:|
| `p88_digits`: match a character against newline | 1,087,899 | 257,833 bytes; about 6,930 lines |
| `p88_field_number`: match role against 1, 2, 3, 13 | 228,745 | 668,588 bytes; about 17,877 lines |

`p88_digits` starts with a String constructor take, then Chr special-take,
then U32 special-take, followed by a long chain of `WCon`/Bool tests. The original
source merely has `case SCon{'\n', tail}`. `p88_field_number` similarly expands
small numeric role literals into bit destructuring. Calls attributed to these
two segments total **32,611,135**, or **19.16%** of public runtime calls.
All directly named `p88_*` segments together account for **57,547,561 (33.80%)**;
anonymous continuations are excluded from that subtotal.

The mature compiler already contains the relevant reusable semantic recognizer:
[`word-pattern.bend`](../../selfhost/src/back/native/word-pattern.bend) extracts
fixed-width rows, verifies reconstructed defaults modulo bound-variable names,
and preserves exposed tails only when used. Its existing C-string emitter is
backend-specific; the row recognition and guards are the useful part to carry
into structured lowering. This does **not** require a new runtime ABI.

The cheap falsification is to lower the unchanged `p88_digits` and role-match
controls through that guarded path, compare complete outputs and failure/default
behavior, and inspect disappearance of U32 special-take and WCon chains. Include
high-bit words, all 32 bit positions, default fallthrough, retained bit/tail values,
and F32 bit-pattern semantics. Only then acquire/profile the compiler again.
Not every U32 destructure is a literal match: escaping Word values must retain
their semantics or use the existing fallback.

## Selector specialization applies, but is a smaller independent opportunity

`$direct.nt_choose` is dispatched **252,295 times**. Its actual generated body
sinks the unselected closure and calls `p111_rt_apply` on the selected closure.
The profile attributes exactly **504,590 public calls** to this segment, agreeing
with those two operations per invocation. Selector applications therefore account
for **23.45%** of the compiler's 1,075,823 public apply calls.

This supports the existing general
[`selectors/` candidate](../../selfhost/tools/performance/phase112/selectors/README.md):
reuse the mature closed-selector rewrite when literal lambda actuals and its
ownership/use-count conditions hold. Successful rewrites expose ordinary branch
bodies to the current lowerer and can avoid the unused closure, selected apply
and associated transfers. It is not a special case keyed to `nt_choose`'s name.

If every observed call had two newly allocated literal closures, the pair count
would be 504,590, or 23.48% of the 2,149,393 closure-construction calls. That is a
conditional scope estimate, **not a measured eligible count**: existing/nonliteral
closures and captureless representations must be distinguished. Dynamic admission
coverage and resulting allocation counts should decide whether to expand this
work. Even perfect selector elimination would not remove the Word-materialization
mechanism above.

## Ray and numeric recurrence: scalar expansion, then wider private calls

Ray's primitive distribution is unusually decisive:

| Primitive | Calls |
|---|---:|
| U32 → F32 | 563,748 |
| F32 multiply | 477,992 |
| F32 subtract | 352,336 |
| F32 add | 251,184 |
| F32 divide | 134,144 |
| F32 less-than | 123,280 |
| F32 sqrt | 15,344 |

The prepared [`float/emit.bend`](../../selfhost/tools/performance/phase112/float/emit.bend)
supports operation23 and operations26–35: **1,902,684** of ray's calls and **8,196
of 10,291 (79.64%)** numeric-recurrence calls. These are operation-coverage counts;
they do not qualify that candidate's correctness or speed. Numeric recurrence
already needs only 286 whole-process dispatches, and its main worker accounts
for 16,388 of 17,173 public calls. Further generic trampoline tuning is therefore
a weaker hypothesis for that kernel than removing arithmetic ABI crossings.
Preserve F32 rounding, NaN comparisons, signed zero and operation order; do not
silently introduce fused operations or replace the guarded F32→U32 conversion.

Ray also performs **1,365,976 public keeps** and **272,179 public sinks**, against
just 4,235 heap allocations. Known scalar values make these ownership operations
trivial at runtime; preserving their representation facts can remove many calls
at compilation time. Current counts alone do not identify every eligible operand.

There is another finite scalar boundary: ray executes **932,373 Succ
special-takes**, whose exact runtime operation is `out[0] = term - 1` after
the matched-constructor premise. The compiler executes **4,686,402 Chr
special-takes**, whose operation is `out[0] = term`. These are candidates for
ordered structured copies/arithmetic under the existing typed admission, with
scratch ownership and match premises preserved. They do not require changing
the U32/Word representation or treating an arbitrary tagged Term as scalar.

Ordinary call structure remains exposed:

| Ray function | Dispatches | Arity | Current limiting shape |
|---|---:|---:|---|
| `sx`, `sy`, `sz`, `sr` | 55,464 each | 1 | Match failure exits; some real non-tail calls |
| `isect.go2` | 53,496 | 3 | Failure exit and downstream calls |
| `isect.go` | 53,496 | 2 | Tail edge depends on admitted callee |
| `isect5` | 53,496 | 10 | Exceeds original eight-argument private gate |
| `nearest` | 39,760 | 12 | Wider arguments and real continuation frames |
| `nearest.t` | 19,680 | 10 | Wider arguments and real continuation frames |

None of these has a private copy in the profiled SSA. `isect5`'s body has 17
primitive-call sites, nine keep sites and a terminal jump: scalar expansion and
wider private admission compose naturally here. The already prepared CPU
fail-stop and wider-argument experiments address real barriers. A larger argument
limit alone cannot admit `nearest`: real non-tail frames still require a separate
safe composition/fusion rule. Test argument permutations, captures, failure paths
and deep loop stack behavior before composing the changes.

## Other workloads and transport overhead

- **Lexer:** `Bool.and` dispatches 61,614 times; `cls`, `step.at`, and `step`
  dispatch 30,806 times each. Its 236,562 frames and 463,226 stack reads favor
  branch/ordinary-call simplification. Primitive expansion alone covers little.
- **Map:** `Map.bit.go` dispatches 25,996 times and `Map.bit.go.rec` 20,372.
  There are 44,720 Tuple constructions, 50,665 Tuple takes, 32,200 SCon
  constructions and 34,917 SCon takes. Avoiding transient products and preserving
  ownership through call composition is more grounded than tuning arithmetic alone.
- **Unicode:** `String.append` dispatches 4,506 times; 3,094 frames target its
  hot continuation. String/List rebuilding remains important: 18,076 allocation
  calls and 7,791 RFC wraps. Reuse the existing shared/static ownership gates
  when evaluating constructor-shell or direct-call changes.
- **Closures:** 2,084 public applies and 2,091 closure constructions dominate
  its distinctive structure. `CLO_APPLY` dispatches 2,092 times. Known-closure
  specialization is relevant here, but captured values and returned closures
  require their own controls.

Register transport remains a cross-cutting secondary cost. The compiler requests
51,406,226 copied words and **659,583,196 zeroed words**: 92.77% of its register
transport words are clearing, about **5.277 GB** of source-requested stores.
Ray requests 13,397,855 zeroed versus 2,134,740 copied words, or 86.26% clearing
(107.18 MB requested). This motivates reducing transfers and tracking initialized
live widths, but is not a license to delete clearing blindly. Preserve the wide
bank, closure, continuation and invalid-metadata controls; eliminate crossings
first when possible.

## Ranked next experiments

1. **Scalar-pattern recovery into structured IR.** Largest demonstrated
   removable-work category for the compiler; can reduce execution, emitted code
   size and machine-build work together. Reuse mature guards and keep fallback.
2. **F32 instruction expansion plus scalar ownership facts.** Directly targets
   ray/numeric arithmetic traffic; validate bit semantics before a short paired
   uninstrumented run. It will not solve compiler Word matching by itself.
3. **Compose fail-stop/wider private workers with safe non-tail fusion.**
   Targets ray and lexer dispatch/frame traffic; measure new admissions and
   eliminated transfers rather than simply raising limits.
4. **General selector specialization.** Real measured compiler applicability,
   cheap existing semantic rule, and independent closure controls. Use it as a
   complementary experiment, not the explanation for all compiler overhead.
5. **Then address transient products and residual register clearing.** Reprofile
   after the first changes; representation fixes may remove much of the work
   before a broader ABI or allocator change is justified.

The profiles demonstrate mechanisms and their dynamic frequency. They do not
yet demonstrate an optimization gain. The next evidence must be an actual
correctness-preserving candidate, reduced relevant counts, and a fast matched
measurement using the **uninstrumented** runtime.
