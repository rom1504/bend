# P97-001: do laws earn their cost during optimization?

Status: complete; candidate not promoted.
[Design](../../design/phase97/law-usefulness-experiments.md).

Test frozen Phase96 contracts against independently selected faults and valid
rewrites, relevant historical regressions, one measured projection optimization,
native lifetime controls and a small semantic-preservation proof. Keep detection,
proof, performance and production promotion separate. Record escapes and false
alarms; success is useful information rather than a preselected speed gain or law
count. No whole-compiler correctness claim or PR comment.

[Report](../../implementation/phase97/README.md) ·
[Evidence](../../selfhost/tools/laws/phase97/evidence01/summary.json).

Original suite: five independent semantic detections, one affine admission
refusal, two extraction gaps, both legitimate changes accepted. Targeted extension
keeps all226 cases and adds two frozen gap witnesses:228 JS/34 native pass; three
follow-up semantic faults reject. One independent fault also violates an unchanged
formal representation law after safe helper admission.

Four public ownership-model laws plus three support lemmas independently check;
three admitted bad protocols fail the frozen law. An isolated missing-child-retain
C mutation compiles but fails at runtime, exposing the absent concrete-ownership
bridge. The model is not a runtime correctness proof.

Actual f_find candidate passes24 full-value JS/native controls and five caller
mutants; six extracted native workloads take0.318–0.345× baseline time. The real
six-source nativeB1 screen is only0.990332× request/0.991748× process, with all48
C/diagnostic comparisons exact. Do not promote the +17line rewrite or infer
generated-program speed, full-self, B2 or broad conformance. No production change.
