#!/usr/bin/env python3
"""Root-only serial execution of the unchanged, guarded observer query controller."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path


def check_pin(pin):
    data = Path(pin['file']).read_bytes()
    assert len(data) == pin['bytes']
    assert hashlib.sha256(data).hexdigest() == pin['sha256'], pin['file']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest', type=Path)
    parser.add_argument('--groups', default='core,demand,boundary')
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text())
    groups = set(args.groups.split(','))
    assert groups <= {'core', 'demand', 'boundary'} and groups
    pins = [manifest[key] for key in ('api', 'controller', 'guard', 'node')]
    pins += manifest['inputs'] + [job['sourcePin'] for job in manifest['jobs']]
    for pin in pins:
        check_pin(pin)
    out = args.manifest.parent / ('execution-' + '-'.join(sorted(groups)) + '.json')
    assert not out.exists(), out
    result = dict(kind='phase70-observer-query-batch-result-v1', complete=False,
                  manifestSha256=hashlib.sha256(args.manifest.read_bytes()).hexdigest(),
                  groups=sorted(groups), rows=[])

    def save():
        out.write_text(json.dumps(result, indent=2) + '\n')

    save()
    try:
        for job in manifest['jobs']:
            if job['group'] not in groups:
                continue
            assert not Path(job['output']).exists(), job['output']
            result['running'] = job['id']
            save()
            process = subprocess.run(job['command'], check=False)
            report = json.loads((Path(job['output']) / 'report.json').read_text())
            assert process.returncode == 0 and report['complete'], job['id']
            records = report['records']
            assert len(records) == 2 and not records[0]['permission'] and records[1]['permission']
            assert all(row['requested'] == job['owner'] for row in records)
            assert not records[0]['accepted']
            accepted = records[1]['accepted']
            status = ('missed-admission' if job['expected'] == 'admit' and not accepted else
                      'unexpected-admission' if job['expected'] == 'decline' and accepted else
                      'needs-demand-oracle' if job['expected'] == 'preserve-or-decline' and accepted else
                      'diagnostic-only' if job['expected'] == 'diagnostic-only' else 'as-expected')
            result['rows'].append(dict(id=job['id'], expected=job['expected'], accepted=accepted,
                status=status, error=records[1]['error'], report=str(Path(job['output'])/'report.json'),
                effectsSafe=report['entry']['effectsSafe']))
            del result['running']
            save()
        for pin in pins:
            check_pin(pin)
        result['inputsUnchanged'] = True
        result['complete'] = True
    except BaseException as error:
        result['error'] = repr(error)
        save()
        raise
    save()
    print(json.dumps(result))


if __name__ == '__main__':
    main()
