#!/usr/bin/env python3
"""Host-only receipt controls. All image fixtures are non-executable text files."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p107_native_run', HERE/'run.py')
host = importlib.util.module_from_spec(spec)
spec.loader.exec_module(host)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)

    def fixture(name):
        file = out/(name+'.txt')
        file.write_text('Host-only, non-executable authentication fixture: '+name+'\n')
        return host.pin(file)

    source, binary, base, cache, acquisition = map(fixture, ['source', 'binary', 'base', 'cache', 'acquisition'])
    manifest = dict(kind='phase107-native-frontend-source', version=1, source=source,
                    assets=dict(base=base, cache=dict(carrier=cache)))
    manifest_file = out/'manifest.json'
    manifest_file.write_text(json.dumps(manifest))
    image = dict(kind='phase107-native-frontend-image', version=1, complete=True,
                 fixtureOnly=True, source=source, binary=binary,
                 manifest=host.pin(manifest_file), acquisition=acquisition)
    cases = []

    def check(name, mutate=lambda record: None, error=None, mode='cache'):
        record = copy.deepcopy(image)
        mutate(record)
        file = out/(name+'.json')
        file.write_text(json.dumps(record))
        try:
            host.authenticate(file, mode)
        except (ValueError, KeyError) as exc:
            if error is None or error not in str(exc):
                raise
            cases.append(dict(name=name, passed=True, refused=str(exc)))
        else:
            if error is not None:
                raise AssertionError(name+' unexpectedly accepted')
            cases.append(dict(name=name, passed=True))

    check('valid-cache')
    check('valid-live', mode='live')
    check('incomplete', lambda r:r.update(complete=False), 'incomplete')
    check('wrong-kind', lambda r:r.update(kind='other'), 'unsupported')
    check('wrong-version', lambda r:r.update(version=2), 'unsupported')
    check('source-binding', lambda r:r.update(source=base), 'different compiler sources')
    for name in ['manifest', 'source', 'binary', 'acquisition']:
        # Source's independent digest is also bound by the manifest comparison.
        expected = 'different compiler sources' if name == 'source' else 'changed pinned input'
        check('changed-'+name, lambda r,n=name:r[n].update(sha256='0'*64), expected)
    original_cache = Path(cache['file']).read_text()
    Path(cache['file']).write_text(original_cache+'changed')
    check('changed-cache-refused', error='changed pinned input')
    check('live-does-not-use-cache', mode='live')
    Path(cache['file']).write_text(original_cache)
    Path(base['file']).write_text('changed')
    check('changed-base-refused', error='changed pinned input')
    report = dict(complete=True, targetsExecuted=False, fixtureImagesExecutable=False,
                  method=host.pin(__file__), launcher=host.pin(HERE/'run.py'), checks=cases)
    (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(passed=len(cases), targetsExecuted=False, report=str(out/'report.json'))))


if __name__ == '__main__':
    main()
