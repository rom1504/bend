#!/usr/bin/env python3
"""Check local inline Markdown file targets in the final release document scope."""
import datetime, hashlib, json, pathlib, re, subprocess, sys
from urllib.parse import unquote
root=pathlib.Path(__file__).resolve().parents[3]
out=pathlib.Path(sys.argv[1]) if len(sys.argv)>1 else root/'implementation/phase5/release-doc-evidence/links.json'
names=set(subprocess.check_output(['git','diff','--name-only','d5a7bd8'],cwd=root,text=True).splitlines())
names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=root,text=True).splitlines())
names.update(['README.md','selfhost/README.md','docs/BEND-IN-BEND.md','docs/PHASE5_DEVELOPMENT.md','selfhost/CONFORMANCE.md','experiments/STEERING.md','experiments/PRESERVATION.md'])
files=[];targets=[];missing=[]
for name in sorted(names):
 p=root/name
 if p.suffix!='.md' or not p.is_file():continue
 data=p.read_bytes(); text=data.decode()
 files.append({'path':name,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)})
 # This audit covers inline Markdown links, not HTML, reference links or anchors.
 clean=re.sub(r'^```.*?^```[^\n]*$', '', text, flags=re.M|re.S)
 for match in re.finditer(r'!?\[[^\]\n]*\]\(([^\n]+?)\)',clean):
  value=match.group(1).strip()
  if value.startswith('<') and '>' in value:value=value[1:value.index('>')]
  else:value=value.split(' "')[0].split(" '")[0]
  if re.match(r'^[A-Za-z][A-Za-z0-9+.-]*:',value) or value.startswith('#'):continue
  value=unquote(value.split('#',1)[0].split('?',1)[0])
  if not value:continue
  target=(p.parent/value).resolve();exists=target.exists()
  row={'document':name,'target':value,'exists':exists}
  targets.append(row)
  if not exists:missing.append(row)
report={'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Current Markdown changed since d5a7bd8, untracked Markdown, and named user-facing release entry points; inline local file/directory targets only. Anchor, HTML and remote URL validity are outside scope.','scriptSha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'documents':files,'targets':targets,'missing':missing,'complete':True,'pass':not missing}
out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'documents':len(files),'targets':len(targets),'missing':missing,'output':str(out)}))
raise SystemExit(bool(missing))
