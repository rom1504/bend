"""Freeze dependency-preserving actual ELF loop projections without running MCA."""
from pathlib import Path
import json,hashlib,re,subprocess
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
m=json.loads((ROOT/'selfhost/build/phase198/orbit-live-plan01/manifest.json').read_text());c=next(c for c in m['cases']if c['id']=='local-fold')
def pin(p):return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
rows=[]
for role,product,sym in [('direct',c['products']['candidate']['generatedSource'],'p113d_FID_'+'_'.join(str(ord(x))for x in '$product.fold.loop')+'_'),('c',c['products']['c']['artifact'],'NF_FID_112_57_51_46_108_111_111_112_')]:
 p=Path(product['file']);assert pin(p)==product
 raw=subprocess.check_output(['objdump','-d','-M','intel','--no-show-raw-insn','--disassemble='+sym,str(p)],text=True)
 (HERE/(role+'-model.objdump')).write_text(raw)
 ins=[(int(q[1],16),' '.join(q[2].split()))for s in raw.splitlines()if(q:=re.match(r'\s*([0-9a-f]+):\s+(.*)',s))]
 if role=='direct':
  hot=[s for pc,s in ins if 0x3e70<=pc<0x3ea2];assert len(hot)==15
  lines=['.Lloop:','  cmp rdi,0','  jne .Lbody','.Lbody:',*['  '+s for s in hot],'  jmp .Lloop'];count=18;cells=1
 else:
  hot=[s for pc,s in ins if 0xf880<=pc<0xf8b2];assert len(hot)==15 and hot[-1].startswith('jne ')
  lines=['.Lloop:',*['  '+s for s in hot[:-1]],'  jne .Lloop'];count=15;cells=2
 dest=HERE/(role+'-model.s');dest.write_text('.intel_syntax noprefix\n.text\n'+'\n'.join(lines)+'\n')
 rows.append(dict(role=role,program=product,disassembly=pin(HERE/(role+'-model.objdump')),source=pin(dest),instructions=count,cellsPerIteration=cells))
plan=dict(status='frozen before model',cases=rows,cpu='ivybridge, family6/model58 physical guard from existing tree MCA',iterations=100,aliasModes=[False,True],prediction='C fewer instructions/control per cell should have lower normalized reciprocal throughput. Numerical agreement with retained ~2.027 incremental wall-time ratio is unproven and may fail.',scope='Actual steady taken path, original register recurrences/load/store retained; cold setup/exit/layout excluded. C processes2 cells/block, direct1; normalize cycles and throughput per cell. noalias=false conservatively serializes potentially aliasing accesses; noalias=true relaxes unknown store/load aliases. Neither encodes exact circular128-cell dependence. Branch prediction and measured whole-program timing are not modeled.')
(HERE/'model-plan.json').write_text(json.dumps(plan,indent=2)+'\n')
