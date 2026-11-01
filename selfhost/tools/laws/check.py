#!/usr/bin/env python3
"""Check a frozen law closure with explicit frontend/kernel assets and source scope.

Run inside the repository disk guard. This worker never acquires another lock.
"""
import argparse
import json
import os
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from assets import load_assets, asset
from common import pin, verify, run, write_json, fresh_output, timeout
from bindings import source_binding


def freeze_closure(source, out):
    rows = []
    def visit(file):
        file = file.resolve()
        if not file.is_relative_to(ROOT):
            raise ValueError('Proof imports must remain inside the workspace')
        origin = pin(file)
        if any(row['origin'] == origin for row in rows):
            return
        data = file.read_bytes()
        target = out/'snapshot'/file.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        rows.append(dict(origin=origin, snapshot=pin(target)))
        for name in re.findall(r'^import\s+(\S+)', data.decode(), re.M):
            if name == 'Base':
                continue
            if not name.startswith('.'):
                raise ValueError('Unbound nonlocal proof import: '+name)
            visit(file.parent/name)
    visit(source)
    return rows, out/'snapshot'/source.relative_to(ROOT)


def validate_laws(rows, allow_empty=False):
    names = []
    for row in rows:
        text = Path(row['snapshot']['file']).read_text()
        for name in re.findall(r'^law\s+([^:\s]+)', text, re.M):
            if not re.search(r'^def\s+'+re.escape(name)+r'\s*\(', text, re.M):
                raise ValueError('Unfilled law: '+name)
            names.append(name)
    if (not names and not allow_empty) or len(names) != len(set(names)):
        raise ValueError('Nonempty unique law names required')
    return names


