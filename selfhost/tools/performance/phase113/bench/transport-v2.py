"""Source-only export selection shared by versioned Phase113 plan tools."""
COMMON = ['p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission']


def select_exports(checked, pipeline):
    if pipeline not in {'direct', 'array'}:
        raise ValueError('Version2 transport supports direct or array')
    prefix = 'p113d' if pipeline == 'direct' else 'p113a'
    admitted = 'p113e_admitted_chunks' if pipeline == 'direct' else 'p113a_admitted_chunks'
    renderer = admitted if admitted in checked.get('exports', []) else prefix+'_chunks'
    result = dict(lowering=prefix+'_lower_request', verifier=prefix+'_verify',
                  renderer=renderer, rendererReverifies=renderer != admitted,
                  explicitVerificationPasses=1)
    result['requiredExports'] = COMMON + [result['lowering'], result['verifier'], renderer]
    if not set(result['requiredExports']).issubset(checked.get('exports', [])):
        raise ValueError('API missing version2 staged exports: ' + str(result['requiredExports']))
    return result
