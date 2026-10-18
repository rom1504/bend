#!/usr/bin/env python3
"""Freeze bounded exact packed-U32 Base comparison and minimal native probe."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p110_prep',HERE/'prepare.py');PREP=importlib.util.module_from_spec(spec);spec.loader.exec_module(PREP)
pin,verify=PREP.pin,PREP.verify
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',required=True,type=Path);p.add_argument('--chunk-probe',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args()
source_file=a.source.resolve()/'manifest.json';m=json.loads(source_file.read_text());out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
if not m['complete'] or not m.get('generalEntry'):raise ValueError('invalid native source')
base=verify(m['assets']['base']);raw=base.read_bytes();compiler=verify(m['source']);runtime=verify(m['assets']['runtime'])
if len(raw)!=75064 or len(raw)%4 or any(byte>127 for byte in raw):raise ValueError('expected exact complete four-byte-aligned ASCII Base')
words=[int.from_bytes(raw[i:i+4],'little') for i in range(0,len(raw),4)]
if b''.join(word.to_bytes(4,'little') for word in words)!=raw:raise ValueError('packed byte inverse differs')
chunk_size=256;chunks=[words[i:i+chunk_size] for i in range(0,len(words),chunk_size)]
generic=HERE/'base-packed.bend';prior=HERE/'base-chunks.bend';sizes=PREP.blocks(prior.read_text());size_names=['p110_base_size','p110_base_size_more','p110_general_base_matches','p110_base_length_checked']
functions=[]
for index,chunk in enumerate(chunks):
 after='String.is_empty(text)' if index==len(chunks)-1 else 'p110_base_chunk_'+str(index+1)+'(text)'
 functions.append('@unsafe\ndef p110_base_chunk_'+str(index)+'(text: String) -> Bool:\n  p110_base_after_'+str(index)+'(p110_base_packed_words(text,['+','.join(map(str,chunk))+']))\n\n@unsafe\ndef p110_base_after_'+str(index)+'(rest: Maybe<&2,String>) -> Bool:\n  match rest:\n    case None{}: False{}\n    case Some{text}: '+after)
module='def p110_general_base_expected_length() -> U32:\n  '+str(len(raw))+'\n\n'+generic.read_text()+'\n\n'+'\n\n'.join(sizes[name] for name in size_names)+'\n\n'+'\n\n'.join(functions)+'\n'
old_probe_file=a.chunk_probe.resolve()/'manifest.json';old_probe=json.loads(old_probe_file.read_text());probe_source=verify(old_probe['source']);probe_blocks=PREP.blocks(probe_source.read_text())
read_names=old_probe['unchangedReadDefinitions'];main='\n\n'.join(probe_blocks[name] for name in ['p110_base_probe_args','main'])
out.mkdir();(out/'module.bend').write_text(module);(out/'packed-words.json').write_text(json.dumps(words)+'\n')
(out/'source.bend').write_text('import Base\n\n'+'\n\n'.join(probe_blocks[name] for name in read_names)+'\n\n'+module+'\n\n'+main+'\n')
(out/'positive.expected').write_text('True\n');(out/'negative.expected').write_text('False\n')
emit=ROOT/'selfhost/build/phase108'/('p110-'+out.name)/'emit'
command=[sys.executable,'-B',str(HERE.parent.parent/'phase108/run.py'),'emit',str(out/'source.bend'),'--runtime',str(runtime),'--out',str(emit),'--seconds','45']
record=dict(kind='phase110-exact-chunked-base-comparison',version=2,encoding='four-ASCII-bytes-little-endian-U32',complete=True,targetsRun=False,base=m['assets']['base'],characters=len(raw),bytes=len(raw),packedWords=len(words),listWords=2*len(words),chunkWords=chunk_size,chunkLimit=4*chunk_size,chunks=len(chunks),
 chunkPins=[dict(index=i,offset=i*chunk_size*4,words=len(chunk),characters=4*len(chunk),sha256=hashlib.sha256(b''.join(word.to_bytes(4,'little') for word in chunk)).hexdigest()) for i,chunk in enumerate(chunks)],inverseExact=True,
 source=pin(out/'source.bend'),module=pin(out/'module.bend'),packed=pin(out/'packed-words.json'),inputs=[pin(Path(__file__)),pin(HERE/'prepare.py'),pin(generic),pin(prior),pin(old_probe_file),old_probe['source'],pin(source_file),m['source'],m['assets']['base'],m['assets']['runtime']],
 apiCommand=[str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),str(ROOT/'selfhost/tools/stage0-library.mjs'),str(out/'source.bend'),str(out/'api.mjs'),'p110_general_base_matches','p110_general_base_expected_length'],
 emitCommand=command,guardCommand=[sys.executable,'-B',str(HERE.parent.parent/'phase86/guard.py'),'--out',str(emit.parent/'emit-guard'),'--seconds','60','--rss-mib','3072','--available-mib','8192','--cpu','3','--',*command],
 unchangedReadDefinitions=read_names,expected={'positive':pin(out/'positive.expected'),'negative':pin(out/'negative.expected')},
 limits=['Preparation only.','U32 is the available stable source scalar; no new U64 primitive or arithmetic ABI is introduced.','Exact ASCII inversion, full codepoint equality, bounded exact length and empty final remainder replace no bytes with a hash.','Static image cap and compiler/runtime code remain unchanged.'])
(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,source=record['source'],module=record['module'],words=len(words),manifest=str(out/'manifest.json'))))
