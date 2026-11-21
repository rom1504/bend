"""Bounded, diagnostic-preserving sequence proof/finite check. Invoked under guard."""
import argparse, hashlib, json, subprocess, sys, time
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--lean',type=Path,required=True);a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False);start=time.monotonic();deadline=start+4.35

def pin(path):
    path=Path(path);b=path.read_bytes()
    return {'file':str(path.resolve()),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
report={'complete':False,'scope':'Generic list sequence theorem and finite semantic controls only; no compiler or machine equivalence.',
        'inputs':[pin(a.lean),pin(HERE/'Sequence.lean'),pin(HERE/'controls.py'),pin(__file__)], 'stages':[]}

def save():
    report['wallSeconds']=time.monotonic()-start
    (a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')

def stage(name,argv,cap):
    budget=min(cap,deadline-time.monotonic())
    row={'name':name,'argv':argv,'budgetSeconds':max(0,budget),'complete':False}
    report['stages'].append(row);save()
    if budget<=0:
        row['error']='whole-check deadline reached before dispatch';save();return False
    begin=time.monotonic()
    with (a.out/(name+'.stdout')).open('wb') as stdout, (a.out/(name+'.stderr')).open('wb') as stderr:
      process=subprocess.Popen(argv,stdout=stdout,stderr=stderr)
      try:
        row['returncode']=process.wait(timeout=budget)
      except subprocess.TimeoutExpired:
        process.kill();row['returncode']=process.wait();row['error']='stage wall deadline exceeded'
    row['wallSeconds']=time.monotonic()-begin
    row['complete']=row['returncode']==0
    row['stdout']=pin(a.out/(name+'.stdout'));row['stderr']=pin(a.out/(name+'.stderr'));save()
    return row['complete']

lean_ok=stage('lean',[str(a.lean),'-j1',str(HERE/'Sequence.lean')],3.0)
if lean_ok:
    output=(a.out/'lean.stdout').read_text()
    names=['Bend.TextSequence.'+s for s in ('join_split','join_split_append','join_split_repeat')]
    report['axiomReportsPresent']=all(s in output for s in names)
    report['noSorryAxiom']='sorryAx' not in output
    lean_ok=report['axiomReportsPresent'] and report['noSorryAxiom'];save()
finite_ok=stage('finite',[sys.executable,'-B',str(HERE/'controls.py'),'--out',str(a.out/'finite.json')],4.35)
if finite_ok:
    r=json.loads((a.out/'finite.json').read_bytes())
    finite_ok=r['complete'] and r['baseChecks']==32790 and r['repetitionChecks']==163950 and r['emptySegmentDroppingMutantRejected']
report['leanPassed']=lean_ok;report['finitePassed']=finite_ok
report['complete']=lean_ok and finite_ok;save()
print(json.dumps({'complete':report['complete'],'leanPassed':lean_ok,'finitePassed':finite_ok,'wallSeconds':report['wallSeconds']}))
sys.exit(0 if report['complete'] else 1)
