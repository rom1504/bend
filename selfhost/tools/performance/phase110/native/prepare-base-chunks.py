#!/usr/bin/env python3
"""Freeze exact chunked Base comparison and a minimal native acquisition probe."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p110_prep',HERE/'prepare.py');PREP=importlib.util.module_from_spec(spec);spec.loader.exec_module(PREP)
pin,verify=PREP.pin,PREP.verify
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--chunk',type=int,default=1024);a=p.parse_args()
source_file=a.source.resolve()/'manifest.json';m=json.loads(source_file.read_text());out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
if not m['complete'] or not m.get('generalEntry') or a.chunk<64 or a.chunk>1024:raise ValueError('invalid source/chunk contract')
base=verify(m['assets']['base']);text=base.read_text();compiler=verify(m['source']);runtime=verify(m['assets']['runtime'])
if len(text)!=75064 or len(text.encode())!=75064:raise ValueError('expected exact ASCII Base')
chunks=[text[i:i+a.chunk] for i in range(0,len(text),a.chunk)]
if ''.join(chunks).encode()!=base.read_bytes():raise ValueError('chunk inverse differs')
generic=HERE/'base-chunks.bend';functions=[]
for index,chunk in enumerate(chunks):
 after='String.is_empty(text)' if index==len(chunks)-1 else 'p110_base_chunk_'+str(index+1)+'(text)'
 functions.append('@unsafe\ndef p110_base_chunk_'+str(index)+'(text: String) -> Bool:\n  p110_base_after_'+str(index)+'(p110_base_prefix(text,'+json.dumps(chunk,ensure_ascii=False)+'))\n\n@unsafe\ndef p110_base_after_'+str(index)+'(rest: Maybe<&2,String>) -> Bool:\n  match rest:\n    case None{}: False{}\n    case Some{text}: '+after)
module='def p110_general_base_expected_length() -> U32:\n  '+str(len(text))+'\n\n'+generic.read_text()+'\n\n'+'\n\n'.join(functions)+'\n'
blocks=PREP.blocks(compiler.read_text());read_names=['kc','p86_read_eof','p86_read_more','p86_read_sized','p86_read_file']
if 'p86_read_limit' in blocks:read_names.insert(-1,'p86_read_limit')
main='''@unsafe
def p110_base_probe_args(args: List<&1,String>) -> IO(Unit):
  match args:
    case Con{program,Con{path,Nil{}}}:
      do IO<Unit>:
        text : String <- p86_read_file(path)
        IO.print(Bool.show(p110_general_base_matches(text)))
    case _: IO.die(Unit,2,"usage: chunk-probe ABS_INPUT")

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1,String> <- IO.args()
    p110_base_probe_args(args)
'''
out.mkdir();(out/'module.bend').write_text(module)
(out/'source.bend').write_text('import Base\n\n'+'\n\n'.join(blocks[name] for name in read_names)+'\n\n'+module+'\n'+main)
(out/'positive.expected').write_text('True\n');(out/'negative.expected').write_text('False\n')
emit=ROOT/'selfhost/build/phase108'/('p110-'+out.name)/'emit'
command=[sys.executable,'-B',str(HERE.parent.parent/'phase108/run.py'),'emit',str(out/'source.bend'),'--runtime',str(runtime),'--out',str(emit),'--seconds','45']
record=dict(kind='phase110-exact-chunked-base-comparison',complete=True,targetsRun=False,base=m['assets']['base'],characters=len(text),bytes=len(text.encode()),chunkLimit=a.chunk,chunks=len(chunks),
 chunkPins=[dict(index=i,offset=i*a.chunk,characters=len(s),bytes=len(s.encode()),sha256=hashlib.sha256(s.encode()).hexdigest()) for i,s in enumerate(chunks)],inverseExact=True,
 source=pin(out/'source.bend'),module=pin(out/'module.bend'),inputs=[pin(Path(__file__)),pin(HERE/'prepare.py'),pin(generic),pin(source_file),m['source'],m['assets']['base'],m['assets']['runtime']],
 apiCommand=[str(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),str(ROOT/'selfhost/tools/stage0-library.mjs'),str(out/'source.bend'),str(out/'api.mjs'),'p110_general_base_matches','p110_general_base_expected_length'],
 emitCommand=command,guardCommand=[sys.executable,'-B',str(HERE.parent.parent/'phase86/guard.py'),'--out',str(emit.parent/'emit-guard'),'--seconds','60','--rss-mib','3072','--available-mib','8192','--cpu','3','--',*command],
 unchangedReadDefinitions=read_names,expected={'positive':pin(out/'positive.expected'),'negative':pin(out/'negative.expected')},
 limits=['No compiler target executed by preparation.','Every character is checked in order after exact bounded length comparison, and final suffix must be empty.','No static-image cap, compiler algorithm, runtime ABI or cache trust rule changes.'])
(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,source=record['source'],module=record['module'],chunks=len(chunks),manifest=str(out/'manifest.json'))))
