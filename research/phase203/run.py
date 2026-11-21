"""Run generated compiler probes with the same request, full object and program oracles."""
import argparse
import gzip
import json
import os
from pathlib import Path
import statistics
import subprocess
import time
from assembly import P201, ROOT, SOURCE, REF, fdpath, sha

def snapshot(schema,path):
    rows=[]
    for line in path.read_text().splitlines():
        stage,wall,cpu,*counts=line.split()
        nums={schema["counters"][int(k)]:int(v) for k,v in (s.split("=") for s in counts)}
        rows.append({"stage":schema["stages"][int(stage)],"wallNs":int(wall),"cpuNs":int(cpu),"counts":nums})
    assert rows[0]["stage"]=="@start" and rows[-1]["stage"]=="@exit"
    assert all(b["wallNs"]>=a["wallNs"] and b["cpuNs"]>=a["cpuNs"] for a,b in zip(rows,rows[1:]))
    return rows

def run(args):
    assert os.sched_getaffinity(0)=={3}
    args.out.mkdir(parents=True,exist_ok=False)
    full=args.full
    source=SOURCE if full else ROOT/"selfhost/build/phase167/verifier-source03/compiler.bend"
    expected=json.loads((P201/("p202self01" if full else "p202self01smoke")/"results.json").read_text())
    assert expected["sourceSha256"]==sha(source)
    want=expected["runs"][0]["objectSha256"]
    report={"source":sha(source),"expectedObject":want,"complete":False,"runs":[]}
    target=args.out/"results.json"
    for i,role in enumerate(args.roles):
        schema=json.loads((args.build/(role+".json")).read_text())
        program=args.build/role
        assert schema["elfSha256"]==sha(program)
        cmd=REF["compilerCommand"].copy()
        cmd[0],cmd[9]=str(program.resolve()),str(source)
        trace=args.out/(str(i)+".tsv")
        env=dict(os.environ,BEND_PHASE203_OBSERVATIONS=str(trace.resolve()))
        with os.fdopen(os.memfd_create("fresh-object"),"w+b") as obj, os.fdopen(os.memfd_create("fresh-exe"),"w+b") as exe:
            start=time.monotonic()
            proc=subprocess.run(cmd,stdout=obj,stderr=subprocess.PIPE,env=env,check=True)
            emitted=time.monotonic()
            assert not proc.stderr,proc.stderr[:300]
            objpath,exepath=fdpath(obj.fileno()),fdpath(exe.fileno())
            link=REF["jobs"][1]["command"].copy()
            link[2],link[-1]=objpath,exepath
            if full: link[3]=str((P201/"runtime01/runtime.o").resolve())
            subprocess.run(link,pass_fds=(obj.fileno(),exe.fileno()),capture_output=True,check=True)
            end=time.monotonic()
            assert sha(objpath)==want,role
            if not full:
                output=subprocess.run([exepath,"+RTS","--threads","1","--gpu","off","-RTS"],pass_fds=(exe.fileno(),),capture_output=True,check=True)
                assert output.stdout==b"768\n" and not output.stderr
            events=[] if role=="stock" else snapshot(schema,trace)
            report["runs"].append(dict(role=role,producer=schema["elfSha256"],emit=emitted-start,link=end-emitted,object=want,events=events))
            target.write_text(json.dumps(report,indent=2)+"\n")
    report["complete"]=True
    target.write_text(json.dumps(report,indent=2)+"\n")

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--build",type=Path,required=True);p.add_argument("--out",type=Path,required=True)
    p.add_argument("--full",action="store_true");p.add_argument("roles",nargs="+",choices=["stock","marks","counts"])
    run(p.parse_args())
