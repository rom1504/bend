"""Heuristic source-form audit; never replaces independent Bend checking."""
from pathlib import Path
import hashlib,json,re
here=Path(__file__).parent
result={'kind':'numeric-source-form-preflight-v1','independentChecking':False,'files':[],'issues':[]}
for path in [here/'numeric-affine.bend',here/'affine.bend',here/'hook.bend']:
 text=path.read_text();lines=text.splitlines();params=[];function=''
 result['files'].append({'file':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
 for n,line in enumerate(lines,1):
  m=re.match(r'def (\w+)\((.*?)\)',line)
  if m:
   function=m[1];params=re.findall(r'\+?(\w+)\s*:',m[2])
   if not params:params=[x.strip().lstrip('+') for x in m[2].split(',') if x.strip()]
  if re.match(r'\s+\+?\w+\s*=\s*(?:[A-Z]\w*\{|\[)',line):result['issues'].append({'file':str(path),'line':n,'kind':'constructor-let-needs-annotation'})
  m=re.match(r'  match ([\w ]+):$',line)
  if m:
   indices=[params.index(x) for x in m[1].split() if x in params]
   if indices!=sorted(indices):result['issues'].append({'file':str(path),'line':n,'function':function,'kind':'later-binder-before-earlier-binder'})
(here/'source-preflight.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result));assert not result['issues']
