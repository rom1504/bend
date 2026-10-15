#!/usr/bin/env python3
"""Snapshot a Bend law dependency closure, then check it under bounded guards."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT/'selfhost/build/phase97'
BUN = ROOT/'selfhost/build/phase66/bun-toolchain01/bun'
KERNEL = ROOT/'selfhost/build/phase94/kernel'
LEAN = ROOT/'selfhost/build/phase94/toolchain/lean-4.34.0-linux/bin/lean'


def pin(path):
    path = Path(path).resolve(); h = hashlib.sha256()
    with path.open('rb') as f:
        for data in iter(lambda:f.read(1024*1024), b''): h.update(data)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--source-only', action='store_true')
    a = p.parse_args(); out = a.out.resolve(); source = a.source.resolve()
    assert source.is_relative_to(ROOT) and out.is_relative_to(BUILD) and not out.exists()
    out.mkdir(parents=True)
    report = dict(complete=False, independentlyChecked=False, sourceOnly=a.source_only,
                  inputs=[], sourceClosure=[], rows={}, source=pin(source))
    def save(): (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    def bind(path):
        item = pin(path); report['inputs'].append(item); return item
    def freeze(file):
        origin = pin(file)
        if any(x['origin']==origin for x in report['sourceClosure']): return
        data = file.read_bytes(); assert hashlib.sha256(data).hexdigest()==origin['sha256']
        target = out/'snapshot'/file.relative_to(ROOT); target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        report['sourceClosure'].append(dict(origin=origin, snapshot=bind(target)))
        for name in re.findall(r'^import\s+(\S+)', data.decode(), re.M):
            if name == 'Base': continue
            assert name.startswith('.'), ('Unsupported import; explicitly bind it', name)
            dep = (file.parent/name).resolve()
            assert dep.is_relative_to(ROOT) and dep.is_file(), dep
            freeze(dep)
    def run(name, argv, expected=0, seconds=60):
        folder = out/name
        command = [sys.executable, '-B', str(ROOT/'selfhost/tools/performance/phase86/guard.py'),
                   '--out', str(folder), '--seconds', str(seconds), '--rss-mib', '2048',
                   '--available-mib', '4096', '--cpu', '3', '--', *map(str,argv)]
        wrapper = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        (out/(name+'-wrapper.stdout')).write_text(wrapper.stdout)
        (out/(name+'-wrapper.stderr')).write_text(wrapper.stderr)
        proc = json.loads((folder/'process.json').read_text())
        stdout = (folder/'stdout.log').read_text(); stderr = (folder/'stderr.log').read_text()
        report['rows'][name] = dict(process=proc, stdout=stdout, stderr=stderr); save()
        assert proc['returncode']==expected and not proc.get('stoppedFor'), (name,stdout,stderr)
        assert proc['complete'] == (expected==0), proc
        return stdout,stderr
    try:
        (out/'method.py').write_bytes(Path(__file__).read_bytes())
        report['originalMethod'] = pin(__file__); bind(out/'method.py')
        bind(ROOT/'selfhost/tools/performance/phase86/guard.py')
        bind(ROOT/'selfhost/tools/performance/programs/support.py')
        prior = ROOT/'selfhost/build/phase94/proof-replay02/report.json'; bind(prior)
        old = json.loads(prior.read_text()); assert old['complete'] and old['independentlyChecked']
        required = {str(BUN), *(str(ROOT/'bend2'/x) for x in ['main.ts','bend.ts','safe.ts','base.bend'])}
        if not a.source_only:
            required |= {str(KERNEL/x) for x in ['BendTT.lean','BendTT.olean','Run.lean']}
            required |= {str(LEAN), str(LEAN.parent.parent/'lib/lean/libleanshared.so')}
        previous = {r['file']:r for r in old['inputs']}
        for file in sorted(required): assert bind(file)==previous[file]
        freeze(source); entry = out/'snapshot'/source.relative_to(ROOT)
        report['lawNames'] = [name for row in report['sourceClosure']
                              for name in re.findall(r'^law\s+([^:\s]+)',Path(row['snapshot']['file']).read_text(),re.M)]
        for row in report['sourceClosure']:
            text = Path(row['snapshot']['file']).read_text()
            for name in re.findall(r'^law\s+([^:\s]+)',text,re.M):
                assert re.search(r'^def\s+'+re.escape(name)+r'\s*\(',text,re.M), ('Unfilled law',name)
        save()
        stdout,stderr = run('check',['env','BEND_NO_TELEMETRY=1',BUN,ROOT/'bend2/main.ts',entry,'--check-only'])
        assert stdout=='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not stderr
        if not a.source_only:
            tt = out/'laws.bendtt'
            stdout,stderr = run('elaborate',['env','BEND_NO_TELEMETRY=1',BUN,ROOT/'bend2/main.ts',entry,'-o',tt])
            assert not stdout and not stderr
            report['elaboration'] = bind(tt)
            report['definitions'] = re.findall(r'^(?:opaque )?(\S+) :',tt.read_text(),re.M)
            report['opaqueDefinitions'] = re.findall(r'^opaque (\S+) :',tt.read_text(),re.M)
            assert report['definitions'] and report['lawNames']
            assert len(report['lawNames'])==len(set(report['lawNames'])), 'Ambiguous law names'
            report['lawBindings'] = {}
            for name in report['lawNames']:
                matches = [x for x in report['definitions'] if re.search(r'(?:^|\.)'+re.escape(name)+r'(?:\.q[012v]+(?:_[0-9]+)?)?$',x)]
                assert matches and not any(x in report['opaqueDefinitions'] for x in matches), ('Omitted or opaque law',name)
                report['lawBindings'][name] = matches
            prefix = ['env','LEAN_STACK_SIZE_KB=4096','LEAN_PATH='+str(KERNEL),LEAN,'-M1400','--run',KERNEL/'Run.lean']
            stdout,stderr = run('kernel',prefix+[tt]); assert stdout=='ALL PROOFS CHECK\n' and not stderr
            negative = ROOT/'selfhost/proofs/phase67/reject-unequal-labels.bendtt'; bind(negative)
            stdout,stderr = run('kernel-negative',prefix+[negative],expected=1)
            assert stdout.startswith('SOME PROOFS FAIL\nIn phase67_false:') and 'expected: .left' in stdout and 'observed: .right' in stdout and not stderr
            report['independentlyChecked'] = True
        for item in report['inputs']: assert pin(item['file'])==item
        report.update(complete=True, inputsUnchanged=True,
                      toolchainScope='Reuses the previously fully audited Phase94 installation; reauthenticates key executable/module bytes, not all toolchain files.')
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: save()
    print(json.dumps(dict(complete=report['complete'], independentlyChecked=report['independentlyChecked'], laws=len(report['lawNames']))))


if __name__ == '__main__': main()
