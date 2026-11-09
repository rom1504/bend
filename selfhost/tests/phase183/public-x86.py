#!/usr/bin/env python3
"""Installed public assembly/ELF/run controls with independent literal oracles."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import assets
from common import changed_inputs, fresh_output, pin, require, run, verify, write_json
spec = importlib.util.spec_from_file_location('public_native', ROOT/'selfhost/tools/build/public-native.py')
public = importlib.util.module_from_spec(spec); spec.loader.exec_module(public)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=120)
    args = parser.parse_args()
    document, provider, inputs = public.selected(ROOT)
    tools = {key:assets.asset(document,key) for key in ('assembler','linker','bun','qbe-runtime','prepared-base')}
    current = json.loads((ROOT/'selfhost/manifests/current.json').read_text())
    inputs += [public.installed(current['components'][key]['image'],current,ROOT) for key in ('nativeCli','js')]
    for row in current['providers'].values():
        inputs.append(pin(verify(dict(row,file=str(ROOT/row['file'])))))
    c_policy = document.get('toolchains',{}).get('c')
    require(isinstance(c_policy,dict) and all(key in c_policy for key in ('compiler','flags','libraries')),
            'Explicit C construction policy required')
    tools['c-compiler'] = assets.asset(document,c_policy['compiler'])
    c_key = document['providers']['c']['runtime']
    c_provider = assets.runtime_provider(document,c_key)
    require(current['components']['nativeCli'].get('targetRuntimeArgumentConvention') == assets.runtime_argument_convention(c_provider),
            'Public C image and target runtime argument convention differ')
    for key, asset_key in [('cRuntime',c_key),('cRuntimeTemplate',document['providers']['c']['runtimeTemplate']),
                           ('jsDirectRuntime',document['providers']['js']['runtime'])]:
        actual = assets.asset(document,asset_key); declared = current['providers'][key]
        require(all(actual[field] == declared[field] for field in ('bytes','sha256')),'Installed/operational provider differs: '+key)
        inputs.append(actual)
    inputs += list(tools.values()) + [pin(__file__),pin(ROOT/'selfhost/bend'),pin(ROOT/'selfhost/native.py'),pin(ROOT/'selfhost/cli.mjs')]
    inputs += [pin(ROOT/'selfhost/tools/build'/name) for name in ('public-native.py','native.py','request.py','assets.py','common.py')]
    inputs += [pin(p) for p in sorted((ROOT/'selfhost/tools').glob('*.mjs'))]
    inputs += [pin(p) for p in sorted((ROOT/'selfhost/src/runtime').rglob('*')) if p.is_file()]
    inputs += [pin(ROOT/'selfhost/src/runtime.mjs'),pin(ROOT/'selfhost/src/compiler.json')]
    fixture = Path(__file__).with_name('public')
    sources = {name:pin(fixture/(name+'.bend')) for name in ('numeric','argv','negative-type')}
    inputs += list(sources.values())
    out = fresh_output(args.out, ROOT)
    report = dict(kind='phase183-public-x86-controls',version=1,complete=False,inputs=inputs,cases=[],jobs=[],
        oracle='Independent literal 42 and exact argv text; actual assembly assembled and linked with authenticated tools.',
        scope='Installed selector, shell transport, x86 and ordinary C/JS finite cases; no compiler generation or performance claim.',
        cToolchain=c_policy,cRuntimeArgumentConvention=assets.runtime_argument_convention(c_provider))
    write_json(out/'report.json',report)
    environment = {key:value for key,value in os.environ.items() if not key.startswith('BEND_')
                   and key not in ('NODE_OPTIONS','NODE_PATH','LD_PRELOAD')}
    environment.update(BEND_PUBLIC_BUILD_ROOT=str(out/'scratch'),BEND_TYPED_BASE_CACHE='off')
    bend = [str(ROOT/'selfhost/bend')]
    cli = [tools['bun']['file'],str(ROOT/'selfhost/cli.mjs')]
    numeric, argv, negative = [sources[name]['file'] for name in ('numeric','argv','negative-type')]
    policy = assets.native_toolchain(document,'x86')

    def child(name, command, expected=None, refusal=False, expected_stderr=b''):
        row = run(command,cwd=ROOT,stdout=out/(name+'.stdout'),stderr=out/(name+'.stderr'),
                  seconds=args.seconds,env=environment)
        report['jobs'].append(dict(name=name,**row)); write_json(out/'report.json',report)
        require((not row['complete'] and not row.get('timedOut') and row.get('exitCode',0) > 0) if refusal else row['complete'],
                'Unexpected command result: '+name)
        if expected is not None:
            require(verify(row['stdout']).read_bytes() == expected, 'Literal stdout differs: '+name)
        if not refusal and expected is not None:
            require(verify(row['stderr']).read_bytes() == expected_stderr, 'Unexpected program stderr: '+name)
        return row

    def accepted(name, **fields):
        report['cases'].append(dict(name=name,passed=True,**fields)); write_json(out/'report.json',report)

    def assembly(file):
        data = file.read_bytes()
        require(data and not data.startswith(b'\x7fELF') and b'\n.globl main\n' in data
                and b'\nmain:\n' in data and b'.note.GNU-stack' in data, 'Expected AMD64 SysV assembly')
        return pin(file)

    try:
        for name, command, required in [('native-help',bend,['OUTPUT.c','OUTPUT.s','--target x86','--run','--live']),
                                        ('js-help',cli,['.js/.mjs','Assembly target:','--target x86','OUTPUT.s','--run'])]:
            helped = child(name,command+['--help'])
            text = verify(helped['stdout']).read_text()
            require(helped['stderr']['bytes'] == 0 and all(word in text for word in required),'Public help omits a route: '+name)
            accepted(name)
        emitted, obj, linked = out/'program.s', out/'program.o', out/'linked'
        child('assembly',bend+['--target','x86',numeric,'-o',str(emitted)],b'')
        emitted_pin = assembly(emitted)
        child('assemble',[tools['assembler']['file'],*policy['assemblerFlags'],'-o',str(obj),str(emitted)])
        child('link',[tools['linker']['file'],*policy['linkerFlags'],str(obj),tools['qbe-runtime']['file'],*policy['libraries'],'-o',str(linked)])
        child('assembly-run',[str(linked),*assets.runtime_arguments(provider,application=True)],b'42\n')
        accepted('assembly-and-independent-link',assembly=emitted_pin,binary=pin(linked))
        binary = out/'program'
        child('elf',bend+['--target','x86',numeric,'-o',str(binary)],b'')
        require(binary.read_bytes()[:4] == b'\x7fELF','Expected an ELF executable')
        child('elf-run',[str(binary),*assets.runtime_arguments(provider,application=True)],b'42\n')
        accepted('elf',binary=pin(binary))
        child('run',bend+['--target','x86',numeric,'--run'],b'42\n'); accepted('run')
        child('argv',bend+['--target','x86',argv,'--run','--','a b','+RTS','--threads','7'],b'a b|+RTS|--threads|7|\n')
        accepted('argv')
        implicit = out/'implicit.s'
        child('js-implicit-assembly',cli+[numeric,'-o',str(implicit)],b'')
        accepted('js-implicit-assembly',assembly=assembly(implicit))
        child('js-explicit-run',cli+['--target','x86',numeric,'--run'],b'42\n'); accepted('js-explicit-run')
        c_source, c_binary = out/'ordinary.c', out/'ordinary-c'
        child('ordinary-c',bend+[numeric,'-o',str(c_source)],b'',
              expected_stderr=b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n')
        require(b'#include' in c_source.read_bytes(),'Default native route did not emit C')
        child('ordinary-c-build',[tools['c-compiler']['file'],*c_policy['flags'],*c_policy.get('includeFlags',[]),
                                 str(c_source),'-o',str(c_binary),*c_policy['libraries']])
        child('ordinary-c-run',[str(c_binary),*assets.runtime_arguments(c_provider,application=True)],b'42\n')
        accepted('ordinary-c',source=pin(c_source),binary=pin(c_binary))
        js_source = out/'ordinary.mjs'
        child('ordinary-js',cli+[numeric,'-o',str(js_source)],b'')
        child('ordinary-js-run',[tools['bun']['file'],str(js_source)],b'42\n')
        accepted('ordinary-js',source=pin(js_source))
        refused = out/'refused.s'
        child('negative-type',bend+['--target','x86',negative,'-o',str(refused)],refusal=True)
        require(not refused.exists(),'Rejected source published output'); accepted('negative-type')
        child('overwrite-source',bend+['--target','x86',numeric,'-o',numeric],refusal=True)
        verify(sources['numeric']); accepted('overwrite-source')
        child('overwrite-output',bend+['--target','x86',numeric,'-o',str(emitted)],refusal=True)
        verify(emitted_pin); accepted('overwrite-output')
        alias = out/'alias.s'; alias.symlink_to(out/'absent')
        child('symlink-output',bend+['--target','x86',numeric,'-o',str(alias)],refusal=True)
        require(alias.is_symlink() and not alias.exists(),'Dangling symlink was replaced'); accepted('symlink-output')
        report['changedInputs'] = changed_inputs(inputs)
        require(not report['changedInputs'],'Inputs changed during public controls')
        require(not list((out/'scratch').iterdir()),'Public temporary builds were not cleaned')
        report['complete'] = True
    except (OSError,ValueError,KeyError,TypeError) as error:
        report['error'] = str(error)
    write_json(out/'report.json',report)
    print('public x86',len(report['cases']),'complete',report['complete'])
    return 0 if report['complete'] else 1


if __name__ == '__main__': raise SystemExit(main())
