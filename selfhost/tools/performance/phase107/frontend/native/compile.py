#!/usr/bin/env python3
"""Compile the admitted scalar Bend subset with native Bend/QBE/binutils, without Bun or Clang."""
import argparse
import json
import re
import shutil
import subprocess
import time
from pathlib import Path
from cache import ObjectCache, digest
from run import authenticate, pin, verify

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]


def main():
    begin = time.monotonic()
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('input', type=Path)
    p.add_argument('--image', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--cache', type=Path)
    p.add_argument('--entry', default='main')
    p.add_argument('--policy', choices=['raw', 'fast'], default='fast')
    p.add_argument('--base', choices=['cache', 'live'], default='cache')
    p.add_argument('--qbe', type=Path, default=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe')
    p.add_argument('--timeout', type=float, default=30)
    p.add_argument('--abi-salt', default='')
    a = p.parse_args()
    if not a.entry or not 0 < a.timeout <= 600:
        raise ValueError('invalid entry or timeout')
    identity = authenticate(a.image, a.base)
    source = pin(a.input)
    if source['bytes'] > 16777216:
        raise ValueError('input exceeds native reader limit')
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    methods = [pin(HERE/name) for name in ['compile.py', 'cache.py', 'run.py']]
    for method in methods:
        shutil.copyfile(method['file'], out/Path(method['file']).name)
    tools = {name:pin(file) for name,file in [('qbe',a.qbe),('as','/usr/bin/as'),('gcc','/usr/bin/gcc'),('ld','/usr/bin/ld')]}
    runner = pin(ROOT/'selfhost/tools/performance/phase106/cranelift/runner.c')
    report = dict(kind='phase107-native-qbe-compilation', version=1, complete=False,
                  generatedProgramExecuted=False, identity=identity, source=source,
                  methods=methods, tools=tools, runner=runner, jobs=[], cache=[],
                  options=dict(entry=a.entry, policy=a.policy, base=a.base, abiSalt=a.abi_salt),
                  authenticationSeconds=time.monotonic()-begin)
    save = lambda:(out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    save()

    def run(label, command, stdout=None):
        stem = digest(label)
        stdout = stdout or out/(stem+'.stdout')
        stderr = out/(stem+'.stderr')
        start = time.monotonic()
        job = dict(label=label, command=list(map(str,command)), status=None)
        report['jobs'].append(job)
        with stdout.open('xb') as output, stderr.open('xb') as error:
            try:
                result = subprocess.run(job['command'], stdout=output, stderr=error, timeout=a.timeout, check=False)
                job['status'] = result.returncode
            except subprocess.TimeoutExpired:
                job['failure'] = 'timeout'
        job.update(seconds=time.monotonic()-start, stdout=pin(stdout), stderr=pin(stderr))
        save()
        if job['status'] != 0:
            raise RuntimeError(label+' failed; see '+str(stderr))
        return job['seconds']

    try:
        units_file = out/'units.json'
        report['frontendSeconds'] = run('native-frontend', [identity['binary']['file'],source['file'],a.entry,'units',a.policy,a.base], units_file)
        payload = json.loads(units_file.read_text())
        program, units = payload['program'], payload['units']
        (out/'program.json').write_text(json.dumps(program, indent=2)+'\n')
        signatures = [dict(name=f['name'],params=[p['type'] for p in f['params']],result=f['result']) for f in program['functions']]
        abi = dict(version=1, entry='u32(const u64*)', selectedEntry=program['entry'], signatures=signatures,
                   target='x86_64-linux-sysv', salt=a.abi_salt)
        unit_identity = dict(abi=abi, producer=identity['binary']['sha256'], source=identity['compilerSource']['sha256'],
                             qbe=tools['qbe'], assembler=tools['as'], flags=['amd64_sysv'])
        cache = ObjectCache(a.cache, out, report['cache'])
        names, objects = set(), []
        backend_start = time.monotonic()
        for unit in units:
            name, text = unit['name'], unit['text']
            if not isinstance(name,str) or not re.fullmatch('[A-Za-z0-9_]+',name) or name in names or not isinstance(text,str):
                raise ValueError('invalid or duplicate transport unit')
            names.add(name)
            il = out/(digest(name)+'.ssa')
            il.write_text(text)

            def build(obj, asm, name=name, il=il):
                run(name+'-qbe',[tools['qbe']['file'],'-t','amd64_sysv','-o',asm,il])
                run(name+'-assemble',[tools['as']['file'],'-o',obj,asm])

            objects.append(cache.object(name,text,unit_identity,build,assembly=True))
        if 'entry' not in names or 'runtime' not in names:
            raise ValueError('missing required transport units')
        runobj = cache.object('common_runner',Path(runner['file']).read_text(),
                              dict(abi=1,gcc=tools['gcc'],assembler=tools['as'],flags=['-O2']),
                              lambda obj,asm:run('runner',[tools['gcc']['file'],'-O2','-c',runner['file'],'-o',obj]))
        report['backendSeconds'] = time.monotonic()-backend_start
        binary = out/'program'
        report['linkSeconds'] = run('link',[tools['gcc']['file'],runobj,*objects,'-o',binary])
        report['binary'] = pin(binary)
        for record in [source,runner,*methods,*tools.values(),*identity.values()]:
            if record is not None:
                verify(record)
        report.update(complete=True,seconds=time.monotonic()-begin)
        save()
        print(json.dumps(dict(binary=str(binary),seconds=report['seconds'],frontendSeconds=report['frontendSeconds'],
                              cacheHits=sum(event['hit'] for event in report['cache']),report=str(out/'report.json'))))
    except Exception as error:
        report.update(error=str(error),seconds=time.monotonic()-begin)
        save()
        raise


if __name__ == '__main__':
    main()
