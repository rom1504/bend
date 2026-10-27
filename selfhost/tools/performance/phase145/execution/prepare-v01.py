#!/usr/bin/env python3
"""Freeze same-source jobs and a reversible diagnostic API derivative; no targets."""
import argparse,hashlib,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p145native',ROOT/'selfhost/tools/performance/phase130/native-request.py')
N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
pin,verify,require=N.pin,N.verify,N.require
NAMES=['lookup','f_find','index_find','index_bucket','index_hash','p88_string_eq_go','String$eq','infer_node','check_node','nc_compact','p111v_stmt','p111v_value','p111v_body','p113e_stmt','p113e_body','p113a_verify','p113e_verify','p112s_verify','p114s_open','p134v_commit','p134v_check','p134v_function','p134v_stmt','p134v_scalar','p111v_schema','p111v_schema_stmt','p113e_schema','p113e_schema_stmt','p113e_signature','p113i_function','p113k_function','no_observer_plan','p128br_scan','p134e_next','p144e_body_tail','p111v_decl','p111v_assign','p111v_get','p111v_put','p111v_intersection_bucket','p111v_intersection','p111v_join','p113e_seed','p113e_seed_params','p113e_originals','ns_ctor_index','p113e_signatures','p111q_function_ids','p111q_constructor_ids','p134v_header']
TERMS={'infer_node':2,'check_node':2,'nc_compact':0,'p111v_stmt':0,'p113e_stmt':0}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145'),'Fresh Phase145 plan required')
 candidate_path=ROOT/'implementation/phase144/final04/candidate.json';candidate=json.loads(candidate_path.read_text())
 require(candidate['complete'] and candidate['nativeQualified'],'Qualified final04 required')
 api_report=json.loads(verify(candidate['checkedApi']).read_text());require(api_report['checked'] and api_report['api']==candidate['api'] and candidate['source'] in api_report['inputs'],'Checked source/API mismatch')
 carrier,base,carrier_inputs=N.carrier_inputs(Path(candidate['preferredCarrierReceipt']['file']))
 products_path=ROOT/'selfhost/build/phase144/final04-small-products01/report.json';products=json.loads(products_path.read_text());require(products['complete'],'Existing ordinary products required')
 cases=[]
 for name in ['lexer','coverage-map-churn-128','coverage-closures-256']:
  rows=[x for x in products['cases'] if x['name']==name];require(len(rows)==1,'Unique frozen case');r=rows[0]
  cases.append(dict(name=name,source=r['source'],expectedQbe=r['qbe']))
 source=verify(candidate['api']).read_text();matches=list(re.finditer(r'^function (\$[^\n(]+)\(([^\n]*)\) \{',source,re.M));hooks=[];modified=source
 for m in reversed(matches):
  name=m[1][1:-1]
  if name not in NAMES:continue
  params=[p.strip() for p in m[2].split(',') if p.strip()];value=params[0] if params else 'undefined'
  insertion='\n  /*p145*/globalThis.__p145hit('+json.dumps(name)+','+value+');/*p145end*/'
  if name in TERMS:insertion+='\n  /*p145*/globalThis.__p145hit('+json.dumps(name)+','+params[TERMS[name]]+',"term");/*p145end*/'
  modified=modified[:m.end()]+insertion+modified[m.end():]
  hooks.append(dict(name=name,header=m[0],termArgument=TERMS.get(name),kind='declaration entry; generated tail iterations are separately counted where present'))
 require(sorted(x['name'] for x in hooks)==sorted(NAMES),'Requested internal declaration absent/duplicate')
 # Preserve generated control flow: only insert calls inside existing loop blocks.
 for name in ['f_find','index_hash','p88_string_eq_go','p134e_next','p113e_schema']:
  pattern=r'(function \$'+re.escape(name)+r'\$\([^\n]*\) \{)(.*?)(?=\nfunction |\Z)'
  m=re.search(pattern,modified,re.S);require(m is not None,'Loop owner missing');body=m[2]
  if 'for (;;) {' in body:anchor='for (;;) {'
  elif 'for (;;) switch ($pc) {\n    case 0: {' in body:anchor='for (;;) switch ($pc) {\n    case 0: {'
  else:raise ValueError('Expected generated loop absent '+name)
  require(body.count(anchor)==1,'Ambiguous loop hook '+name)
  patch='\n      /*p145*/globalThis.__p145hit('+json.dumps(name)+',undefined,"loop");/*p145end*/'
  body=body.replace(anchor,anchor+patch);modified=modified[:m.start(2)]+body+modified[m.end(2):]
 # Count actual string-predicate Char.is_eq evaluations, not input lengths as work.
 anchor='$2 = ($Char$is_eq$(_h_1, _h2_0));'
 m=re.search(r'(function \$p88_string_eq_go\$\([^\n]*\) \{)(.*?)(?=\nfunction |\Z)',modified,re.S)
 require(m[2].count(anchor)==1,'String comparison anchor changed')
 body=m[2].replace(anchor,'/*p145inline*/globalThis.__p145hit("p88_string_eq_go",undefined,"characterComparison");/*p145end*/'+anchor)
 modified=modified[:m.start(2)]+body+modified[m.end(2):]
 reversed_source=re.sub(r'/\*p145inline\*/.*?/\*p145end\*/','',modified)
 reversed_source=re.sub(r'\n[ \t]*/\*p145\*/.*?/\*p145end\*/','',reversed_source)
 reversed_source=re.sub(r'/\*p145\*/.*?/\*p145end\*/','',reversed_source)
 require(reversed_source==source,'Hooks must reverse to exact checked API')
 out.mkdir(parents=True);(out/'diagnostic-api.mjs').write_text(modified)
 inputs=[pin(__file__),pin(HERE/'hosted-v01.mjs'),pin(HERE/'run-v01.py'),pin(candidate_path),candidate['checkedApi'],candidate['api'],candidate['source'],candidate['native'],candidate['nativeBuild'],candidate['runtime'],*api_report['inputs'],pin(products_path),*carrier_inputs]
 for c in cases:inputs.extend([c['source'],c['expectedQbe']])
 for p in inputs:verify(p)
 plan=dict(kind='phase145-same-source-execution-plan',complete=True,targetsRun=False,inputs=inputs,source=candidate['source'],api=candidate['api'],native=candidate['native'],nativeBuild=candidate['nativeBuild'],runtime=candidate['runtime'],bun=next(p for p in api_report['inputs'] if p['file'].endswith('/bun')),base=base,carrier=carrier['carrier'],stamp=carrier['stamp'],cases=cases,diagnosticApi=pin(out/'diagnostic-api.mjs'),hooks=hooks,reversalExact=True,
  scope='Same checked Bend source hosted by pinned Bun versus qualified direct-QBE N2; ordinary single-thread prepared-Base requests. Fresh process and no cross-request semantic cache. OS caches are not flushed. Diagnostic JIT/GC perturbations are excluded from clean ratios.',
  boundaries={'child':'Popen through wait4; source/Base reads, natural GC/reclamation, emitted complete output, process exit included; API acquisition and parent authentication excluded','js':'Also API import and observer timing/metadata costs; no forced final full GC','native':'Actual native CLI IO/RC and process teardown; stdout redirected to file','counts':'Selected declaration/loop/character events only; no universal dynamic instructions or memory accounting'})
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
if __name__=='__main__':main()
