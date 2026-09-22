// Disposable private-image experiment. Never use for public library emission.
// The private compiler constructs term tags and definition kinds from valid text;
// no raw graphs or JavaScript callbacks cross its inspect request boundary.
import {tokenizeGeneratedDefinition as tokenize} from '../rapid/direct-calls.mjs';

function globalCall(tokens, at) {
  if (!['call', 'jump'].includes(tokens[at]?.text)) return null;
  if (tokens.slice(at + 1, at + 6).map(x => x.text).join(' ') !== '( get ( G ,') return null;
  if (tokens[at + 7]?.text !== ')' || tokens[at + 8]?.text !== ',' || tokens[at + 9]?.text !== '[') return null;
  let name;
  try { name = JSON.parse(tokens[at + 6].text); } catch { return null; }
  const close = tokens[at + 9].close, end = tokens[at + 1].close;
  if (close + 1 !== end) return null;
  const args = [];
  for (let next = at + 10; next < close;) {
    const start = next;
    if (tokens[next].text === '.') return null;
    while (next < close && tokens[next].text !== ',') next = tokens[next].close === undefined ? next + 1 : tokens[next].close + 1;
    args.push({start, end: next - 1});
    if (next < close) next++;
  }
  return {name, kind: tokens[at].text, at, end, args};
}

export function transformPrivateTagComparisons(source) {
  if (source.includes('privateTagComparisonMarker')) throw Error('Tag comparison transform already applied');
  for (const [name, ctor, slot] of [['tg', 'KTerm', 0], ['dk', 'KDef', 1]]) {
    const expected = `G[${JSON.stringify(name)}]=fn(1,function(a){return project(${JSON.stringify(ctor)},a[0]).slice()[${slot}];});`;
    const lines = source.split('\n').filter(line => line.startsWith(`G[${JSON.stringify(name)}]=`));
    if (lines.length !== 1 || lines[0] !== expected) throw Error('Unknown tag accessor: ' + name);
  }
  if (source.split("native('String.eq',2,stringEq);").length !== 2 || /^G\["String.eq"\]=/m.test(source)) throw Error('Unknown or overridden String.eq');
  const stats = {calls: 0, tails: 0, byAccessor: {}, byLiteral: {}, requiresPrivateBoundary: true};
  const result = source.split('\n').map(line => {
    if (!/^G\["(?:\\.|[^"\\])*"\]=(?:fn\(\d+,function\(|matcher(?:1)?\()/.test(line)) return line;
    const tokens = tokenize(line), edits = [];
    for (let at = 0; at < tokens.length; at++) {
      const outer = globalCall(tokens, at);
      if (!outer || outer.name !== 'String.eq' || outer.args.length !== 2) continue;
      let match;
      for (let side = 0; side < 2 && !match; side++) {
        const arg = outer.args[side], literal = outer.args[1 - side];
        if (literal.start !== literal.end) continue;
        let text;
        try { text = JSON.parse(tokens[literal.start].text); } catch { continue; }
        if (typeof text !== 'string' || !text.isWellFormed()) continue;
        const selector = globalCall(tokens, arg.start);
        if (!selector || selector.kind !== 'call' || selector.end !== arg.end || selector.args.length !== 1 || !['tg', 'dk'].includes(selector.name)) continue;
        const value = selector.args[0];
        match = {name: selector.name, text, expression: line.slice(tokens[value.start].start, tokens[value.end].end)};
      }
      if (!match) continue;
      // Only one nonliteral expression remains, evaluated once in the same order.
      edits.push({start: tokens[at].start, end: tokens[outer.end].end, text: `((${match.expression}).a[${match.name === 'tg' ? 0 : 1}]===${JSON.stringify(match.text)})`});
      stats[outer.kind === 'call' ? 'calls' : 'tails']++;
      stats.byAccessor[match.name] = (stats.byAccessor[match.name] ?? 0) + 1;
      stats.byLiteral[match.text] = (stats.byLiteral[match.text] ?? 0) + 1;
      at = outer.end;
    }
    for (const edit of edits.reverse()) line = line.slice(0, edit.start) + edit.text + line.slice(edit.end);
    return line;
  }).join('\n');
  if (!stats.calls) throw Error('No private tag comparisons found');
  return {source: result + '\n// privateTagComparisonMarker: experimental private compiler image only.\n', stats};
}
