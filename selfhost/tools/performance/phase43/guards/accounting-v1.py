#!/usr/bin/env python3
"""Read-only refresh of source/tool inventory and enclosing campaign time accounting."""
import argparse, collections, datetime, hashlib, json, pathlib, re, subprocess
p=argparse.ArgumentParser();p.add_argument('--baseline',default='714c5f5');p.add_argument('--out',default='implementation/phase43/accounting.md');a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[5]
def git(*args):return subprocess.check_output(['git',*args],cwd=root)
base=git('rev-parse',a.baseline).decode().strip();head=git('rev-parse','HEAD').decode().strip()
def lines(b):return len(b.splitlines())
def defs(b):return set(re.findall(rb'^def\s+([^\s(]+)',b,re.M))
old={n:git('show',base+':'+n) for n in git('ls-tree','-r','--name-only',base,'--','selfhost/src').decode().splitlines() if n.endswith('.bend')}
new={str(f.relative_to(root)):f.read_bytes() for f in (root/'selfhost/src').rglob('*.bend')}
changes=[]
for row in git('diff','--numstat',base,'--','selfhost/src').decode().splitlines():
 plus,minus,name=row.split('\t');changes.append((name,int(plus),int(minus)))
ledger_path=root/'selfhost/build/phase43/campaign.jsonl';ledger_bytes=ledger_path.read_bytes();records=[json.loads(l) for l in ledger_bytes.splitlines() if l.strip()]
start=next(r['started'] for r in records if r.get('kind')=='start');events=[r for r in records if r.get('kind')=='event' and 'started' in r and 'finished' in r]
intervals=sorted((r['started'],r['finished']) for r in events);merged=[]
for s,e in intervals:
 assert start<=s<=e
 if merged and s<=merged[-1][1]:merged[-1][1]=max(e,merged[-1][1])
 else:merged.append([s,e])
end=max([start]+[r.get('recorded',r.get('finished',start)) for r in records]);summed=sum(e-s for s,e in intervals);union=sum(e-s for s,e in merged);span=end-start
fails=[r for r in events if not r.get('complete') or r.get('returncode',0)!=0]
def utc(t):return datetime.datetime.fromtimestamp(t,datetime.timezone.utc).isoformat()
def dur(t):return f'{t:.3f}s ({t/60:.2f}min)'
def table(headers,rows):return '| '+' | '.join(headers)+' |\n|'+ '|'.join(['---']*len(headers))+'|\n'+''.join('| '+' | '.join(map(str,row))+' |\n' for row in rows)
text=f'''# Phase43 complexity and elapsed-time accounting draft

Read-only snapshot refreshed {utc(datetime.datetime.now(datetime.timezone.utc).timestamp())}.
Protected baseline `{base}`; current checkout HEAD `{head}` plus current working
source. This is a draft before final source freeze, not a final selected-image cost
claim. Refresh after freeze with `python3 selfhost/tools/performance/phase43/guards/accounting-v1.py`.
Generated compiler/module images and `selfhost/build` artifacts are excluded from
source/tool growth. Physical lines include blank lines/comments; Bend definitions
count declarations beginning `def` at column zero, not compiler AST nodes.

## Production source inventory

'''
text+=table(['Scope','Baseline files','Current files','Baseline lines','Current lines','Net lines','Baseline defs','Current defs'],[
 ['All selfhost/src Bend modules',len(old),len(new),sum(map(lines,old.values())),sum(map(lines,new.values())),sum(map(lines,new.values()))-sum(map(lines,old.values())),sum(len(defs(b)) for b in old.values()),sum(len(defs(b)) for b in new.values())],
 ['JS backend Bend modules',sum('/back/js/' in n for n in old),sum('/back/js/' in n for n in new),sum(lines(b) for n,b in old.items() if '/back/js/' in n),sum(lines(b) for n,b in new.items() if '/back/js/' in n),sum(lines(b) for n,b in new.items() if '/back/js/' in n)-sum(lines(b) for n,b in old.items() if '/back/js/' in n),sum(len(defs(b)) for n,b in old.items() if '/back/js/' in n),sum(len(defs(b)) for n,b in new.items() if '/back/js/' in n)]])
text+='\nNo new production Bend modules were introduced at this snapshot; growth expands existing JS backend modules.\n'
text+='\nChanged production files (git diff additions/deletions include replacements):\n\n'
rows=[]
for n,plus,minus in changes:
 current=(root/n).read_bytes();previous=git('show',base+':'+n)
 rows.append([n,plus,minus,plus-minus,lines(previous),lines(current),len(defs(current))-len(defs(previous)) if n.endswith('.bend') else '—'])
