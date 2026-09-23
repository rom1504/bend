# Final-source compilation comparison (P5-023)

The maintained equality derivative reduces mean full-source **process wall by
43.45%**, from 642.58 seconds for genuine checked B1 to 363.39 seconds. Pinned
TypeScript takes 60.25 seconds: the measured Bend workflows remain 10.67× and
6.03× slower respectively. Both opposite-order pairs improve (44.53% and 42.35%).
This is a completed six-row compilation comparison, **not a self-host fixed point**.

The [independent audit](full-source-audit.json) passes after reading the actual
six request/result files, output bytes, process logs, output-oracle records,
ordered roots and consumed identities. The [auditor](full-source-audit.py)
recomputes the statistics without calling a compiler or rerunning an oracle.
Its first successful result is retained in
[attempt01](full-source-audit-attempt01.json); the final audit additionally checks
the separately recorded plan association and computes aggregate reductions.
The [archived inputs and raw results](full-source-evidence/manifest.json) retain
the comparison itself. The [audit preservation record](full-source-audit-history/manifest.json)
also retains the exact first-audit source, so its successful historical result
does not depend on the later auditor's bytes.

| Workflow (two fresh processes each) | Mean request | Mean process wall | Process ratio to TS | Maximum RSS |
| --- | ---: | ---: | ---: | ---: |
| Pinned TypeScript | 56.992s | 60.248s | 1.00× | 1.898GiB |
| Genuine checked B1 | 641.355s | 642.581s | 10.666× | 2.777GiB |
| Maintained equality derivative | 362.181s | 363.392s | 6.032× | 2.774GiB |

The request-time reduction is 43.53%; request ratios are 11.253× and 6.355×.
The six process-wall observations, in their actual order, are TS 60.361s,
checked 647.905s, derived 359.379s, derived 367.406s, checked 637.256s,
TS 60.134s. They ran on CPU2 with Node24.18.0, a 4MiB Node stack, verified
OS stack allowance, 12GiB heap and a maximum 900-second child deadline.
All rows completed without a spawn error, signal, timeout, overflow or skipped
cell. Other intentional compiler workloads were paused for the controlled window.
Two opposite-order samples on one host provide no confidence interval or general
performance guarantee. The raw rows and phase counters remain available; nested
compiler phase timers overlap and must not be added.

## Exact workload and execution gates

All variants compile the same final assembled source
`e3b927d13dc2645e19171b72de60c49dd5bc5e5059863937153b957e2ce0ec1d`
with the canonical pinned Base and frozen output runtime/host. The genuine API is
`5969c53d34a088bc9630eb2c065c2eea7fd260294cf3fefb14dffb305b7e4667`;
its derivative is
`e2b5463678a26558e8fea1d585782e0863f1046067949a374f0469080281b15a`.
The derivative retains its own verified lineage, not a fabricated bootstrap.
The upstream revision is `6018e28ecc67cf1fffc0c20c64b11023474c2df8`, with
recorded successful tracked-clean and revision checks before and after the run.

The actual B1 preflight produces **1,566 ordered requested roots**. TypeScript
independently verifies their membership and receives that exact order; every
measured Bend request reproduces it. Each resulting module is imported in a
separate oracle process and executes ASCII/non-ASCII identifier controls. Each
Bend-generated module additionally executes its own `j_library_roots` classifier
on the retained TypeScript metadata. These are actual prior oracle executions
whose files and logs the audit verifies; the audit does not rerun them.

All four Bend outputs are byte-identical: 1,170,415 bytes, SHA-256
`5043267732f5178b12d14708e7dc07e3aa1a71b9d1d5949ef279af23c4297edd`.
The two TypeScript outputs are byte-identical within their emitter family:
1,234,102 bytes, SHA-256
`f58b21241ae5323425df1e1a7f00711e32fafcb1fd7ce8d6eddc1c1f6def76c5`.
Cross-emitter byte equality is neither expected nor claimed. TypeScript exposes
exactly the requested ordered roots; Bend exposes 1,848 globals/dependencies,
including all requested roots, with identical B1/derived export keys. That ABI
difference is preserved rather than described as identical export objects.

## Timing and proof boundaries

TypeScript loads and checks Base in each fresh process. Both Bend variants use
separately validated disk caches whose decoded books are deeply equal; their
preparation is outside timing. The recorded prime process walls are 21.81s and
14.25s, including wrapper/startup work. Consequently these ratios compare the
selected workflows, not identical cache work or isolated backend lowering.
Process-local warm APIs are not reused and OS caches are not flushed. Request
time excludes imports, provenance hashing and output-file capture; process wall
includes them. Output import/execution oracles are outside both timing measures.

The [plan](../../experiments/phase5/P5-023-final-full-source-comparison.md) was
committed as `24f3105c…` at00:47:41UTC, before the comparison started at
00:48:45.142UTC on2026-09-23. Root's `full-source-plan-identity.json` association
was recorded later, at01:18:58.962UTC, and explicitly does **not** amend the original
benchmark input list. The audit verifies the current plan hash and chronology;
the association's historical commit-byte comparison is retained as root's
separate evidence. The comparison closed at01:25:56.553UTC.

The maintained selfhost runner must independently produce and verify its own
stage2/stage3 report. A timed compiler output cannot be relabeled as one of those
stages. Any subsequent fixed-point/output linkage belongs in a separate audit.

## What the remaining cost suggests

The controlled change is the verified equality derivation, so its reduction is
evidence that the generated string-equality path is a major cost in this B1
workflow. The [recorded coarse phase observations](full-source-phase-observations.json)
show reductions across parsing, checking, annotation, layout checking and emission;
the benefit is not confined to writing JavaScript text. These arithmetic summaries
reuse the six recorded runs and perform no additional compiler execution.

| Coarse API timer | Checked mean | Derived mean |
| --- | ---: | ---: |
| Parse compiler source | 15.77s | 9.64s |
| Check from validated Base prefix | 165.41s | 101.36s |
| Annotate selected definitions | 161.27s | 104.24s |
| Validate JS layout | 84.70s | 39.16s |
| Emit selected library | 155.64s | 70.36s |

These timers are not an additive decomposition, and TypeScript's phase boundaries
differ. The remaining checker, annotation and lowering work deserves a fresh
causal profile before another major representation or emitter rewrite. Parsing
is a much smaller observed region in this workload. The experiment provides no
specific forecast for another optimization and no evidence that the derivative
accelerates generated user programs: its emitted bytes are deliberately unchanged.
