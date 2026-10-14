#!/usr/bin/env python3
"""Serial native launcher acceptance/refusal controls; keep every failed attempt."""
import json
import subprocess
import sys
from pathlib import Path
from native_support import ROOT, pin, require

out = Path(sys.argv[1]).resolve()
out.mkdir(parents=True, exist_ok=False)
method = Path(__file__).parent
image = ROOT / 'selfhost/build/phase88/compiler-native02'
rows = []
report = dict(complete=False, method=pin(__file__), rows=rows)
cases = [
    ('type-error', 'import Base\n\ndef main() -> U32:\n  True{}\n', 'check:', False),
    ('parse-error', 'import Base\n\ndef main( -> U32:\n  42\n', 'parse:', False),
    ('extra-import', 'import Base\nimport ./other.bend as Other\n\ndef main() -> U32:\n  42\n', 'rejects additional import', False),
    ('missing-base', 'def main() -> U32:\n  42\n', 'requires import Base', False),
    ('unaudited-effect', 'import Base\n\ndef main() -> IO(Unit):\n  IO.sleep(1)\n', 'rejects foreign path', False),
    ('cached', 'import Base\n\ndef main() -> U32:\n  42\n', None, False),
    ('live', 'import Base\n\ndef main() -> U32:\n  42\n', None, True),
]
try:
    for name, text, error, live in cases:
        source, target = out / (name + '.bend'), out / (name + '.c')
        source.write_text(text)
        command = [sys.executable, '-B', str(method / 'native.py'), str(source), '-o', str(target), '--image', str(image)]
        if live:
            command.append('--live')
        result = subprocess.run(command, capture_output=True, text=True)
        (out / (name + '.stdout')).write_text(result.stdout)
        (out / (name + '.stderr')).write_text(result.stderr)
        logs = [line.removeprefix('Native request evidence: ') for line in result.stderr.splitlines()
                if line.startswith('Native request evidence: ')]
        require(len(logs) == 1, 'Missing request evidence')
        record = json.loads((Path(logs[0]) / 'report.json').read_text())
        passed = (result.returncode != 0 and not target.exists() and error in result.stderr) if error else (result.returncode == 0 and target.exists() and record['complete'])
        rows.append(dict(case=name, source=pin(source), expectedError=error, returncode=result.returncode,
                         passed=passed, evidence=logs[0], output=pin(target) if target.exists() else None))
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        require(passed, 'Unexpected launcher result: ' + name)
    require(rows[-1]['output']['sha256'] == rows[-2]['output']['sha256'], 'Cached/live C mismatch')
    # Publishing is exclusive: a caller's existing file is never overwritten.
    before = pin(target)
    result = subprocess.run(command, capture_output=True, text=True)
    (out / 'existing-output.stderr').write_text(result.stderr)
    require(result.returncode != 0 and 'Output already exists' in result.stderr and pin(target) == before,
            'Existing output refusal failed')
    report.update(complete=True, passed=True, existingOutputPreserved=True)
finally:
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(dict(complete=report['complete'], cases=len(rows))))
