#!/usr/bin/env python3
"""Root-only bounded JS-API/native-control qualifier; every target is serial."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BUILD = ROOT/'selfhost/build/phase98'
GUARD = ROOT/'selfhost/tools/performance/phase86/guard.py'
STAGE0 = ROOT/'selfhost/tools/stage0-library.mjs'
UPSTREAM = ROOT/'selfhost/.bootstrap/upstream-phase66'
CLANG = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path): return json.loads(Path(path).read_text())
def save(path, data): path.write_text(json.dumps(data, indent=2)+'\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--recipe', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--prepare-only', action='store_true')
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists(); out.mkdir(parents=True)
    inputs = {}; report = dict(kind='phase98-scoped-observer-small-qualification', complete=False,
                               executionPerformed=False, rows=[], inputs=[])
    def bind(path):
        row = pin(path); assert inputs.setdefault(row['file'], row) == row; return row
    def verify_tree(value):
        if isinstance(value, dict):
            if {'file','bytes','sha256'} <= value.keys(): assert bind(value['file']) == value
            else:
                for child in value.values(): verify_tree(child)
        elif isinstance(value, list):
            for child in value: verify_tree(child)
    def flush(): report['inputs'] = list(inputs.values()); save(out/'report.json', report)
    try:
        recipe = read(args.recipe); bind(args.recipe); verify_tree(recipe)
        assert recipe['complete'] and recipe['source']['sha256'] == 'd04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
        original = Path(recipe['source']['file']).read_text(); replay = original
        for change in recipe['changes']:
            before, after = change.get('old', change.get('before')), change.get('new', change.get('after'))
            if 'offset' in change:
                offset = change['offset']; assert replay[offset:offset+len(before)] == before
                replay = replay[:offset]+after+replay[offset+len(before):]
            else:
                assert before and replay.count(before) == 1
                replay = replay.replace(before, after)
        assert replay == Path(recipe['candidate']['file']).read_text()
        for file in [__file__, HERE/'qualify.mjs', HERE/'permission-cases.json', HERE/'qualification.json',
                     HERE/'source-audit.json', STAGE0, GUARD, CLANG,
                     ROOT/'selfhost/tools/typed-driver.mjs', ROOT/'selfhost/dist/typed-api.mjs']:
            bind(file)
        audit = read(HERE/'source-audit.json'); verify_tree(audit)
        upstream = read(ROOT/'selfhost/build/phase86/upstream.json'); verify_tree(upstream)
        assert upstream['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        bind(ROOT/'selfhost/build/phase86/upstream.json')
        cases = read(HERE/'permission-cases.json')['cases']; assert len(cases) == 18
        exports = ['nc_compile_checked','nr_compile_prepared','nr_prepare','nc_compile','nc_foreign_paths']
        extra = ''
        for i, row in enumerate(cases):
            row['exportName'] = f'p98_permission_case_{i:02}'
            extra += '\n@unsafe\ndef '+row['exportName']+'() -> Bool:\n  '+row['expression']+'\n'
        candidate_source = out/'candidate-api.bend'; candidate_source.write_text(replay+extra); bind(candidate_source)
        plan = dict(kind='phase98-observer-qualifier-inputs', method=bind(__file__), recipe=bind(args.recipe),
                    audit=bind(HERE/'source-audit.json'), cases=cases,
                    apis={'baseline':str(out/'baseline.mjs'), 'candidate':str(out/'candidate.mjs')},
                    sourceInputs={'baseline':recipe['source'], 'candidate':bind(candidate_source)},
                    controls=[
                        dict(id='real-io', source=bind(HERE.parent/'comparison/held-io-smoke01.bend'),
                             stdout='λ🙂common\nλ🙂common\nVar-suffix\nVar-other\n\n\n', stderr='1\n0\n1\n',
                             observerOwner='p98_eq_walk', scalar=0),
                        dict(id='generic-array', source=bind(HERE/'generic-array-string-v2.bend'),
                             stdout='Łx:true\nŁx\nŁx\n', stderr='', observerOwner='p98_array_string_walk', scalar=0),
                        dict(id='schema-refusals', source=bind(HERE/'schema-refusals.bend'), stdout='30\n',stderr='',
                             forbiddenOwners=['p98_array_probe','p98_word_view'], scalar=1)],
                    rawCases=bind(ROOT/'selfhost/tools/performance/phase70/observer-controls/raw-observer-cases-v1.mjs'),
                    unknownProvider=bind(ROOT/'selfhost/tools/performance/phase70/observer-controls/v2/foreign-refusal.bend'),
                    scope='Checked upstream-JS APIs from exact baseline/candidate source; installed frontend prepares the same books. Exact C outputs are qualified by full tiny-program execution, not old C identity. No native compiler image or B2 qualification.')
        save(out/'plan.json',plan); bind(out/'plan.json')
        commands = []
        node = shutil.which('node'); assert node; bind(node)
        for role in ['baseline','candidate']:
            roots = exports + ([row['exportName'] for row in cases] if role=='candidate' else [])
            commands.append(dict(name='api-'+role, seconds=150, rss=4096, available=16384,
                                 argv=['env','BEND_UPSTREAM='+str(UPSTREAM),node,'--stack-size=65536','--max-old-space-size=3072',
                                       str(STAGE0),plan['sourceInputs'][role]['file'],plan['apis'][role],*roots]))
        commands.append(dict(name='emission', seconds=180,rss=4096,available=16384,
                             argv=[node,'--stack-size=16384','--max-old-space-size=3072',str(HERE/'qualify.mjs'),str(out/'plan.json'),str(out/'emission')]))
        save(out/'commands.json',commands)
        report.update(plan=bind(out/'plan.json'), commands=commands,
                      scope=plan['scope'], otherQualificationGroups='Formal/lifetime corpus, profiling and real compiler measurement remain separately reported; this method does not claim all12 planned groups complete.')
        flush()
        if args.prepare_only:
            report.update(complete=True,preparedOnly=True); flush(); return
        def run(name, argv, seconds=60, rss=1024, available=4096):
            folder=out/name
            command=[sys.executable,'-B',str(GUARD),'--out',str(folder),'--seconds',str(seconds),
                     '--rss-mib',str(rss),'--available-mib',str(available),'--cpu','3','--',*map(str,argv)]
            report['executionPerformed']=True; flush()
            job=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
            row=dict(name=name,command=command,launcherExit=job.returncode)
            report['rows'].append(row)
            (out/(name+'.launcher.stdout')).write_text(job.stdout); (out/(name+'.launcher.stderr')).write_text(job.stderr)
            row['guard']=bind(folder/'process.json'); process=read(folder/'process.json'); row['process']=process; flush()
            assert job.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'),name
            return folder
        for command in commands: run(**command)
        emission=read(out/'emission/report.json'); assert emission['complete']; report['emission']=bind(out/'emission/report.json')
        for row in emission['programs']:
            c=Path(row['c']['file']); assert pin(c)==row['c']; bind(c)
            binary=out/(row['id']+'-program')
            run(row['id']+'-clang',[CLANG,'-isystem',CLANG.parent.parent/'include/clang','-O2',c,'-o',binary,'-lm','-pthread'],90,2048,4096)
            bind(binary)
            execution=run(row['id']+'-run',[binary,'--threads','1','--gpu','off'],30,1024,4096)
            stdout=(execution/'stdout.log').read_text(); stderr=(execution/'stderr.log').read_text()
            assert stdout==row['stdout'] and stderr==row['stderr'],(row['id'],stdout,stderr)
            report['rows'][-1]['fullOutputExact']=True; flush()
        for row in inputs.values(): assert pin(row['file'])==row
        report.update(complete=True,inputsUnchanged=True,fullPrograms=len(emission['programs']))
    except BaseException as error:
        report['error']=repr(error); raise
    finally: flush()


if __name__ == '__main__': main()
