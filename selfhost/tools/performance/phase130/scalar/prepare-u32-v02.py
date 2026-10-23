"""Place the code projection before its safe baseline caller; retain v01."""
from prepare import HERE, BASE, BASE_SHA, pin, write
from pathlib import Path
import json


def main():
    assert pin(BASE)['sha256'] == BASE_SHA
    prior = json.loads((HERE/'oracle-u32-v01.json').read_text())
    order = HERE/'order-u32-v01.bend'
    workload = HERE/'workload-u32-v01.bend'
    assert pin(order) in prior['modules'] and pin(workload) in prior['modules']
    text = workload.read_text()
    index = text.index('def p130s_prefix(')
    before,after = text[:index],text[index:]
    expected = pin(HERE/'expected.json')
    rows = []
    for variant,call in [('baseline','p130s_code(String.order(a,b))'),('scalar','p130u_order(a,b)')]:
        body = 'import Base\n\n'+order.read_text()+'\n'+before
        body += 'def p130s_query(a: String, b: String) -> U32:\n  '+call+'\n\n'+after
        source = write(variant+'-u32-v02.bend',body)
        rows.append({'name':'scalar-u32-'+variant,'source':source,'expected':expected,'expectedStdoutEvidence':expected})
    write('cases-u32-v02.json',json.dumps({'complete':True,'cases':rows},indent=2)+'\n')
    write('oracle-u32-v02.json',json.dumps({'complete':True,'method':pin(Path(__file__).resolve()),
      'modules':[pin(order),pin(workload)],'base':pin(BASE),'independentOracle':pin(HERE/'oracle.json'),
      'expected':expected,'semanticControls':pin(HERE/'semantic-controls-u32-v01.cases.json'),
      'negativeV01':pin(HERE/'cases-u32-v01.json'),
      'change':'Safe p130s_code definition now precedes baseline p130s_query; no forward unfilled law, no unsafe annotation, semantics unchanged.'},indent=2)+'\n')


if __name__ == '__main__':
    main()
