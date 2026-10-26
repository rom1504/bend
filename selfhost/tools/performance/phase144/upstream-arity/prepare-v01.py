#!/usr/bin/env python3
"""Create a pinned upstream diagnostic copy; execute no compiler or target."""
import argparse, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
P=Path(__file__).resolve().parent

def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--source',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();source=a.source.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase144') and not out.exists()
upstream=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2'
manifest=json.loads((ROOT/'selfhost/build/phase86/upstream.json').read_text())
assert manifest['revision']=='059266225b77c8ca256ac6b25ee5c21449bab151'
for item in manifest['inputs']: assert pin(item['file'])==item
original=upstream/'comp.ts';before=original.read_text()
assert pin(original)['sha256']=='2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c'
old_import='import * as Bend from "./bend.ts";'
new_import='import * as Bend from '+json.dumps((upstream/'bend.ts').as_uri())+';'
old_error='    die("an arity over " + WIDE);'
new_error='''    die("an arity over " + WIDE + "\\nP144_ARITY=" + JSON.stringify((() => {
      const bad = entries.filter((s) => s.params.length > WIDE);
      const describe = (s: Seg) => {
        const owner = s.def.split("$")[0];
        const fun = FL.funs.get(owner);
        return { fid: s.fid, def: s.def, sourceOwner: Bend.name_key(owner),
          paramsWords: s.params.length, resultWords: s.ret.ks.length,
          frame: s.frame, fork: s.fork ?? false,
          kinds: s.ks.reduce((m, k) => { m[k] = (m[k] ?? 0) + 1; return m; }, {} as Record<string, number>),
          parameters: s.params.map((name, i) => ({ index: i, name, kind: s.ks[i] })),
          sourceDeclaredArguments: FL.book.tlds[owner]?.n ?? null,
          cachedArgumentLayouts: fun?.lays.map((l) => l.ks.length) ?? null,
          cachedResultWords: fun?.ret.ks.length ?? null };
      };
      return { kind: "phase144-upstream-live-arity-refusal", limit: WIDE,
        liveEntryCount: entries.length, oversizedEntryCount: bad.length,
        oversizedEntries: bad.slice(0, 32).map(describe), omittedOversizedEntries: Math.max(0, bad.length - 32),
        largestEntries: [...entries].sort((a,b) => b.params.length - a.params.length).slice(0, 10).map(describe),
        oversizedConstructors: [...cids].flatMap(([name, words]) => {
          const encoded = words > WIDE ? 240 + Math.log2(words) : words;
          return encoded > 255 ? [{ name: Bend.name_key(name), words, encoded }] : [];
        }), sourceRoots: FL.srcs.size };
    })()));'''
assert before.count(old_import)==1 and before.count(old_error)==1
after=before.replace(old_import,new_import).replace(old_error,new_error)
assert after.replace(new_error,old_error).replace(new_import,old_import)==before
out.mkdir(parents=True);clone=out/'comp-diagnostic.ts';clone.write_text(after)
report=dict(kind='phase144-upstream-arity-observer-preparation',complete=True,targetsRun=False,
    source=pin(source),original=pin(original),clone=pin(clone),bend=pin(upstream/'bend.ts'),
    upstream=manifest,method=pin(__file__),runner=pin(P/'observe-v01.mjs'),
    host=pin(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'),
    inverseByteIdentical=True,outputDirectory=str(out),
    changes=[dict(kind='absolute-original-module-import',before=old_import,after=new_import),
             dict(kind='failure-message-only',before=old_error,after=new_error)],
    compilerAlgorithmChanged=False,arityLimitChanged=False,emittedSuccessfulCodeChanged=False)
(out/'prepare.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(complete=True,targetsRun=False,manifest=str(out/'prepare.json'),clone=report['clone'])))
