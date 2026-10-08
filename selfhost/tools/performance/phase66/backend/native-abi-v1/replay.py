#!/usr/bin/env python3
"""Root-only guarded native replay of exact failed C plus isolated ABI shim."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,time
ROOT=Path(__file__).resolve().parents[6]
def pin(p):
 p=p.resolve(strict=True);h=hashlib.sha256()
 with p.open('rb') as f:
  for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
 return {'file':str(p),'sha256':h.hexdigest(),'bytes':p.stat().st_size}
def verify(row):
 assert pin(Path(row['file']))==row, row['file']
def run(cmd,out,label,timeout):
 start=time.monotonic()
 try:
  p=subprocess.run(cmd,capture_output=True,text=True,timeout=timeout)
  result={'command':cmd,'exitCode':p.returncode,'stdout':p.stdout,'stderr':p.stderr,'seconds':time.monotonic()-start}
 except subprocess.TimeoutExpired as e:
  result={'command':cmd,'exitCode':None,'timeout':True,'seconds':time.monotonic()-start,'stdout':str(e.stdout or ''),'stderr':str(e.stderr or '')}
 (out/(label+'.json')).write_text(json.dumps(result,indent=2)+'\n');return result
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--manifest',type=Path,required=True);ap.add_argument('--toolchain',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 a.out=a.out.resolve();assert a.out.is_relative_to(ROOT/'selfhost/build/phase66') and not a.out.exists();a.out.mkdir(parents=True)
 m=json.loads(a.manifest.read_text());tc=json.loads(a.toolchain.read_text());inputs=[pin(a.manifest),pin(a.toolchain),pin(Path(__file__)),m['before'],m['after'],m['patch'],m['shim'],m['failedReport'],tc['compiler'],*tc['compilerSharedLibraries']]
 for k,v in tc['environmentOverlay'].items():assert os.environ.get(k)==v,(k,os.environ.get(k))
 shim=Path(m['shim']['file']).read_text();mark='// Requests\n// ========';rows=[]
 for item in m['replays']:
  inputs.extend([item['original'],item['derived'],item['request']]);old=Path(item['original']['file']).read_text();new=Path(item['derived']['file']).read_text();assert old.count(mark)==1 and new==old.replace(mark,shim+mark)
 for item in inputs:verify(item)
 for i,item in enumerate(m['replays']):
  binary=a.out/('program-'+str(i));c=run([os.environ['CC'],'-std=c11','-O3',item['derived']['file'],'-lpthread','-lm','-o',str(binary)],a.out,str(i)+'-compile',30)
  r=run([str(binary),'--threads','1','--gpu','off'],a.out,str(i)+'-run',30) if c['exitCode']==0 else None
  rows.append({'id':item['id'],'compile':c,'run':r,'expected':item['expected'],'pass':c['exitCode']==0 and r is not None and r['exitCode']==0 and r['stdout']==item['expected'] and r['stderr']==''})
 for item in inputs:verify(item)
 report={'kind':'phase66-native-foreign-abi-replay','pass':all(x['pass'] for x in rows),'inputs':inputs,'environment':tc['environmentOverlay'],'results':rows,'scope':'Actual failed generated C with only exact runtime shim inserted. This is compiled C replay, not fresh Bend source emission or final image qualification.'}
 (a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'pass':report['pass'],'observations':len(rows),'report':str(a.out/'report.json')}));return 0 if report['pass'] else 1
if __name__=='__main__':raise SystemExit(main())
