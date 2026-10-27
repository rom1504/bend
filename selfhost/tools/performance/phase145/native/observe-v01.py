#!/usr/bin/env python3
"""Root-only, bounded counters-off/on real native requests; no performance claim."""
import argparse,collections,gzip,importlib.util,json,os,re,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler'
sys.path.insert(0,str(PROF))
from run import pin,verify,save,execute
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True);p.add_argument('--build',type=Path,required=True);p.add_argument('--control',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
assert os.sched_getaffinity(0)=={3} and not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145')
assert not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS'])
m=json.loads(a.plan.read_text());b=json.loads(a.build.read_text());c=json.loads(a.control.read_text())
assert m['complete'] and m['reverseExact'] and not m['addedCounters'];assert b['complete'] and b['plan']==pin(a.plan);assert c['complete']
assert pin(a.plan) in c['inputs'] and pin(a.build) in c['inputs']
binary=pin(a.plan.resolve().parent/'program');assert binary in b['products'];verify(m['ownerMap'])
with gzip.open(m['ownerMap']['file'],'rt') as f:owners=json.load(f)
assert owners['compilerSource']==m['compilerSource'];fids={x['fid']:x for x in owners['fids']};segments=owners['descriptor']['segment_count']
inputs=[pin(__file__),pin(PROF/'run.py'),pin(a.plan),pin(a.build),pin(a.control),binary,*m['inputs'],*m['outputs']]
for x in inputs:verify(x)
# Independent ELF-symbol join authenticates each reported FID address.
nm=Path('/usr/bin/nm').resolve();inputs.append(pin(nm));symbols={}
pn=subprocess.run([str(nm),'-n','--defined-only',binary['file']],capture_output=True,timeout=10);assert pn.returncode==0 and not pn.stderr
for line in pn.stdout.decode().splitlines():
 parts=line.split()
 if len(parts)==3 and parts[2].startswith('p111_FID_'):symbols[parts[2]]=int(parts[0],16)
assert all(x['symbol'] in symbols for x in fids.values())
source=Path(m['compilerSource']['file']).read_text();source_lines={}
for i,line in enumerate(source.splitlines(),1):
 match=re.match(r'(?:unsafe )?def ([^(:\s]+)',line)
 if match:source_lines.setdefault(match[1],i)
out.mkdir();r=dict(kind='phase145-native-operation-observations-v1',complete=False,inputs=inputs,cases=[],compilerSource=m['compilerSource'],programObject=m['programObject'],linkedCleanRuntime=m['linkedRuntime'],diagnosticBinary=binary,scope=m['scope'],counterContract='Unchanged generic16 counters; source-owned contexts are not exact phase or query counts.',wallTimingIsDiagnostic=True)
save(out/'report.json',r);start=time.monotonic()
try:
 for case in m['cases']:
  row=dict(name=case['name'],source=case['source'],expected=case['expected'],runs=[]);r['cases'].append(row)
  for enabled in [False,True]:
   label=case['name']+('-on' if enabled else '-off');d=out/label;events=d/'events.json'
   env=dict(os.environ,BEND_PROFILE_EVENTS_OUT=str(events),BEND_PROFILE_COUNTERS='1' if enabled else '0')
   command=[binary['file'],'--threads','1','--gpu','off','--','phase111',case['source']['file'],m['base']['file'],'cache',m['carrier']['file'],m['stamp']]
   q=execute(command,d,str(ROOT),90,env);q['countsEnabled']=enabled;row['runs'].append(q);save(out/'report.json',r)
   assert q['returncode']==0 and not q['timedOut'] and q['stderr']['bytes']==0
   assert all(q['stdout'][k]==case['expected'][k] for k in ['sha256','bytes']);q['exactQbe']=True
   assert events.stat().st_size<32*1024*1024;q['events']=pin(events);e=json.loads(events.read_text())
   assert e['complete'] and not e['counter_overflow'] and not e['invalid_context_events'] and e['counts_enabled'] is enabled and e['segment_count']==segments
   assert len(e['counter_names'])==16 and len(set(e['counter_names']))==16
   if not enabled:assert not e['rows'];save(out/'report.json',r);continue
   total=collections.Counter();groups={};seen=set();unknown=collections.Counter();runtime=collections.Counter()
   for event in e['rows']:
    fid=event['fid'];assert fid not in seen;seen.add(fid);counts=event['counts'];assert len(counts)==16 and all(type(n)is int and 0<=n<2**64 for n in counts)
    values=dict(zip(e['counter_names'],counts));total.update(values)
    if fid in fids:
     owner=fids[fid];assert int(event['segment_address'],16)==symbols[owner['symbol']]
     name=owner['lowered_owner'];key=name if name is not None else '<unknown-lowered-owner>'
     if key not in groups:groups[key]=dict(owner=name,sourceLine=source_lines.get(name),counts=collections.Counter(),fids=0)
     groups[key]['counts'].update(values);groups[key]['fids']+=1
    elif fid==4294967295:assert int(event['segment_address'],16)==0;unknown.update(values)
    else:assert segments<=fid<segments+4 and int(event['segment_address'],16)==0;runtime.update(values)
   q['totals']=dict(total);q['outsideDispatch']=dict(unknown);q['runtimeDispatch']=dict(runtime)
   all_groups=list(groups.values());gp=out/(case['name']+'-owners.json');save(gp,dict(kind='phase145-native-active-owner-events',complete=True,events=q['events'],ownerMap=m['ownerMap'],compilerSource=m['compilerSource'],rows=all_groups));q['ownerSummary']=pin(gp)
   q['topOwners']={name:sorted([dict(owner=g['owner'],sourceLine=g['sourceLine'],count=g['counts'][name]) for g in all_groups if g['counts'][name]],key=lambda x:-x['count'])[:20] for name in e['counter_names']}
   save(out/'report.json',r)
 for x in inputs:verify(x)
 r['complete']=True
except BaseException as error:r['error']=repr(error);raise
finally:r['seconds']=time.monotonic()-start;save(out/'report.json',r)
print(json.dumps(dict(complete=True,report=pin(out/'report.json'),cases=[dict(name=x['name'],totals=x['runs'][1]['totals']) for x in r['cases']])))
