pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- the loss levels
-- dan hett

function _init()
	sfx(0)

	setupgameparts()
	setuptimeout()
	setupglitches()
	setupfader()
end

function setupgameparts()
	debug = true
	nextgame = 'games/9-arn.p8'
	line1 = "the next day. no sleep."
	line2 = "word has spread. flowers arrive."
	success = "the outpouring\n\nis overwhelming."
	failure = "overwhelmed\n\nby everything."
	col1 = 12
	col2 = 13

	grad = 0

	player = {}
	player.moving = false
	player.frame = 0
	player.framecount = 0
	player.x = 50
	player.y = 106
	player.step = 0
	player.speed = 3
	player.flip = false
	player.idlesprite = 32
	player.sprite = 0

	starty = -900

	flower1 = {}
	flower1.x = 2
	flower1.y = starty - 210
	flower1.speed = 2.6
	flower1.sprite = 64

	flower2 = {}
	flower2.x = 20
	flower2.y = starty - 120
	flower2.speed = 2.5
	flower2.sprite = 66

	flower3 = {}
	flower3.x = 40
	flower3.y = starty  - 110
	flower3.speed = 2.8
	flower3.sprite = 68

	flower4 = {}
	flower4.x = 60
	flower4.y = starty - 130
	flower4.speed = 2.6
	flower4.sprite = 70

	flower5 = {}
	flower5.x = 80
	flower5.y = starty - 120
	flower5.speed = 3
	flower5.sprite = 72

	flower6 = {}
	flower6.x = 100
	flower6.y = starty - 170
	flower6.speed = 3.4
	flower6.sprite = 74

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	messagetimer = 0
	messagelimit = 100

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	losecount = 0
	losemark = 500
end

function setuptimeout()
	tcurrent = 0
	tmax = 60 * 60 -- reset timeout to return to the main menu
end

function setupfader()
	state = "waiting" -- or fadingdown or playing
	waittime = 0
	waittotal = 40
	fadedelay = 0
	fadelimit = 150

	ypos = -20
end

function setupglitches()
	glit = {}
	glit.height=128
	glit.width=128
	glit.t=0
end

function _update()
	if not showingmessage then
		if state=="playing" or state == "fail" or state == "success" then
			checkinputs()
		end
	else
		player.moving = false
	end

	flower1.y += flower1.speed
	flower2.y += flower2.speed
	flower3.y += flower3.speed
	flower4.y += flower4.speed
	flower5.y += flower5.speed
	flower6.y += flower6.speed

	checklossstate()
end

function _draw()
	cls(0)
	drawgame()
	checktimeout()
	handlewinloss()
	handlefading()
	checkcollisions()
	flash()
	glitch()
end


function drawgame()
	-- background
	rectfill_p(0,0,128,128,grad,0,2)

	-- floor
	rectfill_p(0,120,128,128,4,9,10)

	-- player
	if state=="playing" or state == "fail" or state == "success" then
		animateplayer()
	end

	-- flowers
	spr(flower1.sprite, flower1.x, flower1.y, 2, 2)
	spr(flower2.sprite, flower2.x, flower2.y, 2, 2)
	spr(flower3.sprite, flower3.x, flower3.y, 2, 2)
	spr(flower4.sprite, flower4.x, flower4.y, 2, 2)
	spr(flower5.sprite, flower5.x, flower5.y, 2, 2)
	spr(flower6.sprite, flower6.x, flower6.y, 2, 2)

	if player.moving then
		spr(player.sprite * 2, player.x, player.y, 2, 2, player.flip)
	end

	if not player.moving then
		spr(32, player.x, player.y, 2, 2, player.flip)
	end

	-- debug
	if debug then
		--print(player.x, 10, 10, 11)
	end

end

function animateplayer()
	if player.moving then
		player.step+=1

		if(player.step%2==0) player.sprite += 1

	  if player.sprite > 7 then
	   player.sprite = 0
	  end

		resettimeout()
	end
end

