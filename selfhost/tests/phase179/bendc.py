#!/usr/bin/env python3
"""Measure historical bendc's actual checked source-to-executable CLI."""
import argparse
import json
import os
from pathlib import Path
import shutil
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, run, require, write_json, fresh_output, changed_inputs, same_bytes

TREE = ROOT / 'selfhost/build/phase158/historical'
BASE = ROOT / 'selfhost/build/phase158/upstream-2.0.32/bend2'
SEED = ROOT / 'selfhost/build/phase158/seed01/bendc'
CC = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
CC_ARGS = [str(CC), '-isystem', '/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang']
WRAPPER = ROOT / 'selfhost/tests/phase179/cc-record.py'

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('action', choices=['prepare', 'build', 'verify'])
p.add_argument('--prepared', type=Path)
p.add_argument('--binary', type=Path)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--seconds', type=float, default=120)
a = p.parse_args()
out = fresh_output(a.out, ROOT)
inputs = [pin(__file__), pin(ROOT / 'selfhost/tools/build/common.py'), pin(CC)]
inputs += [pin(f) for top in [TREE, BASE] for f in sorted(top.rglob('*'))
           if f.is_file() and f.suffix in {'.bend', '.c', '.h', '.js'}]
report = dict(kind='phase179-bendc-'+a.action, complete=False, inputs=inputs,
              affinity=sorted(os.sched_getaffinity(0)), checking=True,
              scope='Historical9c54842e checked self-build; cold process/program, cached runtime, warm filesystem permitted. Different source/compiler/toolchain from our QBE route.')
env = {k:v for k,v in os.environ.items() if not k.startswith(('BEND_', 'BENDC_', 'P179_'))
       and k not in {'LD_PRELOAD', 'LD_AUDIT', 'CC', 'CFLAGS', 'TMPDIR'}}
env.update(BEND_NO_FREE='1', BENDC_RT=str(TREE / 'rt'))
write_json(out / 'report.json', report)
try:
    if a.action == 'prepare':
        inputs += [pin(SEED), pin(ROOT / 'selfhost/build/phase158/seed01/report.json')]
        binary = out / 'bin/bendc'
        binary.parent.mkdir()
        shutil.copy2(SEED, binary)
        require(same_bytes(binary, SEED), 'Seed copy changed')
        runtime = binary.parent / 'bendrt.o'
        command = CC_ARGS + ['-O2', '-w', '-I', str(TREE / 'rt'), '-c',
                             str(TREE / 'rt/bendrt_impl.c'), '-o', str(runtime)]
        process = run(command, cwd=ROOT, stdout=out/'stdout', stderr=out/'stderr',
                      seconds=a.seconds, env=env)
        report['process'] = process
        require(process['complete'], 'Runtime acquisition failed')
        report.update(binary=pin(binary), runtime=pin(runtime),
                      commandPrefix=CC_ARGS, sourceSeed=pin(SEED))
    else:
        require(a.prepared is not None, '--prepared required')
        prepared = json.loads(a.prepared.read_text())
        require(prepared['complete'] and prepared['kind']=='phase179-bendc-prepare', 'Bad prepared assets')
        inputs += [pin(a.prepared), *prepared['inputs'], prepared['runtime'], prepared['binary'], pin(WRAPPER)]
        for row in inputs:
            verify(row)
        binary = verify(prepared['binary']) if a.action == 'build' else a.binary.resolve(strict=True)
        if a.action == 'verify':
            inputs.append(pin(binary))
        command = [str(binary), '--threads', '1', '--gpu', 'off', '--']
        if a.action == 'build':
            (out / 'tmp').mkdir()
            config = out / 'cc-config.json'
            write_json(config, dict(commandPrefix=prepared['commandPrefix']))
            env.update(CC=str(WRAPPER), TMPDIR=str(out/'tmp'),
                       P179_CC_RECORD=str(out), P179_CC_CONFIG=str(config))
            command += ['-o', str(out/'bendc')]
        command += [str(BASE/'base.bend'), 'bendc.bend']
        report['command'] = command
        report['environment'] = {k:env[k] for k in ['BEND_NO_FREE', 'BENDC_RT', 'CC', 'TMPDIR', 'P179_CC_RECORD', 'P179_CC_CONFIG'] if k in env}
        begun = time.monotonic()
        process = run(command, cwd=TREE, stdout=out/'stdout', stderr=out/'stderr',
                      seconds=a.seconds, env=env)
        report['process'] = process
        require(process['complete'] and process['stderr']['bytes']==0, 'Checked compiler execution failed')
        if a.action == 'build':
            require(process['stdout']['bytes']==0, 'Unexpected CLI stdout')
            require(same_bytes(out/'program.c', TREE/'seed/bendc.c'), 'Emitted C differs from independent committed seed')
            cc = json.loads((out/'cc.json').read_text())
            require(cc['exitCode']==0, 'Machine compiler failed')
            report.update(binary=pin(out/'bendc'), emittedC=pin(out/'program.c'),
                          seedExact=True, machine=cc,
                          sourceThroughCaptureSeconds=cc['compilerStartedMonotonic']-begun,
                          totalSeconds=process['seconds'],
                          buildRemainderSeconds=process['seconds']-cc['machineSeconds'])
        else:
            require(same_bytes(out/'stdout', TREE/'seed/bendc.c'), 'Rebuilt compiler does not reproduce seed')
            report.update(seedExact=True, emittedC=pin(out/'stdout'), totalSeconds=process['seconds'])
    report['changedInputs'] = changed_inputs(inputs)
    require(not report['changedInputs'], 'Input changed during execution')
    report['complete'] = True
except BaseException as error:
    report['error'] = repr(error)
write_json(out/'report.json', report)
print(json.dumps({k:v for k,v in report.items() if k in ['complete','error','totalSeconds','sourceThroughCaptureSeconds','seedExact','buildRemainderSeconds']}))
sys.exit(0 if report['complete'] else 1)
