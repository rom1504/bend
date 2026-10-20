#!/usr/bin/env python3
"""Prepare serial jobs using existing emit/build/observe tools; run no targets."""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]


def verify(row):
    path=ROOT/row["file"]
    raw=path.read_bytes()
    if len(raw)!=row["bytes"] or hashlib.sha256(raw).hexdigest()!=row["sha256"]:
        raise ValueError("Frozen input changed: "+str(path))
    return path


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--api",type=Path,required=True)
    parser.add_argument("--runtime",type=Path,required=True)
    parser.add_argument("--prefix",type=Path,required=True,help="fresh path prefix under selfhost/build/phase111")
    parser.add_argument("--out",type=Path,required=True,help="fresh JSON plan")
    parser.add_argument("--names",nargs="+")
    parser.add_argument("--all",action="store_true")
    parser.add_argument("--pipeline",choices=("static","direct"),default="static")
    args=parser.parse_args()
    prefix=args.prefix.resolve()
    if not prefix.is_relative_to(ROOT/"selfhost/build/phase111"):
        raise ValueError("emit/build products require Phase111 prefix")
    if args.out.exists():
        raise ValueError("plan must be fresh")
    manifest_path=HERE/"manifest01.json"
    manifest=json.loads(manifest_path.read_text())
    for row in manifest["inputs"]:
        verify(row)
    fixtures={x["name"]:x for x in manifest["fixtures"]}
    names=args.names or (list(fixtures) if args.all else manifest["fastOrder"])
    if len(names)!=len(set(names)):
        raise ValueError("duplicate fixture")
    api=args.api.resolve()
    receipt=json.loads((api.parent/"report.json").read_text())
    if not (receipt.get("complete") and receipt.get("checked")):
        raise ValueError("checked complete API required")
    required=["p88_cache_prepare","p86_prepare","p86_plan","p111_runtime_admission"]
    required += (["p113d_lower_request","p113d_verify","p113d_chunks"] if args.pipeline=="direct" else ["p112s_lower_request","p112s_verify","p112s_chunks"])
    if not all(name in receipt.get("exports",[]) for name in required):
        raise ValueError("API missing required checked staged exports: "+str(required))
    binary=receipt["command"][0]
    jobs=[]
    for name in names:
        case=fixtures[name]
        source=verify(case["source"])
        expected=verify(case["expected"])
        emit=Path(str(prefix)+"-"+name+"-emit")
        build=Path(str(prefix)+"-"+name+"-build")
        observe=Path(str(prefix)+"-"+name+"-observe")
        if any(p.exists() for p in (emit,build,observe)):
            raise ValueError("one or more outputs already exists: "+name)
        jobs += [
            dict(name=name+"-emit",seconds=60,command=[binary,str(ROOT/"selfhost/tools/performance/phase113/staged-emit.mjs"),str(api),str(source),str(emit),"cache",args.pipeline]),
            dict(name=name+"-build",seconds=60,command=["python3","-B",str(ROOT/"selfhost/tools/performance/phase111/build.py"),"--source",str(emit/"program.ssa"),"--runtime",str(args.runtime.resolve()),"--out",str(build)]),
            dict(name=name+"-observe",seconds=15,command=["python3","-B",str(ROOT/"selfhost/tools/performance/phase112/observe.py"),"--binary",str(build/"program"),"--expected",str(expected),"--out",str(observe)])]
    args.out.parent.mkdir(parents=True,exist_ok=True)
    args.out.write_text(json.dumps(dict(kind="phase113-independent-controls-jobs",targetsRun=False,
        manifest=str(manifest_path),pipeline=args.pipeline,requiredExports=required,
        preparer=dict(file=str(Path(__file__).resolve()),bytes=Path(__file__).stat().st_size,sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),
        names=names,jobs=jobs,
        scope="Complete execution observations. Optimizer admission/shape needs a separate gate; fallback is semantically valid."),indent=2)+"\n")
    print(json.dumps(dict(plan=str(args.out),cases=len(names),jobs=len(jobs),targetsRun=False)))


if __name__=="__main__":
    main()
