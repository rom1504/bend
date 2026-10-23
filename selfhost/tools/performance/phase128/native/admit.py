"""Authenticate checked source and finite contracts before native acquisition."""
import argparse
import json
from pathlib import Path

from prepare import pin, read, verify, require, unique


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['source-manifest', 'api-report', 'finite-report', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists(), 'Fresh receipt required')
    sm, api, finite = map(read, [a.source_manifest, a.api_report, a.finite_report])
    require(sm['kind'] == 'phase128-native-entry-source' and sm['complete'], 'Wrong source binding')
    require(sm['inverseByteIdentity'] and sm['allOtherBytesUnchanged'], 'Entry identity absent')
    require(api['complete'] and api['checked'] and api['status'] == 0, 'Unchecked wired source')
    require(sm['source'] in api['inputs'], 'API/source mismatch')
    require(set(sm['requiredNextExports']) <= set(api['exports']), 'Missing checked entries')
    require(finite['complete'] and finite['source'] == sm['source'], 'Controls/source mismatch')
    require(finite['sourceManifest'] == pin(a.source_manifest), 'Controls/binding mismatch')
    expected = dict(p128bs_controls=12, p128br_call_controls=10, p128bl_controls=7,
                    p128bi_controls=15, p128rf_controls=20, p128raw_controls=11,
                    p128raw_br_controls=4)
    actual = {r['name']:r for r in finite['groups']}
    for name, count in expected.items():
        row = actual[name]
        require(row['complete'] and len(row['rows']) == count and
                all(x.endswith(':pass') for x in row['rows']), 'Failed contracts '+name)
    pending = sm['runtimeContract']
    require(pending['source'] == sm['source'] and pending['runtime'] == sm['runtime'], 'Runtime/source mismatch')
    inputs = unique([pin(__file__), pin(Path(__file__).with_name('prepare.py')),
        pin(a.source_manifest), pin(a.api_report), pin(a.finite_report),
        sm['source'], api['api'], sm['runtime'], sm['runtimeReport'],
        *sm['inputs'], *api['inputs'], *finite['inputs']])
    for row in inputs:
        verify(row)
    report = dict(kind='phase128-checked-native-acquisition-admission', complete=True,
        sourceChecked=True, finitePredicates=sum(expected.values()),
        source=sm['source'], api=api['api'], runtime=sm['runtime'],
        runtimeContract=pending, sourceBinding=pin(a.source_manifest),
        checkedApi=pin(a.api_report), controls=pin(a.finite_report), inputs=inputs,
        nativeQualified=False, installed=False, selected=False,
        scope='Checked source and independently audited runtime contracts permit acquisition. This is not native self-reproduction, ordinary conformance, or performance qualification. Original source entry error controls also have the separately frozen pre-wiring comparison.')
    a.out.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(complete=True, source=sm['source'], finitePredicates=report['finitePredicates'])))


if __name__ == '__main__':
    main()
