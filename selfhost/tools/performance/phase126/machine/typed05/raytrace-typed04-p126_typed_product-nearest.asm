0000000000406840 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  406840:	f3 0f 1e fa          	endbr64 
  406844:	55                   	push   %rbp
  406845:	48 89 e5             	mov    %rsp,%rbp
  406848:	48 81 ec 78 08 00 00 	sub    $0x878,%rsp
  40684f:	53                   	push   %rbx
  406850:	41 54                	push   %r12
  406852:	41 55                	push   %r13
  406854:	41 56                	push   %r14
  406856:	41 57                	push   %r15
  406858:	4c 8b 55 18          	mov    0x18(%rbp),%r10
  40685c:	4c 8b 75 10          	mov    0x10(%rbp),%r14
  406860:	4d 89 cc             	mov    %r9,%r12
  406863:	4d 89 c7             	mov    %r8,%r15
  406866:	49 89 cd             	mov    %rcx,%r13
  406869:	48 89 d3             	mov    %rdx,%rbx
  40686c:	48 89 75 90          	mov    %rsi,-0x70(%rbp)
  406870:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  406875:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  406879:	ba 00 00 00 41       	mov    $0x41000000,%edx
  40687e:	48 89 55 a0          	mov    %rdx,-0x60(%rbp)
  406882:	be cd cc 4c 3e       	mov    $0x3e4ccccd,%esi
  406887:	48 89 75 a8          	mov    %rsi,-0x58(%rbp)
  40688b:	b9 00 00 60 c0       	mov    $0xc0600000,%ecx
  406890:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  406894:	f3 44 0f 10 c4       	movss  %xmm4,%xmm8
  406899:	f3 44 0f 10 cd       	movss  %xmm5,%xmm9
  40689e:	4d 89 f8             	mov    %r15,%r8
  4068a1:	4d 89 f7             	mov    %r14,%r15
  4068a4:	4d 89 ee             	mov    %r13,%r14
  4068a7:	4d 89 e5             	mov    %r12,%r13
  4068aa:	49 89 fc             	mov    %rdi,%r12
  4068ad:	0f 1f 00             	nopl   (%rax)
  4068b0:	f3 0f 11 45 fc       	movss  %xmm0,-0x4(%rbp)
  4068b5:	f3 0f 11 4d f8       	movss  %xmm1,-0x8(%rbp)
  4068ba:	f3 0f 11 55 f4       	movss  %xmm2,-0xc(%rbp)
  4068bf:	f3 0f 11 5d f0       	movss  %xmm3,-0x10(%rbp)
  4068c4:	f3 44 0f 11 45 dc    	movss  %xmm8,-0x24(%rbp)
  4068ca:	f3 44 0f 11 4d d8    	movss  %xmm9,-0x28(%rbp)
  4068d0:	48 83 fb 00          	cmp    $0x0,%rbx
  4068d4:	0f 94 c2             	sete   %dl
  4068d7:	0f b6 d2             	movzbl %dl,%edx
  4068da:	49 83 fa 01          	cmp    $0x1,%r10
  4068de:	0f 94 c0             	sete   %al
  4068e1:	0f b6 c0             	movzbl %al,%eax
  4068e4:	4c 89 d1             	mov    %r10,%rcx
  4068e7:	48 c1 e9 28          	shr    $0x28,%rcx
  4068eb:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  4068f2:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  4068f9:	0f 94 c1             	sete   %cl
  4068fc:	0f b6 c9             	movzbl %cl,%ecx
  4068ff:	41 89 c1             	mov    %eax,%r9d
  406902:	41 09 c9             	or     %ecx,%r9d
  406905:	83 fa 00             	cmp    $0x0,%edx
  406908:	0f 85 f7 04 00 00    	jne    406e05 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x5c5>
  40690e:	48 89 df             	mov    %rbx,%rdi
  406911:	48 83 eb 01          	sub    $0x1,%rbx
  406915:	66 48 0f 7e c2       	movq   %xmm0,%rdx
  40691a:	89 d2                	mov    %edx,%edx
  40691c:	66 48 0f 7e ce       	movq   %xmm1,%rsi
  406921:	89 f6                	mov    %esi,%esi
  406923:	66 49 0f 7e d2       	movq   %xmm2,%r10
  406928:	45 89 d3             	mov    %r10d,%r11d
  40692b:	66 49 0f 7e da       	movq   %xmm3,%r10
  406930:	45 89 d2             	mov    %r10d,%r10d
  406933:	66 48 0f 6e c2       	movq   %rdx,%xmm0
  406938:	f3 0f 11 45 b8       	movss  %xmm0,-0x48(%rbp)
  40693d:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  406941:	66 48 0f 6e ce       	movq   %rsi,%xmm1
  406946:	f3 0f 11 4d bc       	movss  %xmm1,-0x44(%rbp)
  40694b:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  40694f:	66 49 0f 6e d3       	movq   %r11,%xmm2
  406954:	f3 0f 11 55 c0       	movss  %xmm2,-0x40(%rbp)
  406959:	66 49 0f 6e da       	movq   %r10,%xmm3
  40695e:	f3 0f 11 5d c4       	movss  %xmm3,-0x3c(%rbp)
  406963:	41 83 f1 01          	xor    $0x1,%r9d
  406967:	0f 85 6d 01 00 00    	jne    406ada <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x29a>
  40696d:	4d 89 f5             	mov    %r14,%r13
  406970:	4d 89 c7             	mov    %r8,%r15
  406973:	09 c8                	or     %ecx,%eax
  406975:	0f 84 2d 01 00 00    	je     406aa8 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x268>
  40697b:	48 89 de             	mov    %rbx,%rsi
  40697e:	4c 89 e7             	mov    %r12,%rdi
  406981:	e8 6a fd ff ff       	callq  4066f0 <p113d_FID_36_100_105_114_101_99_116_46_115_120_>
  406986:	49 89 c6             	mov    %rax,%r14
  406989:	48 89 de             	mov    %rbx,%rsi
  40698c:	4c 89 e7             	mov    %r12,%rdi
  40698f:	e8 8c fc ff ff       	callq  406620 <p113d_FID_36_100_105_114_101_99_116_46_115_121_>
  406994:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  406998:	48 89 de             	mov    %rbx,%rsi
  40699b:	4c 89 e7             	mov    %r12,%rdi
  40699e:	e8 ad fb ff ff       	callq  406550 <p113d_FID_36_100_105_114_101_99_116_46_115_122_>
  4069a3:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  4069a7:	48 89 de             	mov    %rbx,%rsi
  4069aa:	4c 89 e7             	mov    %r12,%rdi
  4069ad:	e8 ce fa ff ff       	callq  406480 <p113d_FID_36_100_105_114_101_99_116_46_115_114_>
  4069b2:	f3 0f 10 45 fc       	movss  -0x4(%rbp),%xmm0
  4069b7:	f3 0f 10 4d f8       	movss  -0x8(%rbp),%xmm1
  4069bc:	f3 0f 10 55 f4       	movss  -0xc(%rbp),%xmm2
  4069c1:	f3 0f 10 5d f0       	movss  -0x10(%rbp),%xmm3
  4069c6:	f3 44 0f 10 45 dc    	movss  -0x24(%rbp),%xmm8
  4069cc:	f3 44 0f 10 4d d8    	movss  -0x28(%rbp),%xmm9
  4069d2:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  4069d6:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  4069da:	f3 0f 10 e0          	movss  %xmm0,%xmm4
  4069de:	66 49 0f 6e c6       	movq   %r14,%xmm0
  4069e3:	f3 0f 10 e9          	movss  %xmm1,%xmm5
  4069e7:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  4069ec:	f3 0f 10 f2          	movss  %xmm2,%xmm6
  4069f0:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  4069f5:	f3 0f 10 fb          	movss  %xmm3,%xmm7
  4069f9:	66 48 0f 6e d8       	movq   %rax,%xmm3
  4069fe:	48 83 ec 10          	sub    $0x10,%rsp
  406a02:	48 89 e0             	mov    %rsp,%rax
  406a05:	66 44 0f d6 48 08    	movq   %xmm9,0x8(%rax)
  406a0b:	66 44 0f d6 00       	movq   %xmm8,(%rax)
  406a10:	4c 89 e7             	mov    %r12,%rdi
  406a13:	e8 f8 f6 ff ff       	callq  406110 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  406a18:	49 89 c6             	mov    %rax,%r14
  406a1b:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  406a1f:	48 89 9d 90 f7 ff ff 	mov    %rbx,-0x870(%rbp)
  406a26:	b9 01 00 00 00       	mov    $0x1,%ecx
  406a2b:	48 8d 95 90 f7 ff ff 	lea    -0x870(%rbp),%rdx
  406a32:	be 19 00 00 00       	mov    $0x19,%esi
  406a37:	4c 89 e7             	mov    %r12,%rdi
  406a3a:	e8 e1 63 02 00       	callq  42ce20 <p111_rt_op>
  406a3f:	48 89 c7             	mov    %rax,%rdi
  406a42:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  406a46:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  406a4a:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  406a4e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  406a52:	f3 0f 10 65 dc       	movss  -0x24(%rbp),%xmm4
  406a57:	f3 0f 10 6d d8       	movss  -0x28(%rbp),%xmm5
  406a5c:	f3 0f 10 5d c4       	movss  -0x3c(%rbp),%xmm3
  406a61:	f3 0f 10 55 c0       	movss  -0x40(%rbp),%xmm2
  406a66:	f3 0f 10 4d bc       	movss  -0x44(%rbp),%xmm1
  406a6b:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  406a70:	4c 89 b5 90 f7 ff ff 	mov    %r14,-0x870(%rbp)
  406a77:	4c 89 ad 98 f7 ff ff 	mov    %r13,-0x868(%rbp)
  406a7e:	f3 44 0f 10 c4       	movss  %xmm4,%xmm8
  406a83:	66 49 0f 6e e6       	movq   %r14,%xmm4
  406a88:	f3 44 0f 10 cd       	movss  %xmm5,%xmm9
  406a8d:	66 49 0f 6e ed       	movq   %r13,%xmm5
  406a92:	0f 2e ec             	ucomiss %xmm4,%xmm5
  406a95:	41 0f 97 c0          	seta   %r8b
  406a99:	45 0f b6 c0          	movzbl %r8b,%r8d
  406a9d:	45 89 c2             	mov    %r8d,%r10d
  406aa0:	49 89 f8             	mov    %rdi,%r8
  406aa3:	e9 08 fe ff ff       	jmpq   4068b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x70>
  406aa8:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  406aac:	4c 89 e7             	mov    %r12,%rdi
  406aaf:	be 04 00 00 00       	mov    $0x4,%esi
  406ab4:	e8 47 63 02 00       	callq  42ce00 <p111_rt_fail>
  406ab9:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  406ac0:	48 c7 43 08 00 00 00 00 	movq   $0x0,0x8(%rbx)
  406ac8:	48 c7 43 10 00 00 00 00 	movq   $0x0,0x10(%rbx)
  406ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  406ad5:	e9 a8 03 00 00       	jmpq   406e82 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x642>
  406ada:	48 83 fb 00          	cmp    $0x0,%rbx
  406ade:	0f 94 c1             	sete   %cl
  406ae1:	0f b6 c9             	movzbl %cl,%ecx
  406ae4:	48 89 f8             	mov    %rdi,%rax
  406ae7:	48 83 e8 02          	sub    $0x2,%rax
  406aeb:	49 89 fe             	mov    %rdi,%r14
  406aee:	49 83 ee 03          	sub    $0x3,%r14
  406af2:	49 89 fb             	mov    %rdi,%r11
  406af5:	49 83 eb 04          	sub    $0x4,%r11
  406af9:	49 89 fa             	mov    %rdi,%r10
  406afc:	49 83 ea 05          	sub    $0x5,%r10
  406b00:	49 89 f9             	mov    %rdi,%r9
  406b03:	49 83 e9 06          	sub    $0x6,%r9
  406b07:	49 89 f8             	mov    %rdi,%r8
  406b0a:	49 83 e8 07          	sub    $0x7,%r8
  406b0e:	48 83 ef 08          	sub    $0x8,%rdi
  406b12:	83 f9 00             	cmp    $0x0,%ecx
  406b15:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  406b19:	0f 85 8b 00 00 00    	jne    406baa <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x36a>
  406b1f:	90                   	nop
  406b20:	48 83 f8 00          	cmp    $0x0,%rax
  406b24:	74 77                	je     406b9d <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x35d>
  406b26:	49 83 fe 00          	cmp    $0x0,%r14
  406b2a:	74 64                	je     406b90 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x350>
  406b2c:	49 83 fb 00          	cmp    $0x0,%r11
  406b30:	74 51                	je     406b83 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x343>
  406b32:	49 83 fa 00          	cmp    $0x0,%r10
  406b36:	74 3e                	je     406b76 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x336>
  406b38:	49 83 f9 00          	cmp    $0x0,%r9
  406b3c:	74 2b                	je     406b69 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x329>
  406b3e:	66 90                	xchg   %ax,%ax
  406b40:	49 83 f8 00          	cmp    $0x0,%r8
  406b44:	74 16                	je     406b5c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x31c>
  406b46:	48 83 ff 00          	cmp    $0x0,%rdi
  406b4a:	be 00 00 60 40       	mov    $0x40600000,%esi
  406b4f:	48 0f 45 f1          	cmovne %rcx,%rsi
  406b53:	48 89 d1             	mov    %rdx,%rcx
  406b56:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  406b5a:	eb 59                	jmp    406bb5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x375>
  406b5c:	48 89 d1             	mov    %rdx,%rcx
  406b5f:	48 89 f2             	mov    %rsi,%rdx
  406b62:	be 00 00 00 00       	mov    $0x0,%esi
  406b67:	eb 4c                	jmp    406bb5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x375>
  406b69:	48 89 d1             	mov    %rdx,%rcx
  406b6c:	48 89 f2             	mov    %rsi,%rdx
  406b6f:	be 00 00 80 bf       	mov    $0xbf800000,%esi
  406b74:	eb 3f                	jmp    406bb5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x375>
  406b76:	48 89 d1             	mov    %rdx,%rcx
  406b79:	48 89 f2             	mov    %rsi,%rdx
  406b7c:	be 00 00 80 3f       	mov    $0x3f800000,%esi
  406b81:	eb 32                	jmp    406bb5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x375>
  406b83:	48 89 d1             	mov    %rdx,%rcx
  406b86:	48 89 f2             	mov    %rsi,%rdx
  406b89:	be 00 00 00 c0       	mov    $0xc0000000,%esi
  406b8e:	eb 25                	jmp    406bb5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x375>
  406b90:	48 89 d1             	mov    %rdx,%rcx
  406b93:	48 89 f2             	mov    %rsi,%rdx
  406b96:	be 00 00 00 40       	mov    $0x40000000,%esi
  406b9b:	eb 18                	jmp    406bb5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x375>
  406b9d:	48 89 d1             	mov    %rdx,%rcx
  406ba0:	48 89 f2             	mov    %rsi,%rdx
  406ba3:	be 00 00 00 00       	mov    $0x0,%esi
  406ba8:	eb 0b                	jmp    406bb5 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x375>
  406baa:	48 89 d1             	mov    %rdx,%rcx
  406bad:	48 89 f2             	mov    %rsi,%rdx
  406bb0:	be 00 00 00 00       	mov    $0x0,%esi
  406bb5:	48 83 fb 00          	cmp    $0x0,%rbx
  406bb9:	74 6b                	je     406c26 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3e6>
  406bbb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  406bc0:	48 83 f8 00          	cmp    $0x0,%rax
  406bc4:	74 59                	je     406c1f <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3df>
  406bc6:	49 83 fe 00          	cmp    $0x0,%r14
  406bca:	74 4c                	je     406c18 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d8>
  406bcc:	49 83 fb 00          	cmp    $0x0,%r11
  406bd0:	74 3f                	je     406c11 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3d1>
  406bd2:	49 83 fa 00          	cmp    $0x0,%r10
  406bd6:	74 32                	je     406c0a <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3ca>
  406bd8:	49 83 f9 00          	cmp    $0x0,%r9
  406bdc:	74 25                	je     406c03 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3c3>
  406bde:	66 90                	xchg   %ax,%ax
  406be0:	49 83 f8 00          	cmp    $0x0,%r8
  406be4:	74 16                	je     406bfc <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3bc>
  406be6:	48 89 d1             	mov    %rdx,%rcx
  406be9:	48 83 ff 00          	cmp    $0x0,%rdi
  406bed:	ba cd cc 4c 3e       	mov    $0x3e4ccccd,%edx
  406bf2:	48 0f 45 d1          	cmovne %rcx,%rdx
  406bf6:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  406bfa:	eb 2f                	jmp    406c2b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3eb>
  406bfc:	ba cd cc cc 3f       	mov    $0x3fcccccd,%edx
  406c01:	eb 28                	jmp    406c2b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3eb>
  406c03:	ba 9a 99 19 bf       	mov    $0xbf19999a,%edx
  406c08:	eb 21                	jmp    406c2b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3eb>
  406c0a:	ba 9a 99 19 bf       	mov    $0xbf19999a,%edx
  406c0f:	eb 1a                	jmp    406c2b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3eb>
  406c11:	ba 00 00 00 3f       	mov    $0x3f000000,%edx
  406c16:	eb 13                	jmp    406c2b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3eb>
  406c18:	ba 00 00 00 3f       	mov    $0x3f000000,%edx
  406c1d:	eb 0c                	jmp    406c2b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3eb>
  406c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  406c24:	eb 05                	jmp    406c2b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x3eb>
  406c26:	ba 00 44 1c c6       	mov    $0xc61c4400,%edx
  406c2b:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  406c2f:	48 83 fb 00          	cmp    $0x0,%rbx
  406c33:	74 69                	je     406c9e <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x45e>
  406c35:	48 83 f8 00          	cmp    $0x0,%rax
  406c39:	74 5c                	je     406c97 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x457>
  406c3b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  406c40:	49 83 fe 00          	cmp    $0x0,%r14
  406c44:	74 4a                	je     406c90 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x450>
  406c46:	49 83 fb 00          	cmp    $0x0,%r11
  406c4a:	74 3d                	je     406c89 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x449>
  406c4c:	49 83 fa 00          	cmp    $0x0,%r10
  406c50:	74 30                	je     406c82 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x442>
  406c52:	49 83 f9 00          	cmp    $0x0,%r9
  406c56:	74 23                	je     406c7b <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x43b>
  406c58:	49 83 f8 00          	cmp    $0x0,%r8
  406c5c:	74 16                	je     406c74 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x434>
  406c5e:	48 89 ca             	mov    %rcx,%rdx
  406c61:	48 83 ff 00          	cmp    $0x0,%rdi
  406c65:	b9 00 00 00 41       	mov    $0x41000000,%ecx
  406c6a:	48 0f 45 ca          	cmovne %rdx,%rcx
  406c6e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  406c72:	eb 2f                	jmp    406ca3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406c74:	b9 00 00 e0 40       	mov    $0x40e00000,%ecx
  406c79:	eb 28                	jmp    406ca3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406c7b:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  406c80:	eb 21                	jmp    406ca3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406c82:	b9 00 00 60 40       	mov    $0x40600000,%ecx
  406c87:	eb 1a                	jmp    406ca3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406c89:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  406c8e:	eb 13                	jmp    406ca3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406c90:	b9 00 00 c0 40       	mov    $0x40c00000,%ecx
  406c95:	eb 0c                	jmp    406ca3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406c97:	b9 00 00 a0 40       	mov    $0x40a00000,%ecx
  406c9c:	eb 05                	jmp    406ca3 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x463>
  406c9e:	b9 00 00 a0 40       	mov    $0x40a00000,%ecx
  406ca3:	48 83 fb 00          	cmp    $0x0,%rbx
  406ca7:	74 63                	je     406d0c <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4cc>
  406ca9:	48 83 f8 00          	cmp    $0x0,%rax
  406cad:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  406cb1:	74 52                	je     406d05 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4c5>
  406cb3:	49 83 fe 00          	cmp    $0x0,%r14
  406cb7:	74 45                	je     406cfe <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4be>
  406cb9:	49 83 fb 00          	cmp    $0x0,%r11
  406cbd:	74 38                	je     406cf7 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4b7>
  406cbf:	90                   	nop
  406cc0:	49 83 fa 00          	cmp    $0x0,%r10
  406cc4:	74 2a                	je     406cf0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4b0>
  406cc6:	49 83 f9 00          	cmp    $0x0,%r9
  406cca:	74 1d                	je     406ce9 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4a9>
  406ccc:	49 83 f8 00          	cmp    $0x0,%r8
  406cd0:	74 10                	je     406ce2 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4a2>
  406cd2:	2e 48 83 ff 00       	cs cmp $0x0,%rdi
  406cd7:	bf 00 00 80 3f       	mov    $0x3f800000,%edi
  406cdc:	48 0f 44 c7          	cmove  %rdi,%rax
  406ce0:	eb 34                	jmp    406d16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4d6>
  406ce2:	b8 9a 99 99 3f       	mov    $0x3f99999a,%eax
  406ce7:	eb 2d                	jmp    406d16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4d6>
  406ce9:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  406cee:	eb 26                	jmp    406d16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4d6>
  406cf0:	b8 cd cc cc 3e       	mov    $0x3ecccccd,%eax
  406cf5:	eb 1f                	jmp    406d16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4d6>
  406cf7:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  406cfc:	eb 18                	jmp    406d16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4d6>
  406cfe:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  406d03:	eb 11                	jmp    406d16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4d6>
  406d05:	b8 00 00 80 3f       	mov    $0x3f800000,%eax
  406d0a:	eb 0a                	jmp    406d16 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4d6>
  406d0c:	2e 2e 2e 2e 2e b8 00 40 1c 46 	cs cs cs cs cs mov $0x461c4000,%eax
  406d16:	f3 0f 10 e0          	movss  %xmm0,%xmm4
  406d1a:	66 48 0f 6e c6       	movq   %rsi,%xmm0
  406d1f:	f3 0f 10 e9          	movss  %xmm1,%xmm5
  406d23:	66 48 0f 6e ca       	movq   %rdx,%xmm1
  406d28:	f3 0f 10 f2          	movss  %xmm2,%xmm6
  406d2c:	66 48 0f 6e d1       	movq   %rcx,%xmm2
  406d31:	f3 0f 10 fb          	movss  %xmm3,%xmm7
  406d35:	66 48 0f 6e d8       	movq   %rax,%xmm3
  406d3a:	66 4c 0f 7e c0       	movq   %xmm8,%rax
  406d3f:	89 c0                	mov    %eax,%eax
  406d41:	66 4c 0f 6e c0       	movq   %rax,%xmm8
  406d46:	f3 44 0f 11 45 c8    	movss  %xmm8,-0x38(%rbp)
  406d4c:	66 4c 0f 7e c8       	movq   %xmm9,%rax
  406d51:	89 c0                	mov    %eax,%eax
  406d53:	66 4c 0f 6e c8       	movq   %rax,%xmm9
  406d58:	f3 44 0f 11 4d cc    	movss  %xmm9,-0x34(%rbp)
  406d5e:	48 83 ec 10          	sub    $0x10,%rsp
  406d62:	48 89 e0             	mov    %rsp,%rax
  406d65:	66 44 0f d6 48 08    	movq   %xmm9,0x8(%rax)
  406d6b:	66 44 0f d6 00       	movq   %xmm8,(%rax)
  406d70:	4c 89 e7             	mov    %r12,%rdi
  406d73:	e8 98 f3 ff ff       	callq  406110 <p126_typed_FID_36_100_105_114_101_99_116_46_105_115_101_99_116_53_>
  406d78:	49 89 c6             	mov    %rax,%r14
  406d7b:	48 83 ec f0          	sub    $0xfffffffffffffff0,%rsp
  406d7f:	48 89 9d 90 f7 ff ff 	mov    %rbx,-0x870(%rbp)
  406d86:	b9 01 00 00 00       	mov    $0x1,%ecx
  406d8b:	48 8d 95 90 f7 ff ff 	lea    -0x870(%rbp),%rdx
  406d92:	be 19 00 00 00       	mov    $0x19,%esi
  406d97:	4c 89 e7             	mov    %r12,%rdi
  406d9a:	e8 81 60 02 00       	callq  42ce20 <p111_rt_op>
  406d9f:	48 8b 7d b0          	mov    -0x50(%rbp),%rdi
  406da3:	48 8b 75 a8          	mov    -0x58(%rbp),%rsi
  406da7:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  406dab:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
  406daf:	f3 0f 10 5d c4       	movss  -0x3c(%rbp),%xmm3
  406db4:	f3 0f 10 55 c0       	movss  -0x40(%rbp),%xmm2
  406db9:	f3 0f 10 4d bc       	movss  -0x44(%rbp),%xmm1
  406dbe:	f3 0f 10 45 b8       	movss  -0x48(%rbp),%xmm0
  406dc3:	f3 0f 10 6d cc       	movss  -0x34(%rbp),%xmm5
  406dc8:	f3 0f 10 65 c8       	movss  -0x38(%rbp),%xmm4
  406dcd:	4c 89 b5 90 f7 ff ff 	mov    %r14,-0x870(%rbp)
  406dd4:	4c 89 ad 98 f7 ff ff 	mov    %r13,-0x868(%rbp)
  406ddb:	66 49 0f 6e f6       	movq   %r14,%xmm6
  406de0:	66 49 0f 6e fd       	movq   %r13,%xmm7
  406de5:	0f 2e fe             	ucomiss %xmm6,%xmm7
  406de8:	41 0f 97 c0          	seta   %r8b
  406dec:	45 0f b6 c0          	movzbl %r8b,%r8d
  406df0:	45 89 c2             	mov    %r8d,%r10d
  406df3:	f3 44 0f 10 c4       	movss  %xmm4,%xmm8
  406df8:	f3 44 0f 10 cd       	movss  %xmm5,%xmm9
  406dfd:	49 89 c0             	mov    %rax,%r8
  406e00:	e9 ab fa ff ff       	jmpq   4068b0 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x70>
  406e05:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  406e09:	4c 89 e7             	mov    %r12,%rdi
  406e0c:	44 89 ca             	mov    %r9d,%edx
  406e0f:	83 f2 01             	xor    $0x1,%edx
  406e12:	75 4f                	jne    406e63 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x623>
  406e14:	09 c8                	or     %ecx,%eax
  406e16:	75 2a                	jne    406e42 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x602>
  406e18:	2e 2e be 04 00 00 00 	cs cs mov $0x4,%esi
  406e1f:	e8 dc 5f 02 00       	callq  42ce00 <p111_rt_fail>
  406e24:	48 c7 03 00 00 00 00 	movq   $0x0,(%rbx)
  406e2b:	48 c7 43 08 00 00 00 00 	movq   $0x0,0x8(%rbx)
  406e33:	48 c7 43 10 00 00 00 00 	movq   $0x0,0x10(%rbx)
  406e3b:	b8 00 00 00 00       	mov    $0x0,%eax
  406e40:	eb 40                	jmp    406e82 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x642>
  406e42:	44 89 c0             	mov    %r8d,%eax
  406e45:	48 83 f8 09          	cmp    $0x9,%rax
  406e49:	0f 94 c0             	sete   %al
  406e4c:	0f b6 c0             	movzbl %al,%eax
  406e4f:	89 c0                	mov    %eax,%eax
  406e51:	48 89 03             	mov    %rax,(%rbx)
  406e54:	4c 89 73 08          	mov    %r14,0x8(%rbx)
  406e58:	4c 89 43 10          	mov    %r8,0x10(%rbx)
  406e5c:	b8 00 00 00 00       	mov    $0x0,%eax
  406e61:	eb 1f                	jmp    406e82 <p126_typed_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x642>
  406e63:	44 89 f8             	mov    %r15d,%eax
  406e66:	48 83 f8 09          	cmp    $0x9,%rax
  406e6a:	0f 94 c0             	sete   %al
  406e6d:	0f b6 c0             	movzbl %al,%eax
  406e70:	89 c0                	mov    %eax,%eax
  406e72:	48 89 03             	mov    %rax,(%rbx)
  406e75:	4c 89 6b 08          	mov    %r13,0x8(%rbx)
  406e79:	4c 89 7b 10          	mov    %r15,0x10(%rbx)
  406e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  406e82:	41 5f                	pop    %r15
  406e84:	41 5e                	pop    %r14
  406e86:	41 5d                	pop    %r13
  406e88:	41 5c                	pop    %r12
  406e8a:	5b                   	pop    %rbx
  406e8b:	c9                   	leaveq 
  406e8c:	c3                   	retq   
  406e8d:	0f 1f 00             	nopl   (%rax)

