# Phase67: native performance and a compiler proof pilot

Work started October 8, 2026 at 09:01:10 UTC, from `2035010`.
[Design](../../design/phase67/native-speed-and-proof.md).

The selected source candidate removes immediate-value continuations and inlines
exactly saturated scalar primitives. The three-family screen measures 38.9%
less native execution time; broader qualification is in progress. The installed
Phase66 image remains the preserved baseline; no release promotion or
independent compiler-correctness proof is claimed at this checkpoint.

| Work stream | Hypothesis | Status |
| --- | --- | --- |
| Native/C | Remove general call/value transport overhead before machine optimization | Baseline and two ablations measured; held-out validation in progress |
| B1/B2 compilation | One affordable repeated-work reduction can justify a short screen | Deferred after bounded source/evidence review |
| Proof | A real lowering transformation admits an independently checked Bend theorem | Both Bend checkers accept; independent Lean kernel blocked by toolchain version |

Root preserved the seven installed files and verified the 110 inherited files.
Baseline receipt: `selfhost/build/phase67/baseline.json`, SHA256
`b1bc87ec9dd04aefacc83ac577a1c1ebcae77a33c13a2e9ca8cb0bcaded94cc3`.
The frozen upstream remains `059266225b77c8ca256ac6b25ee5c21449bab151`.
Historical Phase66 and earlier raw evidence is immutable.

Current evidence: [native baseline](native-baseline.md),
[ablations](native-ablations.md), [source review](native-atom-review.md),
[compilation-side decision](compilation-side-review.md), [proof scope](proof.md)
and [final qualification plan](final-qualification-plan.md).

The selected checked B1 passes strict36, eight paired native fixtures, four
fixtures with explicit one/four-thread runs, and raw-core fallback/diagnostic
controls. The conservative executable-closure audit finds all 1,403 frontend
and 3,066 non-native functions unchanged. These are finite gates; actual B2,
held-out native timing and release installation remain pending.
