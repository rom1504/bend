"""Exact source-only body/suffix fusion at literal-suffix call sites; no lowering."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PARENT = ROOT/'selfhost/build/phase143/integrated-source03/compiler.bend'
PARENT_SHA = 'a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e'
SPEC = importlib.util.spec_from_file_location('source_blocks',ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(SPEC); SPEC.loader.exec_module(C)
TOK = re.compile(r'"(?:\\.|[^"\\])*"|\#[^\n]*|[A-Za-z_][A-Za-z0-9_.]*|\+\+|[^\s]')


def rewrite(block):
    tokens=[m for m in TOK.finditer(block) if not m[0].startswith('#')]
    edits=[]; rejected=[]
    for i,t in enumerate(tokens):
        if t[0]!='p111q_body_text' or (i and tokens[i-1][0]=='def'):
            continue
        if i+1>=len(tokens) or tokens[i+1][0]!='(':
            raise ValueError('Non-call use requires manual review')
        depth=0; end=None
        for j in range(i+1,len(tokens)):
            if tokens[j][0]=='(':depth+=1
            elif tokens[j][0]==')':
                depth-=1
                if depth==0:end=j;break
        if end is None:raise ValueError('Unclosed body renderer call')
        if end+2>=len(tokens) or tokens[end+1][0]!='++' or not tokens[end+2][0].startswith('"'):
            rejected.append(dict(offset=t.start(),reason='No immediate literal suffix'));continue
        tail=tokens[end+2][0]
        if tail!='"}\\n"':raise ValueError('Unreviewed suffix: '+tail)
        start=t.start(); stop=tokens[end+2].end()
        old=block[start:stop]
        arg=block[tokens[i+1].end():tokens[end].start()]
        new='p144e_body_tail('+arg+','+tail+')'
        edits.append(dict(start=start,stop=stop,old=old,new=new))
    result=block
    for e in reversed(edits):result=result[:e['start']]+e['new']+result[e['stop']:]
    inverse=result
    for e in edits:
        if inverse.count(e['new'])!=1:raise ValueError('Ambiguous reverse source edit')
        inverse=inverse.replace(e['new'],e['old'],1)
    assert inverse==block
    return result,edits,rejected


def freeze(path,text):
    raw=text.encode()
    if path.exists():assert path.read_bytes()==raw, 'Changed frozen output: '+str(path)
    else:path.write_bytes(raw)


def main():
    assert C.pin(PARENT)['sha256']==PARENT_SHA
    source=PARENT.read_text(); blocks=C.blocks(source)
    output=[]; sites=[]; unmatched=[]; overrides=[]
    for name,block in blocks.items():
        updated,edits,rejected=rewrite(block)
        for row in rejected:unmatched.append(dict(owner=name,**row))
        if edits:
            output.append(updated.rstrip()+'\n\n');overrides.append(name)
            base=source.index(block)
            for e in edits:
                sites.append(dict(owner=name,line=source.count('\n',0,base+e['start'])+1,
                                  old=e['old'],new=e['new']))
    assert sites and len(overrides)==len(set(overrides))
    # Every surviving call is explicitly inventoried. No admission helper or
    # body renderer definition is overridden.
    assert 'p111q_body_text' not in overrides
    freeze(HERE/'wrappers-v01.bend',''.join(output))
    report=dict(kind='phase144-exact-body-tail-source-rewrite',complete=True,
        checked=False,targetsRun=False,parent=C.pin(PARENT),
        helper=C.pin(HERE/'body-tail-v01.bend'),module=C.pin(HERE/'wrappers-v01.bend'),
        inputs=[C.pin(__file__),C.pin(C.__file__)],overrides=overrides,
        sites=sites,unmatched=unmatched,reverseExact=True,
        scope='Only original p111q_body_text(argument) ++ literal-footer call sites; no host QBE rendering.')
    freeze(HERE/'wrappers-v01.json',json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(overrides=overrides,sites=len(sites),unmatched=unmatched)))


if __name__=='__main__':main()
