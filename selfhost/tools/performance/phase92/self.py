#!/usr/bin/env python3
"""One bounded native self-emission, with complete C comparison and guarded clocks."""
import argparse,importlib.util,json,pathlib,re,shutil,sys,time
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE/'comparison'))
from support import ROOT,authenticate,native_args,unchanged,pin,read
spec=importlib.util.spec_from_file_location('program_support',ROOT/'selfhost/tools/performance/programs/support.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--role',required=True,choices=['b1','b2']);p.add_argument('--out',required=True,type=pathlib.Path);p.add_argument('--seconds',type=int,default=300);a=p.parse_args()
ctx=authenticate(ROOT/'selfhost/build/phase92/upstream-b1/build.json')
out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
assert shutil.disk_usage(ROOT).free>210*1024**2,'Reserve room for38MiB C plus160MiB floor'
source=ctx['roles']['b2']['admission']['source'];assert (source['sha256'],source['bytes'])==(ctx['source']['sha256'],ctx['source']['bytes']);oracle=ctx['roles']['b2']['admission']['c'];prefix=out/'self'
cmd=['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase92','taskset','-c','3',*native_args(ctx,a.role,source['file'],prefix)]
report=dict(kind='phase92-native-self-emission',complete=False,passed=False,role=a.role,context=ctx,source=source,oracle=oracle,method=pin(__file__),command=cmd,deadlineSeconds=a.seconds)
S.save(out/'report.json',report)
with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
 job=guard.run(cmd,out/'guard',time.monotonic()+a.seconds)
report['process']=job;report['processReceipt']=pin(out/'guard/process.json')
output=pathlib.Path(str(prefix)+'.1.c')
if output.exists():
 report['output']=pin(output)
 report['exactC']=output.read_bytes()==pathlib.Path(oracle['file']).read_bytes()
logs=(out/'guard/stdout.log').read_text()+(out/'guard/stderr.log').read_text()
for field,pattern in [('requestMs',r'request=\d+ request_ms=(\d+)'),('basePreparationMs',r'base_prepare_ms=(\d+)'),('runtimePreparationMs',r'runtime_prepare_ms=(\d+)')]:
 report[field]=list(map(int,re.findall(pattern,logs)))
unchanged(ctx);report['inputsUnchanged']=True
report['complete']=bool(job['complete'] and job['returncode']==0 and not job.get('stoppedFor'))
report['passed']=bool(report['complete'] and report.get('exactC') and len(report['requestMs'])==1)
report['scope']='Full frozen D04 source, same request assets, native host. Exact C is code-generation fixed-point evidence, not ELF identity or unrestricted semantic proof.'
S.save(out/'report.json',report)
print(json.dumps({k:report.get(k) for k in ['complete','passed','role','exactC','requestMs','basePreparationMs','output']}))
sys.exit(0 if report['passed'] else 1)
