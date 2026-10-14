#!/usr/bin/env python3
"""Exact declaration derivative of frozen native-owned01; no compiler runs."""
import hashlib,json,re,sys
from pathlib import Path
assert len(sys.argv)==2,'Usage: freeze-native.py NEW_NATIVE_COMPILER.bend'
here=Path(__file__).resolve().parent;out=Path(sys.argv[1])
parent=here.parent/'composition/compiler-native-owned01.bend'
parent_receipt=Path(str(parent)+'.derivation.json')
receipt_path=here/'derivation.json';receipt=json.loads(receipt_path.read_text())
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
assert pin(parent)==json.loads(parent_receipt.read_text())['output']
source=parent.read_text();inputs=[pin(parent),pin(parent_receipt),pin(receipt_path),pin(Path(__file__))]
token=re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*|[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*|[^\s]')
def adapt(text):
    return token.sub(lambda m:'p88_string_eq' if m[0]=='String.eq' else m[0],text)
def canonical(text):
    return [m[0] for m in token.finditer(text) if not m[0].startswith('#')]
def declarations(text):
    marks=list(re.finditer(r'(?m)^(?:@unsafe\n)?(type|law|def)\s+([^\s(<:]+)',text));result={}
    for i,m in enumerate(marks):
        end=marks[i+1].start() if i+1<len(marks) else len(text)
        marker=re.search(r'(?m)^# Module:',text[m.end():end])
        if marker:end=m.end()+marker.start()
        # Top-level comments after the last indented body line are not part of
        # this declaration. Keep source offsets for byte-exact inverse edits.
        lines=text[m.start():end].splitlines(keepends=True)
        while lines and (not lines[-1].strip() or lines[-1].startswith('#')):lines.pop()
        block=''.join(lines).rstrip('\n');end=m.start()+len(block)
        key=(m[1],m[2]);assert key not in result,key
        result[key]=(m.start(),end,block)
    return result
old={};new={}
for entry in receipt['changes']:
    for kind,dest in [('old',old),('new',new)]:
        p=Path(entry[kind]['file']);assert pin(p)==entry[kind];inputs.append(pin(p))
        for key,value in declarations(p.read_text()).items():
            assert key not in dest,key;dest[key]=value
assert set(old)<=set(new),'Candidate removed a declaration'
parent_blocks=declarations(source)
added=set(new)-set(old)
assert added=={('type','NC_Text'),('def','nc_text')}|{('def',n) for n in ['nct_leaf','nct_empty','nct_cat_right','nct_cat_left','nct_cat','nct_render_work','nct_render','nct_within_work','nct_within']}
for key in added:assert key not in parent_blocks,key
helper_order=['nct_leaf','nct_empty','nct_cat_right','nct_cat_left','nct_cat','nct_render_work','nct_render','nct_within_work','nct_within','nc_text']
edits=[]
for key,(_,_,old_block) in old.items():
    new_block=new[key][2]
    if canonical(old_block)==canonical(new_block):continue
    assert key in parent_blocks,key
    start,end,current=parent_blocks[key]
    assert canonical(current)==canonical(adapt(old_block)),('Parent declaration differs from frozen owned source',key)
    replacement=adapt(new_block)
    if key==('type','NC_Code'):replacement=new['type','NC_Text'][2]+'\n\n'+replacement
    if key==('def','nc_body'):
        replacement='\n\n'.join(adapt(new['def',n][2]) for n in helper_order)+'\n\n'+replacement
    edits.append((start,end,replacement,current,key))
assert any(e[4]==('type','NC_Code') for e in edits)
assert any(e[4]==('def','nc_body') for e in edits)
result=source
for start,end,replacement,current,key in sorted(edits,reverse=True):
    assert result[start:end]==current
    result=result[:start]+replacement+result[end:]
inverse_edits=[];shift=0
for start,end,replacement,current,key in sorted(edits):
    inverse_edits.append((start+shift,start+shift+len(replacement),current))
    shift+=len(replacement)-(end-start)
inverse=result
for start,end,current in reversed(inverse_edits):inverse=inverse[:start]+current+inverse[end:]
assert inverse==source,'Inverse edits do not recover exact parent source'
with out.open('x') as f:f.write(result)
report=dict(kind='phase89-native-owned01-body-chunks-derivative',complete=True,compiled=False,inputs=inputs,output=pin(out),
    edits=[dict(kind=k[0],name=k[1],oldStartByte=len(source[:s].encode()),oldEndByte=len(source[:e].encode()),oldSha256=hashlib.sha256(c.encode()).hexdigest(),newSha256=hashlib.sha256(r.encode()).hexdigest()) for s,e,r,c,k in sorted(edits)],
    addedDeclarations=[dict(kind=k[0],name=k[1]) for k in sorted(added)],inverseRecoversParent=True,
    validation='Each replaced parent declaration matches the frozen owned baseline token-for-token, ignoring comments/whitespace and preserving its existing String.eq adaptation.',
    scope='Only changed body-tree declarations replaced and 11 declarations inserted. All other parent source bytes, imports, native equality helpers, prepared Base/cache entry and IO permissions remain unchanged.')
with Path(str(out)+'.derivation.json').open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(output=report['output'],changedDeclarations=len(edits),addedDeclarations=len(added))))
