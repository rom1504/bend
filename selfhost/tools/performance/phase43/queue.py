#!/usr/bin/env python3
"""Execute an explicit root-owned serial job queue; keep failed dependencies."""
import json, subprocess, sys
from pathlib import Path
plan=Path(sys.argv[1]); rows=json.loads(plan.read_text()); status={}
for row in rows:
    if any(status.get(k)!=0 for k in row.get('after', [])):
        status[row['id']]='skipped-dependency'
    else:
        status[row['id']]=subprocess.run(row['command']).returncode
    print(json.dumps(dict(id=row['id'],status=status[row['id']])),flush=True)
out=plan.with_suffix('.result.json'); assert not out.exists()
out.write_text(json.dumps(status,indent=2)+'\n')
raise SystemExit(0 if all(x==0 for x in status.values()) else 1)
