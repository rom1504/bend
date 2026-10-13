#!/usr/bin/env python3
import json,hashlib,shutil
from pathlib import Path
R=Path('selfhost/build/phase77');M=Path('selfhost/tools/performance/phase77');out=R/'strings01';out.mkdir()
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
parent=R/'compiler01-compilation/plan.json';j=json.loads(parent.read_text());r=j['roles']['b2'];api=Path(r['api']['file']);s=api.read_text();edits=[]
for key,body in [('String_46_starts_95_with','return p77_starts($a0,$a1);'),('String_46_contains','return p77_contains($a0,$a1);'),('String_46_reverse','return [...$a0].reverse().join("");'),('String_46_is_95_empty','return $a0==="";')]:
 start=s.index('function $jd$'+key+'(');end=s.index('\nfunction ',start);before=s[start:end];replacement='function $jd$'+key+'($a0,$a1,$a2){'+body+'}';s=s[:start]+replacement+s[end:];edits.append(dict(name=key,before=before,after=replacement))
s+='\nfunction p77_boundary(s,i){return !(i>0&&i<s.length&&s.charCodeAt(i)>=0xDC00&&s.charCodeAt(i)<=0xDFFF&&s.charCodeAt(i-1)>=0xD800&&s.charCodeAt(i-1)<=0xDBFF); }\nfunction p77_starts(s,p){return s.startsWith(p)&&p77_boundary(s,p.length); }\nfunction p77_contains(s,p){for(let i=s.indexOf(p);i>=0;i=s.indexOf(p,i+1))if(p77_boundary(s,i)&&p77_boundary(s,i+p.length))return true;return false;}\n'
image=out/'api.mjs';image.write_text(s);project=out/'project';shutil.copytree(r['project'],project,ignore=shutil.ignore_patterns('build'))
r.update(api=pin(image),project=str(project.resolve()),driver=pin(project/'tools/typed-driver.mjs'),runtime=pin(project/'src/runtime.mjs'),preparation=str((out/'runs/prepare-b2/report.json').resolve()))
j['jobs']=[dict(name='prepare-b2',role='b2',action='prepare',profile=False)]+[dict(name='clean-'+str(i)+'-'+c+'-b2',role='b2',action='request',case=c,round=i,profile=False) for i in range(3) for c in j['cases']]
j['inputs'] += [pin(parent),pin(__file__),pin(image),*[pin(f) for f in project.rglob('*') if f.is_file()]]
j['scope']='Diagnostic B2 string-kernel derivative. No checked or self-emitted provenance claimed for modified image. Complete C must equal actual compiler01 acquisitions.'
(out/'plan.json').write_text(json.dumps(j,indent=2)+'\n');(out/'derivation.json').write_text(json.dumps(dict(parent=pin(api),output=pin(image),edits=edits),indent=2)+'\n')
