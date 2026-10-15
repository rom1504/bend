#!/usr/bin/env python3
"""Seal completed native06 admission before canonical runtime migration; no targets."""
import argparse,json,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
P=ROOT/'selfhost/tools/performance'
sys.path.insert(0,str(P/'phase88'))
from native_support import pin,verify
MUTABLE=['selfhost/src/runtime/native/runtime.c','selfhost/src/runtime/native/runtime-template.json','selfhost/tools/typed-driver.mjs']

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('out',type=Path);args=ap.parse_args()
    out=args.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase90');out.mkdir(parents=True,exist_ok=False)
    image=ROOT/'selfhost/build/phase90/compiler-own-native06'
    gates=ROOT/'selfhost/build/phase90/own-native06-gates/gates.json'
    method=P/'phase90/accessor-methods01/emit-qualified.py'
    assert pin(method)['sha256']=='d81378fade2761923ccb4957a567c00e70054dd1ee04ce1ef28371cddb57a283'
    assert pin(image)['sha256']=='2914c0a45305684013bbfc8dd4172f4ddd55347196a4bb3561ec34e0bf60804d'
    command=[sys.executable,'-B',str(method),str(image),str(gates),str(out/'admission'),'--check-only']
    # Existing verifier checks actual source/build/oracle/8 guard receipts; it runs no targets.
    subprocess.run(command,check=True)
    admission_pin=pin(out/'admission/report.json');admission=json.loads(Path(admission_pin['file']).read_text())
    assert admission['complete'] and admission['passed'] and admission['checkOnly'] and not admission['executionPerformed']
    auth=admission['producer']['authentication']
    assert auth['source']['sha256']=='d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
    assert auth['compiledC']['sha256']=='a4cd3990972608fd71542c95cd1e6e20d77c1001ce65222d0c64bdea40bdd612'
    mappings=[]
    for relative in MUTABLE:
        original=pin(ROOT/relative);copy=out/'prior'/relative;copy.parent.mkdir(parents=True,exist_ok=True)
        copy.write_bytes(Path(original['file']).read_bytes());frozen=pin(copy)
        assert all(frozen[k]==original[k] for k in ['sha256','bytes']);verify(original)
        mappings.append(dict(original=original,frozen=frozen))
    inputs={p['file']:verify(p) for p in admission['inputs']}
    inputs.update({m['original']['file']:m['original'] for m in mappings})
    for p in inputs.values():verify(p)
    result=dict(kind='phase90-native06-prior-runtime-transition-seal',complete=True,executionPerformed=False,
        method=pin(__file__),verifier=pin(method),verificationCommand=command,admission=admission_pin,
        producer=auth,qualification=pin(gates),cache=admission['cache'],source=admission['source'],
        mutableMappings=mappings,inputs=list(inputs.values()),
        scope='Exact historical native06 admission with three explicit byte-identical mutable-path snapshots. No receipt rewritten, runtime rebind, new compilation or native07 qualification.')
    target=out/'transition.json';target.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(transition=pin(target),frozenBytes=sum(m['frozen']['bytes'] for m in mappings),targetExecuted=False)))

if __name__=='__main__':main()
