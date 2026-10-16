# Source04 release readiness review

The reviewed release preparation has the correct source04 identity and Phase98
baseline. It prepares a nondefault admission, staged pointer, nine public CLI
controls and a staged request capsule. It does not select the installed default.
Those prepared commands are not completed qualification or a promotion decision.
The completed source replay still authenticates all inputs and reproduces
`c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec`.

The fresh [self-C audit](../../selfhost/build/phase99/static-self-c01/report.json)
passes 21 assertions. It checks every scalar redirect's exact ANY-shared OR
ALL-root-trivial guard against the adapter's saved root words, excludes narrowed
scalar parameters, and compares the owning fallback after removing each side's
guard. Scalar adapters retain their cleanup responsibility; preexisting adapter
bodies are exact. The heap-through-root runtime section and eight ownership
helpers match. Observer coverage is 7 to 11, with four borrowed-calling wrappers;
global flags and cold macros match. Static nodes are immortal without RFC
sharing. No uniquely owned static value, dynamic hit rate, native lifetime
theorem or whole-compiler speedup is inferred.

Use the existing command artifacts without rewriting their pins:

- `selfhost/build/phase99/static-qualification-plan01/commands.json`: source04
  B1/B2, self consistency, paired measurements and ordinary semantic gates.
- `selfhost/build/phase99/static-release-backend-plan02/commands.json`: actual
  final-image borrowed/static programs, source04 laws and the backend collector.
- `selfhost/build/phase99/static-release-plan01/commands.json`: final five,
  runtime continuity, admission, staged selection, public CLI and staged assets.

The release collector's historical Phase98 schema names are intentional host
compatibility. Its source, producer, method and evidence checks still bind the
new candidate. New source04 controls and laws must be consumed; source03 evidence
cannot substitute. The full same-source self-C is under each request's
`execution/output.1.c`, as pinned by its report, rather than `program.c`.

The release preparation's `requires` fields document ordering; they are not a
scheduler. Root must execute targets serially and inspect actual results. In
particular, runtime continuity is a separate release gate and is not an argument
to admission. If any Phase93 runtime-batch C changes, the old 1.115× result stays
historical until matched runtime measurements justify a current claim.

All completed build/gate/collector inputs must remain frozen. The inherited
admission pins original-path `NATIVE_HOST.md` and `NATIVE_OBSERVERS.md`; preserve
both. Its direct input list does not pin the repository or selfhost README, or
`NATIVE_PHASE98.md`, but the old guide should remain a historical Phase98 record.
Add `docs/self_hosted/NATIVE_PHASE99.md` and update current README links only
after the actual release decision. Document exact source/profile and B1/B2
identity, measured stage-specific results, checked effect/import limits,
static/unique/shared guard distinctions and explicit unsupported cases. Retain
canonical and installed JavaScript boundaries. Update the Phase99 report,
results, ledger and steering from actual receipts before archival.

The exact profile at `static-release-plan01/profile.json` can be used explicitly
with `selfhost/tools/native/profile.py`. Its source, delta and Phase98 baseline
capsule are included through the new admission's profile assets. Do not change
`profile.py`'s historical default after replay: that would invalidate its pin.
An immutable copy at a new public profile path is optional, but would need a new
replay/admission if it is to replace the already pinned profile path.

## Default selection after all gates and benefit decision

First finish the prepared `staged-selection`, `public-cli`, `public-assets` and
`verify-public-assets` commands. The staged capsule destination is
`selfhost/tools/native/releases/phase99-static-staged01`.

The Phase98 first-install example uses exclusive creation and will refuse the
existing default. The following is a conditional replacement for root to run
only after those gates pass. It preserves the exact old pointer and refuses a
different current default. No promotion has been performed by this review.

