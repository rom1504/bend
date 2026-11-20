.intel_syntax noprefix
# Proposed reserved-r10/r11 arithmetic for exact certified divisor26.
# Input ebx/output edi; no runtime call, same canonical low32 result.
mov r10d, ebx
mov r11d, 1321528399
imul r11, r10
shr r11, 35
imul r11d, r11d, 26
sub r10d, r11d
mov edi, r10d
