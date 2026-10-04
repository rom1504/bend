#!/usr/bin/env python3
"""Freeze coherent staged source; root owns compiler execution/integration."""
import argparse, subprocess, difflib, hashlib, json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('repo',type=Path);p.add_argument('out',type=Path);a=p.parse_args();root=a.repo.resolve();out=a.out.resolve();assert not out.exists();out.mkdir();here=Path(__file__).resolve().parent
subprocess.run(['python3',str(here/'make-source-patch.py'),str(root),str(out/'ground')],check=True)
files=['jpure.bend','local.bend','finite.bend','tree.bend','producer.bend','projection.bend','emit.bend'];base={};texts={}
for name in files:
 rel='selfhost/src/back/js/'+name;base[rel]=(root/rel).read_text();texts[rel]=(out/'ground'/name).read_text() if (out/'ground'/name).exists() else base[rel]
def replace(name,old,new):
 rel='selfhost/src/back/js/'+name;assert old in texts[rel],(name,old);texts[rel]=texts[rel].replace(old,new)
replace('jpure.bend','j_region_scalar(book, ty) || j_list_ground_type(book, ty) ||','j_region_scalar(book, ty) || j_map_cmp_type(book, ty) || j_list_ground_type(book, ty) ||')
replace('jpure.bend','    kc(Maybe<&2,U32>, j_pure_map_head(book, ty),','    kc(Maybe<&2,U32>, j_map_maybe_head(book, ty), u => j_map_maybe_check(book, ty, active, fuel), u =>\n    kc(Maybe<&2,U32>, j_pure_map_head(book, ty),')
replace('jpure.bend','j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{})))))','j_pure_type_ctors(book, dc(owner), nm(ty), Con{nm(ty), active}, fuel), u => None{})), u => None{}))))))')
replace('jpure.bend','  kc(Maybe<&2,U32>, String.eq(nm(a), "Map")','  kc(Maybe<&2,U32>, String.eq(nm(a), "Maybe") || String.eq(nm(b), "Maybe"), u =>\n    kc(Maybe<&2,U32>, j_map_maybe_head(book, a) && j_map_maybe_head(book, b), u =>\n      j_pure_same_check(book, kid(a, 1), kid(b, 1), fuel), u => None{}), u =>\n  kc(Maybe<&2,U32>, String.eq(nm(a), "Map")')
replace('jpure.bend','List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{}))))','List.is_empty(&2, String, rm(a)) && List.is_empty(&2, String, rm(b)), u => Some{fuel}, u => None{})))))')
replace('jpure.bend','String.eq(tg(kid(ty, 0)), "Qua") && U32.is_eq(qt(kid(ty, 0)), 1) &&','String.eq(tg(kid(ty, 0)), "Qua") && (U32.is_eq(qt(kid(ty, 0)), 1) || U32.is_eq(qt(kid(ty, 0)), 2)) &&')
replace('jpure.bend','String.eq(tg(kid(ty, 1)), "Qua") && U32.is_eq(qt(kid(ty, 1)), 1) &&','String.eq(tg(kid(ty, 1)), "Qua") && (U32.is_eq(qt(kid(ty, 1)), 1) || U32.is_eq(qt(kid(ty, 1)), 2)) &&')
replace('jpure.bend','j_pure_sigma_kind(wnf(book, j_specialize(book, dt(owner), ks(ty))))','j_map_sigma_kind(wnf(book, j_specialize(book, dt(owner), ks(ty))), qt(kid(ty, 0)), qt(kid(ty, 1)))')
replace('jpure.bend','j_pure_sigma_head(book, a) && j_pure_sigma_head(book, b), u =>','j_pure_sigma_head(book, a) && j_pure_sigma_head(book, b) &&\n      U32.is_eq(qt(kid(a, 0)), qt(kid(b, 0))) && U32.is_eq(qt(kid(a, 1)), qt(kid(b, 1))), u =>')
replace('jpure.bend','j_pure_bool_native(book, d) || j_pure_nat_native(book, d) ||','j_pure_bool_native(book, d) || j_pure_nat_native(book, d) || j_map_native_binary(book, d) ||')
replace('jpure.bend','U32.is_lt(j_region_def_count(j_pure_defs(s)), 32)','U32.is_lt(j_region_def_count(j_pure_defs(s)), j_instance_pure_capacity(d, j_pure_defs(s)))')
replace('local.bend','j_fold_type(book, ty) || j_list_ground_type(book, ty) || j_pure_closed_map(book, ty)','j_fold_type(book, ty) || j_list_ground_type(book, ty) || j_pure_closed_map(book, ty) || j_map_closed_maybe(book, ty) || j_map_cmp_type(book, ty)')
for name in ['tree.bend','finite.bend']:
 replace(name,'j_pure_closed_sigma(book, arg) || j_pure_closed_map(book, arg) ||','j_pure_closed_sigma(book, arg) || j_pure_closed_map(book, arg) || j_map_closed_maybe(book, arg) || j_map_cmp_type(book, arg) ||')
