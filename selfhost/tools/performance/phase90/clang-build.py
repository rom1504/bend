#!/usr/bin/env python3
"""One serial, bounded optimized build of the already emitted full compiler C."""
import argparse
import importlib.util
import json
import shutil
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('support', ROOT/'selfhost/tools/performance/programs/support.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
p.add_argument('image', type=Path)
a = p.parse_args()
source = ROOT/'selfhost/build/phase90/js-self11/program.c'
cc = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
include = cc.parent.parent/'include/clang'
assert S.identity(source)['sha256'] == '81ca2837d2f274a23aeab7addf40cbef0e62a96a5ff7026c62a5112b1be0361e'
assert S.identity(cc)['sha256'] == '9fcd5fc4baeea9c449bcc9ca4b9db7714465107669498b0056a853f22f5f4def'
out, image = a.out.resolve(), a.image.resolve()
assert out.parent == image.parent == ROOT/'selfhost/build/phase90'
assert not out.exists() and not image.exists()
assert shutil.disk_usage(ROOT).free > 240*1024**2, 'Need 240MiB disk headroom'
flags = ['-O1', '-ftime-report', '-ftime-trace', '-ftime-trace-granularity=1000000']
target = [str(cc), '-isystem', str(include), *flags, str(source), '-o', str(image), '-lm', '-pthread']
inputs = [S.identity(cc), S.identity(source), S.identity(__file__), S.identity(ROOT/'selfhost/tools/performance/programs/support.py')]
command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase90', 'taskset', '-c', '2,3', *target]
# This is an explicitly recorded full-Clang-only exception. The ordinary
# process supervisor, global execution lock and 16GiB headroom stop remain.
with S.ExecutionGuard(rss_mib=10240, available_mib=16384) as guard:
    result = guard.run(command, out, time.monotonic()+420)
S.save(out/'inputs.json', inputs)
S.save(out/'method.json', dict(method=S.identity(__file__), cpu='2,3',
    diskFreeBytes=shutil.disk_usage(ROOT).free, rationale='Own full C is 2.17x upstream source size; two optimized builds hit the former6GiB cap. One10GiB cap with16GiB available floor, same serial execution lock; no concurrent target.'))
print(json.dumps(result), flush=True)
sys.exit(0 if result['complete'] else 1)
