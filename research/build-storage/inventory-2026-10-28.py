import collections, hashlib, json, os, re, stat, time
from pathlib import Path
root=Path('/home/ai/bend2/build/publish/bend')
proposal=root/'deletion_proposal.txt'; text=proposal.read_text()
candidates=set(re.findall(r'^\s+[0-9.]+ GB  selfhost/build/(phase\d+)\s*$',text,re.M))
base=root/'selfhost/build'; inodes={}; rows={}; errors=[]; start=time.monotonic()
for top in sorted(base.iterdir()):
 if top.is_symlink() or not top.is_dir(): continue
 row=dict(files=0,apparentBytes=0,individuallyCountedAllocatedBytes=0,symlinks=0); rows[top.name]=row; local=set()
 for current,dirs,files in os.walk(top,followlinks=False):
  for name in files:
   p=Path(current)/name
   try:s=p.lstat()
   except OSError as e:errors.append(dict(file=str(p),error=str(e)));continue
   if stat.S_ISLNK(s.st_mode):row['symlinks']+=1;continue
   if not stat.S_ISREG(s.st_mode):continue
   row['files']+=1;row['apparentBytes']+=s.st_size
   key=(s.st_dev,s.st_ino)
   if key not in local:row['individuallyCountedAllocatedBytes']+=s.st_blocks*512;local.add(key)
   item=inodes.setdefault(key,[s.st_blocks*512,s.st_nlink,0,0])
   item[2]+=1
   if top.name in candidates:item[3]+=1
summary=dict(phaseDirectories=len(rows),proposedDirectories=len(candidates),regularFilePaths=sum(r['files'] for r in rows.values()),uniqueRegularFileInodes=len(inodes),
 allUniqueAllocatedBytes=sum(x[0] for x in inodes.values()),
 proposedIndividuallyCountedAllocatedBytes=sum(r['individuallyCountedAllocatedBytes'] for name,r in rows.items() if name in candidates),
 proposedUniqueAllocatedBytes=sum(x[0] for x in inodes.values() if x[3]),
 proposedReclaimableAllocatedBytes=sum(x[0] for x in inodes.values() if x[3] and x[3]==x[1]),
 proposedInodesRetainedByOtherLinks=sum(bool(x[3] and x[3]<x[1]) for x in inodes.values()),
 proposedBytesRetainedByOtherLinks=sum(x[0] for x in inodes.values() if x[3] and x[3]<x[1]),
 proposedApparentBytes=sum(r['apparentBytes'] for name,r in rows.items() if name in candidates),
 errors=len(errors))
out=dict(kind='read-only-build-storage-inventory',observedUtc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),seconds=time.monotonic()-start,
 proposal=dict(file=str(proposal),bytes=proposal.stat().st_size,sha256=hashlib.sha256(proposal.read_bytes()).hexdigest()),
 method='metadata-only lstat walk, no symlink traversal; (device,inode) dedup; allocated bytes=st_blocks*512; reclaimable only if all st_nlink aliases lie in proposal. Excludes directory metadata, open-deleted-file retention, filesystem compression/reflinks; this is not deletion authorization or a dependency audit.',
 summary=summary,directories=[dict(name=n,proposed=n in candidates,**r) for n,r in rows.items()],errors=errors)
p=root/'research/build-storage/proposal-inventory-2026-10-28.json';assert not p.exists();p.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(summary,indent=2))