```sh
python3 -B - <<'PY'
import hashlib, importlib.util, json, os, stat, tempfile
from pathlib import Path
root = Path.cwd().resolve()
plan = root / 'selfhost/build/phase99/static-release-plan01'
pointer = plan / 'selection.json'
target = root / 'selfhost/tools/native/selection.json'
def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
old = target.read_bytes()
assert hashlib.sha256(old).hexdigest() == '0ec0287c1c5e0b877b16a10e451bce4eb1fffa7b3795fcf634d742ea50772fdf'
new = pointer.read_bytes()
selected = json.loads(new)
assert selected['defaultStage'] == 'b2'
admission = json.loads(Path(selected['admission']['file']).read_text())
assert admission['complete'] and admission['qualified'] and admission['inputsUnchanged']
assert admission['source']['sha256'] == 'c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec'
cli = json.loads((plan / 'public-cli/report.json').read_text())
assert cli['complete'] and cli['passed'] and cli['inputsUnchanged']
assert len(cli['rows']) == 9 and all(row['passed'] for row in cli['rows'])
assert cli['admission']['selection'] == pin(pointer)
spec = importlib.util.spec_from_file_location('phase99_promote', root / 'selfhost/tools/native/launch.py')
host = importlib.util.module_from_spec(spec); spec.loader.exec_module(host)
for stage in ['b1', 'b2']:
    host.load(pointer, stage=stage)
with (plan / 'previous-selection.json').open('xb') as saved:
    saved.write(old)
with tempfile.NamedTemporaryFile(dir=target.parent, delete=False) as temp:
    temp.write(new); temp.flush()
    os.fchmod(temp.fileno(), stat.S_IMODE(target.stat().st_mode))
temporary = Path(temp.name)
try:
    assert target.read_bytes() == old and pointer.read_bytes() == new
    os.replace(temporary, target)
finally:
    temporary.unlink(missing_ok=True)
for stage in ['b1', 'b2']:
    host.load(target, stage=stage)
print('Selected exact source04 pointer; previous pointer preserved.')
PY
```

Then exercise the actual default entry, compare the complete product against
the admitted B2 cached-small control and retain its request receipt:

```sh
python3 -B selfhost/native.py selfhost/tools/performance/phase77/fixtures/small.bend -o selfhost/build/phase99/static-public-default01.c
python3 -B - <<'PY'
import hashlib, json
from pathlib import Path
p = Path('selfhost/build/phase99/static-public-default01.c')
r = json.loads(Path('selfhost/build/phase99/static-qualification-plan01/controls/report.json').read_text())
expected = next(row['output'] for row in r['rows'] if row['stage'] == 'b2' and row['name'] == 'cached-small')
assert len(p.read_bytes()) == expected['bytes']
assert hashlib.sha256(p.read_bytes()).hexdigest() == expected['sha256']
PY
python3 -B selfhost/tools/native/assets.py seal selfhost/tools/native/selection.json selfhost/tools/native/releases/phase99-static-assets01
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase99-static-assets01/receipt.json --verify-only
python3 -B selfhost/tools/native/assets.py restore selfhost/tools/native/releases/phase99-static-assets01/receipt.json
```

The final capsule must be sealed from the stable pointer; the staged capsule
alone restores only its staged selection path. Restore is missing-only and
refuses changed existing bytes/modes. After migration, the Phase98 final
capsule's old default pointer conflicts with the new pointer by design; do not
rewrite the old capsule. Historical explicit pointers remain usable. The new
source replay reads its baseline source from the old ZIP and does not need to
restore the old default pointer.

## Final archive

After finishing reports and stopping target and metadata writers, root can seal
the separate evidence capsule. The request capsules preserve launch assets;
the evidence archive preserves raw successes, failures, methods and large C.

```sh
python3 -B selfhost/tools/performance/phase99/evidence.py seal --frozen --public-assets selfhost/tools/native/releases/phase99-static-staged01/receipt.json --public-assets selfhost/tools/native/releases/phase99-static-assets01/receipt.json --out selfhost/tools/performance/phase99/artifacts/evidence01
python3 -B selfhost/tools/performance/phase99/evidence.py restore selfhost/tools/performance/phase99/artifacts/evidence01/receipt.json --verify-only
```

Preserve the earlier Phase98/toolchain archives as dependencies. Archive
completion, byte readback, actual missing-file restoration, public CLI behavior
and compiler qualification are separate claims; report only those performed.
