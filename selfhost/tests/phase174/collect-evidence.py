#!/usr/bin/env python3
"""Collect bounded exact Phase174 receipts; never run a compiler or prune artifacts.

--plan records a provisional selection. --seal requires --final, no active
(unexplained unfinished) guard, fresh output, and unchanged selected bytes.
Missing terminal guard receipts are explicit unknowns, never estimated.
"""
import argparse
from collections import defaultdict
from datetime import datetime, timezone
import gzip
import hashlib
import json
import math
import os
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[3]
RUN = ROOT/'selfhost/build/phase174'
IMPL = ROOT/'implementation/phase174'
META_LIMIT = 1024**2
LOG_LIMIT = 128*1024
METHOD_LIMIT = 256*1024
RAW_LIMIT = 48*1024**2
ARCHIVE_LIMIT = 6*1024**2

def require(ok, message):
    if not ok: raise ValueError(message)

def read(path): return json.loads(path.read_text())
def digest(stream):
    h, size = hashlib.sha256(), 0
    while block := stream.read(1024**2): h.update(block); size += len(block)
    return dict(bytes=size,sha256=h.hexdigest())
def pin(path):
    path=Path(path).absolute()
    require(path.resolve()==path and path.is_file(), 'Regular unsymlinked input required: '+str(path))
    before=path.stat()
    with path.open('rb')as stream: identity=digest(stream)
    after=path.stat()
    require((before.st_ino,before.st_size,before.st_mtime_ns,before.st_ctime_ns)==(after.st_ino,after.st_size,after.st_mtime_ns,after.st_ctime_ns),'Input changed during read: '+str(path))
    return dict(file=str(path.relative_to(ROOT)),**identity,mode=stat.S_IMODE(after.st_mode))
def write(path,value):
    path=Path(path);path.parent.mkdir(parents=True,exist_ok=True)
    tmp=path.with_name(path.name+'.tmp')
    with tmp.open('w')as f:json.dump(value,f,indent=2);f.write('\n')
    os.replace(tmp,path)

def purpose(name, command):
    if name.startswith('fixed-'): return 'fixed_input_performance','final'
    if name.startswith('installed-'): return 'installed_validation','final'
    if any('release.py' in str(v) for v in command): return 'installation','final'
    if name.startswith(('b1','js-b2','js-b3','native-n2','q3','public-bridge','public-c-emission','public-package','controls-api','lazy-baseline-api','qbe-api','session-api')): return 'acquisition_and_reproduction','final'
    if name.startswith('controls-'): return 'finite_controls','final'
    return 'qualification','final'

def collect_costs(final):
    rows=[];active=[];unknown=[];unsealed=[];totals=defaultdict(float);counts=defaultdict(int);intervals=[]
    for path in sorted(RUN.rglob('process.json')):
        value=read(path)
        if value.get('kind')!='build-retention-disk-guard-v1':continue
        lifecycle=path.with_name('retention.json')
        if lifecycle.exists()and read(lifecycle).get('guardDirectory')!=str(path.parent):continue
        name=str(path.parent.relative_to(RUN));category,tranche=purpose(name,value.get('command',[]));finished=value.get('finished');seconds=value.get('wallSeconds');interruption=path.with_name('interruption.json')
        terminal=isinstance(finished,(int,float))and isinstance(seconds,(int,float))and math.isfinite(seconds)and seconds>=0 and value.get('returncode')is not None
        row=dict(name=name,process=pin(path),purpose=category,tranche=tranche,complete=value.get('complete'),returncode=value.get('returncode'),stoppedFor=value.get('stoppedFor'),started=value.get('started'),finished=finished,wallSeconds=seconds if terminal else None,command=value.get('command',[]),artifactRoots=value.get('artifactRoots',[]))
        if lifecycle.exists():row['lifecycle']=pin(lifecycle);row['retentionState']=read(lifecycle).get('state')
        if terminal:
            if row.get('retentionState')!='sealed':unsealed.append(name)
            if not value.get('complete'):category='failures'
            row.update(accountingCategory=category,counted=True,peakRssBytes=value.get('peakTreeRssBytes'),minimumDiskFreeBytes=value.get('minimumDiskFreeBytes'))
            totals[category]+=seconds;counts[category]+=1
            if isinstance(value.get('started'),(int,float)):intervals.append((value['started'],finished))
        elif interruption.exists()and read(interruption).get('complete'):
            row.update(accountingCategory='unknown_interrupted',counted=False,interruption=pin(interruption),limitation='No final guard receipt: wall time and peak RSS are unknown; not counted and not estimated.')
            unknown.append(name)
        else:
            row.update(accountingCategory='active_or_unfinished',counted=False);active.append(name)
        rows.append(row)
    merged=[]
    for start,end in sorted(intervals):
        if not merged or start>merged[-1][1]:merged.append([start,end])
        else:merged[-1][1]=max(end,merged[-1][1])
    union=sum(b-a for a,b in merged);observed=sum(totals.values())
    return dict(kind='phase174-guard-cost-summary',version=1,complete=bool(final and not active),phaseFinalized=bool(final),accountingComplete=not(active or unknown),provisional=not final,createdUTC=datetime.now(timezone.utc).isoformat(),method=pin(__file__),guards=rows,totals=dict(guardRecords=len(rows),measuredGuards=sum(counts.values()),measuredGuardWallSeconds=observed,byCategorySeconds=dict(sorted(totals.items())),byCategoryCounts=dict(sorted(counts.items())),observedIntervalUnionSeconds=union,overlapSeconds=max(0,observed-union),unknownInterruptedGuards=len(unknown),activeOrUnfinishedGuards=len(active)),unknownInterrupted=unknown,activeOrUnfinished=active,unsealedCompletedGuards=unsealed,limits=['Measured guard wall seconds include failures with final receipts; they are not total research wall time, CPU-seconds, or agent cost.','Any interrupted guard without a final receipt is excluded; elapsed time and peak RSS are never inferred from note timestamps.','Acquisition/reproduction, qualification, finite controls, fixed-input performance and installed validation are classified separately. Native bootstrap acquisition includes its internal generation checks; its outer guard is counted once.','Archive maintenance, editing, analysis, idle gaps and external jobs are not included. Missing timing means observed totals are a lower bound, even after phase completion.'])

