"""Capture-avoiding lexical helper rename; never checks or executes Bend."""
from pathlib import Path
import re,json,hashlib
HERE=Path(__file__).resolve().parent
PAIRS=[('numeric-affine.bend','numeric-orbit.bend'),('affine.bend','orbit.bend')]
TOKEN=re.compile(r'"(?:\\.|[^"\\])*"|\#[^\n]*|[A-Za-z_][A-Za-z_0-9.]*|[^A-Za-z_"#]+|.',re.S)
IDENT=re.compile(r'[A-Za-z_][A-Za-z_0-9.]*\Z')
def pin(p):return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
originals={a:(HERE/a).read_text() for a,b in PAIRS}
identifiers={t for s in originals.values() for t in TOKEN.findall(s) if IDENT.fullmatch(t)}
mapping={t:'x198o_'+t[len('x198a_'):] for t in sorted(identifiers) if t.startswith('x198a_')}
assert mapping and len(set(mapping.values()))==len(mapping) and not(set(mapping.values())&identifiers)
inverse={v:k for k,v in mapping.items()}
def renamed(s,m):return ''.join(m.get(t,t) if IDENT.fullmatch(t) else t for t in TOKEN.findall(s))
r={'kind':'phase198-numeric-global-helper-alpha-bijection','targetsRun':False,'method':pin(Path(__file__)),'mapping':mapping,'files':[],'scope':'Only global helper identifier tokens change; string literals including generated local names, types, comments, operators and all other bytes are unchanged.'}
for a,b in PAIRS:
 old=originals[a];new=renamed(old,mapping);assert renamed(new,inverse)==old
 assert ''.join(TOKEN.findall(old))==old and ''.join(TOKEN.findall(new))==new
 assert not any(t.startswith('x198a_') for t in TOKEN.findall(new) if IDENT.fullmatch(t))
 (HERE/b).write_text(new)
 before=[t for t in TOKEN.findall(old) if not(IDENT.fullmatch(t) and t in mapping)]
 after=[t for t in TOKEN.findall(new) if not(IDENT.fullmatch(t) and t in inverse)]
 assert before==after
 r['files'].append(dict(original=pin(HERE/a),renamed=pin(HERE/b),roundTripExact=True,otherTokensExact=True,occurrences={k:TOKEN.findall(old).count(k) for k in mapping if k in TOKEN.findall(old)}))
declarations=set(re.findall(r'^def (x198a_\w+)\(',originals['affine.bend'],re.M));assert declarations==set(mapping)
r['allHelperDeclarationsCovered']=True;r['helperCount']=len(mapping);r['complete']=True
controlBefore=HERE/'controls-affine.mjs';controlAfter=HERE/'controls-orbit.mjs'
oldControl=controlBefore.read_text();newControl=oldControl.replace('x198a_','x198o_').replace("pin('research/phase198/numeric/controls-affine.mjs')","pin('research/phase198/numeric/controls-orbit.mjs')")
assert oldControl.count("pin('research/phase198/numeric/controls-affine.mjs')")==1
controlAfter.write_text(newControl)
r['controls']={'original':pin(controlBefore),'renamed':pin(controlAfter),'change':'Only helper prefix (zero occurrences here) and the receipt self-method filename. All test inputs, oracles and assertions unchanged.'}
build=HERE.parents[2]/'selfhost/build/phase198'
a=build/'numeric-api-source09/compiler.bend';b=build/'numeric-api-source10/compiler.bend'
if a.exists() and b.exists():
 assert renamed(a.read_text(),mapping)==b.read_text()
 assert renamed(b.read_text(),inverse)==a.read_text()
 r['wholeSourceAlphaExact']=True;r['source09']=pin(a);r['source10']=pin(b)
 beforeExports=json.loads((a.parent/'exports.json').read_text())['exports'];afterExports=json.loads((b.parent/'exports.json').read_text())['exports']
 assert [mapping.get(name,name) for name in beforeExports]==afterExports
 r['exportsAlphaExact']=True
(HERE/'orbit-alpha.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'complete':True,'helpers':len(mapping),'files':len(PAIRS),'wholeSourceAlphaExact':r.get('wholeSourceAlphaExact',False)}))
