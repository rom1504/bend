"""Compute breadth and compiler cost from the authenticated Phase199 run."""
import hashlib
import json
import math
from pathlib import Path
from statistics import geometric_mean

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / 'selfhost/build/phase198'

def read(path):
    return json.loads(path.read_bytes())

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def compare(rows, role, reference):
    ratios = [c['medianMs'][role] / c['medianMs'][reference] for c in rows]
    groups = {}
    for c, ratio in zip(rows, ratios):
        g = groups.setdefault(c['family'], {'ratios': [], 'ms': 0, 'referenceMs': 0})
        g['ratios'].append(ratio)
        g['ms'] += c['fixedEquivalentMs'][role]
        g['referenceMs'] += c['fixedEquivalentMs'][reference]
    families = []
    for family, g in groups.items():
        families.append({'family': family, 'cases': len(g['ratios']),
                         'ratio': geometric_mean(g['ratios']),
                         'excessMs': g['ms'] - g['referenceMs']})
    seconds = sum(c['fixedEquivalentMs'][role] for c in rows) / 1000
    ref = sum(c['fixedEquivalentMs'][reference] for c in rows) / 1000
    return {'cases': len(rows), 'geomean': geometric_mean(ratios),
            'familyGeomean': geometric_mean(g['ratio'] for g in families),
            'meanPositiveLog': sum(max(0, math.log(v)) for v in ratios) / len(ratios),
            'over1p1': sum(v > 1.1 for v in ratios), 'over2': sum(v > 2 for v in ratios),
            'fixedEquivalentSeconds': seconds, 'referenceSeconds': ref,
            'fixedRatio': seconds / ref, 'families': sorted(families, key=lambda g: -g['excessMs'])}

def main():
    summary = ROOT / 'research/phase199/broad/integrated-summary01.json'
    result = read(summary)
    raw_file = Path(result['report']['file'])
    assert digest(raw_file) == result['report']['sha256']
    raw = read(raw_file)
    family = {c['id']: c['family'] for c in raw['cases']}
    rows = [dict(c, family=family[c['id']]) for c in result['cases'] if c['ratioEligible']]
    assert raw['complete'] and result['oracleRevalidated']['samples'] == 405 and len(rows) == 44 and len(family) == 45
    out = {'summarySha256': digest(summary), 'timingSha256': digest(raw_file), 'sets': {}}
    for name, chosen in [('all', rows), ('excludingAbsorbingScalar', [c for c in rows if c['id'] != 'scalar-region-8192']),
                         ('excludingFold', [c for c in rows if c['family'] != 'local-fold'])]:
        out['sets'][name] = {f'{r}/{b}': compare(chosen, r, b) for r,b in
                             [('candidate','c'), ('baseline','c'), ('candidate','baseline')]}
    out['compilation'] = {}
    for name, folder in [('progress','progress-native45-01'), ('integrated','p199-integrated-native45-01')]:
        base = BUILD / folder
        report = read(base/'report.json')
        programs = [read(f) for f in base.glob('*/machine/report.json')]
        assert report['complete'] and len(programs) == 45 and all(j['complete'] for j in programs)
        out['compilation'][name] = {'catalogSeconds': report['seconds'],
                                    'emissionSeconds': sum(p['emissionSeconds'] for p in programs),
                                    'catalogReceiptSha256': digest(base/'report.json')}
    target = Path(__file__).with_name('impact.json')
    with target.open('x') as f:
        json.dump(out, f, indent=2)
        f.write('\n')

if __name__ == '__main__':
    main()
