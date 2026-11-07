#!/usr/bin/env python3
"""Prepare Phase174 operational selector proposals; never install or run targets."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import assets
import source
from common import changed_inputs, fresh_output, pin, require, verify, write_json


def identity(row):
    return {key: row[key] for key in ('bytes', 'sha256')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--native-build', type=Path, default=ROOT/'selfhost/build/phase174/n2/report.json')
    parser.add_argument('--native-qualification', type=Path, default=ROOT/'selfhost/build/phase174/qbe64/report.json')
    parser.add_argument('--hosted-api', type=Path, default=ROOT/'selfhost/build/phase174/qbe-api/report.json')
    parser.add_argument('--hosted-qualification', type=Path, default=ROOT/'selfhost/build/phase174/qbe-hosted/report.json')
    parser.add_argument('--session-bootstrap', type=Path, default=ROOT/'selfhost/build/phase174/native-session-bootstrap/report.json')
    parser.add_argument('--session-normal', type=Path, default=ROOT/'selfhost/build/phase174/native-session-normal/report.json')
    args = parser.parse_args()
    require(not args.out.exists(), 'Fresh proposal output required')
    inputs = [pin(__file__), pin(assets.__file__), pin(source.__file__),
              pin(ROOT/'selfhost/tools/build/common.py')]
    predecessor = dict(file='selfhost/build/phase170/prepare-selectors.py',
        bytes=8786, sha256='b0bdf4351a6e2733d0e5e7ea2120c0eb5da6354ff638c9d51aaa74e64c502c5f')
    def read(path):
        row = pin(ROOT / path); inputs.append(row)
        document = json.loads(Path(row['file']).read_text())
        require(document.get('complete') is True and not document.get('error')
                and not document.get('changedInputs'), 'Incomplete/changed receipt: ' + str(path))
        return document, row
    def artifact(row):
        verify(row); inputs.append(row); return row
    build, build_pin = read(args.native_build)
    qgate, qgate_pin = read(args.native_qualification)
    api, api_pin = read(args.hosted_api)
    hgate, hgate_pin = read(args.hosted_qualification)
    session, session_pin = read(args.session_bootstrap)
    normal, normal_pin = read(args.session_normal)
    q = build['imageBinding']; h = api['imageBinding']
    recipe = ROOT / 'selfhost/src/compiler.json'
    inputs.append(pin(recipe))
    inventory = json.loads(recipe.read_text())
    modules = [inventory['preamble'], *inventory['modules']]
    entry = inventory['profiles']['qbe'].get('entryModule')
    if entry:
        modules.append(entry)
    for module in dict.fromkeys(modules):
        inputs.append(pin(ROOT / 'selfhost' / module))
    artifact(q['sourceIdentity']); artifact(h['sourceIdentity'])
    require(build['kind'] == 'bend-native-build' and q.get('complete') is True
            and (q['host'], q['stage'], q['protocol']) == ('native', 'N2', 'qbe-source-v1')
            and q['targets'] == ['qbe'] and identity(q['image']) == identity(build['binary']), 'Wrong native lineage')
    require(api['kind'] == 'bend-checked-hosted-api' and api.get('checked') is True
            and h.get('complete') is True and h.get('checked') is True
            and (h['host'], h['stage'], h['protocol']) == ('js', 'B1', 'qbe-api-v1')
            and h['targets'] == ['qbe'] and h['preparationModes'] == ['cache']
            and identity(h['image']) == identity(api['api'])
            and 'p86_prepare' not in h['exports'], 'Wrong hosted lineage/preparation capability')
    canonical = source.maintained_assemble(ROOT / 'selfhost/src/compiler.json', ROOT / 'selfhost', 'qbe')
    current = dict(bytes=len(canonical), sha256=hashlib.sha256(canonical).hexdigest())
    require(current == identity(q['sourceIdentity']) == identity(h['sourceIdentity'])
            and current['sha256'] == '74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a',
            'Images do not bind the final maintained source')
    for report, binding, host, stage in [(qgate, q, 'native', 'N2'), (hgate, h, 'js', 'B1')]:
        require(report['kind'] == 'bend-finite-qualification' and report.get('passed') is True
                and (report['host'], report['stage'], report['target']) == (host, stage, 'qbe')
                and identity(report['image']) == identity(binding['image'])
                and report['counts']['fail'] == report['counts']['unsupported'] == 0
                and report['counts']['pass'] == len(report['selected']), 'Selected QBE qualification differs')
    require(qgate['counts']['pass'] == 64, 'Final native64 qualification required')
    require(session['kind'] == 'bend-native-session-bootstrap-qualification'
            and session.get('passed') is True and session.get('qualified') is True
            and session['protocolUnderTest'] == 'P140/2'
            and session['modeMatchedColdComparisons'] == 6
            and session['generatedProgramOutputs'] == {'a': '3\n', 'b': '5\n'}
            and identity(session['image']) == identity(q['image'])
            and identity(session['source']) == current
            and identity(session['linkedRuntime']) == identity(q['linkedRuntime'])
            and identity(session['originalImageReceipt']) == identity(build_pin), 'Final session gate does not bind this N2')
    require(normal['kind'] == 'bend-experimental-session'
            and identity(normal['request']['image']) == identity(q['image'])
            and len(normal['rows']) == 6, 'Normal session selector gate differs')
    installed = {
        'selfhost/dist/qbe/bend': artifact(q['image']),
        'selfhost/dist/qbe/hosted-api.mjs': artifact(h['image']),
        'selfhost/dist/qbe/evidence/qbe-qualified.json': qgate_pin,
        'selfhost/dist/qbe/evidence/qbe-hosted-acquisition.json': api_pin,
        'selfhost/dist/qbe/evidence/qbe-hosted-qualified.json': hgate_pin,
        'selfhost/dist/qbe/evidence/qbe-session-bootstrap.json': session_pin,
        'selfhost/dist/qbe/evidence/qbe-session-normal.json': normal_pin,
    }
    def destination(name):
        return dict(installed[name], file=name)
    native_metadata = dict(host='native', stage='N2', targets=['qbe'], protocol='qbe-source-v1',
        sourceIdentity=current, linkedRuntime=identity(artifact(q['linkedRuntime'])),
        preparationModes=['cache', 'live'], sessionProtocols=['P140/2'],
        qualificationReceipt=destination('selfhost/dist/qbe/evidence/qbe-qualified.json'),
        sessionQualification=destination('selfhost/dist/qbe/evidence/qbe-session-bootstrap.json'),
        sessionScope='Qualified positive native P140/2 byte batches; no native recovery or object-unit claim.',
        qualification='Installed final Phase174 native N2; exact native64 and positive session gates.')
    hosted_metadata = dict(host='js', stage='B1', targets=['qbe'], protocol='qbe-api-v1', checked=True,
        sourceIdentity=current, exports=h['exports'], preparationModes=['cache'],
        acquisitionReceipt=destination('selfhost/dist/qbe/evidence/qbe-hosted-acquisition.json'),
        qualificationReceipt=destination('selfhost/dist/qbe/evidence/qbe-hosted-qualified.json'),
        qualification='Installed upstream-checked B1 cursor API; cache-only, with its own hosted QBE gate.')
    proposals = {}; originals = {}
    for name in ('assets-native.json', 'assets-session.json', 'assets-c-request.json'):
        path = ROOT / 'selfhost/manifests' / name
        original = json.loads(path.read_text()); originals[name] = pin(path); inputs.append(originals[name])
        require(original['kind'] == 'bend-build-assets' and original['complete'] is True, 'Invalid current asset map')
        require(set(original['images']['qbe-api'].get('exports', [])) <= set(h['exports']),
                'Operational hosted API would lose an existing export')
        require(identity(original['assets']['qbe-runtime']) == identity(q['linkedRuntime']),
                'Candidate linked runtime differs from existing qualified runtime')
        document = copy.deepcopy(original)
        document['assets']['qbe-n2'] = dict(destination('selfhost/dist/qbe/bend'), executable=True)
        document['assets']['qbe-api'] = destination('selfhost/dist/qbe/hosted-api.mjs')
        document['images']['qbe-n2'] = native_metadata
        document['images']['qbe-api'] = hosted_metadata
        # Only these four selector rows may change. Providers/Base/toolchain and
        # historical operationalParent provenance remain untouched.
        restored = copy.deepcopy(document)
        for section in ('assets', 'images'):
            for key in ('qbe-n2', 'qbe-api'):
                restored[section][key] = original[section][key]
        require(restored == original, 'Unrelated operational asset mutation')
        proposals[name] = document
    require(not changed_inputs(inputs), 'Inputs changed while preparing selectors')
    args.out = fresh_output(args.out, ROOT)
    for name, document in proposals.items():
        write_json(args.out / name, document)
    write_json(args.out / 'installable-files.json', installed)
    write_json(args.out / 'report.json', dict(kind='phase174-operational-selectors-proposal', complete=True,
        installed=False, targetsRun=False, sourceIdentity=current, originalManifests=originals,
        predecessor=predecessor,
        proposedManifests={name: pin(args.out / name) for name in proposals}, inputs=inputs,
        changedRows=['assets.qbe-n2', 'assets.qbe-api', 'images.qbe-n2', 'images.qbe-api'],
        installableFiles=installed, preparationModes={'qbe-n2': ['cache', 'live'], 'qbe-api': ['cache']},
        scope='Fresh proposals only. Root installs exact artifacts/evidence, then publishes manifests and verifies defaults.'))
    print(json.dumps(dict(complete=True, installed=False, output=str(args.out))))


if __name__ == '__main__':
    main()
