.text
movd -2480(%rbp), %xmm1
movd %r15d, %xmm2
subss %xmm1, %xmm2
movaps %xmm2, %xmm3
movd -2488(%rbp), %xmm1
movd -72(%rbp), %xmm2
subss %xmm1, %xmm2
movaps %xmm2, %xmm4
movd -2496(%rbp), %xmm1
movd -80(%rbp), %xmm2
subss %xmm1, %xmm2
movaps %xmm2, %xmm5
movd -88(%rbp), %xmm1
vmulss %xmm1, %xmm3, %xmm2
movaps %xmm2, %xmm6
movd -96(%rbp), %xmm1
vmulss %xmm1, %xmm4, %xmm2
vaddss %xmm2, %xmm6, %xmm7
movaps %xmm7, %xmm2
movd -104(%rbp), %xmm1
vmulss %xmm1, %xmm5, %xmm6
vaddss %xmm6, %xmm2, %xmm7
movd %xmm7, %r10d
movq %r10, -2616(%rbp)
vmulss %xmm7, %xmm7, %xmm2
movaps %xmm2, %xmm6
vmulss %xmm3, %xmm3, %xmm2
movaps %xmm2, %xmm3
vmulss %xmm4, %xmm4, %xmm2
vaddss %xmm2, %xmm3, %xmm4
movaps %xmm4, %xmm2
vmulss %xmm5, %xmm5, %xmm3
vaddss %xmm3, %xmm2, %xmm4
movaps %xmm4, %xmm2
movd -2504(%rbp), %xmm1
movd -2504(%rbp), %xmm3
mulss %xmm1, %xmm3
vsubss %xmm3, %xmm2, %xmm4
vsubss %xmm4, %xmm6, %xmm0
movd %xmm0, %r10d
movq %r10, -2720(%rbp)
movabsq $0, %r10
movd %r10d, %xmm0
movd %xmm0, %r10d
pxor %xmm0, %xmm0
cvtsi2ssq %r10, %xmm0
movd %xmm0, %r10d
movd %r10d, %xmm2
movd -2720(%rbp), %xmm0
movaps %xmm2, %xmm1
ucomiss %xmm1, %xmm0
setb %r10b
setnp %r11b
andb %r11b, %r10b
movzbl %r10b, %r10d
movq %r10, -2736(%rbp)
cmpq $1, %r10
sete %r10b
movzbl %r10b, %r10d
movq %r10, -2760(%rbp)
testl %r10d, %r10d
