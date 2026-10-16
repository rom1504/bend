# Native release path after qualification

This is a read-only execution plan, not a release receipt. The final source may
change while bounded inlining is evaluated. Every command below must bind the
same eventual source and actual B1/B2 images; no result from the earlier source
can substitute merely because the change appears small.

The shortest safe path uses the existing source-parameterized Phase99 release
tools. Their historical names do not select the old Phase92 baseline: the reuse
wrapper injects the installed Phase98 binding. The `plan` mode assumes a single
qualification directory layout that the present distributed Phase102 outputs
do not have. Use the individual collector and selection commands instead of
copying or rewriting completed build receipts to satisfy that layout.

Required before selection:

- Actual B1 and B2 bindings, complete native B1/B2 self requests and exact fixed
  point, all for the final source and unchanged checked runtime inputs.
- Ordinary native controls, native 69-case conformance, broad 45-program
  compilation, backend-specific authority/ownership controls, and final five
  controls, accepted by the existing candidate admission collector.
- Native inheritance of the final API control outputs, or freshly executed
  complete runtime obligations wherever emitted C differs. Exact C continuity
  permits behavior inheritance; it does not create new native timing samples.
- The separate 45-program runtime-continuity emission and matched measurements
  for changed C. This gate is not an argument to `admit`; root must enforce the
  performance decision separately.
- A reversible **Phase98-to-final-source** recipe or a replay receipt for a
  profile based on that source. The compact public D04-to-final-source profile
  is useful source transport but cannot replace this admission input: the
  collector checks its baseline against the installed Phase98 source.

After those results pass, run `phase99/release/reuse.py admit` with the exact
paths described in [the qualification plan](native-qualification-plan.md).
Use a fresh admission output. The existing source-only compact profile can be
published separately and linked by the final source hash; do not change its
experimental/qualification claims after it has been pinned. Alternatively,
create a Phase98-based public profile and replay it before collecting admission.

For the following commands, `ADMISSION` and `NATIVE_CONTROLS` denote the completed
final-source receipts. `STAGED` and `CLI_OUT` must be fresh paths under
`selfhost/build/phase99` because the reused methods deliberately restrict output
locations. For example, use a `phase102-release01` directory there. These shell
variables must be assigned by root to the actual completed receipts.

```sh
python3 -B selfhost/tools/performance/phase99/release/prepare.py selection --admission "$ADMISSION" --out "$STAGED"
python3 -B selfhost/tools/performance/phase99/release/cli-controls.py "$STAGED" "$NATIVE_CONTROLS" "$CLI_OUT"
python3 -B selfhost/tools/native/assets.py seal "$STAGED" selfhost/tools/native/releases/phase102-staged01
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-staged01/receipt.json --verify-only
```

The nine CLI controls include both stages' cached-small, live-file and repeated
map5 requests, plus existing-output, changed-manifest and invalid-source
refusals. The source-generic launcher already accepts a properly qualified new
admission; no launcher or historical default-profile modification is needed.

Only after the benefit decision, nine controls and capsule verification, replace
the default selection conditionally. Reuse the atomic replacement procedure in
[Phase99's release review](../phase99/static-release-readiness.md): verify the
current pointer hash, preserve its exact bytes in an exclusively created file,
validate both stages of the new pointer, recheck both pointer inputs, then use
`os.replace` with preserved permissions. Substitute the actual final source and
receipt paths; the old Phase99 example's source hash is not applicable.

Then run the actual default small compile, compare its complete C bytes with
the admitted B2 cached-small control, and seal a **new stable-default capsule**:

```sh
python3 -B selfhost/tools/native/assets.py seal selfhost/tools/native/selection.json selfhost/tools/native/releases/phase102-assets01
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase102-assets01/receipt.json --verify-only
```

A staged capsule preserves its staged selection path, not the stable default.
Old capsules remain immutable; restoring an old default over the new selection
correctly refuses. Capsule sealing/verification runs no compiler targets and
preserves the minimal request assets, not large qualification C and history.
Archive raw experiment evidence separately after all writers stop.

If final compiler construction, fixed point, semantic gates or runtime checks
do not finish within the phase budget, retain the installed Phase98 selection.
Publish the exact reversible source and explicit completed native candidate
bindings with their actual gate status. A usable private B1 or B2 candidate is
valuable, but is not a selected, qualified self-hosting release.
