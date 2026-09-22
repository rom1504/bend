// Private compiler experiment: eliminate intermediate *partial* applications.
// No function body may execute before the final argument segment in a chain.
import {tokenize} from '../../private-compiler/tokens.mjs';
import {specializeCompiler} from '../../private-compiler/transform.mjs';
import {primitiveExpressions, assertRuntime} from '../../private-compiler/primitives.mjs';

export function flattenKnownPartialCalls(source, arities) {
  const stats = {chains: 0, partialApplications: 0, byName: {}};
  function rewrite(text) {
    const tokens = tokenize(text), edits = [];
    const token = i => tokens[i]?.text;
    function argumentsAt(open) {
      if (token(open) !== '[') return null;
      const end = tokens[open].close, args = [];
      let i = open + 1;
      while (i < end) {
        const start = i;
        if (token(i) === '.' && token(i + 1) === '.') return null;
        while (i < end && token(i) !== ',') i = tokens[i].close === undefined ? i + 1 : tokens[i].close + 1;
        if (i === start) return null;
        args.push(text.slice(tokens[start].start, tokens[i - 1].end));
        if (i < end) i++;
      }
      return {args, end};
    }
    function chainAt(i) {
      const method = token(i);
      if (token(i - 1) === '.' || token(i - 1) === '?.') return null;
      if (!['call', 'jump'].includes(method) || token(i + 1) !== '(') return null;
      const end = tokens[i + 1].close, first = i + 2;
      let name, segments, functionEnd;
      if (token(first) === 'call') {
        const inner = chainAt(first);
        if (!inner || inner.method !== 'call') return null;
        ({name, segments, end: functionEnd} = inner);
      } else {
        if (tokens.slice(first, first + 4).map(t => t.text).join(' ') !== 'get ( G ,') return null;
        if (token(first + 5) !== ')' || tokens[first + 1].close !== first + 5) return null;
        try { name = JSON.parse(token(first + 4)); } catch { return null; }
        if (!arities.has(name)) return null;
        segments = []; functionEnd = first + 5;
      }
      if (token(functionEnd + 1) !== ',') return null;
      const pack = argumentsAt(functionEnd + 2);
      if (!pack || pack.end + 1 !== end) return null;
      return {name, segments: [...segments, pack.args], end, method};
    }
    for (let i = 0; i < tokens.length; i++) {
      const chain = chainAt(i);
      if (!chain || chain.segments.length < 2) continue;
      const arity = arities.get(chain.name);
      let count = 0, safe = true;
      chain.segments.forEach((segment, index) => {
        count += segment.length;
        if (!segment.length || (index < chain.segments.length - 1 && count >= arity)) safe = false;
      });
      if (!safe || count !== arity) continue;
      const args = chain.segments.flat().map(rewrite);
      edits.push({start: tokens[i].start, end: tokens[chain.end].end,
        text: `${chain.method}(get(G,${JSON.stringify(chain.name)}),[${args.join(',')}])`});
      stats.chains++; stats.partialApplications += chain.segments.length - 1;
      stats.byName[chain.name] = (stats.byName[chain.name] ?? 0) + 1;
      i = chain.end;
    }
    for (const edit of edits.reverse()) text = text.slice(0, edit.start) + edit.text + text.slice(edit.end);
    return text;
  }
  // Runtime code, source strings and eager initializer behavior remain intact.
  const transformed = source.split('\n').map(line => /^G\["(?:\\.|[^"\\])*"\]=(?:fn\(\d+,function\(|matcher(?:1)?\()/.test(line) ? rewrite(line) : line).join('\n');
  return {source: transformed, stats};
}

export function privateUncurry(source, exports) {
  if (source.includes('privateImageMarker')) throw Error('Expected original checked self-emitted compiler');
  assertRuntime(source);
  const bools = "native('Bool.not',1,x=>!x);native('Bool.and',2,(a,b)=>a&&b);";
  if (!source.includes(bools)) throw Error('Unreviewed Boolean primitives');
  const declaredNames = [...source.matchAll(/^G\[("(?:\\.|[^"\\])*")\]=/gm)].map(m => JSON.parse(m[1]));
  const declarations = new Set(declaredNames);
  if (declarations.size !== declaredNames.length) throw Error('Duplicate generated globals invalidate static arities');
  const arities = new Map();
  for (const match of source.matchAll(/^G\[("(?:\\.|[^"\\])*")\]=fn\((\d+),function\(a\)\{/gm)) {
    const arity = Number(match[2]);
    if (arity > 1) arities.set(JSON.parse(match[1]), arity);
  }
  for (const [name, [arity]] of Object.entries({...primitiveExpressions, 'Bool.and': [2]}))
    if (arity > 1 && !declarations.has(name)) arities.set(name, arity);
  const flattened = flattenKnownPartialCalls(source, arities);
  const result = specializeCompiler(flattened.source, exports);
  return {source: result.source, stats: {...result.stats, uncurry: flattened.stats}};
}
