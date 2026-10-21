"""Profile the exact qualified native compiler request, retaining the QBE oracle."""
import importlib.util,json,os,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
s=importlib.util.spec_from_file_location('survey116',HERE/'survey-v2.py');S=importlib.util.module_from_spec(s);s.loader.exec_module(S)
receipt=ROOT/'selfhost/build/phase111/p114-native-final02-n1-focused/5-native/report.json';r=S.read(receipt);job=r['jobs'][0];assert r['complete'] and job['label']=='native-request'
for x in r['inputs']:
 if Path(x['file']).is_file():
  y=S.pin(x['file']);assert y['sha256']==x['sha256'] and y['bytes']==x['bytes']
S.verify(job['stdout']);oracle=Path(job['stdout']['file']).read_bytes();cmd=job['command'];assert 'lexer-scan.bend' in ' '.join(cmd)
out=ROOT/'selfhost/build/phase116/compiler01';assert not out.exists();out.mkdir()
report=dict(complete=False,scope='Same qualified QBE N1 compiler, ordinary lexer request, exact full-QBE oracle. Cold prepared-Base request; no compiler rebuild or cross-backend throughput claim.',inputs=[S.pin(__file__),S.pin(S.__file__),S.pin(receipt),S.pin(cmd[0]),job['stdout']],command=cmd,rows=[])
S.save(out/'report.json',report)
for i,period in enumerate([0,8000,13000,8000,13000,0]):
 env=dict(os.environ);sample=out/f'{i}.samples'
 if period:env.update(LD_PRELOAD=str(ROOT/'selfhost/build/phase108/profiler01/sampler.so'),BEND_SAMPLE_OUT=str(sample),BEND_SAMPLE_PERIOD_US=str(period))
 start=time.monotonic();p=subprocess.run(cmd,capture_output=True,env=env,cwd=ROOT,timeout=30);seconds=time.monotonic()-start
 (out/f'{i}.stdout').write_bytes(p.stdout);(out/f'{i}.stderr').write_bytes(p.stderr)
 row=dict(index=i,periodUs=period,seconds=seconds,status=p.returncode,correct=p.returncode==0 and not p.stderr and p.stdout==oracle,stdout=S.pin(out/f'{i}.stdout'),stderr=S.pin(out/f'{i}.stderr'));report['rows'].append(row);S.save(out/'report.json',report);assert row['correct']
 if period:
  a=S.analyze(sample,cmd[0]);S.save(out/f'{i}.analysis.json',a);row.update(profile=S.pin(sample),analysis=S.pin(out/f'{i}.analysis.json'),usable=a['usable'],overruns=a['header']['overruns'],samples=a['header']['samples'])
 S.save(out/'report.json',report);print(i,period,seconds,row.get('overruns'),flush=True)
report['complete']=True;S.save(out/'report.json',report)
