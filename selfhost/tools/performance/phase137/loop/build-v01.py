"""Build already checked small products and check independent ordinary outputs."""
import argparse, hashlib, json, os, pathlib, subprocess, sys
ROOT=pathlib.Path(__file__).resolve().parents[5]
def pin(p):
 p=pathlib.Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):
 assert pin(p['file'])==p, 'Changed input '+p['file']
p=argparse.ArgumentParser();p.add_argument('--emission',action='append',required=True);p.add_argument('--out',type=pathlib.Path,required=True);p.add_argument('--expected',type=pathlib.Path,required=True);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase137')
assert sorted(os.sched_getaffinity(0))==[3]
out.mkdir();report=dict(kind='phase137-small-native-builds',complete=False,inputs=[pin(__file__),pin(a.expected)],rows=[])
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
save()
try:
 for item in a.emission:
  role,file=item.split('=',1);assert role in ['narrow','wide']
  emitted=json.loads(pathlib.Path(file).read_text());assert emitted['complete'];report['inputs'].append(pin(file));report['inputs'].append(emitted['runtime'])
  for c in emitted['cases']:
   assert c['verified'];verify(c['source']);verify(c['qbe']);verify(emitted['runtime'])
   expected=json.loads(pathlib.Path(c['expectedStdoutEvidence']['file']).read_text());verify(c['expectedStdoutEvidence']);assert expected['status']==0 and expected['stderr']=='' and expected['stdout']==a.expected.read_text()
   report['inputs'] += [c['source'],c['qbe'],c['expectedStdoutEvidence']]
   build=ROOT/'selfhost/build/phase111'/('p137-'+out.name+'-'+role+'-'+c['name'])
   cmd=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),'--source',c['qbe']['file'],'--runtime',emitted['runtime']['file'],'--out',str(build),'--expected',str(a.expected.resolve()),'--seconds','30']
   row=dict(role=role,name=c['name'],command=cmd);report['rows'].append(row);save()
   with (out/(role+'-'+c['name']+'.log')).open('xb') as log:
    proc=subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,timeout=45)
   row['exitCode']=proc.returncode;save();assert proc.returncode==0
   result=json.loads((build/'report.json').read_text());assert result['complete'] and result['outputExact']
   row.update(receipt=pin(build/'report.json'),binary=result['binary'],object=result['object'],qbe=c['qbe'],buildSeconds=result['buildSeconds']);save()
 for item in report['inputs']:verify(item)
 report['complete']=True
except BaseException as e:report['error']=repr(e);raise
finally:save()
print(json.dumps(dict(complete=True,rows=len(report['rows']))))
