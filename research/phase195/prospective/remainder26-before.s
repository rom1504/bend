.intel_syntax noprefix
# Actual nonzero U32.mod arithmetic, projected from combined runtime
# 0x41cbea..0x41cbf1, with literal26 from caller0x408afa.
# Registers normalized to input ebx/output edi; calls, dispatch and loads omitted.
mov ecx, 26
mov eax, ebx
xor edx, edx
div ecx
mov edi, edx
