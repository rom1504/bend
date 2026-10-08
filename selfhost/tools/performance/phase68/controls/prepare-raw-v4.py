#!/usr/bin/env python3
"""Bind unchanged Phase67 raw diagnostics to two checked Phase68 images."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
def pin(value):
    item = value if isinstance(value, dict) else None
    p = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    data = p.read_bytes()
    r = dict(file=str(p), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert r['sha256'] == item['sha256']
        if 'bytes' in item:
            assert r['bytes'] == item['bytes']
    return r

def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['baseline', 'candidate', 'toolchain-recipe', 'out']:
        p.add_argument('--' + name, required=True, type=Path)
    a = p.parse_args()
    assert os.sched_getaffinity(0) == {0}
    inputs = [pin(__file__)]
    attempts = []
    for folder in [a.baseline, a.candidate]:
        item = pin(folder / 'attempt.json'); inputs.append(item)
        m = json.loads(Path(item['file']).read_text())
        assert m['checked'] and m['config']['strictExact']
        assert str(m['config']['cpu']) == '3' and m['config']['jobs'] == 1
        inputs.extend(pin(m[k]) for k in ['api','checkedApi','base','runtime','node'])
        inputs.extend(pin(r['frozen']) for r in m['snapshot']['sources'])
        attempts.append(m)
    before, selected = attempts
    assert before['node']['sha256'] == selected['node']['sha256']
    native = ROOT / 'selfhost/src/runtime/native/runtime.c'
    runtime = pin(native); inputs.append(runtime)
    for m in attempts:
        assert pin(Path(m['snapshot']['root']) / 'src/runtime/native/runtime.c')['sha256'] == runtime['sha256']
    recipe_pin = pin(a.toolchain_recipe); inputs.append(recipe_pin)
    recipe = json.loads(Path(recipe_pin['file']).read_text())
    assert recipe['kind'] == 'phase67-native-method-v2'
    assert recipe['api'] == selected['api']['file']
    inputs.extend(pin(r) for r in recipe['inputs'])
    assert recipe['clangArgs'][0] == '-isystem'
    controller = ROOT / 'selfhost/tools/performance/phase68/controls/raw-controls-v6.mjs'
    guard = ROOT / 'selfhost/tools/performance/phase32/bounded-run.py'
    inputs.extend([pin(controller),pin(guard)])
    out = a.out.resolve(); out.relative_to(ROOT / 'selfhost/build/phase68')
    assert not out.exists(); out.mkdir(parents=True)
    command = ['python3','-B',str(guard),'--seconds','180','--rss-mib','2048','--available-mib','4096',str(out/'supervisor'),'--','taskset','-c','3','env','CC='+recipe['clang'],'CPATH='+recipe['clangArgs'][1],'NODE_OPTIONS=','NODE_PATH=',selected['node']['file'],'--max-old-space-size=1024','--stack-size=4096',str(controller),recipe_pin['file'],before['api']['file'],selected['api']['file'],str(out/'execution')]
    result = dict(kind='phase68-raw-native-control-plan',targetExecuted=False,producer=pin(__file__),baselineApi=pin(before['api']),candidateApi=pin(selected['api']),runtime=runtime,controller=pin(controller),command=command,report=str(out/'execution/report.json'),inputs=inputs,scope='Phase67 raw diagnostics, original shared-error oracle, and unused raw product argument demand control on two exact checked images. Native runs at threads1 and4; mocked error is CPU only, not device conformance.')
    for item in inputs: pin(item)
    (out/'plan.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'plan.json'),targetsExecuted=False)))
if __name__ == '__main__': main()
