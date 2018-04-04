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
	debug = false
	nextgame = 'games/9-int.p8'
	line1 = "this is where it happened."
	line2 = "roses mark the dead. find his."
	success = "almost no distance at all.\n\nit was quick."
	failure = "this was the place,\n\nbut this is close enough."
	col1 = 3
	col2 = 11

	frame = 0

	player = {}
	player.moving = false
	player.frame = 0
	player.framecount = 0
	player.x = 40
	player.y = 200
	player.step = 0
	player.speed = 1
	player.flip = false
	player.sprite = 0
	player.idlesprite = 32
	player.eyesclosedsprite = 34

	candle = {}
	candle.x = 97
	candle.y = 62
	candle.sprite = 112

	palt(0,false)
	palt(14,true)

	flashcurrent = 0
	flashrate = 10
	flashstate = false

	messagetimer = 0
	messagelimit = 100

	losecount = 0
	losemark = 600

	blacktimer = 0
	blacktimerlimit = 200

	frame = 0

	playedendsound = false
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
	if state == "playing" then
		checkinputs()
	end

	if state == "playing" then
 		camera(player.x - 60,player.y - 60)
	end

	checklossstate()
end

function checklossstate()
	if losecount < losemark then
		losecount+=1
	end

	if(losecount == losemark and not showingmessage) state="fail"
end

function _draw()
	cls(0)
	drawgame()
	checkcollisions()
	handlewinloss()
	handlefading()
	flash()

	if not state == "fadingdown" then
		glitch()
	end
end


function drawgame()
	-- terrain
	map(0, 0, 0, 0, 128, 128)

	-- candle
	frame+=1
		if frame%3 == 0 then
		if candle.sprite < 115 then
			candle.sprite+=1
		elseif candle.sprite == 115 then
			candle.sprite = 112
		end
	end

	spr(candle.sprite, candle.x, candle.y)

	-- player
	if state == "playing" then
		animateplayer()
	else
		player.moving = false
	end

	if player.moving then
		spr(player.sprite * 2, player.x, player.y, 2, 2, player.flip)
	end

	if not player.moving then
		if state == "fadingdown" then
			spr(player.eyesclosedsprite, player.x, player.y, 2, 2, player.flip)
		else
			spr(32, player.x, player.y, 2, 2, player.flip)
		end
	end

	frame+=1
	if frame <= 400 then
		rectfill(0,0,128,128,0)
	end

	if debug then
		print(state, player.x, player.y, 11)
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
	if(dst(player, candle) > 0 and dst(player, candle) < 20) then
		state = "fadingdown"
	end
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

function checkinputs()
	player.moving = false

	if btn(0) then
		player.x-=player.speed
		player.flip = true;
		player.moving = true
	end

	if btn(1) then
		player.x+=player.speed
		player.flip = false
		player.moving = true
	end

	if btn(2) then
		player.y-=player.speed
		player.moving = true
	end

	if btn(3) then
		player.y+=player.speed
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
	end

	if state == "fadingdown" then
		blacktimer += 1

		--print(blacktimer > blacktimerlimit, player.x + 50, player.y, 11)

		rectfill( 0, 0, 1000, blacktimer, 0 )
		player.sprite = player.eyesclosedsprite

		if blacktimer > blacktimerlimit then
			load(nextgame)
		end
	end
end

