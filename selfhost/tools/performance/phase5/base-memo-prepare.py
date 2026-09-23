"""P5-021: prepare a private-host candidate; do not edit the maintained host."""
import hashlib
import json
from pathlib import Path
import shutil
import sys

source, output = map(lambda value: Path(value).resolve(), sys.argv[1:])
output.mkdir(parents=True, exist_ok=False)
shutil.copytree(source / 'tools', output / 'tools')
shutil.copytree(source / 'src/runtime', output / 'src/runtime')
shutil.copy2(source / 'src/runtime.mjs', output / 'src/runtime.mjs')
(output / 'build/typed').mkdir(parents=True)
shutil.copytree(source / 'build/typed/cache', output / 'build/typed/cache')
driver = output / 'tools/typed-driver.mjs'
text = driver.read_text()

def replace(old, new):
    global text
    assert text.count(old) == 1, old
    text = text.replace(old, new)

replace('function readBaseCache(info) {', '''// Only persistent inspectors own this bounded memo. Re-read and hash the exact
// bytes on every request; cached metadata and filesystem timestamps are not proof.
function freezeBaseBook(book) {
  const pending=[book];
  while(pending.length) {
    const value=pending.pop();
    if(value===null||typeof value!=='object'||Object.isFrozen(value))continue;
    Object.freeze(value);
    for(const child of Object.values(value))if(child!==null&&typeof child==='object')pending.push(child);
  }
  return book;
}
function readBaseCache(info,memo=null) {''')
replace('export async function loadApi() {', '''export async function loadApi() {
  return loadApiForIdentity();
}
async function loadApiForIdentity(identity=null) {''')
replace('const module=await import(pathToFileURL(apiPath));', '''// A content identity prevents a new inspector from binding changed file bytes
  // to an older module already held by Node's URL cache.
  const url=pathToFileURL(identity?.canonicalPath??apiPath);
  if(identity)url.searchParams.set('bendApiSha256',identity.sha256);
  const module=await import(url);''')
replace("    const cached=JSON.parse(fs.readFileSync(info.file,'utf8'));", '''    const previous=memo?.entry;
    if(memo)memo.entry=null;
    const bytes=fs.readFileSync(info.file);
    const key=memo?JSON.stringify([info.version,info.compilerSha256,info.baseSha256,info.sourcePath,info.file]):null;
    const digest=memo?crypto.createHash('sha256').update(bytes).digest('hex'):null;
    if(previous?.key===key&&previous.digest===digest)
      return {...previous.cached,sourcePath:info.sourcePath,sourceText:info.sourceText,...(memo.entry=previous,{})};
    const cached=JSON.parse(bytes.toString('utf8'));''')
replace('    return {...cached,sourcePath:info.sourcePath,sourceText:info.sourceText};', '''    if(memo) {
      freezeBaseBook(cached.book);
      Object.freeze(cached);
      memo.entry={key,digest,cached};
    }
    return {...cached,sourcePath:info.sourcePath,sourceText:info.sourceText};''')
replace("export async function inspect(input,{mode='check',api,args=[],timeoutMs=5000,combinedOutput=false,withReport=false}={}) {", '''export async function inspect(input,options={}) {
  return inspectWithMemo(input,options);
}

// An inspector owns its API and a single immutable decoded Base book. Public
// inspect/prepareBase callers cannot inject an API into this private state.
export async function createPersistentInspector() {
  const identity={canonicalPath:fs.realpathSync(apiPath),sha256:hash(apiPath)};
  const api=await loadApiForIdentity(identity);
  if(fs.realpathSync(apiPath)!==identity.canonicalPath||hash(apiPath)!==identity.sha256)
    throw Error('Compiler API changed while creating persistent inspector');
  const memo={entry:null,identity};
  return Object.freeze({inspect(input,options={}) {
    if(!['parse','check'].includes(options.mode??'check'))throw Error('Persistent inspector supports only parse/check');
    return inspectWithMemo(input,{...options,api},memo);
  }});
}

async function inspectWithMemo(input,{mode='check',api,args=[],timeoutMs=5000,combinedOutput=false,withReport=false}={},memo=null) {''')
replace('    const seed=api.f_load_graph_seed?readBaseCache(baseCacheInfo(api)):null;', '''    const info=api.f_load_graph_seed?baseCacheInfo(api):null;
    if(memo&&(fs.realpathSync(apiPath)!==memo.identity.canonicalPath||(info?.compilerSha256??hash(apiPath))!==memo.identity.sha256)) {
      memo.entry=null;
      throw Error('Compiler API changed during persistent inspection');
    }
    const seed=info?readBaseCache(info,memo):null;''')
# Keep hit handling explicit and free of mutation hidden in object expressions.
replace('''    if(previous?.key===key&&previous.digest===digest)
      return {...previous.cached,sourcePath:info.sourcePath,sourceText:info.sourceText,...(memo.entry=previous,{})};''', '''    if(previous?.key===key&&previous.digest===digest) {
      memo.entry=previous;
      return {...previous.cached,sourcePath:info.sourcePath,sourceText:info.sourceText};
    }''')
driver.write_text(text)
adapter = output / 'tools/conformance/adapters/typed.mjs'
text = adapter.read_text()
replace('inspect,execute,loadApi,apiPath', 'inspect,execute,createPersistentInspector,apiPath')
replace('''// A persistent session shares only the immutable generated API module and its
// loaded function table. Every request still discovers sources, constructs a
// fresh graph, validates its own cache prefix and gets its own work directory.''', '''// A persistent session owns the loaded API and one immutable decoded Base cache.
// Every request verifies the complete cache bytes, discovers sources, constructs
// a fresh graph, validates its prefix and gets its own work directory.''')
replace('async function probeWithApi({test,lane,workdir,timeoutMs},api) {', 'async function probeWithApi({test,lane,workdir,timeoutMs},inspector) {')
replace('await inspect(test.file,{mode:', 'await (inspector?inspector.inspect:inspect)(test.file,{mode:')
replace("'interpreter':'check',api,timeoutMs", "'interpreter':'check',timeoutMs")
replace('''  const api=await loadApi();
  return {probe:request=>probeWithApi(request,api)};''', '''  const inspector=await createPersistentInspector();
  return {probe:request=>probeWithApi(request,inspector)};''')
adapter.write_text(text)
files = ['tools/typed-driver.mjs', 'tools/conformance/adapters/typed.mjs']
identity = lambda file: {'file': str(file), 'sha256': hashlib.sha256(file.read_bytes()).hexdigest()}
(output / 'preparation.json').write_text(json.dumps({'source': str(source), 'output': str(output),
    'inputs': [identity(source / file) for file in files],
    'outputs': [identity(output / file) for file in files], 'tool': identity(Path(__file__).resolve())}, indent=2)+'\n')
