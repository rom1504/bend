#!/usr/bin/env python3
"""Offline only: exact disassembly census, projection and independent integer checks."""
import hashlib,json,pathlib,re,subprocess,random,os
os.sched_setaffinity(0,{0})
R=pathlib.Path(__file__).resolve().parents[3]; OUT=pathlib.Path(__file__).resolve().parent
N=2**32-1

def cert(d):
 if not 1<d<=N:return None
 for k in range(32,64):
  m=((1<<k)+d-1)//d
  if m>N:break
  # ceil reciprocal cannot underestimate. Maximum error occurs at one of
  # these endpoints: last full quotient interval or final partial interval.
  ends=[N,(N//d)*d-1]
  if all((n*m)>>k==n//d for n in ends):return m,k
 return None

def apply(n,d):
 c=cert(d)
 if c is None:return None
 m,k=c;n&=N
 return (n-((n*m)>>k)*d)&N

pins=[];census={}
for role,root in [('baseline','selfhost/build/phase194/native45-02'),('combined','selfhost/build/phase195/combined-dev-build01')]:
 for case in ['lexer','tree-bitonic','editdist','local-pair','coverage-numeric-recurrence-256','variation-ray-active-64-2440']:
  p=R/root/case/'machine/program'
  if not p.exists():continue
  pins.append({'path':str(p.relative_to(R)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
  lines=subprocess.check_output(['objdump','-d','--no-show-raw-insn','-M','intel',str(p)],text=True).splitlines();sym='';hits=[]
  for i,line in enumerate(lines):
   if re.match(r'^\w+ <',line):sym=line
   if 'call' in line and '<p111_rt_op>' in line and any('rsi,0x13' in v for v in lines[i-7:i]):
    window=lines[max(0,i-15):i+5];hits.append({'symbol':sym,'call':line,'window':window})
  census[role+'/'+case]=hits
  if case=='lexer':
   (OUT/(role+'-lexer-mod-calls.asm')).write_text('\n\n'.join(h['symbol']+'\n'+'\n'.join(h['window']) for h in hits)+'\n')
   rt=subprocess.check_output(['objdump','-d','--no-show-raw-insn','-M','intel','--disassemble=p111_rt_op',str(p)],text=True)
   (OUT/(role+'-lexer-runtime.asm')).write_text(rt)

before='''.intel_syntax noprefix
# Actual nonzero U32.mod arithmetic, projected from combined runtime
# 0x41cbea..0x41cbf1, with literal26 from caller0x408afa.
# Registers normalized to input ebx/output edi; calls, dispatch and loads omitted.
mov ecx, 26
mov eax, ebx
xor edx, edx
div ecx
mov edi, edx
'''
after='''.intel_syntax noprefix
# Proposed reserved-r10/r11 arithmetic for exact certified divisor26.
# Input ebx/output edi; no runtime call, same canonical low32 result.
mov r10d, ebx
mov r11d, 1321528399
imul r11, r10
shr r11, 35
imul r11d, r11d, 26
sub r10d, r11d
mov edi, r10d
'''
(OUT/'remainder26-before.s').write_text(before);(OUT/'remainder26-after.s').write_text(after)
rng=random.Random(19526); checks=0;unsupported=[];admitted=[]
for d in list(range(2,257))+[65535,65536,65537,2**31-1,2**31,2**31+1,N]:
 c=cert(d)
 if c is None:unsupported.append(d);continue
 admitted.append({'d':d,'magic':c[0],'shift':c[1]})
 points=set(range(256))|{N,N-1,2**31-1,2**31,2**31+1}
 for q in [0,1,2,N//d-1,N//d]+[rng.randrange(N//d+1) for _ in range(64)]:
  for off in [-1,0,1,d-1]:
   if 0<=q*d+off<=N:points.add(q*d+off)
 points|={rng.getrandbits(32) for _ in range(128)}
 for n in points:
  assert apply(n,d)==n%d,(n,d,c);checks+=1
 # Deliberately contaminated upper input bits must be narrowed for nonzero d.
 for n in list(points)[:32]:assert apply(n+(rng.getrandbits(32)<<32),d)==n%d;checks+=1
mutants=[]
for kind in ['wrong-shift','wrong-magic','no-input-truncation']:
 found=None
 for n in [0,1,25,26,27,N,2**31,2**31-1]+[rng.getrandbits(32) for _ in range(10000)]:
  m,k=cert(26)
  if kind=='wrong-shift':value=(n-((n*m)>>(k-1))*26)&N
  elif kind=='wrong-magic':value=(n-((n*(m-1))>>k)*26)&N
  else:
   raw=n+(1<<32);value=(raw-((raw*m)>>k)*26)&N
  if value!=n%26:found={'n':n,'got':value,'want':n%26};break
 assert found;mutants.append({'kind':kind,'counterexample':found})
result={'inputs':pins,'staticCallCensus':{k:len(v) for k,v in census.items()},'cases':census,'certificate':{'description':'ceil reciprocal; endpoints bound every complete quotient interval and final partial interval','admitted':admitted,'refused':unsupported,'zeroOneRefused':cert(0) is None and cert(1) is None},'independentPythonModuloChecks':checks,'mutantsRejected':mutants,'targetExecutions':0,'compilerExecutions':0,'modelExecuted':False,'frozenPrediction':'Arithmetic model should improve versus DIV for26; whole-lexer improvement expected positive, magnitude unknown. Runtime/profile percentage is not removable share. Model omits real calls, dispatch, packing and code layout; do not treat model ratio as program ratio.','projectionPins':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [OUT/'remainder26-before.s',OUT/'remainder26-after.s']}}
(OUT/'constant-remainder-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'staticCallCensus':result['staticCallCensus'],'oracleChecks':checks,'mutantsRejected':len(mutants),'admittedDivisors':len(admitted),'refusedDivisors':len(unsupported),'divisors':{d:cert(d) for d in [6,7,10,26]}}))