function handlewinloss()
	if state == "success" then
		outline(success,4,6,3,11)
		showingmessage = true

		if playedendsound == false then
			sfx(2)
			playedendsound = true
		end
	end

	if state == "fail" then
		outline(failure,4,6,8,2)
		showingmessage = true

		if playedendsound == false then
			sfx(3)
			playedendsound = true
		end
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffeeeeee
eeeeeeffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffeeeeeeeeeeefff55feeeeeeeeeeeffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffeeeeeeeeeeeff55f5eeeee
eeeeefff55feeeeeeeeeeeffffeeeeeeeeeeeffff55eeeeeeeeeefff75feeeeeeeeeefff55feeeeeeeeeeeffffeeeeeeeeeeeff55f5eeeeeeeeeeff75f5eeeee
eeeeefff75feeeeeeeeeeffff55eeeeeeeeeeffff75eeeeeeeeeeffffffeeeeeeeeeefff75feeeeeeeeeeff55f5eeeeeeeeeeff75f5eeeeeeeeeeffffffeeeee
eeeeeffffffeeeeeeeeeeffff75eeeeeeeeeeffffffeeeeeeeeeeeffffeeeeeeeeeeeffffffeeeeeeeeeeff75f5eeeeeeeeeeffffffeeeeeeeeeeeffffeeeeee
eeeeeeffffeeeeeeeeeeeffffffeeeeeeeeeeeffffeeeeeeeeeeee0000eeeeeeeeeeeeffffeeeeeeeeeeeffffffeeeeeeeeeeeffffeeeeeeeeeeee0000eeeeee
eeeeee0000eeeeeeeeeeeeffffeeeeeeeeeeee0000eeeeeeeeeeee00000eeeeeeeeeee0000eeeeeeeeeeeeffffeeeeeeeeeeee0000eeeeeeeeeeee00000eeeee
eeeeee00000eeeeeeeeeee0000eeeeeeeeeee000000eeeeeeeeeee00000eeeeeeeeeee00000eeeeeeeeeee0000eeeeeeeeeeee00000eeeeeeeeeee00000eeeee
eeeeee00000eeeeeeeeee000000eeeeeeeeee000000eeeeeeeeeee00000eeeeeeeeee0000000eeeeeeeee0000000eeeeeeeee0000000eeeeeeeee000000feeee
eeeeee00000eeeeeeeeee000000eeeeeeeeeef0000ffeeeeeeeeeee0ff0eeeeeeeeeeff0000ffeeeeeee000000000eeeeeeeeff0000ffeeeeeeee0ff000feeee
eeeeee000ffeeeeeeeeeef0000ffeeeeeeeeeff000ffeeeeeeeeeeccffceeeeeeeeeeff0000ffeeeeeeeff00000ffeeeeeeeeff0000ffeeeeeeeeeffcccceeee
eeeeeecccffceeeeeeeeeeccccffeeeeeeeeeeeccceeeeeeeeeeeec5ccceeeeeeeeeeeccccceeeeeeeeeff00000ffeeeeeeeeeeeccceeeeeeeeeeecccccceeee
eeeeeeccccccceeeeeee5cccccceeeeeeeeee5cccceeeeeeeeeeeec5cceeeeeeeeeeeecccccceeeeeeeeeeccccceeeeeeeeeeeecccceeeeeeeeeeecce5cceeee
eeeeeccceeccceeeeeee5cccecceeeeeeeeee5ccceeeeeeeeeeeeec5eeeeeeeeeeeeeccceecceeeeeeee5cceecceeeeeeeeeee5ccceeeeeeeeeeeccce5eeeeee
eeeeccceeee55eeeeeee5eeeecceeeeeeeeee5ecceeeeeeeeeeeeecceeeeeeeeeeeeecceeee55eeeeeee5ceeecceeeeeeeeeee5ecceeeeeeeeeeecceeeeeeeee
eeee55eeeeeeeeeeeeeeeeeeee55eeeeeeeeeeee55eeeeeeeeeeeee55eeeeeeeeeeee55eeeeeeeeeeeeeeeeeee55eeeeeeeeeeeee55eeeeeeeeeee55eeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeffffeeeeeeeeeeeeffffeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeef55f55eeeeeeeeeeffffffeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeef75f57eeeeeeeeeef55f55eeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeffffffeeeeeeeeeeffffffeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeffffeeeeeeeeeeeeffffeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee000000eeeeeeeeee000000eeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee00000000eeeeeeee00000000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0000000000eeeeee0000000000eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0000000000eeeeee0000000000eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeff000000ffeeeeeeff000000ffeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeffccccccffeeeeeeffccccccffeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeecccecceeeeeeeeeecccecceeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeecceecceeeeeeeeeecceecceeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeecceecceeeeeeeeeecceecceeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeddeeeddeeeeeeeeeddeeeddeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666665555555556665665556656655566545555665555566555555655566556666666666666666000000000000000000000000000000000000000000000000
66666666555555556555666655556566545566665554555655556556455555466566666665666666000000000000000000000000000000000000000000000000
66666665555555556566565565665555656564556655665555455555555555666666665566666656000000000000000000000000000000000000000000000000
66666666555555555566565655545556555555555656555555555555556655666666666666666666000000000000000000000000000000000000000000000000
66666665555555556656666566565565665656656556565555555455546555556656666566666666000000000000000000000000000000000000000000000000
66666666555555556665456656555566554656655545565555555555546655556666666666666666000000000000000000000000000000000000000000000000
66666665555555556666656566555565556565555666656655655565555555656666666566666665000000000000000000000000000000000000000000000000
56565656555555555656565656565656565656555656565555555655555556555666565666665656000000000000000000000000000000000000000000000000
68866665666886656666666566666885666666656666666566666665666688656666666566666665666668850000000000000000000000000000000000000000
82886666668888666663336666668888633b66666666688868666666666888866633b66666666666666688880000000000000000000000000000000000000000
88886665668888656b366b656666888566633665666688888886666566688885663633656663b365666688880000000000000000000000000000000000000000
883666666638866633666636666688886666b366666688868888b3b366b388666386633666336386666638860000000000000000000000000000000000000000
663b6665663666656666688566663b65666688886633b8888888366566366665888866b563b688886663b6650000000000000000000000000000000000000000
6663366666b33b6666668888666b366666668888b33666666886666666336666688866636366888866b366660000000000000000000000000000000000000000
6666b365666666356666888866336665666688886666666566666665666b36658888666563368885633666650000000000000000000000000000000000000000
56565336565656365656568656565656565658865656565656565656565636565656565656565656565656560000000000000000000000000000000000000000
6888666566663b656666666568866665666666656666633566666665666686656666686566886665666886650000000000000000000000000000000000000000
88886666666b6666666b3336888866666666666666663b6663b36666668888866666888888886666668888660000000000000000000000000000000000000000
68888665666366656633666588886665666b3665666b366566633665668888656668888888883b65688888650000000000000000000000000000000000000000
888836666663866666b66666688866666b333886666366666666b366666888666666888688883336668886660000000000000000000000000000000000000000
6666b66566688865663886656633b6656366888568886665666688856666366566663885688866b3666b66650000000000000000000000000000000000000000
666636666688886668888866666633663668888888888666666888886663b6666663336666666663666366660000000000000000000000000000000000000000
666b3665668888856888886566666b35666688856888666566668888666366656633666566666665663366650000000000000000000000000000000000000000
5653565656588656568886565656565656565886568856565656588656b3565656365656565656565b3656560000000000000000000000000000000000000000
eeeeeeeeeee9eeeeee9eeeeeee9eeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee9eeeeeee99eeeee99aeeeee99eeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e99eeeeeeea9eeeeee99eeeeea9aeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9aaeeeeeaaaeeeee89aeeeee9a9eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9a8eeeee989eeeee989eeeee89aeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee8eeeeeee8eeeeeee8eeeeeee8eeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555eee55555eee55555eee55555eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555eee55555eee55555eee55555eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
41414141414141414141414141414141414141414141414141414141414141415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040406540404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040484049404940404064404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040406640404040404344454249404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404048404346474440404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040405040404040434546464548404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404059404040404049484242434249404040554040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404048404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040405140405240404040404840404057404058404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040405640404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040405340404040544040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040405a40404069404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404063404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040406840404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404067404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040406040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404061404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
414040404040404040404040404040404040404040404040404040406a4040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040406240404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41404040404040404040404040404040404040404040404040404040404040415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41414141414141414141414141414141414141414141414141414141414141415d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300002c5502b5502a550295502855027550265502555024550235502255021550205501e5501d5501b5501a550195501855017550165501455012550105500c55008550055500255001550015500155001550
000800020855006540015000f5000f500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0005000004050080500b0500f0501205017050190501d0502205025050270502705027050230001d0001c0001c0001c0000000000000000000000000000000000000000000000000000000000000000000000000
010500002805025050220501f0501a0501705013050100500e0500b0500a050080500805007050070500705007050070500705000000000000000000000000000000000000000000000000000000000000000000