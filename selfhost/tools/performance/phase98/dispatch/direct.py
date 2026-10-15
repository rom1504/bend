"""Exact conditional-tree lifting for a bounded list of actual hot callers."""
from transform import args_of

T = 'KTerm'
E = 'KEnv'
C = 'List<&2,KTerm>'
B = 'List<&2,KDef>'
U = 'U32'
R = 'KChecking'
DIRECT = {
    'core_rebuild': ('core/term.bend', [('t', T)]),
    'core_apply_span': ('core/term.bend', [('f', T), ('x', T), ('begin', U), ('end', U)]),
    'core_beta': ('core/term.bend', [('t', T)]),
    'compare': ('core/normalize.bend', [('book', B), ('a', T), ('b', T), ('le', 'Bool')]),
    'norm_compare': ('core/normalize.bend', [('book', B), ('a', T), ('b', T), ('le', 'Bool'), ('fresh', U)]),
    'norm_ref': ('core/normalize.bend', [('book', B), ('t', T), ('args', C), ('d', 'KDef')]),
    'infer_ref': ('check/kernel.bend', [('e', E), ('ctx', C), ('t', T), ('dem', U), ('sp', C), ('d', 'KDef')]),
    'infer_app': ('check/kernel.bend', [('e', E), ('ctx', C), ('t', T), ('dem', U), ('r', R)]),
    'infer_app_type': ('check/kernel.bend', [('e', E), ('ctx', C), ('t', T), ('dem', U), ('r', R), ('ty', T)]),
    'infer_adt': ('check/kernel.bend', [('e', E), ('ctx', C), ('t', T), ('dem', U), ('d', 'KDef')]),
    'check_fits': ('check/kernel.bend', [('e', E), ('r', R), ('ty', T)]),
    'check_lam': ('check/kernel.bend', [('e', E), ('ctx', C), ('t', T), ('dem', U), ('ty', T)]),
    'check_lam_done': ('check/kernel.bend', [('t', T), ('ty', T), ('q', U), ('r', R)]),
    'check_ctr': ('check/kernel.bend', [('e', E), ('ctx', C), ('t', T), ('dem', U), ('ty', T)]),
    'nc_lower_live_to': ('back/native/bridge.bend', [('book', B), ('t', T), ('env', 'List<&2,NC_Binding>'), ('n', U), ('target', 'NC_Target')]),
}


def direct(body, name):
    module, params = DIRECT[name]
    head, expression = body.split(':\n', 1)
    expression = expression.strip()
    locals_text = ''
    if name == 'nc_lower_live_to':
        assert expression.startswith('+tag = tg(t)\n')
        locals_text = '  +tag : String = tg(t)\n'
        expression = expression.split('\n', 1)[1].strip()
        params = params + [('tag', 'String')]
    names = ', '.join(p for p, _ in params)
    typed = ', '.join('+' + p + ': ' + t for p, t in params)
    nodes = []
    helpers = []
    def lift(expr):
        choose = next((c for c in ['kc', 'nt_choose'] if expr.startswith(c + '(')), None)
        if choose is None:
            return expr
        ty, condition, yes, no = args_of('kc' + expr[len(choose):])
        def unwrap(branch):
            binder, body = branch.split('=>', 1)
            assert binder.strip() in ['u', 'v'], binder
            # Production branches use their Unit arguments only to delay work.
            import re
            scrubbed = re.sub(r'"(?:[^"\\]|\\.)*"', '""', body)
            scrubbed = re.sub(r'\b[uv]\s*=>', '', scrubbed)
            assert not re.search(r'\b' + binder.strip() + r'\b', scrubbed), (name, branch)
            return body.strip()
        original_yes, original_no = unwrap(yes), unwrap(no)
        index = len(nodes)
        helper = 'p98_' + name + '_branch' + str(index)
        nodes.append(dict(helper=helper, choose=choose, result=ty, condition=condition,
                          yes=original_yes, no=original_no))
        next_yes, next_no = lift(original_yes), lift(original_no)
        helpers.append('@unsafe\ndef ' + helper + '(+hit: Bool, ' + typed + ') -> ' + ty + ':\n'
                       '  match hit:\n    case True{}: ' + next_yes + '\n    case False{}: ' + next_no + '\n')
        return helper + '(' + condition + ', ' + names + ')'
    entry = lift(expression)
    assert nodes
    replacement = '\n'.join(helpers) + '\n' + head + ':\n' + locals_text + '  ' + entry + '\n'
    return replacement, dict(parameterTypes=params, conditionalNodes=nodes, removedChoiceCalls=len(nodes),
                             branchExpressionsPreserved=True, conditionalOrderPreserved=True,
                             eagerObserversAdded=False, extraLocalAnnotation=bool(locals_text))
