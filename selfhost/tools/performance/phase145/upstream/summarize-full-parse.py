#!/usr/bin/env python3
"""Offline full-source loader comparison; no targets or new instrumentation."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];FULL=ROOT/'selfhost/build/phase145/upstream-full-parse01';PREFIX=ROOT/'selfhost/build/phase145/upstream03'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 out=FULL/'summary01.json';assert not out.exists();inputs=[pin(__file__)];rows={}
 for name,base,case in [('prefix',PREFIX,'compiler-prefix1024'),('full',FULL,'full-phase142')]:
  rows[name]={}
  for variant in ['original','counted']:
   p=base/(case+'-'+variant)/'report.json';a=json.loads(p.read_text());inputs.append(pin(p));assert a['complete']and a['fixture']['mode']=='parse-only'and a['variant']==variant
   assert set(a['timings'])<={'imports','compilerImport','load'} and not a.get('checked') and not a.get('product')
   for i in a['inputs']:assert pin(i['file'])==i
   guard=base/(case+'-'+variant+'-guard')/'process.json';g=json.loads(guard.read_text());inputs.append(pin(guard));assert g['complete']and g['returncode']==0
   rows[name][variant]=dict(source=a['fixture']['source'],loadSeconds=a['timings']['load'],observerSeconds=a['seconds'],guardSeconds=g['wallSeconds'],peakRssBytes=a['peakRssBytes'],peakTreeRssBytes=g['peakTreeRssBytes'],loaded=a['loaded'],counts=a['counts'],stages=a['stages'])
  assert rows[name]['original']['loaded']==rows[name]['counted']['loaded']
 before=rows['prefix'];after=rows['full'];p=before['counted']['counts'];f=after['counted']['counts']
 ratios=dict(sourceBytes=after['original']['source']['bytes']/before['original']['source']['bytes'],originalLoad=after['original']['loadSeconds']/before['original']['loadSeconds'],countedLoad=after['counted']['loadSeconds']/before['counted']['loadSeconds'],events=after['original']['loaded']['events']/before['original']['loaded']['events'],calls={k:f[k]['calls']/v['calls']for k,v in p.items()if k.startswith('load:')and v['calls']})
 report=dict(kind='phase145-full-upstream-parse-comparison',complete=True,targetsRun=False,inputs=inputs,rows=rows,fullOverPrefix=ratios,fullDiagnosticOverOriginal=after['counted']['loadSeconds']/after['original']['loadSeconds'],limits=['book_load includes source/Base loading, header/import processing, name resolution, declaration construction and parser conversions; it is not raw tokenization or syntax only.',
 'No checking or emission is performed. Matching summaries are event/name/kind/constructor evidence, not whole-AST equality or full-compiler correctness.',
 'These are two actual frozen source shapes, not a size-only benchmark family: prefix derives from final03 source; full is frozen Phase142. Shared Base changes effective size ratios.',
 'Function entries and distinct object identities are different from allocation bytes or repeated semantic work. Conversion environments can differ on the same object.',
 'Single fresh measurements establish bounded feasibility and shape differences, not asymptotic scaling or confidence bounds. Diagnostic counts add substantial overhead.'])
 out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(complete=True,out=str(out),fullOverPrefix=ratios,fullDiagnosticOverOriginal=report['fullDiagnosticOverOriginal']),indent=2))
if __name__=='__main__':main()