function checkcollisions()
	if dst(player, flower1) > 0 and dst(player, flower1) < 6 and flower1.speed > 0 then
		flower1.y = -1000
		flower1.speed = 0
		grad+=2
	end

	if dst(player, flower2) > 0 and dst(player, flower2) < 6 and flower2.speed > 0 then
		flower2.y = -1000
		flower2.speed = 0
		grad+=2
	end

	if dst(player, flower3) > 0 and dst(player, flower3) < 6 and flower3.speed > 0 then
		flower3.y = -1000
		flower3.speed = 0
		grad+=2
	end

	if dst(player, flower4) > 0 and dst(player, flower4) < 6 and flower4.speed > 0 then
		flower4.y = -1000
		flower4.speed = 0
		grad+=2
	end

	if dst(player, flower5) > 0 and dst(player, flower5) < 6 and flower5.speed > 0 then
		flower5.y = -1000
		flower5.speed = 0
		grad+=2
	end

	if dst(player, flower6) > 0 and dst(player, flower6) < 6 and flower6.speed > 0 then
		flower6.y = -1000
		flower6.speed = 0
		grad+=2
	end

	if grad == 12 then state = "success" end
end

function dst(p0, p1)
 local dx = p0.x - p1.x
 local dy = p0.y - p1.y

 return sqrt(dx*dx+dy*dy)
end

function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

function checklossstate()
	if losecount == losemark -1 and grad >= 10 then
		state = "success"

	elseif losecount < losemark then
		losecount+=1

	elseif(losecount == losemark and not showingmessage) then
		state="fail"
	end
end

function checkinputs()
	player.moving = false

	if btn(0) and player.x > 2 then
		player.x-=player.speed
		player.flip = true;
		player.moving = true
	end

	if btn(1) and player.x < 104 then
		player.x+=player.speed
		player.flip = false
		player.moving = true
	end

	if not player.moving then
    player.sprite = 0
  end
end

function resettimeout()
	tcurrent = 0
end

function checktimeout()
	if tcurrent < tmax then tcurrent+=1 end

	if tcurrent == tmax then
		load('losslevels.p8')
	end
end

function handlefading()
	if state == "waiting" then
		if fadedelay < fadelimit then
			fadedelay+=1
		end

		if fadedelay == fadelimit then
			state = "fadingup"
		end

		drawmessage()
	end

	if state == "fadingup" then
		waittime+=1

		if waittime < waittotal  then
			rectfill( 0, 0, 127, 127 - (3 * waittime), 0 )
			rectfill( 127, 127, 0, 3 * waittime, 0 )
			drawmessage()
			ypos += 4
		end
	end

	if waittime == waittotal then
		if state == "fadingup" then
			state = "playing"
			waittime = 0
		end

		if state == "fadingdown" then
			load(nextgame)
		end
	end

	if state == "fadingdown" then
		waittime+=1
		rectfill( 0, 0, 127, 3 * waittime, 0 )
		rectfill( 127, 127, 0, 127 - (3 * waittime), 0 )
	end
end

function handlewinloss()
	if state == "success" then
		outline(success,4,6,0,11)
		showingmessage = true
	end

	if state == "fail" then
		outline(failure,4,6,0,8)
		showingmessage = true
	end

	if showingmessage then
		messagetimer+=1
		if(messagetimer >= messagelimit) state = "fadingdown"
	end
end

function drawmessage()
	-- draw shutters
	rectfill( 0, 0, 127, 127 - (3 * waittime), 0 )
	rectfill( 127, 127, 0, 3 * waittime, 0 )

	-- draw text
	if(ypos < 50) then ypos+= 4 end

	if flashstate then
		outline(line1,0,ypos,0,col1)
		outline(line2,0,ypos+10,0,col2)
	else
		outline(line1,0,ypos,1,col1)
		outline(line2,0,ypos+10,1,col2)
	end
end

function rectfill_p(x0,y0,x1,y1,p,c0,c1)
 fill_pattern(p)
 col=color_pattern(c0,c1)
 rectfill(x0,y0,x1,y1,col)
end

