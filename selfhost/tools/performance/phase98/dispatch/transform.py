"""Mechanical dispatch extraction; every selected production branch is retained."""
import re

CONFIG = {
    'infer_node': ('check/kernel.bend', [('e', 'KEnv'), ('ctx', 'List<&2,KTerm>'), ('t', 'KTerm'), ('dem', 'U32'), ('sp', 'List<&2,KTerm>')], 'KChecking', False),
    'check_node': ('check/kernel.bend', [('e', 'KEnv'), ('ctx', 'List<&2,KTerm>'), ('t', 'KTerm'), ('dem', 'U32'), ('ty', 'KTerm')], 'KChecking', True),
    'ka_node': ('check/annotate.bend', [('e', 'KEnv'), ('ctx', 'List<&2,KTerm>'), ('t', 'KTerm'), ('ty', 'KTerm')], 'KTerm', True),
    'ka_type_node': ('check/annotate.bend', [('e', 'KEnv'), ('ctx', 'List<&2,KTerm>'), ('t', 'KTerm')], 'KTerm', False),
}


def args_of(text):
    assert text.startswith('kc(') and text.endswith(')'), text
    text = text[3:-1]
    result, start, depth, quote, escaped = [], 0, 0, False, False
    for i, c in enumerate(text):
        if quote:
            if escaped:
                escaped = False
            elif c == '\\':
                escaped = True
            elif c == '"':
                quote = False
        elif c == '"':
            quote = True
        elif c in '({[':
            depth += 1
        elif c in ')}]':
            depth -= 1
            assert depth >= 0
        elif c == ',' and depth == 0:
            result.append(text[start:i].strip())
            start = i + 1
    assert not quote and depth == 0
    result.append(text[start:].strip())
    assert len(result) == 4
    return result


def body_of_lambda(text):
    assert text.startswith('u =>') and text[4].isspace(), text
    return text[4:].strip()


def dispatch(body, name):
    module, params, result, literal = CONFIG[name]
    head, expression = body.split(':\n', 1)
    expression = expression.strip()
    literal_branch = None
    if literal:
        ty, cond, yes, no = args_of(expression)
        assert ty == result and cond == 'core_literal(t)'
        literal_branch = body_of_lambda(yes)
        expression = body_of_lambda(no)
    branches = []
    while expression.startswith('kc('):
        ty, cond, yes, no = args_of(expression)
        assert ty == result
        # Stop at the complete original fallback; never infer its semantics.
        if not re.fullmatch(r'String\.eq\(tg\(t\), "[A-Za-z]+"\)(?: \|\| String\.eq\(tg\(t\), "[A-Za-z]+"\))*', cond):
            break
        branches.append(dict(condition=cond, expression=body_of_lambda(yes)))
        expression = body_of_lambda(no)
    assert len(branches) >= 5, name
    prefix = 'p98_' + name
    enum = 'P98' + ''.join(part.capitalize() for part in name.split('_'))
    constructors = [enum + str(i) for i in range(len(branches))] + [enum + 'Default']
    selector = 'type ' + enum + ' is Data:\n' + ''.join('  ' + c + '{}\n' for c in constructors) + '\n'
    for i in reversed(range(len(branches))):
        miss = constructors[-1] + '{}' if i + 1 == len(branches) else prefix + '_stage' + str(i+1) + '(' + branches[i+1]['condition'].replace('tg(t)', 'tag') + ', tag)'
        selector += 'def ' + prefix + '_stage' + str(i) + '(+hit: Bool, +tag: String) -> ' + enum + ':\n'
        selector += '  match hit:\n    case True{}: ' + constructors[i] + '{}\n    case False{}: ' + miss + '\n\n'
    selector += 'def ' + prefix + '_select(+tag: String) -> ' + enum + ':\n  ' + prefix + '_stage0(' + branches[0]['condition'].replace('tg(t)', 'tag') + ', tag)\n'
    names = ', '.join(p for p, _ in params)
    typed = ', '.join('+' + p + ': ' + t for p, t in params)
    select_call = prefix + '_dispatch(' + prefix + '_select(tg(t)), ' + names + ')'
    caller = '@unsafe\ndef ' + prefix + '_dispatch(+which: ' + enum + ', ' + typed + ') -> ' + result + ':\n  match which:\n'
    caller += ''.join('    case ' + c + '{}: ' + b['expression'] + '\n' for c, b in zip(constructors, branches))
    caller += '    case ' + constructors[-1] + '{}: ' + expression + '\n'
    if literal:
        caller += '\n@unsafe\ndef ' + prefix + '_literal(+literal: Bool, ' + typed + ') -> ' + result + ':\n  match literal:\n'
        caller += '    case True{}: ' + literal_branch + '\n    case False{}: ' + select_call + '\n'
        entry = prefix + '_literal(core_literal(t), ' + names + ')'
    else:
        entry = select_call
    replacement = selector + '\n' + caller + '\n' + head + ':\n  ' + entry + '\n'
    return replacement, selector, dict(branches=branches, fallback=expression, literalBranch=literal_branch,
                                      selector=prefix + '_select', enum=enum, parameterTypes=params, returnType=result,
                                      selectedBranchExpressionsPreserved=True, orderedConditionsPreserved=True,
                                      literalGatePreserved=literal)
