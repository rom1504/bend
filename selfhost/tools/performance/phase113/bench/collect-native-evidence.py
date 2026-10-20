#!/usr/bin/env python3
"""Collect exact small JSON receipts and a hash ledger; never copy products."""
import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('native_plan_tools', HERE/'prepare-native-plan.py')
tool = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tool)
ROOT, pin, read = tool.ROOT, tool.pin, tool.read


def references(value):
    if isinstance(value, dict):
        if (isinstance(value.get('file'), str) and isinstance(value.get('bytes'), int)
                and isinstance(value.get('sha256'), str)):
            yield value
        for item in value.values():
            yield from references(item)
    elif isinstance(value, list):
        for item in value:
            yield from references(item)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--extra-json', type=Path, action='append', default=[])
    p.add_argument('--extra-tree', type=Path, action='append', default=[])
    p.add_argument('--max-json-mib', type=int, default=2)
    p.add_argument('--max-total-mib', type=int, default=32)
    a = p.parse_args()
    if a.out.exists() or min(a.max_json_mib, a.max_total_mib) <= 0:
        raise ValueError('Fresh output and positive receipt size limits required')
    plan = read(a.plan)
    if plan.get('kind') != 'phase113-native-qualification-plan':
        raise ValueError('Native qualification plan required')
    for row in plan['inputs']:
        tool.verify(row)
    artifacts = {name:Path(path).resolve() for name,path in plan['artifacts'].items()}
    report_paths = {name:artifacts[name]/('process.json' if name == 'guard' else 'report.json')
                    for name in ['hosted','n1','n1Focused','self','n2Focused','n2Full45','jobs','guard']}
    required = [a.plan.resolve(), *report_paths.values(),
                artifacts['self']/'build/report.json', artifacts['comparison']]
    required += [Path(plan[name]['file']) for name in ['sourceManifest','apiReport','runtimeReport']]
    required += [path.resolve() for path in a.extra_json]
    trees = [path for name,path in artifacts.items() if name != 'comparison'] + [x.resolve() for x in a.extra_tree]
    if any(a.out.resolve().is_relative_to(path) for path in trees):
        raise ValueError('Capsule output must be outside scanned artifact trees')
    candidates = set(required)
    for tree in trees:
        if tree.is_dir():
            candidates.update(tree.rglob('*.json'))
    missing = [str(path) for path in required if not path.is_file()]
    selected, excluded, ledger, total = [], [], {}, 0
    values = {}
    for path in sorted(candidates):
        if not path.is_file():
            continue
        if path.suffix != '.json':
            raise ValueError('Only JSON evidence can be copied: '+str(path))
        info = pin(path)
        if info['bytes'] > a.max_json_mib*1024*1024 or total+info['bytes'] > a.max_total_mib*1024*1024:
            excluded.append(dict(input=info, reason='Frozen JSON size limit; hash only'))
            continue
        raw = path.read_bytes()
        if len(raw) != info['bytes'] or hashlib.sha256(raw).hexdigest() != info['sha256']:
            raise ValueError('Receipt changed during collection: '+str(path))
        value = json.loads(raw)
        values[str(path)] = value
        relative = path.relative_to(ROOT).as_posix() if path.is_relative_to(ROOT) else 'external/'+info['sha256']+'/'+path.name
        selected.append((dict(input=info, member='receipts/'+relative), raw))
        total += len(raw)
        for row in [info, *references(value)]:
            target = (ROOT/row['file']).resolve()
            normalized = dict(file=str(target), bytes=row['bytes'], sha256=row['sha256'])
            ledger[(str(target), row['bytes'], row['sha256'])] = normalized
    actual = {}
    for row in ledger.values():
        path = Path(row['file'])
        if row['file'] not in actual:
            actual[row['file']] = pin(path) if path.is_file() else None
        found = actual[row['file']]
        row['status'] = ('missing-external-dependency' if found is None else
                         'verified' if all(found[key] == row[key] for key in ['bytes','sha256']) else
                         'changed-external-dependency')
        if found is not None and row['status'] != 'verified':
            row['current'] = found
    gates = {}
    for name in ['hosted','n1','n1Focused','self','n2Focused','n2Full45','jobs','guard']:
        report = values.get(str(report_paths[name]), {})
        passed = report.get('complete') is True
        if name in ['n1Focused','n2Focused','n2Full45']:
            passed = passed and report.get('passed') is True
        gates[name] = passed
    comparison = values.get(str(artifacts['comparison']), {})
    gates['exactQbe'] = comparison.get('complete') is True and comparison.get('byteExact') is True
    gates['n2Build'] = values.get(str(artifacts['self']/'build/report.json'), {}).get('complete') is True
    a.out.mkdir(parents=True)
    archive = a.out/'receipts.tar.gz'
    with tarfile.open(archive, 'w:gz') as tar:
        for item, raw in selected:
            member = tarfile.TarInfo(item['member'])
            member.size, member.mode, member.mtime = len(raw), 0o644, 0
            tar.addfile(member, io.BytesIO(raw))
    result = dict(kind='phase113-native-receipt-capsule', version=1,
                  complete=not missing and not excluded, targetsRun=False,
                  createdUtc=datetime.now(timezone.utc).isoformat(), method=pin(__file__), plan=pin(a.plan),
                  archive=pin(archive), receiptCount=len(selected), rawReceiptBytes=total,
                  limits=dict(singleJsonMiB=a.max_json_mib,totalJsonMiB=a.max_total_mib),
                  qualificationPassed=all(gates.values()), qualificationGates=gates,
                  missingRequiredReceipts=missing, excludedJson=excluded,
                  receipts=[row for row,raw in selected], references=list(ledger.values()),
                  externalReferencesAllVerified=all(row['status']=='verified' for row in ledger.values()),
                  scope='Exact JSON receipt bytes only. Compiler source/API, QBE, native images, runtime, tools, source/oracle files and stdout/stderr are external hash references, not archived products. Capsule completeness does not imply qualification or availability of every historical dependency. Absolute original paths are retained; replay requires matching external files or separately authenticated archives.')
    (a.out/'manifest.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(manifest=pin(a.out/'manifest.json'), archive=pin(archive),
                         complete=result['complete'], qualificationPassed=result['qualificationPassed'],
                         receiptCount=len(selected), missingRequiredReceipts=len(missing),
                         unverifiedExternalReferences=sum(row['status']!='verified' for row in ledger.values()))))


if __name__ == '__main__':
    main()
