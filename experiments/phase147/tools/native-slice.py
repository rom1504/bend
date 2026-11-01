#!/usr/bin/env python3
"""Prepare one bounded native binary with runtime-selected original/candidate loops."""
import argparse
import json
from pathlib import Path
import re
import sys
from prepare import ROOT, assembly, extract, fresh_output, guard, pin, require, write_json
from common import verify


def items(value):
    rows=[]
    while value['$']=='Con': rows.append(value['head']);value=value['tail']
    require(value=={'$':'Nil'}, 'Malformed list');return rows


def fields(source):
    result={}
    _,blocks=assembly.blocks(source)
    for block in blocks:
        if block['kind']!='type':continue
        for match in re.finditer(rb'^  ([A-Za-z_][A-Za-z0-9_.]*)\{([^\n]*)\}', block['data'], re.M):
            result[match[1].decode()]=re.findall(r'(?:^|,)\s*\+?([A-Za-z_][A-Za-z0-9_]*)\s*:', match[2].decode())
    return result


def literal(value, schema):
    if type(value) is bool:return 'True{}' if value else 'False{}'
    if type(value) is int:require(0<=value<=4294967295,'U32 literal out of range');return str(value)
    if isinstance(value,str):
        text=json.dumps(value,ensure_ascii=False);require('\\u'not in text,'Unsupported literal escape; no normalization');return text
    if isinstance(value,list):return '['+','.join(literal(x,schema)for x in value)+']'
    tag=value['$']
    if tag in ['Con','Nil']:return literal(items(value),schema)
    names=schema[tag];require(set(value)=={'$',*names},'Constructor fields differ: '+tag)
    return tag+'{'+','.join(literal(value[k],schema)for k in names)+'}'


