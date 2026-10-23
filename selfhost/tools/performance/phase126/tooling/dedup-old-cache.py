"""Bounded exact dedup of completed phase30..55 checked-snapshot Base caches."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import time

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('old_cache_dedup',HERE/'dedup.py')
D=importlib.util.module_from_spec(spec);spec.loader.exec_module(D)
ROOT=D.ROOT
PATTERN=re.compile(r'phase(3[0-9]|4[0-9]|5[0-5])/checked[^/]+/snapshot/build/typed/cache/base-[^/]+\.json')

def pin(path):
    path=Path(path).resolve()
    return dict(file=str(path),bytes=path.stat().st_size,sha256=D.digest(path))

def admitted(path):
    assert path==path.resolve() and not path.is_symlink()
    assert PATTERN.fullmatch(str(path.relative_to(ROOT/'selfhost/build')))
    build=path.parents[4]/'build.json'
    record=json.loads(build.read_text())
    assert record.get('complete') and record.get('finished')
    assert all(p.get('execution',{}).get('exitCode')==0 for p in record.get('phases',[]))
    return pin(build)

def unchanged(path,before):
    now=D.stat(path)
    assert all(now[k]==before[k] for k in ['device','inode','bytes','mode','uid','gid','mtimeNs'])
    return now

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--metadata',type=Path)
    p.add_argument('--apply-plan',type=Path)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();assert bool(a.metadata)!=bool(a.apply_plan)
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
    out.mkdir(parents=True);start=time.monotonic()
    methods=[pin(__file__),pin(HERE/'dedup.py')]
    r=dict(complete=False,applied=bool(a.apply_plan),methods=methods,inputs=methods[:],plan=[],results=[],
      freeBefore=shutil.disk_usage(ROOT).free,scope='Only completed old checked snapshot generated Base cache JSONs. SHA256 plus exact byte comparison and atomic same-filesystem hardlinks. Paths, bytes, modes and owners preserved; inode/mtime may change. No active phase126 files, deletion, compression or target execution.')
    def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    save()
    if a.metadata:
        meta=json.loads(a.metadata.read_text());assert meta['complete'] and not meta['contentsRead']
        r['inputs'].append(pin(a.metadata));matched={};seen=set();expected=0;hashed=0
        for group in meta['groups']:
            for item in group['rows']:
                path=Path(item['file']);build=admitted(path);s=D.stat(path);ident=(s['device'],s['inode'])
                if ident in seen:continue
                seen.add(ident)
                if s['links']!=1:continue  # Count only independently reclaimable inodes.
                sha=D.digest(path);hashed+=s['bytes'];unchanged(path,s)
                key=(s['device'],s['bytes'],s['mode'],s['uid'],s['gid'],sha)
                if key not in matched:matched[key]=(path,s,build);continue
                keep,ks,kbuild=matched[key]
                unchanged(keep,ks);assert D.equal(keep,path);unchanged(path,s)
                if expected+s['allocated']>350*1024**2:break
                r['plan'].append(dict(keep=str(keep),file=str(path),sha256=sha,before=s,keeperBefore=ks,build=build,keeperBuild=kbuild))
                expected+=s['allocated']
                if expected>=320*1024**2:break
            if expected>=320*1024**2:break
        r.update(expectedReclaimedAllocatedBytes=expected,hashedBytes=hashed)
    else:
        plan=json.loads(a.apply_plan.read_text());assert plan['complete'] and not plan['applied'] and plan['methods']==methods
        r['inputs'].append(pin(a.apply_plan));r['plan']=plan['plan'];reclaimed=0
        assert sum(x['before']['allocated'] for x in r['plan'])<=350*1024**2
        for row in r['plan']:
            keep,path=Path(row['keep']),Path(row['file'])
            assert admitted(keep)==row['keeperBuild'] and admitted(path)==row['build']
            before=unchanged(path,row['before']);unchanged(keep,row['keeperBefore']);assert before['links']==1
            assert D.digest(keep)==row['sha256']==D.digest(path) and D.equal(keep,path)
            tmp=path.with_name(path.name+'.p126-old-cache-link')
            assert not tmp.exists();os.link(keep,tmp);os.replace(tmp,path)
            after=D.stat(path);assert after['inode']==D.stat(keep)['inode'] and D.digest(path)==row['sha256']
            reclaimed+=before['allocated'];r['results'].append(dict(file=str(path),after=after,reclaimedAllocatedBytes=before['allocated']));save()
        r['reclaimedAllocatedBytes']=reclaimed
    r.update(complete=True,duplicatePaths=len(r['plan']),seconds=time.monotonic()-start,freeAfter=shutil.disk_usage(ROOT).free)
    save();print(json.dumps({k:v for k,v in r.items() if k in ['complete','applied','duplicatePaths','expectedReclaimedAllocatedBytes','reclaimedAllocatedBytes','hashedBytes','seconds','freeBefore','freeAfter']}))

if __name__=='__main__':main()
