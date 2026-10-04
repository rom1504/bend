# P45-020: acyclic public entries with a reduced primitive fence

Status: **reject promotion after the decisive two-point screen**. Keep the recursion profitability gate in worker19. This experiment changes no nullary/Unit admission and no runtime ABI.

## Design and isolation

[P45-018](P45-018-acyclic-root-profitability.md) restored the fast generic row by requiring potentially repeatable work before admitting a new alias-only public worker. [P45-019](P45-019-used-primitive-fences.md) independently reduces primitive dependencies while retaining that gate. The question here is whether a smaller fence makes the previously rejected acyclic public worker profitable enough to remove the gate.

Construct worker20 from **frozen worker17b plus exactly the worker19 collector**, preserving strong root-plan ranking, native-source root policy and contiguous-lambda public-prefix legality. Worker17b predates the recursion profitability gate, so this deliberately restores acyclic alias-only entries without another admission rewrite. The causal runtime comparison is worker19 versus worker20, holding the collector and runtime fixed.

The expected one-file patch is `/tmp/phase45-used-primitives20/used-primitives.patch`, SHA-256 `1ac78715ed8c28483578eb87a171f506d2d3b9d225484b33ed8f48f4a60c00c2`. Independently comparing the root's frozen source20 against 17b confirms every original source/tool/test file is identical except `jpure.bend`; its SHA-256 is `c6a72ce2b102e50e24b9c8142f99ea4dce2853165cb3680e50b39f6099c33ee0`, matching the expected collector-only derivative. The source snapshot additionally preserves `jpure.bend.orig`, an uncompiled patch backup. No consumed input was removed to conceal that provenance.

The supported host contract remains the preexisting standard-intrinsics-at-import contract documented in P45-019. Full host and String guards, all source/native dependencies, both branches' used primitive dependencies, exact entry, public-prefix legality and generic fallback remain unchanged. The primitive collector's prior broader pre-import counterexample remains preserved.

## Qualification and decisive result

The checked build and eight maintained suites pass. The fresh positive-arity v2 primitive controller also passes all 40 supported-boundary observations against the newly compiled modules. These results cover their stated cases; they are not full frontend/backend qualification or a full-corpus performance result.

The fresh two-point screen completes in **14.841s**, with three rotated rounds per point:

| Point | Worker19 median ms | Worker20 median ms | TypeScript median ms | 19/20 speed ratio | 20/TypeScript |
| --- | ---: | ---: | ---: | ---: | ---: |
| Complete generic row32 | 0.384126 | 1.980088 | 0.006974 | 0.193995× | 283.911× |
| Lexer | 2.595708 | 2.576720 | 1.680178 | 1.007369× | 1.534× |

The row is **5.1548× slower** than worker19; lexer is effectively flat. The reduction in primitive dependencies does not make the acyclic public helper competitive. The remaining fixed host/String checks and entry protocol are plausible major contributors, but this two-point experiment does not separately attribute every nanosecond to guards versus JIT or body execution. It does establish that removing the profitability gate is harmful under the current complete implementation.

Evidence: `selfhost/build/phase45/runtime-worker20-vs19-row-lexer/report.json`, SHA-256 `0b095d9191dacdfb9f8258cd94753104e6a86b2621da92636349662d1849ca29`; `qualify-worker20/report.json`; and `primitive-positive-controls20-v2/report.json`. Instrumented controls are not timing evidence. No incomplete run is pooled into these medians.

## Independent acyclic fixture: prepared, not executed

A renamed two-function scalar graph was prepared as `fixtures/acyclic-entry-v1.bend`, with catalog `acyclic-entry-catalog-v1.json` and controller `acyclic-entry-controls-v1.mjs` under `selfhost/tools/performance/phase45`. Its source uses ordinary branching and unsigned arithmetic; the proposed controller pins checked emissions, compares 30 independent input pairs, observes separate activation, tests 10 live helper mutations, and compares public metadata plus partial/raw/overapplication behavior.

The root stopped further worker20 acquisition after the decisive regression. This additional fixture/controller was therefore **not compiled or executed**; its prepared cases are not counted as passed evidence. The existing independent primitive controls did execute and pass. Do not infer more coverage from the existence of the unexecuted files.

## Decision

Retain worker19's conservative recursive-work gate. An acyclic private helper can still be emitted directly inside a larger admitted graph without repeatedly paying public-entry guards. Future work should enlarge safely proved private regions or reduce boundary cost under the same contract, rather than reopen every small public helper based only on a shorter primitive list.
