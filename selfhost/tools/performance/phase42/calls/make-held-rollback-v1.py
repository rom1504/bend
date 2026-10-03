"""Prepare exact isolated reverse integration; never edit canonical sources."""
from pathlib import Path
import hashlib,json,difflib,subprocess,re
root=Path(__file__).resolve().parents[5]
# Explicit component artifacts; reverse order respects their source dependencies.
patches=[
'selfhost/tools/performance/phase42/calls/finite-component-root.patch',
'selfhost/tools/performance/phase42/facts/map-bst/sequential-candidate04/candidate.patch',
'selfhost/tools/performance/phase42/frames/bst/native-emitter-source.patch',
'selfhost/tools/performance/phase42/facts/map-bst/closed-types-candidate04/candidate.patch']
out=root/'selfhost/tools/performance/phase42/calls/held-rollback-v1';out.mkdir()
def sha(b):return hashlib.sha256(b).hexdigest()
files={};producers=[]
for name in patches:
 p=root/name;b=p.read_bytes();producers.append({'path':str(p),'sha256':sha(b)})
 for f in re.findall(r'^\+\+\+ b/(.+)$',b.decode(),re.M):
  if f not in files:
   before=(root/f).read_bytes();files[f]=before;t=out/f;t.parent.mkdir(parents=True,exist_ok=True);t.write_bytes(before)
receipts=[]
for name in patches:
 run=subprocess.run(['patch','--directory',str(out),'-p1','--reverse','--batch','--fuzz=0','--input',str(root/name)],capture_output=True,text=True)
 receipts.append({'patch':name,'exit':run.returncode,'stdout':run.stdout,'stderr':run.stderr})
 if run.returncode:
  (out/'failure.json').write_text(json.dumps(receipts,indent=2)+'\n');raise SystemExit('Exact reverse failed; no canonical source touched')
combined='';rows=[]
for f,before in files.items():
 after=(out/f).read_bytes();combined+=''.join(difflib.unified_diff(before.decode().splitlines(True),after.decode().splitlines(True),fromfile='a/'+f,tofile='b/'+f))
 assert (root/f).read_bytes()==before,'Canonical source changed during producer'
 rows.append({'path':str(root/f),'beforeSha256':sha(before),'afterSha256':sha(after),'removedNetLines':len(before.splitlines())-len(after.splitlines())})
held=('j_finite_component_work','j_sequence_','j_native_tuple_fields','j_pure_closed_','j_pure_same_closed','j_pure_sigma_','j_pure_list_head','j_pure_list_check','j_pure_native_ctor')
for f in files:
 text=(out/f).read_text()
 for symbol in held:assert symbol not in text,(f,symbol)
assert all('j_flat_' in (out/f).read_text() for f in files if f.endswith(('finite.bend','tree.bend'))),'Flat scope must remain'
(out/'source.patch').write_text(combined)
(out/'report.json').write_text(json.dumps({'kind':'unapplied-exact-held-scope-rollback','complete':True,'canonicalSourceUntouched':True,'producer':{'path':str(Path(__file__).resolve()),'sha256':sha(Path(__file__).read_bytes())},'patches':producers,'reverseReceipts':receipts,'files':rows,'removedNetLines':sum(r['removedNetLines']for r in rows),'retained':['flat v5 code','direct calls and expansion budget','covered owner shape fix','owned constructors','fusion','request facts'],'natAddCanonicalPresent':False,'executed':['exact patch application in isolated copies only'],'compilerOrTargetExecution':False},indent=2)+'\n')
print(json.dumps({'complete':True,'out':str(out),'removedNetLines':sum(r['removedNetLines']for r in rows)}))