def candidate_files(costs):
    candidates=set();excluded=[];method_refs=[]
    def visit(base):
        if not base.exists():return
        for path in base.rglob('*'):
            if not path.is_file():continue
            if path.is_symlink():excluded.append(dict(file=str(path.relative_to(ROOT)),reason='symlink not captured'));continue
            if path.is_relative_to(IMPL/'evidence')or path.name.startswith('evidence-plan'):continue
            size=path.stat().st_size;name=path.name;cap=None
            if path.suffix in ['.json','.jsonl','.md']:cap=META_LIMIT
            elif name in ['stdout','stderr']or name.endswith(('.stdout','.stderr','.log')):cap=LOG_LIMIT
            elif path.suffix in ['.py','.sh']or(path.suffix=='.mjs'and name not in ['api.mjs','compiler.mjs','frontend-api.mjs','checker-api.mjs']):cap=METHOD_LIMIT
            if cap is None:continue
            if size<=cap:candidates.add(path)
            else:excluded.append(dict(file=str(path.relative_to(ROOT)),bytes=size,reason='Above bounded metadata/log/method cap; large product/source identities remain in exact reports'))
    for base in [RUN,ROOT/'experiments/phase174',ROOT/'design/phase174',IMPL,ROOT/'selfhost/build-retention/phase174',ROOT/'selfhost/tests/phase174']:
        visit(base)
    # Preserve every Phase174 closure receipt/plan without copying tar payloads.
    for base in (ROOT/'selfhost/build-retention').glob('phase174-*-close'):visit(base)
    # Seven exact archived roots use the frozen Phase169 capture adapter.
    # Only their small metadata is selected, never compressed payloads.
    proposal=read(ROOT/'experiments/phase174/storage-proposal01.json')
    for row in proposal['roots'][:7]:visit(ROOT/'selfhost/build-retention/phase169'/row['name'])
    candidates.add(Path(__file__).absolute());candidates.add(ROOT/'selfhost/manifests/current.json')
    for row in costs['guards']:
        value=read(ROOT/row['process']['file'])
        for record in value.get('method',{}).get('commandFiles',[]):
            raw=record.get('path');path=Path(raw)if raw else None
            if path is None or not path.is_relative_to(ROOT)or path.suffix not in ['.py','.mjs','.sh']or record.get('bytes',METHOD_LIMIT+1)>METHOD_LIMIT:continue
            status='missing'
            if path.is_file():
                identity=pin(path);status='matches_recorded_method'if all(identity[k]==record[k]for k in ['bytes','sha256'])else'changed_since_recorded_run'
                candidates.add(path)
            method_refs.append(dict(recorded=record,status=status))
    # Imported maintained adapters are small execution methods, never compiler images.
    for path in (ROOT/'selfhost/tools/build').glob('*'):
        if path.is_file()and path.suffix in ['.py','.mjs']and path.stat().st_size<=METHOD_LIMIT:candidates.add(path)
    files=[pin(path)for path in sorted(candidates)]
    require(sum(v['bytes']for v in files)<=RAW_LIMIT,'Selected receipts exceed raw evidence budget; review selection explicitly')
    return files,excluded,method_refs

