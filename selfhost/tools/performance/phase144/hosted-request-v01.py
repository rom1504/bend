#!/usr/bin/env python3
"""Run a checked Bend API under Bun, streaming exact QBE; no compiler logic."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import threading
import time

ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('native_request',ROOT/'selfhost/tools/performance/phase130/native-request.py')
N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
pin,verify,require=N.pin,N.verify,N.require


def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for name in ['api-report','compiler-source','source','carrier-receipt','expected-qbe','out']:
  ap.add_argument('--'+name,type=Path,required=True)
 ap.add_argument('--bun',type=Path,default=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun')
 ap.add_argument('--seconds',type=int,default=900)
 a=ap.parse_args();out=a.out.resolve()
 require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144'),'Fresh Phase144 output required')
 require(0<a.seconds<=3600,'Bounded process deadline required')
 require(not any(k in os.environ for k in ('LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS')),'Ambient profiling forbidden')
 begun=time.monotonic();api=json.loads(a.api_report.read_text())
 require(api.get('complete') and api.get('checked') and api.get('status')==0,'Checked API required')
 compiler,source=pin(a.compiler_source),pin(a.source)
 require(compiler in api['inputs'],'API does not use exact compiler source')
 required=['p88_cache_prepare','p86_plan','p134e_plan','p134e_begin','p134e_next']
 require(all(name in api['exports'] for name in required),'API lacks ordinary cursor exports')
 carrier,base,carrier_pins=N.carrier_inputs(a.carrier_receipt)
 expected=pin(a.expected_qbe)
 require(source['bytes']<=16777216 and base['bytes']<=16777216,'Bounded source/Base required')
 inputs=[pin(__file__),pin(ROOT/'selfhost/tools/performance/phase143/hosted-stream.mjs'),pin(N.__file__),pin(a.bun),pin(a.api_report),api['api'],*api['inputs'],compiler,source,expected,*carrier_pins]
 for item in inputs:verify(item)
 out.mkdir(parents=True)
 config=dict(api=api['api'],compilerSource=compiler,source=source,base=base,carrier=carrier['carrier'],stamp=carrier['stamp'],expected=expected,output=str(out/'program.ssa'),stages=str(out/'stages.json'))
 (out/'input.json').write_text(json.dumps(config,indent=2)+'\n');inputs.append(pin(out/'input.json'))
 command=[str(a.bun.resolve()),str(ROOT/'selfhost/tools/performance/phase143/hosted-stream.mjs'),str(out/'input.json')]
 report=dict(kind='phase144-hosted-source-qbe-request',complete=False,inputs=inputs,compilerSource=compiler,source=source,base=base,carrier=carrier['carrier'],stamp=carrier['stamp'],expectedQbe=expected,command=command,limitSeconds=a.seconds,inheritedAffinity=sorted(os.sched_getaffinity(0)),preflightSeconds=time.monotonic()-begun,
  timingScope='Whole child includes Bun startup, API import, source/Base/carrier IO, compiler stages, streaming output, observer digest and bookkeeping. Stage report separates those costs. Input authentication and final oracle comparison are outside child time.',
  limits='Outer existing guard must impose RSS/process-tree resource limits. This supervisor enforces a process-group deadline and reaps the child; no bound on the complete IR is claimed.',
  scope='Ordinary cold compiler request, not incremental session, API acquisition, compiler machine build, semantic qualification or promotion.')
 def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 save();finished=threading.Event();expired=threading.Event();child=None;watchdog=None
 try:
  with (out/'stdout.log').open('xb') as so,(out/'stderr.log').open('xb') as se:
   start=time.monotonic();child=subprocess.Popen(command,cwd=ROOT,stdout=so,stderr=se,start_new_session=True)
   def deadline():
    if not finished.is_set():
     expired.set()
     try:os.killpg(child.pid,signal.SIGKILL)
     except ProcessLookupError:pass
   watchdog=threading.Timer(a.seconds,deadline);watchdog.daemon=True;watchdog.start()
   try:
    _,status,usage=os.wait4(child.pid,0);child.returncode=os.waitstatus_to_exitcode(status)
    report.update(childSeconds=time.monotonic()-start,exitCode=child.returncode,userSeconds=usage.ru_utime,systemSeconds=usage.ru_stime,peakRssBytes=usage.ru_maxrss*1024)
   finally:finished.set();watchdog.cancel()
  report.update(stdout=pin(out/'stdout.log'),stderr=pin(out/'stderr.log'),timedOut=expired.is_set())
  require(not expired.is_set() and child.returncode==0,'Hosted child failed or timed out')
  require(report['stderr']['bytes']==0,'Unexpected hosted stderr')
  stages=json.loads((out/'stages.json').read_text());require(stages.get('complete') and stages.get('exactExpectedBytes'),'Incomplete stage/oracle evidence')
  report['stages']=pin(out/'stages.json');report['product']=pin(out/'program.ssa')
  before=time.monotonic();require(N.same_bytes(out/'program.ssa',a.expected_qbe),'Full output bytes differ from independent expected product')
  report['independentByteComparisonSeconds']=time.monotonic()-before
  require((report['product']['bytes'],report['product']['sha256'])==(expected['bytes'],expected['sha256'])==(stages['bytes'],stages['sha256']),'Product identities differ')
  for item in inputs:verify(item)
  report['complete']=True
 except BaseException as error:report['error']=repr(error)
 finally:
  finished.set()
  if watchdog:watchdog.cancel()
  if child is not None and child.returncode is None:
   try:os.killpg(child.pid,signal.SIGKILL)
   except ProcessLookupError:pass
   child.wait()
  report['totalSeconds']=time.monotonic()-begun;save()
 print(json.dumps({key:report.get(key) for key in ('complete','childSeconds','peakRssBytes','error')}))
 return 0 if report['complete'] else 1


if __name__=='__main__':sys.exit(main())
