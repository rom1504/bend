#!/usr/bin/env python3
"""Bounded object reuse gates. This DOES execute tools/programs; run under guard."""
import argparse
import copy
import json
from pathlib import Path
from types import SimpleNamespace
import sys
import os
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import fresh_output, pin, require, run, verify, workspace, write_json
import assets
sys.path.insert(0, str(HERE))
import objects


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--workspace', type=Path); p.add_argument('--assets', type=Path, required=True)
    p.add_argument('--session', type=Path, required=True); p.add_argument('--out', type=Path, required=True)
    p.add_argument('--seconds', type=float, default=60); a = p.parse_args()
    root = workspace(a.workspace); prior_pin = pin(a.session); prior = json.loads(a.session.read_text())
    require(prior.get('complete') is True and prior.get('kind') == 'bend-experimental-hosted-session', 'Completed session needed')
    rows = {row['name']: row for row in prior['rows']}
    require(all(name in rows and rows[name].get('unitFrames') for name in ['cold-a', 'noop-a', 'edit-b']), 'Framed semantic controls required')
    verify(prior['request']); request = json.loads(Path(prior['request']['file']).read_text()); producer = Path(request['image']['file'])
    verify(request['image']); out = fresh_output(a.out, root); cache = out / 'cache'
    report = dict(kind='bend-session-object-controls', version=1, complete=False, experimental=True,
                  session=prior_pin, method=pin(__file__), rows=[], identityControls=[],
                  scope='Three scalar source products, exact object admission, and one corrupt-object refusal; no benchmark claim.')
    def save(): write_json(out / 'report.json', report)
    def build(name, row, cold=False):
        for key in ['source', 'product', 'unitFrames']: verify(row[key])
        result = objects.build(SimpleNamespace(workspace=root, assets=a.assets, stream=Path(row['unitFrames']['file']),
          out=out / name, cache=cache, producer=producer, source=Path(row['source']['file']), runtime_key='qbe-runtime',
          policy_salt='', expected=Path(row['product']['file']), seconds=a.seconds, max_unit_bytes=67108864,
          cold=cold, retain_units=False))
        report['rows'].append(dict(name=name, complete=result['complete'], receipt=pin(out / name / 'report.json'))); save()
        return result
    save()
    try:
        first = build('cold', rows['cold-a'], True); require(first['complete'], first.get('error', 'Cold build failed'))
        noop = build('noop', rows['noop-a']); require(noop['complete'], noop.get('error', 'No-op build failed'))
        edit = build('edit', rows['edit-b']); require(edit['complete'], edit.get('error', 'Edited build failed'))
        require(first['builtUnits'] > 0 and first['reusedUnits'] == 0, 'Cold cache not empty')
        require(noop['builtUnits'] == 0 and noop['reusedUnits'] == len(first['units']), 'No-op did not reuse every object')
        require(edit['builtUnits'] > 0 and edit['reusedUnits'] > 0, 'Real edit must exercise both hit and miss')
        for label, product, expected in [('cold', first, b'3\n'), ('noop', noop, b'3\n'), ('edit', edit, b'5\n')]:
            provider = product['context']
            require(assets.runtime_argument_convention(provider) != 'bend-rts-v1' or 'BENDRTS' not in os.environ,
                    'Explicit RTS execution requires ambient BENDRTS to be unset')
            process = run([product['binary']['file'], *assets.runtime_arguments(provider)], cwd=root,
                          stdout=out / (label + '.stdout'), stderr=out / (label + '.stderr'), seconds=a.seconds)
            require(process['complete'] and process['stderr']['bytes'] == 0, 'Generated program failed')
            require(Path(process['stdout']['file']).read_bytes() == expected, 'Independent scalar output mismatch')
            report.setdefault('programs', []).append(dict(name=label, expected=expected.decode(), process=process))
        base = first['context']; unit = first['units'][0]
        original_key = objects.key(base, unit['kind'], unit['payload'])
        require(original_key == unit['key'] and 'source' not in base, 'Unexpected source participation in object identity')
        for field in ['producer', 'runtime', 'tools', 'flags', 'methods', 'policySalt']:
            changed = copy.deepcopy(base); changed[field] = dict(changedIdentity=True, original=changed[field])
            require(objects.key(changed, unit['kind'], unit['payload']) != original_key, 'Changed identity collided: ' + field)
            report['identityControls'].append(field)
        for label, kind, payload in [('kind', (unit['kind'] + 1) % 3, unit['payload']),
                                     ('payload', unit['kind'], dict(unit['payload'], sha256='0' * 64))]:
            require(objects.key(base, kind, payload) != original_key, 'Changed unit identity collided')
            report['identityControls'].append(label)
        obj = Path(unit['object']['file']); saved = obj.read_bytes()
        try:
            obj.write_bytes(bytes([saved[0] ^ 1]) + saved[1:])
            refused = build('corrupt', rows['cold-a'])
            require(not refused['complete'] and 'Changed input' in refused.get('error', ''), 'Corrupt cached object accepted')
        finally:
            obj.write_bytes(saved)
        verify(unit['object']); verify(prior_pin); report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        save()
    print(json.dumps({k: report.get(k) for k in ['complete', 'error']}))
    return 0 if report['complete'] else 1


if __name__ == '__main__': sys.exit(main())
