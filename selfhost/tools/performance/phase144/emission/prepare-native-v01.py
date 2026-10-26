"""Extract exact Bend renderers and serialize an already captured input as data."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.setrecursionlimit(20000)
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('source_blocks',ROOT/'selfhost/tools/performance/phase131/prepare.py')
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
SOURCE=ROOT/'selfhost/build/phase143/integrated-source03/compiler.bend'
SHA='a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e'
ROOTS=['p134e_private','p134e_legacy','p134e_public']


def clean(text):return re.sub(r'"(?:\\.|[^"\\])*"|\#[^\n]*',' ',text)


def schemas(blocks):
    result={'Con':['head','tail'],'Nil':[],'True':[],'False':[]}
    owners={}
    for name,body in blocks.items():
        if not body.startswith('type '):continue
        for m in re.finditer(r'^\s+([A-Za-z0-9_.]+)\{([^{}]*)\}',body,re.M):
            ctor,fields=m.groups()
            assert ctor not in owners,ctor
            owners[ctor]=name
            result[ctor]=re.findall(r'(?:^|,)\s*\+?([A-Za-z_][A-Za-z0-9_]*)\s*:',fields)
    return result,owners


def closure(blocks,owners):
    seen=set();todo=ROOTS[:]
    while todo:
        name=todo.pop()
        if name in seen:continue
        seen.add(name)
        tokens=set(re.findall(r'\b[A-Za-z_][A-Za-z0-9_.]*\b',clean(blocks[name])))
        todo+=list(((tokens&set(blocks))|{owners[x]for x in tokens&set(owners)})-seen)
    return seen


def literal(value,schema):
    if isinstance(value,str):
        assert all(ord(c)>=32 or c in '\n\r\t' for c in value),'Unsupported control character in Bend literal'
        return json.dumps(value,ensure_ascii=False)
    if isinstance(value,bool):return 'True{}' if value else 'False{}'
    if isinstance(value,int):
        assert 0<=value<=4294967295
        return str(value)
    assert isinstance(value,dict) and '$' in value,type(value)
    ctor=value['$'];assert ctor in schema,'Unknown constructor '+ctor
    fields=schema[ctor];assert set(value)=={'$',*fields},(ctor,set(value),fields)
    if ctor=='Con':
        items=[];current=value
        while isinstance(current,dict) and current.get('$')=='Con':
            assert set(current)=={'$','head','tail'}
            items.append(literal(current['head'],schema));current=current['tail']
        assert current=={'$':'Nil'},'Improper list'
        return '['+','.join(items)+']'
    return ctor+'{'+','.join(literal(value[f],schema)for f in fields)+'}'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--capture',type=Path,required=True);p.add_argument('--case',required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
    capture=json.loads(a.capture.read_text());assert capture['complete'] and capture['completeParentProductExact']
    row=next(r for r in capture['fixtures']if r['name']==a.case)
    inputs=[C.pin(__file__),C.pin(C.__file__),C.pin(a.capture),*capture['inputs'],row['data'],row['expected'],
      C.pin(HERE/'body-tail-v01.bend'),C.pin(HERE/'wrappers-v02.bend'),C.pin(HERE/'wrappers-v02.json'),C.pin(HERE/'native-workload-v01.bend')]
    for pin in inputs:assert C.pin(pin['file'])==pin
    assert C.pin(SOURCE)['sha256']==SHA
    source=SOURCE.read_text();blocks=C.blocks(source);schema,owners=schemas(blocks)
    selected=closure(blocks,owners)
    datum=json.loads(Path(row['data']['file']).read_text())
    assert datum['kind']==row['kind']
    kindmap={'P134Private':('P144EFPrivate','P113DFunction'),'P134Legacy':('P144EFLegacy','P112RegionEntry'),'P134Public':('P144EFPublic','N111Segment')}
    ctor,typ=kindmap[datum['kind']]
    declarations='''type P144EFInput is Data:
  P144EFPrivate{function: P113DFunction}
  P144EFLegacy{entry: P112RegionEntry}
  P144EFPublic{segment: N111Segment}

@unsafe
def p144ef_render(input: P144EFInput, context: P134Context) -> String:
  match input:
    case P144EFPrivate{function}: p134e_private(function,context)
    case P144EFLegacy{entry}: p134e_legacy(entry,context)
    case P144EFPublic{segment}: p134e_public(segment,context)

'''
    declarations+='def p144ef_value() -> P144EFInput:\n  '+ctor+'{'+literal(datum['value'],schema)+'}\n\n'
    declarations+='def p144ef_context() -> P134Context:\n  '+literal(datum['context'],schema)+'\n\n'
    assert len(declarations.encode())<=4*1024*1024,'Native data fixture cap'
    replacements=C.blocks((HERE/'wrappers-v02.bend').read_text())
    common=(HERE/'native-workload-v01.bend').read_text()
    out.mkdir(parents=True);variants={}
    for variant in ['baseline','body-tail']:
        used={name:body for name,body in blocks.items()if name in selected}
        changed=[]
        if variant=='body-tail':
            for name in selected&set(replacements):used[name]=replacements[name];changed.append(name)
        text='import Base\n\n'+''.join(used.values())
        if variant=='body-tail':text+='\n'+(HERE/'body-tail-v01.bend').read_text()
        text+='\n'+declarations+common
        path=out/(variant+'.bend');path.write_text(text)
        variants[variant]=dict(source=C.pin(path),changed=sorted(changed),physicalLines=len(text.splitlines()))
    (out/'expected.stdout').write_bytes(Path(row['expected']['file']).read_bytes())
    report=dict(kind='phase144-extracted-native-render-fixture',complete=True,checked=False,targetsRun=False,
       inputs=inputs,parent=C.pin(SOURCE),captured=row,expected=C.pin(out/'expected.stdout'),variants=variants,
       extracted=[dict(name=n,sha256=C.hashlib.sha256(blocks[n].encode()).hexdigest(),firstLine=source.count('\n',0,source.index(blocks[n]))+1)for n in blocks if n in selected],
       ordinary=dict(argv=[],stdout='exact expected.stdout',stderr='',exitCode=0),
       timed=dict(argv=['100'],stdout='one decimal IO.now elapsed-millisecond line',boundary='Complete selected wrapper rendering, File.write and close; shared immutable input construction occurs before timing',calibrated=False),
       scope='Native full-function renderer fixture, not full compiler. Exact source extraction; only candidate body/footer fusion. No host compiler lowering, no reconstructed QBE oracle, no new runtime.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(variants=variants,expected=report['expected'],declarations=len(selected),dataBytes=len(declarations.encode()))))


if __name__=='__main__':main()
