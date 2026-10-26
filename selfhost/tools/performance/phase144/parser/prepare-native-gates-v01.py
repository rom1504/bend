#!/usr/bin/env python3
"""Freeze serial root-owned source/oracle gates; do not execute a target."""
import argparse,hashlib,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--source-manifest',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
 manifest=json.loads(a.source_manifest.read_text());assert manifest['complete'] and not manifest['checked']
 method=HERE/'prepare-native-v04.py';spec=importlib.util.spec_from_file_location('slice',method);S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
 inputs=[pin(__file__),pin(a.source_manifest),pin(method),pin(HERE/'native-oracle-v01.mjs'),*manifest['inputs']]
 audits={};pair={}
 for role,row in manifest['sourcePair'].items():
  assert pin(row['source']['file'])==row['source'];assert pin(row['original']['file'])==row['original'];inputs.extend([row['source'],row['original']])
  text=Path(row['source']['file']).read_text();blocks=S.C.blocks(text,combine=True);parent=S.C.blocks(Path(row['original']['file']).read_text(),combine=True);pair[role]=blocks
  assert row['independentDependencyAudit']['complete'] and not row['independentDependencyAudit']['missingInternalNames']
  assert 'f_lex_scanned' in blocks and 'norm_defs_join' in blocks
  assert blocks['norm_defs_join'].startswith('law ') and '\ndef norm_defs_join(' in blocks['norm_defs_join']
  for original,cloned in S.NAMES.items():
   if original not in S.PREFIX:continue
   body=blocks[cloned]
   for old,new in sorted(S.NAMES.items(),key=lambda x:-len(x[1])):body=re.sub(r'\b'+re.escape(new)+r'\b',old,body)
   body=body.replace('P144PNError','P86PlanError').replace('P144PNResult','P86Plan')
   assert S.C.norm(body)==S.C.norm(parent[original]),original
  for name in ('p88_cache_prepare','p88_cache_result','p86_prepare_states','f_prefix_complete_ready_seed','f_prefix_complete_source','f_prefix_graph_trace'):
   assert blocks[name]==parent[name],name
  assert blocks['p144pn_parse_completed'].count('p144pn_loaded(seed, f_prefix_graph_trace(carrier, [source, base], fresh))')==1
  assert blocks['p144pn_loaded'].count('P144PNParsed{load,seed}')==1
  assert text.index('type P144PNResult')<text.index('def p144pn_parse(')<text.index('def main()')
  assert blocks['p144pn_parsed'].index('IO.now()')<blocks['p144pn_parsed'].index('p144pn_observe(')
  assert 'p144pn_hash(result)' in blocks['p144pn_observe'] and 'p144pn_hash(' not in blocks['p144pn_parsed']
  # Check all public schema variants are explicitly represented by the observer.
  for kind,constructors in [('term',['KTerm','KLambda','KLiteral']),('def',['KDef','KIndexLeaf','KIndexNode'])]:
   for name in constructors:assert 'case '+name+'{' in blocks['p144pn_'+kind]
  audits[role]=dict(exactSixFunctionPrefix=True,preparedBaseAndPrefixHelpersExact=True,seedRetainedThroughParseClock=True,
   observationAfterParseClock=True,allTermAndDefinitionVariantsObserved=True,lawAndDefinitionRetained=True,
   lexerQuoteDependencyRetained=True,missingInternalDependencies=[],source=row['source'])
 common=set(pair['original'])&set(pair['candidate']);changed=sorted(n for n in common if pair['original'][n]!=pair['candidate'][n])
 assert not any(n.startswith('p144pn_') for n in changed),'Diagnostic source changed between variants'
 guard=ROOT/'selfhost/tools/performance/phase111/guard.py';check=ROOT/'selfhost/tools/performance/phase111/check-api.py';bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
 inputs.extend(map(pin,[guard,check,bun]));jobs=[];apis={}
 def guarded(label,seconds,cmd):return[sys.executable,'-B',str(guard),'--out',str(out/(label+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','128','--cpu','3','--',*map(str,cmd)]
 for role,suffix in [('original','original03'),('candidate','candidate01')]:
  dest=ROOT/('selfhost/build/phase111/p144-parser-slice-'+suffix);assert not dest.exists();apis[role]=str(dest/'report.json')
  jobs.append(dict(name='check-'+role,command=guarded('check-'+role,60,[sys.executable,'-B',check,'--source',manifest['sourcePair'][role]['source']['file'],'--out',dest,*manifest['exports']]),requiresCompletePrevious=True,receipt=apis[role]))
 oracle=out/'oracle';jobs.append(dict(name='full-input-structural-oracle',command=guarded('oracle',180,[bun,HERE/'native-oracle-v01.mjs',a.source_manifest.resolve(),apis['original'],apis['candidate'],oracle]),requiresCompletePrevious=True,receipt=str(oracle/'report.json')))
 for p in inputs:assert pin(p['file'])==p
 out.mkdir(parents=True);report=dict(kind='phase144-native-parser-gates',complete=True,targetsRun=False,inputs=list({p['file']:p for p in inputs}.values()),sourceAudit=audits,changedCommonDeclarations=changed,jobs=jobs,
  nextBuildPlan=pin(a.source_manifest.parent/'jobs.json'),scope='Run serially and stop after any failed receipt. Source completeness is an audited lexical overapproximation, not a proof of successful checking. No native build before both source checks and the full structural/checksum oracle pass. Native timing remains separate.')
 (out/'jobs.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,out=str(out),jobs=[j['name']for j in jobs],changedCommonDeclarations=changed)))
if __name__=='__main__':main()
