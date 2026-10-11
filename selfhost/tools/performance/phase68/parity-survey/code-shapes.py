#!/usr/bin/env python3
"""Read-only lexical analysis of exact qualified C artifacts; never compiles/runs C.

Counts occurrences in emitted source, not LLVM instructions or execution cost.
Host views only resolve literal DEVICE / !DEVICE preprocessor guards. All other
configuration alternatives remain counted. JSON records exact scope and hashes.
"""
import argparse, collections, hashlib, json, pathlib, re
ROOT=pathlib.Path(__file__).resolve().parents[5]

def pin(path):
 data=path.read_bytes()
 return {'path':str(path.relative_to(ROOT)), 'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}

def decode(text):
 return re.sub(r'((?:NF_)?FID_|CID__CTOR_)((?:\d+_)+)',lambda m:m[1]+'['+''.join(chr(int(x)) for x in m[2].split('_') if x)+']',text)

def host_view(text):
 stack=[]; out=[]
 for line in text.splitlines(keepends=True):
  x=line.strip()
  if re.match(r'#if(?:def|ndef)?\b',x):
   cond=False if x=='#if DEVICE' else True if x=='#if !DEVICE' else None
   stack.append(cond)
  elif x=='#else' and stack and stack[-1] is not None:stack[-1]=not stack[-1]
  elif x=='#endif' and stack:stack.pop()
  elif False not in stack:out.append(line)
 return ''.join(out)

OPS=['heap_alloc','heap_free','rfc_seal','rfc_wrap','term_keep','term_sink','term_drop','ctr_take','term_ctr','term_pak','term_clo','task_node','WL_ROOM','WL_PUSHN','WL_JMP','WL_AGAIN','WL_RETN','err_seen','err_post','blk_loc','native_arr_loc','spare_free']
def metrics(text):
 # Strings and comments cannot contribute operation counts.
 t=re.sub(r'"(?:\\.|[^"\\])*"|/\*.*?\*/|//[^\n]*',lambda m:'\n'*m[0].count('\n'),text,flags=re.S)
 d={x:len(re.findall(r'\b'+x+r'\s*\(',t)) for x in OPS}
 d.update({'lines':text.count('\n'),'bytes':len(text.encode()),'worker_calls':len(re.findall(r'\b(?:NF_FID_\w+|spin_\d+)\s*\(',t)), 'term_local_declarations':len(re.findall(r'\bTerm\s+[A-Za-z_]\w*',t)), 'u32_local_declarations':len(re.findall(r'\bu32\s+[A-Za-z_]\w*',t)), 'closure_apply_jumps':len(re.findall(r'WL_JMP\((?:FID_CLO_APPLY|BEND_CLO_APPLY)\)',t))})
 return d

def analyze(path):
 receipt_path=path.with_suffix('.c.json'); receipt=json.loads(receipt_path.read_text()); assert pin(path)['sha256']==receipt['output']['sha256'], str(path)
 t=path.read_text(); sp=t.index('// Spins'); work=t.index('// Work',sp); seg=t.index('// Segments',work); end=t.index('// Monk',seg)
 sections={'workers':t[sp:work],'segments':t[seg:end]}
 units=[]
 workerpat=r'^(?:INLINE|NF_INLINE)\s+Term\s+((?:NF_FID_\w+|spin_\d+))\([^;\n]*\)\s*\{'
 for kind,pat in [('workers',workerpat),('segments',r'^\s+WL_CASE\((\w+)\)')]:
  sec=sections[kind]; starts=list(re.finditer(pat,sec,re.M)); base=sp if kind=='workers' else seg
  for n,m in enumerate(starts):
   stop=starts[n+1].start() if n+1<len(starts) else len(sec);body=sec[m.start():stop];host=host_view(body)
   units.append({'kind':kind,'name':decode(m[1]),'line':t[:base+m.start()].count('\n')+1, 'host_device_guards_only':{k:v for k,v in metrics(host).items() if v}, 'worker_targets':dict(collections.Counter(decode(x) for x in re.findall(r'\b(NF_FID_\w+|spin_\d+)\s*\(',host)[1 if kind=='workers' else 0:])), 'jump_targets':dict(collections.Counter(decode(x) for x in re.findall(r'WL_(?:JMP|AGAIN)\((\w+)\)',host)))})
 adapters={u['name'] for u in units if u['kind']=='segments' and u['worker_targets']}
 return {'emission_receipt':pin(receipt_path), 'benchmark_input':receipt['input'], 'input':pin(path),'global_bangs':int(re.search(r'^#define BANGS\s+(\d+)',t,re.M)[1]),'whole_file_lines':t.count('\n'),'generated_regions':{k:{'all_branches':metrics(v),'host_device_guards_only':metrics(host_view(v))} for k,v in sections.items()},'units':[u for u in units if u['kind']=='workers' or '../phase37/' in u['name'] or any(n in u['name'] for n in ('FIXTURES_', 'MAP_BIT_', '[Map.bit.', '[Map.ins.', '[Map.del.', '[Map.pop.', '[$direct.Map.'))], 'all_unit_counts':dict(collections.Counter(u['kind'] for u in units)), 'scheduler_worker_boundary_jumps':sum(sum(v for target,v in u['jump_targets'].items() if target in adapters) for u in units if u['kind']=='segments')}

def local_fixture_reachability(family, filename):
 path=ROOT/'selfhost/tools/performance/phase37/fixtures-historical'/filename
 text=path.read_text();starts=list(re.finditer(r'^def ([\w.]+)\(',text,re.M))
 defs={m[1]:text[m.start():(starts[i+1].start() if i+1<len(starts) else len(text))] for i,m in enumerate(starts)}
 clean=lambda s: re.sub(r'"(?:\\.|[^"\\])*"|#[^\n]*','',s)
 edges={k:[n for n in defs if re.search(r'(?<![\w.])'+re.escape(n)+r'(?![\w.])',clean(v))] for k,v in defs.items()}
 live=set();todo=['bench']
 while todo:
  key=todo.pop()
  if key not in live: live.add(key);todo+=edges[key]
 bangs={k:re.findall(r'([\w.]+)!',clean(v)) for k,v in defs.items() if re.search(r'[\w.]!',clean(v))}
 wrapper=ROOT/'selfhost/tools/performance/phase46'/f'{family}-batch.bend'
 return {'family':family,'fixture':pin(path),'wrapper':pin(wrapper),'scope':'Lexical local-definition reference closure from bench, excluding comments and strings; includes all branches, not a complete typed call graph. Independently source reviewed. Wrappers use W.bench and have no bang references.','entry':'bench','reachable_local_definitions':sorted(live),'definitions_with_bang_references':bangs,'reachable_definitions_with_bangs':{k:v for k,v in bangs.items() if k in live},'wrapper_bang_references':re.findall(r'([\w.]+)!',clean(wrapper.read_text()))}

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=pathlib.Path,required=True);a=parser.parse_args()
 evidence=ROOT/'implementation/phase68/evidence/native-facts23.json';d=json.loads(evidence.read_text());seen=set();rows=[]
 for r in d['runtime']['records']:
  k=(r['case'],r['role'])
  if r['role']=='baseline20' or k in seen:continue
  seen.add(k);p=pathlib.Path(r['child']['command'][0]).with_suffix('.c');rows.append({'family':k[0],'role':k[1],**analyze(p)})
 out={'schema':'phase68-c23-code-shapes-v3','producer':pin(pathlib.Path(__file__)),'qualified_evidence':pin(evidence),'scope':'Lexical counts in Spins and Segments regions. Runtime support is excluded. DEVICE-only host views retain other preprocessor alternatives. Counts are not reachability, optimized instruction counts, or dynamic costs. Unit detail retains all workers plus named benchmark/Map segments; anonymous continuation detail is omitted. Boundary jumps target any segment containing a host worker call, so this is an upper bound on removable adapters (especially upstream segments that also do other work). Worker declaration itself counts as one worker call in aggregate metrics; unit worker_targets excludes it.','inputs':rows,'bang_reachability_review':[local_fixture_reachability('tree','tree-bitonic.bend'),local_fixture_reachability('lexer','lexer.bend')]}
 a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(out,indent=2)+'\n')
 print(json.dumps({'output':str(a.output),'inputs':len(rows),'bytes':a.output.stat().st_size}))
if __name__=='__main__':main()