text+=table(['File','Added','Deleted','Net lines','Baseline lines','Current lines','Net Bend defs'],rows)
runtime_old={n:git('show',base+':'+n) for n in git('ls-tree','-r','--name-only',base,'--','selfhost/src/runtime').decode().splitlines() if n.endswith(('.mjs','.c','.h'))}
runtime_new={str(f.relative_to(root)):f.read_bytes() for f in (root/'selfhost/src/runtime').rglob('*') if f.is_file() and f.suffix in ['.mjs','.c','.h']}
text+='\nRuntime source inventory (assembled runtime.mjs remains separate above):\n\n'
text+=table(['Scope','Baseline files','Current files','Baseline lines','Current lines','Net lines'],[[label,sum(n.endswith(ext) for n in runtime_old),sum(n.endswith(ext) for n in runtime_new),sum(lines(b) for n,b in runtime_old.items() if n.endswith(ext)),sum(lines(b) for n,b in runtime_new.items() if n.endswith(ext)),sum(lines(b) for n,b in runtime_new.items() if n.endswith(ext))-sum(lines(b) for n,b in runtime_old.items() if n.endswith(ext))] for label,ext in [('Canonical JS runtime modules','.mjs'),('Native C runtime files','.c'),('Native C headers','.h')]])
text+='''
`runtime/js/core.mjs` is the edited runtime source; `runtime.mjs` is its assembled
copy and contains the same growth. Report both on-disk inventories but count
runtime implementation growth once. This is source line accounting, not emitted
program size, runtime heap usage, compiler latency or complexity proof.

## Mechanism contributions

The file-level net totals above are exact. Shared predicates and rewrites overlap
families, so they cannot be honestly divided into additive net totals by feature.
The following narrower counts attribute newly introduced definition names and
nonblank, noncomment definition-span lines; they exclude edits to existing defs,
comments, decorators, new type declarations and runtime JS. They are an inventory
of added machinery, not a partition of net physical source growth.

'''
mechanisms=collections.defaultdict(lambda:[0,0])
def family(name):
 if name.startswith(('j_instance_','j_instances_','j_erased_','j_pure_map_','j_map_')):return 'Contextual erased instances / exact native Map proofs'
 if name.startswith('j_callback_'):return 'Closed scalar callback capture/application fusion'
 if name.startswith('j_pair_'):return 'Scalar pair loop proof and emission'
 if name.startswith(('j_string_','j_pure_bool_','j_linear_prefix_','j_linear_u32_','j_component_scalar_wrapper_')):return 'Native String / exact Bool / scalar-prefix admission'
 if name=='j_region_root_selected':return 'Full U32 fusion guard selection'
 return 'Other shared admission/emission machinery'
for n,b in new.items():
 previous=defs(old.get(n,b''));ls=b.decode().splitlines();positions=[i for i,l in enumerate(ls) if l.startswith('def ')]+[len(ls)]
 for i,j in zip(positions,positions[1:]):
  name=re.match(r'def\s+([^\s(]+)',ls[i])[1]
  if name.encode() not in previous:
   f=family(name);mechanisms[f][0]+=1;mechanisms[f][1]+=sum(bool(l.strip()) and not l.lstrip().startswith(('#','@')) and not re.match(r'^(type|record)\s',l) for l in ls[i:j])
text+=table(['Mechanism','New defs','Definition-span code lines'],[[f,*counts] for f,counts in sorted(mechanisms.items())])
text+='''
Runtime changes comprise String-family capture metadata and exact String host
descriptor checks, callback U32 capability plumbing, full-U32 fusion host subset
selection, and broader native function snapshots. The exact runtime total is the
single canonical core.mjs row above. Deferred AfterHost clones, resume liveness,
and wrapper-hop proposals live in experiment tools and do not contribute to
production source growth. Exact nominal/type/ownership checks and fallback paths
are substantial code; the campaign does not claim this is a smaller compiler.

## Experiment tool inventory

Count current files under `selfhost/tools/performance/phase43`, excluding
`__pycache__`/`.pyc`. Baseline snapshots are listed separately: they are preserved
inputs, not newly authored implementation. All other files include frozen failed
versions, patches, JS workers/controllers, Python orchestration, fixtures and
metadata. These totals are not production source costs. Binary gzip files count
bytes/files only, with zero text lines; compressed bytes are not source lines.

'''
tools=collections.defaultdict(lambda:[0,0,0]);suffix=collections.defaultdict(lambda:[0,0,0])
for f in (root/'selfhost/tools/performance/phase43').rglob('*'):
 if not f.is_file() or '__pycache__' in f.parts or f.suffix=='.pyc':continue
 rel=f.relative_to(root/'selfhost/tools/performance/phase43');group=rel.parts[0] if len(rel.parts)>1 else '(orchestration)';b=f.read_bytes()
 for bucket,key in [(tools,group),(suffix,f.suffix or '(no extension)')]:bucket[key][0]+=1;bucket[key][1]+=0 if f.suffix=='.gz' else lines(b);bucket[key][2]+=len(b)
