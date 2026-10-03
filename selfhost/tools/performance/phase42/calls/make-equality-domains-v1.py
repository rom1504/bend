"""Restore exact established region equality and isolate new JPure equality."""
from pathlib import Path
import hashlib,difflib,json
repo=Path.cwd();out=Path(__file__).with_name('equality-domains-v1');assert not out.exists();out.mkdir()
fold=repo/'selfhost/src/back/js/fold.bend';pure=repo/'selfhost/src/back/js/jpure.bend';phase41=repo/'selfhost/build/phase41/checked01/snapshot/src/back/js/fold.bend'
old=phase41.read_text().split('def j_region_same_type(',1)[1];old='def j_region_same_type('+old
current=fold.read_text();start=current.index('def j_region_same_type(');assert current[start:].count('def ')==1
updated=current[:start]+old
before=pure.read_text();assert before.count('j_region_same_type(')==3
replacements=[('j_region_same_type(book, kid(t, 1), ty)','j_pure_same_closed(book, kid(t, 1), ty, 64)'),('j_region_same_type(book, j_env(env, ix(t)), ty)','j_pure_same_closed(book, j_env(env, ix(t)), ty, 64)'),('j_region_same_type(book, head, result)','j_pure_same_closed(book, head, result, 64)')]
after=before
for a,b in replacements:assert after.count(a)==1;after=after.replace(a,b)
assert 'j_region_same_type(' not in after
patch='';rows=[]
sha=lambda s:hashlib.sha256(s.encode()).hexdigest()
for p,a,b in [(fold,current,updated),(pure,before,after)]:
 rel=str(p.relative_to(repo));patch+=''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='a/'+rel,tofile='b/'+rel));(out/p.name).write_text(b);rows.append({'source':str(p),'before':sha(a),'after':sha(b)})
(out/'source.patch').write_text(patch)
(out/'identity.json').write_text(json.dumps({'kind':'phase42-equality-domain-separation','checked':False,'producer':sha(Path(__file__).read_text()),'phase41Fold':{'path':str(phase41),'sha256':sha(phase41.read_text())},'files':rows,'patch':sha(patch),'changes':'Restore j_region_same_type exactPhase41; three JPure sites use strict complete closed equality directly'},indent=2)+'\n')
print(out/'source.patch')
