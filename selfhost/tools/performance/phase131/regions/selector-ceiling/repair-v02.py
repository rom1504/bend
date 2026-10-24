"""Retain initial failed extraction, add three exact required source laws."""
from pathlib import Path
import json,re,hashlib
H=Path(__file__).resolve().parent;R=H.parents[5];S=R/'selfhost/build/phase131/combined-literals-source01/compiler.bend'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
s=S.read_text();laws=[re.search(r'^law '+n+r':\n(?:  .*\n)+',s,re.M)[0]for n in ['index_first','index_child_list','index_bucket']];rows=[]
for file in ['cases.json','cases-short.json']:
 for row in json.loads((H/file).read_text())['cases']:
  original=Path(row['source']['file']);text=original.read_text();marker='def p88_string_eq_go(';assert text.count(marker)==1
  repaired=H/(original.stem+'-v02.bend');repaired.write_text(text.replace(marker,'\n'.join(laws)+'\n'+marker));rows.append(dict(row,source=pin(repaired)))
(H/'cases-v02.json').write_text(json.dumps(dict(complete=True,cases=rows),indent=2)+'\n')
(H/'repair-v02.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(S),pin(__file__),pin(H/'cases.json'),pin(H/'cases-short.json')],laws=laws,cases=rows,scope='Three original law signatures omitted by initial extraction. All original function bodies, scalar fusion and independently frozen outputs unchanged. Initial parser refusal retained.'),indent=2)+'\n')
