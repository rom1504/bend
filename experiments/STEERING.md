# Current frontier: Phase58 last01

**Last01 is installed and verified.**
Direct JavaScript remains the default; explicit legacy JavaScript and native C
remain available. Ordinary compilation runs Bend code without TypeScript fallback.
Archive closure and member verification are complete; see the Phase58 publication index. No PR comments are authorized.

[Design](../design/phase58/compiler-allocation-and-code-generation.md) ·
[Report](../implementation/phase58/README.md) ·
[Final measurements](../implementation/phase58/final-measurements.md) ·
[Reproduction](../selfhost/tools/performance/phase58/README.md) ·
[Hypotheses](phase58/).

Selected attempt: `selfhost/build/phase58/checked-last01`.
Checked B1 API: `641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a`.
Source: `85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091`.
Qualified direct B2/B3: `a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081`.
Upstream: `018751270e800bc222a93dad7f257083ee53a5f7`; Node 24.18.0.
Both runtimes, driver and all 17 native modules retain Phase56 bytes.
The installed artifact is checked B1; emitted B2 has no fabricated checked sidecar.

## Established results

Six general changes survive: last-live-constructor-key placement, allocation-free
intermediate constructor misses with checked-owner fallback, scalar provenance
through exact residual Word reconstruction, proved literal continuations,
validated per-definition dependency deduplication, and shared mutual-tail SCC
workers. Partial application, ordered effects/errors, aliasing/capture, erased
fields, special keys, cycles and tail/reentry boundaries retain focused controls.
The final key rule is last LIVE constructor field computed, earlier ordinary keys
literal, __proto__ always computed; ordinary marshalling keys remain literal.
All-literal and whole-computed rollback evidence remain historical, with their
program/compiler tradeoff. No width cutoff is selected; its grid is unexecuted.

Final checked/source/B2 gates pass, including 14 B1 integration jobs,96 source,
34 numeric,18 composition,2 overapplication,8 maintained suites, native retention,
fresh own-source type acceptance and exact B2→B3 reproduction. Type acceptance
and expected unsafe proof-trust refusal remain separate from kernel validity.
Known pinned-reference NaN defects stay explicit; no new mismatch is waived.

Fresh full-program timing passes23 sources / 45 points / 669 samples. Equal-point
new/TS is 1.046110 versus old/TS 1.061731; new/old 0.985287. Equal-source new/TS is
1.040502. No point regresses >10%; worst regression 2.949%, zero timing flags.
These are corpus aggregates, not universal parity or a promise for other hosts.

Changed-source B2 request comparisons take49–56% less import+first time and 59–67%
less later-window time on Evening/lexer. B2 still takes 2.4–2.7× same-campaign TS.
B1 is mixed, including 3.89% later lexer regression. Separate sampled lexer
allocation drops 89.41% versus old B2; cumulative sampled allocation is not RSS.
Own-source emission 36.06s versus retained old 223.48s yields descriptive 6.198×;
the baseline was not freshly rerun consecutively. Peak RSS does not improve.
Samples still warm; no steady-state or isolated six-factor attribution claim.

Source grows 314 physical/238 code lines to 26,560 physical/21,823 code,
3,055 definitions,101 types,108 modules. 98 modules retain bytes. Generated-code
shrinkage and source growth are different quantities; no source-simplification claim.

## Remaining work and publication boundary

1. [Release execution](../selfhost/build/phase58/final-last01/release-execution/report.json)
   is complete/pass: install, integrity before/after, legacy 42 and default 24.
   Finish publication while preserving this installed identity.
2. Complete final preservation/protected103 checks, time accounting and reports;
   explicitly close raw writers, then create/reopen-verify the archive. No archive
   completion is assumed from idle workers or a source checkpoint.
3. Future performance work needs measured discriminators: remaining TS compiler
   gap, substitution/serialization and declaration-event visits. Local ADT-key
   reuse is deferred/unmeasured; context-incomplete caches remain unsupported.
4. Keep B1 allocation missing for this final source explicit; do not substitute
   intermediate shared01 profiles. Avoid more representation/emitter changes
   solely on profile percentages or saved-code syntax counts.

Heavy jobs remain root-serialized under one guard, private staging and fresh paths.
Preserve failed attempts, consumed producers, closed Phase54–57 history, seven
previous release files and all 103 unrelated files. Stage explicit owned paths.
No additional target is authorized by this frontier document.
