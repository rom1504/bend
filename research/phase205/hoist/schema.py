"""Render inspectable Bend patterns from the observed source equations; no program input at compile time."""
import json,gzip,sys
from pathlib import Path
source=Path(sys.argv[1])
defs={d['name']:d for d in json.load(gzip.open(source))['defs']}
roles={'p37.text.repeat':'repeat','ssplit':'split','ssplit.pick':'pick','ssplit.push':'push','sjoin':'join','sjoin.go':'join_rest','String.append':'append'}
def fmt(t,env):
 tag=t['t']; k=t['k']; n=t['n']; i=t['i']
 if tag=='Ann':return fmt(k[0],env)
 if tag=='Lam':return 'L205{'+fmt(k[0],[i,*env])+'}'
 if tag=='Var':return 'V205{'+str(env.index(i))+'}'
 if tag=='Let':
  bind,body=k
  assert bind['t']=='Bind' and len(bind['k'])==1
  return 'B205{'+fmt(bind['k'][0],env)+','+fmt(body,[bind['i'],*env])+'}'
 if tag=='Ref' and n in roles:return 'R205{'+json.dumps(roles[n])+'}'
 assert tag in ('App','Ref','Mat','Ctr','Efq'),tag
 return 'N205{'+','.join([json.dumps(tag),json.dumps(n),'['+','.join(fmt(c,env) for c in k)+']'])+'}'
def ty(t):
 if t['t']=='All':return [*ty(t['k'][0]),*ty(t['k'][1])]
 if t['t']=='Ref':return [t['n']]
 assert t['t']=='ADT' and t['n']=='List' and t['k'][0]['t']=='Qua' and t['k'][0]['q']==2 and t['k'][1]['n']=='String',t
 return ['Strings']
for index,(n,r) in enumerate(roles.items()):
 if index: print()
 d=defs[n]
 print('@unsafe\ndef p205_'+r+'_equation() -> P205Equation:\n  P205Equation{'+json.dumps(ty(d['typ']))+',\n    '+fmt(d['checked'],[])+'}')
