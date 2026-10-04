# P43-001 — Full owned native-String lexer component

Hypothesis: one exact public entry guard plus full typed lexical component
removes generic generator/lexer dispatch and yields >=2× checked16 lexer runtime,
while preserving complete String/Char, Slot/Cls/Mode/Sigma, demand, host and alias
semantics. Domain: saved emitted JS first; source promotion is separate.

Owner: phase43_strings. Baseline: installed Phase42 checked16 API
63ddb2dd35554aafafc26dbdff4aba86b5d3774cd0d99a9509ccf237d210ba54,
commit714c5f5, upstream0187512. Historic phase42 artifacts are read-only.

[Design](../../design/phase43/strings.md),
[handoff](../../implementation/phase43/strings.md),
[derive](../../selfhost/tools/performance/phase43/strings/derive.mjs),
[controls](../../selfhost/tools/performance/phase43/strings/controls.mjs).

Correctness: static syntax checks only; root runs complete selected controls.
Measurement: not run. Decision: investigate. Smallest falsifier: derive fails to
find exact live edges, full ordinary bench does not increment gen/line/batch/lex/
step counters, any full-value/alias/observer mismatch, or <1.5× smallest fixed
point screen. A pass is not compiler-source correctness or broad conformance.

Original/noise same complete bytes quantify same-run variation. Guard, class,
step and lexical-consumer complete ablations precede full producer+consumer.
Full retains all data materialization; faster output cannot justify fusion.
Root serializes bounded jobs and timing; owner runs no compiler/build/program
execution. Failures and timeouts retain fresh output directories and JSON status.

First root derivation failed before module generation at the stale cls-site
count inherited from Phase40. Corrected derive-v2.mjs retains the exact selected16
parent hash and static counts cls2/step1/lex2. Original derive.mjs remains the
failed consumed version. No correctness or measurement status upgrade follows.

Root selected controls pass for strings-prototype02/strings-controls02 (4.925s).
Two manual ordinary-public fullcomponent screen points show17.67×/18.84× over
original and4.99×/5.53× TypeScript. This exceeds the saved-output discriminator;
source integration is now justified but unqualified. The combined-proposal-v3
patch retains actual native matcher lowering plus prng-prefix support; acceptance
requires generated source activation and full controls on the emitted derivative.
