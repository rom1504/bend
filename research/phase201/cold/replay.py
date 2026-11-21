"""Run Phase198's native self-build with fresh anonymous object and executable products."""
import argparse
import fcntl
import gzip
import shutil
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
P198 = ROOT / "selfhost/build/phase198"
REF = json.loads((P198 / "progress-native-reproduction01/report.json").read_text())

def sha(path):
    digest = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

def fdpath(fd):
    return f"/proc/self/fd/{fd}"

def run(args):
    assert os.sched_getaffinity(0) == {3}
    args.out.mkdir(parents=True,exist_ok=False)
    compiler = REF["compilerCommand"].copy()
    source = Path(compiler[9]) if args.full else P198.parent / "phase167/verifier-source03/compiler.bend"
    if args.source:
        source = args.source.resolve()
    compiler[9] = str(source)
    artifact = None
    if args.reference:
        reference = json.loads(args.reference.read_text())
        assert reference["sourceSha256"] == sha(source)
        artifact = reference["runs"][0]["objectSha256"]
    env = os.environ.copy()
    report = {"productRuntimeSha256": sha(args.product_runtime or REF["runtime"]["file"]), "source": str(source), "sourceSha256": sha(source), "runs":[]}
    if args.profile:
        sampler = args.out.resolve() / "sample.so"
        subprocess.run(["gcc","-std=gnu11","-O2","-shared","-fPIC",str(ROOT/"selfhost/tools/profiler/sample-threads.c"),
                        "-o",str(sampler),"-pthread","-lrt","-ldl"],check=True)
        env.update(LD_PRELOAD=str(sampler), BEND_SAMPLE_PERIOD_US="20000" if args.full else "3000")
    for iteration,role in enumerate(args.roles):
        # Re-link the frozen compiler program object only for an experimental runtime.
        producer_fd = None
        descriptors = []
        command = compiler.copy()
        if role == "qbe":
            command[0] = str(P198 / "progress-native-image01/program")
        elif role.startswith("image:"):
            producer_fd = os.memfd_create("candidate-compiler")
            descriptors.append(producer_fd)
            image = Path(role[len("image:"):])
            with gzip.open(image, "rb") as src, os.fdopen(os.dup(producer_fd), "wb") as dst:
                shutil.copyfileobj(src, dst)
            command[0] = fdpath(producer_fd)
        elif role != "baseline":
            producer_fd = os.memfd_create("cold-producer")
            descriptors.append(producer_fd)
            link = REF["jobs"][1]["command"].copy()
            link[2] = str(P198/"progress-native-self01/program.o")
            link[3] = str(Path(role).resolve())
            link[-1] = fdpath(producer_fd)
            subprocess.run(link,check=True,pass_fds=tuple(descriptors),capture_output=True)
            command[0] = fdpath(producer_fd)
        if args.profile:
            env["BEND_SAMPLE_OUT"] = str(args.out.resolve()/f"sample-{iteration}.txt")
        obj = os.memfd_create("fresh-object")
        elf = os.memfd_create("fresh-linked-image")
        try:
            begin=time.monotonic()
            p=subprocess.run(command,env=env,pass_fds=tuple(descriptors),stdout=obj,stderr=subprocess.PIPE)
            emitted=time.monotonic()
            if p.returncode or p.stderr:
                raise RuntimeError((p.returncode,p.stderr[:1024]))
            link = REF["jobs"][1]["command"].copy()
            # GNU ld may encode its object argument in STT_FILE. Give it the
            # same filename even when the producer itself is loaded from RAM.
            stable_obj = fcntl.fcntl(obj,fcntl.F_DUPFD_CLOEXEC,90)
            descriptors.append(stable_obj)
            link[2],link[-1]=fdpath(stable_obj),fdpath(elf)
            if args.product_runtime:
                link[3] = str(args.product_runtime.resolve())
            subprocess.run(link,check=True,pass_fds=(stable_obj,elf),capture_output=True)
            end=time.monotonic()
            digest=sha(fdpath(obj))
            if artifact:
                assert digest == artifact
            if args.full and not args.source:
                assert digest == REF["object"]["sha256"]
            if report["runs"]:
                assert report["runs"][0]["objectSha256"] == digest
            run=dict(role=role,producerSha256=sha(command[0]),objectSha256=digest,elfSha256=sha(fdpath(elf)),
                     bytes=os.fstat(obj).st_size,emit=emitted-begin,link=end-emitted,complete=end-begin)
            if args.save_image:
                with open(fdpath(elf), "rb") as src, gzip.open(args.out/"program.gz","xb",compresslevel=1) as dst:
                    shutil.copyfileobj(src,dst)
            if not args.full and not args.source:
                checked = subprocess.run([fdpath(elf),"+RTS","--threads","1","--gpu","off","-RTS"],
                                         pass_fds=(elf,),capture_output=True,timeout=20)
                assert (checked.returncode,checked.stdout,checked.stderr) == (0,b"768\n",b"")
                run["verifierStdout"] = "768"
            report["runs"].append(run)
            (args.out/"results.json").write_text(json.dumps(report,indent=2)+"\n")
            print(json.dumps(run),flush=True)
        finally:
            for fd in [obj,elf,*descriptors]:
                os.close(fd)

if __name__ == "__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--out",type=Path,required=True)
    p.add_argument("--full",action="store_true")
    p.add_argument("--source",type=Path)
    p.add_argument("--reference",type=Path)
    p.add_argument("--save-image",action="store_true")
    p.add_argument("--product-runtime", type=Path)
    p.add_argument("--profile",action="store_true")
    p.add_argument("roles",nargs="+")
    run(p.parse_args())
