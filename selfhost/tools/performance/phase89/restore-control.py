#!/usr/bin/env python3
"""Recover the admitted executable from its capsule, retaining a rollback copy."""
import json
import os
import subprocess
import sys
from pathlib import Path

from admission import ROOT, HERE, DEFAULT_CACHE, authenticate, pin, read, require, MANIFEST

output = ROOT / 'implementation/phase89/restoration.json'
require(not output.exists(), 'Restoration control report already exists')
image = Path(read(MANIFEST)['producer']['image']['file'])
before = pin(image)
auth = authenticate(image, DEFAULT_CACHE)
backup = image.with_name(image.name + '.restore-control-backup')
require(not backup.exists(), 'Rollback path already exists')
report = dict(complete=False, passed=False, targetJobsRun=0, method=pin(__file__),
              image=before, steps=[], receipts=[pin(ROOT/f'implementation/phase89/evidence{s}.json')
                                               for s in ('02', '03')])


def run(*args):
    command = [sys.executable, '-B', str(HERE/'restore.py'), *args]
    result = subprocess.run(command, capture_output=True, text=True)
    report['steps'].append(dict(command=command, returncode=result.returncode,
                                stdout=result.stdout, stderr=result.stderr))
    require(result.returncode == 0, 'Restoration command failed')


try:
    run('--verify-only')
    image.rename(backup)
    require(not image.exists() and pin(backup)['sha256'] == before['sha256'], 'Failed to stage missing executable')
    report['missingExecutableExercised'] = True
    run()
    require(pin(image) == before and os.access(image, os.X_OK), 'Wrong restored executable bytes or mode')
    require(authenticate(image, DEFAULT_CACHE) == auth, 'Restored admission differs')
    report.update(complete=True, passed=True, restored=pin(image), authenticationUnchanged=True)
finally:
    if backup.exists():
        if not image.exists():
            backup.rename(image)
            report['rollbackPerformed'] = True
        elif pin(image) == before:
            backup.unlink()
            report['rollbackCopyRemovedAfterIdentityCheck'] = True
        else:
            report['rollbackCopyRetained'] = str(backup)
    output.write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(complete=report['complete'], passed=report['passed'], report=pin(output))))
