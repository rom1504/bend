"""Read-only ELF activation and boundary audit; executes no target program."""
import hashlib,json,re,struct,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PLAN=ROOT/'selfhost/build/phase199/focused-plan01/study.json'
OUT=Path(__file__).resolve().parent/'machine-evidence'
OUT.mkdir(exist_ok=True)
def pin(p):
 p=Path(p); b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def text_bytes(p):
 b=p.read_bytes();assert b[:6]==b'\x7fELF\x02\x01';shoff=struct.unpack_from('<Q',b,40)[0];ents,n,strings=struct.unpack_from('<HHH',b,58)
 hdr=[struct.unpack_from('<IIQQQQIIQQ',b,shoff+i*ents) for i in range(n)];s=hdr[strings];names=b[s[4]:s[4]+s[5]]
 for h in hdr:
  name=names[h[0]:].split(b'\0',1)[0]
  if name==b'.text':return b[h[4]:h[4]+h[5]]
 raise AssertionError('.text missing')
def worker(p,symbol):
 symbols=subprocess.check_output(['nm','-S','--defined-only',str(p)],text=True)
 rows=[x.split() for x in symbols.splitlines() if x.endswith(' '+symbol)]
 assert len(rows)==1
 start,size=int(rows[0][0],16),int(rows[0][1],16)
 command=['objdump','-dr','-M','intel','--no-show-raw-insn','--disassemble='+symbol,str(p)]
 raw=subprocess.check_output(command,text=True);lines=[];ins=[];rels=[]
 for line in raw.splitlines():
  m=re.match(r'\s*([0-9a-f]+):\s+(.*)',line)
  if m and start<=int(m[1],16)<start+size:
   lines.append(line)
   (rels if m[2].startswith('R_') else ins).append((int(m[1],16),m[2]))
 data=text_bytes(p)[start:start+size]
 return dict(symbol=symbol,start=start,bytes=size,instructions=len(ins),codeSha256=hashlib.sha256(data).hexdigest(),helperCalls=[hex(a-1) for a,t in rels if 'p199_rt_u32_scan4' in t],relocations=[dict(offset=hex(a),text=t) for a,t in rels],command=command),lines
plan=json.loads(PLAN.read_text());rows=[]
symbol='p113d_FID_'+''.join(str(ord(c))+'_' for c in '$product.fold.loop')
for case in plan['cases']:
 cid=case['id'];p=ROOT/'selfhost/build/phase199/focused-emission01/scan'/cid/'program.o';b=Path(case['baselineObject']['file'])
 if not p.exists():continue
 assert pin(b)['sha256']==case['baselineObject']['sha256']
 r=dict(id=cid,baseline=pin(b),candidate=pin(p),identical=b.read_bytes()==p.read_bytes())
 if 'local-fold' in cid:
  r['baselineWorker'],_=worker(b,symbol);r['candidateWorker'],lines=worker(p,symbol)
  assert len(r['candidateWorker']['helperCalls'])==1 and not r['baselineWorker']['helperCalls']
  if cid=='local-fold':
   witness=OUT/'local-fold-worker.txt';witness.write_text('\n'.join(lines)+'\n');r['witness']=pin(witness)
 else:assert r['identical'],cid
 rows.append(r)
result=dict(complete=True,scope='Read-only actual ELF audit, no target execution or correctness inference.',plan=pin(PLAN),method=pin(__file__),cases=rows,interpretation='The guarded nonzero worker snapshots payload/mask/fuel/index/carry into SysV RDI/RSI/RDX/RCX/R8 before the helper call. Original owner is live in callee-saved RBX and result-out pointer at rbp-0x30; RAX carry is written to output slot1 after owner slot0. Scalar guard fallback and zero result remain. Independent execution is required to validate this static ABI witness.')
(OUT/'report.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps([dict(id=x['id'],identical=x['identical'],worker=x.get('candidateWorker',{}).get('bytes'),helper=x.get('candidateWorker',{}).get('helperCalls')) for x in rows]))
