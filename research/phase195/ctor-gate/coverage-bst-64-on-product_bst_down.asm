000000000040a28d <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_>:
  40a28d:	push   rbp
  40a28e:	mov    rbp,rsp
  40a291:	sub    rsp,0xba0
  40a298:	mov    QWORD PTR [rbp-0x10],r12
  40a29c:	mov    QWORD PTR [rbp-0x8],rbx
  40a2a0:	mov    QWORD PTR [rbp-0x18],r13
  40a2a4:	mov    QWORD PTR [rbp-0x20],r14
  40a2a8:	mov    QWORD PTR [rbp-0x28],r15
  40a2ac:	mov    rax,rdi
  40a2af:	mov    r12,rax
  40a2b2:	mov    rax,rsi
  40a2b5:	mov    QWORD PTR [rbp-0x30],rax
  40a2b9:	mov    rax,rdx
  40a2bc:	mov    rdi,rax
  40a2bf:	mov    rax,rcx
  40a2c2:	mov    r15,rax
  40a2c5:	mov    rax,r8
  40a2c8:	mov    rsi,rax
  40a2cb:	mov    rax,r9
  40a2ce:	mov    rbx,rax
  40a2d1:	cmp    rdi,0x0
  40a2d8:	jne    40a30e <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x81>
  40a2de:	mov    r10,rsi
  40a2e1:	mov    r11,QWORD PTR [rbp-0x30]
  40a2e5:	mov    QWORD PTR [r11],r10
  40a2e8:	mov    r10,rbx
  40a2eb:	mov    r11,QWORD PTR [rbp-0x30]
  40a2ef:	mov    QWORD PTR [r11+0x8],r10
  40a2f3:	xor    eax,eax
  40a2f5:	mov    r12,QWORD PTR [rbp-0x10]
  40a2f9:	mov    rbx,QWORD PTR [rbp-0x8]
  40a2fd:	mov    r13,QWORD PTR [rbp-0x18]
  40a301:	mov    r14,QWORD PTR [rbp-0x20]
  40a305:	mov    r15,QWORD PTR [rbp-0x28]
  40a309:	mov    rsp,rbp
  40a30c:	pop    rbp
  40a30d:	ret    
  40a30e:	mov    r10,rdi
  40a311:	sub    r10,0x1
  40a318:	mov    QWORD PTR [rbp-0x8d0],r10
  40a31f:	mov    rdi,rsi
  40a322:	shr    rdi,0x28
  40a326:	and    rdi,0xffff
  40a32d:	movabs r11,0xa4
  40a337:	cmp    rdi,r11
  40a33a:	jne    40a360 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0xd3>
  40a340:	movabs r10,0x100a40000000000
  40a34a:	mov    QWORD PTR [rbp-0x900],r10
  40a351:	mov    r10,rbx
  40a354:	mov    QWORD PTR [rbp-0x908],r10
  40a35b:	jmp    40a9c4 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x737>
  40a360:	mov    rdi,rsi
  40a363:	shr    rdi,0x28
  40a367:	and    rdi,0xffff
  40a36e:	movabs r11,0xa5
  40a378:	cmp    rdi,r11
  40a37b:	jne    40a985 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x6f8>
  40a381:	mov    r10,r12
  40a384:	mov    QWORD PTR [rsp+0x18],r10
  40a389:	mov    r10,rsi
  40a38c:	mov    QWORD PTR [rsp+0x20],r10
  40a391:	lea    r10,[rbp-0x8e8]
  40a398:	mov    QWORD PTR [rsp+0x28],r10
  40a39d:	mov    rdi,QWORD PTR [rsp+0x18]
  40a3a2:	mov    rsi,QWORD PTR [rsp+0x20]
  40a3a7:	mov    rdx,QWORD PTR [rsp+0x28]
  40a3ac:	xor    eax,eax
  40a3ae:	call   4206b0 <p125_rt_take3>
  40a3b3:	mov    QWORD PTR [rbp-0x910],rax
  40a3ba:	lea    r10,[rbp-0x8e8]
  40a3c1:	mov    r14,QWORD PTR [r10]
  40a3c4:	lea    r10,[rbp-0x8e8]
  40a3cb:	mov    rdi,QWORD PTR [r10+0x8]
  40a3cf:	lea    r10,[rbp-0x8e8]
  40a3d6:	mov    r13,QWORD PTR [r10+0x10]
  40a3da:	mov    esi,r15d
  40a3dd:	mov    edx,edi
  40a3df:	cmp    rsi,rdx
  40a3e2:	setb   sil
  40a3e6:	movzx  esi,sil
  40a3ea:	mov    r10,rsi
  40a3ed:	test   r10d,r10d
  40a3f0:	je     40a689 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x3fc>
  40a3f6:	lea    r10,[rbp-0x958]
  40a3fd:	mov    r11,rdi
  40a400:	mov    QWORD PTR [r10],r11
  40a403:	lea    r10,[rbp-0x958]
  40a40a:	mov    r11,r13
  40a40d:	mov    QWORD PTR [r10+0x8],r11
  40a411:	lea    r10,[rbp-0x958]
  40a418:	movabs r11,0x1
  40a422:	mov    QWORD PTR [r10+0x10],r11
  40a426:	mov    rdi,QWORD PTR [r12+0x8]
  40a42b:	mov    rdx,QWORD PTR [rdi+0x10]
  40a42f:	cmp    rdx,0x0
  40a436:	je     40a4fb <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x26e>
  40a43c:	mov    rsi,QWORD PTR [r12]
  40a440:	mov    r8,rdx
  40a443:	shl    r8,0x3
  40a447:	add    rsi,r8
  40a44a:	mov    r8,QWORD PTR [rsi]
  40a44d:	mov    r9,QWORD PTR [rdi+0x110]
  40a454:	lea    r10,[rbp-0x958]
  40a45b:	mov    r10,QWORD PTR [r10]
  40a45e:	mov    QWORD PTR [rbp-0x9a0],r10
  40a465:	lea    r10,[rbp-0x958]
  40a46c:	mov    r10,QWORD PTR [r10+0x8]
  40a470:	mov    QWORD PTR [rbp-0x9a8],r10
  40a477:	lea    r10,[rbp-0x958]
  40a47e:	mov    r10,QWORD PTR [r10+0x10]
  40a482:	mov    QWORD PTR [rbp-0x9b0],r10
  40a489:	mov    QWORD PTR [rdi+0x10],r8
  40a48d:	mov    r8,r9
  40a490:	sub    r8,0x4
  40a497:	mov    QWORD PTR [rdi+0x110],r8
  40a49e:	mov    r10,rsi
  40a4a1:	mov    r11,QWORD PTR [rbp-0x9a0]
  40a4a8:	mov    QWORD PTR [r10],r11
  40a4ab:	mov    r10,rsi
  40a4ae:	mov    r11,QWORD PTR [rbp-0x9a8]
  40a4b5:	mov    QWORD PTR [r10+0x8],r11
  40a4b9:	mov    r10,rsi
  40a4bc:	mov    r11,QWORD PTR [rbp-0x9b0]
  40a4c3:	mov    QWORD PTR [r10+0x10],r11
  40a4c7:	movabs r10,0xa6
  40a4d1:	shl    r10,0x28
  40a4d5:	mov    QWORD PTR [rbp-0x9c0],r10
  40a4dc:	movabs r11,0x200000000000000
  40a4e6:	or     r10,r11
  40a4e9:	mov    QWORD PTR [rbp-0x9c8],r10
  40a4f0:	mov    rdi,r10
  40a4f3:	or     rdi,rdx
  40a4f6:	jmp    40a527 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x29a>
  40a4fb:	mov    rdi,r12
  40a4fe:	movabs rsi,0xa6
  40a508:	mov    esi,esi
  40a50a:	lea    rdx,[rbp-0x958]
  40a511:	movabs rcx,0x3
  40a51b:	mov    ecx,ecx
  40a51d:	xor    eax,eax
  40a51f:	call   41a720 <p111_rt_ctor>
  40a524:	mov    rdi,rax
  40a527:	lea    r10,[rbp-0x958]
  40a52e:	mov    r11,rdi
  40a531:	mov    QWORD PTR [r10],r11
  40a534:	lea    r10,[rbp-0x958]
  40a53b:	mov    r11,rbx
  40a53e:	mov    QWORD PTR [r10+0x8],r11
  40a542:	mov    rdi,QWORD PTR [r12+0x8]
  40a547:	mov    rsi,QWORD PTR [rdi+0x8]
  40a54b:	cmp    rsi,0x0
  40a552:	je     40a644 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x3b7>
  40a558:	mov    r10,r12
  40a55b:	mov    r10,QWORD PTR [r10]
  40a55e:	mov    QWORD PTR [rbp-0x9f0],r10
  40a565:	mov    r10,rsi
  40a568:	shl    r10,0x3
  40a56c:	mov    QWORD PTR [rbp-0x9f8],r10
  40a573:	mov    r11,r10
  40a576:	mov    rdx,QWORD PTR [rbp-0x9f0]
  40a57d:	add    rdx,r11
  40a580:	mov    r10,rdx
  40a583:	mov    r10,QWORD PTR [r10]
  40a586:	mov    QWORD PTR [rbp-0xa08],r10
  40a58d:	mov    r10,rdi
  40a590:	mov    r10,QWORD PTR [r10+0x108]
  40a597:	mov    QWORD PTR [rbp-0xa10],r10
  40a59e:	lea    r10,[rbp-0x958]
  40a5a5:	mov    r10,QWORD PTR [r10]
  40a5a8:	mov    QWORD PTR [rbp-0xa18],r10
  40a5af:	lea    r10,[rbp-0x958]
  40a5b6:	mov    r10,QWORD PTR [r10+0x8]
  40a5ba:	mov    QWORD PTR [rbp-0xa20],r10
  40a5c1:	mov    r10,rdi
  40a5c4:	mov    r11,QWORD PTR [rbp-0xa08]
  40a5cb:	mov    QWORD PTR [r10+0x8],r11
  40a5cf:	mov    r10,QWORD PTR [rbp-0xa10]
  40a5d6:	sub    r10,0x2
  40a5dd:	mov    QWORD PTR [rbp-0xa28],r10
  40a5e4:	mov    r10,rdi
  40a5e7:	mov    r11,QWORD PTR [rbp-0xa28]
  40a5ee:	mov    QWORD PTR [r10+0x108],r11
  40a5f5:	mov    r10,rdx
  40a5f8:	mov    r11,QWORD PTR [rbp-0xa18]
  40a5ff:	mov    QWORD PTR [r10],r11
  40a602:	mov    r10,rdx
  40a605:	mov    r11,QWORD PTR [rbp-0xa20]
  40a60c:	mov    QWORD PTR [r10+0x8],r11
  40a610:	movabs r10,0x12
  40a61a:	shl    r10,0x28
  40a61e:	mov    QWORD PTR [rbp-0xa30],r10
  40a625:	movabs r11,0x200000000000000
  40a62f:	or     r10,r11
  40a632:	mov    QWORD PTR [rbp-0xa38],r10
  40a639:	mov    rdi,r10
  40a63c:	or     rdi,rsi
  40a63f:	jmp    40a670 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x3e3>
  40a644:	mov    rdi,r12
  40a647:	movabs rsi,0x12
  40a651:	mov    esi,esi
  40a653:	lea    rdx,[rbp-0x958]
  40a65a:	movabs rcx,0x2
  40a664:	mov    ecx,ecx
  40a666:	xor    eax,eax
  40a668:	call   41a720 <p111_rt_ctor>
  40a66d:	mov    rdi,rax
  40a670:	mov    r10,r14
  40a673:	mov    QWORD PTR [rbp-0xa40],r10
  40a67a:	mov    r10,rdi
  40a67d:	mov    QWORD PTR [rbp-0xa48],r10
  40a684:	jmp    40a964 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x6d7>
  40a689:	lea    r10,[rbp-0x958]
  40a690:	mov    r11,rdi
  40a693:	mov    QWORD PTR [r10],r11
  40a696:	lea    r10,[rbp-0x958]
  40a69d:	mov    r11,r14
  40a6a0:	mov    QWORD PTR [r10+0x8],r11
  40a6a4:	lea    r10,[rbp-0x958]
  40a6ab:	movabs r11,0x0
  40a6b5:	mov    QWORD PTR [r10+0x10],r11
  40a6b9:	mov    rdi,QWORD PTR [r12+0x8]
  40a6be:	mov    rdx,QWORD PTR [rdi+0x10]
  40a6c2:	cmp    rdx,0x0
  40a6c9:	je     40a7db <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x54e>
  40a6cf:	mov    r10,r12
  40a6d2:	mov    r10,QWORD PTR [r10]
  40a6d5:	mov    QWORD PTR [rbp-0xa68],r10
  40a6dc:	mov    r10,rdx
  40a6df:	shl    r10,0x3
  40a6e3:	mov    QWORD PTR [rbp-0xa70],r10
  40a6ea:	mov    r11,r10
  40a6ed:	mov    rsi,QWORD PTR [rbp-0xa68]
  40a6f4:	add    rsi,r11
  40a6f7:	mov    r10,rsi
  40a6fa:	mov    r10,QWORD PTR [r10]
  40a6fd:	mov    QWORD PTR [rbp-0xa80],r10
  40a704:	mov    r10,rdi
  40a707:	mov    r10,QWORD PTR [r10+0x110]
  40a70e:	mov    QWORD PTR [rbp-0xa88],r10
  40a715:	lea    r10,[rbp-0x958]
  40a71c:	mov    r10,QWORD PTR [r10]
  40a71f:	mov    QWORD PTR [rbp-0xa90],r10
  40a726:	lea    r10,[rbp-0x958]
  40a72d:	mov    r10,QWORD PTR [r10+0x8]
  40a731:	mov    QWORD PTR [rbp-0xa98],r10
  40a738:	lea    r10,[rbp-0x958]
  40a73f:	mov    r10,QWORD PTR [r10+0x10]
  40a743:	mov    QWORD PTR [rbp-0xaa0],r10
  40a74a:	mov    r10,rdi
  40a74d:	mov    r11,QWORD PTR [rbp-0xa80]
  40a754:	mov    QWORD PTR [r10+0x10],r11
  40a758:	mov    r10,QWORD PTR [rbp-0xa88]
  40a75f:	sub    r10,0x4
  40a766:	mov    QWORD PTR [rbp-0xaa8],r10
  40a76d:	mov    r10,rdi
  40a770:	mov    r11,QWORD PTR [rbp-0xaa8]
  40a777:	mov    QWORD PTR [r10+0x110],r11
  40a77e:	mov    r10,rsi
  40a781:	mov    r11,QWORD PTR [rbp-0xa90]
  40a788:	mov    QWORD PTR [r10],r11
  40a78b:	mov    r10,rsi
  40a78e:	mov    r11,QWORD PTR [rbp-0xa98]
  40a795:	mov    QWORD PTR [r10+0x8],r11
  40a799:	mov    r10,rsi
  40a79c:	mov    r11,QWORD PTR [rbp-0xaa0]
  40a7a3:	mov    QWORD PTR [r10+0x10],r11
  40a7a7:	movabs r10,0xa6
  40a7b1:	shl    r10,0x28
  40a7b5:	mov    QWORD PTR [rbp-0xab0],r10
  40a7bc:	movabs r11,0x200000000000000
  40a7c6:	or     r10,r11
  40a7c9:	mov    QWORD PTR [rbp-0xab8],r10
  40a7d0:	mov    rdi,r10
  40a7d3:	or     rdi,rdx
  40a7d6:	jmp    40a807 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x57a>
  40a7db:	mov    rdi,r12
  40a7de:	movabs rsi,0xa6
  40a7e8:	mov    esi,esi
  40a7ea:	lea    rdx,[rbp-0x958]
  40a7f1:	movabs rcx,0x3
  40a7fb:	mov    ecx,ecx
  40a7fd:	xor    eax,eax
  40a7ff:	call   41a720 <p111_rt_ctor>
  40a804:	mov    rdi,rax
  40a807:	lea    r10,[rbp-0x958]
  40a80e:	mov    r11,rdi
  40a811:	mov    QWORD PTR [r10],r11
  40a814:	lea    r10,[rbp-0x958]
  40a81b:	mov    r11,rbx
  40a81e:	mov    QWORD PTR [r10+0x8],r11
  40a822:	mov    rdi,QWORD PTR [r12+0x8]
  40a827:	mov    rsi,QWORD PTR [rdi+0x8]
  40a82b:	cmp    rsi,0x0
  40a832:	je     40a924 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x697>
  40a838:	mov    r10,r12
  40a83b:	mov    r10,QWORD PTR [r10]
  40a83e:	mov    QWORD PTR [rbp-0xad8],r10
  40a845:	mov    r10,rsi
  40a848:	shl    r10,0x3
  40a84c:	mov    QWORD PTR [rbp-0xae0],r10
  40a853:	mov    r11,r10
  40a856:	mov    rdx,QWORD PTR [rbp-0xad8]
  40a85d:	add    rdx,r11
  40a860:	mov    r10,rdx
  40a863:	mov    r10,QWORD PTR [r10]
  40a866:	mov    QWORD PTR [rbp-0xaf0],r10
  40a86d:	mov    r10,rdi
  40a870:	mov    r10,QWORD PTR [r10+0x108]
  40a877:	mov    QWORD PTR [rbp-0xaf8],r10
  40a87e:	lea    r10,[rbp-0x958]
  40a885:	mov    r10,QWORD PTR [r10]
  40a888:	mov    QWORD PTR [rbp-0xb00],r10
  40a88f:	lea    r10,[rbp-0x958]
  40a896:	mov    r10,QWORD PTR [r10+0x8]
  40a89a:	mov    QWORD PTR [rbp-0xb08],r10
  40a8a1:	mov    r10,rdi
  40a8a4:	mov    r11,QWORD PTR [rbp-0xaf0]
  40a8ab:	mov    QWORD PTR [r10+0x8],r11
  40a8af:	mov    r10,QWORD PTR [rbp-0xaf8]
  40a8b6:	sub    r10,0x2
  40a8bd:	mov    QWORD PTR [rbp-0xb10],r10
  40a8c4:	mov    r10,rdi
  40a8c7:	mov    r11,QWORD PTR [rbp-0xb10]
  40a8ce:	mov    QWORD PTR [r10+0x108],r11
  40a8d5:	mov    r10,rdx
  40a8d8:	mov    r11,QWORD PTR [rbp-0xb00]
  40a8df:	mov    QWORD PTR [r10],r11
  40a8e2:	mov    r10,rdx
  40a8e5:	mov    r11,QWORD PTR [rbp-0xb08]
  40a8ec:	mov    QWORD PTR [r10+0x8],r11
  40a8f0:	movabs r10,0x12
  40a8fa:	shl    r10,0x28
  40a8fe:	mov    QWORD PTR [rbp-0xb18],r10
  40a905:	movabs r11,0x200000000000000
  40a90f:	or     r10,r11
  40a912:	mov    QWORD PTR [rbp-0xb20],r10
  40a919:	mov    rdi,r10
  40a91c:	or     rdi,rsi
  40a91f:	jmp    40a950 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x6c3>
  40a924:	mov    rdi,r12
  40a927:	movabs rsi,0x12
  40a931:	mov    esi,esi
  40a933:	lea    rdx,[rbp-0x958]
  40a93a:	movabs rcx,0x2
  40a944:	mov    ecx,ecx
  40a946:	xor    eax,eax
  40a948:	call   41a720 <p111_rt_ctor>
  40a94d:	mov    rdi,rax
  40a950:	mov    r10,r13
  40a953:	mov    QWORD PTR [rbp-0xa40],r10
  40a95a:	mov    r10,rdi
  40a95d:	mov    QWORD PTR [rbp-0xa48],r10
  40a964:	mov    r10,QWORD PTR [rbp-0xa40]
  40a96b:	mov    QWORD PTR [rbp-0x900],r10
  40a972:	mov    r10,QWORD PTR [rbp-0xa48]
  40a979:	mov    QWORD PTR [rbp-0x908],r10
  40a980:	jmp    40a9c4 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x737>
  40a985:	mov    rdi,r12
  40a988:	movabs rsi,0x4
  40a992:	mov    esi,esi
  40a994:	xor    eax,eax
  40a996:	call   41ae40 <p111_rt_fail>
  40a99b:	mov    QWORD PTR [rbp-0x910],rax
  40a9a2:	movabs r10,0x0
  40a9ac:	mov    QWORD PTR [rbp-0x900],r10
  40a9b3:	movabs r10,0x0
  40a9bd:	mov    QWORD PTR [rbp-0x908],r10
  40a9c4:	mov    r10,QWORD PTR [rbp-0x8d0]
  40a9cb:	mov    rdi,r10
  40a9ce:	mov    r10,QWORD PTR [rbp-0x900]
  40a9d5:	mov    rsi,r10
  40a9d8:	mov    r10,QWORD PTR [rbp-0x908]
  40a9df:	mov    rbx,r10
  40a9e2:	jmp    40a2d1 <p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_+0x44>

