#!/usr/bin/env python3
"""Count frozen registered compiler source and inventory selected evidence; no targets."""
import argparse
import hashlib
import json
import re
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def pin(p):
    p = Path(p).resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def census(directory):
    attempt_path = directory/'attempt.json'
    attempt = json.loads(attempt_path.read_text())
    assert attempt['checked'] and attempt['config']['strictExact']
    snapshot = Path(attempt['snapshot']['root'])
    original = {r['frozen']['file']:r['frozen'] for r in attempt['snapshot']['sources']}
    manifest_path = snapshot/'src/compiler.json'
    manifest_pin = pin(manifest_path)
    assert manifest_pin['sha256'] == original[str(manifest_path)]['sha256']
    manifest = json.loads(manifest_path.read_text())
    assert len(manifest['modules']) == len(set(manifest['modules']))
    rows = []
    for name in manifest['modules']:
        file = snapshot/name
        identity = pin(file)
        assert identity['sha256'] == original[str(file)]['sha256']
        lines = file.read_text().splitlines()
        text = '\n'.join(lines)
        rows.append(dict(module=name, identity=identity, physical=len(lines),
            code=sum(bool(line.strip()) and not line.lstrip().startswith('#') for line in lines),
            definitions=len(re.findall(r'^def\s+',text,re.M)), laws=len(re.findall(r'^law\s+',text,re.M)),
            types=len(re.findall(r'^type\s+',text,re.M))))
    counts = {key:sum(row[key] for row in rows) for key in ['physical','code','definitions','laws','types']}
    counts['modules'] = len(rows)
    assert pin(attempt['api']['file'])['sha256'] == attempt['api']['sha256']
    return dict(attempt=pin(attempt_path), api=pin(attempt['api']['file']),
                compilerManifest=manifest_pin, counts=counts, modules=rows)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline', required=True, type=Path)
    p.add_argument('--candidate', required=True, type=Path)
    p.add_argument('--raw', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    assert not a.out.exists()
    before, after = census(a.baseline.resolve()), census(a.candidate.resolve())
    old, new = ({row['module']:row for row in c['modules']} for c in (before,after))
    changes = []
    for name in sorted(old.keys() | new.keys()):
        left,right = old.get(name),new.get(name)
        if left and right and left['identity']['sha256'] == right['identity']['sha256']:
            continue
        changes.append(dict(module=name,baseline=left,candidate=right,
            deltas={key:(right[key] if right else 0)-(left[key] if left else 0)
                    for key in ['physical','code','definitions','laws','types']}))
    live = []
    for name,row in new.items():
        current = pin(ROOT/'selfhost'/name)
        if current['sha256'] != row['identity']['sha256']:
            live.append(dict(module=name,frozen=row['identity'],live=current))
    evidence, unreadable = [], []
    paths = []
    raw = a.raw.resolve(strict=True)
    # High-level receipts only: avoid treating every nested fixture/process as
    # another independent gate or requiring a large recursive evidence join.
    for directory in sorted(raw.iterdir()):
        if not directory.is_dir():
            continue
        for relative in ['report.json','attempt.json','plan.json','image-pins.json',
                         'validation-001/report.json','execution/report.json',
                         'execution/selected/paired.json','full/report.json','driver-comparison.json',
                         'self-check/report.json','fixed-point/report.json']:
            file=directory/relative
            if file.is_file():
                paths.append(file)
    for file in paths:
        try:
            data=file.read_bytes()
            item=json.loads(data)
        except (OSError,json.JSONDecodeError) as error:
            unreadable.append(dict(file=str(file),error=str(error)))
            continue
        if not isinstance(item,dict):
            continue
        record=dict(file=str(file),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
        for key in ['kind','complete','pass','passed','checked','status','artifactKind','error',
                    'geomeanCandidateOverUpstream','geomeanBaseline23OverCandidate',
                    'allTimingQualified','observations','expectedCases','expectedAddedCases','customCases']:
            if key in item and isinstance(item[key],(str,bool,int,float,type(None))):
                record[key]=item[key]
        for key in ['records','rows','cases','jobs','emissions']:
            if isinstance(item.get(key),list):
                record[key+'Count']=len(item[key])
        evidence.append(record)
    result=dict(kind='phase69-selected-source-and-evidence-inventory',recorded=time.time(),dataOnly=True,
        targetsExecuted=False,producer=pin(__file__),baseline=before,candidate=after,
        deltas={key:after['counts'][key]-before['counts'][key] for key in before['counts']},
        changedModules=changes,liveSourceDifferences=live,evidence=evidence,unreadableReceipts=unreadable,
        scope='Frozen registered Bend modules counted once, matching Phase68 physical/code-line rules. Definitions/laws/types are syntactic counts, not semantic-concept complexity. Runtime/host, generated C and diagnostic infrastructure are excluded from Bend counts. Evidence list is a point-in-time status inventory while root may still run; it is not a final qualification join, pooled denominator or performance conclusion.')
    with a.out.open('x') as f:
        json.dump(result,f,indent=2)
        f.write('\n')
    print(json.dumps(dict(baseline=before['counts'],candidate=after['counts'],deltas=result['deltas'],
        changedModules=len(changes),liveDifferences=len(live),evidenceReceipts=len(evidence),out=str(a.out))))


if __name__=='__main__':
    main()
