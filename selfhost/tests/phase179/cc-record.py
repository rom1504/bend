#!/usr/bin/python3
"""Transport-only wrapper around the pinned Clang; no compiler transformations."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, require, write_json

out = Path(os.environ['P179_CC_RECORD']).resolve(strict=True)
config = json.loads(Path(os.environ['P179_CC_CONFIG']).read_text())
args = sys.argv[1:]
require(not (out / 'cc.json').exists(), 'Expected exactly one machine compiler call')
require('-DBEND_RT_SPLIT' in args and '-c' not in args, 'Runtime must already be cached')
sources = [Path(x).resolve(strict=True) for x in args if x.endswith('.c')]
require(len(sources) == 1 and sources[0].is_relative_to(out / 'tmp'), 'Unexpected temporary C')
require(Path(args[args.index('-o') + 1]).resolve().is_relative_to(out), 'Unexpected executable path')
entered = time.monotonic()
shutil.copyfile(sources[0], out / 'program.c')
captured = time.monotonic()
command = config['commandPrefix'] + args
start = time.monotonic()
result = subprocess.run(command)
end = time.monotonic()
write_json(out / 'cc.json', dict(command=command, exitCode=result.returncode,
    enteredMonotonic=entered, compilerStartedMonotonic=start,
    compilerFinishedMonotonic=end, machineSeconds=end-start,
    captureSeconds=captured-entered, input=pin(out / 'program.c'),
    scope='Actual CLI Clang compile+link call; cached split runtime. Copy and wrapper overhead are included in whole CLI time.'))
sys.exit(result.returncode)
