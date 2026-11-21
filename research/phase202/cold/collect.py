"""Retain small receipts; generated compiler images stay in the guarded artifact store."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

def main(out, names):
    runs={}
    root=Path("selfhost/build/phase201")
    for name in names:
        directory=root/name
        guard=directory.with_name(name+"-guard")/"process.json"
        if not guard.is_file():
            raise FileNotFoundError(guard)
        process=json.loads(guard.read_text())
        if "finished" not in process:
            raise ValueError("unfinished guard " + name)
        run={"guard":process,"receipts":{}}
        for file in ["results.json","report.json"]:
            path=directory/file
            if path.is_file():
                data=path.read_bytes()
                run["receipts"][file]={"sha256":hashlib.sha256(data).hexdigest(),"data":json.loads(data)}
        if not process.get("complete"):
            err=guard.parent/"stderr.log"
            run["failure"]=err.read_text(errors="replace")[-1500:]
        runs[name]=run
    out.write_bytes(gzip.compress((json.dumps(runs,indent=2)+"\n").encode(),mtime=0))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("out",type=Path)
    p.add_argument("runs",nargs="+")
    a=p.parse_args()
    main(a.out,a.runs)
