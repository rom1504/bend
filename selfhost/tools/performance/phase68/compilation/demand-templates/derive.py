#!/usr/bin/env python3
"""Derive one lazy intrinsic lookup from the existing unique literal catalog."""
import difflib
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
SOURCE = ROOT/'selfhost/src/back/native'


def pin(p):
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def main():
    out = ROOT/'selfhost/build/phase68/demand-templates-proposal01'
    assert not out.exists()
    out.mkdir(parents=True)
    before = {name:(SOURCE/name).read_text() for name in ['intrinsic.bend','direct.bend','bridge.bend']}
    tokens = re.findall(r'ni_Op\{("(?:[^"\\]|\\.)*"), ("(?:[^"\\]|\\.)*")\}', before['intrinsic.bend'])
    pairs = [(json.loads(k),json.loads(v)) for k,v in tokens]
    assert len(pairs) == len({k for k,v in pairs}) == 69 and all(k and v for k,v in pairs)
    old_body = before['intrinsic.bend'].split('def ni_templates() -> List<&2, ni_Op>:\n',1)[1].split('\n\n@unsafe',1)[0]
    reconstructed = '  '+''.join('Con{ni_Op{'+k+', '+v+'}, ' for k,v in tokens)+'Nil{}'+'}'*len(tokens)
    assert old_body == reconstructed, 'Catalog extraction must consume the entire old expression'
    header = ('# Select exactly one immutable template; unknown names have no template.\n'
        '# Empty primitive names are common identity misses and cannot match this catalog.\n'
        '@unsafe\ndef ni_template(+k: String) -> String:\n'
        '  nt_choose(String, String.is_empty(k), u => "", u =>\n')
    chain = ''.join('    nt_choose(String, String.eq(k, '+k+'), u => '+v+', u =>\n' for k,v in tokens)
    header += chain+'      ""'+')'*(len(tokens)+1)+'\n\n'
    after = dict(before)
    after['intrinsic.bend'] = header+before['intrinsic.bend'][before['intrinsic.bend'].index('@unsafe\ndef ni_replace_all('):]
    count = 0
    for name in after:
        after[name], n = re.subn(r'ni_find\((k|name|prim), ni_templates\(\)\)',r'ni_template(\1)',after[name])
        count += n
        assert not re.search(r'\b(?:ni_Op|ni_templates|ni_find)\b',after[name])
    assert count == 4
    files = []
    patch = ''
    for name in before:
        old = out/'before'/name;new = out/'after'/name
        old.parent.mkdir(exist_ok=True);new.parent.mkdir(exist_ok=True)
        old.write_text(before[name]);new.write_text(after[name])
        assert old.read_bytes() == (SOURCE/name).read_bytes()
        patch += ''.join(difflib.unified_diff(before[name].splitlines(True),after[name].splitlines(True),
            fromfile='a/selfhost/src/back/native/'+name,tofile='b/selfhost/src/back/native/'+name))
        files.append(dict(path='selfhost/src/back/native/'+name,before=pin(old),after=pin(new),
            linesBefore=len(before[name].splitlines()),linesAfter=len(after[name].splitlines())))
    patch_file = HERE/'candidate-v1.patch';assert not patch_file.exists();patch_file.write_text(patch)
    data_file = HERE/'catalog-v1.json';assert not data_file.exists()
    data_file.write_text(json.dumps(dict(kind='phase68-intrinsic-catalog-oracle',source=files[0]['before'],
        entries=[dict(name=k,template=v) for k,v in pairs],scope='Historical test oracle derived exactly once; candidate production has one maintained template lookup, not a duplicated catalog.'),indent=2)+'\n')
    meta = dict(kind='phase68-demand-selected-intrinsic-proposal',status='isolated-unselected-unexecuted',
        producer=pin(Path(__file__).resolve()),patch=pin(patch_file),catalog=pin(data_file),files=files,
        replacements=count,templates=69,removedTypes=['ni_Op'],removedDefinitions=['ni_templates','ni_find'],
        newDefinitions=['ni_template'],publicRequestedExportsChanged=False,
        invariant='Each old catalog name occurs once, all69 names and templates are nonempty, ordered exact equality preserves lookup for every String. Empty-key refusal is exact. Template substitution remains unchanged. No host compiler algorithm or mutable cache.')
    meta_file=HERE/'candidate-v1.json';assert not meta_file.exists();meta_file.write_text(json.dumps(meta,indent=2)+'\n')
    print(json.dumps(dict(manifest=pin(meta_file),patch=pin(patch_file),lineDelta=sum(x['linesAfter']-x['linesBefore'] for x in files))))


if __name__=='__main__':
    main()
