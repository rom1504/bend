#!/usr/bin/env python3
"""Plan Phase147 guard closure. Reads raw metadata; never closes or prunes."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import time

ROOT=Path(__file__).resolve().parents[4]
RAW=ROOT/'selfhost/build/phase147'
HOT=['baseline-source','cold-baseline01','integrated-source03','integrated-plan05',
     'integrated-sequel02','integrated-plan04/image','integrated-plan04/cold',
     'integrated-plan04/fast-pairs','corpus-references01','corpus-identity02']
QUALIFIABLE={'integrated-plan05/image-guard','integrated-sequel02/n2-guard'}
KEEP_SUFFIX={'.json','.jsonl','.log','.stdout','.stderr','.txt','.bend','.patch','.py','.mjs','.md','.c','.h','.before','.after'}


def pin(path):
    data=path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def inside(path,parent):return path==parent or parent in path.parents


def hot_reason(path):
    for name in HOT:
        if inside(path,RAW/name):return 'explicit selected chain, full baseline, retained profiler parent, or corpus dependency'
    if path.relative_to(RAW).parts[0].startswith('profile'):
        return 'profiler image/map/sample bundle kept together pending explicit retirement'
    if 'verifier-profile' in str(path.relative_to(RAW)):
        return 'retained diagnostic profiler bundle'
    return None


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--qualification',type=Path,help='Root-selected final complete qualification receipt; never inferred')
    a=p.parse_args();out=a.out.absolute()
    assert out.resolve()==out and out.is_relative_to(ROOT/'implementation/phase147/evidence') and not out.exists()
    qualification=None
    if a.qualification:
        q=a.qualification.absolute();assert json.loads(q.read_text()).get('complete')is True
        qualification=pin(q)
    rows=[]; root_members={}; pending=[]
    for path in sorted(RAW.rglob('process.json')):
        process=json.loads(path.read_text())
        if process.get('kind')!='build-retention-disk-guard-v1':continue
        guard=path.parent;state_path=guard/'retention.json';state=json.loads(state_path.read_text())
        name=str(guard.relative_to(RAW))
        if 'finished'not in process or state.get('state')!='finished' or state.get('closed'):
            pending.append(dict(guard=name,state=state.get('state'),closed=state.get('closed')));continue
        assert state['artifactRoots']==process['artifactRoots'] and state['guardDirectory']==str(guard)
        successful=process.get('complete')is True and process.get('returncode')==0
        classification='completed'if successful else'failed'
        qualified=successful and name in QUALIFIABLE and qualification is not None
        if qualified:classification='qualified'
        close_out='selfhost/build-retention/phase147/'+name.replace('/','--')+'-close'
        argv=['python3','-B','selfhost/tools/build-retention/close.py','--run',str(guard.relative_to(ROOT)),
              '--out',close_out,'--classification',classification]
        if qualified:argv+=['--qualification',qualification['file']]
        roots=[]
        for index,value in enumerate(process['artifactRoots']):
            root=Path(value);assert root.is_relative_to(RAW) and root.resolve()==root
            reason=hot_reason(root);members=[];inodes={};keep=[];candidates=[]
            if qualified:reason='root-selected final qualification; all artifact roots stay hot'
            for f in sorted(root.rglob('*'))if root.exists()else[]:
                if f.is_symlink():
                    keep.append(str(f.relative_to(ROOT)));continue
                if not f.is_file():continue
                st=f.stat();inodes[(st.st_dev,st.st_ino)]=st.st_blocks*512
                members.append(dict(file=str(f.relative_to(ROOT)),bytes=st.st_size))
                if f.suffix in KEEP_SUFFIX or f.name in {'stdout','stderr'}:
                    keep.append(str(f.relative_to(ROOT)))
                else:candidates.append(dict(file=str(f.relative_to(ROOT)),bytes=st.st_size,
                                           allocatedBytes=st.st_blocks*512,links=st.st_nlink))
            row=dict(root=str(root.relative_to(ROOT)),keptHot=reason is not None,reason=reason,
                     files=len(members),logicalBytes=sum(x['bytes']for x in members),
                     allocatedUniqueInodesBytes=sum(inodes.values()))
            if reason:
                if not qualified:argv+=['--keep-root',str(root.relative_to(ROOT))]
            else:
                receipt=close_out+'/root-%02d/receipt.json'%index
                row.update(archiveThenSelectivePruneEligible=True,pruningAuthorized=False,
                           preservePrefixes=keep,bulkCandidateFiles=candidates,
                           policyTemplate=dict(allowedRoots=[str(root.relative_to(ROOT))],
                             archiveRoots={receipt:str(root.relative_to(ROOT))},keepPrefixes=keep),
                           blockedUntil=['root declares all target/analysis writers closed',
                             'metrics and corpus aggregators finish consuming these exact files',
                             'final compact evidence capsule verified',
                             'archive plus separate selective file plan verified and root authorizes apply'])
            roots.append(row);root_members[str(root)]=row
        rows.append(dict(guard=name,process=pin(path),retention=pin(state_path),
                         classification=classification,qualifiedPending=name in QUALIFIABLE and not qualified,
                         closeArgv=argv,closeExecuted=False,roots=roots))
    cold=[r for r in root_members.values()if not r['keptHot']]
    result=dict(kind='phase147-proposed-final-retention-plan-v1',complete=True,created=time.time(),
                dataOnly=True,targetExecuted=False,closeExecuted=False,archiveExecuted=False,pruningExecuted=False,
                campaignClosed=False,method=pin(Path(__file__).resolve()),qualification=qualification,
                guardCount=len(rows),classifications=dict(Counter(r['classification']for r in rows)),pendingGuards=pending,
                guards=rows,coldEligibleRoots=len(cold),coldEligibleLogicalBytes=sum(x['logicalBytes']for x in cold),
                coldBulkCandidateBytes=sum(y['bytes']for x in cold for y in x['bulkCandidateFiles']),
                protectedPrefixes=['selfhost/build/phase147/'+x for x in HOT],
                scope=['Planning only; successful commands do not themselves qualify a compiler.',
                  'All profiler bundles, selected roots, unguarded roots and shared coordination remain hot.',
                  'Cold rows are eligibility proposals only. Archive with close.py without --prune, then verify a policy retaining receipts/source/oracles before optional apply.',
                  'All pending/new guards require a fresh final plan. Guard state/hash changes invalidate this snapshot.',
                  'Logical and allocated inventory are not reclaim estimates: shared inodes, open files and final archive space affect actual savings.',
                  'No unrelated phases, dirty source files, installed selectors, assets/toolchains or shared lock are modified.'])
    out.parent.mkdir(parents=True,exist_ok=True)
    with out.open('x')as f:json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps({k:result[k]for k in ['guardCount','classifications','coldEligibleRoots','coldEligibleLogicalBytes','coldBulkCandidateBytes']}))


if __name__=='__main__':main()
