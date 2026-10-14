#!/usr/bin/env python3
"""Freeze ten modules and derive the body-tree candidate, without compiling.

The baseline layers the separately frozen owned-match patch onto current source.
Only NC_Code's body and its consumers change. Frozen outputs are never replaced.
"""
import difflib, hashlib, json, re
from pathlib import Path

here=Path(__file__).resolve().parent
root=here.parents[4]
names=['bridge','direct','flat','product','pattern','word-pattern','parallel','book','observer-emitter','observer-adapter']
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
manifest=root/'selfhost/src/compiler.json'
inputs=[pin(manifest),pin(here/'helpers.bend'),pin(Path(__file__))]
frozen={}
for name in names:
    source=root/f'selfhost/src/back/native/{name}.bend'
    text=source.read_text();inputs.append(pin(source))
    if name=='bridge':
        old=here.parent/'composition/bridge.baseline.bend'
        owned=here.parent/'composition/bridge.candidate.bend'
        assert text in [old.read_text(),owned.read_text()], 'Bridge is not frozen baseline or owned candidate'
        inputs.extend([pin(old),pin(owned)]);text=owned.read_text()
    frozen[name]=text
    with (here/'baseline'/f'{name}.bend').open('x') as f:f.write(text)

def split_top(text,separator):
    """Split a Bend expression outside balanced delimiters/quoted literals."""
    chunks=[];start=0;stack=[];quote=None;escape=False;i=0
    while i<len(text):
        c=text[i]
        if quote:
            if escape:escape=False
            elif c=='\\':escape=True
            elif c==quote:quote=None
        elif c in '\"\'':quote=c
        elif c in '([{':stack.append(c)
        elif c in ')]}':
            assert stack and '([{'.index(stack[-1])==')]}'.index(c)
            stack.pop()
        elif not stack and text.startswith(separator,i):
            chunks.append(text[start:i]);i+=len(separator);start=i;continue
        i+=1
    assert not stack and quote is None
    return chunks+[text[start:]]

def field_end(text,start):
    stack=[];quote=None;escape=False
    for i in range(start,len(text)):
        c=text[i]
        if quote:
            if escape:escape=False
            elif c=='\\':escape=True
            elif c==quote:quote=None
        elif c in '\"\'':quote=c
        elif c in '([{':stack.append(c)
        elif c in ')]}':
            if not stack:return i
            stack.pop()
        elif c==',' and not stack:return i
    raise AssertionError('Unterminated NC_Code constructor')

def tree_expr(expr):
    parts=split_top(expr.strip(),'++');pieces=[];strings=[]
    def flush():
        if strings:
            pieces.append('nct_leaf('+' ++ '.join(strings)+')');strings.clear()
    for raw in parts:
        item=raw.strip()
        if re.fullmatch(r'nc_body\([^\n]+\)|body|hit_body|miss_body',item):
            flush();pieces.append(item.replace('nc_body(', 'nc_text('))
        else:strings.append(item)
    flush()
    assert pieces
    result=pieces[-1]
    for piece in reversed(pieces[:-1]):result=f'nct_cat({piece}, {result})'
    return result

changes=[];candidate={}
for name,text in frozen.items():
    replacements=[]
    for m in re.finditer(r'NC_Code\{',text):
        prefix=text[text.rfind('\n',0,m.start())+1:m.start()]
        if re.fullmatch(r'\s*case\s+',prefix):continue
        start=m.end();end=field_end(text,start)
        first=text[start:end]
        if '+body: String' in first:continue
        replacement=tree_expr(first)
        replacements.append((start,end,replacement))
    for start,end,replacement in reversed(replacements):text=text[:start]+replacement+text[end:]
    if name=='bridge':
        text=text.replace('NC_Code{+body: String,','NC_Code{+body: NC_Text,')
        text=text.replace('hit_body: String, hit_segs:', 'hit_body: NC_Text, hit_segs:')
        original='''def nc_body(+x: NC_Code) -> String:
  match x:
    case NC_Code{+body, +segs, +n, +err, edges}: body'''
        replacement='''def nc_body(x: NC_Code) -> String:
  match x:
    case NC_Code{body, segs, n, err, edges}: nct_render(body)

@unsafe
def nc_text(x: NC_Code) -> NC_Text:
  match x:
    case NC_Code{body, segs, n, err, edges}: body'''
        assert text.count(original)==1;text=text.replace(original,replacement)
        helper=(here/'helpers.bend').read_text().removeprefix('import Base\n\n')
        text=text.replace('type NC_Code is Data:',helper+'\n'+'type NC_Code is Data:',1)
    if name=='flat':
        old='Nat.is_le(String.length(nc_body(code)), 4096n)'
        assert text.count(old)==1;text=text.replace(old,'nct_within(nc_text(code), 4096)')
    if name=='book':
        old='String.eq(nc_body(code), "")'
        assert text.count(old)==1;text=text.replace(old,'nct_empty(nc_text(code))')
    candidate[name]=text
    with (here/'candidate'/f'{name}.bend').open('x') as f:f.write(text)
    changes.append(dict(module=name,bodyConstructors=len(replacements),old=pin(here/'baseline'/f'{name}.bend'),new=pin(here/'candidate'/f'{name}.bend')))

patch=''.join(''.join(difflib.unified_diff(frozen[n].splitlines(True),candidate[n].splitlines(True),
                  fromfile=f'a/selfhost/src/back/native/{n}.bend',tofile=f'b/selfhost/src/back/native/{n}.bend')) for n in names)
with (here/'candidate.patch').open('x') as f:f.write(patch)
# Pin every active module, including those whose bytes are carried through.
module_pins=[pin(root/'selfhost'/m) for m in json.loads(manifest.read_text())['modules']]
receipt=dict(kind='phase89-body-chunks-source-derivation',complete=True,compiled=False,
    baseline='Ten frozen modules, with the separately frozen owned-match bridge patch already applied.',
    inputs=inputs,activeModules=module_pins,changes=changes,patch=pin(here/'candidate.patch'),
    boundaries=['nc_let_cut','nc_lambda','nd_join','nc_children','nc_parallel_finish','nc_append_book','nf_bodies','nq_wrap_segment'],
    inspections=dict(empty='nct_empty',inlineThreshold='nct_within(tree,4096), measured in Bend characters'))
with (here/'derivation.json').open('x') as f:json.dump(receipt,f,indent=2);f.write('\n')
print(json.dumps(dict(modules=len(changes),constructors=sum(x['bodyConstructors'] for x in changes),patchSha256=receipt['patch']['sha256'])))
