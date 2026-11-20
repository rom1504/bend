0000000000408f6d <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_>:
  408f6d:	push   rbp
  408f6e:	mov    rbp,rsp
  408f71:	sub    rsp,0x9e0
  408f78:	mov    QWORD PTR [rbp-0x10],r12
  408f7c:	mov    QWORD PTR [rbp-0x8],rbx
  408f80:	mov    QWORD PTR [rbp-0x18],r13
  408f84:	mov    QWORD PTR [rbp-0x20],r14
  408f88:	mov    QWORD PTR [rbp-0x28],r15
  408f8c:	mov    rax,rdi
  408f8f:	mov    r12,rax
  408f92:	mov    rax,rsi
  408f95:	mov    QWORD PTR [rbp-0x30],rax
  408f99:	mov    rax,rdx
  408f9c:	mov    rdi,rax
  408f9f:	mov    rax,rcx
  408fa2:	mov    r15,rax
  408fa5:	mov    rax,r8
  408fa8:	mov    rsi,rax
  408fab:	mov    rax,r9
  408fae:	mov    rbx,rax
  408fb1:	cmp    rdi,0x0
  408fb8:	jne    408fee <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x81>
  408fbe:	mov    r10,rsi
  408fc1:	mov    r11,QWORD PTR [rbp-0x30]
  408fc5:	mov    QWORD PTR [r11],r10
  408fc8:	mov    r10,rbx
  408fcb:	mov    r11,QWORD PTR [rbp-0x30]
  408fcf:	mov    QWORD PTR [r11+0x8],r10
  408fd3:	xor    eax,eax
  408fd5:	mov    r12,QWORD PTR [rbp-0x10]
  408fd9:	mov    rbx,QWORD PTR [rbp-0x8]
  408fdd:	mov    r13,QWORD PTR [rbp-0x18]
  408fe1:	mov    r14,QWORD PTR [rbp-0x20]
  408fe5:	mov    r15,QWORD PTR [rbp-0x28]
  408fe9:	mov    rsp,rbp
  408fec:	pop    rbp
  408fed:	ret    
  408fee:	mov    r10,rdi
  408ff1:	sub    r10,0x1
  408ff8:	mov    QWORD PTR [rbp-0x8d0],r10
  408fff:	mov    rdi,rsi
  409002:	shr    rdi,0x28
  409006:	and    rdi,0xffff
  40900d:	movabs r11,0xa4
  409017:	cmp    rdi,r11
  40901a:	jne    40902f <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0xc2>
  409020:	movabs r13,0x100a40000000000
  40902a:	jmp    40921c <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x2af>
  40902f:	mov    rdi,rsi
  409032:	shr    rdi,0x28
  409036:	and    rdi,0xffff
  40903d:	movabs r11,0xa5
  409047:	cmp    rdi,r11
  40904a:	jne    4091eb <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x27e>
  409050:	mov    r10,r12
  409053:	mov    QWORD PTR [rsp+0x18],r10
  409058:	mov    r10,rsi
  40905b:	mov    QWORD PTR [rsp+0x20],r10
  409060:	lea    r10,[rbp-0x8e8]
  409067:	mov    QWORD PTR [rsp+0x28],r10
  40906c:	mov    rdi,QWORD PTR [rsp+0x18]
  409071:	mov    rsi,QWORD PTR [rsp+0x20]
  409076:	mov    rdx,QWORD PTR [rsp+0x28]
  40907b:	xor    eax,eax
  40907d:	call   41de20 <p125_rt_take3>
  409082:	mov    QWORD PTR [rbp-0x910],rax
  409089:	lea    r10,[rbp-0x8e8]
  409090:	mov    r14,QWORD PTR [r10]
  409093:	lea    r10,[rbp-0x8e8]
  40909a:	mov    rdi,QWORD PTR [r10+0x8]
  40909e:	lea    r10,[rbp-0x8e8]
  4090a5:	mov    r13,QWORD PTR [r10+0x10]
  4090a9:	mov    esi,r15d
  4090ac:	mov    edx,edi
  4090ae:	cmp    rsi,rdx
  4090b1:	setb   sil
  4090b5:	movzx  esi,sil
  4090b9:	mov    r10,rsi
  4090bc:	test   r10d,r10d
  4090bf:	je     409158 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x1eb>
  4090c5:	lea    r10,[rbp-0x958]
  4090cc:	mov    r11,rdi
  4090cf:	mov    QWORD PTR [r10],r11
  4090d2:	lea    r10,[rbp-0x958]
  4090d9:	mov    r11,r13
  4090dc:	mov    QWORD PTR [r10+0x8],r11
  4090e0:	lea    r10,[rbp-0x958]
  4090e7:	movabs r11,0x1
  4090f1:	mov    QWORD PTR [r10+0x10],r11
  4090f5:	mov    rdi,r12
  4090f8:	movabs rsi,0xa6
  409102:	mov    esi,esi
  409104:	lea    rdx,[rbp-0x958]
  40910b:	xor    eax,eax
  40910d:	call   41dd50 <p125_rt_ctor3>
  409112:	mov    rdi,rax
  409115:	lea    r10,[rbp-0x958]
  40911c:	mov    r11,rdi
  40911f:	mov    QWORD PTR [r10],r11
  409122:	lea    r10,[rbp-0x958]
  409129:	mov    r11,rbx
  40912c:	mov    QWORD PTR [r10+0x8],r11
  409130:	mov    rdi,r12
  409133:	movabs rsi,0x12
  40913d:	mov    esi,esi
  40913f:	lea    rdx,[rbp-0x958]
  409146:	xor    eax,eax
  409148:	call   41dad0 <p125_rt_ctor2>
  40914d:	mov    rdi,rax
  409150:	mov    r13,r14
  409153:	jmp    4091e3 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x276>
  409158:	lea    r10,[rbp-0x958]
  40915f:	mov    r11,rdi
  409162:	mov    QWORD PTR [r10],r11
  409165:	lea    r10,[rbp-0x958]
  40916c:	mov    r11,r14
  40916f:	mov    QWORD PTR [r10+0x8],r11
  409173:	lea    r10,[rbp-0x958]
  40917a:	movabs r11,0x0
  409184:	mov    QWORD PTR [r10+0x10],r11
  409188:	mov    rdi,r12
  40918b:	movabs rsi,0xa6
  409195:	mov    esi,esi
  409197:	lea    rdx,[rbp-0x958]
  40919e:	xor    eax,eax
  4091a0:	call   41dd50 <p125_rt_ctor3>
  4091a5:	mov    rdi,rax
  4091a8:	lea    r10,[rbp-0x958]
  4091af:	mov    r11,rdi
  4091b2:	mov    QWORD PTR [r10],r11
  4091b5:	lea    r10,[rbp-0x958]
  4091bc:	mov    r11,rbx
  4091bf:	mov    QWORD PTR [r10+0x8],r11
  4091c3:	mov    rdi,r12
  4091c6:	movabs rsi,0x12
  4091d0:	mov    esi,esi
  4091d2:	lea    rdx,[rbp-0x958]
  4091d9:	xor    eax,eax
  4091db:	call   41dad0 <p125_rt_ctor2>
  4091e0:	mov    rdi,rax
  4091e3:	mov    rbx,rdi
  4091e6:	jmp    40921c <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x2af>
  4091eb:	mov    rdi,r12
  4091ee:	movabs rsi,0x4
  4091f8:	mov    esi,esi
  4091fa:	xor    eax,eax
  4091fc:	call   4185b0 <p111_rt_fail>
  409201:	mov    QWORD PTR [rbp-0x910],rax
  409208:	movabs r13,0x0
  409212:	movabs rbx,0x0
  40921c:	mov    r10,QWORD PTR [rbp-0x8d0]
  409223:	mov    rdi,r10
  409226:	mov    rsi,r13
  409229:	jmp    408fb1 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x44>

