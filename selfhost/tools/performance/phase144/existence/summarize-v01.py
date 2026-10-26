#!/usr/bin/env python3
"""Summarize existing completed consumer receipts; no target execution."""
import hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 source=ROOT/'selfhost/build/phase144/existence-screen01/report.json';r=json.loads(source.read_text());assert r['complete']
 rows=[]
 for fixture in r['rows']:
  for consumer in ('events','disjoint'):
   blocks=[b for b in fixture['blocks']if b['consumer']==consumer];assert len(blocks)==4
   metrics={}
   for key in ('seconds','inclusiveSeconds'):
    values={mode:[next(c[key]/c['repeats']for c in b['calls']if c['mode']==mode)for b in blocks]for mode in ('original','indexed')}
    ratios=[b/a for a,b in zip(values['original'],values['indexed'])]
    metrics[key]=dict(medians={m:statistics.median(v)for m,v in values.items()},pairedMedianRatio=statistics.median(ratios),pairedGeometricRatio=math.exp(statistics.mean(map(math.log,ratios))),rawValues=values)
   rows.append(dict(declarations=fixture['parsedDefinitions'],adts=len(fixture['adts']),consumer=consumer,metrics=metrics))
 out=ROOT/'selfhost/build/phase144/existence-summary01';assert not out.exists();out.mkdir()
 report=dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(source),pin(ROOT/'selfhost/build/phase144/existence-controls01/report.json')],rows=rows,
  decision='Select only prefix-disjoint adapter for next source/output gates. Reject event/name adapter: per-ADT fact rebuilding loses.',
  scope='Four alternating hosted observations per actual parsed compiler-prefix consumer. Index construction inside candidate; inclusive adds forced Bun GC, not native reference-count destruction. No native or full compilation speed claim.')
 (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(complete=True,rows=len(rows),report=str(out/'report.json'))))
if __name__=='__main__':main()
