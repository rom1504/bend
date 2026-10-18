#!/usr/bin/env python3
"""Root-only synthetic wide-ABI machine gate; requires the outer serial guard."""
import argparse
import hashlib
import json
import shutil
import subprocess
import time
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
def verify(row):
    path = Path(row['file'])
    if pin(path) != row: raise ValueError('changed ' + str(path))
    return path
def read(path): return json.loads(path.read_text())
def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['api','source','admission','runtime-build','out']:
        p.add_argument('--' + name, required=True, type=Path)
    p.add_argument('--clang', required=True, type=Path)
    a = p.parse_args(); out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    prepared = a.source.resolve(); source = read(prepared / 'manifest.json')
    api_record = read(a.api.parent / 'report.json')
    admission_path = a.admission if a.admission.is_file() else a.admission / 'manifest.json'
    admission = read(admission_path)
    runtime_path = a.runtime_build if a.runtime_build.is_file() else a.runtime_build / 'report.json'
    runtime = read(runtime_path)
    if source['kind'] != 'phase110-context-wide-source' or not source['complete']:
        raise ValueError('prepared synthetic wide source required')
    if not api_record['complete'] or api_record['source'] != source['source'] or api_record['api'] != pin(a.api):
        raise ValueError('checked API source differs')
    if admission['kind'] != 'phase110-context-call-admission' or not admission['complete'] or admission['inputs'][0] != source['source']:
        raise ValueError('wide source admission differs')
    if not all(row['ok'] for row in admission['controls']): raise ValueError('source refusal failed')
    if runtime['kind'] != 'phase110-context-runtime-build' or not runtime['complete'] or runtime['source'] not in admission['inputs']:
        raise ValueError('runtime build differs from admission')
    process = read(verify(runtime['process']))
    if not process['complete'] or process.get('returncode') != 0: raise ValueError('runtime process failed')
    inputs = [pin(Path(__file__)),pin(HERE / 'emit-wide.mjs'),pin(prepared / 'manifest.json'),pin(a.api.parent / 'report.json'),
              pin(admission_path),pin(runtime_path),*source['inputs'],*source['outputs'],*admission['inputs'],*admission['runtimeChain'],
              *runtime['inputs'],runtime['object'],runtime['process'],api_record['api'],pin(a.clang)]
    tools = dict(bun=ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun', qbe=ROOT / 'selfhost/build/phase108/toolchain/qbe-1.3/qbe',
                 gcc=Path(shutil.which('gcc')), assembler=Path(shutil.which('as')), clang=a.clang.resolve())
    inputs += [pin(path) for path in tools.values()]
    for row in inputs: verify(row)
    out.mkdir(); report = dict(kind='phase110-context-wide-machine', complete=False, synthetic=True,
        inputs=inputs,jobs=[],observations=[],scope='Four independent ownership observations for baseline/threaded/context and QBE/Clang. Synthetic ABI gate only; no timing or actual-source claim.',
        cFlags=['-O2','-fno-inline','-fno-optimize-sibling-calls'],cFlagReason='Keep both ordinary synthetic calls present so eleven-argument forwarding is exercised; no performance measurements.')
    def save(): (out / 'report.json').write_text(json.dumps(report,indent=2)+'\n')
    def run(label, command):
        command=list(map(str,command)); start=time.monotonic(); stdout=out/(label+'.stdout'); stderr=out/(label+'.stderr')
        with stdout.open('xb') as so, stderr.open('xb') as se:
            child=subprocess.run(command,cwd=ROOT,stdout=so,stderr=se,timeout=60)
        report['jobs'].append(dict(label=label,command=command,status=child.returncode,seconds=time.monotonic()-start,stdout=pin(stdout),stderr=pin(stderr)));save()
        if child.returncode: raise ValueError(label+' failed')
        return stdout
    save()
    try:
        emission=out/'emission';run('emit',[tools['bun'],HERE/'emit-wide.mjs',a.api,emission])
        runtime_source=Path(runtime['source']['file']).parent
        harness=out/'harness.o';run('harness',[tools['gcc'],'-O2','-I',runtime_source,'-c',prepared/'harness.c','-o',harness])
        expected=[json.loads(line) for line in (prepared/'expected.jsonl').read_text().splitlines()]
        for mode in ['baseline','threaded','context']:
            for backend in ['qbe','clang']:
                name=mode+'-'+backend;obj=out/(name+'.o');binary=out/name
                if backend=='qbe':
                    asm=out/(name+'.s');run(name+'-qbe',[tools['qbe'],'-t','amd64_sysv','-o',asm,emission/(mode+'.ssa')]);run(name+'-as',[tools['assembler'],'-o',obj,asm])
                else: run(name+'-compile',[tools['clang'],*report['cFlags'],'-std=c11','-c',emission/(mode+'.c'),'-o',obj])
                run(name+'-link',[tools['gcc'],'-no-pie',obj,verify(runtime['object']),harness,'-pthread','-lm','-o',binary])
                output=run(name,[binary]); actual=[json.loads(line) for line in output.read_text().splitlines()]
                if actual!=expected: raise ValueError(name+' complete oracle differs')
                report['observations'].append(dict(mode=mode,backend=backend,cases=4,exact=True,binary=pin(binary),object=pin(obj),stdout=pin(output)));save()
        for row in inputs: verify(row)
        report['complete']=True;save();print(json.dumps(dict(complete=True,synthetic=True,observations=24,timingsRun=False)))
    except BaseException as error: report['error']=repr(error);save();raise
if __name__ == '__main__': main()
