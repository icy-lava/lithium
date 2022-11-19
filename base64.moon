import byte, format from string
import floor from math
import array from require 'lithium.common'

with {}
	bmap = {[0]:'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'}
	ibmap = {A:0,B:1,C:2,D:3,E:4,F:5,G:6,H:7,I:8,J:9,K:10,L:11,M:12,N:13,O:14,P:15,Q:16,R:17,S:18,T:19,U:20,V:21,W:22,X:23,Y:24,Z:25,a:26,b:27,c:28,d:29,e:30,f:31,g:32,h:33,i:34,j:35,k:36,l:37,m:38,n:39,o:40,p:41,q:42,r:43,s:44,t:45,u:46,v:47,w:48,x:49,y:50,z:51,['0']:52,['1']:53,['2']:54,['3']:55,['4']:56,['5']:57,['6']:58,['7']:59,['8']:60,['9']:61,['+']:62,['/']:63}
	.encode = (str) ->
		(
			str\gsub '..?.?', (chars) ->
				b1, b2, b3 = byte chars, 1, 3
				value = b1 * (2 ^ 16) + (b2 or 0) * (2 ^ 8) + (b3 or 0)
				c4, value = value % 64, floor value / 64
				c3, value = value % 64, floor value / 64
				c2, value = value % 64, floor value / 64
				c1 = value
				switch #chars
					when 3 then format '%s%s%s%s', bmap[c1], bmap[c2], bmap[c3], bmap[c4]
					when 2 then format '%s%s%s=', bmap[c1], bmap[c2], bmap[c3]
					else format '%s%s==', bmap[c1], bmap[c2]
		)