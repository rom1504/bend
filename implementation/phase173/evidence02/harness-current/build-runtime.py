#!/usr/bin/env python3
"""Execute a frozen diagnostic runtime/relink plan inside a resource guard."""
import argparse
import json
import os
from pathlib import Path
import time

from run import pin, verify, save, execute


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    plan = json.loads(args.plan.read_text())
    assert plan['complete'] and plan['reverseExact'] and not plan['compiled']
    assert plan['schema'] == 'bend-native-profile-runtime-plan-v1'
    for item in plan['inputs'] + plan['outputs']:
        verify(item)
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, plan=pin(args.plan), method=pin(__file__), jobs=[], started=time.time())
    save(out/'report.json', report)
    try:
        for index, job in enumerate(plan['jobs']):
            row = execute(job['command'], out/f'{index}-{job["label"]}', str(args.plan.resolve().parent),
                          60, dict(os.environ))
            row['label'] = job['label']; report['jobs'].append(row)
            if row['returncode'] or row['timedOut']:
                raise ValueError('Diagnostic build failed: ' + job['label'])
            target = Path(job['command'][job['command'].index('-o') + 1])
            row['product'] = pin(target)
            save(out/'report.json', report)
        report.update(complete=True, products=[row['product'] for row in report['jobs']])
    except BaseException as error:
        report['error'] = str(error)
        raise
    finally:
        report['finished'] = time.time()
        save(out/'report.json', report)
    print(json.dumps(dict(complete=True, report=pin(out/'report.json'), products=report['products'])))


if __name__ == '__main__':
    main()
