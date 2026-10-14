#!/usr/bin/env python3
"""Offline standalone NC_Text controls plus a Python code-point oracle."""
import hashlib,json
from pathlib import Path
here=Path(__file__).resolve().parent
helpers=here/'helpers.bend';out=here/'controls.bend'
head=helpers.read_text()+'''
type P89TextCase is Data:
  P89TextCase{+name: String, +text: String, +empty: Bool, +within0: Bool, +within4095: Bool, +within4096: Bool, +within4097: Bool}

@unsafe
def p89_text_case(name: String, +tree: NC_Text) -> P89TextCase:
  P89TextCase{name, nct_render(tree), nct_empty(tree), nct_within(tree, 0), nct_within(tree, 4095), nct_within(tree, 4096), nct_within(tree, 4097)}

@unsafe
def p89_text_left(+n: U32, +leaf: NC_Text, tree: NC_Text) -> NC_Text:
  match n:
    case 0: tree
    case _: p89_text_left(U32.sub(n, 1), leaf, nct_cat(tree, leaf))

@unsafe
def p89_text_right(+n: U32, +leaf: NC_Text, tree: NC_Text) -> NC_Text:
  match n:
    case 0: tree
    case _: p89_text_right(U32.sub(n, 1), leaf, nct_cat(leaf, tree))

@unsafe
def p89_text_shared(+tree: NC_Text) -> NC_Text:
  nct_cat(tree, nct_cat(nct_leaf("|"), tree))

@unsafe
def main() -> List<&2, P89TextCase>:
'''
q=lambda s:json.dumps(s,ensure_ascii=False)
cases=[]
def add(name,expr,expected):cases.append(dict(name=name,expression=expr,expected=expected))
add('empty-literal','nct_leaf("")','')
add('empty-node','NC_Empty{}','')
add('left-empty','nct_cat(nct_leaf(""), nct_leaf("R"))','R')
add('right-empty','nct_cat(nct_leaf("L"), nct_leaf(""))','L')
add('both-empty','nct_cat(nct_leaf(""), nct_cat(nct_leaf(""), NC_Empty{}))','')
add('nested-order','nct_cat(nct_cat(nct_leaf("a"), nct_leaf("bc")), nct_cat(nct_leaf("de"), nct_leaf("f")))','abcdef')
add('unicode','nct_cat(nct_leaf("λ"), nct_leaf("😀\\n"))','λ😀\n')
add('shared-leaf','p89_text_shared(nct_leaf("shared"))','shared|shared')
add('shared-tree','p89_text_shared(nct_cat(nct_leaf("A"), nct_leaf("B")))','AB|AB')
for direction in ['left','right']:
    add(f'skew-{direction}-8192',f'p89_text_{direction}(8192, nct_leaf("x"), NC_Empty{{}})','x'*8192)
for alphabet,character in [('ascii','a'),('unicode','😀')]:
    for n in [4095,4096,4097]:
        add(f'{alphabet}-{n}',f'p89_text_left({n}, nct_leaf({q(character)}), NC_Empty{{}})',character*n)
add('split-4096','nct_cat(p89_text_left(2048, nct_leaf("a"), NC_Empty{}), p89_text_right(2048, nct_leaf("😀"), NC_Empty{}))','a'*2048+'😀'*2048)
add('split-4097','nct_cat(p89_text_left(2048, nct_leaf("a"), NC_Empty{}), p89_text_right(2049, nct_leaf("😀"), NC_Empty{}))','a'*2048+'😀'*2049)
source=head+'  [\n    '+',\n    '.join(f'p89_text_case({q(c["name"])}, {c["expression"]})' for c in cases)+'\n  ]\n'
with out.open('x') as f:f.write(source)
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
oracle={c['name']:dict(text=c['expected'],empty=not c['expected'],within0=len(c['expected'])<=0,
                      within4095=len(c['expected'])<=4095,within4096=len(c['expected'])<=4096,
                      within4097=len(c['expected'])<=4097) for c in cases}
with (here/'controls.json').open('x') as f:json.dump(dict(kind='phase89-body-tree-controls',source=pin(out),inputs=[pin(helpers),pin(Path(__file__))],expected=oracle),f,ensure_ascii=False,indent=2);f.write('\n')
print(json.dumps(dict(cases=len(cases),source=pin(out))))
