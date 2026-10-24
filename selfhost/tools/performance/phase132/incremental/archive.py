"""Bounded object-reuse evidence archive; no compiler/program execution."""
import gzip
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tarfile

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('objects',HERE/'objects.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
ROOT=M.ROOT;B=ROOT/'selfhost/build/phase132';OUT=ROOT/'implementation/phase132/incremental-evidence'
M.require(not OUT.exists(),'Fresh archive directory required')
plan=M.read(B/'object-output-gates01/plan.json');executed=M.read(B/'object-output-gates01-executed/report.json')
M.require(executed['complete']and executed['planSha256']==M.pin(B/'object-output-gates01/plan.json')['sha256']and len(executed['jobs'])==len(plan['commands'])==15,'Output gates incomplete')
for job,command in zip(executed['jobs'],plan['commands']):M.require(job['name']==command['name']and job['command']==command['argv']and job['returncode']==0,'Output command differs')
for name in ['object-baseline-build01','object-changed-cached01','object-changed-reference01']:
    report=M.read(B/name/'report.json');M.require(report['complete'],'Build incomplete')
elf=M.read(B/'object-elf-comparison01/report.json');M.require(elf['complete']and elf['headersExact']and elf['allocatedSectionsExact']and elf['positiveCacheHits'],'Execution image comparison incomplete')
trees=['object-baseline01','object-changed01','object-baseline-build01','object-changed-cached01','object-changed-reference01','object-cache01','object-cache-reference01','object-changed-comparison01','object-elf-comparison01','object-change-census01','object-literal-churn01','object-output-gates01','object-output-gates01-executed','source-edit01','source-check01-guard','edited-full01-guard','edited-full-observation01','object-admission-negatives01']
selected=set(HERE.rglob('*'))
trees += ['object-baseline-build01-guard','object-changed-cached01-guard','object-changed-reference01-guard','object-output-gates01-guard']
for name in trees:
    path=B/name
    if path.exists():selected.update(path.rglob('*'))
for job in executed['jobs']:
    args=job['command'];path=Path(args[args.index('--out')+1]);selected.update(path.rglob('*'))
for path in [ROOT/'selfhost/build/phase130/p132-edited-full01/report.json',ROOT/'selfhost/tools/performance/phase132/symbols/compact.py',ROOT/'selfhost/tools/performance/phase132/boundaries/cache-rejections.py']:
    selected.add(path)
for oracle in plan['oracles']:
    for key in ['source','ordinaryStdout','before','after']:selected.add(M.verify(oracle[key]))
included=[];excluded=[]
for path in sorted(p for p in selected if p.is_file()and '__pycache__'not in p.parts):
    M.require(not path.is_symlink()and path.resolve().is_relative_to(ROOT),'Unsafe source')
    row=M.pin(path)
    with path.open('rb')as stream:header=stream.read(4)
    oracle=path.parent==B/'object-output-gates01' or '/phase130/p132-objects-'in str(path) or path in [Path(x['before']['file'])for x in plan['oracles']]
    if header==b'\x7fELF' or path.suffix in ['.o','.s']or(path.suffix=='.ssa'and not oracle):
        excluded.append(dict(**row,reason='Regenerable compiler/unit IR, assembly or executable/object; exact identity retained'))
    else:included.append(dict(**row,member=str(path.relative_to(ROOT))))
buffer=io.BytesIO()
with gzip.GzipFile(filename='',mode='wb',fileobj=buffer,compresslevel=9,mtime=0)as zipped:
    with tarfile.open(fileobj=zipped,mode='w|',format=tarfile.PAX_FORMAT)as tar:
        for row in included:
            data=Path(row['file']).read_bytes();M.require(hashlib.sha256(data).hexdigest()==row['sha256'],'Input changed')
            info=tarfile.TarInfo(row['member']);info.size=len(data);info.mode=0o644;info.mtime=0;info.uid=info.gid=0;info.uname=info.gname='';tar.addfile(info,io.BytesIO(data))
payload=buffer.getvalue();M.require(len(payload)<=20*1024*1024,'Archive exceeds20MiB');OUT.mkdir()
with (OUT/'evidence.tar.gz').open('xb')as f:f.write(payload)
with tarfile.open(OUT/'evidence.tar.gz','r:gz')as tar:
    members=tar.getmembers();M.require([m.name for m in members]==[r['member']for r in included],'Member list differs')
    for member,row in zip(members,included):M.require(member.isfile()and member.size==row['bytes']and hashlib.sha256(tar.extractfile(member).read()).hexdigest()==row['sha256'],'Member mismatch')
M.save(OUT/'inventory.json',dict(complete=True,targetsRun=False,members=included,excluded=excluded,externalInputPolicy='Other identities inside preserved reports remain declarations, not a recursive historical rescan. Full original/edited QBE and qualified producer/runtime are separate pinned prerequisites.'))
copies={'census.json':'object-change-census01/report.json','literal-patterns.json':'object-literal-churn01/report.json','elf.json':'object-elf-comparison01/report.json','outputs.json':'object-output-gates01-executed/report.json','cache-refusals.json':'object-admission-negatives01/report.json'}
for name,source in copies.items():(OUT/name).write_bytes((B/source).read_bytes())
M.save(OUT/'receipt.json',dict(complete=True,targetsRun=False,method=M.pin(__file__),outputs=[M.pin(p)for p in sorted(OUT.iterdir())],members=len(included),excludedArtifacts=len(excluded),everyMemberReopened=True,compressedBytes=len(payload),scope='Bounded object-reuse experiment only. No frontend incrementality, native qualification or production promotion. Raw cold/warm/reference costs and semantic gates retained separately.'))
print(json.dumps(dict(complete=True,archive=M.pin(OUT/'evidence.tar.gz'),receipt=M.pin(OUT/'receipt.json'),members=len(included),excluded=len(excluded))))
