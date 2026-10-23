"""Inventory exact literal atom calls without interpreting or executing Bend.

Comments and quoted strings are skipped. This tool does not change source;
its purpose is to bound a possible immutable-constructor exposure experiment.
"""
import bisect
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode=True

ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('compose',HERE.parent/'prepare.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)

def pin(p):
    p=p.resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def quoted_end(text,i):
    assert text[i]=='"'
    j=i+1
    while j<len(text):
        if text[j]=='\\':j+=2
        elif text[j]=='"':return j+1
        else:j+=1
    raise ValueError('Unclosed quoted string')

def whitespace(text,i):
    while i<len(text) and text[i].isspace():i+=1
    return i

def calls(text):
    i=0;answer=[]
    while i<len(text):
        if text[i]=='#':
            end=text.find('\n',i);i=len(text) if end<0 else end+1
        elif text[i]=='"':i=quoted_end(text,i)
        elif text[i].isalpha() or text[i]=='_':
            start=i;i+=1
            while i<len(text) and (text[i].isalnum() or text[i] in '_.'):i+=1
            if text[start:i]!='atom':continue
            j=whitespace(text,i)
            if j>=len(text) or text[j]!='(':continue
            j=whitespace(text,j+1)
            if j>=len(text) or text[j]!='"':continue
            end=quoted_end(text,j);close=whitespace(text,end)
            if close<len(text) and text[close]==')':
                answer.append(dict(begin=start,end=close+1,literal=text[j:end],call=text[start:close+1]))
                i=close+1
        else:i+=1
    return answer

def main():
    selection=ROOT/'implementation/phase130/candidate.json'
    selected=json.loads(selection.read_text());source=Path(selected['source']['file'])
    assert pin(source)==selected['source'];text=source.read_text()
    decls=list(S.PAT.finditer(text));starts=[m.start() for m in decls]
    protected=S.ENTRY_GATES|set(S.blocks(S.DIRECT_VERIFIER.read_text()))|{m[1] for m in decls if m[1].startswith('p111v_')}
    rows=calls(text)
    for row in rows:
        row['owner']=decls[bisect.bisect_right(starts,row['begin'])-1][1]
        row['line']=text.count('\n',0,row['begin'])+1
        row['protected']=row['owner'] in protected
    # Scanner falsifiers: never treat source-looking text in comments/strings,
    # qualified names, dynamic arguments or multiple arguments as literal calls.
    assert [x['call'] for x in calls('# atom("X")\n"atom(\\"Y\\")" foo.atom("Z") atom(tag) atom("A",x) atom("B")')]==['atom("B")']
    out=HERE/'literal-atoms-inventory.json'
    assert not out.exists()
    out.write_text(json.dumps(dict(complete=True,targetsRun=False,source=selected['source'],
        inputs=[pin(Path(__file__)),pin(selection),pin(HERE.parent/'prepare.py'),pin(S.DIRECT_VERIFIER)],
        count=len(rows),unprotectedCount=sum(not x['protected'] for x in rows),
        ownerCount=len({x['owner'] for x in rows}),
        unprotectedOwnerCount=len({x['owner'] for x in rows if not x['protected']}),
        literals=dict(Counter(x['literal'] for x in rows)),rows=rows,
        scope='Source-only lexical inventory; no transform or target execution. Potential direct constructor exposure must preserve exact selected atom/kt semantics, retain protected final verifier source, and receive independent whole-payload and whole-request checks.'),indent=2)+'\n')

if __name__=='__main__':main()
