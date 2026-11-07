#!/usr/bin/env python3
"""Deduplicate only Phase175's 45 exact QBE copies against their recorded oracle.

Both paths remain present, immutable and byte-identical. No source, binary,
runtime, report or selected compiler changes. Verify and apply are separate.
"""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('p175_dedup',ROOT/'experiments/phase175/dedup-machine.py')
D=importlib.util.module_from_spec(spec);spec.loader.exec_module(D)
A=D.A;need=A.need
root=ROOT/'selfhost/build/phase175/timed-products45'
out=ROOT/'selfhost/build/phase176'
action=sys.argv[1];need(action in ['verify','apply'],'verify or apply')

def inspect():
    inputs=[A.pin(root/'report.json'),A.pin(root.with_name(root.name+'-guard')/'process.json'),A.pin(root.with_name(root.name+'-guard')/'retention.json')]
    report,guard,life=[json.loads(Path(p['file']).read_text())for p in inputs]
    need(report['complete'] and not report['changedInputs'] and len(report['rows'])==45,'Qualified exact product set required')
    need(guard['complete'] and life['closed'] and life['state']=='sealed','Writer must be sealed')
    rows=[]
    for x in report['rows']:
        left,right=x['expected'],x['product'];lp,rp=Path(left['file']),Path(right['file'])
        need(rp.parent.parent==root and rp.name=='program.ssa' and lp.is_relative_to(ROOT/'selfhost/build/phase169'),'Unexpected product location')
        need(x['complete'] and all(left[k]==right[k]for k in ['bytes','sha256']),'Not an exact oracle copy')
        lm,rm=D.metadata(lp),D.metadata(rp);linked=lm['inode']==rm['inode']
        need(lm['links']==rm['links']==(2 if linked else 1),'Unknown aliases')
        need(all(lm[k]==rm[k]for k in ['device','size','mode','uid','gid']),'Incompatible metadata')
        A.authenticate(left);A.authenticate(right);need(D.C.same_bytes(lp,rp),'Literal comparison failed')
        need(D.metadata(lp)==lm and D.metadata(rp)==rm,'Concurrent product change')
        rows.append(dict(id=x['id'],left=left,right=right,leftMetadata=lm,rightMetadata=rm,alreadyLinked=linked))
    return dict(inputs=inputs,rows=rows)

with A.exclusive():
    need(shutil.disk_usage(ROOT).free>=5*2**30+2**20,'Preserve reserve and receipt headroom')
    method=[A.pin(__file__),A.pin(D.__file__),A.pin(A.__file__),A.pin(D.C.__file__)]
    before=inspect();receipt=dict(kind='phase176-exact-product-dedup',action=action,complete=False,method=method,before=before,immutablePaths=True)
    if action=='apply':
        verified=out/'storage-verified.json';v=json.loads(verified.read_text())
        need(v['complete'] and v['action']=='verify' and v['method']==method and v['before']==before,'Verification stale')
        receipt['verified']=A.pin(verified);A.write_new(out/'storage-intent.json',receipt)
        with (out/'storage-journal.jsonl').open('x')as journal:
            for x in before['rows']:
                if x['alreadyLinked']:continue
                lp,rp=Path(x['left']['file']),Path(x['right']['file']);temp=rp.with_name('program.ssa.phase176-link')
                need(not temp.exists() and not temp.is_symlink(),'Existing link temporary')
                need(D.metadata(lp)==x['leftMetadata'] and D.metadata(rp)==x['rightMetadata'],'Changed before link')
                try:
                    os.link(lp,temp);A.authenticate(x['left']);A.authenticate(x['right'])
                    need(D.C.same_bytes(temp,rp) and D.metadata(rp)==x['rightMetadata'],'Changed destination')
                    current=D.metadata(lp);need(current==dict(x['leftMetadata'],links=2,ctimeNs=current['ctimeNs']),'Changed keeper')
                    os.replace(temp,rp);D.sync_parent(rp)
                    journal.write(json.dumps(dict(id=x['id'],sha256=x['right']['sha256'],recoveredBytes=x['rightMetadata']['allocatedBytes']))+'\n');journal.flush();os.fsync(journal.fileno())
                finally:
                    if temp.exists():temp.unlink()
    after=inspect();need(after['inputs']==before['inputs'],'Original receipts changed')
    receipt.update(after=after,complete=True,recoveredAllocatedBytes=sum(x['rightMetadata']['allocatedBytes']for x in before['rows']if not x['alreadyLinked']) if action=='apply' else 0)
    A.write_new(out/('storage-verified.json' if action=='verify' else 'storage-applied.json'),receipt)
    print(json.dumps(dict(complete=True,action=action,recoveredAllocatedBytes=receipt['recoveredAllocatedBytes'])))
