# P40-001 — Direct unfused first-order lists

- Owner / independent reviewer: list investigator; independent reviewer evidence agent.
- Started: campaign 2026-10-02 00:18:49 UTC; record authored 00:24:25 UTC, before scheduled timing. Source inspection only.
- Baseline: installed Phase39 checked05 API `04d9ebf417a20297598bb6b047936a02228f3b8fb3a3b0cc4b59eeea04bad49f`; upstream `018751270e800bc222a93dad7f257083ee53a5f7`.
- Correctness: unchecked new mechanism. Measurement: not run. Decision: investigate.
- Root executes serially: Node24.18, CPU3, heap1024MiB, treeRSS2048MiB, free-memory floor2048MiB; fresh output directories, retained failures.
- Prospective design: [Phase40](../../design/phase40/lists.md). Outcomes: [implementation report](../../implementation/phase40/README.md).

## Claim and cheapest disproof

**Hypothesis:** direct producer/filter/map/fold helpers reduce first-order list dispatch while preserving every materialized tagged stage. Keep BigInt countdown to isolate dispatch. Producer-only and whole-component ablations distinguish the source of benefit.

**Invariant:** admit only an exact scalar root with verified complete dependencies and host state; no public list argument enters a direct helper. Producer/map read heads before tails; filter applies predicate after the recursive tail. Empty outputs remain fresh; dropped heads alias the computed tail. Generic wrappers retain mutation, forcing and error order.

**Disproof:** independent complete list/value/sharing oracle mismatch, public/host mutation bypass, raw/forged entry admission, reordered errors, stack growth or no useful gain in the bounded screen. Callback specialization remains rejected; fusion waits for a direct unfused comparator.

## Controlled setup and gates

Use the [Phase40 tool recipe](../../selfhost/tools/performance/phase40/README.md): exact portable starting baseline, explicit Phase37 catalog, saved-output prototypes labeled unchecked, then checked B1 and actual-emission controls for surviving source changes. Clean measurements use newly executed baseline/candidate/TS roles in the same run; no historical median denominator. Retain module hashes and full rounds, ranges and drift; diagnostics remain separate.

No completed timing or correctness observations are recorded here. Freeze this input record; future results and independent review belong in the linked implementation report and experiment ledger, retaining rejected attempts. Full integration, inherited/new owners, compiler-request cost and installed/relocated checks precede any promotion.

## Preservation

Tracked design, hypothesis and Phase40 scripts identify the intended experiment. Raw results use fresh Phase40 paths, later linked by exact identities and commands. Closed Phase35/36/37/39 evidence and the103 unrelated starting files remain protected. No new result is claimed by this prospective record.
