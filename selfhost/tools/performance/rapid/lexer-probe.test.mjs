import test from 'node:test';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
import {installLexerExperiment, tokenRows} from './lexer-probe.mjs';

const apiPath = process.env.BEND_LEXER_PROBE_API || path.resolve(import.meta.dirname, '../../../dist/phase1/selfhost-api.mjs');
const module = await import(pathToFileURL(apiPath));
const capture = callback => { try { return {tokens: tokenRows(callback())}; } catch (error) { return {error: error.message}; } };
const run = (source, line = 1, col = 0, depth = 0, previous = []) => module.default.f_lex(source, line, col, depth, module.list(previous.map(row => module.ctor('FToken', row))));
const compare = (source, ...state) => {
  const expected = capture(() => run(source, ...state));
  for (const variant of ['direct-head-tail', 'cursor']) {
    const restore = installLexerExperiment(module, variant);
    try { assert.deepEqual(capture(() => run(source, ...state)), expected, `${variant}: ${JSON.stringify(source)}`); }
    finally { restore(); }
  }
};

test('token text, kind and positions match across lexical boundary cases', () => {
  for (const source of ['', '# comment', '# comment\nfoo', 'foo\r\nbar', '  # hi\nfoo', '(\n[{}]\n)\n', ')\nfoo', '0n++foo 0n ++foo n+foo n +foo', 'foo>bar foo >bar >> >>> >', '-> => <- ++ <> == != <= >= && || << >> .&. .|. .^. <&>', '1e+2 1E-2 fooe+4 fooe+bar 1e+', '"hi\\\"there"', "'\\\\'", '"unterminated', '"trailing\\', '"multiline\nstring"\nnext', '"😀é" 😀\né', '\0foo', '\v\ffoo', '😀+foo', '"\\😀"', '\ud800', '\udc00', '"\ud800"', '#\ud800\nfoo']) compare(source);
  compare('foo\n', 0xffffffff, 0xffffffff, 0xffffffff);
  compare('++x >', 2, 3, 0, [['1n', 2, 1, 1], ['older', 1, 0, 1]]);
});

test('deterministic mixed-input differential fuzz', () => {
  const alphabet = ['a', 'E', 'n', '0', '2', ' ', '\n', '\r', '\t', '#', '+', '-', '>', '<', '.', '&', '|', '^', '(', ')', '[', ']', '{', '}', '"', "'", '\\', '😀', 'é', '\0'];
  let random = 0x5a17;
  const next = () => { random = (Math.imul(random, 1664525) + 1013904223) >>> 0; return random; };
  for (let fixture = 0; fixture < 300; fixture++) {
    let source = ''; const length = next() % 80;
    for (let index = 0; index < length; index++) source += alphabet[next() % alphabet.length];
    compare(source);
  }
});

test('malformed UTF-16 preserves original failures through explicit fallback', () => {
  const counters = {};
  const restore = installLexerExperiment(module, 'cursor', counters);
  try { capture(() => run('\ud800')); assert.equal(counters.malformedFallbacks, 1); }
  finally { restore(); }
});

test('worker overrides restore after use and do not mutate original worker', () => {
  const before = module.G.f_lex;
  const restore = installLexerExperiment(module, 'cursor');
  assert.notEqual(module.G.f_lex, before);
  restore(); assert.equal(module.G.f_lex, before);
});
