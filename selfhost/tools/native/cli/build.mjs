// Build-time orchestration only. Ordinary requests run the native Bend binary.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'../../../..');
const [action,dirArg,kind='bridge']=process.argv.slice(2);
const out=path.resolve(dirArg??root+'/selfhost/build/phase103/cli01');
assert(out.startsWith(root+'/selfhost/build/phase103/'));
const read=p=>fs.readFileSync(p,'utf8');
const json=p=>JSON.parse(read(p));
const pin=p=>{p=fs.realpathSync(p);const b=fs.readFileSync(p);return {file:p,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const verify=p=>{assert.deepEqual(pin(p.file),p);return p.file;};
const save=(p,x)=>fs.writeFileSync(p,JSON.stringify(x,null,2)+'\n');
const once=(s,a,b)=>{assert.equal(s.split(a).length,2,a.slice(0,120));return s.replace(a,b);};
const clang='/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang';
const include=path.resolve(clang,'../../include/clang');
const guard=root+'/selfhost/tools/performance/phase86/guard.py';
const methods=[import.meta.filename,import.meta.dirname+'/acquire.mjs',import.meta.dirname+'/start.c',root+'/selfhost/src/host/native-cli.bend',root+'/selfhost/src/host/native-os.c'];
function run(name,argv,seconds=420,large=false){
  const log=out+'/'+name;assert(!fs.existsSync(log));
  console.log('start '+name);
  const r=spawnSync('python3',['-B',guard,'--out',log,'--seconds',String(seconds),'--rss-mib',large?'6144':'2048','--available-mib',large?'16384':'4096','--cpu',large?'2,3':'3','--',...argv],{cwd:root,encoding:'utf8',maxBuffer:1024**2});
  fs.writeFileSync(log+'.stdout',r.stdout??'');fs.writeFileSync(log+'.stderr',r.stderr??'');
  const p=json(log+'/process.json');assert.equal(r.status,0,JSON.stringify(p));assert.equal(p.returncode,0,read(log+'/stderr.log').slice(-4000));assert(p.complete&&!p.stoppedFor&&!p.interrupted);
  console.log('done '+name+' '+JSON.stringify({seconds:p.elapsedSeconds??p.elapsed_s}));
  return pin(log+'/process.json');
}
if(action==='prepare'){
  assert(!fs.existsSync(out));fs.mkdirSync(out,{recursive:true});
  const selection=json(root+'/selfhost/tools/native/selection.json');
  const admission=json(verify(selection.admission));assert(admission.complete&&admission.qualified);
  assert.equal(admission.source.sha256,'63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237');
  const source=read(verify(admission.source)),assets=admission.assets;
  const assetMap={'base.bend':assets.base,'base.p88':assets.cache.carrier};
  assets.parts.forEach((p,i)=>assetMap['runtime.c.part'+i]=p);
  assets.effects.forEach(p=>assetMap['effs/'+path.basename(p.file)]=p);
  for(const [name,p] of Object.entries(assetMap)){verify(p);const dest=out+'/assets/'+name;fs.mkdirSync(path.dirname(dest),{recursive:true});fs.copyFileSync(p.file,dest);}
  const host=root+'/selfhost/src/host/native-os.c';
  fs.copyFileSync(host,out+'/assets/effs/native-os.c'); // build-only; excluded from package
  fs.copyFileSync(host,out+'/native-os.c');
  let config='\n# Generated immutable asset identities, not an editable trust manifest.\n';
  config+='def cli_base_identity() -> String:\n  '+JSON.stringify(assets.cacheBasePath)+'\n';
  config+='def cli_cache_stamp() -> String:\n  '+JSON.stringify(assets.cache.stamp)+'\n';
  config+='@unsafe\ndef cli_digest(+name: String) -> String:\n  ';
  config+=Object.entries(assetMap).map(([name,p])=>'kc(String, String.eq(name, '+JSON.stringify(name)+'), u => "'+p.sha256+'", u => ').join('\n  ');
  config+='""'+')'.repeat(Object.keys(assetMap).length)+'\n';
  let entry=read(root+'/selfhost/src/host/native-cli.bend');
  const oldMain='@unsafe\ndef main() -> IO(U32):\n  do IO<U32>:\n    args : List<&1,String> <- IO.args()\n    p86_cli(args)';
  let final=once(source,oldMain,'# The public main is assembled from src/host/native-cli.bend.');
  final=once(final,'source : String <- p86_read_file(directory ++ "/" ++ file)','source : String <- cli_read(directory ++ "/" ++ file, cli_digest("effs/" ++ file))');
  final+='\n'+entry+config;
  fs.writeFileSync(out+'/compiler.bend',final);
  // This bridge is never installed. Its extra authority is bound to exact build
  // source/provider bytes, never granted to the shipped compiler's user input.
  let bridge=once(source,'def p86_effect_file(', 'def p103_previous_effect_file(');
  bridge=once(bridge,'v => no_effect_foreign_allowed(db(d), String.eq(tg(nc_unann(dv(d))), "Foreign"), dn(d)),','v => p103_host_foreign(d) || no_effect_foreign_allowed(db(d), String.eq(tg(nc_unann(dv(d))), "Foreign"), dn(d)),');
  bridge=once(bridge,'(Bool.not(db(d)) && (p98_tag_eq(nc_unann(dv(d)), "Foreign")','(Bool.not(db(d) || p103_host_foreign(d)) && (p98_tag_eq(nc_unann(dv(d)), "Foreign")');
  const hostPaths=[out+'/native-os.c',out+'/./native-os.c'];
  bridge+='\n@unsafe\ndef p86_effect_file(+base: String, +path: String) -> String:\n  kc(String, '+hostPaths.map(p=>'String.eq(path, '+JSON.stringify(p)+')').join(' || ')+', u => "native-os.c", u => p103_previous_effect_file(base, path))\n';
  bridge+='\n@unsafe\ndef p103_host_foreign(+d: KDef) -> Bool:\n  p98_tag_eq(nc_unann(dv(d)), "Foreign") && no_effect_provider_member(["NativeHost.read", "NativeHost.path", "NativeHost.publish"], dn(d)) && ('+hostPaths.map(p=>'kf_has_path(ks(nc_unann(dv(d))), '+JSON.stringify(p)+')').join(' || ')+')\n';
  fs.writeFileSync(out+'/bridge.bend',bridge);
  const harness=entry.slice(0,entry.indexOf('@unsafe\ndef cli_runtime'))+
    '@unsafe\ndef cli_request(input: String, output: String, live: Bool) -> IO(U32):\n  do IO<U32>:\n    rp : Result<&1,&1,U32 & String,String> <- NativeHost.path("")\n    root : String <- cli_pass(String, rp)\n    base : String <- cli_asset(root, "base.bend")\n    ip : Result<&1,&1,U32 & String,String> <- NativeHost.path(input)\n    path : String <- cli_pass(String, ip)\n    text : String <- cli_read(path, "")\n    result : Result<&1,&1,U32 & String,Unit> <- NativeHost.publish(output, text)\n    Unit <- cli_pass(Unit, result)\n    IO.pure(U32, 0)\n\n'+entry.slice(entry.indexOf('def cli_dispatch'))+config;
  const choose=source.slice(source.indexOf('@unsafe\ndef kc('),source.indexOf('# Module identity uses ns:name;'));
  fs.writeFileSync(out+'/harness.bend','import Base\n'+choose+harness);
  save(out+'/inputs.json',{version:1,baseline:selection.admission,source:admission.source,assets:assetMap,cache:assets.cache,baseIdentity:assets.cacheBasePath,methods:methods.map(pin),compiler:pin(out+'/compiler.bend'),bridge:pin(out+'/bridge.bend'),harness:pin(out+'/harness.bend'),host:pin(host),sourceEdits:['replace private main with Bend public entry','authenticate effect bytes at host read'],bridgeOnlyPolicy:['exact host provider path','three filled foreign observer permissions','three foreign packing exceptions']});
  console.log(out);process.exit(0);
}
const inputs=json(out+'/inputs.json');
function unchanged(){
  for(const p of [...inputs.methods,inputs.compiler,inputs.bridge,inputs.harness,inputs.host,inputs.source,...Object.values(inputs.assets)])verify(p);
  for(const [name,p] of [...Object.entries(inputs.assets),['effs/native-os.c',inputs.host]]){
    const copy=pin(out+'/assets/'+name);assert.equal(copy.sha256,p.sha256);assert.equal(copy.bytes,p.bytes);
  }
  assert.equal(pin(out+'/native-os.c').sha256,inputs.host.sha256);
}
unchanged();
if(action==='bootstrap'){
  assert(['bridge','harness'].includes(kind));
  const bun=root+'/selfhost/.bootstrap/bun-1.4.3/bun';
  run(kind+'-acquire',[bun,import.meta.dirname+'/acquire.mjs',out+'/'+kind+'.bend',out+'/'+kind+'-c'],180,true);
  const base=['-O2','-isystem',include];
  const src=kind==='harness'?['-DBEND_NATIVE_HOST=0','-DBEND_IMAGE_C='+JSON.stringify(out+'/harness-c/program.c'),import.meta.dirname+'/start.c']:[out+'/bridge-c/program.c'];
  const build=run(kind+'-link',[clang,...base,...src,'-lm','-pthread','-o',out+'/'+kind],420,true);
  save(out+'/'+kind+'.json',{complete:true,source:inputs[kind],acquisition:pin(out+'/'+kind+'-c/report.json'),build,binary:pin(out+'/'+kind),toolchain:pin(clang),stage:'upstream-built B1'});
}else if(action==='emit'){
  const bridge=json(out+'/bridge.json');verify(bridge.binary);verify(bridge.source);
  const args=[bridge.binary.file,'--threads','1','--gpu','off','--',inputs.compiler.file,inputs.baseIdentity,
    path.resolve(inputs.assets['runtime.c.part0'].file,'..','runtime.c'),out+'/assets/effs',out+'/image','1',inputs.cache.carrier.file,inputs.cache.stamp];
  const execution=run('native-emit',args,420,true);
  const c=pin(out+'/image.1.c'),raw=read(c.file);
  for(const name of ['NATIVE_READONLY_OBSERVERS','NATIVE_PACK_CTORS'])assert(raw.includes('#define '+name+' 1\n'),name);
  assert(raw.includes('#define NATIVE_SCALAR_ARRAYS 0\n'));
  save(out+'/emission.json',{complete:true,source:inputs.compiler,producer:bridge.binary,execution,c,observers:true,packedConstructors:true,scalarArrays:false});
}else if(action==='link'){
  const e=json(out+'/emission.json');verify(e.c);assert(e.complete);assert.deepEqual(e.source,inputs.compiler);
  const build=run('native-link',[clang,'-O2','-isystem',include,'-DBEND_NATIVE_HOST=1','-DBEND_IMAGE_C='+JSON.stringify(e.c.file),import.meta.dirname+'/start.c','-lm','-pthread','-o',out+'/bend'],420,true);
  save(out+'/native.json',{complete:true,stage:'native Bend-produced B2',source:inputs.compiler,emission:pin(out+'/emission.json'),build,binary:pin(out+'/bend'),toolchain:pin(clang),startup:pin(import.meta.dirname+'/start.c'),generatedCUnmodified:true});
}else {throw Error('Expected prepare, bootstrap [bridge|harness], emit, or link');}
unchanged();
