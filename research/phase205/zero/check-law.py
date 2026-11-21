"""Check the counted-visit theorem together with its exact Phase200 prerequisite."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path
out = Path(sys.argv[1]); out.mkdir(exist_ok=False)
sources = [Path('research/phase200/text-laws/Sequence.lean'), Path('research/phase205/zero/Visits.lean')]
combined = out / 'Visits.lean'
combined.write_bytes(b'\n'.join(p.read_bytes() for p in sources))
args = ['lean', '+leanprover/lean4:v4.32.0', str(combined)]
r = subprocess.run(args, text=True, capture_output=True)
(out / 'results.json').write_text(json.dumps(dict(command=args, exit=r.returncode, stdout=r.stdout, stderr=r.stderr, sources={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in sources}), indent=2)+'\n')
print(r.stdout+r.stderr)
sys.exit(r.returncode)
