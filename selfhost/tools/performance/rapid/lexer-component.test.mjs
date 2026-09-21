// Differential gate for either upstream-emitted components or self-emitted
// whole-compiler capsules. No prototype lexer substitution occurs in this test.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';

const root = path.resolve(import.meta.dirname, '../../..');
const controlPath = path.resolve(process.env.BEND_LEXER_CONTROL || path.join(root, 'dist/phase1/selfhost-api.mjs'));
const candidatePath = process.env.BEND_LEXER_CANDIDATE && path.resolve(process.env.BEND_LEXER_CANDIDATE);
if (!candidatePath) throw Error('Set BEND_LEXER_CANDIDATE to the checked component or compiler capsule');
const load = async file => {
  const module = await import(pathToFileURL(file));
  return {api: {...module.default, ...module.rapidLexerControl}, nil: module.G ? {$: 'Nil', a: []} : {$: 'Nil'}};
};
const control = await load(controlPath), candidate = await load(candidatePath);
const sha = value => createHash('sha256').update(value).digest('hex');
function rows(tokens) {
  const result = [];
  while (tokens.$ === 'Con') {
    const token = tokens.a ? tokens.a[0] : tokens.head;
    result.push(token.a || [token.text, token.f_line, token.f_col, token.f_kind]);
    tokens = tokens.a ? tokens.a[1] : tokens.tail;
  }
  assert.equal(tokens.$, 'Nil'); return result;
}
const capture = (module, source, line = 1, col = 0, depth = 0) => {
  try { return {tokens: rows(module.api.f_lex(source, line, col, depth, module.nil))}; }
  catch (error) { return {error: error.message}; }
};
let compared = 0; const errors = [];
function compare(source, ...state) {
  const expected = capture(control, source, ...state), actual = capture(candidate, source, ...state);
  assert.deepEqual(actual, expected, JSON.stringify(source)); compared++;
  if (expected.error) errors.push({source, error: expected.error});
  return actual;
}
for (const source of ['', '# comment', '# comment\nfoo', 'foo\r\nbar', '  # hi\nfoo', '(\n[{}]\n)\n', ')\nfoo',
  '0n++foo 0n ++foo n+foo n +foo', 'foo>bar foo >bar >> >>> >', '-> => <- ++ <> == != <= >= && || << >> .&. .|. .^. <&>',
  '1e+2 1E-2 fooe+4 fooe+bar 1e+', '"unterminated', '"trailing\\', '"multiline\nstring"\nnext', '"😀é" 😀\né',
  '\0foo', '\v\ffoo', '😀+foo', '\ud800', '\udc00', '"\ud800"', '#\ud800\nfoo', 'a#\ud800', '.&\ud800', '<&\ud800']) compare(source);
compare('foo\n', 0xffffffff, 0xffffffff, 0xffffffff);
const alphabet = ['a', 'E', 'n', '0', '2', ' ', '\n', '\r', '\t', '#', '+', '-', '>', '<', '.', '&', '|', '^', '(', ')', '[', ']', '{', '}', '"', "'", '\\', '😀', 'é', '\0', '\ud800', '\udc00'];
let random = 0x5a17; const next = () => random = (Math.imul(random, 1664525) + 1013904223) >>> 0;
for (let fixture = 0; fixture < 300; fixture++) {
  let source = ''; const length = next() % 80;
  for (let index = 0; index < length; index++) source += alphabet[next() % alphabet.length];
  compare(source);
}
const basePath = path.resolve(process.env.BEND_LEXER_BASE || path.join(root, '.bootstrap/upstream/bend2/base.bend'));
const base = fs.readFileSync(basePath, 'utf8'), baseTokens = compare(base).tokens;
assert(baseTokens, 'Base must tokenize successfully');
let fullBaseParseEqual = null;
if (control.api.f_parse && candidate.api.f_parse) {
  // Whole-compiler capsules share a representation. Cross-backend parser ADTs
  // require ABI conversion, so component tests compare their token rows only.
  assert.deepEqual(candidate.api.f_parse(base), control.api.f_parse(base)); fullBaseParseEqual = true;
}
const report = {kind: 'checked-bend-lexer-component-differential', pass: true, compared, randomCases: 300,
  matchingErrors: errors.length, errors, controlPath, controlSha256: sha(fs.readFileSync(controlPath)),
  candidatePath, candidateSha256: sha(fs.readFileSync(candidatePath)), basePath, baseSha256: sha(base),
  baseTokenCount: baseTokens.length, baseTokensSha256: sha(JSON.stringify(baseTokens)), fullBaseParseEqual};
if (process.env.BEND_LEXER_REPORT) fs.writeFileSync(process.env.BEND_LEXER_REPORT, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({...report, errors: errors.length}));
