# P152-001: retain prepared nullary values through bounded expansion

Status: local mechanism demonstrated; native integration campaign in progress.
Starting source: `21657b5844c3168ad16acbe0de8096c7a3e7623ff3efbe8c710a09a97d091074`.

Hypothesis: preserving the authenticated prepared constructor and its full-width
nonowning binding removes the Unit constructor/sink regression established by
Phase151 without a benchmark-specific rewrite or broader selector admission.

The 91-line experimental implementation replaces `nbc_definition` and
`p113_value_kind`, adding ten helpers. Original source admission runs first;
bounded structural correspondence permits only ordinary nullary Ctr→NStatic
leaf differences. Constructor identity/arity, fresh image context, fallback,
ordered evaluation, freshness and final verification remain required.

## Early observations

Both complete compiler sources independently check through the pinned upstream
compiler. Six-root hosted QBE APIs acquire in16.589/16.405 guarded seconds,
using2.49/2.46GB peak RSS. This is a useful experimental workflow improvement:
it tests actual new generated native code without first rebuilding a native
compiler. It is not a speed improvement in the native compiler itself.

The unchanged Phase151 witness loses22 ctor/22 sink sites in the roles selector
and20/20 in the opcode selector. Both consuming loops also lose2/2 sites. The
compiler implementation does not recognize these names. Exact output controls
pass, including514 input pairs,28 independent table expectations and10 loop
observation pairs. The old independent reference remains unchanged.

Two observations per variant, order baseline/candidate/candidate/baseline,
20million calls, seed4294967290:

| Consumed path | Old compiler | Candidate | Candidate/old |
| --- | ---: | ---: | ---: |
| Original roles |0.6960s|0.6205s|0.892|
| Scalar roles |1.3215s|0.6065s|0.459|
| Original opcode |1.5580s|1.4605s|0.937|
| Scalar opcode |2.2155s|1.4585s|0.658|

Complete witnessed acquisition costs19.518→19.916s (dispatch),14.750→14.927s
(usage kernel),5.979→6.062s (search), each a single observation under hosted B1.
These do not establish a native compiler overhead ratio. All final products
pass independent output checks. The small usage kernel's fresh-process time
is0.06469→0.06466s: no demonstrated execution gain, despite smaller QBE.
The unrelated search output matches its34-byte independent oracle.

All66 finite compiler-data controls pass: unchanged19 selector controls plus47
new context, correspondence, constructor, fallback and ownership controls. No
malformed compiler-data fixture executes as a generated native program. This is
not a new BendTT theorem or an end-to-end correctness proof.

## Negative findings and next gate

Two initial control assertions were wrong: a builtin flag on an unrecognized
name is not an intrinsic, and compact-callee correspondence does not accept
arbitrary literal-containing caller results. Independent review caught both;
corrected controls preserve the production contract. The first control source
was checked but its assertions were not executed. A missing explicit refresh
output path caused one source-transport/API admission failure before a compiler
source was read. All artifacts remain preserved.

The broad static census finds13,438 immediate ctor→sink pairs in the retained
Phase147 compiler, not13,438 measured hot operations. All ctor/sink leaf samples
sum to6.08%, a loose direct-helper envelope, and these Unit calls do not allocate.
Do not assign them the compiler's heap reclamation cost or predict a100s build.

The next gate combines this capability with the already measured preferred
Phase150 lexer and compact Phase151 tables, then measures actual native
generations, independent ordinary correctness and generated-program regressions.
The original qualified compiler and installed selection remain available.

Evidence roots: `selfhost/build/phase152/{baseline-api01,candidate-api02,
controls-api02,controls-run01-guard,baseline-dispatch01,candidate-dispatch01,
dispatch-time01-guard..dispatch-time16-guard,baseline-usage01,candidate-usage01,
usage-time01-guard..usage-time04-guard,baseline-search01,candidate-search01}`.
Compact committed evidence and final identities will accompany the phase report.
