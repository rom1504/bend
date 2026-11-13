#!/usr/bin/env python3
"""Transport one frozen argv file through the guard without oversized path probes."""
import json
from pathlib import Path
import subprocess
import sys
command=json.loads(Path(sys.argv[1]).read_text())
assert isinstance(command,list) and command and all(isinstance(x,str) for x in command)
raise SystemExit(subprocess.run(command).returncode)
