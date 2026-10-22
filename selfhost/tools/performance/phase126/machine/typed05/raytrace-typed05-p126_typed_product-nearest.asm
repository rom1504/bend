0000000000406800 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  406800:	f3 0f 1e fa          	endbr64 
  406804:	55                   	push   %rbp
  406805:	48 89 e5             	mov    %rsp,%rbp
  406808:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  40680f:	53                   	push   %rbx
  406810:	41 54                	push   %r12
  406812:	41 55                	push   %r13
  406814:	41 56                	push   %r14
  406816:	41 57                	push   %r15
  406818:	4c 8b 55 18          	mov    0x18(%rbp),%r10
  40681c:	4c 8b 7d 10          	mov    0x10(%rbp),%r15
  406820:	4d 89 cc             	mov    %r9,%r12
  406823:	4d 89 c6             	mov    %r8,%r14
  406826:	49 89 cd             	mov    %rcx,%r13
  406829:	f3 44 0f 10 fb       	movss  %xmm3,%xmm15
  40682e:	f3 0f 10 da          	movss  %xmm2,%xmm3
  406832:	f3 41 0f 10 d7       	movss  %xmm15,%xmm2
  406837:	f3 44 0f 10 fc       	movss  %xmm4,%xmm15
  40683c:	f3 0f 10 e1          	movss  %xmm1,%xmm4
  406840:	f3 41 0f 10 cf       	movss  %xmm15,%xmm1
  406845:	f3 44 0f 10 c0       	movss  %xmm0,%xmm8
  40684a:	f3 0f 10 c5          	movss  %xmm5,%xmm0
  40684e:	48 89 d3             	mov    %rdx,%rbx
  406851:	48 89 75 80          	mov    %rsi,-0x80(%rbp)
  406855:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  40685a:	48 89 45 88          	mov    %rax,-0x78(%rbp)
  40685e:	ba 00 00 00 41       	mov    $0x41000000,%edx
  406863:	48 89 55 90          	mov    %rdx,-0x70(%rbp)
  406867:	be cd cc 4c 3e       	mov    $0x3e4ccccd,%esi
  40686c:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
  406870:	b8 00 00 60 c0       	mov    $0xc0600000,%eax
  406875:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  406879:	4c 89 ea             	mov    %r13,%rdx
  40687c:	4d 89 f0             	mov    %r14,%r8
  40687f:	4d 89 e5             	mov    %r12,%r13
  406882:	49 89 fc             	mov    %rdi,%r12
  406885:	4d 89 fe             	mov    %r15,%r14
  406888:	0f 1f 84 00 00 00 00 00 	nopl   0x0(%rax,%rax,1)
  406890:	f3 44 0f 11 45 bc    	movss  %xmm8,-0x44(%rbp)
  406896:	f3 0f 11 65 b8       	movss  %xmm4,-0x48(%rbp)
  40689b:	f3 0f 11 5d b4       	movss  %xmm3,-0x4c(%rbp)
  4068a0:	f3 0f 11 55 b0       	movss  %xmm2,-0x50(%rbp)
  4068a5:	f3 0f 11 4d ac       	movss  %xmm1,-0x54(%rbp)
  4068aa:	f3 0f 11 45 a8       	movss  %xmm0,-0x58(%rbp)
  4068af:	48 83 fb 00          	cmp    $0x0,%rbx
  4068b3:	40 0f 94 c7          	sete   %dil
  4068b7:	40 0f b6 ff          	movzbl %dil,%edi
  4068bb:	49 83 fa 01          	cmp    $0x1,%r10
  4068bf:	0f 94 c0             	sete   %al
  4068c2:	0f b6 c0             	movzbl %al,%eax
  4068c5:	4c 89 d1             	mov    %r10,%rcx
  4068c8:	48 c1 e9 28          	shr    $0x28,%rcx
  4068cc:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4068d3:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  4068da:	0f 94 c1             	sete   %cl
  4068dd:	0f b6 c9             	movzbl %cl,%ecx
  4068e0:	41 89 c1             	mov    %eax,%r9d
  4068e3:	41 09 c9             	or     %ecx,%r9d
  4068e6:	83 ff 00             	cmp    $0x0,%edi
  4068e9:	0f 85 38 04 00 00    	jne    406d27 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x527>
  4068ef:	2e 2e 2e 48 89 df    	cs cs cs mov %rbx,%rdi
  4068f5:	48 83 eb 01          	sub    $0x1,%rbx
  4068f9:	41 89 df             	mov    %ebx,%r15d
  4068fc:	41 83 f1 01          	xor    $0x1,%r9d
  406900:	0f 85 4b 01 00 00    	jne    406a51 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x251>
  406906:	49 89 d5             	mov    %rdx,%r13
  406909:	4d 89 c6             	mov    %r8,%r14
  40690c:	09 c8                	or     %ecx,%eax
  40690e:	0f 84 0b 01 00 00    	je     406a1f <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x21f>
  406914:	48 89 de             	mov    %rbx,%rsi
  406917:	4c 89 e7             	mov    %r12,%rdi
  40691a:	e8 91 fd ff ff       	callq  4066b0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  40691f:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  406923:	48 89 de             	mov    %rbx,%rsi
  406926:	4c 89 e7             	mov    %r12,%rdi
  406929:	e8 b2 fc ff ff       	callq  4065e0 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  40692e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  406932:	48 89 de             	mov    %rbx,%rsi
  406935:	4c 89 e7             	mov    %r12,%rdi
  406938:	e8 d3 fb ff ff       	callq  406510 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  40693d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  406941:	48 89 de             	mov    %rbx,%rsi
  406944:	4c 89 e7             	mov    %r12,%rdi
  406947:	e8 f4 fa ff ff       	callq  406440 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  40694c:	f3 44 0f 10 45 bc    	movss  -0x44(%rbp),%xmm8
  406952:	f3 0f 10 65 b8       	movss  -0x48(%rbp),%xmm4
  406957:	f3 0f 10 5d b4       	movss  -0x4c(%rbp),%xmm3
  40695c:	f3 0f 10 55 b0       	movss  -0x50(%rbp),%xmm2
  406961:	f3 0f 10 4d ac       	movss  -0x54(%rbp),%xmm1
  406966:	f3 0f 10 45 a8       	movss  -0x58(%rbp),%xmm0
  40696b:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  40696f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  406973:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  406977:	f3 44 0f 10 c8       	movss  %xmm0,%xmm9
  40697c:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  406981:	f3 0f 10 f9          	movss  %xmm1,%xmm7
  406985:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  40698a:	f3 0f 10 f2          	movss  %xmm2,%xmm6
  40698e:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  406993:	f3 0f 10 eb          	movss  %xmm3,%xmm5
  406997:	66 48 0f 6e d8       	movq   %rax,%xmm3
  40699c:	48 83 ec 10          	sub    $0x10,%rsp
  4069a0:	48 89 e0             	mov    %rsp,%rax
  4069a3:	66 44 0f d6 48 08    	movq   %xmm9,0x8(%rax)
  4069a9:	66 0f d6 38          	movq   %xmm7,(%rax)
  4069ad:	f3 0f 10 fe          	movss  %xmm6,%xmm7
  4069b1:	f3 0f 10 f5          	movss  %xmm5,%xmm6
  4069b5:	f3 0f 10 ec          	movss  %xmm4,%xmm5
  4069b9:	f3 41 0f 10 e0       	movss  %xmm8,%xmm4
  4069be:	4c 89 e7             	mov    %r12,%rdi
  4069c1:	e8 4a f7 ff ff       	callq  406110 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  4069c6:	48 89 c1             	mov    %rax,%rcx
  4069c9:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  4069cd:	48 8b 75 98          	mov    -0x68(%rbp),%rsi
  4069d1:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  4069d5:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  4069d9:	f3 44 0f 10 45 bc    	movss  -0x44(%rbp),%xmm8
  4069df:	f3 0f 10 65 b8       	movss  -0x48(%rbp),%xmm4
  4069e4:	f3 0f 10 5d b4       	movss  -0x4c(%rbp),%xmm3
  4069e9:	f3 0f 10 55 b0       	movss  -0x50(%rbp),%xmm2
  4069ee:	f3 0f 10 4d ac       	movss  -0x54(%rbp),%xmm1
  4069f3:	f3 0f 10 45 a8       	movss  -0x58(%rbp),%xmm0
  4069f8:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  4069fc:	66 48 0f 6e e9       	movq   %rcx,%xmm5
  406a01:	66 49 0f 6e f5       	movq   %r13,%xmm6
  406a06:	0f 2e f5             	ucomiss %xmm5,%xmm6
  406a09:	41 0f 97 c0          	seta   %r8b
  406a0d:	45 0f b6 c0          	movzbl %r8b,%r8d
  406a11:	45 89 c2             	mov    %r8d,%r10d
  406a14:	48 89 ca             	mov    %rcx,%rdx
  406a17:	4d 89 f8             	mov    %r15,%r8
  406a1a:	e9 71 fe ff ff       	jmpq   406890 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x90>
  406a1f:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
  406a23:	4c 89 e7             	mov    %r12,%rdi
  406a26:	be 04 00 00 00       	mov    $0x4,%esi
  406a2b:	e8 f0 5f 02 00       	callq  42ca20 <p111_rt_fail>
  406a30:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  406a37:	48 c7 43 08 00 00 00 00 	movq   $0x0,0x8(%rbx)
  406a3f:	48 c7 43 10 00 00 00 00 	movq   $0x0,0x10(%rbx)
  406a47:	b8 00 00 00 00       	mov    $0x0,%eax
  406a4c:	e9 51 03 00 00       	jmpq   406da2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x5a2>
  406a51:	48 83 fb 00          	cmp    $0x0,%rbx
  406a55:	0f 94 c2             	sete   %dl
  406a58:	0f b6 d2             	movzbl %dl,%edx
  406a5b:	48 89 f9             	mov    %rdi,%rcx
  406a5e:	48 83 e9 02          	sub    $0x2,%rcx
  406a62:	48 89 f8             	mov    %rdi,%rax
  406a65:	48 83 e8 03          	sub    $0x3,%rax
  406a69:	49 89 fb             	mov    %rdi,%r11
  406a6c:	49 83 eb 04          	sub    $0x4,%r11
  406a70:	49 89 fa             	mov    %rdi,%r10
  406a73:	49 83 ea 05          	sub    $0x5,%r10
  406a77:	49 89 f9             	mov    %rdi,%r9
  406a7a:	49 83 e9 06          	sub    $0x6,%r9
  406a7e:	49 89 f8             	mov    %rdi,%r8
  406a81:	49 83 e8 07          	sub    $0x7,%r8
  406a85:	48 83 ef 08          	sub    $0x8,%rdi
  406a89:	83 fa 00             	cmp    $0x0,%edx
  406a8c:	48 89 f2             	mov    %rsi,%rdx
  406a8f:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  406a93:	75 69                	jne    406afe <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2fe>
  406a95:	48 83 f9 00          	cmp    $0x0,%rcx
  406a99:	74 5c                	je     406af7 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2f7>
  406a9b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  406aa0:	48 83 f8 00          	cmp    $0x0,%rax
  406aa4:	74 4a                	je     406af0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2f0>
  406aa6:	49 83 fb 00          	cmp    $0x0,%r11
  406aaa:	74 3d                	je     406ae9 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2e9>
  406aac:	49 83 fa 00          	cmp    $0x0,%r10
  406ab0:	74 30                	je     406ae2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2e2>
  406ab2:	49 83 f9 00          	cmp    $0x0,%r9
  406ab6:	74 23                	je     406adb <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2db>
  406ab8:	49 83 f8 00          	cmp    $0x0,%r8
  406abc:	74 16                	je     406ad4 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2d4>
  406abe:	48 89 f2             	mov    %rsi,%rdx
  406ac1:	48 83 ff 00          	cmp    $0x0,%rdi
  406ac5:	be 00 00 60 40       	mov    $0x40600000,%esi
  406aca:	48 0f 45 f2          	cmovne %rdx,%rsi
  406ace:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  406ad2:	eb 2f                	jmp    406b03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x303>
  406ad4:	be 00 00 00 00       	mov    $0x0,%esi
  406ad9:	eb 28                	jmp    406b03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x303>
  406adb:	be 00 00 80 bf       	mov    $0xbf800000,%esi
  406ae0:	eb 21                	jmp    406b03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x303>
  406ae2:	be 00 00 80 3f       	mov    $0x3f800000,%esi
  406ae7:	eb 1a                	jmp    406b03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x303>
  406ae9:	be 00 00 00 c0       	mov    $0xc0000000,%esi
  406aee:	eb 13                	jmp    406b03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x303>
  406af0:	be 00 00 00 40       	mov    $0x40000000,%esi
  406af5:	eb 0c                	jmp    406b03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x303>
  406af7:	be 00 00 00 00       	mov    $0x0,%esi
  406afc:	eb 05                	jmp    406b03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x303>
  406afe:	be 00 00 00 00       	mov    $0x0,%esi
  406b03:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  406b07:	48 83 fb 00          	cmp    $0x0,%rbx
  406b0b:	74 65                	je     406b72 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x372>
  406b0d:	48 83 f9 00          	cmp    $0x0,%rcx
  406b11:	74 58                	je     406b6b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x36b>
  406b13:	48 83 f8 00          	cmp    $0x0,%rax
  406b17:	74 4b                	je     406b64 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x364>
  406b19:	49 83 fb 00          	cmp    $0x0,%r11
  406b1d:	74 3e                	je     406b5d <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x35d>
  406b1f:	90                   	nop
  406b20:	49 83 fa 00          	cmp    $0x0,%r10
  406b24:	74 30                	je     406b56 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x356>
  406b26:	49 83 f9 00          	cmp    $0x0,%r9
  406b2a:	74 23                	je     406b4f <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x34f>
  406b2c:	49 83 f8 00          	cmp    $0x0,%r8
  406b30:	74 16                	je     406b48 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x348>
  406b32:	48 89 d6             	mov    %rdx,%rsi
  406b35:	48 83 ff 00          	cmp    $0x0,%rdi
  406b39:	ba cd cc 4c 3e       	mov    $0x3e4ccccd,%edx
  406b3e:	48 0f 45 d6          	cmovne %rsi,%rdx
  406b42:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  406b46:	eb 34                	jmp    406b7c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x37c>
  406b48:	ba cd cc cc 3f       	mov    $0x3fcccccd,%edx
  406b4d:	eb 2d                	jmp    406b7c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x37c>
  406b4f:	ba 9a 99 19 bf       	mov    $0xbf19999a,%edx
  406b54:	eb 26                	jmp    406b7c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x37c>
  406b56:	ba 9a 99 19 bf       	mov    $0xbf19999a,%edx
  406b5b:	eb 1f                	jmp    406b7c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x37c>
  406b5d:	ba 00 00 00 3f       	mov    $0x3f000000,%edx
  406b62:	eb 18                	jmp    406b7c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x37c>
  406b64:	ba 00 00 00 3f       	mov    $0x3f000000,%edx
  406b69:	eb 11                	jmp    406b7c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x37c>
  406b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  406b70:	eb 0a                	jmp    406b7c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x37c>
  406b72:	2e 2e 2e 2e 2e ba 00 44 1c c6 	cs cs cs cs cs mov $0xc61c4400,%edx
  406b7c:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  406b80:	48 83 fb 00          	cmp    $0x0,%rbx
  406b84:	74 7e                	je     406c04 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x404>
  406b86:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  406b8a:	48 83 f9 00          	cmp    $0x0,%rcx
  406b8e:	74 55                	je     406be5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3e5>
  406b90:	48 83 f8 00          	cmp    $0x0,%rax
  406b94:	74 48                	je     406bde <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3de>
  406b96:	49 83 fb 00          	cmp    $0x0,%r11
  406b9a:	74 3b                	je     406bd7 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d7>
  406b9c:	0f 1f 40 00          	nopl   0x0(%rax)
  406ba0:	49 83 fa 00          	cmp    $0x0,%r10
  406ba4:	74 2a                	je     406bd0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d0>
  406ba6:	49 83 f9 00          	cmp    $0x0,%r9
  406baa:	74 1d                	je     406bc9 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3c9>
  406bac:	49 83 f8 00          	cmp    $0x0,%r8
  406bb0:	74 10                	je     406bc2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3c2>
  406bb2:	2e 48 83 ff 00       	cs cmp $0x0,%rdi
  406bb7:	be 00 00 00 41       	mov    $0x41000000,%esi
  406bbc:	48 0f 44 d6          	cmove  %rsi,%rdx
  406bc0:	eb 28                	jmp    406bea <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ea>
  406bc2:	ba 00 00 e0 40       	mov    $0x40e00000,%edx
  406bc7:	eb 21                	jmp    406bea <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ea>
  406bc9:	ba 00 00 60 40       	mov    $0x40600000,%edx
  406bce:	eb 1a                	jmp    406bea <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ea>
  406bd0:	ba 00 00 60 40       	mov    $0x40600000,%edx
  406bd5:	eb 13                	jmp    406bea <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ea>
  406bd7:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  406bdc:	eb 0c                	jmp    406bea <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ea>
  406bde:	ba 00 00 c0 40       	mov    $0x40c00000,%edx
  406be3:	eb 05                	jmp    406bea <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ea>
  406be5:	ba 00 00 a0 40       	mov    $0x40a00000,%edx
  406bea:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  406bee:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  406bf2:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  406bf6:	f2 44 0f 10 7d c8    	movsd  -0x38(%rbp),%xmm15
  406bfc:	f2 44 0f 11 7d c0    	movsd  %xmm15,-0x40(%rbp)
  406c02:	eb 08                	jmp    406c0c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x40c>
  406c04:	48 c7 45 c0 00 00 a0 40 	movq   $0x40a00000,-0x40(%rbp)
  406c0c:	48 83 fb 00          	cmp    $0x0,%rbx
  406c10:	74 65                	je     406c77 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x477>
  406c12:	48 83 f9 00          	cmp    $0x0,%rcx
  406c16:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  406c1a:	74 54                	je     406c70 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x470>
  406c1c:	48 83 f8 00          	cmp    $0x0,%rax
  406c20:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  406c24:	74 43                	je     406c69 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x469>
  406c26:	49 83 fb 00          	cmp    $0x0,%r11
  406c2a:	74 36                	je     406c62 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x462>
  406c2c:	49 83 fa 00          	cmp    $0x0,%r10
  406c30:	74 29                	je     406c5b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x45b>
  406c32:	49 83 f9 00          	cmp    $0x0,%r9
  406c36:	74 1c                	je     406c54 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x454>
  406c38:	49 83 f8 00          	cmp    $0x0,%r8
  406c3c:	74 0f                	je     406c4d <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x44d>
  406c3e:	48 83 ff 00          	cmp    $0x0,%rdi
  406c42:	bf 00 00 80 3f       	mov    $0x3f800000,%edi
  406c47:	48 0f 44 c7          	cmove  %rdi,%rax
  406c4b:	eb 33                	jmp    406c80 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x480>
  406c4d:	b8 9a 99 99 3f       	mov    $0x3f99999a,%eax
  406c52:	eb 2c                	jmp    406c80 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x480>
  406c54:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  406c59:	eb 25                	jmp    406c80 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x480>
  406c5b:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  406c60:	eb 1e                	jmp    406c80 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x480>
  406c62:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  406c67:	eb 17                	jmp    406c80 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x480>
  406c69:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  406c6e:	eb 10                	jmp    406c80 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x480>
  406c70:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  406c75:	eb 09                	jmp    406c80 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x480>
  406c77:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  406c7b:	b8 00 40 1c 46       	mov    $0x461c4000,%eax
  406c80:	f3 44 0f 10 c8       	movss  %xmm0,%xmm9
  406c85:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  406c8a:	f3 0f 10 f9          	movss  %xmm1,%xmm7
  406c8e:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  406c93:	f3 0f 10 f2          	movss  %xmm2,%xmm6
  406c97:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  406c9c:	f3 0f 10 eb          	movss  %xmm3,%xmm5
  406ca0:	66 48 0f 6e d8       	movq   %rax,%xmm3
  406ca5:	48 83 ec 10          	sub    $0x10,%rsp
  406ca9:	48 89 e0             	mov    %rsp,%rax
  406cac:	66 44 0f d6 48 08    	movq   %xmm9,0x8(%rax)
  406cb2:	66 0f d6 38          	movq   %xmm7,(%rax)
  406cb6:	f3 0f 10 fe          	movss  %xmm6,%xmm7
  406cba:	f3 0f 10 f5          	movss  %xmm5,%xmm6
  406cbe:	f3 0f 10 ec          	movss  %xmm4,%xmm5
  406cc2:	f3 41 0f 10 e0       	movss  %xmm8,%xmm4
  406cc7:	4c 89 e7             	mov    %r12,%rdi
  406cca:	e8 41 f4 ff ff       	callq  406110 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  406ccf:	49 97                	xchg   %rax,%r15
  406cd1:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  406cd5:	48 8b 75 98          	mov    -0x68(%rbp),%rsi
  406cd9:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  406cdd:	48 8b 4d 88          	mov    -0x78(%rbp),%rcx
  406ce1:	f3 44 0f 10 45 bc    	movss  -0x44(%rbp),%xmm8
  406ce7:	f3 0f 10 65 b8       	movss  -0x48(%rbp),%xmm4
  406cec:	f3 0f 10 5d b4       	movss  -0x4c(%rbp),%xmm3
  406cf1:	f3 0f 10 55 b0       	movss  -0x50(%rbp),%xmm2
  406cf6:	f3 0f 10 4d ac       	movss  -0x54(%rbp),%xmm1
  406cfb:	f3 0f 10 45 a8       	movss  -0x58(%rbp),%xmm0
  406d00:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  406d04:	66 49 0f 6e ef       	movq   %r15,%xmm5
  406d09:	66 49 0f 6e f5       	movq   %r13,%xmm6
  406d0e:	0f 2e f5             	ucomiss %xmm5,%xmm6
  406d11:	41 0f 97 c0          	seta   %r8b
  406d15:	45 0f b6 c0          	movzbl %r8b,%r8d
  406d19:	45 89 c2             	mov    %r8d,%r10d
  406d1c:	4c 89 fa             	mov    %r15,%rdx
  406d1f:	49 89 c0             	mov    %rax,%r8
  406d22:	e9 69 fb ff ff       	jmpq   406890 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x90>
  406d27:	48 8b 5d 80          	mov    -0x80(%rbp),%rbx
  406d2b:	4c 89 e7             	mov    %r12,%rdi
  406d2e:	44 89 ce             	mov    %r9d,%esi
  406d31:	83 f6 01             	xor    $0x1,%esi
  406d34:	75 4d                	jne    406d83 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x583>
  406d36:	09 c8                	or     %ecx,%eax
  406d38:	75 28                	jne    406d62 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x562>
  406d3a:	be 04 00 00 00       	mov    $0x4,%esi
  406d3f:	e8 dc 5c 02 00       	callq  42ca20 <p111_rt_fail>
  406d44:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  406d4b:	48 c7 43 08 00 00 00 00 	movq   $0x0,0x8(%rbx)
  406d53:	48 c7 43 10 00 00 00 00 	movq   $0x0,0x10(%rbx)
  406d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  406d60:	eb 40                	jmp    406da2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x5a2>
  406d62:	44 89 c0             	mov    %r8d,%eax
  406d65:	48 83 f8 09          	cmp    $0x9,%rax
  406d69:	0f 94 c0             	sete   %al
  406d6c:	0f b6 c0             	movzbl %al,%eax
  406d6f:	89 c0                	mov    %eax,%eax
  406d71:	48 89 03             	mov    %rax,(%rbx)
  406d74:	48 89 53 08          	mov    %rdx,0x8(%rbx)
  406d78:	4c 89 43 10          	mov    %r8,0x10(%rbx)
  406d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  406d81:	eb 1f                	jmp    406da2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x5a2>
  406d83:	44 89 f0             	mov    %r14d,%eax
  406d86:	48 83 f8 09          	cmp    $0x9,%rax
  406d8a:	0f 94 c0             	sete   %al
  406d8d:	0f b6 c0             	movzbl %al,%eax
  406d90:	89 c0                	mov    %eax,%eax
  406d92:	48 89 03             	mov    %rax,(%rbx)
  406d95:	4c 89 6b 08          	mov    %r13,0x8(%rbx)
  406d99:	4c 89 73 10          	mov    %r14,0x10(%rbx)
  406d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  406da2:	41 5f                	pop    %r15
  406da4:	41 5e                	pop    %r14
  406da6:	41 5d                	pop    %r13
  406da8:	41 5c                	pop    %r12
  406daa:	5b                   	pop    %rbx
  406dab:	c9                   	leaveq 
  406dac:	c3                   	retq   
  406dad:	0f 1f 00             	nopl   (%rax)

