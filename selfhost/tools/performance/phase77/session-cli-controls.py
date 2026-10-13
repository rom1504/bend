#!/usr/bin/env python3
"""Exercise the real installed NDJSON tool; all writes stay in a new test root."""
import hashlib,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
out=Path(sys.argv[1]).resolve();out.mkdir()
node=sys.argv[2];tool=ROOT/'selfhost/tools/native-session.mjs'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def launch():return subprocess.Popen([node,'--stack-size=4096','--max-old-space-size=1024',str(tool)],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
records=[];p=launch();source=out/'source.bend';target=out/'result.c'
def send(proc,input,output,id):
 proc.stdin.write(json.dumps(dict(id=id,input=str(input),output=str(output)))+'\n');proc.stdin.flush()
 result=json.loads(proc.stdout.readline());assert result['id']==id;records.append(result);return result
def source_value(value):source.write_text('import Base\n\ndef main() -> U32:\n  '+value+'\n')
source_value('42');first=send(p,source,target,'first');assert first['status']=='ok' and first['sha256']==digest(target)
before=target.read_bytes();source_value('"bad"');bad=send(p,source,target,'bad');assert bad['status']=='error' and not bad['recycle'] and target.read_bytes()==before
source_value('43');changed=send(p,source,target,'changed');assert changed['status']=='ok' and target.read_bytes()!=before
source_value('42');again=send(p,source,target,'restored');assert again['status']=='ok' and target.read_bytes()==before
p.stdin.close();assert p.wait(timeout=10)==0;stderr=p.stderr.read();assert not stderr,stderr
# A .c symlink to the source must not overwrite source bytes.
alias=out/'alias.c';alias.symlink_to(source);before=source.read_bytes();p=launch()
refused=send(p,source,alias,'alias');assert refused['status']=='error' and refused['recycle'] and 'aliases' in refused['diagnostic'] and source.read_bytes()==before
p.stdin.close();assert p.wait(timeout=10)==0;assert not p.stderr.read()
report=dict(complete=True,passed=True,checks=['NDJSON-success','error-preserves-output','edited-source','restored-source','source-alias-refusal'],records=records,tool=dict(file=str(tool),sha256=digest(tool)),api=dict(file=str(ROOT/'selfhost/dist/typed-api.mjs'),sha256=digest(ROOT/'selfhost/dist/typed-api.mjs')))
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('installed native session CLI controls passed')