class LimitedOutput:
    def __init__(self,stream):self.stream=stream;self.written=0
    def write(self,data):
        require(self.written+len(data)<=ARCHIVE_LIMIT,'Compressed evidence exceeds6MiB cap; sources unchanged')
        self.written+=len(data);return self.stream.write(data)
    def flush(self):return self.stream.flush()

def seal(out,plan,costs):
    require(costs['phaseFinalized']and not costs['activeOrUnfinished'],'Final collection requires no unexplained active guards')
    require(not costs['unsealedCompletedGuards'],'Close completed guards before final evidence seal: '+str(costs['unsealedCompletedGuards']))
    out=out.absolute();require(out.is_relative_to(IMPL/'evidence')and not out.exists(),'Fresh implementation/phase174/evidence output required')
    out.mkdir(parents=True);archive=out/'receipts.tar.gz'
    with archive.open('xb')as raw:
        with gzip.GzipFile(filename='',mode='wb',fileobj=LimitedOutput(raw),mtime=0,compresslevel=6)as compressed:
            with tarfile.open(fileobj=compressed,mode='w|')as tar:
                for item in plan['files']:
                    path=ROOT/item['file'];require(pin(path)==item,'Selected input changed before archive')
                    info=tarfile.TarInfo(item['file']);info.size=item['bytes'];info.mode=item['mode'];info.mtime=0
                    with path.open('rb')as source:tar.addfile(info,source)
        raw.flush();os.fsync(raw.fileno())
    expected={v['file']:v for v in plan['files']};seen=set()
    with tarfile.open(archive,'r:gz')as tar:
        for member in tar:
            require(member.isfile()and member.name in expected and member.name not in seen,'Unexpected evidence member');seen.add(member.name);item=expected[member.name]
            with tar.extractfile(member)as source:require(digest(source)=={k:item[k]for k in ['bytes','sha256']},'Evidence member mismatch')
            require(member.mode==item['mode'],'Evidence member mode differs')
    require(seen==set(expected),'Missing evidence members')
    with gzip.open(archive,'rb')as source:
        while source.read(1024**2):pass
    for item in plan['files']:require(pin(ROOT/item['file'])==item,'Selected input changed during collection')
    write(out/'index.json',dict(plan,complete=True,archive=pin(archive),allMembersVerified=True,sourceInputsUnchanged=True,restore='Archive members use exact repository-relative paths. Restore into a fresh directory, verify each index hash/size/mode, then copy only intended missing metadata; never overwrite live methods or manifests. Large omitted compiler artifacts are not recoverable from this bounded receipt capsule.'))
    print(json.dumps(dict(complete=True,archive=pin(archive),files=len(plan['files']),rawBytes=sum(v['bytes']for v in plan['files']),measuredGuardSeconds=costs['totals']['measuredGuardWallSeconds'],unknownInterrupted=costs['unknownInterrupted'])))

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--costs',type=Path,default=IMPL/'costs.json')
    p.add_argument('--plan',type=Path)
    p.add_argument('--final',action='store_true',help='Use only after final gates, installation and report writing finish')
    p.add_argument('--seal',type=Path,help='Fresh output; requires --final. Omit for metadata planning only.')
    args=p.parse_args();require(not args.seal or args.final,'--seal requires explicit --final')
    costs=collect_costs(args.final);write(args.costs,costs);files,excluded,methods=candidate_files(costs)
    head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
    plan=dict(kind='phase174-bounded-exact-evidence-plan',version=1,complete=False,provisional=not args.final,gitHeadAtCollection=head,method=pin(__file__),costs=pin(args.costs),files=files,excluded=excluded,referencedMethods=methods,limits=dict(rawBytes=RAW_LIMIT,archiveBytes=ARCHIVE_LIMIT,metadataFileBytes=META_LIMIT,logFileBytes=LOG_LIMIT),scope=['Exact small reports, methods, controls, guard receipts, interruptions, retention and installation metadata.','No binary/SSA/source snapshots or generated compiler API images are included. Their original identities remain in reports; this is not a hermetic compiler distribution.','Method references that changed since a recorded run are labeled; current bytes are not misrepresented as the former execution method.','No compiler/program execution or pruning. Archive creation occurs only on explicit --final --seal after all reports finish.'])
    if args.plan:write(args.plan,plan)
    if args.seal:seal(args.seal,plan,costs)
    else:print(json.dumps(dict(provisional=not args.final,selectedFiles=len(files),rawBytes=sum(v['bytes']for v in files),costTotals=costs['totals'],active=costs['activeOrUnfinished'],unknownInterrupted=costs['unknownInterrupted'])))

if __name__=='__main__':main()
