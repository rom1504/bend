"""Prepare fresh same-toolchain baseline/compact builds; coordinator runs CPU3."""
import argparse,importlib.util,json,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('compact',HERE/'compact.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--report',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--modes',nargs='+',default=['private-local']);a=p.parse_args()
out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase132')
r=json.loads(a.report.read_text());assert r['complete']and not r['targetsRun']
assert len(set(a.modes))==len(a.modes)and set(a.modes)<={x['mode']for x in r['modes']}
assert shutil.disk_usage(ROOT).free>2*1024**3
runtime=ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o'
builder=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
guard=ROOT/'selfhost/tools/performance/phase111/guard.py'
inputs=[C.pin(__file__),C.pin(a.report),C.pin(runtime),C.pin(builder),C.pin(guard),C.pin(HERE/'machine.py'),r['source']]
out.mkdir();jobs=[];builds={}
def target(label,source):
    output=ROOT/'selfhost/build/phase111'/('p132-'+out.name+'-'+label)
    assert not output.exists();builds[label]=str(output/'report.json')
    command=['python3',str(guard),'--out',str(out/(label+'-guard')),'--seconds','90','--rss-mib','3072','--available-mib','16384','--file-mib','128','--cpu','3','--','python3',str(builder),'--source',source['file'],'--runtime',str(runtime),'--out',str(output),'--seconds','60']
    jobs.append(dict(name=label,command=command,heavyTarget=True));inputs.append(source)
target('baseline',r['source'])
for mode in a.modes:
    row=next(x for x in r['modes']if x['mode']==mode);target(mode,row['output'])
    mapping=row.get('globalMap',row.get('mapping'));assert mapping
    inputs.append(mapping)
    jobs.append(dict(name=mode+'-machine-audit',command=['python3',str(HERE/'machine.py'),'--before',builds['baseline'],'--after',builds[mode],'--mapping',mapping['file'],'--out',str(out/(mode+'-machine'))],heavyTarget=False))
for item in inputs:assert C.pin(item['file'])==item,item['file']
result=dict(complete=True,targetsRun=False,inputs=inputs,jobs=jobs,builds=builds,
    scope='Fresh baseline and compact QBE with identical cached runtime/QBE1.3/as alignment/gcc link. '
          'Root owns one CPU3 lane. First pair is code/layout and descriptive-cost discriminator; '
          'not a controlled timing campaign. No compiler sources, defaults or qualification changed.')
(out/'jobs.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,jobs=str(out/'jobs.json'))))
