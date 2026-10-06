#!/usr/bin/env python3
"""Data-only four-point choice01/shared01 bundle; never compile or execute targets."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PROGRAMS = HERE.parents[1] / 'programs'
sys.path.insert(0, str(PROGRAMS))
from run import load_bundle, PRESETS

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(ROOT / 'selfhost/build/phase58') and not out.exists()
raw = ROOT / 'selfhost/build/phase58'
catalog_file = HERE.parents[1] / 'phase37/catalog.json'
ids = ['test-morning-program', 'test-evening-program', 'test-map-set-ops', 'editdist']
paths = {'choice': raw/'final-choice02/checked/program45/manifest.json',
         'shared': raw/'final-shared01/checked/program45/manifest.json',
         'reference': raw/'program-performance-shared01/baseline/manifest.json'}
inputs = {}
def pin(file, expected=None):
    file = Path(file).resolve(strict=True)
    if str(file) not in inputs:
        data = file.read_bytes()
        inputs[str(file)] = dict(path=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    actual = inputs[str(file)]
    if expected:
        assert actual['sha256'] == expected['sha256'], str(file)
        if 'bytes' in expected: assert actual['bytes'] == expected['bytes'], str(file)
    return actual
def read(file, expected=None):
    pin(file, expected)
    return json.loads(Path(file).read_text())
def reported(row):
    return pin(row.get('file', row.get('path', row.get('canonicalPath'))), row)
def save(file, value):
    file.parent.mkdir(parents=True, exist_ok=True)
    with file.open('x') as stream: json.dump(value, stream, indent=2); stream.write('\n')

for file in [__file__, PROGRAMS/'run.py', PROGRAMS/'support.py', PROGRAMS/'execute.mjs']:
    pin(file)
catalog = read(catalog_file)
assert pin(catalog_file)['sha256'] == '33e353f51d1c90d27ff05dd2051dfccbefb23e29cfd73d7839b4cb1d42690b1c'
selected = [next(c for c in catalog['cases'] if c['id'] == name) for name in ids]
for c in selected: pin(catalog_file.parent/c['source']['path'], c['source'])
bundles = {}
for name, path in paths.items():
    checks = []
    bundles[name] = load_bundle(path, catalog, pin(catalog_file)['sha256'], selected,
                                ['baseline', 'typescript'] if name == 'reference' else ['candidate'], checks)
    for row in checks: reported(row)

comparison = read(raw/'program-performance-shared01/report.json')
assert comparison['complete'] and comparison['inputsUnchanged'] and comparison['timingScope'] == 'full'
assert reported(comparison['timingBaseline']) == pin(paths['reference'])
assert reported(comparison['candidate']) == pin(paths['shared'])
lineage = {}
for name, attempt_name in [('choice','checked-choice01'),('shared','checked-shared01')]:
    manifest = read(paths[name]); prep = read(paths[name].parent/manifest['preparation']['path'], manifest['preparation'])
    assert prep['complete'] and prep['backend'] == 'direct'
    attempt_file = raw/attempt_name/'attempt.json'; attempt = read(attempt_file)
    v = read(raw/attempt_name/'validation-001/report.json')
    assert attempt['checked'] and v['complete'] and v['pass'] and v['strictExact'] and v['selected']['exactDifferences'] == 0
    compiler = bundles[name]['roles']['candidate']['compiler']
    assert compiler['kind'] == 'checked-development-attempt' and compiler['backend'] == 'direct'
    assert compiler['callingContract'] == 'upstream-compatible-direct-v1'
    assert compiler['upstreamCommit'] == catalog['upstreamCommit']
    assert compiler['api']['sha256'] == attempt['api']['sha256'] == v['api']['sha256']
    for key in ['api','runtime','base','driver','directRuntime']: reported(compiler[key])
    reported(attempt['bootstrapReport']); reported(attempt['derivationReport'])
    receipts = []
    for case in selected:
        entry = bundles[name]['points'][case['id']]['candidate']
        module = paths[name].parent/entry['path']; receipt = read(Path(str(module)+'.json'))
        assert receipt['kind'] == 'bend-program-checked-emission' and receipt['complete']
        assert receipt['compiler'] == compiler and receipt['backend'] == 'direct'
        assert reported(receipt['attempt']) == pin(attempt_file)
        assert receipt['input']['sha256'] == case['source']['sha256']
        assert receipt['catalog']['sha256'] == pin(catalog_file)['sha256']
        assert receipt['observation']['checked'] and receipt['observation']['typeAccepted']
        assert receipt['observation']['status'] == 'ok' and receipt['observation']['backend'] == 'direct'
        assert reported(receipt['output']) == pin(module, entry)
        for row in receipt['emissionInputs']: reported(row)
        receipts.append(pin(Path(str(module)+'.json')))
    lineage[name] = dict(attempt=pin(attempt_file), validation=pin(raw/attempt_name/'validation-001/report.json'),
                         preparation=pin(paths[name].parent/manifest['preparation']['path']), emissions=receipts)

out.mkdir()
copies = []
def bundle(destination, role_sources, labels):
    rows = []
    for case in selected:
        modules = {}
        for role, (source_name, source_role) in role_sources.items():
            entry = bundles[source_name]['points'][case['id']][source_role]
            src = paths[source_name].parent/entry['path']
            dst = destination/'modules'/(role+'-'+entry['sha256']+'.mjs')
            dst.parent.mkdir(parents=True, exist_ok=True)
            if not dst.exists(): shutil.copyfile(src, dst)
            actual = pin(dst, entry); copies.append(dict(source=pin(src), copy=actual))
            modules[role] = dict(path=str(dst.relative_to(destination)), sha256=actual['sha256'], bytes=actual['bytes'])
        rows.append(dict(id=case['id'], sourceSha256=case['source']['sha256'], point=case['point'], modules=modules))
    roles = {}
    for role,(source_name,source_role) in role_sources.items():
        roles[role] = copy.deepcopy(bundles[source_name]['roles'][source_role]); roles[role]['label'] = labels[role]
    save(destination/'manifest.json',dict(kind='bend-program-bundle', schemaVersion=1, complete=True,
        upstreamCommit=catalog['upstreamCommit'], catalogSha256=pin(catalog_file)['sha256'],
        comparisonContract='upstream-compatible-direct-v1', roles=roles, cases=rows))
    checks=[];load_bundle(destination/'manifest.json',catalog,pin(catalog_file)['sha256'],selected,list(role_sources),checks)
    for row in checks:reported(row)
bundle(out/'baseline',{'baseline':('choice','candidate'),'typescript':('reference','typescript')},
       {'baseline':'Phase58 checked choice01 predecessor; exact saved direct modules', 'typescript':'Same pinned TypeScript modules as full shared01 campaign'})
bundle(out/'candidate',{'candidate':('shared','candidate')},{'candidate':'Phase58 checked shared01; exact saved direct modules'})
equality=[]
for name in ids:
    left=bundles['choice']['points'][name]['candidate'];right=bundles['shared']['points'][name]['candidate']
    equal=left['sha256']==right['sha256'];assert equal == (name in ['test-map-set-ops','editdist'])
    equality.append(dict(id=name,byteEqual=equal,choice=left,shared=right))
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node');pin(node)
commands=[]
for name,names,base,scope in [('choice-shared-0',ids,out/'baseline/manifest.json','choice01 versus shared01'),
        ('choice-shared-1',list(reversed(ids)),out/'baseline/manifest.json','independent repeat, reversed case order'),
        ('phase56-shared-optional',ids,paths['reference'],'optional Phase56 versus shared01 reproducibility screen; separate baseline')]:
    argv=['python3','-B',str(PROGRAMS/'run.py'),'--catalog',str(catalog_file),'--baseline',str(base),
          '--candidate',str(out/'candidate/manifest.json'),'--node',str(node),'--cpu','3','--rss-mib','2048',
          '--available-mib','4096','--budget','60','--cases',','.join(names),'--out',str(out/name)]
    commands.append(dict(name=name,scope=scope,optional=name.endswith('optional'),argv=argv,
                         expected=dict(complete=True,passedCases=4,freshSamples=36,roundsPerCase=3)))
save(out/'commands.json',dict(kind='phase58-scc-ablation-commands',executed=False,commands=commands,
    guard='Each unchanged programs/run.py owns its one ExecutionGuard. Root launches serially with an unpinned parent; never add an outer guard.'))
text=['# Shared-SCC runtime ablation','',
      'Data-only preparation. Choice01 is baseline and shared01 candidate; the first two runs do not use Phase56 as baseline.',
      'Morning/Evening changed; MapSet/editdist are exact-byte controls. No output is normalized or recompiled.',
      'Run the first two commands serially: 2 × 60-second presets, 36 samples each, 72 total if complete. Short-warmup screening; retain all failures and flags. Report each run separately before any pooled analysis.',
      'The third command is optional and separately compares the original Phase56 baseline to shared01. It adds 36 samples and a separate 60-second budget; it is not part of the 120-second choice ablation.',
      'Only fresh successful balanced rotations form ratios. Baseline/candidate > 1 favors shared01. Byte-identical controls can still expose measurement variation.',
      'Root owns execution. These commands contain their own guard. The reader/worker enforce heap1024MiB, RSS2048MiB, CPU3 and a4096MiB headroom floor.','']
for command in commands:text += ['## '+command['name'],'',command['scope'],'','```sh',shlex.join(command['argv']),'```','']
(out/'README.md').write_text('\n'.join(text))
for row in list(inputs.values()):
    data=Path(row['path']).read_bytes();assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256']
save(out/'report.json',dict(kind='phase58-scc-runtime-ablation-preparation',complete=True,**{'pass':True},dataOnly=True,
    targetExecuted=False,ids=ids,protocol=PRESETS[60],requiredBatches=2,requiredSamples=72,optionalSamples=36,
    comparison='choice01 direct versus shared01 direct versus the same pinned TS; optional third run uses the original Phase56 baseline explicitly.',
    sourceChanges='Choice01 to shared01 includes reach-reference deduplication and shared SCC emission. This receipt proves selected output identity/difference, not isolated JIT causality.',
    scope='Exact saved modules and checked-emission lineage. No target execution, compiler-image change, timing result, performance gate or threshold implementation.',
    lineage=lineage,byteComparison=equality,copies=copies,inputs=list(inputs.values()),inputsUnchanged=True,
    commands=pin(out/'commands.json'),recipe=pin(out/'README.md')))
print(json.dumps(dict(complete=True,manifest=pin(out/'baseline/manifest.json'),report=pin(out/'report.json'))))
