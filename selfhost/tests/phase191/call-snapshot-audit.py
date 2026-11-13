import json,re,hashlib,pathlib,collections
root=pathlib.Path('/home/ai/bend2/build/publish/bend')
results=[]
for folder in ['both-dev-emission02','extra-dev-emission01']:
 report=json.load(open(root/'selfhost/build/phase191'/folder/'report.json'))
 for case in ['coverage-map-churn-32','local-pair','editdist','coverage-expression-32','tree-bitonic','variation-ray-active-64-2440']:
  row=next(r for r in report['rows'] if r['id']==case);pin=row['assembly'];p=pathlib.Path(pin['file']);data=p.read_bytes();assert hashlib.sha256(data).hexdigest()==pin['sha256']
  assert hashlib.sha256(pathlib.Path(row['source']['file']).read_bytes()).hexdigest()==row['source']['sha256']
  lines=data.decode().splitlines();symbol='';hits=[]
  for idx,line in enumerate(lines):
   if line.startswith('.type '):symbol=line.split()[1].rstrip(',')
   m=re.fullmatch(r'  movq (\d+)\(%rsp\), %rdi',line)
   if not m:continue
   base=int(m[1]);n=base//8
   if base%8 or not 1<=n<=512:continue
   # Exact contiguous original snapshot stores, separated only by each source
   # load and optional mask; never search across a label/call/branch.
   before=[]
   for l in reversed(lines[max(0,idx-4*n):idx]):
    if not l.startswith('  ') or re.match(r'  (call|j)',l):break
    z=re.fullmatch(r'  movq %r10, (\d+)\(%rsp\)',l)
    if z:before.append(int(z[1]))
    if len(before)==n:break
   if list(reversed(before))!=[base+8*i for i in range(n)]:continue
   hits.append({'line':idx+1,'function':symbol,'arguments':n,'snapshotRspRefs':2*n})
  hot=[h for h in hits if any(x in h['function'] for x in ['112_51_55_46_109_97_112_','77_97_112_'])]
  result={'variant':folder,'case':case,'source':row['source'],'assembly':pin,'sites':len(hits),'snapshotRspRefs':sum(h['snapshotRspRefs'] for h in hits),'mapNamedSites':len(hot),'examples':hot[:8] or hits[:4]}
  results.append(result)
  print(folder,case,'sites',result['sites'],'snapshot RSP refs',result['snapshotRspRefs'],'mapnamed',len(hot),'examples',result['examples'][:2])
pathlib.Path('/tmp/p191-call-snapshot-audit.json').write_text(json.dumps(results,indent=2)+'\n')
