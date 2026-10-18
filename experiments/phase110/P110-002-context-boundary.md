# P110-002: validate runtime context once per closed owning call chain

Status: diagnostic design recorded before candidate execution, 2026-10-18
20:56 UTC. This is an extension of the Phase110 ambition ladder, after the
original policy selection and fresh held-out evaluation. It cannot retroactively
reselect that winner or make its old held-outs fresh again.

## Observation and hypothesis

`native-transfer01` compares the already selected compact-general QBE policy
with fused QBE on two additional computations, using actual native products,
the same runtime and independent original oracles. Five paired rounds give
nt_append median ratios 0.9215, 0.7180 and 0.6246 on its three predeclared shapes;
one round is noisy. Actual non-tail recursive Base String.append regresses in
every round: median 1.1584 on shared-left512 and 1.0519 on unique-left1024.

The selected runtime template calls `rt_ir_heap` and `rt_ir_alc` on each worker
entry. Each helper validates the active single-thread context and clean scratch,
then returns a stable base pointer. A reverse loop amortizes this work; recursive
String.append repeats it once per cell. This is a source/machine hypothesis,
not a measured attribution of all lost time.

## Competing representations

Keep the public owning ABI unchanged and retain both checked getters in each
exported wrapper. Private workers are only reachable through the authenticated
closed worker catalogue. Compare:

1. **Threaded pointers:** the wrapper passes borrowed heap/allocator pointers
   as two extra private arguments; ordinary calls forward them.
2. **Private context loads:** internal calls keep their ctx-plus-Term ABI and
   read the two context pointers at authenticated offsets. The wrapper still
   performs the original checks once. Separate static assertions bind the exact
   context layout; no production runtime layout change is allowed.

Both preserve mutable allocator loads, ownership credits, all slow paths and
single-context restrictions. The runtime allocates its arena at open and extends
the mapping without relocating its base; ALC[0] is static. Closed owning code
cannot open/close a context, and scratch must be empty across each ordinary call.
Those are explicit runtime/source premises, not properties established by NxPtr
typing alone. Swapped heap/allocator arguments have the same type and must fail
the exact regenerated-machine gate.

## Smallest useful experiment

Use the existing checked API, actual captured canonical String.append facts and
unchanged original graph oracle. First reproduce the selected native QBE bytes
exactly from those facts. Then emit additive candidates in Bend, validate the
original ownership library and complete transformed machine graph, and test
mutations of pointer order, wrapper checks, exports, private-call mapping and
offsets. JS/Python may only transport, prepare or supervise.

Compile the actual candidates with QBE and the C control; use the same pinned
runtime, with assertion-only acquisition where context offsets are exposed.
Execute the existing complete-value/alias/release controls before timing. Compare
the fixed policies with alternating order on the same bounded-depth recursive
cases, plus reverse/ordinary-call regression controls. Inspect machine code to
confirm the intended call removal and any added register/stack cost.

No new policy search, production selection, whole-compiler build or performance
claim is authorized by a local positive result. Stop source changes by21:30 to
leave time for report and evidence consolidation. A negative result is useful:
it distinguishes context validation from allocation, call-frame and memory costs.

## Result

The bounded experiment completes with `context-source07`, its exact admission,
`context-api07`, `context-emit04` and `context-machine02`. The native source05
selection remains unchanged. All nine libraries reproduce the original native
QBE/C bytes before transformation, pass 31 Bend controls and 54 explicit
malformed-certificate refusals. Eighteen actual workers pass 234 original semantic
observations. The assertion-only runtime object is byte-identical to the original.

Five paired rounds, with the original two bounded String.append inputs and all
semantic/release checks, give median variant/current-compact ratios:

| Backend/input | Threaded pointers | Private context loads |
|---|---:|---:|
| QBE/shared left512 | 0.9040 | 0.8841 |
| QBE/unique left1024 | 0.8501 | 0.8571 |
| Clang/shared left512 | 0.8821 | 0.9072 |
| Clang/unique left1024 | 0.8340 | 0.8426 |

Every paired ratio improves; one Clang unique round is anomalously low. Keep the
full five-round range rather than selecting it. Context-machine02 takes117.926s
guarded wall and135.7MB peak RSS. Static inspection confirms two fewer checked
getters per recursive private entry. QBE body sizes548/568/522 bytes for
baseline/threaded/context expose the extra forwarding cost despite the shared
call-removal benefit. The matched C bodies are409/415/375 bytes. These are static
sites/bytes, not measured instruction or cycle counts.

The additive synthetic eight-owner witness in `context-wide-machine02` passes
24 observations across six builds, including all eight owners physically aliased,
both release orders and zero live allocations. Machine inspection confirms the
QBE private eleven-argument ABI (six registers and five stack slots). Clang
optimizes unused hidden arguments and the returned owner away from private calls,
so its result does not establish an eleven-argument internal machine ABI. This
is an explicit synthetic calling-convention gate, not actual-source coverage.

Failures remain preserved: missing unused canonical descriptors in the initial
capture; transport expecting the wrong control-report shape; hosted recursive
String.eq overflowing on a large certificate; rejected local/match binder forms;
missing Clang stddef.h; and a disk preflight refusal before the wide target ran.
The successful capture still derives checked descriptors in Bend. The exact
comparator now consumes full codepoints with direct self-tail recursion. The
successful C builds all use the same pinned header include path. Lossless
compression of an unused cleanup proposal recovered disk headroom; the160MiB
guard was not weakened.

Observation: validating once removes measurable repeated work in this admitted
closed call chain. Limit: two reused timing graphs do not select a universal
ABI, prove a whole-compiler gain, or directly compare against fused QBE. Do not
multiply separate campaigns to claim the original transfer regression is fixed.
The next useful gate is broader real closed-call workloads and a new matched
denominator before native integration. See the [phase report](../../implementation/phase110/README.md)
and its sealed raw receipts for exact pins and commands.
