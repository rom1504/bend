// Compose a separate candidate entry. No compiler invocation or source mutation.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const dir=import.meta.dirname;
const parent=path.resolve(dir,'../entry.bend'),decoder=path.join(dir,'decoder.bend');
const output=path.resolve(process.argv[2]??path.join(dir,'entry-cache.bend'));
assert(!fs.existsSync(output),'candidate entry already exists; use a fresh filename');
const source=fs.readFileSync(parent,'utf8'),decode=fs.readFileSync(decoder,'utf8');
const marker='@unsafe\ndef p86_cli(args: List<&1,String>) -> IO(U32):\n  match args:\n';
assert.equal(source.split(marker).length,2);
const fields=['program','+input','+base','+runtime','+directory','+output','+count','+cache','+stamp'];
const pattern=fields.reduceRight((tail,head)=>`Con{${head}, ${tail}}`,'Nil{}');
const extraCase=`    case ${pattern}:\n      p88_cli_cache(input,base,runtime,directory,output,count,cache,stamp)\n`;
const helpers=`
# PRIVATE cache mode: the wrapper authenticates the complete carrier receipt,
# producer/Base/path/ABI and native consumer image before invoking this entry.
# A matching stamp alone grants no trust. Cache refusal never falls back silently.
@unsafe
def p88_cache_prepare(+path: String, +text: String, carrier: String, stamp: String) -> P86Preparation:
  +end = U32.add(p86_width(text,0),2)
  p88_cache_result(f_source_located(FSource{"Base",path,text},1,end),p88_decode_admitted(carrier,stamp,1,end))

@unsafe
def p88_cache_result(+source: FSource, decoded: P88Decoded) -> P86Preparation:
  match decoded:
    case P88DecodeError{error}: P86PreparationError{"base_cache: " ++ error}
    case P88DecodeReady{P88Products{book,fresh,ready,world}}:
      p86_prepare_states(source,book,fresh,ready,world)

@unsafe
def p88_cache_paths(+input: String, +base: String, runtime: String, +directory: String, +output: String, +count: U32, cache: String, stamp: String) -> IO(U32):
  do IO<U32>:
    text : String <- p86_read_file(input)
    base_text : String <- p86_read_file(base)
    before : Nat <- IO.now()
    carrier : String <- p86_read_file(cache)
    p86_base_prepared(input,text,base,runtime,directory,output,count,p88_cache_prepare(base,base_text,carrier,stamp),before)

@unsafe
def p88_cli_cache(+input: String, +base: String, +runtime: String, +directory: String, +output: String, +count: String, +cache: String, +stamp: String) -> IO(U32):
  kc(IO(U32),String.starts_with(input,"/") && String.starts_with(base,"/") && String.starts_with(runtime,"/") && String.starts_with(directory,"/") && String.starts_with(output,"/") && String.starts_with(cache,"/") && Bool.not(String.is_empty(stamp)) && (String.eq(count,"1") || String.eq(count,"5")),
    u => p88_cache_paths(input,base,runtime,directory,output,kc(U32,String.eq(count,"1"),v => 1,v => 5),cache,stamp),
    u => IO.die(U32,2,"expected absolute paths, COUNT 1 or 5, and authenticated cache stamp"))

`;
const assembled=source.replace(marker,helpers+marker+extraCase).replace(
  'usage: compiler INPUT BASE RUNTIME EFFECTDIR OUTPUT COUNT',
  'usage: compiler INPUT BASE RUNTIME EFFECTDIR OUTPUT COUNT [CACHE STAMP]');
const text='# Candidate only: frozen decoder plus copied Phase88 entry.\n'+decode+'\n'+assembled;
const pin=f=>{const b=fs.readFileSync(f);return {file:fs.realpathSync(f),sha256:createHash('sha256').update(b).digest('hex'),bytes:b.length};};
const inputs=[parent,decoder,import.meta.filename].map(pin);
fs.writeFileSync(output,text,{flag:'wx'});
fs.writeFileSync(output+'.json',JSON.stringify({kind:'phase88-cache-entry-composition',inputs,output:pin(output),
  mode:'Six-argument live mode retained; eight-argument private cache mode appends CACHE STAMP.',
  clock:'Input/Base reads retain baseline placement; carrier read, decode and seed construction are inside base_prepare_ms.',
  admission:'Root must authenticate full receipt and consumer image. Candidate only; no admission granted by generation.'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify(pin(output)));
