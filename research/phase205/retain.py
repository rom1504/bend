"""Retain bounded stage receipts, refusing unsealed or unrecognized runs."""
import json,gzip,hashlib,io,tarfile,sys
from pathlib import Path
root=Path('selfhost/build')
dest=Path('implementation/phase205/evidence')
def pin(b):return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def store(path,doc):
    raw=json.dumps(doc,separators=(',',':'),ensure_ascii=False).encode()
    path.write_bytes(gzip.compress(raw,compresslevel=9,mtime=0))
def main(p):
    run=root/p
    guard=run.with_name(run.name+'-guard')
    ret=json.loads((guard/'retention.json').read_text())
    assert ret['state']=='sealed',str(run)
    rec={}
    for folder,names in [(guard,['process.json','retention.json','stderr.log','stdout.log']),(run,['report.json','results.json','summary.json','summary.md','preparation.json','timing/report.json','stderr'])]:
        for n in names:
            f=folder/n
            if not f.is_file():continue
            b=f.read_bytes();entry=pin(b);entry['file']=str(f)
            if n.endswith('.json'):
                val=json.loads(b)
                if n=='preparation.json':
                    val={k:val[k] for k in val if k not in ('cases','controls')}
                entry['data']=val
            else:entry['tail']=b[-4000:].decode(errors='replace')
            rec[str(f)]=entry
    store(dest/(run.name+'.json.gz'),rec)
for p in sys.argv[1:]:main(p)
