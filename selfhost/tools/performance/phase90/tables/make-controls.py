from pathlib import Path
import json,re,hashlib
root=Path(__file__).resolve().parents[5]; out=root/'selfhost/tools/performance/phase90/tables'
pin=lambda p:dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
def definition(text,name):
 m=re.search(r'(?m)^def '+re.escape(name)+r'\(',text);assert m,name
 start=text.rfind('@unsafe\n',0,m.start());assert start>=0 and text[start:m.start()]=='@unsafe\n'
 end=re.search(r'(?m)^(?:@unsafe|law |type |def )',text[m.end():]);end=m.end()+end.start() if end else len(text)
 return text[start:end].rstrip()+'\n'
oldpath=root/'selfhost/src/back/native/tables.bend'; newpath=out/'tables.bend';textpath=root/'selfhost/src/back/native/text.bend';idpath=root/'selfhost/src/back/native/identity.bend';irpath=root/'selfhost/src/back/native/ir.bend'
old,new,txt,identity=[p.read_text() for p in [oldpath,newpath,textpath,idpath]]
parts=['import Base\n',irpath.read_text(),definition(identity,'nc_ctor_codes')]
for name in ['nt_choose','nt_text_finish','nt_count_go','nt_count','nt_fid','nt_bool']:parts.append(definition(txt,name))
for name in ['nb_frame_results','nb_contains']:parts.append(definition(old,name))
names=['nb_seg_ids','nb_arities','nb_result_words','nb_flags','nb_dispatch']
for name in names:
 d=definition(old,name+'_go');parts.append(re.sub(r'\b'+name+r'_go\b','old_'+name+'_go',d))
 for suffix in ['_chunks','_go','']:parts.append(definition(new,name+suffix))
parts.append('''@unsafe
def p90_chars(s: String) -> List<&2,U32>:
  match s:
    case SNil{}: Nil{}
    case SCon{h,t}: Con{Char.to_u32(h),p90_chars(t)}

@unsafe
def p90_pack(xs: List<&2,String>) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case Con{+h,t}: Con{U32.from_nat(String.length(h)),List.append(&2,U32,p90_chars(h),p90_pack(t))}

@unsafe
def p90_case(+ss: List<&2,N_Segment>, +forks: List<&2,String>, +i: U32, +prefix: String) -> List<&2,String>:
  [old_nb_seg_ids_go(ss,i,prefix), nb_seg_ids_go(ss,i,prefix),
   old_nb_arities_go(ss,prefix), nb_arities_go(ss,prefix),
   old_nb_result_words_go(ss,prefix), nb_result_words_go(ss,prefix),
   old_nb_flags_go(ss,forks,prefix), nb_flags_go(ss,forks,prefix),
   old_nb_dispatch_go(ss,prefix), nb_dispatch_go(ss,prefix),
   nb_seg_ids(ss,i), nb_arities(ss), nb_result_words(ss), nb_flags(ss,forks), nb_dispatch(ss),
   prefix, U32.show(nt_count(N_Segment,ss)), U32.show(nt_count(String,forks))]
''')
a=dict(name='alpha',params=0,frame=None,fork=False,bang=False)
b=dict(name='é\n😀',params=3,frame=['x'],fork=True,bang=True)
c=dict(name='tail',params=2,frame=[],fork=False,bang=True)
d=dict(name='',params=1,frame=None,fork=False,bang=True)
cases=[dict(segments=[],forks=[],i=0,prefix=''),dict(segments=[],forks=['unused'],i=9,prefix='prefix;\n'),dict(segments=[a],forks=[],i=7,prefix='P:'),dict(segments=[a,b,c,d],forks=['tail'],i=11,prefix='é\n'),dict(segments=[a,b,c,d],forks=[],i=4294967294,prefix='/*p*/'),dict(segments=[c,a,c],forks=['alpha','tail'],i=1,prefix='')]
q=lambda s:json.dumps(s,ensure_ascii=False)
def segment(x):
 ps='['+', '.join('N_Param{'+q('p'+str(i))+', '+['N_W32{}','N_W64{}','N_Box{}'][i%3]+'}' for i in range(x['params']))+']'
 frame='N_Direct{}' if x['frame'] is None else 'N_Frame{3,['+','.join(q(y) for y in x['frame'])+']}'
 return 'N_Segment{'+','.join([q(x['name']),ps,'3',frame,q('retained body 😀'), '["reference"]','True{}','False{}','True{}' if x['fork'] else 'False{}','True{}' if x['bang'] else 'False{}'])+'}'
outputs=[];exprs=[]
for case in cases:
 ss=case['segments'];forks=case['forks'];i=case['i'];prefix=case['prefix'];fid=lambda name:'FID_'+''.join(str(ord(c))+'_' for c in name)
 tail=(i+len(ss))%(2**32)
 vals=[''.join('#define '+fid(s['name'])+' '+str((i+k)%(2**32))+'\n' for k,s in enumerate(ss))+'#define FID_IO_EMIT '+str(tail)+'\n#define BEND_CLO_APPLY '+str((tail+1)%(2**32))+'\n#define FID_EXIT '+str((tail+2)%(2**32))+'\n#define FID_ENTER '+str((tail+3)%(2**32))+'\n', ''.join(str(s['params'])+', ' for s in ss)+'1, 2', ''.join(str(0 if s['frame'] is None else (s['params']-len(s['frame']))%(2**32))+', ' for s in ss)+'0, 0', ''.join(str(int(s['bang'])+2*int(not s['fork'] and s['name'] not in forks))+', ' for s in ss)+'2, 0', ''.join('WL_X('+fid(s['name'])+') ' for s in ss)+'WL_X(FID_IO_EMIT) WL_X(BEND_CLO_APPLY) WL_X(FID_EXIT)']
 outputs += [prefix+v for v in vals for _ in range(2)] + vals + [prefix,str(len(ss)),str(len(forks))]
 exprs.append('p90_case(['+','.join(segment(s) for s in ss)+'],['+','.join(q(x) for x in forks)+'],'+str(i)+','+q(prefix)+')')
expr='Nil{}'
for e in reversed(exprs):expr='List.append(&2,String,'+e+','+expr+')'
parts.append('@unsafe\ndef main() -> List<&2,U32>:\n  p90_pack('+expr+')\n')
p=out/'controls.bend';p.write_text('\n'.join(parts))
meta=dict(kind='phase90-actual-table-controls',source=pin(p),dependencies=[pin(x) for x in [oldpath,newpath,textpath,idpath,irpath]],cases=cases,observations=outputs,expectedWords=[n for s in outputs for n in [len(s),*map(ord,s)]],retained='Each input is shared through all baseline/candidate/public calls; prefix and list counts are observed afterward.')
(out/'controls.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2)+'\n');print(json.dumps(pin(p)));print('observations',len(outputs),'words',len(meta['expectedWords']))
