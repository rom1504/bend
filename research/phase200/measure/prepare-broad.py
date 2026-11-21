#!/usr/bin/env python3
"""Freeze complete three-role measurement after native45 actually succeeds."""
import argparse,json,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench as B
p=argparse.ArgumentParser();p.add_argument('--name',default='candidate-broad01');p.add_argument('--native-manifest',required=True,type=Path);a=p.parse_args()
acquisition=B.read(a.native_manifest.with_name('report.json'));assert acquisition['complete'] and not acquisition.get('changedInputs') and len(acquisition['rows'])==45
assert acquisition['programManifest']==B.pin(a.native_manifest)
config=B.read(ROOT/'research/phase199/broad/integrated-pins.json')
subprocess.run([sys.executable,'-B',str(HERE/'make-plan.py'),'--name',a.name,'--runtime',config['live']['file'],'--receipt',config['bundle']['file'],'--cases','all','--native-manifest',str(a.native_manifest)],check=True,capture_output=True)
path=HERE/'plans'/(a.name+'.json');argvpath=path.with_name(a.name+'-argv.json');plan=B.read(path);argv=B.read(argvpath)
plan.update(timingSeconds=165,guardSeconds=180,checkpointPolicy='Complete-case checkpoints, individual raw streams retained',acquisition=B.pin(a.native_manifest.with_name('report.json')))
plan['inputs']=B.unique_inputs([*plan['inputs'],B.pin(__file__),B.pin(HERE/'broad.py'),plan['acquisition']]);argv[argv.index(str(HERE/'screen.py'))]=str(HERE/'broad.py');argv[argv.index(a.name)+1]='180'
B.save(path,plan);B.save(argvpath,argv);print(json.dumps(dict(plan=str(path),argv=str(argvpath),physicalJobsRun=False,guardSeconds=180,diskMiB=plan['diskMiB'])))
