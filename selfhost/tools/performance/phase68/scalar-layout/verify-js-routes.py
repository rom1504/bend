#!/usr/bin/env python3
"""Source-only exact JS/frontend closure check across the new native entry."""
import argparse,hashlib,importlib.util,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser(description=__doc__)
for name in ['baseline','candidate','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();a.out.mkdir(exist_ok=False)
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
inputs=[pin(__file__)]
def read(p):inputs.append(pin(p));return json.loads(Path(p).read_text())
records=[read(d/'attempt.json') for d in [a.baseline,a.candidate]]
assert all(r['checked'] and r['config']['strictExact'] for r in records)
for r in records:
 for x in r['snapshot']['sources']:
  assert pin(x['frozen']['file'])['sha256']==x['frozen']['sha256'];inputs.append(pin(x['frozen']['file']))
 for k in ['api','runtime','base']:assert pin(r[k]['file'])['sha256']==r[k]['sha256'];inputs.append(pin(r[k]['file']))
assert all(records[0][k]['sha256']==records[1][k]['sha256'] for k in ['runtime','base','node'])
parent=ROOT/'selfhost/tools/performance/phase66/controls/frontend-closure.py';inputs.append(pin(parent))
s=parent.read_text();old='    assert len(exports) == 99';assert s.count(old)==1
scanner=a.out/'scanner.py';scanner.write_text(s.replace(old,'    assert len(exports) in [99, 100]'))
inputs.append(pin(scanner));spec=importlib.util.spec_from_file_location('scanner',scanner);C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
programs=[C.program(r['api']['file']) for r in records];before,after=programs
assert len(before['exports'])==99 and len(after['exports'])==100
assert set(after['exports'])-set(before['exports'])=={'nc_compile_checked'}
assert all(after['exports'][k]==v for k,v in before['exports'].items())
assert before['runtime']==after['runtime']
assert before['exportSource'].splitlines()==[l for l in after['exportSource'].splitlines() if not l.startswith('  "nc_compile_checked":')]
drivers=[(Path(r['snapshot']['root'])/'tools/typed-driver.mjs').read_text() for r in records]
# This exact extra bootstrap declaration exports only the new native root.
export="    if(files.includes('src/back/native/scalar-array.bend'))exports.push('nc_compile_checked');\n"
assert drivers[1].count(export)==1;drivers[1]=drivers[1].replace(export,'')
regions=[("    if(mode==='native'&&api.nc_annotation_stops",'    } else if(selectedEmission){'),("    if(mode==='native') {","    trace('emit '+mode);")]
stripped=[];arms=[]
for driver in drivers:
 route=driver;items=[]
 for begin,end in regions:
  assert driver.count(begin)==driver.count(end)==1
  first=driver.index(begin);last=driver.index(end,first);arm=driver[first:last]
  assert route.count(arm)==1;route=route.replace(arm,'');items.append(dict(begin=begin,end=end,sha256=hashlib.sha256(arm.encode()).hexdigest()))
 stripped.append(route);arms.append(items)
assert stripped[0]==stripped[1], 'Host JS/frontend route changed'
route=stripped[0];dynamic=[l for l in route.splitlines() if 'api[' in l]
assert len(dynamic)==5 and all("typeof api[name]==='function'" in l or "typeof api[name]!=='function'" in l for l in dynamic)
refs=set(re.findall(r'\bapi\.([A-Za-z_]\w*)',route));assert refs-set(before['exports'])=={'bend','mjs'}
roots=sorted(refs&set(before['exports']));left,right=[C.closure(prog,roots) for prog in programs]
assert left==right
assert all(before['functions'][k]['source']==after['functions'][k]['source'] for k in left)
report=dict(complete=True,pass_=True,roots=roots,unchangedFunctions=len(left),runtimeExact=True,commonExportWrappersExact=True,hostRoutesExact=True,nativeGuardedArms=arms,addedNativeRoot='nc_compile_checked',scannerDerivation=dict(parent=pin(parent),candidate=pin(scanner),before=old,after='    assert len(exports) in [99, 100]'),inputs=inputs,scope='Exact frontend/JS generated dependency closure and host routes; native guards excluded. Does not transfer native or B2 behavior, compiler timings, or untested public API roots.')
(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items() if k not in ['inputs','nativeGuardedArms','roots']}))
