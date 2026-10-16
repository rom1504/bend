# Phase99 native qualification preparation

This preparation runs no compiler, API check, build or program. The root owns
the serial execution queue. The scalar-only micro was neutral (about 1.027 times
baseline); preparing these commands is not a reason to build a full image.
Continue only when a retained mechanism and benefit gate justify that cost.

## Frozen comparison baseline

[baseline.json](../../selfhost/tools/performance/phase99/qualification/baseline.json)
pins the completed, currently selected Phase98 admission and its two builds:

| Item | Identity |
| --- | --- |
| Compiler source | `2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051` |
| Native B1 | `origin-checked01/compiler`, `099df960c418c9caef6977f011074fcc2aa43e2fbbd3daee32fe80824b54e1e9` |
| Native B2 | `origin-b2/compiler`, `c481bd2c1b057dee537442765aca1b36786437fe37b3543dc405677329f18554` |

The baseline remains explicit if the installed selection later changes.
Historical Phase92 authentication supplies the unchanged toolchain and request
assets; it does not select the measured producer. The wrapper verifies the
current admission, selected source/build/C/ELF identities, matching assets and
unchanged `p86_*` request definitions. Full prior qualification is represented by
its pinned completed receipt, rather than rehashing every historical test on
each new request.

## Minimal reuse and commands

[reuse.py](../../selfhost/tools/performance/phase99/qualification/reuse.py) adapts
the baseline then calls **unchanged snapshot17** build, bind, request, backend
policy, broad controls and conformance preparation methods. Inherited Phase98
schema names remain for compatibility; wrapper inputs are pinned and copied
alongside the original methods. Existing frozen files stay unchanged.

[compare.py](../../selfhost/tools/performance/phase99/qualification/compare.py)
is the small stage-selectable successor of the Phase98 B2 comparison. Always
invoke it through `reuse.py compare`. The old B2 comparator directly selects
native07 and must not be used as the Phase99 performance comparator.

- Six original source fixtures, four alternating rounds per stage: 24 pairs.
  Twelve separate oracle emissions precede timing: the current baseline at the
  selected stage and the candidate B1 each compile all six fixtures.
- Full-self mode uses two alternating pairs per stage, with both compilers
  compiling the **same candidate source**. Current Phase98 B1 and B2 references
  are separate. Candidate B1 self-emission must agree with the current B2's
  complete diagnostic; candidate B2 must reproduce its B1's entire self C.
- Every timed request checks full C against its own producer's oracle and the
  complete diagnostic. Different baseline/candidate C is recorded under an
  explicit source-bound backend policy, not counted as semantic equivalence.
- Request time excludes prepared Base/runtime work. Process wall includes
  startup, preparation, output and teardown. The existing CPU3, 2 GiB RSS,
  4 GiB available floor and 60-second screen/300-second self bounds remain.
  Image builds retain matched O2 flags, CPU2,3, 6 GiB RSS, 16 GiB available floor
  and a 420-second deadline. No timing forecast is implied.

[prepare.py](../../selfhost/tools/performance/phase99/qualification/prepare.py)
accepts explicit source, recipe, prospective acquisition and fresh output paths.
It independently replays the forward and inverse source edits, emits a compatible
changed-backend policy, and writes staged commands with decision points. Example:

```sh
python3 -B selfhost/tools/performance/phase99/qualification/prepare.py \
  --source selfhost/build/phase99/scalars-source02/compiler.bend \
  --recipe selfhost/build/phase99/scalars-source02/changes.json \
  --acquisition selfhost/build/phase99/scalars-checked02/report.json \
  --reason 'Scoped typed scalars preserve packed field and array permissions; changed C requires original semantic gates.' \
  --out selfhost/build/phase99/qualification-plan01
```

That source is currently `7520f6ef07ed3b955bc2d6dea1d6fde5b3fa45fdb18f950b124fd5cb8aac1492`.
The methods impose no candidate hash: a revised variant needs its own exact
recipe and fresh plan/output paths. `--acquisition` is a prospective prerequisite;
preparation neither creates nor claims a checked image. The generated
[commands](../../selfhost/build/phase99/qualification-plan01/commands.json) are
not a run-all instruction. Review the small benefit gate before B1 construction,
the B1 screen before full self, and the B1 result before B2 construction.

If integration is justified, the prepared sequence also runs original live/cache
controls and exact rejections, all 45 original programs through both candidate
stages with actual common-C execution, and native69 plus three rejections per
stage. Snapshot17's full-provenance-before/after-suite checks and per-case actual
execution-input checks remain intact; 31 fixtures per stage remain excluded.
Changed program C requires matched runtime measurement before a speed claim.
No new admission, archive or installed-selection mechanism is prepared here.
Final promotion still needs source-specific scalar controls, retained observer
contracts/controls and appropriate public-host evidence; a self fixed point alone
does not establish those properties.

## Runtime dispatch finding

The scalar micro's audited runtime already names
`selfhost/build/phase90/runtime-accessor-transport02/runtime.c`. It and
`selfhost/src/runtime/native/runtime.c` are byte-identical: 83,683 bytes, SHA256
`9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9`.
This is also the runtime bound by the current native admission.

The active dispatch differs because that exact runtime defines `wl_target` and
redirects `WL_DYN` through it only under `#if FID_ENTER >= 4096`. Both append micro
products define `FID_ENTER 117`; the current complete compiler C defines
`FID_ENTER 39147`. Changing only the runtime path cannot reproduce the full
compiler dispatch mechanism in the micro. A bounded explicit dispatch experiment
or actual native-stage evidence is needed; this observation alone predicts no
benefit. The micro's typed-scalar switch is 0 to 1, while current full self C has
typed scalars disabled. These are distinct representation and size conditions.
