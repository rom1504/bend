"""A narrow whole-QBE identity bridge; never relabel a native image's source."""
from common import require


def identity(a, b):
    return isinstance(a, dict) and isinstance(b, dict) and all(k in a and a[k] == b.get(k) for k in ('bytes','sha256'))


def shape(component, canonical):
    bridge = component.get('canonicalEquivalence', {})
    return (bridge.get('kind') == 'whole-qbe-byte-identity'
            and identity(bridge.get('canonicalSourceIdentity'), canonical)
            and isinstance(bridge.get('requestGate'), str)
            and isinstance(bridge.get('qualificationGate'), str))


def audit(current, checked):
    component, canonical = current['components']['qbe'], current['source']['identity']
    if identity(component['sourceIdentity'], canonical):
        return
    require(shape(component, canonical), 'Explicit QBE canonical-source equivalence required')
    bridge = component['canonicalEquivalence']
    require({bridge['requestGate'],bridge['qualificationGate']} <= set(component['gates']), 'QBE bridge gates must be component gates')
    qualified, request = checked[bridge['qualificationGate']], checked[bridge['requestGate']]
    require(qualified.get('kind') == 'phase146-native-qualification'
            and all(qualified.get(k) is True for k in ('complete','sourceChecked','nativeQualified','q1q2CompleteStreamDigest','q3ObservedLiteralEqual')),
            'Exact independently qualified N2 fixed-point reference required')
    require(identity(qualified['source'],component['sourceIdentity']) and identity(qualified['n2'],component['image']), 'QBE image actual source/reference mismatch')
    require(request.get('kind') == 'bend-build-request' and request.get('complete') is True
            and request.get('byteExact') is True and not request.get('changedInputs')
            and (request.get('host'),request.get('target'),request.get('stage')) == ('native','qbe','N2'),
            'Actual complete native N2 QBE comparison required')
    plan, process = request['request'], request['process']
    require(plan.get('outputContract') == 'stdout' and plan['imageMetadata'].get('protocol') == 'qbe-source-v1'
            and process.get('complete') is True and process.get('exitCode') == 0
            and not process.get('timedOut') and not process.get('error') and process['stderr']['bytes'] == 0,
            'QBE comparison process did not complete cleanly')
    require(identity(request['source'],canonical) and identity(plan['source'],canonical)
            and identity(request['image'],component['image']) and identity(plan['image'],component['image'])
            and identity(plan['imageMetadata']['sourceIdentity'],component['sourceIdentity']), 'QBE bridge producer/source identities differ')
    require(all(identity(value,qualified['qbe']) for value in
                (plan['expected'],request['product'],process['stdout'],bridge.get('qualifiedQbeIdentity'))),
            'QBE bridge must compare the complete independently qualified IR bytes')