replace('tree.bend','String.eq(tg(first), "Var") && String.eq(j_component_origin(env, ix(first)), "@child")','((String.eq(tg(first), "Var") && String.eq(j_component_origin(env, ix(first)), "@child")) ||\n      (String.eq(dk(index_first(dc(d))), "JErasedInstance") && String.eq(tg(first), "Ctr") && j_instance_child_fields(env, ks(first))))')
replace('projection.bend','j_region_capture_eligible(book, d) || j_callback_capture_eligible(book, d)','j_region_capture_eligible(book, d) || j_callback_capture_eligible(book, d) || j_instance_public_capture(d)')
replace('emit.bend','  +worker = j_nat_loop_worker(book, d)\n  +component = lookup(book, dn(d))\n  kc(String, String.eq(worker, ""),','  +instance = j_instance_root(book, lookup(book, dn(d)))\n  +worker = j_nat_loop_worker(book, d)\n  +component = lookup(book, dn(d))\n  kc(String, Bool.not(String.eq(instance, "")), u => j_l_global_worker(book, d, dv(d), instance), u =>\n  kc(String, String.eq(worker, ""),')
replace('emit.bend','j_component_declaration(book, component, j_component_cached(book, dn(component)))','j_component_declaration(book, component, j_component_cached(book, dn(component))))')
for extra in ['erased-instance.bend','instance-context.bend','instance-lowering.bend','component-support.bend']:texts['selfhost/src/back/js/jpure.bend']+='\n'+(here/extra).read_text()
rel='selfhost/src/runtime/js/core.mjs';base[rel]=(root/rel).read_text();texts[rel]=base[rel]
old="return G[name]=name==='Array.new'||name==='Array.get'||name==='Array.set'||name==='F32.to_u32'||name==='Bool.xor'?scalarCapture(name,value):value;"
assert old in texts[rel];texts[rel]=texts[rel].replace(old,'return G[name]=scalarCapture(name,value);')
patch=''.join(''.join(difflib.unified_diff(base[n].splitlines(True),t.splitlines(True),fromfile='a/'+n,tofile='b/'+n)) for n,t in texts.items());(out/'prototype.patch').write_text(patch)
for n,t in texts.items():f=out/'files'/n;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(t)
sha=lambda b:hashlib.sha256(b).hexdigest()
report={'kind':'phase43-contextual-map-source-prototype','checked':False,'emissionVerified':False,'sourceInputs':{n:sha(s.encode())for n,s in base.items()},'sourceOutputs':{n:sha(s.encode())for n,s in texts.items()},'patchSha256':sha(patch.encode()),'scope':'generic scalar root with saturated erased calls; exactgrounded instance facts/live privateABI; canonical original guards/fallback; direct self-stack workers; unsupported SCC/prefix workers original residual G calls; no public graph ownership'}
(out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
