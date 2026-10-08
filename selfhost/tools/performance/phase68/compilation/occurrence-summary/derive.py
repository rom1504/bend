#!/usr/bin/env python3
"""Stage the pure-Bend occurrence summary; never edit production source."""
import ast
import difflib
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
SOURCE = ROOT/'selfhost/src/back/native/bridge.bend'
OUT = ROOT/'selfhost/build/phase68/occurrence-summary-proposal01'
assert not OUT.exists()
before = SOURCE.read_text()
after = before
edits = []


def edit(old, new):
    global after
    assert after.count(old) == 1, old
    after = after.replace(old, new)
    edits.append(dict(before=old, after=new))


edit('type NC_Code is Data:', '''# Ordered output rows remain independent of the occurrence-ID set.
type NC_EnvPartition is Data:
  NC_EnvPartition{+live: List<&2, NC_Binding>, +drop: String}

type NC_Code is Data:''')

marker = '''@unsafe
def nc_live_env(env: List<&2, NC_Binding>, +t: KTerm) -> List<&2, NC_Binding>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word}, +rest}:
      nt_choose(List<&2, NC_Binding>, nc_occurs(t, id), u => Con{NC_Binding{id, word}, nc_live_env(rest, t)}, u => nc_live_env(rest, t))'''
edit(marker, '''# Full U32 IDs are explicit trie keys; the payload name is constant.
# Var is a leaf, including malformed raw terms with Var children.
@unsafe
def nc_uses_term(+t: KTerm, +uses: KDef, +mark: KDef) -> KDef:
  nt_choose(KDef, String.eq(tg(t), "Var"),
    u => index_set(uses, mark, ix(t), 32),
    u => nc_uses_list(ks(t), uses, mark))

@unsafe
def nc_uses_list(+ts: List<&2, KTerm>, +uses: KDef, +mark: KDef) -> KDef:
  match ts:
    case Nil{}: uses
    case Con{h, rest}: nc_uses_list(rest, nc_uses_term(h, uses, mark), mark)

@unsafe
def nc_uses(+t: KTerm) -> KDef:
  nc_uses_term(t, missing(), KDef{"$native.occurrence", "Occurrence", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}})

@unsafe
def nc_uses_has(+uses: KDef, +id: U32) -> Bool:
  String.eq(dn(index_find(uses, "$native.occurrence", id, 32)), "$native.occurrence")

@unsafe
def nc_live_uses(env: List<&2, NC_Binding>, +uses: KDef) -> List<&2, NC_Binding>:
  match env:
    case Nil{}: Nil{}
    case Con{NC_Binding{+id, +word}, +rest}:
      nt_choose(List<&2, NC_Binding>, nc_uses_has(uses, id), u => Con{NC_Binding{id, word}, nc_live_uses(rest, uses)}, u => nc_live_uses(rest, uses))

@unsafe
def nc_live_env(env: List<&2, NC_Binding>, +t: KTerm) -> List<&2, NC_Binding>:
  match env:
    case Nil{}: Nil{}
    case Con{h, rest}: nc_live_uses(Con{h, rest}, nc_uses(t))

@unsafe
def nc_partition_step(+id: U32, +word: String, +live: Bool, +more: NC_EnvPartition) -> NC_EnvPartition:
  match more:
    case NC_EnvPartition{+env, +drop}:
      nt_choose(NC_EnvPartition, live,
        u => NC_EnvPartition{Con{NC_Binding{id, word}, env}, drop},
        u => NC_EnvPartition{env, "term_sink(e, " ++ word ++ ");\\n" ++ drop})

@unsafe
def nc_partition_uses(env: List<&2, NC_Binding>, +uses: KDef) -> NC_EnvPartition:
  match env:
    case Nil{}: NC_EnvPartition{Nil{}, ""}
    case Con{NC_Binding{id, word}, rest}:
      nc_partition_step(id, word, nc_uses_has(uses, id), nc_partition_uses(rest, uses))

@unsafe
def nc_prepare_env(env: List<&2, NC_Binding>, +t: KTerm) -> NC_EnvPartition:
  match env:
    case Nil{}: NC_EnvPartition{Nil{}, ""}
    case Con{h, rest}: nc_partition_uses(Con{h, rest}, nc_uses(t))''')

