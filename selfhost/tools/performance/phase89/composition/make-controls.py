#!/usr/bin/env python3
"""Extract real production/candidate composers into a small standalone fixture."""
import hashlib,json,re,sys
from pathlib import Path

assert len(sys.argv)==2,'Usage: make-controls.py NEW_CONTROL.bend'
here=Path(__file__).resolve().parent;root=here.parents[4];out=Path(sys.argv[1])
inputs=[]
def blocks(p):
    p=Path(p);inputs.append(p);s=p.read_text()
    marks=list(re.finditer(r'(?m)^(?:@unsafe\n)?(type|law|def)\s+([^\s(<:]+)',s))
    return {(m[1],m[2]):s[m.start():marks[i+1].start() if i+1<len(marks) else len(s)].rstrip()+'\n'
            for i,m in enumerate(marks)}
all_blocks={}
for name in ['ir','text','sharing','product']:
    all_blocks.update(blocks(root/f'selfhost/src/back/native/{name}.bend'))
baseline=blocks(here/'bridge.baseline.bend');candidate=blocks(here/'bridge.candidate.bend')
all_blocks.update(baseline)
types=['N_WordKind','N_Param','N_Frame','N_Segment','NC_Code']
defs=['nt_choose','nt_reverse','nt_append','nt_clean','nt_cid','nc_id','nh_field_test','nh_field_type',
      'nc_body','nc_segs','nc_fresh','nc_error','nc_first_error','nc_calls',
      'nc_condition','nc_field_word','nc_field_decls','nc_destructure']
parts=['import Base\n']+[all_blocks['type',n] for n in types]+[all_blocks['def',n] for n in defs]
parts.append(candidate['def','nc_match_apply_join'])
original=baseline['def','nc_match_apply_slow_to']
tail=original[original.index('  +guard ='):].replace('nm(mat)','name')
parts.append('@unsafe\ndef p89_original(+name: String, +word: String, +count: U32, +n: U32, +hit: NC_Code, +miss: NC_Code) -> NC_Code:\n'+tail)
parts.append('''type P89Case is Data:
  P89Case{+name: String, +original: NC_Code, +candidate: NC_Code}

@unsafe
def p89_candidate(+name: String, +word: String, +count: U32, +n: U32, hit: NC_Code, miss: NC_Code) -> NC_Code:
  match hit:
    case NC_Code{body, segs, next, error, calls}:
      nc_match_apply_join(name, word, count, n, body, segs, error, calls, miss)

@unsafe
def p89_segment(+name: String, +n: U32) -> N_Segment:
  N_Segment{name, [N_Param{"arg", N_W64{}}], n, N_Frame{n, ["slot"]}, "segment-body:" ++ name, ["seg-ref:" ++ name], True{}, False{}, True{}, False{}}

@unsafe
def p89_child(+side: String, n: U32, error: String) -> NC_Code:
  NC_Code{"BODY:" ++ side ++ ";\\n", [p89_segment(side, 3)], n, error, ["first:" ++ side, "dup", "last:" ++ side]}

@unsafe
def p89_case(name: String, +ctor: String, +count: U32, +hit: NC_Code, +miss: NC_Code) -> P89Case:
  P89Case{name, p89_original(ctor, "w", count, 100, hit, miss), p89_candidate(ctor, "w", count, 100, hit, miss)}
''')
cases=[('ordinary','Box',2,'',''),('hit-error','Box',2,'hit-failed',''),
       ('miss-error','Box',2,'','miss-failed'),('both-error','Box',2,'hit-failed','miss-failed'),
       ('effect-emit','Emit',2,'',''),('effect-halt','Halt',1,'',''),
       ('primitive-true','True',0,'',''),('primitive-false','False',0,'',''),
       ('primitive-zero','Zero',0,'',''),('primitive-succ','Succ',1,'',''),
       ('primitive-chr','Chr',1,'',''),('primitive-u32','U32',1,'',''),
       ('primitive-f32','F32',1,'',''),('array-leaf','ALeaf',1,'',''),
       ('array-node','ANode',2,'',''),('generic-nullary','Empty',0,'','')]
quote=lambda x:json.dumps(x,ensure_ascii=False)
rows=[];expect={}
for name,ctor,count,he,me in cases:
    rows.append(f'p89_case({quote(name)}, {quote(ctor)}, {count}, p89_child("hit", 17, {quote(he)}), p89_child("miss", 29, {quote(me)}))')
    expect[name]=dict(fresh=29,error=he or me,segments=['hit','miss'],calls=['first:hit','dup','last:hit','first:miss','dup','last:miss'],bodyContains=['BODY:hit;\n','BODY:miss;\n'],guard=ctor in ['Emit','Halt'])
rows.append('p89_case("empty", "Empty", 0, NC_Code{"", Nil{}, 0, "", Nil{}}, NC_Code{"", Nil{}, 7, "", Nil{}})')
expect['empty']=dict(fresh=7,error='',segments=[],calls=[],bodyContains=['} else {\n'],guard=False)
rows.append('p89_case("no-newline", "Box", 1, NC_Code{"HIT", Nil{}, 0, "", ["h"]}, NC_Code{"MISS", Nil{}, 31, "", ["m"]})')
expect['no-newline']=dict(fresh=31,error='',segments=[],calls=['h','m'],bodyContains=['HIT} else {\nMISS}\n'],guard=False)
rows.append('p89_case("nested", "True", 0, p89_original("Box", "inner", 2, 200, p89_child("inner-hit", 11, ""), p89_child("inner-miss", 19, "")), p89_child("outer-miss", 43, ""))')
expect['nested']=dict(fresh=43,error='',segments=['inner-hit','inner-miss','outer-miss'],calls=['first:inner-hit','dup','last:inner-hit','first:inner-miss','dup','last:inner-miss','first:outer-miss','dup','last:outer-miss'],bodyContains=['BODY:inner-hit;\n','BODY:inner-miss;\n','BODY:outer-miss;\n'],guard=False)
parts.append('@unsafe\ndef main() -> List<&2, P89Case>:\n  [\n    '+',\n    '.join(rows)+'\n  ]\n')
with out.open('x') as f:f.write('\n'.join(parts))
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
report=dict(kind='phase89-complete-composition-controls',source=pin(out),inputs=[pin(p) for p in inputs]+[pin(Path(__file__))],cases=expect,
            scope='Actual extracted original expression and candidate final composer with real formatting helpers; synthetic child products, not recursive lowering.')
with out.with_suffix('.json').open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(source=str(out),cases=len(expect),bytes=out.stat().st_size)))
