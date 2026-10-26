"""Add diagnostic concat counters using the existing generic profiler machinery."""
import argparse,importlib.util,json,shutil,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7];HERE=Path(__file__).resolve().parent;PROF=ROOT/'selfhost/tools/profiler'
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('existing_profiler',PROF/'runtime.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
pin,verify=M.pin,M.verify
COUNTERS=[('BP_CONCAT_ATTEMPTS','concat_attempts'),('BP_CONCAT_NODES','concat_nodes_examined'),('BP_CONCAT_EMPTY','concat_success_empty'),('BP_CONCAT_SPLICE','concat_success_splice'),('BP_CONCAT_STATIC','concat_refused_static_term'),('BP_CONCAT_SHARED','concat_refused_shared_rfc'),('BP_CONCAT_STATIC_TARGET','concat_refused_static_target')]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
base=ROOT/'selfhost/build/phase128/runtime-borrow01';source=base/'runtime.c';original=source.read_bytes();assert pin(source)['sha256']=='6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a'
diag,edits=M.materialize(original);text=diag.decode();start=text.index('uint64_t p125_rt_concat_typed(');end=text.index('\n}\n',start)+3;body=text[start:end]
hooks=[('attempt','  Term nil = term_pak(empty_cid, 0), node = left;','  bend_profile_count(BP_CONCAT_ATTEMPTS, 1);\n  Term nil = term_pak(empty_cid, 0), node = left;'),('node','  while (node != nil) {','  while (node != nil) {\n    bend_profile_count(BP_CONCAT_NODES, 1);'),('static','    if (term_loc(node) < HEAP_OFF) return 0;','    if (term_loc(node) < HEAP_OFF) { bend_profile_count(BP_CONCAT_STATIC, 1); return 0; }'),('shared','      if ((cell & RFC_CNT) != 1) return 0;','      if ((cell & RFC_CNT) != 1) { bend_profile_count(BP_CONCAT_SHARED, 1); return 0; }'),('static-target','      if (last < HEAP_OFF) return 0;','      if (last < HEAP_OFF) { bend_profile_count(BP_CONCAT_STATIC_TARGET, 1); return 0; }'),('empty','  if (!last) {\n    return right;','  if (!last) {\n    bend_profile_count(BP_CONCAT_EMPTY, 1);\n    return right;'),('splice','  return left;','  bend_profile_count(BP_CONCAT_SPLICE, 1);\n  return left;')]
new=body
for label,old,replacement in hooks:assert new.count(old)==1;new=new.replace(old,replacement,1)
recovered=new
for label,old,replacement in reversed(hooks):assert recovered.count(replacement)==1;recovered=recovered.replace(replacement,old,1)
assert recovered==body
text=text[:start]+new+text[end:];back=text[:start]+body+text[start+len(new):]
assert back.encode()==diag
for edit in reversed(edits):assert back.count(edit['diagnostic'])==1;back=back.replace(edit['diagnostic'],edit['original'],1)
assert back.encode()==original
support=(PROF/'runtime-support.inc.c').read_text();oldenum='BP_REG_CLEAR_WORDS, BP_COUNTER_COUNT';newenum='BP_REG_CLEAR_WORDS, '+', '.join(k for k,_ in COUNTERS)+', BP_COUNTER_COUNT';oldnames='"register_words_copy_requested", "register_words_clear_requested"';newnames=oldnames+',\n  '+', '.join('"'+v+'"' for _,v in COUNTERS)
assert support.count(oldenum)==support.count(oldnames)==1
extended=support.replace(oldenum,newenum,1).replace(oldnames,newnames,1);assert extended.replace(newenum,oldenum,1).replace(newnames,oldnames,1)==support
acqfile=ROOT/'selfhost/build/phase144/programs-plan04-acquire/report.json';acq=json.loads(acqfile.read_text());assert acq['complete'];corpusfile=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json';corpus=json.loads(corpusfile.read_text());cases=[]
for name in ['complete-generic-row32','coverage-unicode-text-64']:
 row=next(x for x in acq['rows'] if x['name']==name);product=row['products']['codegen'];case=next(x for x in corpus['cases'] if x['name']==name)
 assert row['source']==case['source'];verify(product['object']);verify(product['qbe']);verify(product['build']);assert product['runtime']==pin(base/'runtime.o')
 cases.append(dict(name=name,source=case['source'],object=product['object'],qbe=product['qbe'],parentBinary=product['binary'],build=product['build'],runtimeArgs=case['runtimeArgs'],repetitions=1,warmups=0,expectedStdout=case['expectedStdout'],expectedStdoutEvidence=case['expectedStdoutEvidence'],binary=str(out/(name+'-diagnostic'))))
inputs=[pin(__file__),pin(PROF/'runtime.py'),pin(PROF/'runtime-support.inc.c'),pin(source),pin(base/'runtime.h'),pin(base/'primitives.h'),pin(base/'runtime.o'),pin(acqfile),pin(corpusfile),pin('/usr/bin/x86_64-linux-gnu-gcc-10')]
for c in cases:inputs.extend(c[k] for k in ['source','object','qbe','parentBinary','build','expectedStdoutEvidence'])
for i in inputs:verify(i)
out.mkdir();(out/'runtime.c').write_text(text);(out/'runtime-support.inc.c').write_text(extended)
for n in ['runtime.h','primitives.h']:shutil.copyfile(base/n,out/n)
shutil.copyfile(__file__,out/'method.py')
expectedfile=PROF/'controls/runtime-control.expected.json';expected=json.loads(expectedfile.read_text());expected['counterNames'].extend(v for _,v in COUNTERS)
for row in [expected['totals'],*expected['rows'].values()]:row.update({v:0 for _,v in COUNTERS})
expected['limitations'].append('The seven additive concat counters have zero expected events in this unchanged independent ABI fixture. Their positive branch coverage is not qualified by this fixture.')
expected['derivation']+=' Additive concat counters are zero because this frozen source never calls p125_rt_concat_typed.'
(out/'expected-control.json').write_text(json.dumps(expected,indent=2)+'\n');inputs.append(pin(expectedfile))
(out/'edits.json').write_text(json.dumps(dict(generic=edits,concat=[dict(label=l,original=o,diagnostic=n) for l,o,n in hooks]),indent=2)+'\n')
gcc='/usr/bin/x86_64-linux-gnu-gcc-10';jobs=[dict(label='compile-runtime',command=[gcc,'-O2','-std=gnu11','-ffp-contract=off','-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')])]
for c in cases:jobs.append(dict(label='link-'+c['name'],command=[gcc,'-no-pie',c['object']['file'],str(out/'runtime.o'),'-pthread','-lm','-o',c['binary']]))
plan=dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,inputs=inputs,outputs=[pin(out/n) for n in ['runtime.c','runtime-support.inc.c','runtime.h','primitives.h','method.py','edits.json','expected-control.json']],jobs=jobs,cases=cases,addedCounters=[v for _,v in COUNTERS],scope='Opt-in additive concat diagnosis, same original program objects and runtime ABI. Original generic profiler files unchanged. Counters add no heap reads/ownership operations; existing conditions evaluated once. Branch counts include whole process initialization/validation/one iteration/output, not isolated timed kernel. No timings from this instrumented image are performance evidence.')
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(json.dumps(dict(plan=pin(out/'plan.json'),cases=len(cases),newCounters=len(COUNTERS),reverseExact=True)))
