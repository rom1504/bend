"""Use an explicit Data pair in the retained list; preserve rejected fixtures."""
from prepare import HERE, BASE, BASE_SHA, pin, write
from pathlib import Path
import json


def main():
    assert pin(BASE)['sha256'] == BASE_SHA
    order = HERE / 'order-v03.bend'
    old_workload = HERE / 'workload.bend'
    assert pin(old_workload)['sha256'] == '1e56078d0c9b703af98f8933c7351323a551852309e7fd7fee684ae2eb0cb8fd'
    old = old_workload.read_text()
    start = old.index('def p130s_pairs(')
    stop = old.index('def p130s_digest(')
    pairs = '''def p130s_pairs(+prefix: String) -> List<&2,P130SCase>:
  [P130SCase{prefix,prefix},P130SCase{prefix,prefix ++ "a"},P130SCase{prefix ++ "a",prefix},
   P130SCase{prefix ++ "λ",prefix ++ "中"},P130SCase{prefix ++ "🙂",prefix ++ "λ"},
   P130SCase{prefix ++ "same",prefix ++ "same"},P130SCase{prefix,"!" ++ prefix},P130SCase{"!" ++ prefix,prefix},
   P130SCase{SCon{Char.from_u32(0),prefix},SCon{Char.from_u32(1),prefix}},
   P130SCase{prefix ++ SCon{Char.from_u32(57344),SNil{}},prefix ++ SCon{Char.from_u32(65536),SNil{}}}]

'''
    text = 'type P130SCase is Data:\n  P130SCase{left: String, right: String}\n\n'+old[:start]+pairs+old[stop:]
    text = text.replace('List<&2,String & String>','List<&2,P130SCase>')
    text = text.replace('case Con{pair,rest}:\n      (left,right) = pair\n', 'case Con{P130SCase{left,right},rest}:\n')
    workload = write('workload-v04.bend',text)
    expected = pin(HERE / 'expected.json')
    rows = []
    for variant, call in [('baseline','String.order(a,b)'),('scalar','p130s_order(a,b)')]:
        body = 'import Base\n\n'+order.read_text()+'\n'
        body += 'def p130s_query(a: String, b: String) -> Cmp:\n  '+call+'\n\n'+text
        source = write(variant+'-v04.bend',body)
        rows.append({'name':'scalar-order-'+variant,'source':source,'expected':expected,'expectedStdoutEvidence':expected})
    write('cases-v04.json',json.dumps({'complete':True,'cases':rows},indent=2)+'\n')
    old_controls = HERE / 'semantic-controls.bend'
    controls = old_controls.read_text().replace('List<&2,String & String>','List<&2,P130SCase>')
    controls = controls.replace('def p130sc_pair(pair: String & String) -> IO(Unit):\n  (a,b) = pair\n  p130sc_compare(a,b)',
      'def p130sc_pair(pair: P130SCase) -> IO(Unit):\n  match pair:\n    case P130SCase{a,b}: p130sc_compare(a,b)')
    controls_pin = write('semantic-body-v04.bend',controls)
    prefix = text.split('def p130s_digest(',1)[0]
    source = write('semantic-controls-v04.bend','import Base\n\n'+order.read_text()+'\n'+prefix+'\n'+controls)
    sem_expected = pin(HERE / 'semantic-controls.expected.json')
    write('semantic-controls-v04.cases.json',json.dumps({'complete':True,'cases':[{
      'name':'scalar-order-semantics','source':source,'expected':sem_expected,'expectedStdoutEvidence':sem_expected}]},indent=2)+'\n')
    write('oracle-v04.json',json.dumps({'complete':True,'method':pin(Path(__file__).resolve()),
      'modules':[pin(order),workload,controls_pin],'base':pin(BASE),'independentOracle':pin(HERE/'oracle.json'),
      'expected':expected,'semanticExpected':sem_expected,'negativeV03':pin(HERE/'cases-v03.json'),
      'change':'Base Pair is Type with quantities1/1, unsuitable for List<&2>. Explicit P130SCase Data container fixes the fixture; computation and oracle unchanged.'},indent=2)+'\n')


if __name__ == '__main__':
    main()
