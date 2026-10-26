"""Freeze optional skip policy on final03 and prepare source/control gates only."""
import importlib.util
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('C', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
out = ROOT/'selfhost/build/phase144/range-skip-final03-source01'
assert not out.exists()
parent = ROOT/'selfhost/build/phase144/predicate-canonical-source01/manifest.json'
pm = json.loads(parent.read_text())
assert pm['complete'] and C.pin(pm['source']['file']) == pm['source']
assert pm['source']['sha256'] == '31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2'
module = HERE/'range-skip-v01.bend'
before = Path(pm['source']['file']).read_text()
text, added, protected = C.compose(before, [module.read_text()], {'p114s_ranges'}, set())
assert not added
old, new = C.blocks(before, combine=True), C.blocks(text, combine=True)
unchanged = [name for name in old if C.norm(old[name]) == C.norm(new[name])]
assert set(old)-set(unchanged) == {'p114s_ranges'}
out.mkdir()
source = out/'compiler.bend'
source.write_text(text)
(out/'module.bend').write_bytes(module.read_bytes())
(out/'method.py').write_bytes(Path(__file__).read_bytes())
manifest = dict(kind='phase144-optional-fast-policy-final03-composition', complete=True,
    checked=False, nativeQualified=False, selected=False, targetsRun=False, source=C.pin(source),
    parent=pm['source'], inputs=[C.pin(__file__), C.pin(C.__file__), C.pin(parent), pm['source'], C.pin(module)],
    overrides=['p114s_ranges'], added=[], oldPhysicalLines=len(before.splitlines()),
    physicalLines=len(text.splitlines()), sourceBytesDelta=len(text.encode())-len(before.encode()),
    unchangedDeclarationCount=len(unchanged), protectedDeclarationsUnchanged=protected,
    allOtherDeclarationsIncludingProofsAndFinalVerifiersNormalizedExact=True,
    scope='Optional development pass policy. Final03 source differs only by outer range identity. Keep production selection and full optimization default unchanged pending independently qualified cost/quality evidence.')
(out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
previous = ROOT/'selfhost/build/phase111/p144-integrated-api03/report.json'
ar = json.loads(previous.read_text())
assert ar['complete'] and ar['checked'] and pm['source'] in ar['inputs']
exports = list(ar['exports']) + ['p114s_ranges', 'p134v_controls', 'p114s_control_report']
assert len(exports) == len(set(exports))
api = ROOT/'selfhost/build/phase111/p144-range-skip-final03-api01'
controls = ROOT/'selfhost/build/phase144/range-skip-final03-controls01'
assert not api.exists() and not controls.exists()
guard = ROOT/'selfhost/tools/performance/phase111/guard.py'
checker = ROOT/'selfhost/tools/performance/phase111/check-api.py'
runner = ROOT/'selfhost/tools/performance/phase143/controls-v01.mjs'
bun = ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
specs = ['p144o_controls:35:prefix', 'p144e_controls:10:prefix', 'p144pc_controls:27:suffix',
         'p144ap_controls:23:prefix', 'p125pc_controls:12:prefix', 'p127lb_controls:20:suffix',
         'p134v_controls:26:prefix', 'p114s_control_report:18:prefix']
jobs = []


def job(name, command, seconds):
    jobs.append(dict(name=name, seconds=seconds+20, command=[sys.executable, '-B', str(guard),
        '--out', str(out/(name+'-guard')), '--seconds', str(seconds), '--cpu', '3',
        '--rss-mib', '3072', '--available-mib', '16384', '--file-mib', '100', '--', *map(str, command)]))


job('checked-api', [sys.executable, '-B', checker, '--source', source, '--out', api, *exports], 120)
job('171-finite-controls', [bun, runner, api/'report.json', controls, *specs], 100)
(out/'jobs.json').write_text(json.dumps(dict(kind='phase144-final03-fast-policy-root-gates', complete=True,
    targetsRun=False, optional=True, selected=False, inputs=[C.pin(out/'manifest.json'), C.pin(previous),
    C.pin(guard), C.pin(checker), C.pin(runner), C.pin(bun)], jobs=jobs,
    controls=dict(existingIntegrated=127, independentCommitAndOptimizerFixtures=44, total=171),
    gate='Root source check followed by existing127 controls plus26 verification-reuse and18 small optimizer equivalence controls. Finite controls do not prove arbitrary-pass idempotence or whole-compiler correctness.'), indent=2)+'\n')
print(json.dumps(dict(source=C.pin(source), plan=C.pin(out/'jobs.json'), sourceBytesDelta=manifest['sourceBytesDelta'])))
