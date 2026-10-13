#!/usr/bin/env python3
"""Reconcile the completed release evidence into repository documentation."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];D=ROOT/'implementation/phase76'
q=json.loads((D/'qualification.json').read_text());assert q['release']['complete'] and q['release']['pass']
b1=q['promotion']['images']['b1']['sha256'];b2=q['promotion']['images']['b2']['sha256']
p=D/'README.md';s=p.read_text();s=s.replace('Release qualification is in progress. The selected exact-output candidate is\ncompiler12. Phase75 stays installed until all release gates finish. This phase\nhas **not reached compilation parity**. The much faster scalar-pattern prototype\nis preserved separately because it regresses two generated programs.', 'Installed compiler12 reduces measured C-request time by **6.28% for B1** and\n**1.84% for B2**, with exact previous generated programs. This phase has **not\nreached compilation parity**. The much faster scalar-pattern prototype is\npreserved separately because it regresses two generated programs.')
s=s.replace('The current selected candidate passes frontend36, genuine B2 formation and its\neight driver comparisons. All twelve native acquisitions execute correctly and\nproduce **exactly the same C files and executable bytes** as Phase75/73. Final\nnative/raw, self-hosting and installed CLI gates are pending at this checkpoint.',f'''The [completed qualification](qualification.json) verifies:

- Frontend36; native100 (candidate100, reference93 with the same seven failures);
  additional native14; raw31; 28 executions at one/four threads.
- Twelve independently executed acquisitions with **exact previous C and executable
  bytes**, and twelve genuine B2 requests reproducing that same C.
- Genuine B2/driver8, fresh B2 own-source type acceptance with expected unsafe
  proof-trust refusal, and exact B2/B3 byte equality. This is not a mathematical
  correctness proof.
- Unchanged non-native generated dependency closure (2,992 functions), 166 report
  controls, 1,066 constructor comparisons and 199,400 occurrence-set controls.
- Installed release verification before/after, legacy42, default24 and helper5.
  All seven previous release files are preserved byte-for-byte.

Installed checked B1: `{b1}`. Genuine B2/B3: `{b2}`.
The default remains the checked B1 image; B2 results are separately qualified.
No release change silently substitutes stages in the performance metric.''')
p.write_text(s)
front=f'''# Active frontier: Phase76 exact-output native checks

Installed compiler12: checked B1`{b1[:8]}…`, genuine B2/B3`{b2[:8]}…`.
[Report](../implementation/phase76/README.md) and [qualification](../implementation/phase76/qualification.json).
The interleaved45 comparison gives B1 **2.93623x→2.75191x** upstream and B2
**1.94374x→1.90803x**:6.28%/1.84% less request time. The B2 difference is small
at this sampling precision. Fresh JS-hosted Bend-to-C requests exclude imports,
explicit Bend Base, Clang and execution; TS checks Base in its request.

Retain lazy native-definition/call admission and representation certificates.
The four-module change adds34 physical/22 code lines;131 modules now contain
32,018 physical/26,162 code lines. All twelve C files and binaries remain exact
Phase75/73, preserving the prior runtime artifact set (historical1.05060x aggregate).
All selected native/raw/selfhosting/installed gates pass. Seven reference failures
and thirteen broader API gaps remain. Source algorithms stay in Bend.

Reject the scalar-pattern prototype for default promotion despite a substantial
compilation gain: candidate08 reaches1.99078x B1/1.51774x B2 (32.25%/22.20% less
time) but Tree/Array.map executables regress3.66%/4.93%. Candidate10 reconstruction
elimination and alignment/placement variants fail to recover both. Complete
prototype source, controls and failures remain in experiments/phase76/prototypes
and the evidence capsule. Changed addresses/layout are plausible, not proven
hardware causes. Do not keep guessing alignment without hardware counters.

Next large discriminator: retain per-node lowering facts/relocatable products
while requiring exact existing C before committing to a bigger native IR. A
root-only memo remains weak (97% distinct roots). Reusable Base products need
explicit dependency/static-image/ID relocation and separate cold/warm metrics.
Shared benchmark argument-reading code limits extrapolation of pattern savings.
Parity remains unachieved. Do not present rejected prototype speed as the release.

Use fresh phase/output paths after sealing. One guarded CPU3 target tree,2GiB
RSS/4GiB available floor,Node1GiB heap/4MiB stack. No agents were used; no PR
comments without explicit request. Preserve inherited work and sealed history.

## Historical Phase75 frontier

'''
p=ROOT/'experiments/STEERING.md';s=p.read_text();p.write_text(front+s.removeprefix('# Active frontier: Phase75 faster native compilation, exact programs\n\n'))
p=ROOT/'experiments/README.md';s=p.read_text();at=s.index('## Completed implementation: Phase75');new='''## Completed implementation: Phase76 exact-output native checks

[Design](../design/phase76/native-work-reuse.md) ·
[Report](../implementation/phase76/README.md). Installed compiler12 improves the
paired three-source loop to2.75191x B1/1.90803x B2 upstream,6.28%/1.84% less time.
All twelve C files/binaries are exact previous artifacts; all selected release
gates pass. Reject the scalar-pattern prototype (1.99078x/1.51774x) because two
programs regress3–5%; preserve its complete source, controls and measurements.
+34 physical/+22 code lines, no module added. Known gaps remain; no parity claim.

''';p.write_text(s[:at]+new+s[at:])
p=ROOT/'experiments/ledger.md';p.write_text(p.read_text()+'''

## Phase76 native work amplification and safe admission — 2026-10-13

[Design](../design/phase76/native-work-reuse.md) · [Report](../implementation/phase76/README.md).
Install compiler12, B1`98134f59…`, genuine B2/B3`29da003b…`. Paired45:
B1 2.93623x→2.75191x, B2 1.94374x→1.90803x TS;6.28%/1.84% less time.
Select lazy intrinsic/call admission and representation certificates. Twelve
C files/binaries exactPhase75/73. All selected native/raw/selfhosting/installed
gates pass; known seven reference failures/thirteen broader API gaps remain.
Reject general scalar-pattern compaction despite32.25%/22.20% request savings:
Tree/Array.map regress3.66%/4.93%. Reconstruction elimination and saved-C layout
variants fail to repair both. Full prototype/independent controls retained.
+34physical/+22code lines, unchanged131modules. No agents or PR comments.
Parity not achieved; no default runtime regression on the twelve artifact set.
''')
print('Reconciled completed release documentation.')
