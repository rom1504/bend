# Native declaration parallelism: annotation first

This is a **proposal for a later experiment**, based on read-only source inspection. No parallel compiler was built, no timing was collected, and no production source or frozen artifact changed. It targets multicore wall time, not single-core efficiency or faster emitted user programs. See [P4-018](../../experiments/phase4/P4-018-native-annotation-parallelism.md).

## Why checking is not an independent map

`check_book` in `selfhost/src/check/kernel.bend:1033` is an ordered fold over declaration events. Before checking event `d`, it checks `event_error(done, d, lookup(done, dn(d)))`, then checks `d` against `book_put(done, declared(d))`. Only success installs the complete declaration into `done`. The context contains the precise preceding events, with the current body absent. Replacing it with the final book changes forward visibility, recursive unfolding, duplicate detection and law-fill behavior.

There are additional dependencies:

- `event_error` compares a filling definition's signature against the earlier law in the earlier context, and checks constructor names against earlier declarations.
- `signature_mode(d, rest)` deliberately consults the remaining events for a later unsafe law fill. Merely splitting contiguous event ranges loses this suffix information.
- `check_template_open` extends the checking context with template-local definitions. These extensions belong to that one definition's recursion, not the global event stream.
- `check_open` reports remaining laws only after all earlier event checks succeed. Exact-prefix checking seeds precisely the validated prefix, not an arbitrary final context.

A theoretical speculative checker could construct every original prefix once, assign each event its original prefix and suffix, preserve `event_error` before its own definition check, and select the lowest-index error after joining. This reproduces returned strings only when all scheduled work terminates normally. A later divergent or resource-failing check can prevent an earlier error from being returned; the current serial checker would never execute that later work. Prefix construction and retention also add memory and bookkeeping. There is no cheap, unrestricted split/combine replacement preserving the current first-error and demand behavior. Do not rebuild a book separately for every declaration, or call checking against the final book and describe it as equivalent.

## The smaller independent boundary

`annotate_selected(book, selected, stops)` in `selfhost/src/check/annotate.bend:157` is exactly:

```text
context = book_context(book)
ordered_map(selected, d => stops contains dn(d) ? d : ka_def(context, d))
```

`ka_def` constructs a fresh environment for its own declaration. All workers read the same original context; earlier annotated definitions are not installed into that context. Local environments, substitutions and normalization state are passed as values. Templates have already passed the serial checking/specialization pipeline; annotation still uses the same lookup, normalization and local-context functions. `BookCache` and its binder bound must be constructed once from the original context and shared unchanged. Do not build a context from a chunk or annotated output.

For a finite list `selected = c0 ++ c1 ++ ... ++ ck`, the proposed result is:

```text
annotated = ka_defs_except(context, c0, stops)
         ++ ka_defs_except(context, c1, stops)
         ++ ...
         ++ ka_defs_except(context, ck, stops)
```

Run the chunk workers concurrently, but concatenate in source order. Preserve every element, duplicate and stop entry; do not merge by name or reorder by completion time. The concatenation must rebuild only the list spine, preserving each returned declaration exactly. A first prototype should use two contiguous chunks and then four, without changing annotation internals. Build the context and split the selected list once, outside the workers. Node-weighted splitting is a later option only if measured imbalance warrants its additional traversal.

