"""Zero-additional-block archival of the two explicitly authorized Phase199 assembly files."""
import argparse
import fcntl
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import time
import zlib

ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'selfhost/build/phase198'
OUT=ROOT/'selfhost/build-retention/phase200/authorized-assembly01'
LOCK=ROOT/'selfhost/build/phase32/execution.lock'
REFERENCE=BASE/'progress-native-image01/program.s'
PREFIX='2840d921ded6a4ee141bd1cd633f150f3fbb14f1a1357681e9e808034fd94622'
EXPECTED={'p199-core-native-image01':(86612765,'0d0164bf2114af51d31cd0689d233c3427a9943231a8b0dad057438a3ec9bb96'),
          'p199-integrated-native-image01':(87046134,'d47f262d0c3529e95161d3688843eb6647f0a2301c2fa7bc5898ba7cac0277f9')}
RESERVE=5*(1<<30)
CHUNK=65536


def sha(data):return hashlib.sha256(data).hexdigest()

def syncdir(path):
    fd=os.open(path,os.O_RDONLY|os.O_DIRECTORY)
    try:os.fsync(fd)
    finally:os.close(fd)

def save(path,data):
    with path.open('x') as f:
        json.dump(data,f,indent=2);f.write('\n');f.flush();os.fsync(f.fileno())
    syncdir(path.parent)

def margin():return shutil.disk_usage(ROOT).free-RESERVE

def bootstrap():
    with REFERENCE.open('rb') as f:data=f.read(CHUNK)
    assert sha(data)==PREFIX
    return data

def recover(name,path):
    """Decode fsynced gzip members, then read the untouched source suffix after an interruption."""
    size=EXPECTED[name][0];raw_total=offset=0
    with path.open('rb',buffering=0) as f:
        while raw_total<size:
            block=os.pread(f.fileno(),CHUNK+1024,offset)
            decoder=zlib.decompressobj(31)
            try:raw=decoder.decompress(block,CHUNK+1)
            except zlib.error:break
            if not decoder.eof or len(raw)!=min(CHUNK,size-raw_total):break
            yield raw
            raw_total+=len(raw);offset+=len(block)-len(decoder.unused_data)
        if raw_total==0:
            yield bootstrap();raw_total=CHUNK
        while raw_total<size:
            raw=os.pread(f.fileno(),min(CHUNK,size-raw_total),raw_total)
            assert raw,'Incomplete recovery data'
            yield raw;raw_total+=len(raw)

def restored_digest(name,path,sink=None):
    h=hashlib.sha256();size=0
    for raw in recover(name,path):
        h.update(raw);size+=len(raw)
        if sink:sink.write(raw)
    assert (size,h.hexdigest())==EXPECTED[name]

def archive(name):
    path=BASE/name/'program.s';expected=EXPECTED[name];size,digest=expected
    builder=json.loads((path.parent/'report.json').read_bytes());assert builder['complete']
    assert builder['assembly']==dict(file=str(path),bytes=size,sha256=digest)
    st=path.lstat();assert path.resolve()==path and path.is_file() and st.st_nlink==1 and st.st_uid==os.getuid() and not os.listxattr(path)
    assert st.st_size==size and st.st_blocks*512>=size
    with path.open('r+b',buffering=0) as file:
        fd=file.fileno();assert os.lseek(fd,0,os.SEEK_HOLE)>=size,'Source has sparse extents'
        # The existing retained progress prefix is an independent durable copy before modifying block zero.
        assert os.pread(fd,CHUNK,0)==bootstrap()
        full=hashlib.sha256();roundtrip=hashlib.sha256();pieces=[]
        for pos in range(0,size,CHUNK):
            raw=os.pread(fd,min(CHUNK,size-pos),pos);full.update(raw)
            packed=gzip.compress(raw,compresslevel=5,mtime=0);roundtrip.update(gzip.decompress(packed));pieces.append(packed)
        assert full.hexdigest()==roundtrip.hexdigest()==digest
        offset=raw_total=0
        for packed in pieces:
            raw=gzip.decompress(packed)
            # Every overwritten raw byte is already durably represented by the untouched reference prefix or a previously fsynced gzip member.
            assert offset+len(packed)<=max(CHUNK,raw_total)
            count=os.pwrite(fd,packed,offset);assert count==len(packed);os.fsync(fd)
            recorded=os.pread(fd,count,offset);assert recorded==packed and gzip.decompress(recorded)==raw
            offset+=len(packed);raw_total+=len(raw)
        assert raw_total==size
        restored_digest(name,path)
        # All original bytes are now durably recoverable from this inode alone. Release excess allocated blocks.
        os.ftruncate(fd,offset);os.fsync(fd)
        assert margin()>65536,'Archive complete in its original inode; await metadata space'
        OUT.mkdir(parents=True,exist_ok=True);syncdir(OUT.parent)
        dest=OUT/(name+'.s.gz');os.link(path,dest);syncdir(OUT)
        with gzip.open(dest,'rb') as decoded:
            verified=hashlib.sha256();n=0
            for raw in iter(lambda:decoded.read(CHUNK),b''):verified.update(raw);n+=len(raw)
        assert (n,verified.hexdigest())==expected
        auth=dict(source=str(path),originalBytes=size,originalSha256=digest,mode=st.st_mode&0o7777,
                  mtimeNs=st.st_mtime_ns,archive=str(dest),archiveBytes=offset,archiveSha256=sha(dest.read_bytes()),
                  allocatedBefore=st.st_blocks*512,archiveAllocated=dest.stat().st_blocks*512,chunks=len(pieces),
                  originalInode=st.st_ino,archiveInode=dest.stat().st_ino)
        save(OUT/(name+'.verified.json'),auth)
        assert path.stat().st_ino==dest.stat().st_ino==st.st_ino and path.stat().st_nlink==2
        path.unlink();syncdir(path.parent)
        return auth

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--apply',action='store_true');p.add_argument('--restore',choices=EXPECTED);p.add_argument('--destination',type=Path);a=p.parse_args()
    if a.apply:
        assert not a.restore and not a.destination and not OUT.exists()
        with LOCK.open('rb') as lock:
            fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
            before=margin();result={};start=time.time()
            for name in EXPECTED:result[name]=archive(name)
            save(OUT/'report.json',dict(kind='phase200-authorized-assembly-archive',complete=True,inputs=EXPECTED,members=result,
                existingPrefixReference=str(REFERENCE),prefixSha256=PREFIX,chunkSize=CHUNK,initialMargin=before,finalMargin=margin(),
                methodSha256=sha(Path(__file__).read_bytes()),started=start,finished=time.time()))
            print(json.dumps(dict(complete=True,initialMargin=before,finalMargin=margin(),members=list(result))))
    else:
        assert a.restore and a.destination
        name=a.restore;source=OUT/(name+'.s.gz')
        if not source.exists():source=BASE/name/'program.s'
        assert margin()>EXPECTED[name][0]+65536
        with a.destination.open('xb') as f:restored_digest(name,source,f);f.flush();os.fsync(f.fileno())
        proof=OUT/(name+'.verified.json')
        if proof.exists():
            meta=json.loads(proof.read_bytes());a.destination.chmod(meta['mode']);os.utime(a.destination,ns=(meta['mtimeNs'],meta['mtimeNs']))
        syncdir(a.destination.parent)

if __name__=='__main__':main()