def workload():
    chunks=['''type P147HCase is Data:
  P147HCase{+index: U32, +function: P113DFunction}
''']
    for mode,raw,direct in [('old','p111v_segment','p113e_function'),('new','p147v_segment','p147v_function')]:
        chunks.append(f'''
@unsafe
def p147h_{mode}_raw(functions: List<&2,N111Segment>, +ids: N111Ids, count: U32) -> U32:
  match functions:
    case Nil{{}}: count
    case Con{{head,rest}}: p147h_{mode}_raw(rest,ids,U32.add(count,Bool.to_u32(String.is_empty({raw}(head,ids)))))

@unsafe
def p147h_{mode}_scans(functions: P111VScan, constructors: P111VScan) -> U32:
  match functions constructors:
    case P111VScan{{fs,+fe,fc}} P111VScan{{cs,+ce,cc}}:
      nt_choose(U32,String.is_empty(fe) && String.is_empty(ce),
        u => p147h_{mode}_raw(p147h_raw_bodies(),N111Ids{{fs,cs}},0),u => 0)

@unsafe
def p147h_{mode}_direct(headers: List<&2,P113DFunction>, +selected: List<&2,P147HCase>, +ids: N111Ids, +ready: KDef, +index: U32, +count: U32) -> U32:
  match headers selected:
    case _ Nil{{}}: count
    case Nil{{}} _: count
    case Con{{+header,+rest}} Con{{P147HCase{{wanted,+function}},+next}}:
      nt_choose(U32,U32.is_eq(index,wanted),
        u => p147h_{mode}_direct(rest,next,ids,p113e_insert(ready,p113e_signature(header)),U32.inc(index),
          U32.add(count,Bool.to_u32(String.is_empty({direct}(function,ids,ready))))),
        u => p147h_{mode}_direct(rest,selected,ids,p113e_insert(ready,p113e_signature(header)),U32.inc(index),count))

@unsafe
def p147h_{mode}_once() -> U32:
  U32.add(p147h_{mode}_scans(p111v_functions(p147h_headers(),P111VScan{{missing(),"",0}}),
    p111v_constructors(p147h_constructors(),P111VScan{{missing(),"",0}})),
    p147h_{mode}_direct(p147h_direct_headers(),p147h_direct_bodies(),
      N111Ids{{p113e_originals(p147h_headers(),missing()),ns_ctor_index(p147h_constructors(),missing())}},missing(),0,0))

@unsafe
def p147h_{mode}_loop(left: U32, count: U32) -> U32:
  match left:
    case 0: count
    case _: p147h_{mode}_loop(U32.sub(left,1),U32.add(count,p147h_{mode}_once()))
''')
    chunks.append('''
@unsafe
def p147h_run(+mode: String, +count: U32) -> IO(Unit):
  nt_choose(IO(Unit),U32.is_le(count,100000) && (String.eq(mode,"old") || String.eq(mode,"new")),
    u => IO.print(U32.show(nt_choose(U32,String.eq(mode,"new"),v => p147h_new_loop(count,0),v => p147h_old_loop(count,0)))),
    u => IO.die(Unit,2,"expected old/new and repetition count <=100000"))

@unsafe
def p147h_parsed(mode: String, parsed: Maybe<&2,U32>) -> IO(Unit):
  match parsed:
    case Some{count}: p147h_run(mode,count)
    case None{}: IO.die(Unit,2,"invalid repetition count")

@unsafe
def p147h_args(args: List<&1,String>) -> IO(Unit):
  match args:
    case Con{program,Con{mode,Con{count,Nil{}}}}: p147h_parsed(mode,U32.read(count))
    case _: IO.die(Unit,2,"usage: verifier-slice old/new REPEATS")

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<&1,String> <- IO.args()
    p147h_args(args)
''')
    return '\n'.join(chunks).encode()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--capture',type=Path,required=True);p.add_argument('--family',required=True)
    p.add_argument('--candidate',type=Path,required=True);p.add_argument('--controls',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    capture=json.loads(a.capture.read_text());controls=json.loads(a.controls.read_text())
    require(capture['complete'] and capture['kind']=='phase147-verifier-input-capture','Actual completed capture required')
    require(controls['complete'] and controls['passed'] and all(r['passed']for r in controls['rows']),'Independent controls required')
    prepared=json.loads(a.candidate.read_text());require(prepared['mode']=='candidate','Candidate source preparation required')
    source=verify(prepared['source']);checked=verify(controls['candidate'])
    api=json.loads((a.candidate.parent/'api/report.json').read_text())
    require(api['complete'] and api['checked'] and pin(checked)==api['api'] and api['source']==prepared['source'],'Controlled candidate image/source differs')
    data_pin=next(row['data']for row in capture['rows']if row['name']==a.family);datum=json.loads(verify(data_pin).read_text())
    require(datum['complete'] and datum['originalAccepted'],'Verified captured data required')
    canonical=assembly.maintained_assemble(ROOT/'selfhost/src/compiler.json',ROOT/'selfhost','qbe')
    _,blocks=assembly.blocks(canonical)
    # Candidate prepared source already contains exact original dependencies.
    # Extract it alone; adding canonical again would silently shadow definitions.
    schema=fields(canonical);schema['P147HCase']=['index','function']
    definitions=[('headers','List<&2,N111Segment>',datum['segments']),('constructors','List<&2,N_Constructor>',datum['constructors']),
                 ('raw_bodies','List<&2,N111Segment>',[r['function']for r in datum['raw']]),
                 ('direct_headers','List<&2,P113DFunction>',datum['directHeaders']),
                 ('direct_bodies','List<&2,P147HCase>',[dict({'$':'P147HCase'},index=r['index'],function=r['function'])for r in datum['direct']])]
    fixture='\n'.join('def p147h_'+name+'() -> '+typ+':\n  '+literal(value,schema)+'\n'for name,typ,value in definitions).encode()
    harness=workload();_,candidate_rows=assembly.blocks(source.read_bytes());have={r['name']for r in candidate_rows}
    # Native orchestration uses two extra original signature helpers, retaining
    # exact current declarations absent from the testing API closure if necessary.
    extra=b''.join(row['data']for row in blocks if row['name']not in have and row['name']!='main')
    body,inventory=extract([('checked-candidate',source.read_bytes()),('canonical-extra',extra),('fixture',fixture),('harness',harness)],['main'],1_000_000)
    out=fresh_output(a.out,ROOT);(out/'compiler.bend').write_bytes(body);(out/'fixture.bend').write_bytes(fixture);(out/'workload.bend').write_bytes(harness)
    build=out/'native';command=['python3','-B',ROOT/'selfhost/tools/build/native.py','--assets',ROOT/'selfhost/manifests/assets-native.json',
        '--host','native','--target','qbe','--stage','N2','--image-key','qbe-n2','--mode','cache','--source',out/'compiler.bend',
        '--out',build,'--seconds','150']
    jobs=[guard('native-verifier-'+a.family,build,command,180,3072,256)]
    total=len(datum['raw'])+len(datum['direct'])
    report=dict(kind='phase147-native-complete-region-preparation',version=1,complete=True,checked=False,targetsRun=False,
        inputs=[pin(__file__),pin(a.capture),pin(a.candidate),pin(a.controls),data_pin,prepared['source'],controls['candidate']],
        family=a.family,source=pin(out/'compiler.bend'),fixture=pin(out/'fixture.bend'),workload=pin(out/'workload.bend'),
        declarations=inventory,checksPerIteration=total,metadataHeaders=len(datum['segments']),directHeaders=len(datum['directHeaders']),
        binary=str(build/'program'),buildReport=str(build/'report.json'),jobs=jobs,
        argv=['--threads','1','--gpu','off','--','verifier-slice','old|new','REPEATS'],expected='checksPerIteration * REPEATS followed by newline; stderr empty; exit0',
        scope='One binary holds both modes. Runtime mode/count prevents a fixed-loop constant. Each iteration rebuilds original global metadata, exact ordered ready context and all selected local schemas/conversion/flows. Temporary ownership state is destroyed before scalar count publication; whole process includes final cleanup. This is a bounded selected-function region, not whole-request speed.')
    write_json(out/'manifest.json',report);write_json(out/'jobs.json',jobs)
    print(json.dumps(dict(source=report['source'],declarations=len(inventory),checksPerIteration=total,jobs=str(out/'jobs.json'),targetsRun=False)))


if __name__=='__main__':main()
