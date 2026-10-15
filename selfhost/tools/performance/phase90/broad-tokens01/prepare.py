#!/usr/bin/env python3
"""Bind 45 archived B2 C oracles; optionally extract one temporary baseline."""
import argparse, hashlib, json, zipfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]

def pin(p):
    p = Path(p).resolve(); data = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

def prepare(out):
    inputs = {}
    def bind(p, expected=None):
        actual = pin(p)
        if expected: assert all(actual[k] == expected[k] for k in ('sha256', 'bytes')), str(p)
        inputs[actual['file']] = actual
        return actual
    evidence = ROOT/'implementation/phase88/evidence.json'
    receipt = json.loads(evidence.read_text()); bind(evidence)
    archive = bind(ROOT/receipt['archive']['file'], receipt['archive'])
    assert archive['sha256'] == '3ee20c99ea41489e9e2d1b53cfd93ba87234b9e94b03e30777b8128cfb00e7c3'
    sealed_pin = bind(ROOT/receipt['manifest']['file'], receipt['manifest'])
    assert sealed_pin['sha256'] == 'a7420b151807b2606b0434287f5441da3566fd7c8b87d798fabdd505e7ab19e5'
    sealed = {x['file']: x for x in json.loads(Path(sealed_pin['file']).read_text())}
    def retained(relative):
        record = bind(ROOT/relative, sealed[relative])
        return json.loads(Path(record['file']).read_text()), record
    manifest, manifest_pin = retained('selfhost/build/phase88/broad-fixtures03/manifest.json')
    qualified, qualified_pin = retained('selfhost/build/phase88/broad-qualified.json')
    assert qualified['complete'] and qualified['passed'] and qualified['points'] == 45
    assert len(manifest['cases']) == len(qualified['rows']) == 45
    references = {x['id']: x for x in qualified['rows']}
    assert len(references) == 45
    out = out.resolve(); assert out.is_relative_to(ROOT/'selfhost/build/phase90')
    out.mkdir(parents=True, exist_ok=False)
    cases, runs = [], {}
    with zipfile.ZipFile(archive['file']) as capsule:
        for case in manifest['cases']:
            reference = references[case['id']]
            assert reference['exactC'] and reference['exactStdout']
            assert reference['family'] == case['family']
            source = bind(case['source']['file'], case['source'])
            assert source['sha256'] == reference['sourceSha256']
            run = reference['run']; assert run in ('broad01', 'broad02', 'broad03')
            if run not in runs: runs[run] = retained(f'selfhost/build/phase88/{run}/report.json')
            report, report_pin = runs[run]
            previous = next(x for x in report['cases'] if x['id'] == case['id'])
            assert previous['pass_'] and previous['exact'] and previous['executionExact']
            assert previous['source']['sha256'] == source['sha256']
            assert previous['expected'] == case['expected']
            assert all(x['pass_'] for x in previous['jobs'].values())
            old = previous['b2']
            assert old['sha256'] == previous['native']['sha256'] == reference['cSha256']
            member = str(Path(old['file']).relative_to(ROOT))
            assert all(sealed[member][k] == old[k] for k in ('sha256', 'bytes'))
            data = capsule.read(member)
            assert len(data) == old['bytes'] and hashlib.sha256(data).hexdigest() == old['sha256']
            cases.append(dict(name=case['id'], family=case['family'], source=source,
                oracleReceipt=report_pin, baseline=old, expectedStdout=case['expected'],
                baselineOrigin=dict(recorded=old, archive=archive, member=member,
                    transport='sealed-independent-B2-output', priorExecutionExact=True)))
    for item in inputs.values(): assert pin(item['file']) == item
    result = dict(kind='phase90-archived-independent-b2-c-oracles', complete=True,
        executionPerformed=False, method=bind(__file__), archive=archive, sealedManifest=sealed_pin,
        manifest=manifest_pin, qualification=qualified_pin, cases=cases, inputs=list(inputs.values()))
    (out/'manifest.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(manifest=pin(out/'manifest.json'), cases=len(cases), restoredBytes=0, verifiedArchiveBytes=sum(x['baseline']['bytes'] for x in cases))))

def extract(manifest, name, output):
    report = json.loads(manifest.read_text())
    assert report['kind'] == 'phase90-archived-independent-b2-c-oracles' and report['complete']
    assert report['archive']['sha256'] == '3ee20c99ea41489e9e2d1b53cfd93ba87234b9e94b03e30777b8128cfb00e7c3'
    case = next(x for x in report['cases'] if x['name'] == name)
    assert case['baselineOrigin']['archive'] == report['archive']
    assert output.resolve().is_relative_to(ROOT/'selfhost/build/phase90') and not output.exists()
    with zipfile.ZipFile(report['archive']['file']) as capsule:
        data = capsule.read(case['baselineOrigin']['member'])
    assert len(data) == case['baseline']['bytes']
    assert hashlib.sha256(data).hexdigest() == case['baseline']['sha256']
    output.write_bytes(data)
    print(json.dumps(pin(output)))

if __name__ == '__main__':
    ap=argparse.ArgumentParser(description=__doc__);sub=ap.add_subparsers(dest='action',required=True)
    p=sub.add_parser('manifest');p.add_argument('out',type=Path)
    p=sub.add_parser('extract');p.add_argument('manifest',type=Path);p.add_argument('name');p.add_argument('output',type=Path)
    a=ap.parse_args()
    if a.action=='manifest':prepare(a.out)
    else:extract(a.manifest,a.name,a.output)
