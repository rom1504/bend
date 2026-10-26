"""Execute the six frozen focused native controls serially under an outer guard."""
import json
from pathlib import Path
import subprocess
import sys
import time

plan = Path(sys.argv[1]).resolve()
data = json.loads(plan.read_text())
assert data['kind'] == 'phase142-native-layout-control-plan' and data['complete']
assert len(data['jobs']) == 6
rows = []
out = plan.with_name(plan.stem + '-execution.json')
assert not out.exists()
started = time.monotonic()
record = dict(complete=False, plan=str(plan), jobs=rows)
save = lambda: out.write_text(json.dumps(record, indent=2) + '\n')
save()
try:
    for job in data['jobs']:
        command = job['command']
        assert Path(command[2]).name == 'native-emit.py'
        before = time.monotonic()
        completed = subprocess.run(command, timeout=55, capture_output=True)
        rows.append(dict(name=job['name'], variant=job['variant'],
                         command=command, seconds=time.monotonic()-before,
                         exitCode=completed.returncode,
                         expectedExit=job['expectedTransportExit'],
                         stdout=completed.stdout.decode(errors='replace'),
                         stderr=completed.stderr.decode(errors='replace')))
        save()
        assert completed.returncode == job['expectedTransportExit']
    record['complete'] = True
finally:
    record['seconds'] = time.monotonic()-started
    save()
