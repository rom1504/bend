"""Freeze ordinary scalar-order ceiling inputs and an independent oracle.

Composes source only. Does not run Bend, compile code or benchmark targets.
"""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'
BASE_SHA = '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'


def pin(path):
    data = path.read_bytes()
    return {'file': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def write(name, text):
    path = HERE / name
    if path.exists() and path.read_text() != text:
        raise ValueError('Refusing to overwrite frozen input: ' + str(path))
    if not path.exists():
        path.write_text(text)
    return pin(path)


def pairs(size):
    pre = 'λ' * size
    return [(pre,pre),(pre,pre+'a'),(pre+'a',pre),(pre+'λ',pre+'中'),
            (pre+'🙂',pre+'λ'),(pre+'same',pre+'same'),(pre,'!'+pre),('!'+pre,pre),
            ('\0'+pre,'\1'+pre),(pre+'\ue000',pre+'\U00010000')]


def digest(size):
    value = 2166136261
    orders = []
    for a, b in pairs(size):
        # Python compares Unicode code points, independently of Bend cmp/reader.
        order = 1 if a < b else 3 if a > b else 2
        orders.append(order)
        value = (value * 16777619 + order) & 0xffffffff
    return value, orders


def main():
    assert pin(BASE)['sha256'] == BASE_SHA, 'Pinned Base changed'
    method = pin(Path(__file__).resolve())
    modules = [pin(HERE / n) for n in ['order.bend','workload.bend']]
    common = 'import Base\n\n' + (HERE / 'order.bend').read_text() + '\n'
    tail = '\n' + (HERE / 'workload.bend').read_text()
    rows = []
    stdout = ''.join(str(digest(n)[0])+'\n' for n in [0,1,17,128]) + '1\n129\n'
    expected = write('expected.json',json.dumps({'status':0,'stdout':stdout,'stderr':''},indent=2)+'\n')
    for variant, call in [('baseline','String.order(a,b)'),('scalar','p130s_order(a,b)')]:
        source = write(variant+'.bend',common+'def p130s_query(a: String, b: String) -> Cmp:\n  '+call+'\n'+tail)
        rows.append({'name':'scalar-order-'+variant,'source':source,'expected':expected,'expectedStdoutEvidence':expected})
    write('cases.json',json.dumps({'complete':True,'cases':rows},indent=2)+'\n')
    write('oracle.json',json.dumps({'complete':True,'method':method,'modules':modules,'base':pin(BASE),
      'scope':'Source-level ceiling only; source composition, no compiler changes or target execution.',
      'ordinary':[{'size':n,'digest':digest(n)[0],'orders':digest(n)[1]} for n in [0,1,17,128]],
      'timing':'-- repetitions warmups prefix_size reserved; checksum = repetitions*digest modulo2^32',
      'owned':1,'retainedSharedSuffixAndAlias':129},indent=2)+'\n')


if __name__ == '__main__':
    main()
