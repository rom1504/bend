#!/usr/bin/env python3
"""Root-only writer closure after explicit acknowledgements and final receipt copies."""
import argparse
import importlib.util
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.dont_write_bytecode = True
TOOLS = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase66_archive', TOOLS / 'archive.py')
archive = importlib.util.module_from_spec(spec)
spec.loader.exec_module(archive)
ROOT, RAW = archive.ROOT, archive.RAW
pin, read, path = archive.identity, archive.read, archive.repo_file
ROLES = {'compilerQualification', 'releaseQualification', 'timeAccount',
         'finalSimplicity', 'protectedInputs', 'installedFiles'}


def lookup(value, dotted):
    for key in dotted.split('.'):
        value = value[key]
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', required=True)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}, 'Closure data work uses CPU0'
    config_file = path(args.config)
    config_pin = pin(config_file)
    config = read(config_file)
    assert config['kind'] == 'phase66-root-closure-authorization'
    assert config['allRawWritersStopped'] is True
    assert config['compilerTargetsClosed'] is True and config['installationVerified'] is True
    acknowledgements = config['ownerAcknowledgements']
    assert acknowledgements and all(v is True for v in acknowledgements.values())
    assert 'root' in acknowledgements
    assert len(config['sourceCommit']) == 40 and all(c in '0123456789abcdef' for c in config['sourceCommit'])
    closure_file = RAW / 'writers-closed.json'
    assert not closure_file.exists(), 'Never replace closure or resume an old campaign'
    assert not archive.OUT.exists(), 'Publication must follow closure'
    copies = config['copies']
    assert ROLES <= {row['role'] for row in copies}, 'Missing final evidence role'
    assert len({row['copy'] for row in copies}) == len(copies), 'Copies need fresh unique paths'
    assert any(row['source'] == 'implementation/phase66/evidence/time-account-final.json' for row in copies)
    verified = []
    for row in copies:
        source, destination = path(row['source']), path(row['copy'])
        destination.relative_to(RAW / 'final-closure')
        assert not destination.exists() and source != destination
        observed = pin(source)
        assert observed['sha256'] == row['sha256'] and observed['bytes'] == row['bytes']
        # Assertions are explicit per receipt: conformance failures can remain
        # recorded as failures; no generic recursively inferred "pass" exists.
        assertions = row['assertions']
        assert assertions, 'Bind each role to explicit closed receipt fields'
        value = read(source)
        for key, expected in assertions.items():
            assert lookup(value, key) == expected, (row['role'], key)
        verified.append((row, source, destination, observed))
    protected = archive.preserved()
    for row, source, destination, observed in verified:
        destination.parent.mkdir(parents=True, exist_ok=True)
        with source.open('rb') as incoming, destination.open('xb') as outgoing:
            for block in iter(lambda: incoming.read(1048576), b''):
                outgoing.write(block)
        assert pin(source) == observed
        assert pin(destination)['sha256'] == observed['sha256']
        assert pin(destination)['bytes'] == observed['bytes']
    assert pin(config_file) == config_pin
    assert archive.preserved() == protected
    closure = dict(kind='phase66-raw-writers-closed', complete=True,
                   closed=datetime.now(timezone.utc).isoformat(),
                   sourceCommit=config['sourceCommit'], compilerTargetsClosed=True,
                   installationVerified=True, ownerAcknowledgements=acknowledgements,
                   authorization=config_pin, producer=pin(Path(__file__).resolve()),
                   copies=copies, scope='Root explicitly stopped all raw writers and copied final '
                   'closed receipts before this last raw record. Failed and interrupted outputs '
                   'remain unfiltered. Subsequent archive/report/Git writes must stay outside '
                   'selfhost/build/phase66; historical raw trees remain closed.')
    with closure_file.open('x') as stream:
        stream.write(json.dumps(closure, indent=2) + '\n')
    print(json.dumps(dict(closure=pin(closure_file), sealed=True, archiveExecuted=False)))


if __name__ == '__main__':
    main()
