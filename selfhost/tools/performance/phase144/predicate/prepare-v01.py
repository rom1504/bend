#!/usr/bin/env python3
"""Source-only actual-index proxy extraction and negated-condition census."""
import collections,hashlib,importlib.util,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
SOURCE=ROOT/'selfhost/build/phase144/integrated-source01/compiler.bend'
OUT=ROOT/'selfhost/build/phase144/predicate-proxy-source01'
OLD=ROOT/'selfhost/tools/performance/phase131/identity'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 assert not OUT.exists()
 assert pin(SOURCE)['sha256']=='992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b'
 spec=importlib.util.spec_from_file_location('census',ROOT/'selfhost/tools/performance/phase141/census/read-onlyinventory.py')
 C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
 rows=C.parse(str(SOURCE));names={r['name'] for r in rows};owners=collections.defaultdict(set)
 for r in rows:
  if r['kind']=='type':
   for n in re.findall(r'\b([A-Z][A-Za-z0-9_]*)\s*\{',C.clean(r['raw'])):owners[n].add(r['name'])
 graph={n:set() for n in names}
 for r in rows:
  graph[r['name']]|=r['tokens']&names
  for t in r['tokens']:graph[r['name']]|=owners.get(t,set())
 roots={'p131i_insert','index_set','index_find','kt','atom','dn','da','missing','p131ic_case','p131ic_legacy_case','p131ic_queries'}
 selected=C.reach(graph,roots)
 assert len(selected)==42 and 'main' not in selected
 replacement=(HERE/'insert-positive-v01.bend').read_text()
 old=next(r['raw'] for r in rows if r['kind']=='def' and r['name']=='p131i_insert')
 # Require the exact one-condition/two-arm change, not arbitrary source edits.
 needle='''        u => kc(KDef, Bool.not(U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0)),
          v => index_join(tree, d, hash, index_split_bit(diff)),
          v => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
            w => index_node(stored, split, p131i_insert(left, d, hash), right),
            w => index_node(stored, split, left, p131i_insert(right, d, hash)))))'''
 revised='''        u => kc(KDef, U32.is_eq(U32.and(diff, U32.sub(split, 1)), 0),
          v => kc(KDef, U32.is_eq(U32.and(hash, split), 0),
            w => index_node(stored, split, p131i_insert(left, d, hash), right),
            w => index_node(stored, split, left, p131i_insert(right, d, hash))),
          v => index_join(tree, d, hash, index_split_bit(diff))))'''
 assert old.count(needle)==1
 assert C.norm(old.replace(needle,revised))==C.norm(replacement)
 oldnames=json.loads((OLD/'proxy-manifest.json').read_text())['actualCompilerNames']
 assert len(oldnames)==len(set(oldnames))==256 and set(oldnames)<=names
 namesdef='def p131ip_names() -> List<&2,String>:\n  ['+',\n   '.join(json.dumps(n) for n in oldnames)+']\n'
 workload=(OLD/'proxy-workload.bend').read_text()
 assert 'def main()' in workload
 OUT.mkdir(parents=True)
 variants=[]
 for label in ['original','positive']:
  text='import Base\n\n'+''.join(replacement+'\n\n' if label=='positive' and r['name']=='p131i_insert' else r['raw'] for r in rows if r['name'] in selected)+'\n'+namesdef+'\n'+workload
  path=OUT/(label+'.bend');path.write_text(text)
  variants.append(dict(name='predicate-index-'+label,source=pin(path),expected=pin(OLD/'proxy-v02-expected.json'),expectedStdoutEvidence=pin(OLD/'proxy-v02-expected.json')))
 (OUT/'cases.json').write_text(json.dumps(dict(complete=True,cases=variants),indent=2)+'\n')
 # Conservative syntax census. Count all Bool.not references, then simple
 # conditional prefixes with a complete Bool.not call as condition. No rewrite.
 occurrences=[];direct=[]
 for r in rows:
  if r['kind']!='def':continue
  raw=C.clean(r['raw']);hits=list(re.finditer(r'\bBool\.not\s*\(',raw))
  if hits:occurrences.append(dict(owner=r['name'],line=r['line'],count=len(hits)))
  # Type argument is restricted to comma-free parentheses here; complex types
  # are deliberately omitted rather than parsed approximately as expressions.
  for m in re.finditer(r'\b(kc|nt_choose|f_choose)\(\s*[^,\n]+,\s*Bool\.not\s*\(',raw):
   depth=1;i=m.end()
   while i<len(raw) and depth:
    depth+=(raw[i]=='(')-(raw[i]==')');i+=1
   if depth==0 and raw[i:].lstrip().startswith(','):
    direct.append(dict(owner=r['name'],line=r['line']+raw[:m.start()].count('\n'),chooser=m[1]))
 census=dict(totalBoolNotCallsites=sum(x['count'] for x in occurrences),owners=len(occurrences),completeNegatedSimpleChooserConditions=len(direct),directConditionOwners=len({x['owner'] for x in direct}),occurrences=occurrences,directConditions=direct,scope='Lexical counts, not dynamic frequency. Direct-condition count excludes complex type arguments and composite Boolean conditions; no name-only optimization is authorized.')
 (OUT/'negation-census.json').write_text(json.dumps(census,indent=2)+'\n')
 report=dict(complete=True,checked=False,targetsRun=False,source=pin(SOURCE),inputs=[pin(__file__),pin(C.__file__),pin(HERE/'insert-positive-v01.bend'),pin(OLD/'proxy-manifest.json'),pin(OLD/'proxy-workload.bend'),pin(OLD/'proxy-v02-expected.json'),pin(OLD/'check.mjs'),pin(OLD/'timing-oracle.py')],roots=sorted(roots),declarations=[dict(kind=r['kind'],name=r['name'],line=r['line'],sha256=hashlib.sha256(r['raw'].encode()).hexdigest())for r in rows if r['name']in selected],cases=variants,checkedApiExports=['p131ic_case','p131ic_legacy_case','p131ic_queries'],controlMethod=pin(OLD/'check.mjs'),controlScope='Existing336 complete-tree comparisons +11088 independent payload lookups; retained legacy,collision,duplicate,wrapping-boundary cases. No tests executed by preparation.',nativeTimingMethod=pin(OLD/'timing-oracle.py'),negationCensus=pin(OUT/'negation-census.json'),scope='Exact current compiler index slice,256 actual compiler names, unchanged two-pass workload. Sole candidate delta positive equality with swapped arms. No general optimizer/ownership/runtime change.')
 (OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps(dict(complete=True,targetsRun=False,selectedNames=len(selected),sourceBytes=[c['source']['bytes'] for c in variants],negationCalls=census['totalBoolNotCallsites'],simpleNegatedConditions=len(direct))))
if __name__=='__main__':main()
