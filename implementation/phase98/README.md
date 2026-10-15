# Phase98: useful laws and native compiler optimization

Work in progress; this checkpoint does not select a new public compiler.
Design: [three-hour campaign](../../design/phase98/laws-and-native-optimization.md).

The first material result is a safe Bend string-equality wrapper that keeps
whole inputs alive across the unchanged recursive comparison. Upstream's
borrowing analysis then emits reads instead of per-cell ownership operations.
The simplest version adds3 lines and takes **0.85619×** D04 compilation-request
time across six fixed sources, four alternating rounds, with48 complete C and
diagnostic matches. Process time is0.91709×. These are native B1 compiler timings,
not generated-program execution or a measured native B2 improvement.

| Candidate | Request ratio to D04 | Added lines | Decision at checkpoint |
| --- | ---: | ---: | --- |
| Cache two caller tag observations | 1.00749× | 2 | Neutral; decline. |
| Preserve roots in a three-word observation | 0.85866× | 10 | Mechanism works; superseded by simpler form. |
| Preserve roots through a finishing function | 0.85619× | 3 | Proceed to broader/stage qualification. |
| Fuse term-tag comparison with retained roots | 0.81383× | 23 | Material B1 result; stage qualification pending. |
| Extract dispatch across19 functions | 0.98766× | 525 | No material gain; decline. |

The selected fused-tag helper also passes96 complete-value native controls and
six independently checked laws (four inherited, two new). Its process ratio is
0.87818×. The larger dispatch experiment preserves48 full products but does not
justify its code cost. Two held scalar-field projections have passed10 complete
native controls and two universal laws; they have no compiler timing result yet.

The accepted equality proofs use exact frozen helper bodies and an independent
structural reference. Native controls cover all1,444 ordered pairs of38 strings,
shared and copied inputs, Unicode and subsequent input observations. A separate
arbitrary-term tag-fusion law and four dispatch-selector laws also pass independent
BendTT checking, but semantic equivalence alone does not establish speed: the
first fused-tag C still consumes the whole term.

Independent challenge tests distinguish actual finite semantic failures from
proof maintenance. Three incorrect equality/observation helpers are admitted as
safe code and rejected by unchanged laws. A correct full-width character
comparison change passes finite tests but needs a two-line support-proof repair;
the repaired five-law closure passes the independent kernel. One incorrect
internal retained-root product escapes the Boolean-result finite corpus but
violates the full-value law. That is an internal contract failure, not evidence
that its final Bool result is wrong.

The remaining stage issue is concrete: the self-hosted backend couples observer
permission to a whole-program scalar-array certificate. The compiler's audited
file-IO entry does not satisfy that certificate. A real IO control keeps observers
disabled and emits the consuming equality walker, so the source wrapper alone
cannot be assumed to improve B2. Work is investigating a distinct checked
observer permission while preserving existing array and constructor-sharing
restrictions, followed by actual native-chain qualification.

Detailed work tracks: [comparison](comparison.md), [dispatch](dispatch.md),
[proofs](proofs.md), [independent review](review.md). The final report will bind
all results, retained failures, execution cost, production changes and limits.
