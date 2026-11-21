"""Apply selected, reversible ELF writer replacements to an explicit compiler source."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import source

RULES = {'checked-size':'x187_elf','layout':'x187_elf_layout_step','relocations':'x187_elf_reloc_step'}
OWNER = ROOT/'selfhost/src/back/x86/object-elf.bend'


def digest(data):
    return {'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}


def blocks(data):
    rows=source.blocks(data)[1]
    result={(r['kind'],r['name']):r for r in rows}
    assert len(rows)==len(result)
    return result


def body(row):
    return row['data'][row['headerOffset']-row['offset']:].rstrip()


def apply(data, selected):
    assert selected and len(set(selected))==len(selected)
    original=blocks(data); maintained=blocks(OWNER.read_bytes());expected={}; edits=[]
    protected=set(json.loads((ROOT/'selfhost/src/compiler.json').read_bytes())['protectedDeclarations'])
    for label in selected:
        key=('def',RULES[label]);module=(HERE/(label+'.bend')).read_bytes();pieces=blocks(module)
        assert {k for k in pieces if k in original}=={key} and not(set(pieces)&set(expected))
        assert not {k[1] for k in pieces}&protected
        assert body(original[key])==body(maintained[key])
        expected.update({k:body(v) for k,v in pieces.items()})
        row=original[key];start=row['offset'];end=start+len(row['data']);edits.append((start,end,b'\n'+module.strip()+b'\n'))
    for start,end,replacement in sorted(edits,reverse=True):data=data[:start]+replacement+data[end:]
    actual=blocks(data);assert set(original)<=set(actual)
    assert {k:body(v) for k,v in actual.items() if k not in original or body(v)!=body(original[k])}==expected
    return data,sorted(k[1] for k in expected)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',type=Path,required=True)
    p.add_argument('--out',type=Path);p.add_argument('--rules',choices=RULES,nargs='+',default=list(RULES));a=p.parse_args()
    d=a.source.read_bytes();result,changes=apply(d,a.rules)
    rec=dict(source=source.pin(a.source),selected=digest(result),rules=a.rules,changedDeclarations=changes,
             modules=[source.pin(HERE/(r+'.bend')) for r in a.rules],method=source.pin(__file__))
    if a.out:
        a.out.mkdir(parents=True,exist_ok=False);(a.out/'compiler.bend').write_bytes(result)
        (a.out/'report.json').write_text(json.dumps(rec,indent=2)+'\n')
    print(json.dumps(rec,indent=2))
