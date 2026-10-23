"""Freeze safe structural-first scalar ordering; preserve both rejected forms."""
from prepare import HERE, BASE, BASE_SHA, pin, write, digest
from pathlib import Path
import json


def main():
    assert pin(BASE)['sha256'] == BASE_SHA
    order = HERE / 'order-v03.bend'
    workload = HERE / 'workload.bend'
    expected = pin(HERE / 'expected.json')
    rows = []
    for variant, call in [('baseline','String.order(a,b)'),('scalar','p130s_order(a,b)')]:
        text = 'import Base\n\n'+order.read_text()+'\n'
        text += 'def p130s_query(a: String, b: String) -> Cmp:\n  '+call+'\n\n'+workload.read_text()
        source = write(variant+'-v03.bend',text)
        rows.append({'name':'scalar-order-'+variant,'source':source,'expected':expected,'expectedStdoutEvidence':expected})
    write('cases-v03.json',json.dumps({'complete':True,'cases':rows},indent=2)+'\n')
    controls = HERE / 'semantic-controls.bend'
    prefix = workload.read_text().split('def p130s_digest(',1)[0]
    source = write('semantic-controls-v03.bend','import Base\n\n'+order.read_text()+'\n'+prefix+'\n'+controls.read_text())
    sem_expected = pin(HERE / 'semantic-controls.expected.json')
    write('semantic-controls-v03.cases.json',json.dumps({'complete':True,'cases':[{
      'name':'scalar-order-semantics','source':source,'expected':sem_expected,'expectedStdoutEvidence':sem_expected}]},indent=2)+'\n')
    write('oracle-v03.json',json.dumps({'complete':True,'method':pin(Path(__file__).resolve()),
      'modules':[pin(order),pin(workload),pin(controls)],'base':pin(BASE),'independentOracle':pin(HERE/'oracle.json'),
      'expected':expected,'semanticExpected':sem_expected,'negativeV01':pin(HERE/'cases.json'),
      'negativeV02':pin(HERE/'cases-v02.json'),
      'change':'Structural String argument first; one ordered match follows previously safe Phase89 algorithm. No unsafe annotation; expected values unchanged.'},indent=2)+'\n')


if __name__ == '__main__':
    main()
