#!/usr/bin/env python3
"""Admit pinned optional Base-annotation products without changing measured clocks."""
import argparse, ast, hashlib, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase65'
PARENT = RAW/'latency-method01'
PARENT_SHA = '290eac14e3606206c41773ef2ab49d0a098af2587869b9a400dbd2405712a424'

def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())

p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
parent=identity(PARENT/'derivation.json');assert parent['sha256']==PARENT_SHA
manifest=json.loads((PARENT/'derivation.json').read_text())
parents={Path(row['output']['file']).name:row['output'] for row in manifest['derivations']}
texts={};rows=[]
for name in ['profile.mjs','setup.mjs','worker.mjs','run.py']:
    before=identity(PARENT/name);assert before==parents[name]
    text=(PARENT/name).read_text();edits=[]
    def edit(old,new,count=1):
        global text
        assert text.count(old)==count,(name,old,text.count(old),count)
        text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
    count=text.count(str(PARENT))
    if count:edit(str(PARENT),str(out),count)
    if name=='setup.mjs':
        edit("    for(const item of cacheFiles) {", "    const cacheBindings=[];\n    for(const item of cacheFiles) {")
        edit("      if(!framed)assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));", """      if(!framed)assert.equal(c.bookSha256,hash(Buffer.from(JSON.stringify(c.book))));
      cacheBindings.push({file:item.file,metadata:c});""")
        edit("    return {inputsUnchanged:true,copiesUnchanged:true,cacheFiles};", r"""    // Preparation is outside timing. Ordinary requests must not create or mutate products.
    const productDirectory=path.join(project,'build/typed/base-products');
    const productApis=['base_annotation_prepare','base_annotation_wanted','base_annotation_allowed','annotate_selected_base'];
    const supported=productApis.every(name=>typeof api[name]==='function');
    const declared=D.baseAnnotationDirectory!==undefined;
    if(declared)assert.equal(D.baseAnnotationDirectory,productDirectory);
    if(supported)assert.equal(declared,true,'Product API requires declared private directory');
    const productExists=fs.existsSync(productDirectory);
    if(productExists)assert.ok(fs.lstatSync(productDirectory).isDirectory()&&!fs.lstatSync(productDirectory).isSymbolicLink());
    const productNames=productExists?fs.readdirSync(productDirectory).sort():[];
    for(const name of productNames){const stat=fs.lstatSync(path.join(productDirectory,name));assert.ok(stat.isFile()&&!stat.isSymbolicLink());}
    const productFiles=productNames.map(name=>identity(path.join(productDirectory,name)));
    let productHeaderBinding=null;
    if(supported) {
      assert.equal(cacheBindings.length,1);const frame=cacheBindings[0];
      assert.ok(frame.file.endsWith('-frame4.json'));
      assert.deepEqual(productNames,[path.basename(frame.file).replace(/-frame4\.json$/,'-annotations64-v1.bin')]);
      const bytes=fs.readFileSync(productFiles[0].file);assert.ok(bytes.length>=36);
      const length=bytes.readUInt32LE(0);assert.ok(length>0&&length<=65536&&4+length+32<=bytes.length);
      const header=JSON.parse(bytes.subarray(4,4+length).toString('utf8'));
      assert.ok(header&&typeof header==='object'&&!Array.isArray(header));
      const cached=frame.metadata,frameBytes=fs.readFileSync(frame.file),newline=frameBytes.indexOf(10);
      assert.ok(newline>0&&newline<=65536);const frameHeader=JSON.parse(frameBytes.subarray(0,newline).toString('utf8'));
      assert.equal(frameHeader.format,'bend-base-cache-frame-4');assert.ok(Array.isArray(frameHeader.segments));assert.equal(frameHeader.segments.length,2);
      const [bookBytes,preparedBytes]=frameHeader.segments;assert.ok(Number.isSafeInteger(bookBytes)&&bookBytes>0&&Number.isSafeInteger(preparedBytes)&&preparedBytes>0);
      assert.equal(frameBytes.length,newline+1+bookBytes+preparedBytes);
      assert.equal(hash(frameBytes.subarray(newline+1,newline+1+bookBytes)),frameHeader.bookGraphSha256);
      assert.equal(hash(frameBytes.subarray(newline+1+bookBytes)),frameHeader.preparedGraphSha256);
      const expected={format:'bend-base-annotations-1',version:1,producer:'base_annotation_prepare',minimumWork:64,
        compilerSha256:apiFile.sha256,baseSha256:selected.attempt.base.sha256,sourcePath:fs.realpathSync(selected.attempt.base.file),
        termAbi:cached.termAbi,spanAbi:cached.spanAbi,sourceBegin:cached.sourceBegin,sourceEnd:cached.sourceEnd,
        bookGraphSha256:frameHeader.bookGraphSha256,preparedGraphSha256:frameHeader.preparedGraphSha256};
      for(const [key,value] of Object.entries(expected))assert.equal(header[key],value,'Product binding '+key);
      assert.ok(Number.isSafeInteger(header.productBytes)&&header.productBytes>=32&&header.productBytes<=128*1024*1024);
      assert.equal(bytes.length,4+length+header.productBytes);assert.equal(hash(bytes.subarray(4+length)),header.productSha256);
      assert.equal(typeof header.keys,'string');assert.ok(header.keys.length<=65536);
      const keys=Buffer.from(header.keys,'base64');assert.equal(keys.toString('base64'),header.keys);assert.equal(hash(keys),header.keysSha256);
      productHeaderBinding={...expected,productBytes:header.productBytes,productSha256:header.productSha256,keysSha256:header.keysSha256};
    } else {assert.equal(productExists,false,'Unexpected product directory for an unsupported image');assert.deepEqual(productFiles,[]);}
    return {inputsUnchanged:true,copiesUnchanged:true,cacheFiles,
      baseProducts:{directory:productDirectory,exists:productExists,declared,supported,files:productFiles,headerBinding:productHeaderBinding,
        scope:'Explicit preparation generated and decoder-validated optional products; this verifier binds exact metadata/digests and directory inventory. No-hit workers preserve the same dependency.'}};""")
    if name=='worker.mjs':
        edit("      report.project=staged.project;", "      report.project=staged.project;\n      report.basePrimeScope='Ordinary explicit D.prepareBase, including optional backend products when supported; excluded from measurement.';")
        edit("const bindings=[...(prep.copies??[]).map(x=>x.after),...(prep.verification?.cacheFiles??[]),", "const bindings=[...(prep.copies??[]).map(x=>x.after),...(prep.verification?.cacheFiles??[]),...(prep.verification?.baseProducts?.files??[]),")
        edit("    check(bindings);\n    const row=config.cases.find", r"""    check(bindings);
    function verifyProducts() {
      if(request.role==='typescript')return;
      const products=prep.verification?.baseProducts;assert.ok(products,'Preparation must bind optional product presence or absence');
      const directory=path.join(prep.project,'build/typed/base-products');assert.equal(products.directory,directory);
      assert.equal(fs.existsSync(directory),products.exists,'Optional product directory changed');
      if(products.exists)assert.ok(fs.lstatSync(directory).isDirectory()&&!fs.lstatSync(directory).isSymbolicLink());
      const names=products.exists?fs.readdirSync(directory).sort():[];
      for(const name of names){const stat=fs.lstatSync(path.join(directory,name));assert.ok(stat.isFile()&&!stat.isSymbolicLink());}
      assert.deepEqual(names,products.files.map(x=>path.basename(x.file)).sort(),'Optional product inventory changed');
      for(const file of products.files){assert.equal(path.dirname(file.file),directory);verify(file);}
    }
    verifyProducts();report.baseProducts=prep.verification?.baseProducts??null;
    const row=config.cases.find""")
        edit("    check(bindings);check(caseInputs);check(oldConfig.inputs);", "    verifyProducts();check(bindings);check(caseInputs);check(oldConfig.inputs);")
    if name.endswith('.py'):ast.parse(text)
    texts[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
out.mkdir(parents=True)
for name,text in texts.items():(out/name).write_text(text)
result=dict(kind='phase61-candidate-fast-loop-method',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),parentDerivation=parent,derivations=rows,
    explicitCacheAdmission=manifest['explicitCacheAdmission'],immutableAuditSnapshot=manifest['immutableAuditSnapshot'],
    optionalProductAdmission=dict(format='bend-base-annotations-1',version=1,minimumWork=64,directory='build/typed/base-products',
        preparation='Existing explicit D.prepareBase default backendProducts=true; ordinary inspect only reads',
        integrity='Exact image/Base/source/span/frame binding and key/body digests; every-worker exact file hashes and presence/inventory before/after, including no-hit and absent baseline'),
    scope='Fresh method relocation and optional annotation-product dependency admission only. Mandatory frame cache still exactly one; old compiler images and all clocks, lineage, raw oracles, profile sampling and guards unchanged. Additional file hashing remains excluded preflight, so this is not an OS-cold I/O measurement.')
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(method=identity(out/'derivation.json'))))