function fill_pattern(n)
 t={
 0b1111111111111111,
 0b1111111111110111,
 0b1111110111110111,
 0b1111110111110101,
 0b1111010111110101,
 0b1111010110110101,
 0b1110010110110101,
 0b1110010110100101,
 0b1010010110100101,
 0b1010010110100001,
 0b1010010010100001,
 0b1010010010100000,
 0b1010000010100000,
 0b1010000000100000,
 0b1000000000100000,
 0b1000000000000000,
 0b0000000000000000}
 if n<0 then n=0
 elseif n>16 then n=16 end
 fillp(t[n+1])
end

function color_pattern(c0,c1)
 t={0,1,2,3,4,5,6,7,8,9,
 "a","b","c","d","e","f"}
 return "0x"..t[c0+1]..t[c1+1]
end

function flash()
	flashcurrent+=1

	if flashcurrent > flashrate then
		flashstate = true
	else
		flashstate = false
	end

	if flashcurrent == flashrate * 2 then
		flashcurrent = 0
	end
end

function glitch()
	if g_on == true then -- on boolean is mangaged by the timer
		local t={7,6,10} -- create array of three colors
		local c=rnd(3) -- generate a random number between 1 and 3, we'll use this in a bit
		c=flr(c) -- make sure our random number is an integer and not a float
		for i=0, 5, 4 do -- the outer loop generates the vertical glitch dots
			local gl_height = rnd(glit.height)
			for h=0, 100, 2 do -- the inner loop creates longer horizontal lines
				pset(rnd(glit.width), gl_height, t[c]) -- write the random pixels to the screen and randomize the colors from the previously generated random number against out color array
			end
		end
	end

	-- animation timeline that turns the static on and off
	if glit.t>30 and glit.t < 50 then
		g_on=true
	elseif glit.t>70 and glit.t < 80 then
		g_on=true
	elseif glit.t>120 then
		glit.t = 0

	else
		g_on=false

	end
	glit.t+=1

	o1 = flr(rnd(0x1f00)) + 0x6040
 o2 = o1 + flr(rnd(0x4)-0x2)
 len = flr(rnd(0x40))

 memcpy(o1,o2,len)
