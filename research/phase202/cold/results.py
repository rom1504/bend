"""Produce the cold build comparison from sealed runs and independently pinned oracles."""
from pathlib import Path
import json
from statistics import median

from compare import compare

ROOT = Path(__file__).resolve().parents[3]
RUNS = ROOT / "selfhost/build/phase201"

def read(name, file="results.json"):
    guard = json.loads((RUNS / (name+"-guard") / "process.json").read_text())
    if not guard["complete"]:
        raise ValueError(name + " is unsealed or failed")
    return json.loads((RUNS / name / file).read_text()), guard

def run():
    roles = ("p202acquire01","p202self01")
    data = compare(*(RUNS / k / "results.json" for k in roles))
    for name in roles:
        j, g = read(name)
        data[name]={"peakProcessTreeRssBytes":g["peakTreeRssBytes"],"guardSeconds":g["wallSeconds"]}
    baseline = read("smoke01")[0]["runs"][0]
    smoke = read("p202self01smoke")[0]["runs"][0]
    assert baseline["objectSha256"] == smoke["objectSha256"] and baseline["verifierStdout"]==smoke["verifierStdout"]=="768"
    data["verifier"]={"previousSeconds":baseline["complete"],"candidateSeconds":smoke["complete"],
                      "objectSha256":smoke["objectSha256"], "output":smoke["verifierStdout"]}
    passed=[]
    for name in ("p202transfer03","p202transfer04"):
        if not (RUNS / name / "results.json").exists():
            continue
        portfolio, _ = read(name)
        ids = [r["id"] for r in portfolio["rows"]]
        assert portfolio["complete"] and ids == portfolio["selected"]
        assert portfolio["producerSha256"] == data["elfSha256"]
        assert not set(ids).intersection(passed)
        passed.extend(ids)
    data["native45Subset"]={"selected":passed,"exactObjectAndOutputPasses":len(passed)}
    if (RUNS / "p202verifierpairs01/results.json").exists():
        rows,_=read("p202verifierpairs01")
        rows=rows["runs"]
        assert len(rows)==4 and all(r["objectSha256"]==smoke["objectSha256"] and r["verifierStdout"]=="768" for r in rows)
        assert [r["producerSha256"] for r in rows]==[baseline["producerSha256"],smoke["producerSha256"],smoke["producerSha256"],baseline["producerSha256"]]
        old,new=median([rows[0]["complete"],rows[3]["complete"]]),median([rows[1]["complete"],rows[2]["complete"]])
        data["verifierPairs"]={"previousMedianSeconds":old,"candidateMedianSeconds":new,"ratio":new/old}
    return data

if __name__=="__main__":
    print(json.dumps(run(),indent=2))