baseline_tool_names=git('ls-tree','-r','--name-only',base,'--','selfhost/tools/performance/phase43').decode().splitlines()
text+=f'\nProtected commit contains {len(baseline_tool_names)} files in the Phase43 tool subtree.\n\n'
text+=table(['Tool family','Files','Physical lines','Bytes'],[[k,*v] for k,v in sorted(tools.items())])
text+='\n'+table(['File extension','Files','Physical lines','Bytes'],[[k,*v] for k,v in sorted(suffix.items())])
authored=[v for k,v in tools.items() if k!='baseline']
text+='\nNon-baseline experiment inventory totals: '+str(sum(v[0] for v in authored))+' files, '+str(sum(v[1] for v in authored))+' text lines, '+str(sum(v[2] for v in authored))+' bytes. This includes fixtures and copied reference sources; it is not a claim that every line was newly authored.\n'
text+=f'''
The refresh script itself is included. Tool inventory can grow through reporting
without changing compiler code. Version counts are intentionally not deduplicated:
frozen versions and rejected variants are part of the retained research cost.

## Recorded enclosing job time

Ledger `selfhost/build/phase43/campaign.jsonl`, SHA256
`{hashlib.sha256(ledger_bytes).hexdigest()}`, {len(records)} complete JSON records;
latest sequence {max(r.get('sequence',0) for r in records)}.
Clock scope begins at the ledger's explicit setup start ({utc(start)}); earlier
conversation/delegation is outside this clock. Cutoff is the latest ledger
recorded timestamp ({utc(end)}), not the time this document was generated.

'''
text+=table(['Quantity','Value'],[
 ['Completed enclosing interval records',len(events)],['Successful recorded jobs',len(events)-len(fails)],['Failed/incomplete recorded jobs',len(fails)],['Sum of failed/incomplete intervals',dur(sum(r['finished']-r['started'] for r in fails))],['Sum of enclosing wall intervals',dur(summed)],['Union of enclosing wall intervals',dur(union)],['Sum minus union (overlap)',dur(summed-union)],['Recorded wall span',dur(span)],['Wall span outside recorded interval union; unclassified',dur(span-union)],['Sum of reported toolElapsedSeconds',dur(sum(r.get('toolElapsedSeconds',0) for r in events))]])
text+='''
Each ledger event is an enclosing job interval. Nested child durations are not
added again. The sum counts overlapping enclosing intervals more than once; the
union measures covered wall time. Neither is CPU time, person-hours or model
inference time. The residual wall span is **unclassified**, including activity
outside recorded jobs and recording gaps; it must not be described as waiting,
model time or overhead. Jobs still running/unrecorded at cutoff are not charged.
A zero exit status says the supervising command passed; it does not mean every
hypothesis was useful or promoted. Nonzero status can be a sandbox/tool/control
failure and is not automatically a compiler semantic failure.

Failed/incomplete enclosing records:\n\n'''
text+=table(['Sequence','Label','Return code','Interval seconds'],[[r.get('sequence','—'),r.get('label','—'),r.get('returncode','—'),f"{r['finished']-r['started']:.3f}"] for r in fails])
labels=collections.Counter(r.get('label') for r in events);dupes=[k for k,v in labels.items() if v>1]
text+=f'\nRepeated enclosing labels: {json.dumps(dupes)}. Invalid/inverted intervals: none (asserted).\n'
text+='''
Final refresh must bind the selected source snapshot and completed release ledger.
Compiler-cost measurements, full timing/profiles and qualification decisions belong
in their respective receipts/reports; this accounting does not infer those costs
from line counts or elapsed job intervals.
'''
out=root/a.out;out.write_text(text);print(json.dumps({'output':str(out),'bendNetLines':sum(map(lines,new.values()))-sum(map(lines,old.values())),'jobs':len(events),'failed':len(fails),'sumSeconds':summed,'unionSeconds':union,'spanSeconds':span,'unclassifiedSeconds':span-union}))
