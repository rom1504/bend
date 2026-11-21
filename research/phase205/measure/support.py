"""Shared metadata and existing measurement methods; importing runs no targets."""
import hashlib,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench as B

def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
P=module('phase200_checkpoint',ROOT/'research/phase200/measure/broad.py');R=P.M.R;S=P.M.S
L=module('phase198_layout',ROOT/'research/phase198/qualification/compare-source-products.py')
import request as NATIVE
CATALOG=R.CATALOG
SUMMARY=ROOT/'research/phase200/measure/recovered-summary01.json'
REFERENCE=ROOT/'selfhost/build/phase198/progress-native-reproduction01/report.json'
SMOKE=['coverage-unicode-text-16','coverage-unicode-text-64','lexer']

def content_pin(path):
 pin=B.pin(path);return {k:pin[k] for k in ('bytes','sha256')}
def checked_bytes(pin):
 B.verify(pin);return Path(pin['file']).read_bytes()
def image_binding(image,receipt,source=None):
 doc=B.read(receipt);assert len(doc.get('runs',[]))==1,'One saved replay image per receipt required'
 row=doc['runs'][0];assert isinstance(row['complete'],(int,float)) and row['complete']>0 and len(row['elfSha256'])==64
 source=Path(source or doc['source']);src=B.pin(source);assert src['sha256']==doc['sourceSha256']
 return dict(gzip=B.pin(image),receipt=B.pin(receipt),source=src,elfSha256=row['elfSha256'],producerRuntimeSha256=doc.get('productRuntimeSha256'),acquisitionFormat='phase201-cold-replay-saved-gzip')
def c_reference():
 s=B.read(SUMMARY);m=B.read(s['references']['file']);B.verify(s['references']);assert s['completeObservedEvidence'] and s['oracleRevalidated']['samples']==405
 cases={c['id']:c for c in m['cases']};observed={c['id']:c for c in s['cases']}
 for name,c in cases.items():assert c['products']['c']['artifact']==observed[name]['artifacts']['c']
 return s,m,cases
