#!/usr/bin/env python3
"""Root-run exact-source upstream-built native B1; no qualification/promotion."""
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('phase102_acquire_support', HERE.parent / 'phase100/run.py')
R = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = R
spec.loader.exec_module(R)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--recipe', required=True, type=Path)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102') and not out.exists()
    out.mkdir(parents=True)
    report = dict(kind='phase102-native-b1-acquisition', complete=False,
        imageQualified=False, releaseQualified=False, started=time.time(),
        method=R.pin(__file__), recipe=R.pin(a.recipe), jobs=[],
        scope='Actual pinned-upstream checked C, unmodified matched-O2 Clang and exact native B1 binding. '
              'No B2, compiler speed, semantic qualification or installed-selection claim.')
    def save(): R.save(out / 'report.json', report)
    def room(): assert shutil.disk_usage(ROOT).free > 512 * 1024**2, 'Need 512MiB reserve'
    def command(name, argv):
        room()
        row = dict(name=name, command=list(map(str, argv)), started=time.time())
        report['jobs'].append(row); save()
        with (out / (name + '.stdout')).open('w') as stdout, (out / (name + '.stderr')).open('w') as stderr:
            result = subprocess.run(row['command'], cwd=ROOT, stdout=stdout, stderr=stderr)
        row.update(returncode=result.returncode, finished=time.time(),
            stdout=R.pin(out / (name + '.stdout')), stderr=R.pin(out / (name + '.stderr')))
        save()
        assert result.returncode == 0, ('Failed stage; retained logs', name)
    save()
    try:
        recipe = R.read(a.recipe)
        assert recipe['complete']
        for key in ('source', 'candidate'): R.verify(recipe[key])
        text = Path(recipe['source']['file']).read_text()
        original = text
        for c in recipe['changes']:
            at = c['offset']; assert text[at:at + len(c['old'])] == c['old']
            text = text[:at] + c['new'] + text[at + len(c['old']):]
        assert text == Path(recipe['candidate']['file']).read_text()
        for c in reversed(recipe['changes']):
            at = c['offset']; assert text[at:at + len(c['new'])] == c['new']
            text = text[:at] + c['old'] + text[at + len(c['new']):]
        assert text == original
        release, context = R.authenticate()
        report.update(source=recipe['candidate'], recipeForwardInverseExact=True, context=context,
            baseline=dict(source=release['source'], stages={s:release['stages'][s]['binary'] for s in ('b1','b2')}))
        derivation = R.read(HERE / 'acquire-native-derivation.json')
        for key in ('source', 'candidate'): R.verify(derivation[key])
        before = Path(derivation['source']['file']).read_text()
        delta = derivation['change']
        assert before.count(delta['old']) == 1
        assert before.replace(delta['old'], delta['new']) == Path(derivation['candidate']['file']).read_text()
        reuse = ROOT / 'selfhost/tools/performance/phase99/qualification/reuse.py'
        guard = ROOT / 'selfhost/tools/performance/phase86/guard.py'
        execute = ROOT / 'selfhost/tools/performance/phase46/execute.py'
        methods = [R.pin(p) for p in (HERE / 'acquire-native.mjs', HERE / 'acquire-native-derivation.json', reuse, guard, execute)]
        report.update(methods=methods, acquisitionDerivation=derivation); save()
        command('upstream-acquire', [sys.executable, '-B', guard, '--out', out / 'acquire-guard',
            '--seconds', '180', '--rss-mib', '6144', '--available-mib', '16384', '--cpu', '2,3', '--',
            sys.executable, '-B', execute, out / 'acquire-child.json',
            context['bun']['file'], HERE / 'acquire-native.mjs', recipe['candidate']['file'], out / 'checked'])
        acquisition = R.read(out / 'checked/report.json')
        assert acquisition['complete'] and acquisition['holes'] == 0 and acquisition['source'] == recipe['candidate']
        process = R.read(out / 'acquire-guard/process.json')
        assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')
        report.update(acquisition=R.pin(out / 'checked/report.json'), c=acquisition['c'],
            acquisitionGuard=R.pin(out / 'acquire-guard/process.json')); save()
        command('build', [sys.executable, '-B', reuse, 'build', '--emission-receipt', out / 'checked/report.json',
            '--binary', out / 'compiler', '--out', out / 'build', '--seconds', '420', '--rss-mib', '6144'])
        command('bind', [sys.executable, '-B', reuse, 'bind', '--stage', 'b1', '--binary', out / 'compiler',
            '--source', recipe['candidate']['file'], '--emission-receipt', out / 'checked/report.json',
            '--build-guard', out / 'build', '--out', out / 'b1.json'])
        bound = R.read(out / 'b1.json')
        assert bound['complete'] and bound['stage'] == 'b1' and not bound['argvSentinel']
        assert bound['source'] == recipe['candidate'] and bound['c'] == acquisition['c'] and not bound['cPatched']
        # The reused builder/binder independently authenticate the frozen Phase98
        # baseline. This runner records the current installed stages separately;
        # timing tools must choose the same named stage, never historical native07.
        for item in [report['method'], report['recipe'], recipe['source'], recipe['candidate'], *methods, *context['inputs']]:
            R.verify(item)
        report.update(complete=True, binary=bound['binary'], buildBinding=R.pin(out / 'b1.json'), inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time(); save()
        print(json.dumps({k:report.get(k) for k in ('complete','source','binary','buildBinding','error')}), flush=True)


if __name__ == '__main__': main()