end
__gfx__
000000000000000000000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000ffff000000
000000ffff0000000000000000000000000000ffff00000000000fff55f00000000000ffff0000000000000000000000000000ffff00000000000ff55f500000
00000fff55f00000000000ffff00000000000ffff550000000000fff75f0000000000fff55f00000000000ffff00000000000ff55f50000000000ff75f500000
00000fff75f0000000000ffff550000000000ffff750000000000ffffff0000000000fff75f0000000000ff55f50000000000ff75f50000000000ffffff00000
00000ffffff0000000000ffff750000000000ffffff00000000000ffff00000000000ffffff0000000000ff75f50000000000ffffff00000000000ffff000000
000000ffff00000000000ffffff00000000000ffff0000000000007777000000000000ffff00000000000ffffff00000000000ffff0000000000007777000000
0000007777000000000000ffff000000000000777700000000000077777000000000007777000000000000ffff00000000000077770000000000007777700000
00000077777000000000007777000000000007777770000000000077777000000000007777700000000000777700000000000077777000000000007777700000
000000777770000000000777777000000000077777700000000000777770000000000777777700000000077777770000000007777777000000000777777f0000
0000007777700000000007777770000000000f7777ff000000000007ff70000000000ff7777ff000000077777777700000000ff7777ff000000007ff777f0000
000000777ff0000000000f7777ff000000000ff777ff000000000011ff10000000000ff7777ff0000000ff77777ff00000000ff7777ff000000000ff11110000
000000111ff100000000001111ff00000000000111000000000000161110000000000011111000000000ff77777ff00000000000111000000000001111110000
00000011111110000000611111100000000006111100000000000016110000000000001111110000000000111110000000000001111000000000001106110000
00000111001110000000611101100000000006111000000000000016000000000000011100110000000061100110000000000061110000000000011106000000
00001110000660000000600001100000000006011000000000000011000000000000011000066000000061000110000000000060110000000000011000000000
00006600000000000000000000660000000000006600000000000006600000000000066000000000000000000066000000000000066000000000006600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000ffff00000000000000000000000000000000000000
00000f55f5500000000000ffff0000000000000000000000000000ffff000000000000ffff00000000000f55f550000000000000000000000000000000000000
00000f75f570000000000f55f5500000000000ffff00000000000f55f550000000000f55f550000000000f75f570000000000000000000000000000000000000
00000ffffff0000000000f75f570000000000f55f550000000000f75f570000000000f75f570000000000ffffff0000000000000000000000000000000000000
000000ffff00000000000ffffff0000000000f75f570000000000ffffff0000000000ffffff00000000000ffff00000000000000000000000000000000000000
0000077777700000000000ffff00000000000ffffff00000000007ffff700000000007ffff700000000007777770000000000000000000000000000000000000
00007777777700000000077777700000000007ffff70000000000777777000000000777777770000000077777777000000000000000000000000000000000000
00077777777770000000777777770000000077777777000000007777777700000007777777777000000777777777700000000000000000000000000000000000
00077777777770000007777777777000000777777777700000077777777770000007777777777000000777777777700000000000000000000000000000000000
000ff777777ff000000777777777700000077777777770000007777777777000000ff777777ff000000ff777777ff00000000000000000000000000000000000
000ff111111ff000000ff777777ff000000ff777777ff000000ff111111ff000000ff111111ff000000ff111111ff00000000000000000000000000000000000
0000011101100000000ff111111ff000000ff111111ff000000ff111011ff0000000011101100000000001110110000000000000000000000000000000000000
00000110011000000000011101100000000001110110000000000110011000000000011001100000000001100110000000000000000000000000000000000000
00000110011000000000011001100000000001100110000000000110011000000000011001100000000001100110000000000000000000000000000000000000
00000660006600000000066000660000000006600066000000000660006600000000066000660000000006600066000000000000000000000000000000000000
0000ee00aee00b000000cc00acc00b0000002000020800000000a0000a0900000000000000000000000000000000000000000000000000000000000000000000
000eae3e30033e30000cac3c30033c3002022028800003300a0aa0a9900003300000000000000000000000000000000000000000000000000000000000000000
0000eeb03003eae00000ccb03003cac008088b288302288209099ba9930aa99a0000000000000000000000000000000000000000000000000000000000000000
00000e3e32eb02e000000c3c31cb01c002223b2223b222820aaa3baaa3baaa9a0000000000000000000000000000000000000000000000000000000000000000
00003eae0eae0b3000003cac0cac0b300022888383b8822000aa999393b99aa00002280000000000000667000000000000000000000000000000000000000000
000032e30e3e30b3000031c30c3c30b30022b8b02388323000aab9b0a3993a300282020000000000067606000000000000000000000000000000000000000000
0000330eeab33e230000330ccab33c1300b88832222b0b3300b9993aaaab0b330828828800000000076776770000000000000000000000000000000000000000
00000b332e33eaee00000b331c33cacc000832228880383000093aaa999039300888828800000000077776770000000000000000000000000000000000000000
0000000b333b3e000000000b333b3c000002b22b88b3bb00000abaab99b3bb0088808882033b000067707776033b000000000000000000000000000000000000
000000666665000000000066666500000000bb3b2222b2000000bb3baaaaba0088888880033b000066766670033b000000000000000000000000000000000000
000000666655000000000066665500000000023b00bb000000000a3b00bb000008880083003bb00006660073003bb00000000000000000000000000000000000
00000066655000000000006665500000000000b3bb000000000000b3bb000000000000033333b000000000033333b00000000000000000000000000000000000
0000006655000000000000665500000000000003b000000000000003b0000000000000333b33b000000000333b33b00000000000000000000000000000000000
000000655000000000000065500000000000000660000000000000066000000000000033bb33b00000000033bb33b00000000000000000000000000000000000
0000065500000000000006550000000000000006600000000000000660000000000000bbb003bb00000000bbb003bb0000000000000000000000000000000000
000005500000000000000550000000000000000bb00000000000000bb00000000000000000000bbb0000000000000bbb00000000000000000000000000000000
__map__
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101011111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0401000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300002c5502b5502a550295502855027550265502555024550235502255021550205501e5501d5501b5501a550195501855017550165501455012550105500c55008550055500255001550015500155001550
