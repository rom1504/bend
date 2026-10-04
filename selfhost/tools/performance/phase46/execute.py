#!/usr/bin/env python3
"""High-resolution child turnaround and resource receipt, inside ExecutionGuard."""
import json, resource, subprocess, sys, time
from pathlib import Path
out=Path(sys.argv[1]);command=sys.argv[2:]
start=time.perf_counter();r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
seconds=time.perf_counter()-start;usage=resource.getrusage(resource.RUSAGE_CHILDREN)
record=dict(command=command,returncode=r.returncode,processSeconds=seconds,
            maxRssKiB=usage.ru_maxrss,userSeconds=usage.ru_utime,systemSeconds=usage.ru_stime,
            stdout=r.stdout.decode(errors='replace'),stderr=r.stderr.decode(errors='replace'))
out.write_text(json.dumps(record,indent=2)+'\n')
sys.stdout.buffer.write(r.stdout);sys.stderr.buffer.write(r.stderr)
raise SystemExit(r.returncode)
