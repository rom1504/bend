#!/usr/bin/env python3
"""Archive immutable Phase96 evidence, validate receipts, and count serial work."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase96'


def read(path): return json.loads(path.read_text())


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path),
                bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(item):
    result = pin(ROOT / item['file'])
    assert all(item[key] == result[key] for key in ['bytes', 'sha256']), item['file']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/tools/laws/phase96')
    out.mkdir(parents=True, exist_ok=False)
    audit, fast = read(RAW/'audit01/report.json'), read(RAW/'fast01/report.json')
    for report in [audit, fast]:
        assert report['complete'] and report['inputsUnchanged']
        for item in report['inputs']: verify(item)
    for name in ['algebra', 'representation']:
        report = read(RAW/'audit01'/name/'report.json')
        assert report['complete'] and report['independentlyChecked']
        for item in report['inputs']: verify(item)
        assert len(report['lawBindings']) == len(report['lawNames'])
        for source in report['sourceClosure']: verify(source['snapshot'])
    proofs = [read(RAW/'audit01'/name/'report.json') for name in ['algebra-negatives', 'representation-negatives']]
    assert all(p['complete'] for p in proofs)
    assert sum(p['rejectedCases'] for p in proofs) == 16
    mutant_reports = sorted((RAW/'audit01').glob('mutation-*/report.json'))
    assert len(mutant_reports) == 10
    for file in mutant_reports:
        report = read(file); assert report['complete'] and report['rejectedWitness']
        result = read(Path(report['execution']['file'])); assert result['complete'] and result['inputsUnchanged']
        row = next(r for r in result['rows'] if r['id'] == report['rejectedWitness'])
        assert not row['passed'] and row['actual'] != row['expected']
    native = read(RAW/'audit01/production-native/report.json')
    assert native['complete'] and native['cases'] == 32
    verify(native['expected']); verify(native['actual'])
    assert native['expected']['sha256'] == native['actual']['sha256']
    execution = read(RAW/'audit01/production/execution/report.json')
    assert execution['complete'] and execution['passed'] and execution['inputsUnchanged']
    assert len(execution['rows']) == 226 and all(r['passed'] for r in execution['rows'])
    ledger = []
    for file in sorted(RAW.rglob('process.json')):
        receipt = read(file)
        assert 'finished' in receipt and 'returncode' in receipt, file
        ledger.append(dict(receipt=pin(file), **receipt))
    ledger.sort(key=lambda r:r['started'])
    overlaps = [(a['receipt']['file'], b['receipt']['file']) for a,b in zip(ledger,ledger[1:]) if a['finished'] > b['started']]
    assert not overlaps, overlaps
    assert not any(row.get('stoppedFor') for row in ledger)
    summary = dict(complete=True, publicLaws=31, supportingLemmas=7, finiteFamilies=16,
                   finiteJSCases=226, nativeCases=32, proofRejectionControls=16,
                   wellFormedMutantHelperAdmissions=11, executableMutants=10,
                   fastSeconds=fast['wallSeconds'], auditSeconds=audit['wallSeconds'],
                   guardedJobs=len(ledger), targetOccupancySeconds=sum(r['wallSeconds'] for r in ledger),
                   targetSpanSeconds=ledger[-1]['finished']-ledger[0]['started'],
                   peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in ledger),
                   overlaps=overlaps, stoppedJobs=0, productionChanged=False,
                   method=pin(__file__), audit=pin(RAW/'audit01/report.json'), fast=pin(RAW/'fast01/report.json'))
    (out/'execution-ledger.json').write_text(json.dumps(ledger,indent=2)+'\n')
    # Keep failed attempts and old frozen methods. External toolchains/images are
    # represented by their recorded pins, not redundantly copied into the capsule.
    files = sorted(p for p in RAW.rglob('*') if p.is_file() and '__pycache__' not in p.parts)
    inventory = [pin(file) for file in files]
    archive = out/'raw-evidence.zip'
    with zipfile.ZipFile(archive, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for file,item in zip(files,inventory): z.write(file,item['file'])
    with zipfile.ZipFile(archive) as z:
        assert len(z.namelist()) == len(inventory)
        for item in inventory:
            data=z.read(item['file'])
            assert len(data)==item['bytes'] and hashlib.sha256(data).hexdigest()==item['sha256']
            verify(item)
    (out/'archive-members.json').write_text(json.dumps(inventory,indent=2)+'\n')
    summary.update(archive=pin(archive), archivedFiles=len(inventory), archivedBytes=sum(x['bytes'] for x in inventory), archiveReadbackVerified=True)
    (out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps(summary))


if __name__ == '__main__': main()
