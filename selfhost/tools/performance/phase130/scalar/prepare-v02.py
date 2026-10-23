"""Freeze the binder-order correction; original v01 files remain unchanged."""
from prepare import HERE, BASE, BASE_SHA, pin, write, digest
from pathlib import Path
import json


def main():
    assert pin(BASE)['sha256'] == BASE_SHA
    order = HERE / 'order-v02.bend'
    workload = HERE / 'workload.bend'
    expected = pin(HERE / 'expected.json')
    rows = []
    for variant, call in [('baseline','String.order(a,b)'),('scalar','p130s_order(a,b)')]:
        text = 'import Base\n\n' + order.read_text() + '\n'
        text += 'def p130s_query(a: String, b: String) -> Cmp:\n  '+call+'\n\n'
        text += workload.read_text()
        source = write(variant+'-v02.bend',text)
        rows.append({'name':'scalar-order-'+variant,'source':source,'expected':expected,'expectedStdoutEvidence':expected})
    write('cases-v02.json',json.dumps({'complete':True,'cases':rows},indent=2)+'\n')
    write('oracle-v02.json',json.dumps({'complete':True,'method':pin(Path(__file__).resolve()),
      'modules':[pin(order),pin(workload)],'base':pin(BASE),'independentOracle':pin(HERE/'oracle.json'),
      'expected':expected,'negativeV01':pin(HERE/'cases.json'),
      'change':'Reorder scalar accumulator before strings to satisfy pattern binder order; expected values unchanged.'},indent=2)+'\n')


if __name__ == '__main__':
    main()