def bind_elaboration(text, names):
    definitions = re.findall(r'^(?:opaque )?(\S+) :', text, re.M)
    opaque = re.findall(r'^opaque (\S+) :', text, re.M)
    bindings = {}
    for name in names:
        matches = [x for x in definitions if re.search(r'(?:^|\.)'+re.escape(name)+r'(?:\.q[012v]+(?:_[0-9]+)?)?$', x)]
        if not matches or any(x in opaque for x in matches):
            raise ValueError('Omitted or opaque law: '+name)
        bindings[name] = matches
    return definitions, opaque, bindings


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--assets', type=Path, required=True)
    parser.add_argument('--binding', type=Path, help='Manifest from prepare.py; required for actual-source proof claims')
    parser.add_argument('--source-only', action='store_true')
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--seconds', type=float, default=60)
    args = parser.parse_args()
    timeout(args.seconds)
    source = args.source.resolve()
    binding = source_binding(args.binding, source) if args.binding else None
    assets = load_assets(args.assets, ROOT)
    keys = ['bun', 'upstream-main', 'upstream-bend', 'upstream-safe', 'base']
    if not args.source_only:
        keys += ['lean', 'lean-shared', 'kernel-source', 'kernel-olean', 'kernel-runner']
    pins = {key: asset(assets, 'law-'+key) for key in keys}
    paths = {key: Path(row['file']) for key, row in pins.items()}
    front = paths['upstream-main'].parent
    for key, filename in [('upstream-main','main.ts'),('upstream-bend','bend.ts'),('upstream-safe','safe.ts'),('base','base.bend')]:
        if paths[key] != front/filename:
            raise ValueError('Frontend assets must be one explicit coherent module directory')
    if not args.source_only:
        kernel = paths['kernel-runner'].parent
        if paths['kernel-source'] != kernel/'BendTT.lean' or paths['kernel-olean'] != kernel/'BendTT.olean' or paths['kernel-runner'].name != 'Run.lean':
            raise ValueError('Kernel assets must be one explicit coherent module directory')
        if paths['lean-shared'] != paths['lean'].parent.parent/'lib/lean/libleanshared.so':
            raise ValueError('Lean shared library does not match its executable layout')
    out = fresh_output(args.out, ROOT)
    report = dict(schema='bend-law-check-v1', complete=False, independentlyChecked=False,
                  preparedOnly=args.prepare_only, sourceOnly=args.source_only,
                  sourceBinding=binding, wholeCompilerProved=False, nativeOwnershipProved=False,
                  scope='Actual extracted declarations under frozen value contracts' if binding else 'Standalone source closure; no production compiler binding claimed',
                  source=pin(source), inputs=[pin(args.assets), *pins.values(), pin(__file__), pin(HERE/'bindings.py'),
                                           pin(ROOT/'selfhost/tools/build/common.py'), pin(ROOT/'selfhost/tools/build/assets.py')], rows={})
    def save(): write_json(out/'report.json', report)
    try:
        (out/'method.py').write_bytes(Path(__file__).read_bytes())
        report['sourceClosure'], entry = freeze_closure(source, out)
        report['lawNames'] = validate_laws(report['sourceClosure'],allow_empty=args.source_only)
        report['inputs'] += [r['origin'] for r in report['sourceClosure']] + [r['snapshot'] for r in report['sourceClosure']]
        env = dict(os.environ, BEND_NO_TELEMETRY='1')
        check = [str(paths['bun']), str(paths['upstream-main']), str(entry)]
        jobs = [dict(name='check', command=check+['--check-only'], expected=0)]
        tt = out/'laws.bendtt'
        if not args.source_only:
            negative = ROOT/'selfhost/proofs/compiler-laws/control/reject-unequal-labels.bendtt'
            report['inputs'].append(pin(negative))
            prefix = [str(paths['lean']), '-M1400', '--run', str(paths['kernel-runner'])]
            env.update(LEAN_STACK_SIZE_KB='4096', LEAN_PATH=str(kernel))
            jobs += [dict(name='elaborate',command=check+['-o',str(tt)],expected=0),
                     dict(name='kernel',command=prefix+[str(tt)],expected=0),
                     dict(name='kernel-negative',command=prefix+[str(negative)],expected=1)]
        report['jobs'] = jobs
        save()
        if args.prepare_only:
            report['preparationComplete'] = True
            return
        for job in jobs:
            folder = out/job['name']; folder.mkdir()
            process = run(job['command'], cwd=ROOT, stdout=folder/'stdout.log', stderr=folder/'stderr.log', seconds=args.seconds, env=env)
            stdout=(folder/'stdout.log').read_text();stderr=(folder/'stderr.log').read_text()
            report['rows'][job['name']] = dict(process=process,stdout=stdout,stderr=stderr)
            save()
            if process.get('exitCode') != job['expected'] or process.get('timedOut') or process.get('error'):
                raise ValueError('Law job refused or failed: '+job['name'])
            if job['name']=='check':
                if stdout!='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' or stderr: raise ValueError('Unexpected frontend diagnostic')
            elif job['name']=='elaborate':
                if stdout or stderr: raise ValueError('Unexpected elaboration diagnostic')
                report['elaboration']=pin(tt)
                report['definitions'],report['opaqueDefinitions'],report['lawBindings']=bind_elaboration(tt.read_text(),report['lawNames'])
            elif job['name']=='kernel':
                if stdout!='ALL PROOFS CHECK\n' or stderr: raise ValueError('Kernel rejected laws')
            elif not (stdout.startswith('SOME PROOFS FAIL\nIn phase67_false:') and 'expected: .left' in stdout and 'observed: .right' in stdout and not stderr):
                raise ValueError('Kernel negative control did not reject the known false claim')
        for row in report['inputs']: verify(row)
        if binding and source_binding(args.binding,source)!=binding: raise ValueError('Source binding changed')
        report.update(complete=True, independentlyChecked=not args.source_only, inputsUnchanged=True,
                      toolchainScope='Explicit key frontend/kernel executable and module pins, plus current false-law kernel control; not an authentication of every toolchain installation file.')
    except BaseException as error:
        report['error']=repr(error)
        raise
    finally:
        save()
    print(json.dumps(dict(complete=report['complete'], independentlyChecked=report['independentlyChecked'], laws=len(report['lawNames']))))


if __name__=='__main__': main()
