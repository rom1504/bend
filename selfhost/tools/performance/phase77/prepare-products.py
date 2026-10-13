#!/usr/bin/env python3
import json,hashlib,shutil
from pathlib import Path
R=Path('selfhost/build/phase77');M=Path('selfhost/tools/performance/phase77');out=R/'products01';out.mkdir()
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
parent=R/'compiler01-compilation/plan.json';j=json.loads(parent.read_text());old=j['roles']['b2'];project=out/'memo-project';shutil.copytree(old['project'],project,ignore=shutil.ignore_patterns('build'))
p=project/'tools/typed-driver.mjs';s=p.read_text()
before='layoutDefs=api.annotate_selected(contextBook,selected,stops);layoutStops=stops;'
after="const products=usedPreparedWorld&&baseAnnotationApis(api)?readBaseAnnotations(api,info,cached,graph.prefixLoad,selected,stops):null;\n      layoutDefs=products?api.annotate_selected_base(contextBook,selected,stops,products):api.annotate_selected(contextBook,selected,stops);layoutStops=stops;"
assert s.count(before)==1;s=s.replace(before,after);p.write_text(s)
j['roles']['memo']={**old,'project':str(project.resolve()),'driver':pin(p),'runtime':pin(project/'src/runtime.mjs'),'preparation':str((out/'runs/prepare-memo/report.json').resolve()),'persistent':False}
for c in j['cases'].values():c['expected']['memo']=c['expected']['b2']
j['inputs'] += [pin(parent),pin(__file__),pin(M/'warm-request.mjs'),*[pin(f) for f in project.rglob('*') if f.is_file()]]
j['jobs']=[dict(name='prepare-memo',role='memo',action='prepare',profile=False)]
j['scope']='Prototype reads the existing Bend-produced, exact-context-admitted Base annotation products during native requests. Unprepared requests retain ordinary annotation. No erased/lowered native output is cached.'
(out/'plan.json').write_text(json.dumps(j,indent=2)+'\n')
(out/'derivation.json').write_text(json.dumps(dict(parent=old['driver'],output=pin(p),before=before,after=after),indent=2)+'\n')
