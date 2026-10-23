"""Make all retained local bindings explicit after complete fixture review."""
from prepare import HERE, BASE, BASE_SHA, pin, write
from pathlib import Path
import json


def main():
    assert pin(BASE)['sha256'] == BASE_SHA
    order = HERE / 'order-v03.bend'
    old_workload = HERE / 'workload-v04.bend'
    old_controls = HERE / 'semantic-body-v04.bend'
    prior = json.loads((HERE/'oracle-v04.json').read_text())
    for source in [old_workload,old_controls]:
        assert pin(source) in prior['modules'], 'Frozen input drift'
    text = old_workload.read_text()
    replacements = {
      '+suffix = p130s_prefix(9n)': '+suffix : String = p130s_prefix(9n)',
      '+left = SCon{': '+left : String = SCon{',
      '+right = SCon{': '+right : String = SCon{',
      '+pairs = p130s_pairs(': '+pairs : List<&2,P130SCase> = p130s_pairs(',
    }
    for before,after in replacements.items():
        assert text.count(before) == 1, before
        text = text.replace(before,after)
    workload = write('workload-v05.bend',text)
    expected = pin(HERE / 'expected.json')
    rows = []
    for variant, call in [('baseline','String.order(a,b)'),('scalar','p130s_order(a,b)')]:
        body = 'import Base\n\n'+order.read_text()+'\n'
        body += 'def p130s_query(a: String, b: String) -> Cmp:\n  '+call+'\n\n'+text
        source = write(variant+'-v05.bend',body)
        rows.append({'name':'scalar-order-'+variant,'source':source,'expected':expected,'expectedStdoutEvidence':expected})
    write('cases-v05.json',json.dumps({'complete':True,'cases':rows},indent=2)+'\n')
    controls = old_controls.read_text()
    for before,after in [('+a = p130s_prefix(', '+a : String = p130s_prefix('),
                         ('+b = p130s_prefix(', '+b : String = p130s_prefix(')]:
        assert controls.count(before) == 1
        controls = controls.replace(before,after)
    controls_pin = write('semantic-body-v05.bend',controls)
    prefix = text.split('def p130s_digest(',1)[0]
    source = write('semantic-controls-v05.bend','import Base\n\n'+order.read_text()+'\n'+prefix+'\n'+controls)
    sem_expected = pin(HERE / 'semantic-controls.expected.json')
    write('semantic-controls-v05.cases.json',json.dumps({'complete':True,'cases':[{
      'name':'scalar-order-semantics','source':source,'expected':sem_expected,'expectedStdoutEvidence':sem_expected}]},indent=2)+'\n')
    write('oracle-v05.json',json.dumps({'complete':True,'method':pin(Path(__file__).resolve()),
      'modules':[pin(order),workload,controls_pin],'base':pin(BASE),'independentOracle':pin(HERE/'oracle.json'),
      'expected':expected,'semanticExpected':sem_expected,'negativeV04':pin(HERE/'cases-v04.json'),
      'change':'Explicit types for all retained String and corpus local bindings; no computation or expected output change.'},indent=2)+'\n')


if __name__ == '__main__':
    main()
