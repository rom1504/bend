"""Freeze direct-U32 comparison variants; do not compile or execute targets."""
from prepare import HERE, BASE, BASE_SHA, pin, write
from pathlib import Path
import json


def main():
    assert pin(BASE)['sha256'] == BASE_SHA
    order = HERE / 'order-u32-v01.bend'
    old_workload = HERE / 'workload-v05.bend'
    prior = json.loads((HERE/'oracle-v05.json').read_text())
    assert pin(old_workload) in prior['modules']
    text = old_workload.read_text()
    for before,after in [
      ('p130s_code(p130s_query(left,right))','p130s_query(left,right)'),
      ('p130s_code(p130s_query(left,left))','p130s_query(left,left)'),
      ('p130s_code(p130s_query(p130s_prefix(7n),p130s_prefix(8n)))','p130s_query(p130s_prefix(7n),p130s_prefix(8n))')]:
        assert before in text
        text = text.replace(before,after)
    workload = write('workload-u32-v01.bend',text)
    expected = pin(HERE / 'expected.json')
    rows = []
    for variant, call in [('baseline','p130s_code(String.order(a,b))'),('scalar','p130u_order(a,b)')]:
        body = 'import Base\n\n'+order.read_text()+'\n'
        body += 'def p130s_query(a: String, b: String) -> U32:\n  '+call+'\n\n'+text
        source = write(variant+'-u32-v01.bend',body)
        rows.append({'name':'scalar-u32-'+variant,'source':source,'expected':expected,'expectedStdoutEvidence':expected})
    write('cases-u32-v01.json',json.dumps({'complete':True,'cases':rows},indent=2)+'\n')
    old_controls = HERE / 'semantic-body-v05.bend'
    assert pin(old_controls) in prior['modules']
    controls = old_controls.read_text().replace('p130s_code(p130s_order(a,b))','p130u_order(a,b)')
    controls_pin = write('semantic-body-u32-v01.bend',controls)
    prefix = text.split('def p130s_digest(',1)[0]
    source = write('semantic-controls-u32-v01.bend','import Base\n\n'+order.read_text()+'\n'+prefix+'\n'+controls)
    sem_expected = pin(HERE / 'semantic-controls.expected.json')
    write('semantic-controls-u32-v01.cases.json',json.dumps({'complete':True,'cases':[{
      'name':'scalar-u32-semantics','source':source,'expected':sem_expected,'expectedStdoutEvidence':sem_expected}]},indent=2)+'\n')
    write('oracle-u32-v01.json',json.dumps({'complete':True,'method':pin(Path(__file__).resolve()),
      'modules':[pin(order),workload,controls_pin],'base':pin(BASE),'independentOracle':pin(HERE/'oracle.json'),
      'expected':expected,'semanticExpected':sem_expected,'priorCmpCeiling':pin(HERE/'cases-v05.json'),
      'change':'Both query interfaces return U32 directly; candidate uses two Bool predicate state lanes and primitive unsigned comparisons, without Cmp construction or projection.'},indent=2)+'\n')


if __name__ == '__main__':
    main()
