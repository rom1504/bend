#!/usr/bin/env python3
"""Metadata-only correction: use the authenticated caller-capable sampler."""
import argparse,copy,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler'
sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins

def read(p):return json.loads(Path(p).read_text())
def need(value,message):
 if not value:raise ValueError(message)
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--profile',type=Path,required=True);a=ap.parse_args();out=a.profile.resolve()
 need(out.is_relative_to(ROOT/'selfhost/build/phase143') and not(out/'manifest-v02.json').exists(),'Fresh v02 manifest required')
 original=read(out/'manifest.json');failed=read(out/'capture/report.json')
 need(not failed['complete'] and len(failed['rows'])==1 and failed['rows'][0]['returncode']==125,'Expected retained v01 sampler refusal')
 stderr=failed['rows'][0]['stderr'];verify(stderr)
 need('physical callers requested without a compiled unwind table' in Path(stderr['file']).read_text(),'Different initial failure')
 directory=ROOT/'selfhost/build/phase127/sampler-cfi03';receipt=read(directory/'report.json')
 need(receipt['complete'] and receipt['returncode']==0,'Completed sampler build required')
 table=original['unwindTable'];need(table in receipt['inputs'],'Sampler was not built for this table')
 snapshots={Path(p['file']).name:p for p in receipt['snapshots']}
 for item in receipt['snapshots']:verify(item)
 by_name={Path(p['file']).name:p for p in receipt['inputs']}
 for snapshot,original_name in [('sample.c','sample.c'),('method.py','build-sampler.py'),('unwind-table.h','unwind-table.h')]:
  need(all(snapshots[snapshot][k]==by_name[original_name][k] for k in ('bytes','sha256')),'Frozen sampler producer input mismatch')
 verify(by_name['unwind-table.h']);verify(table);verify(receipt['sampler']);verify(by_name['x86_64-linux-gnu-gcc-10'])
 macro='-DBEND_PROFILE_UNWIND_TABLE="'+str(directory/'unwind-table.h')+'"'
 need(macro in receipt['command'] and str(directory/'sample.c') in receipt['command'] and receipt['command'][receipt['command'].index('-o')+1]==receipt['sampler']['file'],'Unwind-capable compile command missing')
 for field in ('stdout','stderr'):verify(receipt[field])
 manifest=copy.deepcopy(original);manifest['sampler']=receipt['sampler']
 manifest['samplerCorrection']=dict(previousManifest=pin(out/'manifest.json'),failure=pin(out/'capture/report.json'),failureStderr=stderr,build=pin(directory/'report.json'),reason='Phase140 sampler lacked compiled unwind support; use exact authenticated Phase127 CFI sampler/header/table. Existing diagnostic image and request unchanged.')
 added=[pin(__file__),pin(out/'manifest.json'),pin(out/'capture/report.json'),stderr,pin(directory/'report.json'),receipt['sampler'],*receipt['snapshots'],table,by_name['unwind-table.h'],by_name['x86_64-linux-gnu-gcc-10'],receipt['stdout'],receipt['stderr']]
 manifest['inputs']=list({(p['file'],p['sha256']):p for p in [*manifest['inputs'],*added]}.values())
 for item in all_pins(manifest):verify(item)
 save(out/'manifest-v02.json',manifest)
 jobs=copy.deepcopy(read(out/'jobs.json'));jobs['inputs']=[*jobs['inputs'],pin(__file__),pin(out/'manifest-v02.json')]
 jobs['jobs']=jobs['jobs'][2:]
 for job in jobs['jobs']:
  job['command']=[s.replace(str(out/'manifest.json'),str(out/'manifest-v02.json')).replace(str(out/'capture-guard'),str(out/'capture02-guard')).replace(str(out/'capture'),str(out/'capture02')).replace(str(out/'attribution'),str(out/'attribution02')).replace(str(out/'timeline'),str(out/'timeline02')) for s in job['command']]
 # Match the root's stricter actual resource lane rather than silently widening it.
 cmd=jobs['jobs'][0]['command'];cmd[cmd.index('--rss-mib')+1]='3072'
 jobs.update(targetsRun=False,scope='Retry with existing diagnostic image and authenticated caller sampler; no relink, compiler or sampler build.')
 save(out/'jobs-v02.json',jobs)
 print(json.dumps(dict(complete=True,targetsRun=False,manifest=pin(out/'manifest-v02.json'),jobs=pin(out/'jobs-v02.json'))))
if __name__=='__main__':main()
