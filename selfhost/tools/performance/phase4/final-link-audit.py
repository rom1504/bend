import pathlib,re,urllib.parse,json,datetime,hashlib,sys
root=pathlib.Path.cwd()
paths=[root/'README.md',root/'selfhost/README.md',root/'docs/PHASE4_DEVELOPMENT.md',*sorted((root/'design/phase4').rglob('*.md')),*sorted((root/'implementation/phase4').rglob('*.md')),*sorted((root/'experiments').glob('*.md')),*sorted((root/'experiments/phase4').rglob('*.md'))]
seen=set();files=[];links=[];broken=[]
for p in paths:
 if p in seen:continue
 seen.add(p)
 if not p.exists():broken.append({'file':str(p.relative_to(root)),'missingDocument':True});continue
 text=p.read_text();files.append({'file':str(p.relative_to(root)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()});fence=None
 for number,line in enumerate(text.splitlines(),1):
  f=re.match(r'^\s*(`{3,}|~{3,})',line)
  if f:
   if fence is None:fence=f[1][0]
   elif f[1][0]==fence:fence=None
   continue
  if fence is not None:continue
  # Do not treat documentation examples inside inline code as live links.
  line=re.sub(r'(`+).*?\1','',line)
  targets=[m.group(1) for m in re.finditer(r'!?\[[^\]]*\]\((<[^>]+>|[^)\n]+)\)',line)]
  ref=re.match(r'^\s{0,3}\[[^\]]+\]:\s*(<[^>]+>|\S+)',line)
  if ref:targets.append(ref[1])
  for target in targets:
   target=target.strip()
   if target.startswith('<'):target=target[1:target.index('>')]
   else:target=re.split(r'\s+["\']',target,maxsplit=1)[0]
   parsed=urllib.parse.urlsplit(target)
   if parsed.scheme or parsed.netloc or not parsed.path:continue
   local=urllib.parse.unquote(parsed.path)
   if any(x in local for x in ['{','}','<','>']):continue
   resolved=(root/local.lstrip('/') if local.startswith('/') else p.parent/local).resolve()
   item={'file':str(p.relative_to(root)),'line':number,'target':target,'resolved':str(resolved),'exists':resolved.exists()};links.append(item)
   if not item['exists']:broken.append(item)
report={'kind':'phase4-markdown-local-link-audit','complete':True,'created':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Read-only actual local file/directory targets. Fenced and inline code examples, external URLs, empty paths and anchor-only destinations excluded; anchors are not validated.','files':files,'linksChecked':len(links),'links':links,'broken':broken}
pathlib.Path(sys.argv[1]).write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'files':len(files),'linksChecked':len(links),'broken':broken},indent=2))
