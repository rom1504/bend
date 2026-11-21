"""Offline final fold comparison. Executes objdump only, never target binaries."""
from pathlib import Path
import json,hashlib,re,math,subprocess
ROOT=Path(__file__).resolve().parents[4];OUT=Path(__file__).resolve().parent
runtime=ROOT/'selfhost/build/phase198/orbit-live-broad01/report.json';plan=ROOT/'selfhost/build/phase198/orbit-live-plan01/manifest.json';profile=ROOT/'selfhost/build/phase190/profile-role-analysis01/report.json';count=ROOT/'selfhost/build/phase198/runtime-count01/report.json'
r=json.loads(runtime.read_text());m=json.loads(plan.read_text());p=json.loads(profile.read_text());ct=json.loads(count.read_text())
def pin(p):return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
rows=[]
for c in r['cases']:
 if 'local-fold'not in c['id']:continue
 q=next(x for x in m['cases']if x['id']==c['id']);names=['candidate','live','c']
 ids={}
 for name in ['phase197','candidate']:
  pp=q['products'][name]['generatedSource'];actual=pin(Path(pp['file']));assert actual['sha256']==pp['sha256'];ids[name]=actual
 assert ids['phase197']['sha256']==ids['candidate']['sha256']
 body=OUT/(c['id']+'-candidate.objdump');ins=[]
 symbol='p113d_FID_'+'_'.join(str(ord(x))for x in '$product.fold.loop')+'_'
 body.write_text(subprocess.check_output(['objdump','-d','-M','intel','--no-show-raw-insn','--disassemble='+symbol,ids['candidate']['file']],text=True))
 for line in body.read_text().splitlines():
  match=re.match(r'\s*([0-9a-f]+):\s+(.*)',line)
  if match:ins.append((int(match[1],16),' '.join(match[2].split())))
 back=ins[-1];assert back[1].startswith('jmp');header=int(back[1].split()[1],16);ix=next(i for i,x in enumerate(ins)if x[0]==header);start=int(ins[ix+1][1].split()[1],16);hot=[s for a,s in ins if start<=a<back[0]]
 assert len(hot)==15 and not any(s.startswith('call')or'[rbp'in s or'[rsp'in s for s in hot)
 rows.append(dict(case=c['id'],n=c['point']['runtimeArgs'][0],seed=c['point']['runtimeArgs'][1],mediansNs={n:c['summary']['stats'][n]['medianMs']*1e6 for n in names},ratios=c['summary']['ratios'],objectIdenticalTo197=True,objects=ids,hotBody=hot,hotBodyInstructions=len(hot),hotWithControl=len(hot)+3,counters=next(x['second']for x in ct['cases']if x['id']==c['id'])))
a=next(x for x in rows if x['n']==4096);b=next(x for x in rows if x['n']==8192)
fit={}
for role in ['candidate','live','c']:
 slope=(b['mediansNs'][role]-a['mediansNs'][role])/4096;fit[role]=dict(nsPerCell=slope,interceptNs=a['mediansNs'][role]-4096*slope)
prof=p['roles']['local-fold:c'];hot=total=ns=0;caps=[]
for cp in prof['profile']['acceptedCaptures']:
 q=Path(cp['file']);assert pin(q)['sha256']==cp['sha256'];d=json.loads(q.read_text());per=cp['periodUs'];caps.append(pin(q))
 for v in d['pcs']:
  total+=v['samples']*per
  if 0xf880<=int(v['elf_address'],16)<0xf8b2:hot+=v['samples']*per;ns+=v['samples']
result=dict(complete=True,targetsExecuted=False,rows=rows,largePointAffineFit=fit,fitScope='Descriptive two-point fit across different seeds/ordinary binaries, not causal attribution or confidence bounds. Small C point does not follow this intercept.',cHistoricalExactSameBinary=dict(samples=prof['profile']['samples'],innerSamples=ns,innerWeightedFraction=hot/total,region=['0xf880','0xf8b2'],captures=caps),historicalDirectScope='Old Phase188 binary only:522/523 leaf samples in product.fold.loop,0.997492 weighted fraction. Never transfer that percentage to orbit binary.',inputs=[pin(x)for x in [runtime,plan,profile,count,Path(__file__),OUT/'machine-pins.json']])
(OUT/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(fit=fit,cHistoricalHotFraction=hot/total,familyLiveVsC=math.exp(sum(math.log(x['ratios']['live'])for x in rows)/3)),indent=2))
