"""Cold candidate compiler requests on the qualified catalog, retaining digests and oracles."""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

from replay import REF, P198, sha, fdpath

def verified(pin):
    f=Path(pin["file"])
    if f.stat().st_size != pin["bytes"] or sha(f) != pin["sha256"]:
        raise ValueError("identity mismatch " + str(f))
    return f

def run(args):
    assert os.sched_getaffinity(0)=={3}
    args.out.mkdir(parents=True)
    catalog_path=P198/"progress-native45-02/report.json"
    catalog=json.loads(catalog_path.read_text())
    assert catalog["complete"] and len(catalog["rows"])==45 and not catalog["changedInputs"]
    image=os.memfd_create("tested-compiler")
    receipt=json.loads((args.image.parent/"results.json").read_text())["runs"][0]
    with gzip.open(args.image,"rb") as src, os.fdopen(os.dup(image),"wb") as dst:
        shutil.copyfileobj(src,dst)
    assert sha(fdpath(image))==receipt["elfSha256"]
    report={"catalogSha256":sha(catalog_path),"producerSha256":receipt["elfSha256"],"rows":[],"complete":False}
    for row in catalog["rows"]:
        assert row["complete"] and row["status"]=="executed-independent-oracle-pass"
        source=verified(row["source"])
        oracle=json.loads(verified(row["oracleReceipt"]).read_text())
        assert oracle["complete"] and oracle["exitCode"]==0 and oracle["stderr"]["bytes"]==0
        cmd=REF["compilerCommand"].copy()
        cmd[0],cmd[9]=fdpath(image),str(source)
        obj=os.memfd_create("ordinary-program-object")
        elf=os.memfd_create("ordinary-program")
        try:
            begin=time.monotonic()
            proc=subprocess.run(cmd,stdout=obj,stderr=subprocess.PIPE,pass_fds=(image,),timeout=24)
            if proc.returncode or proc.stderr: raise ValueError((row["id"],proc.stderr[:200]))
            assert sha(fdpath(obj))==row["object"]["sha256"],row["id"]
            link=REF["jobs"][1]["command"].copy()
            link[2],link[-1]=fdpath(obj),fdpath(elf)
            subprocess.run(link,capture_output=True,check=True,pass_fds=(obj,elf))
            cmd=[fdpath(elf),*oracle["command"][1:]]
            actual=subprocess.run(cmd,capture_output=True,pass_fds=(elf,),timeout=30)
            assert actual.returncode==0 and not actual.stderr and hashlib.sha256(actual.stdout).hexdigest()==oracle["stdout"]["sha256"],row["id"]
            report["rows"].append(dict(id=row["id"],seconds=time.monotonic()-begin,
                objectSha256=row["object"]["sha256"],stdoutSha256=oracle["stdout"]["sha256"]))
            (args.out/"results.json").write_text(json.dumps(report,indent=2)+'\n')
        finally:
            os.close(obj)
            os.close(elf)
    report["complete"]=True
    (args.out/"results.json").write_text(json.dumps(report,indent=2)+'\n')
    os.close(image)
    print(len(report["rows"]),"exact objects and executions")

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--out",required=True,type=Path)
    p.add_argument("--image",required=True,type=Path)
    run(p.parse_args())
