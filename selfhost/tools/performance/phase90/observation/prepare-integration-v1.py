#!/usr/bin/env python3
"""Prepare a canonical-table patch offline; never modifies selfhost/src."""
import argparse,difflib,hashlib,importlib.util,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p90_shared',HERE/'prepare.py')
s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
ROOT=s.ROOT
NAMES={'p90_fork_member':'nb_fork_member','p90_fork_mark':'nb_fork_mark','p90_fork_index':'nb_fork_index','p90_fork_reaches':'nb_fork_reaches_indexed','p90_fork_round':'nb_fork_close_indexed','p90_fork_scan':'nb_fork_scan_indexed','p90_flags_indexed':'nb_flags_indexed'}

def blocks(text):
    starts=list(re.finditer(r'(?m)^(?:@unsafe\n)?(type|law|def)\s+([^\s(<:]+)',text))
    return [(m[1],m[2],text[m.start():starts[i+1].start() if i+1<len(starts) else len(text)].rstrip()+'\n') for i,m in enumerate(starts)]

def main():
    p=argparse.ArgumentParser();p.add_argument('--out',required=True,type=Path);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    canonical=ROOT/'selfhost/src/back/native/tables.bend'
    chunks=HERE.parent/'tables/tables.bend';fork=HERE/'fork-indexed.bend'
    before,chunked,proposal=[x.read_text() for x in (canonical,chunks,fork)]
    assert 'p88_' not in chunked and 'p88_' not in proposal
    for name in NAMES.values():assert not re.search(r'(?m)^def '+re.escape(name)+r'\(',before),name
    renamed=re.sub(s.TOKEN,lambda m:NAMES.get(m[0],m[0]),proposal)
    assert renamed.count('"$p90.fork"')==2
    renamed=renamed.replace('"$p90.fork"','"NativeFork"')
    reverse={v:k for k,v in NAMES.items()}
    restored=re.sub(s.TOKEN,lambda m:reverse.get(m[0],m[0]),renamed).replace('"NativeFork"','"$p90.fork"')
    assert restored==proposal
    result=chunked
    replacements=[]
    for name in ('nb_fork_close','nb_flags_chunks'):
        old=s.declaration(result,name);new=s.declaration(renamed,name)
        assert result.count(old)==1;result=result.replace(old,new,1)
        replacements.append(dict(name=name,before=old,after=new))
    helper='\n'.join(t for k,n,t in blocks(renamed) if n not in ('nb_fork_close','nb_flags_chunks'))
    marker='@unsafe\ndef nb_fork_close(';assert result.count(marker)==1
    comment='# Carry exact membership beside the ordered roots. Within-pass growth,\n# duplicates in the initial roots, finite fuel and count convergence remain.\n'
    result=result.replace(marker,comment+helper+'\n'+marker,1)
    assert 'p90_' not in result and 'p88_' not in result and '$p90' not in result
    assert 'String.eq' in result
    original_functions=set(re.findall(r'(?m)^def (\w+)\(',before))
    final_functions=set(re.findall(r'(?m)^def (\w+)\(',result))
    assert original_functions<=final_functions
    source=a.out/'tables.bend';source.write_text(result)
    diff=''.join(difflib.unified_diff(before.splitlines(True),result.splitlines(True),fromfile='a/selfhost/src/back/native/tables.bend',tofile='b/selfhost/src/back/native/tables.bend'))
    patch=a.out/'tables.patch';patch.write_text(diff)
    # Every inherited function outside the five builder families and fork close
    # must remain the exact declaration bytes.
    changed={'nb_seg_ids_go','nb_arities_go','nb_result_words_go','nb_flags_go','nb_dispatch_go','nb_fork_close'}
    retained=[]
    for name in sorted(original_functions-changed):
        assert s.declaration(before,name)==s.declaration(result,name),name
        retained.append(name)
    m=dict(kind='phase90-canonical-tables-integration-proposal',complete=True,targetExecuted=False,sourceChanged=False,inputs=[s.pin(Path(__file__)),s.pin(HERE/'prepare.py'),s.pin(canonical),s.pin(chunks),s.pin(fork)],outputs=[s.pin(source),s.pin(patch)],helperRenames=NAMES,privateMarkerRename={'before':'$p90.fork','after':'NativeFork'},helperInverseExact=True,originalLines=len(before.splitlines()),candidateLines=len(result.splitlines()),lineDelta=len(result.splitlines())-len(before.splitlines()),originalFunctions=len(original_functions),candidateFunctions=len(final_functions),newFunctions=sorted(final_functions-original_functions),removedFunctions=[],retainedExactDeclarations=retained,rootDecisionRequired='Review and qualify canonical String.eq version; parent owns all production edits and target runs.')
    (a.out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    print(json.dumps({k:m[k] for k in ('complete','targetExecuted','sourceChanged','originalLines','candidateLines','lineDelta','originalFunctions','candidateFunctions','outputs')}))
if __name__=='__main__':main()
