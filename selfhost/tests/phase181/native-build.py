#!/usr/bin/env python3
"""Invoke a checked native Bend assembly emitter, assembler and linker only."""
import argparse,json,os,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,write_json,fresh_output,run,changed_inputs
import assets
p=argparse.ArgumentParser();p.add_argument('--image-receipt',type=Path,required=True);p.add_argument('--source',type=Path,required=True);p.add_argument('--binding',type=Path,required=True);p.add_argument('--expected',type=Path);p.add_argument('--execute',action='store_true');p.add_argument('--args-json',type=Path);p.add_argument('--seconds',type=float,default=120);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
r=json.loads(a.image_receipt.read_text());require(r['complete'] and not r.get('changedInputs'),'successful image receipt required')
require(r['kind'] in ['bend-native-build','phase181-native-assembly-build'],'recognized build receipt required')
image=r['binary'];verify(image)
binding=json.loads(a.binding.read_text());document=assets.load_assets(ROOT/'selfhost/manifests/assets-native.json',ROOT)
tools={k:assets.asset(document,k)for k in ['assembler','linker','qbe-runtime']};policy=document['toolchains']['qbe'];source=pin(a.source)
inputs=[pin(__file__),pin(a.image_receipt),image,pin(a.binding),binding['base'],binding['carrier'],source,document['_manifest'],*tools.values()]
if a.expected:inputs.append(pin(a.expected))
args=json.loads(a.args_json.read_text())if a.args_json else[]
require(isinstance(args,list)and all(isinstance(x,str)for x in args),'string argv required')
if a.args_json:inputs.append(pin(a.args_json))
for row in inputs:verify(row)
out=fresh_output(a.out,ROOT);start=time.monotonic();report=dict(kind='phase181-native-assembly-build',complete=False,inputs=inputs,source=source,image=image,binding=pin(a.binding),runtime=tools['qbe-runtime'],toolchain=policy,jobs=[],scope='Bend-native checked source to x86 assembly, external assembler/linker and optional execution. No QBE machine stage. Image acquisition/semantic qualification and promotion remain separate.')
def save():report['wallSeconds']=time.monotonic()-start;write_json(out/'report.json',report)
def stage(name,command,stdout=None):
    left=a.seconds-(time.monotonic()-start);require(left>0,'whole build deadline exceeded')
    d=run(command,cwd=ROOT,stdout=stdout or(out/(name+'.stdout')),stderr=out/(name+'.stderr'),seconds=left);d['label']=name;report['jobs'].append(d);save()
    require(d['complete'] and (name in ['assemble','link']or d['stderr']['bytes']==0),'stage failed '+name)
    return d
save()
try:
    stage('emit',[image['file'],'--threads','1','--gpu','off','--','phase181-x86',source['file'],binding['base']['file'],binding['carrier']['file'],binding['stamp']],out/'program.s')
    report['assembly']=pin(out/'program.s');require(report['assembly']['bytes']>0,'empty assembly')
    stage('assemble',[tools['assembler']['file'],*policy['assemblerFlags'],'-o',str(out/'program.o'),str(out/'program.s')])
    stage('link',[tools['linker']['file'],*policy['linkerFlags'],str(out/'program.o'),tools['qbe-runtime']['file'],*policy['libraries'],'-o',str(out/'program')])
    report['object']=pin(out/'program.o');report['binary']=pin(out/'program');report['buildSeconds']=time.monotonic()-start
    if a.execute or a.expected or a.args_json:
        stage('execute',[str(out/'program'),'--threads','1','--gpu','off',*(['--',*args]if args else[])])
        if a.expected:require((out/'execute.stdout').read_bytes()==a.expected.read_bytes(),'complete expected output differs');report['outputExact']=True
    report['complete']=True
except Exception as e:report['error']=repr(e)
finally:
    report['changedInputs']=changed_inputs(inputs)
    if report['changedInputs']:report['complete']=False
    save();print(json.dumps({k:report[k]for k in ['complete','wallSeconds','buildSeconds','error']if k in report}))
if not report['complete']:raise SystemExit(1)
