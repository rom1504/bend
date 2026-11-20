"""Add only the split code paths to the original runtime; preserve every descriptor lookup."""
def variant(original,cached):
    head,body=original.split('#define P125_VERIFIED(N)',1)
    macro,tail=body.split('P125_VERIFIED(1)',1)
    cached_macro=cached.split('#define P125_VERIFIED(N)',1)[1].split('P125_VERIFIED(1)',1)[0]
    start='uint64_t p125_rt_ctor##N(P111State *s,'
    assert cached_macro.count(start)==1
    public=cached_macro[cached_macro.index(start):]
    replacements=[
        ('cid < 65536u && (p198_ctor_info[cid] & P198_NO_SEAL)',
         'cid < p111_program_active->constructor_count && (p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)'),
        ('(p198_ctor_info[cid] & 511u) == N + 1u',
         'cid < p111_program_active->constructor_count && N == cid_arity(cid)')]
    for before,after in replacements:
        assert public.count(before)==1
        public=public.replace(before,after)
    for op in ('ctor','take'):
        before='uint64_t p125_rt_'+op+'##N('
        assert macro.count(before)==1
        macro=macro.replace(before,'static __attribute__((noinline)) uint64_t p198_slow_'+op+'##N(')
    result=head+'#define P125_VERIFIED(N)'+macro.rstrip()+' '+chr(92)+'\n'+public+'P125_VERIFIED(1)'+tail
    assert 'p198_ctor_info' not in result and 'p198_heap_base' not in result
    return result
