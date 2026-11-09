#!/usr/bin/env python3
"""Publish exactly three prepared Phase183 asset maps after release installation.

No compiler or program executes. Each replacement is atomic; a failed transaction
restores the three original byte streams from separately retained local backups.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT/'selfhost/tools/build'
sys.path.insert(0, str(BUILD))
import assets
import release
from common import changed_inputs, fresh_output, pin, require, verify, write_json

PREPARE = Path(__file__).with_name('prepare-release.py')
spec = importlib.util.spec_from_file_location('phase183_asset_preparation', PREPARE)
preparation = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preparation)
MAPS = preparation.MAPS


def read_pin(row, root):
    file = verify(dict(row, file=str(root/row['file'])))
    return json.loads(file.read_text())


def transaction(out, destinations, originals, proposed, rollback, protected, validate, metadata=None):
    """Stage and verify every byte before replacing the first map."""
    report = dict(kind='phase183-operational-assets-publication', version=1, complete=False,
                  targetsRun=False, mutations=[], rollback=False, originals=originals,
                  proposed=proposed, inputs=protected)
    report.update(metadata or {})
    staged, backups = {}, {}
    for name in MAPS:
        require(os.stat(out).st_dev == os.stat(destinations[name].parent).st_dev,
                'Asset staging and destination must share a filesystem')
        staged[name], backups[name] = out/('stage-'+name), out/('backup-'+name)
        shutil.copyfile(verify(proposed[name]), staged[name])
        shutil.copyfile(verify(rollback[name]), backups[name])
        require(release.same(pin(staged[name]), proposed[name])
                and release.same(pin(backups[name]), originals[name]), 'Staged asset/backup differs: '+name)
    report['backups'] = {name: pin(file) for name, file in backups.items()}
    write_json(out/'report.json', report)
    try:
        require(not changed_inputs(protected), 'Protected publication inputs changed')
        for name in MAPS:
            require(pin(destinations[name]) == originals[name], 'Original asset map changed: '+name)
        validate()
        for name in MAPS:
            # Record intent before replacement so even an interrupted rename is
            # covered by restoration of all three preverified original streams.
            report['mutations'].append(name)
            write_json(out/'report.json', report)
            os.replace(staged[name], destinations[name])
        validate()
        require(not changed_inputs(protected), 'Protected publication inputs changed')
        for name in MAPS:
            require(release.same(pin(destinations[name]), proposed[name]), 'Published asset map differs: '+name)
        report['published'] = {name: pin(file) for name, file in destinations.items()}
        report['complete'] = True
        write_json(out/'report.json', report)
    except BaseException as error:
        report['complete'] = False
        report['error'] = repr(error)
        if report['mutations']:
            failures = {}
            for name in MAPS:
                try:
                    restore = out/('restore-'+name)
                    shutil.copyfile(verify(report['backups'][name]), restore)
                    os.replace(restore, destinations[name])
                    require(pin(destinations[name]) == originals[name], 'Restored bytes differ')
                except BaseException as restore_error:
                    failures[name] = repr(restore_error)
            report['rollback'] = not failures
            if failures: report['rollbackErrors'] = failures
        write_json(out/'report.json', report)
    return report


def publish(proposal_report, output, root=ROOT):
    protected = [pin(__file__), pin(PREPARE), pin(release.__file__), pin(assets.__file__), pin(BUILD/'common.py')]
    report_pin = pin(proposal_report); protected.append(report_pin)
    prepared = read_pin(report_pin, root)
    require(prepared.get('kind') == 'phase183-release-preparation' and prepared.get('version') == 1
            and prepared.get('complete') is True and prepared.get('releaseAudited') is True
            and prepared.get('installed') is False and prepared.get('targetsRun') is False,
            'Completed audited Phase183 preparation report required')
    for key in ('originalManifests', 'proposedManifests', 'rollbackManifests'):
        require(set(prepared[key]) == set(MAPS), 'Exactly three maintained asset maps required: '+key)
    proposal = read_pin(prepared['proposal'], root)
    protected += [prepared['proposal'], prepared['audit']]
    selector = root/'selfhost/manifests/current.json'
    verification = release.installed(selector, root)
    selector_pin = pin(selector); protected.append(selector_pin)
    current = json.loads(selector.read_text())
    installed_audit = read_pin(current['provenance'], root)
    require(release.same(current['provenance'], prepared['audit'])
            and installed_audit['promotion'] == prepared['proposal'],
            'Installed release is not the exact prepared audited promotion')
    selected = dict(current)
    selected.pop('provenance', None); selected.pop('gateStatus', None)
    selected['files'] = {name: row for name, row in current['files'].items() if name != preparation.AUDIT_NAME}
    require(selected == proposal['bindings'], 'Installed selector differs from prepared release')
    protected.append(dict(current['provenance'], file=str(root/current['provenance']['file'])))
    n2_gate = proposal['gates'][proposal['x86Qualification']['n2']]['report']
    n2 = read_pin(n2_gate, root); protected.append(n2_gate)
    destinations, originals, proposed, rollback = {}, {}, {}, {}
    for name in MAPS:
        destination = root/'selfhost/manifests'/name
        require(destination == destination.resolve() and not destination.is_symlink(), 'Canonical asset destination required')
        original = prepared['originalManifests'][name]
        require(original['file'] == str(destination) and pin(destination) == original, 'Original map changed: '+name)
        original_document = read_pin(original, root)
        proposed_pin, rollback_pin = prepared['proposedManifests'][name], prepared['rollbackManifests'][name]
        actual = read_pin(proposed_pin, root)
        read_pin(rollback_pin, root)
        require(release.same(rollback_pin, original), 'Raw asset rollback identity differs: '+name)
        require(actual == preparation.operational_map(original_document, current, n2, prepared['proposal']),
                'Proposed map changes more than the audited additive assembly fields: '+name)
        document = assets.load_assets(root/proposed_pin['file'], root)
        for key in document['assets']:
            protected.append(assets.asset(document, key))
        assets.image(document, 'x86-n2', 'native', 'N2', 'x86')
        assets.native_toolchain(document, 'x86')
        require(assets.runtime_abi(assets.runtime_provider(document, 'qbe-runtime')) == 11102,
                'Installed assembly runtime ABI differs')
        for row in current['components']['x86']['qualificationReceipts'].values():
            verify(dict(row, file=str(root/row['file'])))
        protected += [proposed_pin, rollback_pin]
        destinations[name], originals[name] = destination, original
        proposed[name], rollback[name] = proposed_pin, rollback_pin
    require(not changed_inputs(protected), 'Protected publication inputs changed during preflight')
    out = fresh_output(output, root)

    def validate():
        require(pin(selector) == selector_pin, 'Installed selector changed during asset publication')
        release.installed(selector, root)

    metadata = dict(preparation=report_pin, promotion=prepared['proposal'], installedRelease=verification,
                    scope='Exact three-map metadata publication after release installation; no compiler execution or additional qualification.')
    return transaction(out, destinations, originals, proposed, rollback, protected, validate, metadata)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--proposal', type=Path, required=True, help='Completed prepare-release report.json')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    try:
        result = publish(args.proposal, args.out)
        print(json.dumps({key: result[key] for key in ('complete', 'mutations', 'rollback')}))
        raise SystemExit(0 if result['complete'] else 1)
    except (ValueError, KeyError, OSError, TypeError, json.JSONDecodeError) as error:
        print('Phase183 asset publication refused: '+str(error), file=sys.stderr)
        raise SystemExit(1)
