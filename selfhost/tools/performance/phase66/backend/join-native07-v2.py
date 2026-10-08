#!/usr/bin/env python3
"""Data-only native admission: exact executable closure plus explicit gate reuse."""
from pathlib import Path
import argparse, hashlib, importlib.util, json, re
ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase66'
INPUTS={}
def pin(p,want=None):
 p=p.resolve(strict=True);b=p.read_bytes();h=hashlib.sha256(b).hexdigest();assert want is None or h==want,(str(p),h,want)
 row={'file':str(p),'sha256':h,'bytes':len(b)};INPUTS[str(p)]=row;return row
def pinned(row):return pin(Path(row['file']),row['sha256'])
def read(p):return json.loads(p.read_text()),pin(p)
def same(a,b):
 x,y=pinned(a),pinned(b);assert x['file']==y['file'] and x['sha256']==y['sha256'];return x
def report_inputs(d):
 for x in d.get('inputs',[]):pinned(x)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();assert not a.out.exists();pin(Path(__file__))
 old,oldp=read(RAW/'checked-b1-05/attempt.json');new,newp=read(RAW/'checked-b1-07/attempt.json');assert old['checked'] and new['checked']
 oldapi,newapi=pinned(old['api']),pinned(new['api']);assert oldapi['sha256']!=newapi['sha256']
 for key in ['base','node','runtime']:assert pinned(old[key])['sha256']==pinned(new[key])['sha256']
 baseline,bp=read(ROOT/'implementation/phase66/evidence/native-backend05.json');assert baseline['pass'] and baseline['complete'];same(baseline['selectedAttempt'],oldp);same(baseline['selectedApi'],oldapi);report_inputs(baseline)
 indexes=[]
 for attempt in [old,new]:
  snapshot=Path(attempt['snapshot']['root']);indexes.append({str(Path(x['frozen']['file']).relative_to(snapshot)):pinned(x['frozen']) for x in attempt['snapshot']['sources']})
 assert indexes[0].keys()==indexes[1].keys();changed=[k for k in indexes[0] if indexes[0][k]['sha256']!=indexes[1][k]['sha256']]
 assert set(changed)=={'src/back/js/direct/calls.bend','src/back/js/direct/core.bend','src/back/js/validate.bend'}
 native=[{'relative':k,'baseline':indexes[0][k],'selected':indexes[1][k]} for k in indexes[0] if k.startswith('src/runtime/native/')];assert all(x['baseline']['sha256']==x['selected']['sha256'] for x in native)
 scanner=ROOT/'selfhost/tools/performance/phase66/controls/frontend-closure.py';scanner_pin=pin(scanner);spec=importlib.util.spec_from_file_location('native_closure',scanner);mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
 before,after=mod.program(oldapi['file']),mod.program(newapi['file']);assert before['runtime']==after['runtime'] and before['exportSource']==after['exportSource'] and before['exports']==after['exports']
 driver=Path(new['snapshot']['root'])/'tools/typed-driver.mjs';driver_text=driver.read_text();assert pin(driver)['sha256']==indexes[0]['tools/typed-driver.mjs']['sha256']
 prefix=driver_text[:driver_text.index("    if(mode==='check') return")];dynamic=[line for line in prefix.splitlines() if 'api[' in line];assert len(dynamic)==3 and all("typeof api[name]==='function'" in x or "typeof api[name]!=='function'" in x for x in dynamic)
 refs=set(re.findall(r'\bapi\.([A-Za-z_]\w*)',prefix));assert refs-before['exports'].keys()=={'bend','mjs'};front=sorted(refs&before['exports'].keys())
 native_roots=['driver_emit_owned','j_roots','j_layout_error','nc_annotation_stops','reach_book','annotate_selected','nc_annotated_context','annotate_book','nc_foreign_paths','nc_foreign_scope','kf_source','nc_foreign_source','nc_compile']
 native_annotation=driver_text[driver_text.index("    if(mode==='native'&&api.nc_annotation_stops"):driver_text.index('    } else if(selectedEmission){')]
 emission_start=driver_text.index("    if(mode==='native') {",driver_text.index("trace('validate runtime layouts')"))
 native_emission=driver_text[emission_start:driver_text.index("    trace('emit '+mode);",emission_start)]
 actual_native_refs=set(re.findall(r'\bapi\.([A-Za-z_]\w*)',native_annotation+native_emission))|{'driver_emit_owned','j_roots','j_layout_error','annotate_book'}
 assert actual_native_refs==set(native_roots),(actual_native_refs,set(native_roots))
 assert pin(driver)['sha256']=='e093483d5103a8e833b6ca710246b1ec3c579b7fac5060c8e42f626c5e25ec85','Reviewed native driver control flow changed'
 closures={}
 before['exports']['privateIoType']='$j_io_type$';after['exports']['privateIoType']='$j_io_type$'
 for label,roots in [('frontend',front),('nativePipeline',native_roots),('ioClassification',['privateIoType'])]:
  aa,bb=mod.closure(before,roots),mod.closure(after,roots);assert aa==bb;assert all(before['functions'][n]['source']==after['functions'][n]['source'] for n in aa)
  closures[label]={'roots':roots,'count':len(aa),'functions':[{'name':n,'sha256':hashlib.sha256(after['functions'][n]['source'].encode()).hexdigest()} for n in sorted(aa)]}
 # Bind the unchanged entry and IO branch separately from the changed pure predicate.
 assert before['functions']['$j_compile_error$']['source']==after['functions']['$j_compile_error$']['source']
 marker='}) : ((_x_7) => {';oldmain=before['functions']['$j_main_error$']['source'];newmain=after['functions']['$j_main_error$']['source'];assert oldmain.count(marker)==newmain.count(marker)==1
 io_prefix=oldmain.split(marker)[0];assert io_prefix==newmain.split(marker)[0]
 invocation='$j_printable$(_book_0, ($dt$(_main_0)), {$: "Nil"}, 0)';assert oldmain.replace('run_loop('+invocation+')','('+invocation+')')==newmain
 admission_changes=sorted(n for n in mod.closure(before,['j_compile_error'])|mod.closure(after,['j_compile_error']) if before['functions'].get(n,{}).get('source')!=after['functions'].get(n,{}).get('source'))
 assert set(admission_changes)<={'$j_main_error$','$j_printable$','$j_printable_done$','$j_printable_head$','$j_printable_adt$','$j_printable_ctors$','$j_printable_ctors_more$','$j_printable_fields$','$j_printable_fields_more$'}
 printable,printp=read(RAW/'printable-controls07-01/report.json');assert printable['complete'] and printable['pass'];same(printable['roles']['baseline']['attempt'],oldp);same(printable['roles']['candidate']['attempt'],newp);report_inputs(printable)
 for role in ['baseline','candidate']:
  rows={x['name']:x for x in printable['roles'][role]['cases']};assert all(x['pass'] and x['actual']==x['expected'] for x in rows.values());assert rows['distinct-namespace-spelling']['actual'] is False
 primary,primaryp=read(RAW/'conformance-final07-direct-js01/bend-candidate-new-base/js/report.json');assert primary['finished'] and not primary['changedInputs'];primaryrows={x['id']:x for x in primary['results']};assert pinned(primary['identity']['artifacts']['compiler'])['sha256']==newapi['sha256'];assert pinned(primary['identity']['artifacts']['driver'])['sha256']==pin(driver)['sha256']
 for name,h in primary['inputHashes'].items():pin(Path(primary['inputPaths'].get(name,name)),h)
 primaryrecipe,prp=read(RAW/'conformance-final07-direct-js01/recipe.json');role=next(x for x in primaryrecipe['images'] if x['role']=='bend-candidate-new-base');same(role['attempt'],newp);assert pinned(role['compilerImage'])['sha256']==newapi['sha256']
 pure_ids=['compile/array_equality_print.bend','compile/f32_word_boxed_default.bend','compile/word_boxed_default.bend','compile/word_boxed_sequence.bend','import/alias_file_name.bend','import/base_family_file.bend']
 native16,n16p=read(RAW/'backend-native-controls05-clang01-recipe/bend-direct/observations/report.json');native16rows={x['id']:x for x in native16['results']};native16_io=[];native16_pure=[]
 for row in native16['results']:
  if row['evidence']!='checked-execution':continue
  files=list(Path(row['artifacts']).glob('*.c'));assert len(files)==1;text=files[0].read_text();matches=re.findall(r'^#define MAIN_PURE ([01])$',text,re.M);assert len(matches)==1
  request,rqp=read(Path(row['artifacts'])/'request.json');fixture=pinned(request['test']);entry={'id':row['id'],'request':rqp,'fixture':fixture,'emittedC':pin(files[0])}
  (native16_io if matches[0]=='0' else native16_pure).append(entry)
 assert {x['id'] for x in native16_pure}==set(pure_ids);assert len(native16_io)==7 and len(native16_pure)==6
 pure=[]
 for name in pure_ids:
  row=primaryrows[name];request,rqp=read(Path(row['artifacts'])/'request.json');prior=next(x for x in native16_pure if x['id']==name);same(request['test'],prior['fixture']);assert row['status']=='pass' and row['evidence']=='checked-execution' and row['result']['checked'];pure.append({'id':name,'currentCommonAdmission':'actual07 checked direct execution passes same pre-backend j_compile_error','output':row['result']['output'],'source':prior['fixture'],'currentRequest':rqp})
 source19,s19p=read(RAW/'native-effects-source02-recipe/bend-direct/observations/report.json');io=[]
 for row in source19['results']:
  assert row['status']=='pass' and row['evidence']=='checked-execution';files=list(Path(row['artifacts']).glob('*.c'));assert len(files)==1;text=files[0].read_text();assert text.count('#define MAIN_PURE 0\n')==1;io.append({'id':row['id'],'emittedC':pin(files[0]),'main':'IO; unchanged entry branch bypasses printability'})
 assert len(io)==19
 early=[]
 for name in ['import/alias_twice.bend','io/marshal_imported_nullary_type.bend']:
  prior=native16rows[name];assert prior['status']=='pass'
  if name in primaryrows:
   current=primaryrows[name];assert current['status']=='pass' and current['result']['phase']==prior['result']['phase'] and current['result']['diagnostic']==prior['result']['diagnostic'];evidence='fresh07 direct observation and exact frontend closure'
  else:
   assert name=='io/marshal_imported_nullary_type.bend' and prior['lane']=='check';evidence='retained05 check-lane refusal admitted by exact frontend executable closure; fixture has no runtime main and is absent from07JS inventory'
  early.append({'id':name,'phase':prior['result']['phase'],'diagnostic':prior['result']['diagnostic'],'evidence':evidence})
 collision,collisionp=read(RAW/'native-admission07-recipe/focused-v2-report.json');assert collision['selectedComplete'] and not collision['changedInputs'] and len(collision['results'])==1
 assert pinned(collision['identity']['artifacts']['compiler'])['sha256']==newapi['sha256'];assert pinned(collision['identity']['artifacts']['driver'])['sha256']==pin(driver)['sha256']
 crow=collision['results'][0];assert crow['lane']=='native';prior=native16rows['phase66/printable-name-collision.bend'];assert crow['id']==prior['id'] and crow['status']=='pass' and crow['evidence']=='compile-rejection' and crow['result']['diagnostic']==prior['result']['diagnostic']
 cproject,cpp=read(RAW/'native-admission07-recipe/recipe.json');same(cproject['attempt'],newp);assert pinned(cproject['images'][0]['compilerImage'])['sha256']==newapi['sha256']
 for name,h in collision['inputHashes'].items():pin(Path(collision['inputPaths'].get(name,name)),h)
 cr,crp=read(Path(crow['artifacts'])/'request.json');orr,orp=read(Path(prior['artifacts'])/'request.json');same(cr['test'],orr['test'])
 # Fresh07 actual native execution and exact emitted-C comparison against05.
 fresh,fp=read(RAW/'qualification07/checked/native3/report.json');assert fresh['pass'] and fresh['complete'] and fresh['inputsUnchanged'];report_inputs(fresh);candidate=fresh['roles']['candidate'];same(candidate['image']['attempt'],newp);assert pinned(candidate['image']['api'])['sha256']==newapi['sha256'];assert candidate['verification']['inputsUnchanged'] and candidate['verification']['copiesUnchanged']
 for row in candidate['copies']:assert pinned(row['before'])['sha256']==pinned(row['after'])['sha256']
 cequal=[]
 for stem in ['word_arithmetic','float_arithmetic','array_map_loop']:
  x=pin(RAW/'native3-05'/f'{stem}--candidate.c');y=pin(RAW/'qualification07/checked/native3'/f'{stem}--candidate.c');assert x['sha256']==y['sha256'];cequal.append({'case':stem,'baseline':x,'selected':y})
 driver_outputs=[]
 for label in ['driver-source','driver-direct']:
  d,q=read(RAW/'bootstrap-b2-07'/label/'report.json');assert d['complete'] and d['pass'];same(d['subject']['attempt'],newp);report_inputs(d);actual=pinned(d['api']);output=next(x for x in d['outputs'] if x['file'].endswith('/native-c.c'));driver_outputs.append({'role':label,'report':q,'api':actual,'output':pinned(output)})
 assert driver_outputs[0]['api']['sha256']==newapi['sha256'];assert driver_outputs[0]['output']['sha256']==driver_outputs[1]['output']['sha256']
 result={'kind':'phase66-selected07-native-backend-admission','complete':True,'pass':True,'dataOnly':True,'version':2,'predecessorMethod':pin(Path(__file__).with_name('join-native07.py')),'selectedAttempt':newp,'selectedApi':newapi,'baselineAttempt':oldp,'reused05Receipt':bp,'snapshotIdentity':{'files':len(indexes[0]),'changed':changed,'unchanged':len(indexes[0])-len(changed),'nativeFiles':native},'executableClosure':{'scanner':scanner_pin,'runtimeIdentical':True,'publicWrappersIdentical':True,**closures},'admission':{'nativeDriverRootsExhaustive':True,'unchangedIoBranchSha256':hashlib.sha256(io_prefix.encode()).hexdigest(),'changedPureFunctions':admission_changes,'printabilityControls':printp,'native16PriorReport':n16p,'currentPrimaryReport':primaryp,'currentPrimaryRecipe':prp,'pureNativeCasesCurrentCommonAdmission':pure,'nativeSource19Io':io,'native16Io':native16_io,'native16Pure':native16_pure,'native16EarlyRejections':early,'freshCollision':{'report':collisionp,'roleRecipe':cpp,'diagnostic':crow['result']['diagnostic'],'request':crp},'externalCollision':'Fresh actual07 native-lane source compile rejection has exact native05 diagnostic and fixture hash.','earlyRejections':'The two parse/proof-trust native16 cases use the byte-identical frontend closure.','proofBoundary':'IO entry bypass bytes plus unchanged IO-type helper; known pure native16 cases admitted by actual07 common-driver calls. Printability preserves its Boolean graph predicate while threading completed visits; checked05 and07 finite controls bind the source review. This is explicit gate reuse, not equality of whole compiler APIs.'},'freshNative3':fp,'native3EmittedCEqual':cequal,'b1B2NativeDriverC':driver_outputs,'unsupportedNative':baseline['unsupportedNative'],'reusedGates':['nativeSource19Reference','nativeSource19Bend','native16ReferenceReused','native16Selected05','mockedSyscalls7'],'scope':'Selected native CPU gate admission only. Fresh native3 executes07. Older source19/native16/mock7 observations retain05 provenance and are admitted by exact unchanged emitter/frontend/native-host closure plus separate common-entry evidence. No full native/GPU coverage, new timed API support, all-program C equality, or installed-image claim. Legacy04 JS gates are not automatically transferred by this native receipt.','inputs':list(INPUTS.values())}
 for row in result['inputs']:pinned(row)
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'pass':True,'report':pin(a.out),'inputs':len(result['inputs']),'nativeFunctions':closures['nativePipeline']['count']}))
if __name__=='__main__':main()