edit('''@unsafe
def nc_drop_dead(env: List<&2, NC_Binding>, +t: KTerm) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{+id, +word}, rest}:
      nt_choose(String, nc_occurs(t, id), u => "", u => "term_sink(e, " ++ word ++ ");\\n") ++ nc_drop_dead(rest, t)

@unsafe
def nc_share_env(env: List<&2, NC_Binding>, +a: KTerm, +b: KTerm) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{+id, +word}, rest}:
      nt_choose(String, nc_occurs(a, id) && nc_occurs(b, id), u => word ++ " = term_keep(e, " ++ word ++ ");\\n", u => "") ++ nc_share_env(rest, a, b)''', '''@unsafe
def nc_partition_drop(+parts: NC_EnvPartition) -> String:
  match parts:
    case NC_EnvPartition{live, drop}: drop

@unsafe
def nc_drop_dead(env: List<&2, NC_Binding>, +t: KTerm) -> String:
  nc_partition_drop(nc_prepare_env(env, t))

@unsafe
def nc_keep_uses(env: List<&2, NC_Binding>, +uses: KDef) -> String:
  match env:
    case Nil{}: ""
    case Con{NC_Binding{+id, +word}, rest}:
      nt_choose(String, nc_uses_has(uses, id), u => word ++ " = term_keep(e, " ++ word ++ ");\\n", u => "") ++ nc_keep_uses(rest, uses)

@unsafe
def nc_share_used(env: List<&2, NC_Binding>, +b: KTerm) -> String:
  match env:
    case Nil{}: ""
    case Con{h, rest}: nc_keep_uses(Con{h, rest}, nc_uses(b))

@unsafe
def nc_share_env(env: List<&2, NC_Binding>, +a: KTerm, +b: KTerm) -> String:
  nc_share_used(nc_live_env(env, a), b)''')

edit('''  nc_prepend(nc_drop_dead(env, t), nc_lower_live_to(book, t, nc_live_env(env, t), n, target))''', '''  nc_lower_partition(book, t, n, target, nc_prepare_env(env, t))

@unsafe
def nc_lower_partition(+book: List<&2, KDef>, +t: KTerm, +n: U32, +target: NC_Target, +parts: NC_EnvPartition) -> NC_Code:
  match parts:
    case NC_EnvPartition{live, drop}: nc_prepend(drop, nc_lower_live_to(book, t, live, n, target))''')


def pin(p):
    p = p.resolve(); b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


OUT.mkdir(parents=True)
old, new = OUT/'before.bend', OUT/'after.bend'
old.write_text(before); new.write_text(after)
patch = HERE/'candidate-v1.patch'
assert not patch.exists()
patch.write_text(''.join(difflib.unified_diff(before.splitlines(True), after.splitlines(True),
    fromfile='a/selfhost/src/back/native/bridge.bend', tofile='b/selfhost/src/back/native/bridge.bend')))
manifest = dict(kind='phase68-occurrence-summary-proposal', status='isolated-unselected-unexecuted',
    producer=pin(Path(__file__)), source=pin(SOURCE), before=pin(old), after=pin(new),
    patch=pin(patch), edits=edits, lineDelta=len(after.splitlines())-len(before.splitlines()),
    invariant='Exact Var-as-leaf occurrence semantics and ordered duplicate-preserving environment decisions. Full U32 IDs reuse the existing compressed index. No NC_Code or public/cache ABI change.')
path = HERE/'candidate-v1.json'
assert not path.exists(); path.write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(dict(manifest=pin(path), patch=pin(patch), lineDelta=manifest['lineDelta'])))
