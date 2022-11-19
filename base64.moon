import byte, format from string
import floor from math
import array from require 'lithium.common'

with {}
	bmap = {[0]:'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'}
	-- ibmap = {A:0,B:1,C:2,D:3,E:4,F:5,G:6,H:7,I:8,J:9,K:10,L:11,M:12,N:13,O:14,P:15,Q:16,R:17,S:18,T:19,U:20,V:21,W:22,X:23,Y:24,Z:25,a:26,b:27,c:28,d:29,e:30,f:31,g:32,h:33,i:34,j:35,k:36,l:37,m:38,n:39,o:40,p:41,q:42,r:43,s:44,t:45,u:46,v:47,w:48,x:49,y:50,z:51,['0']:52,['1']:53,['2']:54,['3']:55,['4']:56,['5']:57,['6']:58,['7']:59,['8']:60,['9']:61,['+']:62,['/']:63}
	ibmap = {[65]:0,[66]:1,[67]:2,[68]:3,[69]:4,[70]:5,[71]:6,[72]:7,[73]:8,[74]:9,[75]:10,[76]:11,[77]:12,[78]:13,[79]:14,[80]:15,[81]:16,[82]:17,[83]:18,[84]:19,[85]:20,[86]:21,[87]:22,[88]:23,[89]:24,[90]:25,[97]:26,[98]:27,[99]:28,[100]:29,[101]:30,[102]:31,[103]:32,[104]:33,[105]:34,[106]:35,[107]:36,[108]:37,[109]:38,[110]:39,[111]:40,[112]:41,[113]:42,[114]:43,[115]:44,[116]:45,[117]:46,[118]:47,[119]:48,[120]:49,[121]:50,[122]:51,[48]:52,[49]:53,[50]:54,[51]:55,[52]:56,[53]:57,[54]:58,[55]:59,[56]:60,[57]:61,[43]:62,[47]:63}
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
	.decode = (str) ->
		str = str\gsub '=+$', '', 1
		error 'invalid number of characters' if #str % 4 == 1
		(
			str\gsub '..?.?.?', (chars) ->
				b1, b2, b3, b4 = byte chars, 1, 4
				b1, b2, b3, b4 = ibmap[b1 or 0], ibmap[b2 or 0], ibmap[b3 or 0], ibmap[b4 or 0]
				value = b1 * (2 ^ 18) + (b2 or 0) * (2 ^ 12) + (b3 or 0) * (2 ^ 6) + (b4 or 0)
				c3, value = value % 256, floor value / 256
				c2, value = value % 256, floor value / 256
				c1 = value
				switch #chars
					when 4 then format '%c%c%c', c1, c2, c3
					when 3 then format '%c%c', c1, c2
					when 2 then format '%c', c1
		)