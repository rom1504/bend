"""Obtain the Phase202 compiler's ordinary assembly listing for a diagnostic build."""
from pathlib import Path
import gzip
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "research/phase201/cold"))
from replay import REF, fdpath, sha

P201 = ROOT / "selfhost/build/phase201"
SOURCE = ROOT / "selfhost/build/phase202/stack06/compiler.bend"
IMAGE = P201 / "p202acquire01/program.gz"

def run(out):
    assert os.sched_getaffinity(0) == {3}
    out.mkdir(parents=True,exist_ok=False)
    identity = json.loads((IMAGE.parent / "results.json").read_text())
    assert sha(SOURCE) == identity["sourceSha256"]
    fd=os.memfd_create("phase202")
    with gzip.open(IMAGE,"rb") as src, os.fdopen(os.dup(fd),"wb") as dst:
        shutil.copyfileobj(src,dst)
    assert sha(fdpath(fd))==identity["runs"][0]["elfSha256"]
    cmd=REF["compilerCommand"].copy()
    cmd[0],cmd[8],cmd[9]=fdpath(fd),"x86",str(SOURCE)
    start=time.monotonic()
    count=0
    h=hashlib.sha256()
    with (out/"stderr").open("wb") as err, subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=err,pass_fds=(fd,)) as proc, gzip.open(out/"program.s.gz","xb",compresslevel=1) as dst:
        for chunk in iter(lambda:proc.stdout.read(1048576),b""):
            count+=len(chunk)
            if count>180*1024*1024:
                proc.kill()
                raise ValueError("unexpected assembly size")
            h.update(chunk)
            dst.write(chunk)
        assert proc.wait()==0
    os.close(fd)
    assert count>1024*1024 and not (out/"stderr").stat().st_size
    (out/"report.json").write_text(json.dumps(dict(sha256=h.hexdigest(),bytes=count,source=identity["sourceSha256"],
        producer=identity["runs"][0]["elfSha256"],seconds=time.monotonic()-start,argv=cmd),indent=2)+"\n")

if __name__=="__main__":run(Path(sys.argv[1]))
