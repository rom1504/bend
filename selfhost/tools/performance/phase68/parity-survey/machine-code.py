#!/usr/bin/env python3
"""Read-only disassembly of already qualified binaries. Does not execute them."""
import collections,hashlib,json,pathlib,re,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[5]
OUT=ROOT/'selfhost/build/phase68/parity-survey23-assembly01'
def pin(p):return {'path':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size}
def decode(s):return re.sub(r'FID_((?:\d+_)+)',lambda m:'FID['+''.join(chr(int(n)) for n in m[1].split('_') if n)+']',s)
def fid(name):return 'WL_FID_'+''.join(str(ord(c))+'_' for c in name)
report=ROOT/'selfhost/build/phase68/parity-survey23-debug01/report.json';d=json.loads(report.read_text());assert d['complete']
rows=[]
for family in ['closures','map']:
 for role in ['selfhost','upstream']:
  r=next(r for r in d['records'] if r['job']['case']==family and r['job']['role']==role)
  assert r['textIdentical'];exe=pathlib.Path(r['executable']['path']);assert pin(exe)['sha256']==r['executable']['sha256']
  names=['rfc_wrap','term_keep','term_drop','WL_BEND_CLO_APPLY' if role=='selfhost' else 'WL_FID_CLO_APPLY']
  if family=='closures':names += [fid('$direct.../phase37/fixtures-new/closures:chain'),fid('native_k_15623')] if role=='selfhost' else ['WL_FID____PHASE37_FIXTURES_NEW_CLOSURES_CHAIN','WL_FID____PHASE37_FIXTURES_NEW_CLOSURES_CHAIN_C40']
  if family=='map':names += [fid('$direct.Map.bit.go'),fid('$direct.Map.bit.go.rec'),fid('$direct.Map.bit.go.chr')] if role=='selfhost' else ['WL_FID_MAP_BIT_GO','WL_FID_MAP_BIT_GO_K51']
  item={'family':family,'role':role,'executable':pin(exe),'text_identical_to_qualified':True,'text_sha256':r['textExtractions'][0]['section']['sha256'],'symbols':[]}
  for name in names:
   cmd=['objdump','-d','--no-show-raw-insn','--disassemble='+name,str(exe)];out=subprocess.check_output(cmd,text=True)
   dest=OUT/(family+'-'+role+'-'+decode(name).replace('/','_').replace('$','')+'.asm');dest.write_text(out)
   insns=[]
   for l in out.splitlines():
    m=re.match(r'\s*([0-9a-f]+):\s+(\S+)(?:\s+(.*))?$',l)
    if m:insns.append({'address':'0x'+m[1],'mnemonic':m[2],'operands':m[3] or ''})
   calls=collections.Counter(re.findall(r'\bcallq?\s+[0-9a-f]+\s+<([^>+]+)',out))
   item['symbols'].append({'name':name,'decoded':decode(name),'disassembly':pin(dest),'instruction_count':len(insns),'calls':dict(calls),'conditional_jumps':sum(x['mnemonic'].startswith('j') and x['mnemonic'] not in ('jmp','jmpq') for x in insns),'lock_instructions':[x for x in insns if x['mnemonic']=='lock'],'instructions':insns})
  rows.append(item)
result={'schema':'phase68-c23-machine-code-v1','producer':pin(pathlib.Path(__file__)),'debug_report':pin(report),'scope':'Static x86-64 disassembly from .text-identical debug binaries; instructions counts include all branches, never dynamic cost. objdump CPU0 only.','rows':rows}
(OUT/'report.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'report':str(OUT/'report.json'),'symbols':sum(len(r['symbols']) for r in rows)}))
