#!/usr/bin/env python3
"""Data-only completed workflow occupancy and preservation audit."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT/'selfhost/build/phase62'
OUT = ROOT/'implementation/phase62/evidence/accounting-preservation.json'
assert not OUT.exists()


def sha(file):
    return hashlib.sha256(file.read_bytes()).hexdigest()


groups = []
for name in ['preparation', 'clean36', 'cpu46', 'allocation46', 'stages-smoke04', 'stages46', 'warm16']:
    p = RAW/'generations01'/name/'report.json'
    r = json.loads(p.read_text())
    assert r['complete'] and r['pass'] and not r['failures']
    groups.append(dict(name=name, seconds=r['wallSeconds'], receipt=str(p.relative_to(ROOT)), sha256=sha(p)))
p = RAW/'scaling01/report.json'
r = json.loads(p.read_text())
assert r['complete'] and r['pass'] and not r['failures']
groups.append(dict(name='scaling01', seconds=r['elapsedSeconds'], receipt=str(p.relative_to(ROOT)), sha256=sha(p)))
for name in ['work-counts01-supervisor', 'work-counts02-supervisor']:
    p = RAW/name/'run.json'; r = json.loads(p.read_text())
    assert r['complete'] and r['returncode'] == 0 and not r.get('stoppedFor')
    groups.append(dict(name=name, seconds=r['wallSeconds'], peakTreeRssBytes=r['peakTreeRssBytes'],
                       receipt=str(p.relative_to(ROOT)), sha256=sha(p)))
protected = json.loads((OUT.parent/'inherited-files.json').read_text())
for item in protected['files']:
    assert sha(ROOT/item['file']) == item['sha256'], item['file']
old = json.loads((ROOT/'selfhost/build/phase61/preservation-final.json').read_text())
installed = old['installedInventory']
if isinstance(installed, dict):
    installed = list(installed.values())
for item in installed:
    assert sha(Path(item['file'])) == item['sha256'], item['file']
result = dict(kind='phase62-workflow-accounting-and-preservation', complete=True,
              workflows=groups, workflowWallSeconds=sum(x['seconds'] for x in groups),
              protectedFiles=len(protected['files']), installedFiles=len(installed),
              inheritedFilesUnchanged=True, installedFilesUnchanged=True,
              scope='Sum of ten serial whole-workflow wall receipts, not target CPU time or '
                    'complete session elapsed. Includes preparation, preflight, validation and '
                    'profile processing inside each workflow. Excludes source research, tool '
                    'development, review, data-only analysis and publication. No overlapping '
                    'child clocks added; no claim that uncovered elapsed time was waiting.')
result['pass'] = True
OUT.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: result[k] for k in ['workflowWallSeconds', 'protectedFiles', 'installedFiles']}))
