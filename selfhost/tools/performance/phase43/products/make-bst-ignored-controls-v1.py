from pathlib import Path
import json,hashlib,sys
base=Path(__file__).resolve().parent;parent=base/'fixtures/prefix-controls.bend';s=parent.read_text().split('# Scalar Nat result stays')[0];old='case (BLeaf{}, path):\n      (BLeaf{}, path)';assert s.count(old)==1;s=s.replace(old,'case (BLeaf{}, path):\n      (BLeaf{}, Nil{})').replace('#|12589','#|9');s='# Independent ignored-pair derivative: leaf branch discards both old fields.\n'+s
p=base/'fixtures/pair-bst-ignored-controls-v1.bend';assert not p.exists();p.write_text(s);src=p.read_bytes();cases=[]
for n,seed in [(0,0),(1,0),(1,17),(7,17),(32,0),(64,17),(16,4294967295)]:
 expected=0 if not n else((((((n-1)*((seed*2+1)&0xffffffff))&0xffffffff)+seed)&0xffffffff)%257)
 case=dict(id=f'products-bst-ignored-{n}-{seed}',family='products-pair-ignored',category='diagnostic',partition='development',description='Known active BST component topology with leaf branch ignoring both old pair fields')
 case['source']=dict(path='fixtures/'+p.name,sha256=hashlib.sha256(src).hexdigest(),bytes=len(src),provenance=dict(kind='phase43-independent-bst-pair-ignored-derivative',parentSourceSha256=hashlib.sha256(parent.read_bytes()).hexdigest(),design='design/phase43/products.md'))
 case.update(point=dict(exportName='bench',args=[n,seed],expected=expected),sets=['fast','core','broad','full'],oracle='Independent Python modular last-key formula; leaf path reset makes each insertion final singleton');cases.append(case)
r=dict(schemaVersion=1,upstreamCommit='018751270e800bc222a93dad7f257083ee53a5f7',cases=cases,sets={k:[c['id']for c in cases]for k in ['fast','core','broad','full']},scope='Independent active-shape ignored-pair semantic control, no timing evidence',oracleProducer=dict(path='make-bst-ignored-controls-v1.py',sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()))
cat=base/'pair-bst-ignored-catalog-v1.json';assert not cat.exists();cat.write_text(json.dumps(r,indent=2)+'\n')
sys.path.insert(0,str(base.parents[1]/'programs'))
from prepare import select,checked_source
for c in select(r,'full',None):checked_source(c,cat)
print(cat,len(cases),'selector/hash PASS')
