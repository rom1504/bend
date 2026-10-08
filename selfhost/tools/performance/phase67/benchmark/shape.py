#!/usr/bin/env python3
"""Count defined textual C patterns; never compiles or interprets generated code."""
import argparse, hashlib, json, re
from pathlib import Path
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
PATTERNS={'segments':r'^\s*WL_CASE\(([^)]+)\)','heapAllocationSyntax':r'\bheap_alloc\s*\(','closureConstructionSyntax':r'\bterm_clo\s*\(','genericClosureTransferSyntax':r'\bWL_JMP\(\s*(?:BEND|FID)_CLO_APPLY\s*\)','continuationAssignmentSyntax':r'\bWL_CONT\s*=','taskNodeSyntax':r'\btask_node\s*\('}
def decode(n):
 return ''.join(chr(int(c))for c in n[4:].strip('_').split('_'))if re.fullmatch(r'FID_(?:[0-9]+_)+',n) else n
p=argparse.ArgumentParser();p.add_argument('--acquired',type=Path,nargs='+',required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();rows=[];inputs=[]
for directory in a.acquired:
 receipt=directory/'report.json';report=json.loads(receipt.read_text());assert report['complete'];inputs.append(pin(receipt))
 for r in report['records']:
  c=Path(r['nativeSource']['path']);assert pin(c)==r['nativeSource'];inputs.append(pin(c));source=c.read_text();text='\n'.join(line for line in source.splitlines() if not line.lstrip().startswith('#'))
  counts={k:len(re.findall(v,text,re.M))for k,v in PATTERNS.items()};segments=re.findall(PATTERNS['segments'],text,re.M);names=[decode(n)for n in segments];targets=set(re.findall(r'\bterm_clo\(\s*([A-Za-z_][A-Za-z_0-9]*)\s*,',text))
  rows.append(dict(case=r['case'],role=r['role'],source=pin(c),lines=source.count('\n'),counts=counts,uniqueSegments=len(set(segments)),privateNativeSegments=sum(n.startswith('native_k_')for n in names),closureTargetsWithSegment=sum(n in targets for n in segments),namedSegments=[n for n in names if not n.startswith('native_k_')],clangWallSeconds=r['toolchain']['wallSeconds']))
result=dict(kind='phase67-native-shape-v1',complete=True,producer=pin(__file__),inputs=inputs,patterns=PATTERNS,scope='Whole C translation unit excluding preprocessor lines. Syntax occurrences include runtime bodies and function declarations; they are not dynamic operation counts, reachable-code proof, or comparable ownership semantics. Segments is WL_CASE declaration count. Private native_k segments include continuations and closures; closureTargetsWithSegment is only syntactic target membership.',rows=rows)
with a.out.open('x')as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps({'output':pin(a.out),'rows':[{k:r[k]for k in ['case','role','counts','privateNativeSegments','closureTargetsWithSegment']}for r in rows]}))
