from pathlib import Path
import json,gzip,hashlib,datetime
root=Path('/home/ai/bend2/build/publish/bend'); out=root/'implementation/phase4/private-final-images'; (out/'objects').mkdir()
sha=lambda x:hashlib.sha256(x).hexdigest()
sourcecap=root/'implementation/phase4/final-source-capsule'; reuse=json.loads((sourcecap/'manifest.json').read_bytes()); known={x['sha256']:x for x in reuse['artifacts']}
expected={'scope-fixed':'61e7d94c19bbda2de2a55037d5e2b992868a145ab6f29d557f4bc0885e759cb1','profile-combined':'4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3'}
inputs={};objects={};images={}
def capture(p,expected=None):
 data=p.read_bytes(); digest=sha(data)
 if expected:assert digest==expected,(p,expected,digest)
 inputs[str(p)]={'sha256':digest,'canonicalPath':str(p.resolve()),'bytes':len(data)}
 return data,digest
def object_for(data,key):
 if key in objects:return key
 if key in known:
  item=known[key];p=sourcecap/item['archive'];compressed,_=capture(p,item['archiveSha256']);assert gzip.decompress(compressed)==data
  archive='../final-source-capsule/'+item['archive']
 else:
  compressed=gzip.compress(data,compresslevel=9,mtime=0);archive='objects/'+key+'.gz';(out/archive).write_bytes(compressed)
 objects[key]={'archive':archive,'archiveSha256':sha(compressed),'archiveBytes':len(compressed),'bytes':len(data)}
 return key
capture(out/'extract.py')
capture(Path(__file__))
for name,image_sha in expected.items():
 directory=root/'selfhost/build/phase4/private'/name;raw,msha=capture(directory/'manifest.json');manifest=json.loads(raw)
 assert manifest['complete'] and manifest['proofStatus']=='fixedpoint'
 files={'manifest.json':object_for(raw,msha)}
 for item in manifest['artifacts']:
  relative=item['relative']; p=directory/relative;assert p.resolve().is_relative_to(directory.resolve()) and '..' not in Path(relative).parts and not Path(relative).is_absolute()
  data,key=capture(p,item['sha256']);assert len(data)==item['bytes'];assert relative not in files
  files[relative]=object_for(data,key)
 assert files['image.mjs']==image_sha
 images[name]={'originalDirectory':str(directory),'manifestSha256':msha,'imageSha256':image_sha,'optimizationProfile':manifest.get('optimizationProfile','default'),'canonicalBase':manifest['base'],'originalDriver':manifest['originalDriver'],'files':files}
for p,item in inputs.items():assert sha(Path(p).read_bytes())==item['sha256'] and str(Path(p).resolve())==item['canonicalPath']
manifest={'kind':'phase4-private-image-capsule','version':1,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Exact immutable consumed images; excludes mutable host caches and measurements; no new build or relocated proof.','images':images,'objects':objects,'inputsUnchanged':True,'creationInputs':inputs,'creationInputAfterSha256':{p:v['sha256'] for p,v in inputs.items()},'sizes':{'originalBytesIncludingManifests':sum(v['bytes'] for p,v in inputs.items() if '/private/' in p),'uniqueUncompressedBytes':sum(x['bytes'] for x in objects.values()),'localCompressedBytes':sum(x['archiveBytes'] for x in objects.values() if x['archive'].startswith('objects/')),'reusedCompressedBytes':sum(x['archiveBytes'] for x in objects.values() if x['archive'].startswith('../'))}}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({'images':{k:len(v['files']) for k,v in images.items()},'objects':len(objects),'sizes':manifest['sizes']},indent=2))
