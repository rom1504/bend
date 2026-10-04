#!/usr/bin/env python3
"""Prepare exact ground Map admission/matching source patch; do not edit source."""
from pathlib import Path
import difflib, argparse, json, hashlib
p=argparse.ArgumentParser();p.add_argument('repo',type=Path);p.add_argument('out',type=Path);a=p.parse_args();assert not a.out.exists();a.out.mkdir()
root=a.repo.resolve();sources={};changes={}
def read(name):
 s=(root/name).read_text();sources[name]=s;return s
def replace(s,old,new):
 assert s.count(old)>=1,old;return s.replace(old,new)
name='selfhost/src/back/js/jpure.bend';s=read(name)
s=replace(s,'    kc(Maybe<&2,U32>, j_pure_list_head(book, ty), u => j_pure_list_check(book, ty, active, fuel), u =>','    kc(Maybe<&2,U32>, j_pure_map_head(book, ty), u => j_pure_map_check(book, ty, active, fuel), u =>\n    kc(Maybe<&2,U32>, j_pure_list_head(book, ty), u => j_pure_list_check(book, ty, active, fuel), u =>')
s=replace(s,'j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{}))))','j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{})))))')
s=replace(s,'  kc(Maybe<&2,U32>, String.eq(nm(a), "List") || String.eq(nm(b), "List"), u =>','  kc(Maybe<&2,U32>, String.eq(nm(a), "Map") || String.eq(nm(b), "Map"), u =>\n    kc(Maybe<&2,U32>, j_pure_map_head(book, a) && j_pure_map_head(book, b), u =>\n      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>\n  kc(Maybe<&2,U32>, String.eq(nm(a), "List") || String.eq(nm(b), "List"), u =>')
s=replace(s,'List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{})))','List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{}))))')
s+='\n'+Path(__file__).with_name('map-ground.bend').read_text();changes[name]=s
# Local type gate is a private ownership proof, never public graph admission.
name='selfhost/src/back/js/local.bend';s=read(name)
s=replace(s,'j_fold_type(book, ty) || j_list_ground_type(book, ty), u => Some{fuel}', 'j_fold_type(book, ty) || j_list_ground_type(book, ty) || j_pure_closed_map(book, ty), u => Some{fuel}');changes[name]=s
name='selfhost/src/back/js/finite.bend';s=read(name)
s=replace(s,'j_pure_closed_list(book, arg) || j_pure_closed_sigma(book, arg) ||','j_pure_closed_list(book, arg) || j_pure_closed_sigma(book, arg) || j_pure_closed_map(book, arg) ||');changes[name]=s
name='selfhost/src/back/js/tree.bend';s=read(name)
s=replace(s,'j_list_ground_type(book, kid(head, 0)) || j_pure_closed_list(book, kid(head, 0)) ||','j_list_ground_type(book, kid(head, 0)) || j_pure_closed_list(book, kid(head, 0)) || j_pure_closed_map(book, kid(head, 0)) ||')
s=replace(s,'String.eq(tg(arg), "ADT") && Bool.not(db(lookup(book, nm(arg))))','String.eq(tg(arg), "ADT") && (Bool.not(db(lookup(book, nm(arg)))) || j_pure_closed_map(book, arg))')
s=replace(s,'j_pure_closed_list(book, arg) || j_pure_closed_sigma(book, arg) ||','j_pure_closed_list(book, arg) || j_pure_closed_sigma(book, arg) || j_pure_closed_map(book, arg) ||');changes[name]=s
name='selfhost/src/back/js/producer.bend';s=read(name)
s=replace(s,'(has_name(active, "@producer") && j_fold_type(book, ty)) || j_list_ground_type(book, ty),','(has_name(active, "@producer") && j_fold_type(book, ty)) || j_list_ground_type(book, ty) || j_pure_closed_map(book, ty),');changes[name]=s
patch=''.join(''.join(difflib.unified_diff(sources[n].splitlines(True),v.splitlines(True),fromfile='a/'+n,tofile='b/'+n)) for n,v in changes.items());(a.out/'map-ground.patch').write_text(patch)
for name,s in changes.items():(a.out/Path(name).name).write_text(s)
sha=lambda b:hashlib.sha256(b).hexdigest()
(a.out/'manifest.json').write_text(json.dumps({'kind':'phase43-exact-ground-map-source-patch','checked':False,'emissionVerified':False,'completeWholeMapAdmission':False,'sourceInputs':{n:sha(s.encode())for n,s in sources.items()},'patchSha256':sha(patch.encode()),'requires':'String and exact qty2 Sigma/Maybe admission; generic erased-prefix specialization remains unresolved'},indent=2)+'\n')
