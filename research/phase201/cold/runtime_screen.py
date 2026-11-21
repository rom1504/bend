"""Compare the original and proposed compiler execution runtimes, with frozen output runtime."""
import argparse
import subprocess
import sys
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument("--out",type=Path,required=True)
a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False)
runtime=a.out/"runtime.o"
source=a.out/"runtime.c"
subprocess.run([sys.executable,"-B","research/phase201/runtime/variant.py","--parent","original",
                "--mode","all","--output",str(source)],check=True)
subprocess.run(["/usr/bin/x86_64-linux-gnu-gcc-10","-O2","-std=gnu11","-ffp-contract=off",
                "-DP144_SINGLE_MUTATOR_RFC=1","-I","selfhost/src/runtime/qbe","-c",str(source),"-o",str(runtime)],check=True)
live="selfhost/build/phase198/runtime-split-controls01/runtime-live.o"
subprocess.run([sys.executable,"-B","research/phase201/cold/replay.py","--out",str(a.out/"times"),"baseline",str(runtime),live,live,str(runtime),"baseline"],check=True)
