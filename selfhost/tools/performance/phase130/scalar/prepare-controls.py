"""Compose full scalar-code and long-prefix checks; do not execute targets."""
from prepare import HERE, BASE, BASE_SHA, pin, write, digest
from pathlib import Path
import json


def main():
    assert pin(BASE)['sha256'] == BASE_SHA
    order = HERE / 'order-v02.bend'
    workload = HERE / 'workload.bend'
    controls = HERE / 'semantic-controls.bend'
    prefix = workload.read_text().split('def p130s_digest(',1)[0]
    source = write('semantic-controls-v02.bend','import Base\n\n'+order.read_text()+'\n'+prefix+'\n'+controls.read_text())
    values = [code for n in [0,1,17] for code0 in digest(n)[1] for code in [code0,code0]]
    values += [2,2,2,2,1,1,3,3,16384]
    expected = write('semantic-controls.expected.json',json.dumps({'status':0,'stdout':''.join(str(x)+'\n' for x in values),'stderr':''},indent=2)+'\n')
    write('semantic-controls.cases.json',json.dumps({'complete':True,'cases':[{
      'name':'scalar-order-semantics','source':source,'expected':expected,'expectedStdoutEvidence':expected}]},indent=2)+'\n')
    write('semantic-controls.oracle.json',json.dumps({'complete':True,'method':pin(Path(__file__).resolve()),
      'modules':[pin(order),pin(workload),pin(controls)],'base':pin(BASE),
      'independentOracle':pin(HERE/'oracle.json'),'expected':expected,
      'scope':'69 exact output lines: full codepoint comparison vectors and long shared/equal/alias/prefix16K roots.'},indent=2)+'\n')


if __name__ == '__main__':
    main()
