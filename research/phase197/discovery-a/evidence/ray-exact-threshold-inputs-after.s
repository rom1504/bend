.text
movd %xmm0, %edi
leaq -2752(%rbp), %r10
movq -2784(%rbp), %r11
movq %r11, 0(%r10)
leaq -2752(%rbp), %r10
movq %rdi, %r11
movq %r11, 8(%r10)
movd %edi, %xmm1
movd -2784(%rbp), %xmm0
subss %xmm1, %xmm0
movd %xmm0, %edi
movl $1065353216, %r10d
movd %r10d, %xmm3
movl $1148846080, %r10d
movd %r10d, %xmm0
movaps %xmm0, %xmm2
movaps %xmm3, %xmm4
divss %xmm2, %xmm4
movd %edi, %xmm0
movaps %xmm4, %xmm1
ucomiss %xmm1, %xmm0
setb %r10b
setnp %r11b
andb %r11b, %r10b
movzbl %r10b, %r10d
movq %r10, -2824(%rbp)
cmpq $1, %r10
sete %r10b
movzbl %r10b, %r10d
movq %r10, -2832(%rbp)
testl %r10d, %r10d
