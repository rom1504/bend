"""Prepare genuine absent-sum source ablation; reuse frozen old native baseline."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('blocks', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--parent', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
parent = json.loads(a.parent.read_text())
assert parent['complete']
inputs = [C.pin(__file__), C.pin(C.__file__), C.pin(a.parent), *parent['inputs'],
          C.pin(HERE/'table-v02.bend'), C.pin(HERE/'table-v03.bend'), parent['variants']['new']['source']]
for item in inputs:
    assert C.pin(item['file']) == item
before = Path(parent['variants']['new']['source']['file']).read_text()
old_table, new_table = C.blocks((HERE/'table-v02.bend').read_text()), C.blocks((HERE/'table-v03.bend').read_text())
assert set(old_table) == set(new_table)
changed = {n for n in old_table if C.norm(old_table[n]) != C.norm(new_table[n])}
assert changed == {'P144VEntry','p144vt_absent','p144vt_name','p144vt_kind','p144vt_width','p144vt_capacity'}
actual = C.blocks(before)
for name in changed:
    assert C.norm(actual[name]) == C.norm(old_table[name]), name
module = '\n'.join(new_table[n] for n in new_table if n in changed)
text, added, protected = C.compose(before,[module],changed,set())
assert not added
out.mkdir(parents=True)
source, expected = out/'new.bend',out/'new.expected.stdout'
source.write_text(text)
expected.write_bytes(Path(parent['variants']['new']['expected']['file']).read_bytes())
selection = json.loads((ROOT/'implementation/phase143/candidate.json').read_text())
emit = ROOT/'selfhost/build/phase130'/('p144-'+out.name+'-new-emit')
build = ROOT/'selfhost/build/phase111'/('p144-'+out.name+'-new-build')
assert not emit.exists() and not build.exists()
new = {**parent['variants']['new'], 'source':C.pin(source), 'expected':C.pin(expected),
       'emission':str(emit/'report.json'),'qbe':str(emit/'program.ssa'),
       'build':str(build/'report.json'),'binary':str(build/'program'),
       'changedDeclarations':sorted(changed)}
new['originalDeclarations'] = [{**d, 'sha256':C.hashlib.sha256(new_table[d['name']].encode()).hexdigest(),
                              'origin':'table-v03.bend'} if d['name'] in changed else d
                             for d in new['originalDeclarations']]
jobs = []
def job(name,cmd,seconds):
    jobs.append(dict(name=name,seconds=seconds+20,command=[sys.executable,'-B',
        str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(out/(name+'-guard')),
        '--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',*map(str,cmd)]))
job('new-emit',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase130/native-request.py',
    '--image',selection['native']['file'],'--source',source,'--carrier-receipt',selection['preferredCarrierReceipt']['file'],
    '--out',emit,'--seconds','120'],130)
job('new-build',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
    '--source',emit/'program.ssa','--runtime',selection['runtime']['file'],'--out',build,'--expected',expected,'--seconds','45'],75)
manifest = {**parent,'inputs':inputs,'variants':{'old':parent['variants']['old'],'new':new},'jobs':jobs,
    'ablation':'Genuine absence sum inhibits unavailable product return specialization; present records remain four fields. Six exact declaration changes; all verifier decisions/strings and workload data remain unchanged.',
    'checked':False,'targetsRun':False}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[C.pin(out/'manifest.json')],jobs=jobs),indent=2)+'\n')
print(json.dumps(dict(plan=C.pin(out/'jobs.json'),source=C.pin(source),changed=sorted(changed))))
