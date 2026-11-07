#!/usr/bin/env python3
"""Execute the exact reviewed Phase175 transport-file recovery, no compiler jobs."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('retention_close', ROOT/'selfhost/tools/build-retention/close.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
A = C.A
which = sys.argv[1] if len(sys.argv) == 2 else 'phase140'
reviewed = {'phase140':'3739ce753eb9836e891cc9e4550f4af65ac9d2a75a3d8c0aaba175c4898ef6a7',
            'phase102':'233312656791efe9d3483947891ac17c61901ddca6e436a60b394f938088bc30',
            'own':'fa6ee5f9d23ea2956670c03baf1eb2a99e4dd193ce0e350967845b592988b7bc',
            'own-combined':'0bfd87afea97018d1d01ca71a378609e13c04116801fdf3396ee723086009f79'}
A.need(which in reviewed, 'Only explicitly reviewed proposals are admitted')
proposal = ROOT/({'own':'experiments/phase175/storage-own-native-intermediates.json',
                  'own-combined':'experiments/phase175/storage-own-combined.json'}.get(which,
                  'experiments/phase175/storage-emergency-'+which+'.json'))
expected = reviewed[which]
A.need(A.pin(proposal)['sha256'] == expected, 'Unreviewed proposal')
plan = json.loads(proposal.read_text())
A.authenticate(plan['method'])
A.authenticate(plan['archiveVerifier'])

class MaintenanceBudget(C.Budget):
    def __init__(self, archive):
        super().__init__()
        self.archive = archive

    def check(self, *, additional=0, force=False):
        super().check(additional=additional, force=force)
        A.need(shutil.disk_usage(ROOT).free >= plan['maintenanceReserveBytes'], 'Maintenance reserve')
        if self.archive.exists():
            A.need(self.archive.stat().st_size <= plan['archiveCapPerRootBytes'], 'Archive cap')

for item in plan['roots']:
    base = ROOT/item['captureOut']
    A.need(not base.exists(), 'Fresh recovery output required')
    base.mkdir()
    root = ROOT/item['root']
    budget = MaintenanceBudget(base/'capsule/files.tar.gz')
    started = time.monotonic()
    free_before = shutil.disk_usage(ROOT).free
    with A.exclusive():
        A.authenticate(item['report'])
        A.need(json.loads(Path(item['report']['file']).read_text())['complete'], 'Unfinished old run')
        rows = []
        for selected in item['selectedFiles']:
            path = ROOT/selected['file']
            A.need(path.relative_to(root).as_posix() == selected['member'], 'Member/path mismatch')
            A.need((which == 'phase140' and (path.name == 'payload.bin' or path.suffix == '.frames')) or
                   (which == 'phase102' and path.name == 'child.json') or
                   (which in ['own','own-combined'] and path.name in ['program.s','program.o']), 'Unexpected file category')
            A.need(A.metadata(path) == selected['metadata'], 'Changed metadata')
            identity = {k:selected[k] for k in ['bytes', 'sha256']}
            A.need(identity['bytes'] <= plan['memberCapBytes'], 'Member cap')
            A.need({k:A.pin(path)[k] for k in identity} == identity, 'Original evidence differs')
            rows.append(dict(path=path, name=selected['member'], signature=C.signature(path), identity=identity))
        receipt = C.capsule(root, rows, base/'capsule', budget)
        policy = dict(allowedRoots=[item['root']], archiveRoots={str(receipt.relative_to(ROOT)):item['root']}, keepPrefixes=[])
        A.write_new(base/'policy.json', policy)
    command = [sys.executable, '-B', str(C.ARCHIVE), 'verify', '--policy', str(base/'policy.json'), '--receipt', str(receipt), '--out', str(base/'verified')]
    with (base/'verify.stdout').open('x') as out:
        subprocess.run(command, cwd=ROOT, stdout=out, check=True, timeout=120)
    verified = json.loads((base/'verified/plan.json').read_text())
    selected = {str(ROOT/x['file']):x for x in item['selectedFiles']}
    actual = list(A.plan_files(verified))
    A.need(verified['selectedFiles'] == len(selected) and verified['allocatedBytes'] == item['allocatedBytes'], 'Unexpected prune totals')
    A.need({r['file']['file'] for r in actual} == set(selected), 'Unexpected prune members')
    for row in actual:
        wanted = selected[row['file']['file']]
        A.need(row['metadata'] == wanted['metadata'] and all(row['file'][k] == wanted[k] for k in ['bytes','sha256']), 'Prune differs from approved member')
    with (base/'apply.stdout').open('x') as out:
        subprocess.run(item['applyCommand'], cwd=ROOT, stdout=out, check=True, timeout=120)
    result = dict(name=item['name'], complete=True, seconds=time.monotonic()-started,
                  freeBefore=free_before, freeAfter=shutil.disk_usage(ROOT).free,
                  receipt=A.pin(receipt), applied=A.pin(base/'applied/report.json'))
    A.write_new(base/'recovery.json', result)
    print(json.dumps(result), flush=True)
