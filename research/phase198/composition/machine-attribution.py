"""Partition the actual full-suite timing by whether the optimizer changed the loaded code."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
from statistics import geometric_mean

HERE = Path(__file__).resolve().parent
layout = runpy.run_path(str(HERE.parent / 'qualification/compare-source-products.py'))['loaded_layout']


def authenticate(pin):
    path = Path(pin['file'])
    data = path.read_bytes()
    assert len(data) == pin['bytes'] and hashlib.sha256(data).hexdigest() == pin['sha256'], path
    return path


def analyse(receipt):
    run = json.loads(receipt.read_bytes())
    assert run['complete'] and run['fullCatalog'] and not run['changedInputs']
    suite = run['inputs'][0]
    manifest = json.loads(authenticate(suite).read_bytes())
    assert manifest['roles'] == run['roles']
    sources = {case['id']: case for case in manifest['cases']}
    partitions = {'changed': [], 'identical': []}
    for case in run['cases']:
        products = sources[case['id']]['products']
        a, b = products['phase197'], products['candidate']
        objects = [authenticate(p['generatedSource']) for p in [a, b]]
        binaries = [authenticate(p['artifact']) for p in [a, b]]
        identical = objects[0].read_bytes() == objects[1].read_bytes()
        assert identical == (layout(binaries[0]) == layout(binaries[1])), case['id']
        s = case['summary']
        times = {role: row['medianMs'] for role, row in s['stats'].items()}
        partitions['identical' if identical else 'changed'].append({
            'case': case['id'], 'timed': s['ratioEligible'],
            'originalRuntimeOverPhase197': times['candidate'] / times['phase197'] if s['ratioEligible'] else None,
            'liveOverPhase197': times['live'] / times['phase197'] if s['ratioEligible'] else None,
            'objects': [p['generatedSource']['sha256'] for p in [a, b]],
        })
    result = {'runSHA256': hashlib.sha256(receipt.read_bytes()).hexdigest(), 'manifest': suite, 'byIdentity': {}}
    for key, rows in partitions.items():
        timed = [r for r in rows if r['timed']]
        result['byIdentity'][key] = {
            'count': len(rows), 'timed': len(timed),
            'originalRuntimeOverPhase197': geometric_mean(x['originalRuntimeOverPhase197'] for x in timed),
            'liveOverPhase197': geometric_mean(x['liveOverPhase197'] for x in timed),
            'cases': rows,
        }
    timed = [case['summary']['stats'] for case in run['cases'] if case['summary']['ratioEligible']]
    result['byRoundLiveOverC'] = [geometric_mean(x['live']['samplesMs'][i] / x['c']['samplesMs'][i] for x in timed) for i in range(run['rounds'])]
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('receipt', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    result = analyse(args.receipt)
    with args.output.open('x') as out:
        json.dump(result, out, indent=2)
        out.write('\n')
