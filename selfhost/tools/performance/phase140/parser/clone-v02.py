"""Exact append-only top-parser transport derivative; no target execution."""
import hashlib, importlib.util, json, re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
p=ROOT/'selfhost/tools/performance/phase131/prepare.py'
s=importlib.util.spec_from_file_location('C',p); C=importlib.util.module_from_spec(s);s.loader.exec_module(C)
SOURCE=ROOT/'selfhost/build/phase137/integrated-source03/compiler.bend'
raw=SOURCE.read_text(); assert hashlib.sha256(raw.encode()).hexdigest()=='2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38'
b=C.blocks(raw,True); g={n:set(re.findall(r'\b([A-Za-z_][A-Za-z0-9_]*)\(',v))&b.keys() for n,v in b.items()}
def reach(n):
 seen=set();todo=[n]
 while todo:
  q=todo.pop()
  if q in seen:continue
  seen.add(q);todo+=list(g[q]-seen)
 return seen
scc={n for n in reach('f_top') if 'f_top' in reach(n)}
assert len(scc)==34
hits=list(C.PAT.finditer(raw)); parts=[]; names={n:'p140p_'+n[2:] for n in scc}
for i,h in enumerate(hits):
 n=h[1]
 if n not in scc:continue
 block=raw[h.start():hits[i+1].start() if i+1<len(hits) else len(raw)]
 # Exclude provenance/comments so the mechanical derivative is reviewable.
 block='\n'.join(x for x in block.splitlines() if not x.lstrip().startswith('#')).rstrip()+'\n'
 law=block.startswith('law ')
 haslaw=b[n].startswith('law ')
 if law:
  block=block.replace('law '+n+':','law '+names[n]+':\n  for +p140p_stop: U32',1)
 else:
  block=block.replace('def '+n+'(', 'def '+names[n]+'(' + ('p140p_stop, ' if haslaw else '+p140p_stop: U32, '),1)
 for old,new in names.items():
  block=re.sub(r'\b'+old+r'\(',new+'(p140p_stop, ',block)
 block=re.sub(r'\bf_result\(', 'p140p_result(',block)
 block=block.replace('FRawResult','P140PStop')
 if n=='f_top' and not law:
  signature,body=block.split(':\n',1)
  block=signature+':\n  f_choose(P140PStop, U32.is_gt(p140p_stop,0) && U32.is_ge(f_begin(ts),p140p_stop) && (f_eq(f_tx(ts),"def") || f_eq(f_tx(ts),"law") || f_eq(f_tx(ts),"type")),\n    u => P140PCut{ts,book,imports,unsafe,scope},\n    u => '+body.strip()+')\n'
 parts.append(block)
text='# Mechanical derivative of the34 actual FRawResult parser SCC entries.\n# Only checkpoint transport, threaded stop cursor, and f_top stop branch differ.\n\n'+'\n'.join(parts)
out=HERE/'top-parser-v02.bend';assert not out.exists();out.write_text(text)
(HERE/'clone-v02.json').write_text(json.dumps(dict(complete=True,targetsRun=False,source=C.pin(SOURCE),method=C.pin(__file__),composer=C.pin(p),module=C.pin(out),functions=sorted(scc),transformation='Rename exact34 SCC declarations/calls; thread U32 stop; FRawResult→P140PStop; f_result wrapper; add pre-f_top stop branch. All other expressions unchanged.'),indent=2)+'\n')
print(len(text.splitlines()),'lines',len(scc),'functions')
