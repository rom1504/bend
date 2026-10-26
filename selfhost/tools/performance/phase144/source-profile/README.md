# Native source composition experiment

`prepare-v01.py` constructs a **new, unchecked** source profile from the exact
qualified Phase143 source. It preserves `main` and therefore all existing native
CLI branches, every protected verifier/API root in the parent manifest, the 11
proof-connected declarations, and the lexical dependency closure of those roots.
Selecting a name retains **all** its law/type/definition declarations in original
order and with their original attached annotations. No function is rewritten.

```sh
python3 selfhost/tools/performance/phase144/source-profile/prepare-v01.py \
  --out selfhost/build/phase144/native-profile-source01
```

`--all-laws` additionally roots every existing law and its definition/dependencies.
Use a fresh output directory for that alternative. It gives a conservative
proof-surface variant without changing the full-source/API/test composition.

The manifest, ordered retained/excluded declaration lists and source hashes are
review artifacts, not admission certificates. Source checking comes first. The
root agent owns subsequent API/output gates, native builds, ordinary qualification
and separate session/batch checks. No target executes from the preparer.

Compare compiler behavior on the **same frozen user inputs**, including refusal
cases. Reduced compiler source changes self-compilation input and possibly its
generated layout/IDs: any self-build reduction is source-composition/workflow gain,
not a same-source compiler algorithm speedup. Preserve the full original source
for all JS/C/library exports and test controls. This is not permission to delete
those backends or tests, and it does not prove correctness of lexical dead-code
elimination in general.

The method reuses Phase141's read-only declaration census, independently masks
literals before checking declaration matches, verifies whole-source byte
reconstruction, checks every source annotation is attached, and never uses the
last-definition-wins `C.blocks` dictionary as an emitter. Binder collisions may
retain extra names. Implicit elaboration, reflection/foreign contracts and
unpublished API clients remain independent review obligations.

## Integrated-candidate profile

`prepare-v02.py` accepts an explicit manifest plus independent expected manifest
and source hashes. It recomputes the closure from that source, requires the exact
qualified Phase143 protected/proof root sets, and compares every associated
law/definition/type block against that authority modulo blank/comment-only lines.
It does not import the old source profile or reuse its retained-name set.

The integrated candidate was prepared without running any compiler target:

```sh
python3 selfhost/tools/performance/phase144/source-profile/prepare-v02.py \
  --parent-manifest selfhost/build/phase144/integrated-source01/manifest.json \
  --manifest-sha256 089cf673a59b1526292b8870bf179c80bd487e5099606ee53b354e79ac7e2762 \
  --source-sha256 992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b \
  --out selfhost/build/phase144/native-profile-source02
```

The output SHA is
`24fcb6f429140ddca54e7be23319114d6a148403e8d36195a061719af8d44a4c`,
with 38,436 physical / 28,126 code lines and 1,650,827 bytes. All 4,916 retained
declaration blocks, including 553 laws, remain in original order. The full
integrated API source and original Phase143 profile01 are unchanged. This profile
is unchecked/unqualified until the coordinator's separate gates succeed.

## Root-owned checks and native acquisition

The exact profile API has now passed independent source checking:
`selfhost/build/phase111/p144-native-profile-api01/report.json`. Its five ordinary
cursor exports come from source SHA `24fcb6f4…`; this is source admission, not
native qualification or proof of the packaging transformation.

`plan-v01.py` prepares, but does not execute,
`selfhost/build/phase144/native-profile-plan01/`:

1. `hosted-jobs.json`: Lexer, closures and Map outputs compared byte-for-byte with
   the existing independent frozen QBE references. All three must pass first.
2. `acquire-jobs.json`: existing integrated N1
   `phase134/p144-integrated-n1-01/program` compiles profile02 through the unchanged
   QBE/assembler/linker path and original `phase128/runtime-borrow01/runtime.o`.
   Output is `phase134/p144-native-profile-n1-01/program`; QBE is retained for a
   potential later reproduction gate. This first acquisition has no prior oracle
   for the newly composed compiler input.
3. `native-smoke-jobs.json`: the same three independent ordinary requests, followed
   by a two-revision `phase140-session` and four-revision `phase140-batch`
   seed/edit/revert/edit-again. Their actual Lexer sources, owner/hint, outputs and
   expected QBE are the previously successful Phase141 smoke inputs; no expected
   result is newly invented. Existing transport validators authenticate both full
   and reused pieces.

Each command already contains the existing CPU3 resource guard (3GiB RSS,
16GiB available floor) and a finite process deadline. Run them serially in the
coordinator's lane. The plans never launch themselves. This is a focused smoke
screen, not full language or incremental qualification. `main`, ordinary args,
session and batch entry definitions are retained unchanged; the packaging graph
retains dependencies of every CLI branch.

## Interpreting self-build time

The current **266.8624038s** result is the full integrated N1 compiling the
**unchanged Phase142 source** `phase142/indexed-source02/compiler.bend`, with exact
115,909,112-byte QBE (`phase130/p144-integrated-fixed-cold01/report.json`). It is
not the time to compile either integrated-source01 or profile02.

Profile02 has 55.29% of integrated-source01's bytes and 59.98% of its code lines.
Those reductions primarily remove parse/check/book work; reachable backend and
output work remains. A simple model is `new self-build = old self-build - f*F`,
where `F` is the measured frontend cost on the comparable source and `f` is the
fraction actually eliminated. Applying roughly40% to the historical117s
diagnostic frontend suggests46.8s as an illustration, not a forecast for the new
compiler. The current integrated frontend has not received that stage measurement,
and checking costs are not proportional to source lines. No40% whole-speed claim
is justified.

Keep three measurements distinct:

- The packaged image compiling the same frozen Phase142 source/oracle is a
  same-input comparison against266.862s; it tests whether generated compiler speed
  changed through image layout or specialization.
- Full compiler versus packaged compiler self-builds use different source inputs
  while retaining the same native CLI features. Any reduction is a source
  composition/workflow gain and must be labelled accordingly.
- Acquisition uses an overlapping compiler→QBE pipe. Its `wallSeconds` and
  `emitAndQbeSeconds` include machine work and cannot be compared directly with
  the standalone request's `nativeSeconds`.

No hosted/native gate, acquisition, self-build measurement or compiler selection
ran from this preparation task. The full source/API composition remains intact.


## 2026-10-26 consolidation update

The preparation-only status above describes the authoring task. Root subsequently
ran the source check, all three hosted product gates, native acquisition
(approximately268s guarded wall), three ordinary native requests and the two-/
four-revision session/batch smokes successfully. Their receipts remain under
`selfhost/build/phase144/native-profile-*`, `phase134/p144-native-profile-n1-01`
and `phase140/p144-native-profile-{session,batch}01`. Full source-profile native
qualification and a controlled same-input execution comparison remain absent.

The statement that the integrated frontend has not been stage-profiled is now
superseded by `research/phase144/integrated-profile-v2.json`: source01 measures
94.833 diagnostic frontend seconds on unchanged full Phase142 input. This is
not a profile02 self-build timing; neither source-byte proportions nor unequal
producer acquisition times establish its causal workflow gain.
