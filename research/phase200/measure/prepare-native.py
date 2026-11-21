#!/usr/bin/env python3
"""Freeze ordinary all45 acquisition for an independently checked native N1."""
import argparse,hashlib,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench as B
p=argparse.ArgumentParser();p.add_argument('--name',default='candidate-native45-01');p.add_argument('--source',required=True,type=Path);p.add_argument('--source-check',required=True,type=Path);p.add_argument('--image',required=True,type=Path);p.add_argument('--image-receipt',required=True,type=Path);a=p.parse_args();assert re.fullmatch('[a-z0-9][a-z0-9-]{0,70}',a.name)
source=B.pin(a.source);checked=B.read(a.source_check);assert checked['complete'] and checked['checked'] and checked['source']==source
receipt=B.read(a.image_receipt);binding=receipt['imageBinding'];assert receipt['complete'] and binding['complete'] and binding['host']=='native' and binding['stage']=='N1' and 'x86' in binding['targets'] and binding['sourceIdentity']==source
image=B.pin(a.image);assert all(image[k]==binding['image'][k] for k in ('bytes','sha256'))
assets=ROOT/'research/phase199/broad/integrated-assets.json';old=B.read(ROOT/'research/phase199/broad/integrated-pins.json');assert B.pin(assets)==old['assets'];B.verify(old['original']);B.verify(old['live'])
folder=HERE/'plans';folder.mkdir(exist_ok=True);plan=folder/(a.name+'.json');argvpath=folder/(a.name+'-argv.json');assert not plan.exists() and not argvpath.exists()
argv=[sys.executable,'-B',str(HERE/'job.py'),a.name,'150','32',sys.executable,'-B','selfhost/tests/phase190/native-programs.py','--assets',str(assets),'--image',str(a.image.resolve()),'--image-receipt',str(a.image_receipt.resolve()),'--host','native','--stage','N1','--target','x86','--emit','object','--mode','cache','--role','candidate','--cases','all','--out',str(ROOT/'selfhost/build/phase200'/a.name),'--seconds','140','--guarded']
B.save(plan,dict(kind='phase200-ordinary-native45-plan',targetsRun=False,source=source,sourceCheck=B.pin(a.source_check),image=image,imageReceipt=B.pin(a.image_receipt),assets=B.pin(assets),runtime=old['original'],method=B.pin(__file__),driver=B.pin(ROOT/'selfhost/tests/phase190/native-programs.py'),argv=argv),fresh=True);B.save(argvpath,argv,fresh=True);print(json.dumps(dict(plan=str(plan),argv=str(argvpath),source=source)))
