
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/tree-bitonic/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000411e47 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_>:
  411e47:	push   rbp
  411e48:	mov    rbp,rsp
  411e4b:	sub    rsp,0x1b60
  411e52:	mov    QWORD PTR [rbp-0x10],r12
  411e56:	mov    QWORD PTR [rbp-0x8],rbx
  411e5a:	mov    QWORD PTR [rbp-0x18],r13
  411e5e:	mov    QWORD PTR [rbp-0x20],r14
  411e62:	mov    QWORD PTR [rbp-0x28],r15
  411e66:	mov    rax,rdi
  411e69:	mov    r12,rax
  411e6c:	mov    rax,rsi
  411e6f:	mov    r13,rax
  411e72:	mov    rax,rdx
  411e75:	mov    rbx,rax
  411e78:	mov    rax,rcx
  411e7b:	mov    r14,rax
  411e7e:	mov    rax,r8
  411e81:	mov    rdi,rax
  411e84:	mov    rax,r9
  411e87:	mov    r15,rax
  411e8a:	mov    rax,QWORD PTR [rbp+0x10]
  411e8e:	mov    QWORD PTR [rbp-0x58],rax
  411e92:	mov    r10,rdi
  411e95:	test   r10d,r10d
  411e98:	je     41205d <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x216>
  411e9e:	cmp    r15,0x0
  411ea5:	je     412040 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x1f9>
  411eab:	sub    r15,0x1
  411eb2:	mov    rdi,QWORD PTR [r12+0x10]
  411eb7:	movabs r11,0xfffffffffffffff8
  411ec1:	add    rdi,r11
  411ec4:	mov    QWORD PTR [r12+0x10],rdi
  411ec9:	mov    rdi,QWORD PTR [r12+0x10]
  411ece:	mov    rdi,QWORD PTR [rdi]
  411ed1:	movabs r11,0x74
  411edb:	cmp    rdi,r11
  411ede:	jne    411f95 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x14e>
  411ee4:	mov    rdi,QWORD PTR [r12+0x10]
  411ee9:	movabs r11,0xffffffffffffffe8
  411ef3:	add    rdi,r11
  411ef6:	mov    QWORD PTR [r12+0x10],rdi
  411efb:	mov    rdi,QWORD PTR [r12+0x10]
  411f00:	mov    r13,QWORD PTR [rdi]
  411f03:	mov    rdi,QWORD PTR [r12+0x10]
  411f08:	mov    r14,QWORD PTR [rdi+0x8]
  411f0c:	mov    rdi,QWORD PTR [r12+0x10]
  411f11:	mov    rbx,QWORD PTR [rdi+0x10]
  411f15:	lea    r10,[rbp-0x10d8]
  411f1c:	mov    r11,QWORD PTR [rbp-0x58]
  411f20:	mov    QWORD PTR [r10],r11
  411f23:	mov    rdi,r12
  411f26:	movabs rsi,0x75
  411f30:	mov    esi,esi
  411f32:	lea    rdx,[rbp-0x10d8]
  411f39:	movabs rcx,0x1
  411f43:	mov    ecx,ecx
  411f45:	xor    eax,eax
  411f47:	call   41c4e0 <p111_rt_frame>
  411f4c:	mov    QWORD PTR [rbp-0x1950],rax
  411f53:	add    r15,0x1
  411f5a:	lea    r10,[rbp-0x10d8]
  411f61:	mov    r11,r13
  411f64:	mov    QWORD PTR [r10],r11
  411f67:	lea    r10,[rbp-0x10d8]
  411f6e:	mov    r11,rbx
  411f71:	mov    QWORD PTR [r10+0x8],r11
  411f75:	lea    r10,[rbp-0x10d8]
  411f7c:	mov    r11,r14
  411f7f:	mov    QWORD PTR [r10+0x10],r11
  411f83:	movabs r10,0x0
  411f8d:	mov    rdi,r10
  411f90:	jmp    411e92 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  411f95:	movabs r11,0x75
  411f9f:	cmp    rdi,r11
  411fa2:	jne    41200a <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x1c3>
  411fa8:	mov    rdi,QWORD PTR [r12+0x10]
  411fad:	movabs r11,0xfffffffffffffff8
  411fb7:	add    rdi,r11
  411fba:	mov    QWORD PTR [r12+0x10],rdi
  411fbf:	mov    rdi,QWORD PTR [r12+0x10]
  411fc4:	mov    r10,rdi
  411fc7:	mov    r10,QWORD PTR [r10]
  411fca:	mov    QWORD PTR [rbp-0x1970],r10
  411fd1:	mov    rdi,r12
  411fd4:	mov    rsi,QWORD PTR [rbp-0x1970]
  411fdb:	mov    rdx,QWORD PTR [rbp-0x58]
  411fdf:	xor    eax,eax
  411fe1:	call   40886b <p112w_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_122_105_112_>
  411fe6:	mov    QWORD PTR [rbp-0x1978],rax
  411fed:	movabs r10,0x1
  411ff7:	mov    rdi,r10
  411ffa:	mov    r10,QWORD PTR [rbp-0x1978]
  412001:	mov    QWORD PTR [rbp-0x58],r10
  412005:	jmp    411e92 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  41200a:	mov    rdi,r12
  41200d:	movabs rsi,0x4
  412017:	mov    esi,esi
  412019:	xor    eax,eax
  41201b:	call   41c730 <p111_rt_fail>
  412020:	mov    QWORD PTR [rbp-0x1980],rax
  412027:	mov    r12,QWORD PTR [rbp-0x10]
  41202b:	mov    rbx,QWORD PTR [rbp-0x8]
  41202f:	mov    r13,QWORD PTR [rbp-0x18]
  412033:	mov    r14,QWORD PTR [rbp-0x20]
  412037:	mov    r15,QWORD PTR [rbp-0x28]
  41203b:	mov    rsp,rbp
  41203e:	pop    rbp
  41203f:	ret    
  412040:	mov    rax,QWORD PTR [rbp-0x58]
  412044:	mov    r12,QWORD PTR [rbp-0x10]
  412048:	mov    rbx,QWORD PTR [rbp-0x8]
  41204c:	mov    r13,QWORD PTR [rbp-0x18]
  412050:	mov    r14,QWORD PTR [rbp-0x20]
  412054:	mov    r15,QWORD PTR [rbp-0x28]
  412058:	mov    rsp,rbp
  41205b:	pop    rbp
  41205c:	ret    
  41205d:	mov    rdi,r13
  412060:	shr    rdi,0x28
  412064:	and    rdi,0xffff
  41206b:	movabs r11,0xa4
  412075:	cmp    rdi,r11
  412078:	jne    41241f <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x5d8>
  41207e:	mov    r10,r13
  412081:	shr    r10,0x28
  412085:	mov    QWORD PTR [rbp-0x1998],r10
  41208c:	and    r10,0x7fffff
  412093:	mov    QWORD PTR [rbp-0x19a0],r10
  41209a:	movabs r10,0xa4
  4120a4:	or     r10,0x10000
  4120ab:	mov    QWORD PTR [rbp-0x19a8],r10
  4120b2:	mov    r10,QWORD PTR [rbp-0x19a0]
  4120b9:	mov    r11,QWORD PTR [rbp-0x19a8]
  4120c0:	cmp    r10,r11
  4120c3:	jne    4120f6 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x2af>
  4120c9:	mov    r10,r13
  4120cc:	movabs r11,0xffffffffff
  4120d6:	and    r10,r11
  4120d9:	mov    QWORD PTR [rbp-0x19b8],r10
  4120e0:	lea    r10,[rbp-0x860]
  4120e7:	mov    r11,QWORD PTR [rbp-0x19b8]
  4120ee:	mov    QWORD PTR [r10],r11
  4120f1:	jmp    412111 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x2ca>
  4120f6:	mov    rdi,r12
  4120f9:	mov    rsi,r13
  4120fc:	lea    rdx,[rbp-0x860]
  412103:	xor    eax,eax
  412105:	call   421ac0 <p125_rt_take1>
  41210a:	mov    QWORD PTR [rbp-0x19c0],rax
  412111:	lea    r10,[rbp-0x860]
  412118:	mov    r10,QWORD PTR [r10]
  41211b:	mov    QWORD PTR [rbp-0x19c8],r10
  412122:	mov    rdi,rbx
  412125:	shr    rdi,0x28
  412129:	and    rdi,0xffff
  412130:	movabs r11,0xa4
  41213a:	cmp    rdi,r11
  41213d:	jne    412270 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x429>
  412143:	mov    r10,rbx
  412146:	shr    r10,0x28
  41214a:	mov    QWORD PTR [rbp-0x19d0],r10
  412151:	and    r10,0x7fffff
  412158:	mov    QWORD PTR [rbp-0x19d8],r10
  41215f:	movabs r10,0xa4
  412169:	or     r10,0x10000
  412170:	mov    QWORD PTR [rbp-0x19e0],r10
  412177:	mov    r10,QWORD PTR [rbp-0x19d8]
  41217e:	mov    r11,QWORD PTR [rbp-0x19e0]
  412185:	cmp    r10,r11
  412188:	jne    4121bb <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x374>
  41218e:	mov    r10,rbx
  412191:	movabs r11,0xffffffffff
  41219b:	and    r10,r11
  41219e:	mov    QWORD PTR [rbp-0x19f0],r10
  4121a5:	lea    r10,[rbp-0x860]
  4121ac:	mov    r11,QWORD PTR [rbp-0x19f0]
  4121b3:	mov    QWORD PTR [r10],r11
  4121b6:	jmp    4121d6 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x38f>
  4121bb:	mov    rdi,r12
  4121be:	mov    rsi,rbx
  4121c1:	lea    rdx,[rbp-0x860]
  4121c8:	xor    eax,eax
  4121ca:	call   421ac0 <p125_rt_take1>
  4121cf:	mov    QWORD PTR [rbp-0x19c0],rax
  4121d6:	lea    r10,[rbp-0x860]
  4121dd:	mov    rdi,QWORD PTR [r10]
  4121e0:	lea    r10,[rbp-0x860]
  4121e7:	mov    r11,QWORD PTR [rbp-0x19c8]
  4121ee:	mov    QWORD PTR [r10],r11
  4121f1:	lea    r10,[rbp-0x860]
  4121f8:	mov    r11,rdi
  4121fb:	mov    QWORD PTR [r10+0x8],r11
  4121ff:	lea    r10,[rbp-0x860]
  412206:	mov    r11,r14
  412209:	mov    QWORD PTR [r10+0x10],r11
  41220d:	mov    r10,r12
  412210:	mov    QWORD PTR [rsp+0x20],r10
  412215:	mov    r10,QWORD PTR [rbp-0x19c8]
  41221c:	mov    QWORD PTR [rsp+0x28],r10
  412221:	mov    r10,rdi
  412224:	mov    QWORD PTR [rsp+0x30],r10
  412229:	mov    r10,r14
  41222c:	mov    QWORD PTR [rsp+0x38],r10
  412231:	mov    rdi,QWORD PTR [rsp+0x20]
  412236:	mov    rsi,QWORD PTR [rsp+0x28]
  41223b:	mov    rdx,QWORD PTR [rsp+0x30]
  412240:	mov    rcx,QWORD PTR [rsp+0x38]
  412245:	xor    eax,eax
  412247:	call   408e9c <p112w_FID_36_100_105_114_101_99_116_46_119_97_114_112_95_108_101_97_102_>
  41224c:	mov    QWORD PTR [rbp-0x1a00],rax
  412253:	movabs r10,0x1
  41225d:	mov    rdi,r10
  412260:	mov    r10,QWORD PTR [rbp-0x1a00]
  412267:	mov    QWORD PTR [rbp-0x58],r10
  41226b:	jmp    411e92 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  412270:	mov    rdi,r12
  412273:	mov    rsi,QWORD PTR [rbp-0x19c8]
  41227a:	xor    eax,eax
  41227c:	call   41bfa0 <p111_rt_sink>
  412281:	mov    QWORD PTR [rbp-0x19c0],rax
  412288:	mov    rdi,rbx
  41228b:	shr    rdi,0x28
  41228f:	and    rdi,0xffff
  412296:	movabs r11,0xa5
  4122a0:	cmp    rdi,r11
  4122a3:	jne    412337 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4f0>
  4122a9:	mov    rdi,r12
  4122ac:	mov    rsi,rbx
  4122af:	lea    rdx,[rbp-0x860]
  4122b6:	xor    eax,eax
  4122b8:	call   421d40 <p125_rt_take2>
  4122bd:	mov    QWORD PTR [rbp-0x19c0],rax
  4122c4:	lea    r10,[rbp-0x860]
  4122cb:	mov    r10,QWORD PTR [r10]
  4122ce:	mov    QWORD PTR [rbp-0x1a08],r10
  4122d5:	lea    r10,[rbp-0x860]
  4122dc:	mov    r10,QWORD PTR [r10+0x8]
  4122e0:	mov    QWORD PTR [rbp-0x1a10],r10
  4122e7:	mov    rdi,r12
  4122ea:	mov    rsi,QWORD PTR [rbp-0x1a08]
  4122f1:	xor    eax,eax
  4122f3:	call   41bfa0 <p111_rt_sink>
  4122f8:	mov    QWORD PTR [rbp-0x19c0],rax
  4122ff:	mov    rdi,r12
  412302:	mov    rsi,QWORD PTR [rbp-0x1a10]
  412309:	xor    eax,eax
  41230b:	call   41bfa0 <p111_rt_sink>
  412310:	mov    QWORD PTR [rbp-0x19c0],rax
  412317:	movabs r10,0x1
  412321:	mov    rdi,r10
  412324:	movabs r10,0x100a40000000000
  41232e:	mov    QWORD PTR [rbp-0x58],r10
  412332:	jmp    411e92 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  412337:	lea    r10,[rbp-0x860]
  41233e:	mov    r11,r14
  412341:	mov    QWORD PTR [r10],r11
  412344:	mov    r10,r12
  412347:	mov    r10,QWORD PTR [r10+0x10]
  41234b:	mov    QWORD PTR [rbp-0x1a18],r10
  412352:	mov    r11,r14
  412355:	mov    QWORD PTR [r10],r11
  412358:	mov    r10,QWORD PTR [rbp-0x1a18]
  41235f:	movabs r11,0x72
  412369:	mov    QWORD PTR [r10+0x8],r11
  41236d:	mov    r10,QWORD PTR [rbp-0x1a18]
  412374:	add    r10,0x10
  41237b:	mov    QWORD PTR [rbp-0x1a20],r10
  412382:	mov    r10,r12
  412385:	mov    r11,QWORD PTR [rbp-0x1a20]
  41238c:	mov    QWORD PTR [r10+0x10],r11
  412390:	lea    r10,[rbp-0x860]
  412397:	mov    r11,rbx
  41239a:	mov    QWORD PTR [r10],r11
  41239d:	mov    r10,r12
  4123a0:	mov    r10,QWORD PTR [r10+0x10]
  4123a4:	mov    QWORD PTR [rbp-0x1a28],r10
  4123ab:	mov    r11,rbx
  4123ae:	mov    QWORD PTR [r10],r11
  4123b1:	mov    r10,QWORD PTR [rbp-0x1a28]
  4123b8:	movabs r11,0x73
  4123c2:	mov    QWORD PTR [r10+0x8],r11
  4123c6:	mov    r10,QWORD PTR [rbp-0x1a28]
  4123cd:	add    r10,0x10
  4123d4:	mov    QWORD PTR [rbp-0x1a30],r10
  4123db:	mov    r10,r12
  4123de:	mov    r11,QWORD PTR [rbp-0x1a30]
  4123e5:	mov    QWORD PTR [r10+0x10],r11
  4123e9:	mov    rdi,r12
  4123ec:	movabs rsi,0x4
  4123f6:	mov    esi,esi
  4123f8:	xor    eax,eax
  4123fa:	call   41c730 <p111_rt_fail>
  4123ff:	mov    QWORD PTR [rbp-0x1a38],rax
  412406:	mov    r12,QWORD PTR [rbp-0x10]
  41240a:	mov    rbx,QWORD PTR [rbp-0x8]
  41240e:	mov    r13,QWORD PTR [rbp-0x18]
  412412:	mov    r14,QWORD PTR [rbp-0x20]
  412416:	mov    r15,QWORD PTR [rbp-0x28]
  41241a:	mov    rsp,rbp
  41241d:	pop    rbp
  41241e:	ret    
  41241f:	mov    rdi,r13
  412422:	shr    rdi,0x28
  412426:	and    rdi,0xffff
  41242d:	movabs r11,0xa5
  412437:	cmp    rdi,r11
  41243a:	jne    4127fc <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x9b5>
  412440:	mov    rdi,r12
  412443:	mov    rsi,r13
  412446:	lea    rdx,[rbp-0x860]
  41244d:	xor    eax,eax
  41244f:	call   421d40 <p125_rt_take2>
  412454:	mov    QWORD PTR [rbp-0x19c0],rax
  41245b:	lea    r10,[rbp-0x860]
  412462:	mov    r10,QWORD PTR [r10]
  412465:	mov    QWORD PTR [rbp-0x1a40],r10
  41246c:	lea    r10,[rbp-0x860]
  412473:	mov    r10,QWORD PTR [r10+0x8]
  412477:	mov    QWORD PTR [rbp-0x1a48],r10
  41247e:	mov    rdi,rbx
  412481:	shr    rdi,0x28
  412485:	and    rdi,0xffff
  41248c:	movabs r11,0xa4
  412496:	cmp    rdi,r11
  412499:	jne    4125ab <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x764>
  41249f:	mov    r10,rbx
  4124a2:	shr    r10,0x28
  4124a6:	mov    QWORD PTR [rbp-0x1a50],r10
  4124ad:	and    r10,0x7fffff
  4124b4:	mov    QWORD PTR [rbp-0x1a58],r10
  4124bb:	movabs r10,0xa4
  4124c5:	or     r10,0x10000
  4124cc:	mov    QWORD PTR [rbp-0x1a60],r10
  4124d3:	mov    r10,QWORD PTR [rbp-0x1a58]
  4124da:	mov    r11,QWORD PTR [rbp-0x1a60]
  4124e1:	cmp    r10,r11
  4124e4:	jne    412517 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x6d0>
  4124ea:	mov    r10,rbx
  4124ed:	movabs r11,0xffffffffff
  4124f7:	and    r10,r11
  4124fa:	mov    QWORD PTR [rbp-0x1a70],r10
  412501:	lea    r10,[rbp-0x860]
  412508:	mov    r11,QWORD PTR [rbp-0x1a70]
  41250f:	mov    QWORD PTR [r10],r11
  412512:	jmp    412532 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x6eb>
  412517:	mov    rdi,r12
  41251a:	mov    rsi,rbx
  41251d:	lea    rdx,[rbp-0x860]
  412524:	xor    eax,eax
  412526:	call   421ac0 <p125_rt_take1>
  41252b:	mov    QWORD PTR [rbp-0x19c0],rax
  412532:	lea    r10,[rbp-0x860]
  412539:	mov    r10,QWORD PTR [r10]
  41253c:	mov    QWORD PTR [rbp-0x1a78],r10
  412543:	mov    rdi,r12
  412546:	mov    rsi,QWORD PTR [rbp-0x1a40]
  41254d:	xor    eax,eax
  41254f:	call   41bfa0 <p111_rt_sink>
  412554:	mov    QWORD PTR [rbp-0x19c0],rax
  41255b:	mov    rdi,r12
  41255e:	mov    rsi,QWORD PTR [rbp-0x1a48]
  412565:	xor    eax,eax
  412567:	call   41bfa0 <p111_rt_sink>
  41256c:	mov    QWORD PTR [rbp-0x19c0],rax
  412573:	mov    rdi,r12
  412576:	mov    rsi,QWORD PTR [rbp-0x1a78]
  41257d:	xor    eax,eax
  41257f:	call   41bfa0 <p111_rt_sink>
  412584:	mov    QWORD PTR [rbp-0x19c0],rax
  41258b:	movabs r10,0x1
  412595:	mov    rdi,r10
  412598:	movabs r10,0x100a40000000000
  4125a2:	mov    QWORD PTR [rbp-0x58],r10
  4125a6:	jmp    411e92 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  4125ab:	mov    rdi,rbx
  4125ae:	shr    rdi,0x28
  4125b2:	and    rdi,0xffff
  4125b9:	movabs r11,0xa5
  4125c3:	cmp    rdi,r11
  4125c6:	jne    4126e4 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x89d>
  4125cc:	mov    rdi,r12
  4125cf:	mov    rsi,rbx
  4125d2:	lea    rdx,[rbp-0x860]
  4125d9:	xor    eax,eax
  4125db:	call   421d40 <p125_rt_take2>
  4125e0:	mov    QWORD PTR [rbp-0x19c0],rax
  4125e7:	lea    r10,[rbp-0x860]
  4125ee:	mov    rbx,QWORD PTR [r10]
  4125f1:	lea    r10,[rbp-0x860]
  4125f8:	mov    r10,QWORD PTR [r10+0x8]
  4125fc:	mov    QWORD PTR [rbp-0x1a88],r10
  412603:	lea    r10,[rbp-0x860]
  41260a:	mov    r11,QWORD PTR [rbp-0x1a48]
  412611:	mov    QWORD PTR [r10],r11
  412614:	lea    r10,[rbp-0x860]
  41261b:	mov    r11,r14
  41261e:	mov    QWORD PTR [r10+0x8],r11
  412622:	lea    r10,[rbp-0x860]
  412629:	mov    r11,QWORD PTR [rbp-0x1a88]
  412630:	mov    QWORD PTR [r10+0x10],r11
  412634:	mov    rdi,QWORD PTR [r12+0x10]
  412639:	mov    r10,rdi
  41263c:	mov    r11,QWORD PTR [rbp-0x1a48]
  412643:	mov    QWORD PTR [r10],r11
  412646:	lea    r10,[rbp-0x860]
  41264d:	mov    rsi,QWORD PTR [r10+0x8]
  412651:	mov    QWORD PTR [rdi+0x8],rsi
  412655:	lea    r10,[rbp-0x860]
  41265c:	mov    rsi,QWORD PTR [r10+0x10]
  412660:	mov    QWORD PTR [rdi+0x10],rsi
  412664:	mov    r10,rdi
  412667:	movabs r11,0x74
  412671:	mov    QWORD PTR [r10+0x18],r11
  412675:	mov    r10,rdi
  412678:	add    r10,0x20
  41267f:	mov    QWORD PTR [rbp-0x1aa0],r10
  412686:	mov    r10,r12
  412689:	mov    r11,QWORD PTR [rbp-0x1aa0]
  412690:	mov    QWORD PTR [r10+0x10],r11
  412694:	add    r15,0x1
  41269b:	lea    r10,[rbp-0x860]
  4126a2:	mov    r11,QWORD PTR [rbp-0x1a40]
  4126a9:	mov    QWORD PTR [r10],r11
  4126ac:	lea    r10,[rbp-0x860]
  4126b3:	mov    r11,rbx
  4126b6:	mov    QWORD PTR [r10+0x8],r11
  4126ba:	lea    r10,[rbp-0x860]
  4126c1:	mov    r11,r14
  4126c4:	mov    QWORD PTR [r10+0x10],r11
  4126c8:	mov    r10,QWORD PTR [rbp-0x1a40]
  4126cf:	mov    r13,r10
  4126d2:	movabs r10,0x0
  4126dc:	mov    rdi,r10
  4126df:	jmp    411e92 <p114r_FID_36_100_105_114_101_99_116_46_119_97_114_112_+0x4b>
  4126e4:	mov    rdi,r12
  4126e7:	mov    rsi,QWORD PTR [rbp-0x1a40]
  4126ee:	xor    eax,eax
  4126f0:	call   41bfa0 <p111_rt_sink>
  4126f5:	mov    QWORD PTR [rbp-0x19c0],rax
  4126fc:	mov    rdi,r12
  4126ff:	mov    rsi,QWORD PTR [rbp-0x1a48]
  412706:	xor    eax,eax
  412708:	call   41bfa0 <p111_rt_sink>
  41270d:	mov    QWORD PTR [rbp-0x19c0],rax
  412714:	lea    r10,[rbp-0x860]
  41271b:	mov    r11,r14
  41271e:	mov    QWORD PTR [r10],r11
  412721:	mov    r10,r12
  412724:	mov    r10,QWORD PTR [r10+0x10]
  412728:	mov    QWORD PTR [rbp-0x1aa8],r10
  41272f:	mov    r11,r14
  412732:	mov    QWORD PTR [r10],r11
  412735:	mov    r10,QWORD PTR [rbp-0x1aa8]
  41273c:	movabs r11,0x76
  412746:	mov    QWORD PTR [r10+0x8],r11
  41274a:	mov    r10,QWORD PTR [rbp-0x1aa8]
  412751:	add    r10,0x10
  412758:	mov    QWORD PTR [rbp-0x1ab0],r10
  41275f:	mov    r10,r12
  412762:	mov    r11,QWORD PTR [rbp-0x1ab0]
  412769:	mov    QWORD PTR [r10+0x10],r11
  41276d:	lea    r10,[rbp-0x860]
  412774:	mov    r11,rbx
  412777:	mov    QWORD PTR [r10],r11
  41277a:	mov    r10,r12
  41277d:	mov    r10,QWORD PTR [r10+0x10]
  412781:	mov    QWORD PTR [rbp-0x1ab8],r10
  412788:	mov    r11,rbx
  41278b:	mov    QWORD PTR [r10],r11
  41278e:	mov    r10,QWORD PTR [rbp-0x1ab8]
  412795:	movabs r11,0x77
  41279f:	mov    QWORD PTR [r10+0x8],r11
  4127a3:	mov    r10,QWORD PTR [rbp-0x1ab8]
  4127aa:	add    r10,0x10
  4127b1:	mov    QWORD PTR [rbp-0x1ac0],r10
  4127b8:	mov    r10,r12
  4127bb:	mov    r11,QWORD PTR [rbp-0x1ac0]
  4127c2:	mov    QWORD PTR [r10+0x10],r11
  4127c6:	mov    rdi,r12
  4127c9:	movabs rsi,0x4
  4127d3:	mov    esi,esi
  4127d5:	xor    eax,eax
  4127d7:	call   41c730 <p111_rt_fail>
  4127dc:	mov    QWORD PTR [rbp-0x1a38],rax
  4127e3:	mov    r12,QWORD PTR [rbp-0x10]
  4127e7:	mov    rbx,QWORD PTR [rbp-0x8]
  4127eb:	mov    r13,QWORD PTR [rbp-0x18]
  4127ef:	mov    r14,QWORD PTR [rbp-0x20]
  4127f3:	mov    r15,QWORD PTR [rbp-0x28]
  4127f7:	mov    rsp,rbp
  4127fa:	pop    rbp
  4127fb:	ret    
  4127fc:	lea    r10,[rbp-0x860]
  412803:	mov    r11,r14
  412806:	mov    QWORD PTR [r10],r11
  412809:	mov    r10,r12
  41280c:	mov    r10,QWORD PTR [r10+0x10]
  412810:	mov    QWORD PTR [rbp-0x1ac8],r10
  412817:	mov    r11,r14
  41281a:	mov    QWORD PTR [r10],r11
  41281d:	mov    r10,QWORD PTR [rbp-0x1ac8]
  412824:	movabs r11,0x78
  41282e:	mov    QWORD PTR [r10+0x8],r11
  412832:	mov    r10,QWORD PTR [rbp-0x1ac8]
  412839:	add    r10,0x10
  412840:	mov    QWORD PTR [rbp-0x1ad0],r10
  412847:	mov    r10,r12
  41284a:	mov    r11,QWORD PTR [rbp-0x1ad0]
  412851:	mov    QWORD PTR [r10+0x10],r11
  412855:	lea    r10,[rbp-0x860]
  41285c:	mov    r11,rbx
  41285f:	mov    QWORD PTR [r10],r11
  412862:	mov    r10,r12
  412865:	mov    r10,QWORD PTR [r10+0x10]
  412869:	mov    QWORD PTR [rbp-0x1ad8],r10
  412870:	mov    r11,rbx
  412873:	mov    QWORD PTR [r10],r11
  412876:	mov    r10,QWORD PTR [rbp-0x1ad8]
  41287d:	movabs r11,0x79
  412887:	mov    QWORD PTR [r10+0x8],r11
  41288b:	mov    r10,QWORD PTR [rbp-0x1ad8]
  412892:	add    r10,0x10
  412899:	mov    QWORD PTR [rbp-0x1ae0],r10
  4128a0:	mov    r10,r12
  4128a3:	mov    r11,QWORD PTR [rbp-0x1ae0]
  4128aa:	mov    QWORD PTR [r10+0x10],r11
  4128ae:	lea    r10,[rbp-0x860]
  4128b5:	mov    r11,r13
  4128b8:	mov    QWORD PTR [r10],r11
  4128bb:	mov    r10,r12
  4128be:	mov    r10,QWORD PTR [r10+0x10]
  4128c2:	mov    QWORD PTR [rbp-0x1ae8],r10
  4128c9:	mov    r11,r13
  4128cc:	mov    QWORD PTR [r10],r11
  4128cf:	mov    r10,QWORD PTR [rbp-0x1ae8]
  4128d6:	movabs r11,0x7a
  4128e0:	mov    QWORD PTR [r10+0x8],r11
  4128e4:	mov    r10,QWORD PTR [rbp-0x1ae8]
  4128eb:	add    r10,0x10
  4128f2:	mov    QWORD PTR [rbp-0x1af0],r10
  4128f9:	mov    r10,r12
  4128fc:	mov    r11,QWORD PTR [rbp-0x1af0]
  412903:	mov    QWORD PTR [r10+0x10],r11
  412907:	mov    rdi,r12
  41290a:	movabs rsi,0x4
  412914:	mov    esi,esi
  412916:	xor    eax,eax
  412918:	call   41c730 <p111_rt_fail>
  41291d:	mov    QWORD PTR [rbp-0x1a38],rax
  412924:	mov    r12,QWORD PTR [rbp-0x10]
  412928:	mov    rbx,QWORD PTR [rbp-0x8]
  41292c:	mov    r13,QWORD PTR [rbp-0x18]
  412930:	mov    r14,QWORD PTR [rbp-0x20]
  412934:	mov    r15,QWORD PTR [rbp-0x28]
  412938:	mov    rsp,rbp
  41293b:	pop    rbp
  41293c:	ret    

Disassembly of section .fini:
