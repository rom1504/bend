"""Bind cold-build results to the historical oracles and the resource supervisor."""
from bisect import bisect_right
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import statistics
import subprocess

from replay import P198, ROOT, sha

P201 = P198.parent / "phase201"

def read(path):
    return json.loads(path.read_bytes())

def pins(path):
    return {"file":str(path.relative_to(ROOT)), "bytes":path.stat().st_size, "sha256":sha(path)}

def samples(sample,image):
    lines=sample.read_text()
    raw,pcs=lines.split("\nPCS\n")
    entries=[int(row,16) for row in pcs.splitlines() if row != "END"]
    meta=dict(line.split("\t",1) for line in raw.split("\nMAPS\n")[0].splitlines() if "\t" in line)
    assert len(entries)==int(meta["samples"]) and meta["dropped"]=="0"
    nm=subprocess.run(["nm","-nS",str(image)],capture_output=True,text=True,check=True)
    symbols=[]
    for line in nm.stdout.splitlines():
        x=line.split()
        if len(x)==4 and x[2] in ("t","T"):
            symbols.append((int(x[0],16),int(x[1],16),x[3]))
    symbols.sort()
    starts=[row[0] for row in symbols]
    counts=Counter()
    for pc in entries:
        i=bisect_right(starts,pc)-1
        base,size,name=symbols[i]
        if i<0 or pc>=base+size: name="unmapped"
        match=re.fullmatch(r'p(?:111|113d)_FID_((?:[0-9]+_)+)',name)
        if match: name=''.join(chr(int(c)) for c in match.group(1)[:-1].split('_'))
        counts[name]+=1
    return {"input":pins(sample), "image":pins(image),"samples":len(entries),"overruns":int(meta["overruns"]),
            "dropped":int(meta["dropped"]), "topLeaves":counts.most_common(15)}

def summarize():
    runs={}
    for g in sorted(P201.glob("*-guard")):
        if not (g/"process.json").is_file(): continue
        j=read(g/"process.json")
        runs[g.name[:-6]]={k:j.get(k) for k in ("complete","returncode","wallSeconds","stoppedFor","peakTreeRssBytes",
                                             "peakRunAllocatedBytes","peakFilesystemDecreaseBytes","command")}
    data={"guards":runs,"measurements":{}}
    files=["slice02/results.json","check01/report.json","check02/report.json","runtime01/times/results.json",
           "elfscreen01/report.json","acquire01/results.json","smoke01/results.json","cold01/results.json","transfer01/results.json"]
    for rel in files:
        p=P201/rel
        if p.is_file(): data["measurements"][rel]={"pin":pins(p),"receipt":read(p)}
    data["physicalVerifierProfiles"]=[samples(P201/f"slice02/sample-{i}.txt",P198/f"progress-native-{image}01/program")
                                      for i,image in enumerate(["self","image"])]
    if (P201/"cold01/results.json").exists():
        old=read(P201/"acquire01/results.json"); new=read(P201/"cold01/results.json")
        a,b=old["runs"][0],new["runs"][0]
        assert old["sourceSha256"]==new["sourceSha256"] and old["productRuntimeSha256"]==new["productRuntimeSha256"]
        assert b["producerSha256"]==a["elfSha256"]==b["elfSha256"] and a["objectSha256"]==b["objectSha256"]
        assert all(runs[k]["complete"] for k in ("acquire01","cold01"))
        data["cold"]={"objectAndExecutableExact":True,"sourceSha256":old["sourceSha256"],"incumbent":a["complete"],
                      "candidate":b["complete"],"secondsSaved":a["complete"]-b["complete"],
                      "fractionSaved":1-b["complete"]/a["complete"],"remainingFactorTo37s":b["complete"]/37}
    return data

if __name__=="__main__":
    print(json.dumps(summarize(),indent=2))
