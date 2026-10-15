#!/usr/bin/env python3
"""Run an explicitly admitted native Bend compiler stage; no compiler host in Python."""
import argparse, datetime, hashlib, json, os, shutil, subprocess, sys, tempfile
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DEFAULT = HERE/'selection.json'
GUARD = ROOT/'selfhost/tools/performance/phase86/guard.py'
SUPPORT = ROOT/'selfhost/tools/performance/programs/support.py'


def pin(file):
    file = Path(file).resolve(strict=True); digest = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''): digest.update(block)
    return dict(file=str(file), sha256=digest.hexdigest(), bytes=file.stat().st_size)


def verify(record):
    actual = pin(record['file'])
    assert actual == record, 'Artifact changed: '+actual['file']
    return actual


def load(pointer=DEFAULT, stage=None, live=False):
    """Authenticate only selected request assets; admission already checked history."""
    pointer_pin = pin(pointer); selection = json.loads(Path(pointer_pin['file']).read_text())
    assert selection['kind'] == 'bend-native-compiler-selection' and selection['version'] == 1 and selection['complete']
    admission_pin = verify(selection['admission']); release = json.loads(Path(admission_pin['file']).read_text())
    assert release['kind'] == 'phase98-native-candidate-qualification' and release['version'] == 1
    assert release['complete'] and release['qualified'] and release['defaultSelection'] is False
    stage = stage or selection['defaultStage']; assert stage in ('b1','b2')
    assert set(release['stages']) == {'b1','b2'}
    source = verify(release['source']); producer = release['stages'][stage]
    assert producer['stage'] == stage and producer['source'] == source
    assert producer['argvSentinel'] is (stage == 'b2')
    verify(producer['binary'])
    assets = release['assets']
    for key in ('base','runtime','template'): verify(assets[key])
    assert len(assets['parts']) == 5 and len(assets['effects']) == 9
    for index, part in enumerate(assets['parts']):
        verify(part); assert part['file'] == assets['runtime']['file']+f'.part{index}'
    effect_paths = []
    for effect in assets['effects']:
        verify(effect); effect_paths.append(effect['file'])
        assert Path(effect['file']).parent == Path(assets['effectsDir'])
    assert len(set(effect_paths)) == 9
    assert isinstance(assets['argvSentinel'], str) and assets['argvSentinel']
    if not live:
        verify(assets['cache']['carrier'])
        assert assets['cacheBasePath'] == assets['base']['file']
        assert isinstance(assets['cache']['stamp'], str) and assets['cache']['stamp']
    return release, dict(selection=pointer_pin, admission=admission_pin, stage=stage)


def native_args(release, source, prefix, calls=1, live=False, stage='b2'):
    assert calls in (1,5) and stage in ('b1','b2')
    producer = release['stages'][stage]; assets = release['assets']
    argv = [producer['binary']['file'], '--threads', '1', '--gpu', 'off', '--']
    if producer['argvSentinel']: argv.append(assets['argvSentinel'])
    argv.extend([str(Path(source).resolve()), assets['base']['file'], assets['runtime']['file'],
                 assets['effectsDir'], str(Path(prefix).resolve()), str(calls)])
    if not live: argv.extend([assets['cache']['carrier']['file'], assets['cache']['stamp']])
    return argv


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path); parser.add_argument('-o','--output', type=Path, required=True)
    parser.add_argument('--selection', type=Path, default=DEFAULT)
    parser.add_argument('--stage', choices=['b1','b2']); parser.add_argument('--live', action='store_true')
    parser.add_argument('--calls', type=int, choices=[1,5], default=1)
    parser.add_argument('--seconds', type=int, default=60)
    args = parser.parse_args(); assert 1 <= args.seconds <= 600
    log_root = ROOT/'selfhost/build/native/requests'; log_root.mkdir(parents=True, exist_ok=True)
    prefix = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ-')
    out = Path(tempfile.mkdtemp(prefix=prefix, dir=log_root))
    report = dict(kind='bend-native-compiler-request', version=1, complete=False, method=pin(__file__), log=str(out))
    status = 1
    try:
        source = pin(args.source); assert source['bytes'] <= 16*1024**2
        destination = args.output.resolve(); assert not destination.exists(), 'Output already exists'
        release, binding = load(args.selection,args.stage,args.live); stage = binding['stage']
        methods = [pin(__file__),pin(GUARD),pin(SUPPORT)]
        argv = native_args(release,source['file'],out/'program',args.calls,args.live,stage)
        command = [sys.executable,'-B',str(GUARD),'--out',str(out/'guard'),'--seconds',str(args.seconds),
                   '--rss-mib','2048','--available-mib','4096','--cpu','3','--',*argv]
        report.update(source=source,selection=binding,stage=stage,live=args.live,calls=args.calls,methods=methods,command=command)
        child = subprocess.run(command,capture_output=True,text=True)
        (out/'launcher.stdout').write_text(child.stdout); (out/'launcher.stderr').write_text(child.stderr)
        process = json.loads((out/'guard/process.json').read_text()); report['process'] = process
        stderr = out/'guard/stderr.log'
        if stderr.exists(): sys.stderr.write(stderr.read_text())
        assert child.returncode == 0 and process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted'), 'Compilation failed; see retained request evidence'
        outputs = [pin(out/f'program.{i}.c') for i in range(1,args.calls+1)]
        generated = outputs[0]
        assert all(0 < item['bytes'] <= 64*1024**2 for item in outputs)
        assert all((item['sha256'],item['bytes']) == (generated['sha256'],generated['bytes']) for item in outputs), 'Repeated generated C differs'
        report.update(outputs=outputs,repeatedCEqual=True)
        assert pin(source['file']) == source and load(args.selection,args.stage,args.live) == (release,binding), 'Inputs changed during request'
        for method in methods: verify(method)
        destination.parent.mkdir(parents=True,exist_ok=True)
        with tempfile.NamedTemporaryFile(prefix='.'+destination.name+'.',dir=destination.parent) as temp:
            with Path(generated['file']).open('rb') as stream: shutil.copyfileobj(stream,temp)
            temp.flush(); assert pin(temp.name)['sha256'] == generated['sha256']
            os.link(temp.name,destination)
        report.update(complete=True,generated=generated,output=pin(destination)); status = 0
    except Exception as error:
        report['error'] = str(error); print('native compiler: '+str(error),file=sys.stderr)
    finally:
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
        print('Request evidence: '+str(out),file=sys.stderr)
    return status


if __name__ == '__main__': sys.exit(main())
