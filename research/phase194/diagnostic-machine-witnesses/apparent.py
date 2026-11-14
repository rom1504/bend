#!/usr/bin/env python3
"""Inspect changed call paths and exact leaf bytes; never executes a target."""
from pathlib import Path
import subprocess,re,hashlib,json
ROOT=Path(__file__).resolve().parents[3];OUT=Path(__file__).resolve().parent
report={}
for case in ['value-identity-rebind','value-identity-helpers','product-ownership-unique','predicate-flow-mask']:
 report[case]={}
 for role,stage in [('selected','diag-selected-build02'),('commutative','diag-commutative-build01')]:
  binary=ROOT/'selfhost/build/phase194'/stage/case/'machine/program'
  report[case][role]={}
  for which in ['kernel','loop']:
   sym='p113d_FID_'+''.join(str(x)+'_'for x in ('$direct.p194.'+which).encode())
   asm=subprocess.check_output(['objdump','-d','--no-show-raw-insn','--disassemble='+sym,str(binary)],text=True)
   path=OUT/f'{case}-{role}-{which}.asm';path.write_text(asm)
   raw=subprocess.check_output(['objdump','-d','--disassemble='+sym,str(binary)],text=True)
   code=b''.join(bytes.fromhex(x)for x in re.findall(r'^\s*[a-f0-9]+:\s*((?:[a-f0-9]{2}\s)+)',raw,re.M))
   rows=[(int(a,16),s)for a,s in re.findall(r'^\s*([a-f0-9]+):\s*(.+)',asm,re.M)]
   first=rows[0][0]
   row={'address':hex(first),'addressMod64':first%64,'codeBytes':len(code),'codeSha256':hashlib.sha256(code).hexdigest(),
    'assembly':str(path.relative_to(ROOT)),'assemblySha256':hashlib.sha256(path.read_bytes()).hexdigest(),'instructions':len(rows)}
   if which=='kernel':
    dest=int(re.search(r'jmp\w*\s+([a-f0-9]+)',rows[-1][1])[1],16)
    h=next(i for i,(a,s)in enumerate(rows)if a==dest)
    positive=int(re.search(r'jne\w*\s+([a-f0-9]+)',rows[h+1][1])[1],16)
    r=rows[h:h+2]+[(a,s)for a,s in rows if a>=positive]
    row.update(loopInstructions=len(r),loopMoves=sum(s.startswith('mov')for a,s in r),loopHeader=hex(dest),loopHeaderMod64=dest%64)
   report[case][role][which]=row
(OUT/'apparent-gains.json').write_text(json.dumps(report,indent=2)+'\n')
