#!/usr/bin/env python3
"""Derive narrow current-fold and two-worker-auditor successors; execute nothing."""
import argparse, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]

def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())

def emit(parent,out,name,changes,kind):
 text=parent.read_text(); original=out/('original-'+name);original.write_bytes(parent.read_bytes())
 for before,after,count in changes:
  assert text.count(before)==count,(name,before,text.count(before));text=text.replace(before,after)
 target=out/name;target.write_text(text)
 report=dict(kind=kind,complete=True,executed=False,parent=ident(parent),original=ident(original),derived=ident(target),producer=ident(__file__),changes=[dict(before=a,after=b,count=n) for a,b,n in changes])
 target.with_suffix('.json').write_text(json.dumps(report,indent=2)+'\n')
 return target

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('out',type=Path);a=ap.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
 fold=ROOT/'selfhost/tools/performance/phase35/fold-final-controls.py'
 assert ident(fold)['sha256']=='51bd2646c5a08d784b0ae216e06441ed791cb4a8e5d556cd5170e0fc18629426'
 foldchanges=[
  ('HERE = Path(__file__).resolve().parent',f'HERE = Path({str(fold.parent)!r})',1),
  ("str(HERE/(name+'.mjs'))", "str(HERE.parent/'phase40/fold-controls-v3.mjs') if name=='fold-controls' else str(HERE/(name+'.mjs'))",1),
  ("dict(api=manifest['api']['file'])","dict(api=manifest['api']['file'], selectedApi=manifest['api'], attempt=ident(attempt/'attempt.json'))",1),
  ("kind='phase35-final-recursive-fold-owner'","kind='phase41-current-recursive-fold-owner'",1),
  ("inputs = [Path(__file__),", "inputs = [Path(__file__), Path(__file__).with_suffix('.json'), HERE/'fold-final-controls.py', HERE.parent/'phase40/fold-controls-v3.mjs', HERE.parent/'phase40/fold-controls-v3.json',",1),
 ]
 ft=emit(fold,out,'fold-final-controls-v1.py',foldchanges,'phase41-current-fold-wrapper-derivation')
 audit=ROOT/'selfhost/tools/performance/phase37/final-gate-audit.py'
 assert ident(audit)['sha256']=='808068f34159c1e9979914a469a46ba52a18f2cb4194ec47cc117d059226516a'
 # Parent identity is frozen in the emitted exact derivation; source counts fail closed.
 achanges=[
  ("ap.add_argument('out')", "ap.add_argument('out')\nap.add_argument('--frontend-tool-derivation', required=True)",1),
  ("Path(__file__).resolve().parent.parent / 'phase32/final-gate-audit.py'",repr(str(ROOT/'selfhost/tools/performance/phase32/final-gate-audit.py')),1),
  ("Path(__file__).resolve().parent.parent/'phase35/final-gate-audit.py'",repr(str(ROOT/'selfhost/tools/performance/phase35/final-gate-audit.py')),1),
  ("'phase37-inherited-final-audit-derivation'","'phase41-two-worker-final-audit-derivation'",1),
  ("len(candidate['workers']) == 1", "len(candidate['workers']) == 2",1),
  ("config['jobs'] == 1", "config['jobs'] == 2",1),
  ("candidateWorkers=1", "candidateWorkers=2",1),
  ("root = Path(__file__).resolve().parents[4]",f"root = Path({str(ROOT)!r})",1),
 ]
 before="    assert data['scope'] == name"
 after="""    frontend_derivation = read(args.frontend_tool_derivation)
    assert frontend_derivation['kind'] == 'phase41-two-worker-frontend-derivation'
    assert frontend_derivation['complete'] and not frontend_derivation['executed']
    for key in ['producer', 'parent', 'original', 'derived']:
        verify(frontend_derivation[key])
    assert any(x.get('sha256') == frontend_derivation['derived']['sha256'] and x.get('file') == frontend_derivation['derived']['file'] for x in data['inputs'])
    assert data['kind'] == 'phase41-two-worker-explicit-layout-frontend-gate'
    assert len(set(data['affinity'].split(','))) == len(data['affinity'].split(',')) == 2
    bounded = read(base / ('run-frontend-' + name) / 'run.json')
    assert bounded['complete'] and bounded['returncode'] == 0 and not bounded.get('stoppedFor')
    assert bounded['secondsLimit'] == 1200 and bounded['rssLimitBytes'] == 3072*1024**2
    assert bounded['availableFloorBytes'] == 2048*1024**2
    assert bounded['minimumAvailableBytes'] >= bounded['availableFloorBytes']
    assert bounded['peakTreeRssBytes'] <= bounded['rssLimitBytes']
    assert identity(Path(__file__).resolve().parents[0] / 'original-final-gate-audit-v1.py')['sha256'] == derivation['parent']['sha256']
    verify(bounded['producer'])
    assert bounded['producer']['sha256'] == identity("""+repr(str(ROOT/'selfhost/tools/performance/phase32/bounded-run.py'))+""")['sha256']
    assert frontend_derivation['derived']['file'] in bounded['command']
    assert 'PHASE41_FRONTEND_CPU='+data['affinity'] in bounded['command']
    assert data['scope'] == name"""
 achanges.append((before,after,1))
 at=emit(audit,out,'final-gate-audit-v1.py',achanges,'phase41-two-worker-final-audit-derivation')
 print(json.dumps(dict(complete=True,executed=False,fold=str(ft),audit=str(at))))
if __name__=='__main__':main()
