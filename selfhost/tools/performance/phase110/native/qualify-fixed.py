#!/usr/bin/env python3
"""Root-run native preservation of four already-qualified fixed contracts."""
import argparse,hashlib,json,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','image','qualification','expected','out']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--mode',choices=['cache','live'],default='cache')
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
read=lambda path:json.loads(Path(path).read_text())
source_file=a.source.resolve()/'manifest.json';m=read(source_file);image_file=a.image.resolve()/'report.json';image=read(image_file);qualification=a.qualification.resolve();q=read(qualification);expected_file=a.expected.resolve()/'manifest.json';expected=read(expected_file)
if not m['complete'] or not image['complete'] or q.get('kind')!='phase110-native-general-qualification' or not q['complete']:raise ValueError('qualified native general image required')
if not all(any(row==value for row in q['inputs']) for value in [pin(source_file),pin(image_file),image['binary']]):raise ValueError('qualification belongs to another image')
if expected.get('kind')!='phase110-native-fixed-expected' or not expected['complete'] or [row['contract'] for row in expected['rows']]!=['reverse','tail','last','append']:raise ValueError('four fixed contracts required')
if not any(row==pin(source_file) for row in expected['inputs']):raise ValueError('fixed expectations belong to another source')
binary=verify(image['binary']);inputs=[pin(Path(__file__)),pin(source_file),pin(image_file),pin(qualification),pin(expected_file),*q['inputs'],*expected['inputs']]
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-native-fixed-qualification',complete=False,inputs=inputs,mode=a.mode,jobs=[],rows=[],scope='Exact native QBE/C products for reverse, tail, last and append match previously qualified hosted emissions; worker execution is separate.')
save=lambda:(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');save()
try:
 for test in expected['rows']:
  for fmt,key in [('qbe','expectedQbe'),('c','expectedC')]:
   for row in inputs:verify(row)
   label=test['contract']+'-'+fmt;command=[str(binary),'--threads','1','--gpu','off','--','phase110',str(verify(test['source'])),test['contract'],fmt,test['policy'],a.mode]
   job=dict(label=label,command=command);report['jobs'].append(job);save();start=time.monotonic();so=out/(label+'.stdout');se=out/(label+'.stderr')
   with so.open('xb') as stdout,se.open('xb') as stderr:child=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=45)
   job.update(status=child.returncode,seconds=time.monotonic()-start,stdout=pin(so),stderr=pin(se));save()
   if child.returncode or se.read_bytes() or so.read_bytes()!=verify(test[key]).read_bytes()+b'\n':raise ValueError(label+' differs from previously qualified exact product')
   report['rows'].append(dict(contract=test['contract'],format=fmt,output=pin(so),expected=test[key],exactExpectedPlusPrintNewline=True));save()
 for row in inputs:verify(row)
 report['complete']=True;save();print(json.dumps(dict(complete=True,contracts=4,products=len(report['rows']),mode=a.mode)))
except BaseException as error:report['error']=repr(error);save();raise
