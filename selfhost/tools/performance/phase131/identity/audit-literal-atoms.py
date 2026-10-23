"""Independent source-identity gate for the frozen literal constructor overlay."""
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('inventory',HERE/'literal-atoms.py')
I=importlib.util.module_from_spec(spec);spec.loader.exec_module(I)
S=I.S

def identifiers(text,name):
    i=0;answer=[]
    while i<len(text):
        if text[i]=='#':
            end=text.find('\n',i);i=len(text) if end<0 else end+1
        elif text[i]=='"':i=I.quoted_end(text,i)
        elif text[i].isalpha() or text[i]=='_':
            begin=i;i+=1
            while i<len(text) and (text[i].isalnum() or text[i] in '_.'):i+=1
            if text[begin:i]==name:answer.append(begin)
        else:i+=1
    return answer

def main():
    manifest=ROOT/'selfhost/build/phase131/literal-atoms-overlay02/manifest.json'
    exposure=json.loads(manifest.read_text());assert exposure['complete'] and exposure['replacements']==421
    source=Path(exposure['source']['file']);fast=Path(exposure['fastSource']['file']);overlay=Path(exposure['overlay']['file'])
    for p in [source,fast,overlay]:
        assert I.pin(p)==next(x for x in [exposure['source'],exposure['fastSource'],exposure['overlay']] if x['file']==str(p))
    old=source.read_text();current=fast.read_text();before=S.blocks(old);now=S.blocks(current);changed=S.blocks(overlay.read_text())
    for name in ['atom','kt']:assert S.norm(before[name])==S.norm(now[name])
    # Every bare atom identifier is its unique global declaration, a literal
    # call, or the one original dynamic atom(name) call. The dynamic call is
    # deliberately untouched. No local binder/alias shadows this spelling.
    atom_def=re.search(r'^def atom\(',old,re.M);assert atom_def
    all_tokens=set(identifiers(old,'atom'));literal_tokens={x['begin'] for x in I.calls(old)}
    dynamic=[m.start() for m in re.finditer(r'\batom\(name\)',old)]
    assert len(dynamic)==1
    assert all_tokens==literal_tokens|{atom_def.start()+4,*dynamic}
    rows={x['name']:x for x in exposure['rows']};assert set(rows)==set(changed)
    for name,body in changed.items():
        original=before[name];assert S.norm(original)==S.norm(now[name])
        for row in reversed(rows[name]['replacements']):
            assert original[row['begin']:row['end']]==row['call']
            expected='{KTerm{'+row['literal']+', "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}'
            assert row['replacement']==expected
            original=original[:row['begin']]+expected+original[row['end']:]
        assert original==body
    source02=ROOT/'selfhost/build/phase131/literal-atoms-source02/compiler.bend'
    patched=S.blocks(source02.read_text())
    for name in exposure['protectedUnchanged']:assert S.norm(patched[name])==S.norm(now[name])
    out=ROOT/'selfhost/build/phase131/literal-atoms-source02/source-bridge-audit.json';assert not out.exists()
    out.write_text(json.dumps(dict(complete=True,targetsRun=False,
        inputs=[I.pin(Path(__file__)),I.pin(HERE/'literal-atoms.py'),I.pin(manifest),I.pin(source),I.pin(fast),I.pin(overlay),I.pin(source02)],
        exactFactoryBodies=True,unshadowedAtomName=True,selectedAtomIdentifiers=len(all_tokens),
        selectedLiteralCalls=len(literal_tokens),unchangedDynamicCalls=1,replacements=421,erasedAscription=True,
        protectedDeclarationsUnchanged=len(exposure['protectedUnchanged']),
        scope='Exact source bridge and binder-name preconditions for a pinned source patch. No theorem about runtime sharing or performance; independent static verifier and execution gates remain necessary.'),indent=2)+'\n')

if __name__=='__main__':main()
