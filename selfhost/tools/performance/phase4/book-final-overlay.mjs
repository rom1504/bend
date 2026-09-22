// Isolated Bend overlay for exact final-definition selection.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';

const [baselineArgument, outputArgument] = process.argv.slice(2);
if (!outputArgument) throw Error('Usage: book-final-overlay.mjs BASELINE NEW_OVERLAY');
const baseline = fs.realpathSync(baselineArgument), out = path.resolve(outputArgument);
fs.mkdirSync(out, {recursive: false});
function write(relative, transform) {
  const before = fs.readFileSync(path.join(baseline, relative), 'utf8');
  const after = transform(before);
  assert.notEqual(after, before);
  const destination = path.join(out, relative); fs.mkdirSync(path.dirname(destination), {recursive: true});
  fs.writeFileSync(destination, after);
}
write('src/core/index.bend', text => text + `

# Exact final-definition selection. Short event lists use the original scan.
# Marker values distinguish even the empty name from an unsuccessful lookup.
law book_final_fast:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

law book_final_names_valid:
  for +book: List<&2,KDef>
  Bool

law book_final_name_valid:
  for +name: String
  Bool

law book_final_large:
  for +book: List<&2,KDef>
  for +remaining: U32
  Bool

law book_final_reverse:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

law book_final_scan:
  for +book: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

law book_final_step:
  for +d: KDef
  for +rest: List<&2,KDef>
  for +seen: KDef
  for +kept: List<&2,KDef>
  for +done: List<&2,KDef>
  for +hash: U32
  List<&2,KDef>

law book_final_filter:
  for +done: List<&2,KDef>
  for +seen: KDef
  List<&2,KDef>

law book_final_seen:
  for +seen: KDef
  for +name: String
  for +hash: U32
  Bool

law book_final_legacy:
  for +book: List<&2,KDef>
  for +done: List<&2,KDef>
  List<&2,KDef>

@unsafe
def book_final_large(book, remaining):
  match book:
    case Nil{}: U32.is_eq(remaining, 0)
    case Con{h, rest}:
      kc(Bool, U32.is_eq(remaining, 0), u => True{}, u => book_final_large(rest, U32.sub(remaining, 1)))

# Malformed raw JavaScript names retain the legacy comparison demand order.
# Projection and Char.to_u32 do not throw on surrogate codepoints; only the
# unchanged legacy comparisons decide whether such input must fail.
@unsafe
def book_final_name_valid(name):
  match name:
    case SNil{}: True{}
    case SCon{h, rest}:
      kc(Bool, U32.is_le(U32.sub(Char.to_u32(h), 55296), 2047),
        u => False{}, u => book_final_name_valid(rest))

@unsafe
def book_final_names_valid(book):
  match book:
    case Nil{}: True{}
    case Con{d, rest}:
      kc(Bool, book_final_name_valid(dn(d)),
        u => book_final_names_valid(rest), u => False{})

@unsafe
def book_final_fast(book, done):
  kc(List<&2,KDef>, book_final_large(book, 256),
    u => kc(List<&2,KDef>, book_final_names_valid(book),
      u => kc(List<&2,KDef>, book_final_names_valid(done),
        u => book_final_scan(book_final_reverse(book, Nil{}), missing(), Nil{}, done),
        u => book_final_legacy(book, done)),
      u => book_final_legacy(book, done)),
    u => book_final_legacy(book, done))

@unsafe
def book_final_reverse(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_reverse(rest, Con{d, done})

@unsafe
def book_final_seen(seen, name, hash):
  String.eq(dk(index_find(seen, name, hash, 32)), "$final.seen")

@unsafe
def book_final_scan(book, seen, kept, done):
  match book:
    case Nil{}: book_final_reverse(kept, book_final_filter(done, seen))
    case Con{d, rest}:
      book_final_step(d, rest, seen, kept, done, index_hash(dn(d), 2166136261))

@unsafe
def book_final_step(d, rest, seen, kept, done, hash):
  kc(List<&2,KDef>, book_final_seen(seen, dn(d), hash),
    u => book_final_scan(rest, seen, kept, done),
    u => book_final_scan(rest,
      index_set(seen, KDef{dn(d), "$final.seen", 0, 0, atom("Absent"), atom("Absent"), Nil{}, True{}, False{}}, hash, 32),
      Con{d, kept}, done))

@unsafe
def book_final_filter(done, seen):
  match done:
    case Nil{}: Nil{}
    case Con{d, rest}:
      kc(List<&2,KDef>, book_final_seen(seen, dn(d), index_hash(dn(d), 2166136261)),
        u => book_final_filter(rest, seen),
        u => Con{d, book_final_filter(rest, seen)})

@unsafe
def book_final_legacy(book, done):
  match book:
    case Nil{}: done
    case Con{d, rest}: book_final_legacy(rest, Con{d, book_without(done, dn(d))})
`);
write('src/driver/api.bend', text => {
  const before = 'def driver_final(book, done):\n  match book:\n    case Nil{}: done\n    case Con{d, rest}: driver_final(rest, Con{d, book_without(done, dn(d))})';
  assert.equal(text.split(before).length, 2);
  return text.replace(before, 'def driver_final(book, done):\n  book_final_fast(book, done)');
});
write('src/check/specialize.bend', text => {
  const before = 'def sp_canonical(book, done):\n  match book:\n    case Nil{}:\n      done\n    case Con{h, rest}:\n      sp_canonical(rest, Con{h, book_without(done, dn(h))})';
  assert.equal(text.split(before).length, 2);
  return text.replace(before, 'def sp_canonical(book, done):\n  book_final_fast(book, done)');
});
console.log(JSON.stringify({baseline, overlay: out}));
