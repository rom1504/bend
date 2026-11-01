#!/usr/bin/env python3
"""Link and stage the public CLI; an outer guard and independent CLI gate are required."""
import argparse
import json
from pathlib import Path
import shutil
import sys
import time
sys.dont_write_bytecode = True
import assets
from common import ROOT, clean_environment, fresh_output, pin, require, run, verify, write_json

def same(a, b):
    return all(a.get(k) == b.get(k) for k in ('bytes', 'sha256'))

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--assets', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    clean_environment()
    profile = json.loads(args.profile.read_text())
    build = json.loads(args.build.read_text())
    require(profile.get('kind') == 'bend-public-cli-source-profile' and profile.get('complete')
            and profile.get('allOtherBodiesIdentical'), 'Completed shared-source CLI profile required')
    require(build.get('kind') == 'bend-native-build' and build.get('complete')
            and not build.get('changedInputs') and build.get('target') == 'qbe'
            and same(build.get('request', {}).get('source', {}), profile['source']),
            'Actual native build of the exact public CLI source required')
    document = assets.load_assets(args.assets, ROOT)
    linker = assets.asset(document, 'linker')
    runtime = assets.asset(document, 'qbe-runtime')
    require(same(runtime, build['runtime']), 'CLI runtime differs from selected QBE runtime')
    require(profile['linkContract'] == {'extraSource': profile['startup']['file'],
            'flags': ['-Wl,--wrap=main'], 'generatedMainUnmodified': True}, 'Unknown startup contract')
    inputs = [pin(__file__), pin(Path(__file__).with_name('common.py')), pin(assets.__file__),
              pin(args.profile), pin(args.build), document['_manifest'], linker, runtime,
              build['object'], profile['source'], profile['startup'],
              *profile['inputs'], *build['inputs'], *profile['assets'].values()]
    for row in inputs:
        verify(row)
    out = fresh_output(args.out, ROOT)
    report = dict(kind='bend-public-cli-package', version=1, complete=False, qualified=False,
                  installed=False, host='native', stage='N1', targets=['c'],
                  protocol='native-public-cli-v1', source=profile['source'],
                  canonicalSource=profile['canonicalSource'], baseIdentity=profile['baseIdentity'],
                  cacheStamp=profile['cacheStamp'], profile=pin(args.profile),
                  nativeBuild=pin(args.build), runtime=runtime, startup=profile['startup'],
                  inputs=inputs, jobs=[], assets={},
                  scope='Actual native compiler object plus an argv-only startup wrapper and immutable assets. '
                        'A separate ordinary-output/public-option/integrity gate must qualify this image before installation.')
    start = time.monotonic()
    def job(name, command):
        result = run(command, cwd=ROOT, stdout=out/(name+'.stdout'), stderr=out/(name+'.stderr'), seconds=60)
        report['jobs'].append(dict(name=name, **result))
        write_json(out/'BUILD.json', report)
        require(result['complete'] and result['stdout']['bytes'] == 0, name+' failed')
    try:
        job('startup', [linker['file'], '-std=c11', '-O2', '-c', profile['startup']['file'], '-o', out/'startup.o'])
        job('link', [linker['file'], '-no-pie', '-Wl,--wrap=main', out/'startup.o', build['object']['file'],
                     runtime['file'], '-pthread', '-lm', '-o', out/'bend'])
        for name, original in profile['assets'].items():
            require(not Path(name).is_absolute() and '..' not in Path(name).parts, 'Invalid asset path')
            destination = out/'assets'/name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(original['file'], destination)
            copied = pin(destination)
            require(same(original, copied), 'Copied asset differs')
            report['assets'][name] = copied
        report['startupObject'], report['image'] = pin(out/'startup.o'), pin(out/'bend')
        for row in inputs:
            verify(row)
        report['complete'] = True
        report['imageBinding'] = {key: report[key] for key in ('host', 'stage', 'targets', 'protocol')}
        report['imageBinding'].update(kind='bend-build-image-binding', version=1, complete=True,
            image=report['image'], sourceIdentity=profile['source'], linkedRuntime=runtime,
            packageAssets=report['assets'],baseIdentity=profile['baseIdentity'],cacheStamp=profile['cacheStamp'],
            targetRuntime=pin(ROOT/'selfhost/src/runtime/native/runtime.c'),
            qualification='Constructed public CLI; separate behavioral qualification required.')
    except BaseException as error:
        report['error'] = repr(error)
    report['seconds'] = time.monotonic()-start
    write_json(out/'BUILD.json', report)
    print(json.dumps({key: report.get(key) for key in ('complete', 'image', 'source', 'error')}))
    return 0 if report['complete'] else 1

if __name__ == '__main__':
    raise SystemExit(main())