The insertion point is the existing `rapid_bundle_emit`/graph-host annotation call, after serial checking, ownership, TODO, specialization, entry and reachable foreign-declaration validation. Keep layout checking, late asset loading and emission serial and unchanged after the ordered join. This does not introduce a native parse/check lane or solve [P4-017's host protocol obstruction](native_frontend_feasibility.md).

## Native runtime feasibility and cost

The pinned compiler already emits native fork/join code for multi-binding lets. The existing `tests/reg/borrow_fork_hold.bend` demonstrates `a b = reader1(xs) reader2(xs)`. `comp.ts:2557` emits a join task and child call tasks, plus a serial path; `comp.ts:5290` selects serial execution for one worker, and the pthread pool supports `--threads N`. Ordinary CPU forks do not require a GPU or a new scheduler. One binary can therefore compare its serial fallback with two/four workers; an unchanged serial wrapper remains necessary to measure added splitting/joining overhead.

Shared input is possible, but not free. `term_keep` increments an existing reference count or wraps a dynamic node; `ctr_take` on a shared node exposes fields and adjusts their ownership through `span_fade`. The compiler's annotation laws currently take `+book`, and the emitted C must be inspected to determine whether the shared context is borrowed or repeatedly retained/projected. The existing borrowed-reader witness proves a runtime capability, not that annotation already receives that optimization. Do not change quantities blindly or count reference sharing as zero-cost deep sharing. Worker-local outputs and normalization allocations can raise peak RSS and compete for memory bandwidth even when the input graph is not fully copied.

The existing serial O2 native compiler takes a median 245.364 seconds on the final compiler source in [the same-source comparison](../../implementation/phase4/native-final.md). That is **not an annotation timing**. No defensible percentage ceiling is available until the annotation fraction is measured. If annotation occupies fraction `p` of serial wall time, idealized speedup with `k` workers is at most `1 / ((1-p) + p/k)` before scheduling, imbalance, allocation and memory costs. Source inspection alone does not determine `p`.

## Smallest discriminating experiment

Use a disposable checked Bend wrapper and the existing pinned C/O2 build path, keeping all 59 production modules untouched. Start from the final frozen source `34c6ef63…`, checked API `0653f21e…`, canonical Base and runtime in the combined launch report. Load, check and specialize once, construct the identical reachable annotation input, then compare the unchanged serial worker against a fork wrapper. Record wrapper/source/toolchain/build hashes and cost separately.

1. Prove the wrapper is checked and the generated C actually contains the intended fork. Inspect context captures and `term_keep`/`ctr_take` use. First compare exact annotated KDef/KTerm trees against the ordinary serial function on small fixtures, including cross-declaration references, dependent types, templates, recursive references, erased/foreign/absent bodies, selected subsets and stops. Keep all malformed-source diagnostics on the unchanged serial path.
2. Measure an actual compiler-core book with the same annotation input. Fully consume an annotation digest before the stop clock and compare it with the structural oracle. Separately include split/join, process wall and peak RSS. Compare unchanged serial, fork-wrapper `--threads 1`, `--threads 2`, then `--threads 4`, reversing order on the second round and allocating matching physical CPU affinity. Never infer a multicore gain from differently primed source/Base caches.
3. Stop if the one-worker wrapper costs over 5%, two workers do not reduce annotation wall by at least 20% across both orders, exact output differs, or peak RSS exceeds 1.5 times the serial run. These are proposed experiment thresholds, not measured outcomes. A workload too small to discriminate should use a real larger subset once, not repeated synthetic scaling until it wins.
4. Only a survivor earns a full-source compile: require exact final emitted JavaScript bytes, actual execution controls, unchanged negative phases/diagnostics and separate total CPU/RSS versus wall time. A native compiler wrapper must not silently replace public JavaScript APIs. Build expense remains part of the development-loop decision.

Annotation is implemented with `@unsafe` functions, so this inspection is not a proof that every caller-supplied graph terminates. On ordinary finite, terminating immutable inputs, the value equation above is straightforward. Parallel runtime failures, resource exhaustion and divergent annotation demand need separate analysis before a general public contract can change. The first prototype stays within the checked native-host boundary and makes no universal error-order or termination equivalence claim.

Estimated first implementation and meaningful component gate: 60–90 minutes plus the checked native build. Full-source and runtime validation make it a subsequent campaign task, not a justified late change to the already frozen Phase 4 source. The immediate decision is **defer implementation, retain this falsifiable annotation-only route; reject naive parallel declaration checking**.
