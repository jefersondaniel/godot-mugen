[Statedef 4300]
type    = S
movetype= A
physics = S
juggle  = 8
ctrl = 0
anim = 430
sprpriority = 2

[State 90, d1]
type = removeexplod
trigger1 = animelem = 1


[State 9000, 1]
type = TargetFacing
trigger1 = 1
value = -1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 11
channel = 1

[State 430, 2]
type = HitDef
trigger1 = !MoveContact 
;trigger1 = var(30) = 10000
attr = C, NA
damage    = 200, 50
animtype  = Heavy
getpower = 200,50 
hitflag = MAF ;HAF
guardflag = HL
pausetime = 30,2
;p1stateno = 431
p2stateno = 43011
sparkno = -1
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
guardsound = 5,14
;ground.cornerpush.veloff = -30
ground.type = High
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.slidetime = 20
ground.hittime  = 20
ground.velocity = -1.8,-12
air.velocity = -1.8,-12
yaccel = 0.38
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
numhits = -1
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 9000, 1]
type = Explod
trigger1 = animelem = 5
trigger1 = anim = 430
anim = F16
postype = p1
ID = 20002
pos = 60,-105
postype = left
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
;removetime = -1


[State 9000, 1]
type = Explod
trigger1 = time = 129
anim = 888
postype = p1
ID = 20004
pos = 30,0
postype = left
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1


[State 43000, Hide]
type = Changeanim
trigger1 = animtime = 0
value = 0

[State 430, 4]
type = ChangeAnim
trigger1 = Time = 47
value = 888

[State 430, 4we]
type = posSet
trigger1 = Time >= 110
Y = 888

[State 430, 4]
type = Changestate
trigger1 = Time = 200
value = 0
ctrl = 1

[State 43005, VeX]
type = sprpriority
trigger1 = Time >= 90
value = -5

[State -34, ony]
type = Helper
trigger1 = time = 47
trigger1 = facing = 1
trigger1 = facing != -1
ID = 5050
stateno = 43013
pos = 0, 0
postype = p1
size.xscale = 1
size.yscale = 1
facing = 1
size.shadowoffset = -1000

[State -34, onysd]
type = Helper
trigger1 = time = 47
trigger1 = facing = -1
trigger1 = facing != 1
ID = 5050
stateno = 43013
pos = 0, 0
postype = p1
size.xscale = 1
size.yscale = 1
facing = 1
size.shadowoffset = -1000


[State -2, yex2e]
type = VarAdd
trigger1 = time = 47
V = 18
value = 1

[State -2, yex2esd]
type = VarAdd
trigger1 = time = 99
V = 26
value = 1


;---------------------------------------------------------------------------
[Statedef 43001]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 181, goros cell]
type = Explod
triggerall = p2stateno != 43011
triggerall = p2stateno != 712
trigger1 = root, Var(18) = 0
triggerall = facing = 1
triggerall = time = 0
trigger1 = roundstate = 0
trigger2 = roundstate = 1
trigger3 = roundstate = 2
triggerall = Numexplod(1010) < 1
triggerall = Numexplod(1011) != 1
anim = F48
ID = 1010
postype = p1
pos = -360,134
facing = 1
removeongethit = 0
sprpriority = -3
ownpal = 0
bindtime = -1
removetime = -1

[State 181, gorl]
type = Explod
triggerall = p2stateno != 43011
triggerall = p2stateno != 712
trigger1 = root, Var(18) = 0
triggerall = facing = 1
triggerall = time = 0
trigger1 = roundstate = 0
trigger2 = roundstate = 1
trigger3 = roundstate = 2
;triggerall = Numexplod(1010) < 1
triggerall = Numexplod(1011) < 1
anim = F49
ID = 1011
postype = p1
pos = -360,134
facing = 1
removeongethit = 0
ontop = 1
ownpal = 0
bindtime = -1
removetime = -1

[State -2, cccourtxa]
type = RemoveExplod
trigger1 = root, stateno = 43011
trigger2 = root, Var(23) = 1
;trigger3 = numexplod(1011) = 1
;trigger4 = root, Var(18) = 1
;trigger4 = stateno = 43011
ID = 1010

[State 2, ourtxa]
type = VelSet
trigger1 = root, Var(18) = 1
Y = -13.8

[State 2, ourtxa]
type = VelSet
trigger1 = root, Var(26) = 1
Y = 0

[State -2, cccourtxa]
type = destroyself
trigger1 = root, Var(23) = 1


;---------------------------------------
[Statedef 43011]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5050
sprpriority = 4

[State -2, yex2e]
type = VarAdd
trigger1 = time >= 0
V = 23
value = 1

[State 9000, 123]
type = VelSet
trigger1 = time = 0
Y = -13
X = -1.2

[State 9000, 54123]
type = VelSet
trigger1 = time = 50
Y = 12.9
X = -1

[State 9000, 34123]
type = VelSet
trigger1 = time = 24
trigger2 = time >= 80
Y = 0

[State 9000, 34123d]
type = VelSet
trigger1 = time = 35
trigger2 = time >= 80
X = 0


[State 9000, 54sd]
type = changeanim
trigger1 = time = 118
value = 5080


[State 9000, 54]
type = posAdd
trigger1 = time = 118
Y = -70
X = -5

[State 9000, 5x4sd]
type = sprpriority
trigger1 = 1
value = 4


[State 90, 51]
type = Explod
trigger1 = time = 117
anim = F16
postype = p1
pos = 0,-60
facing = -1
sprpriority = 5

[State 90, 51r]
type = Explod
trigger1 = time = 117
anim = F16
postype = p1
pos = -40,-70
sprpriority = 5

[State 90, 51t]
type = Explod
trigger1 = time = 117
anim = F16
postype = p1
pos = 40,-70
sprpriority = 5

[State 345, pughp]
type = PlaySnd
trigger1 = time = 50
value = 4, 1
volume = 50

[State 345, sdpughp]
type = PlaySnd
trigger1 = time = 117
value = F5, 0
volume = 50

[State 345, sdpughpsd]
type = PlaySnd
trigger1 = time = 120
value = F7, 0
volume = 150


[State 235, sss]
type = envshake
trigger1 = time = 120
time = 10
freq = 30
ampl = 3

[State 345, hp]
type = LifeSet
trigger1 = time >= 135
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 147
value = 5150

;-------

[StateDef 43012]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5050
sprpriority = 4

[State 9000, 123]
type = VelAdd
trigger1 = time = 0
Y = 12

[State 9000, 34123]
type = VelSet
trigger1 = time = 50
Y = 0

[State 9000, 45123]
type = changeanim
trigger1 = time = 96
value = 5080

[State 9000, 123q]
type = PosAdd
trigger1 = time = 96
Y = -55

;--------
[StateDef 43013]
type    = S
movetype = I
physics = N
ctrl = 0
anim = 180
sprpriority = 2

[State 9000, 123]
type = VelSet
trigger1 = time >= 0
Y = -13.8

[State 9000, 34123]
type = VelSet
trigger1 = time = 150
Y = 0

[State 9000, 34123e]
type = destroyself
trigger1 = time = 150

; Bell Tower
;------------------------
[Statedef 4302]
type    = S
movetype= A
physics = S
juggle  = 8
ctrl = 0
anim = 430
sprpriority = 4

[State 9000, 1]
type = Explod
trigger1 = time = 198
anim = 888
pos = -16*const(size.xscale),-13*const(size.xscale)
ID = 4302
postype = p1
bindtime = -1
facing = 1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 11
channel = 1

[State 430, 2]
type = HitDef
trigger1 = !MoveContact 
trigger1 = var(30) = 10001
attr = C, NA
damage    = 200, 50
animtype  = Heavy
getpower = 200,50 
hitflag = MAF ;HAF
guardflag = HL
pausetime = 30,2
;p1stateno = 431
p2stateno = 43003
sparkno = -1
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
guardsound = 5,14
ground.cornerpush.veloff = -30
ground.type = High
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.slidetime = 20
ground.hittime  = 20
numhits = -1
ground.velocity = -1.8,-12
air.velocity = -1.8,-12
yaccel = 0.38
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 9000, 1]
type = Explod
triggerall = var(30) = 10001
trigger1 = time = 75
trigger2 = time = 100
trigger3 = time = 120
trigger4 = time = 140
trigger5 = time = 170
trigger6 = time = 180
trigger7 = time = 200
trigger8 = time = 220
anim = F20002
pos = -56*const(size.xscale),0*const(size.xscale)
ID = 20001
vel = 0,-18
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = 60

[State 9000, 1]
type = Explod
triggerall = var(30) = 10001
trigger1 = time = 75
trigger2 = time = 100
trigger3 = time = 120
trigger4 = time = 140
trigger5 = time = 170
trigger6 = time = 180
trigger7 = time = 200
trigger8 = time = 220
anim = F20002
pos = -56*const(size.xscale),240*const(size.xscale)
ID = 20001
vel = 0,-18
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = 60


[State 9000, 1]
type = Explod
trigger1 = var(30) = 10001
trigger1 = time = 198
anim = F20001
pos = -160*const(size.xscale),-130*const(size.xscale)
ID = 20001
postype = left
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = var(30) = 10001
trigger1 = time = 198
anim = F20001
pos = -188*const(size.xscale),-130*const(size.xscale)
ID = 20001
postype = left
bindtime = -1
facing = 1
sprpriority = 3
;ontop = 1
ownpal = 1
removetime = -1


[State 9000, 123]
type = Explod
trigger1 = time = 1
anim = F15
postype = p1
pos = 35,-105
ID = 20005
bindtime = -1
facing = 1
;sprpriority = 2
ontop = 1
ownpal = 1
removetime = -70

[State 43000, AssertSpecial]
type = AssertSpecial
trigger1 = var(30) = 10001
trigger1 = time >= 75
trigger2 = roundstate = 3
trigger4 = roundstate = 4
trigger5 = NumExplod(20001) = 1
flag = noBG
;flag2 = globalnoshadow
flag2 = noFG
;flag3 = nobardisplay

[State 43000, ide]
type = removeexplod
trigger1 = time = 50

[State 43000, Hide]
type = Changeanim
trigger1 = animtime = 0
value = 180

[State 430, 4]
type = ChangeAnim
trigger1 = Time = 80
value = 888
;ctrl = 1

[State 430, 4]
type = Changestate
trigger1 = Time = 280
value = 0
ctrl = 1

[State 43005, VeX]
type = sprpriority
trigger1 = Time = 200
value = 3

[State 43005, PosAdd]
type = PosAdd
trigger1 = Time = 100
x = -25

[State 9000, 1]
type = Explod
trigger1 = time = 240
anim = F20003
pos = -56*const(size.xscale),240*const(size.xscale)
ID = 20001
postype = left
bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = -1

;---------------------------------------------------------------------------
[Statedef 43003]
type    = A
movetype = I
physics = N
ctrl = 0
anim = 5050
sprpriority = 5


[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = 3, 0
volume = 50

[State 430, 1]
type = PlaySnd
trigger1 = Time = 90
value = 4, 1
volume = 110

[State 435, cvbt]
type = ChangeAnim
trigger1 = Time = 80
value = 5050

[State 5, cvb]
type = VelSet
trigger1 = Time >= 0
trigger1 = Time <= 18
X = -1.5

[State 433, vv]
type = VelSet
trigger1 = time = 80
X = 0

[State 43, vx]
type = Gravity
trigger1 = Vel Y != 0

[State 433, vxv]
type = VelSet
trigger1 = time = 120
trigger2 = time = 245
X = 0
Y = 0

[State 5, PosAdd]
type = VelAdd
trigger1 = Time <= 2
;trigger2 = Pos Y < 10
Y = -5

[State 5, PosAdd]
type = PosAdd
trigger1 = Time >= 15
trigger1 = Time <= 75
Y = -3


[State 5, PosAdd]
type = PosAdd
trigger1 = Time >= 120
;trigger2 = Pos Y < 10
Y = 1.75 

[State 45, fff]
type = LifeSet
trigger1 = time = 265
value = 0

[State 345, pup]
type = PlaySnd
trigger1 = time = 259
value = F5,23
volume = 100

[State 345, pughp]
type = PlaySnd
trigger1 = time = 259
value = 3,2
volume = 50

[State 435, fdg]
type = SelfState
;trigger1 = Pos Y >= 10
trigger1 = time = 265
value = 5150

[State 435, Vel X]
type = PosSet
trigger1 = Time = 120
trigger1 = Facing = -1
;X = 80
Y = -140

[State 5, Vel XY]
type = PosSet
trigger1 = Time = 120
trigger1 = Facing = 1
;X = -80
Y = -140

[State 345, pup]
type = PlaySnd
trigger1 = time = 259
value = F5,0
volume = 100

[State 9000, 1]
type = Explod
trigger1 = time = 264
anim = F15
postype = p1
ID = 20002
pos = 0,-90
;postype = front
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
;removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 264
anim = F15
postype = p1
ID = 20002
pos = -20,-90
;postype = front
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
;removetime = -1


[State 9000, 123]
type = Explod
trigger1 = time = 264
anim = F15
postype = p1
ID = 20002
pos = 20,-90
;postype = front
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
;removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 100
anim = 888
postype = p1
ID = 20001
pos = 20,-90
;postype = front
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

;---------------------
;PIT3
[Statedef 4304]
type    = S
movetype= A
physics = S
juggle  = 8
ctrl = 0
anim = 430
sprpriority = 2

[State 9000, 123]
type = Explod
trigger1 = time = 10
anim = 888
postype = p1
ID = 2000
pos = 20,-90
;postype = front
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1


[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 11
channel = 1

[State 430, 2]
type = HitDef
trigger1 = !MoveContact 
trigger1 = var(30) = 10002
attr = C, NA
damage    = 200, 50
animtype  = Heavy
getpower = 200,50 
hitflag = MAF ;HAF
guardflag = HL
pausetime = 30,2
;p1stateno = 431
numhits = -1
p2stateno = 43005
sparkno = -1
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
guardsound = 5,14
ground.cornerpush.veloff = -30
ground.type = High
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.slidetime = 20
ground.hittime  = 20
ground.velocity = -1.8,-12
air.velocity = -1.8,-12
yaccel = 0.38
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 9000, 1]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 75
;trigger1 = facing = 1
anim = F20010
pos = 0*const(size.xscale),0*const(size.xscale)
ID = 2321
;vel = -.7,0
postype = left
bindtime = -1
facing = 1
sprpriority = 1
;ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 75
trigger1 = facing = 1
anim = F20004
pos = 0*const(size.xscale),20*const(size.xscale)
ID = 2000
vel = -.7,0
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 75
trigger1 = facing = -1
anim = F20004
pos = 0*const(size.xscale),20*const(size.xscale)
ID = 21000
vel = .7,0
postype = Left
;bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = -1


[State 9000, 1]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 192
anim = F20005
pos = 70*const(size.xscale),410*const(size.xscale)
ID = 21
vel = 0 ,-5
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 192
anim = F20005
pos = 170*const(size.xscale),410*const(size.xscale)
ID = 22
vel = 0,-5
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 192
anim = F20005
pos = 250*const(size.xscale),410*const(size.xscale)
ID = 23
vel = 0,-5
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 12]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 192
anim = F20005
pos = 320*const(size.xscale),410*const(size.xscale)
ID = 24
vel = 0,-5
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 13]
type = Explod
trigger1 = var(30) = 10002
trigger1 = time = 192
anim = F20005
pos = 10*const(size.xscale),410*const(size.xscale)
ID = 25
vel = 0,-5
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1


;----modify
[State 9000, 1]
type = ModifyExplod
;trigger1 = var(30) = 10002
trigger1 = time = 210
;anim = F20005
pos = 80*const(size.xscale),249*const(size.xscale)
ID = 21
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = ModifyExplod
;trigger1 = var(30) = 10002
trigger1 = time = 210
;anim = F20005
pos = 170*const(size.xscale),249*const(size.xscale);
vel = 0,0
ID = 22
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = ModifyExplod
;trigger1 = var(30) = 10002
trigger1 = time = 210
;anim = F20005
pos = 250*const(size.xscale),249*const(size.xscale)
ID = 23
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = ModifyExplod
;trigger1 = var(30) = 10002
trigger1 = time = 210
;anim = F20005
pos = 320*const(size.xscale),249*const(size.xscale)
ID = 24
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = ModifyExplod
;trigger1 = var(30) = 10002
trigger1 = time = 210
;anim = F20005
pos = 10*const(size.xscale),249*const(size.xscale)
ID = 25
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1


[State 9000, 123]
type = Explod
trigger1 = animelem = 4
trigger1 = anim = 430
anim = F15
postype = p1
pos = 35,-105
ID = 20005
bindtime = -1
facing = 1
ontop = 1
ownpal = 1
removetime = 70

[State 9000, 1]
type = ModifyExplod
trigger1 = var(30) = 10002
trigger1 = time = 210
;anim = F20004
pos = -93*const(size.xscale),20*const(size.xscale)
ID = 2000
vel = 0,0
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = ModifyExplod
trigger1 = var(30) = 10002
trigger1 = time = 210
;anim = F20004
pos = 93*const(size.xscale),20*const(size.xscale)
ID = 21000
vel = 0,0
postype = Left
;bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = -1

[State 43000, ide]
type = removeexplod
trigger1 = time = 74

[State 43000, Hide]
type = Changeanim
trigger1 = animtime = 0
value = 180

[State 430, 4]
type = ChangeAnim
trigger1 = Time = 75
value = 888
;ctrl = 1

[State 430, 4]
type = Changestate
trigger1 = Time = 290
value = 0
ctrl = 1

[State 43005, VeX]
type = sprpriority
trigger1 = Time = 200
value = 2

;---------------------------------------------------------------------------
[Statedef 43005]
type    = A
movetype = H
physics = N
ctrl = 0
anim = 5050
sprpriority = 2

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = 3, 0
volume = 50

[State 430, 1]
type = PlaySnd
trigger1 = Time = 50
value = 4, 1
volume = 110

[State 435, cvbt]
type = ChangeAnim
trigger1 = Time = 80
value = 5050

[State 5, cvb]
type = VelSet
trigger1 = Time >= 0
trigger1 = Time <= 15
;trigger2 = Time >= 16
;trigger2 = Time <= 40
X = -1.4

[State 433, vv]
type = VelSet
trigger1 = time = 78
X = 0

[State 43, vx]
type = Gravity
trigger1 = Vel Y != 0

[State 433, vxv]
type = VelSet
trigger1 = time = 120
X = 0
Y = 0

[State 5, PosAdd]
type = VelAdd
trigger1 = Time <= 2
;trigger2 = Pos Y < 10
Y = -4.6

[State 5, PosAdd]
type = PosAdd
trigger1 = Time >= 15
trigger1 = Time <= 75
Y = -3

[State 5, PosAdd]
type = PosAdd
trigger1 = Time >= 120
trigger2 = Time >= 25
trigger2 = Time <= 35
Y = 4.8

[State 5, PosA]
type = PosAdd
trigger1 = Time >= 128
;trigger2 = Pos Y < 10
Y = -2.7

[State 45, fff]
type = LifeSet
trigger1 = time = 300
value = 0

[State 45, 34fff]
type = Selfstate
trigger1 = time = 305
value = 5150


[State 345, pup]
type = PlaySnd
trigger1 = time = 223
value = F5,16
volume = 100

[State 345, pup]
type = PlaySnd
trigger1 = time = 226
value = F5,16
volume = 100

[State 345, pup]
type = PlaySnd
trigger1 = time = 229
value = F5,16
volume = 100


[State 345, pughp]
type = PlaySnd
trigger1 = time = 228
value = F5, 17
volume = 50

[State 345, pughp]
type = PlaySnd
trigger1 = time = 230
value = F5, 17
volume = 50


[State 345, pughp]
type = PlaySnd
trigger1 = time = 230
value = F5, 18
volume = 50

[State 345, pughp]
type = PlaySnd
trigger1 = time = 225
value = F5, 19
volume = 50

[State 345, pughp]
type = PlaySnd
trigger1 = time = 225
value = F5, 26
volume = 90

[State 345, pughp]
type = PlaySnd
trigger1 = time = 227
value = F5, 26
volume = 90

[State 345, pughp]
type = PlaySnd
trigger1 = time = 230
value = F5, 26
volume = 90

[State 435, Vel X]
type = PosSet
trigger1 = Time = 120
trigger1 = Facing = -1
;X = 80
Y = -140

[State 5, Vel XY]
type = PosSet
trigger1 = Time = 120
trigger1 = Facing = 1
;X = -80
Y = -140

[State 5, VelX]
type = sprpriority
trigger1 = Time >= 227
value = 2

[State 235, sss]
type = envshake
trigger1 = time = 228
time = 10
freq = 40
ampl = 4

[State 9000, 123]
type = Explod
trigger1 = time = 228
anim = F16
postype = p1
pos = 0,-90
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 235
anim = F16
postype = p1
pos = 10,-130
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1


[State 9000, 1]
type = Explod
trigger1 = time = 228
anim = F17
postype = p1
pos = 0,-110
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1

[State 9000, 1]
type = Explod
trigger1 = time = 228
anim = F17
postype = p1
pos = 0,-80
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1

[State 9000, 1]
type = Explod
trigger1 = time = 228
anim = F17
postype = p1
pos = 0,-60
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1


[State 9000, 123]
type = Explod
trigger1 = time = 231
anim = 43051
postype = p1
pos = 0,-110
vel = -2 , 2
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 232
anim = 43052
postype = p1
pos = 0,-150
vel = 9 , -6
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 234
anim = 43052
postype = p1
facing = -1
pos = 40,-150
vel = -10 , -8
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1


[State 9000, 123]
type = Explod
trigger1 = time = 232
anim = 43053
postype = p1
pos = 0,-90
vel = -7 , -6
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 232
anim = 43053
postype = p1
pos = 50,-90
vel = 14 , -2
facing = -1
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 232
anim = 43054
postype = p1
pos = 0,-130
vel = 1,3
;postype = front
bindtime = 1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 234
anim = F16
postype = p1
pos = 80,-180
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1


[State 9000, 000]
type = Explod
trigger1 = time = 232
anim = 888
ID = 333
postype = p1
pos = -50,-90
facing = 1
sprpriority = 2
removetime = -1
ontop = 1
ownpal = 1

; Prison
[Statedef 4306]
type    = S
movetype= A
physics = S
juggle  = 4
ctrl = 0
velset = 0,0,0
anim = 240

[State 240, 1.5]
type = Playsnd
trigger1 = animelem = 3
trigger1 = anim = 240
value = F5,15

[State 5, Pod]
type = PlaySnd
trigger1 = Time = 71
value = F5,27

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 11
channel = 1

[State 240, 2]
type = HitDef
trigger1 = !movecontact;trigger1 = AnimElem = 5
trigger1 = facing = 1
attr = S, NA
animtype  = Back
damage    = 166, 22
guardflag = HL
hitflag = MAF
pausetime = 0, 2
sparkno = -1
sparkxy = -55,-95
guard.sparkno = -1
hitsound = 5,0
guardsound = 5,14
ground.type = High
p2stateno = 4307
ground.slidetime = 30
;p2facing = 1
numhits = -1
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.hittime  = 30
ground.velocity = -5,-5            
air.velocity = -5,-6
air.hittime = 17  
ground.cornerpush.veloff = -25
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 9000, 1]
type = TargetFacing
trigger1 = time >= 1
value = -1

[State 9000, 1]
type = Explod
trigger1 = time = 75
trigger1 = facing = 1
anim = F20007
pos = 0*const(size.xscale),0*const(size.xscale)
;ID = 2000
postype = left
facing = 1
sprpriority = 2
ownpal = 1
removetime = -1
;ontop = 1

[State 9000, 1]
type = Explod
trigger1 = time = 75
trigger1 = facing = 1
anim = F20006
pos = 0*const(size.xscale),0*const(size.xscale)
ID = 2000
postype = left
;bindtime = -1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = -1



[State 9000, 123]
type = Explod
trigger1 = Animelem = 5
trigger1 = anim = 240
anim = F15
postype = p1
pos = 75,-105
ID = 20005
bindtime = -1
facing = 1
;sprpriority = 2
ontop = 1
ownpal = 1
removetime = 70

[State 43000, ide]
type = removeexplod
trigger1 = time = 60


[State 240, 3]
type = ChangeAnim
trigger1 = AnimTime = 0
value = 180

[State 240, 3]
type = ChangeState
trigger1 = Time = 850
value = 0
ctrl = 1

[Statedef 4307]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 888
sprpriority = 4

[State 9000, 123]
type = Explod
trigger1 = time = 0
anim = 5050
postype = p1
pos = 0,0
vel = -10 , -2
;postype = front
bindtime = 1
facing = 1
sprpriority = 5
ontop = 1
ownpal = 1
removetime = -1

[State 435, Vel X]
type = PosSet
trigger1 = Time = 96
trigger1 = Facing = -1
X = -7
Y = -42

[State 240, 3]
type = ChangeAnim
trigger1 = Time = 1
value = 5050

[State 240, 3]
type = PosSet
trigger1 = Time = 1
Y = 999


[State 9000, 123]
type = Explod
trigger1 = time = 70
anim = 5050
postype = Left
pos = -50,200
ID = 1
vel = 8 , -2
;postype = front
bindtime = 1
facing = -1
sprpriority = -5
ontop = 1
ownpal = 1
removetime = -1

[State 43000, ide]
type = removeexplod
trigger1 = time = 96
ID = 1

[State 5, PosAdd]
type = VelAdd
trigger1 = Time >= 95
;trigger1 = Time <= 110
X = -.88

[State 5, PosAdd]
type = VelAdd
trigger1 = Time >= 100
;Y = .6
X = 1

[State 5, PosAdd]
type = VelAdd
trigger1 = Time >= 194
trigger1 = Time <= 260
trigger2 = time >= 300
trigger3 = time >= 392
trigger2 = time <= 510
trigger3 = time <= 540
trigger4 = time >= 600
trigger5 = time >= 145
trigger5 = time <= 145
triggerall = time <= 800
;X = -.88
Y = .1

[State 5, PosAdd]
type = VelSet
trigger1 = Time = 192
Y = 0

[State 5, PosAdd]
type = VelAdd
trigger1 = Time >= 213
trigger2 = time >= 240
trigger2 = Time <= 310
trigger1 = time <= 340
trigger3 = time >= 370
trigger3 = time <= 570
trigger4 = time >= 450
trigger4 = time <= 510
triggerall = time <= 800
Y = -.1


[State 5, PosAdd]
type = VelSet
trigger1 = Time >= 132
X = 0

[State 9000, 1]
type = Explod
trigger1 = time = 92
;trigger1 = facing = 1
anim = F20007
pos = 0*const(size.xscale),0*const(size.xscale)
;ID = 2000
vel = 0,-12
postype = left
facing = 1
sprpriority = 4
;ontop = 1
ownpal = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = time = 92
trigger2 = time = 116
trigger3 = time = 136
trigger4 = time = 156
trigger5 = time = 176
trigger6 = time = 196
trigger7 = time = 216
trigger8 = time = 236
trigger9 = time = 256
trigger10 = time = 276
trigger11 = time = 296
trigger12 = time = 316
trigger13 = time = 336
trigger14 = time = 356
trigger15 = time = 376
trigger16 = time = 396
trigger17 = time = 416
trigger18 = time = 436
trigger19 = time = 456
trigger20 = time = 476
trigger21 = time = 496
trigger22 = time = 516
trigger23 = time = 536
trigger24 = time = 556
trigger25 = time = 576
trigger26 = time = 596
;trigger27 = time = 616
;trigger28 = time = 636
;trigger29 = time = 656
;trigger30 = time = 676
;trigger31 = time = 696
;trigger32 = time = 716
;trigger33 = time = 736
;trigger34 = time = 756
;trigger35 = time = 776
;trigger1 = facing = 1
anim = F20008
pos = 0*const(size.xscale),352*const(size.xscale)
;ID = 2000
vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 4
ownpal = 1
removetime = 50

[State 9000, 13]
type = Explod
trigger1 = time = 595
anim = F20008
pos = 0*const(size.xscale),352*const(size.xscale)
ID = 339
vel = 0,-22
postype = left
facing = 1
;ontop = 1
sprpriority = 4
ownpal = 1
removetime = 50

[State 9000, 13]
type = ModifyExplod
trigger1 = time = 635
anim = F20008
pos = 0*const(size.xscale),0*const(size.xscale)
ID = 339
;vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 4
ownpal = 1
removetime = -1

[State 9000, 13]
type = Explod
trigger1 = time = 635
anim = F20008
pos = 60*const(size.xscale),220*const(size.xscale)
;vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 3
ownpal = 1
removetime = -1

[State 9000, 13]
type = Explod
trigger1 = time = 635
anim = F20008
pos = 120*const(size.xscale),220*const(size.xscale)
;vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 3
ownpal = 1
removetime = -1

[State 9000, 13]
type = Explod
trigger1 = time = 635
anim = F20008
pos = 180*const(size.xscale),220*const(size.xscale)
;vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 3
ownpal = 1
removetime = -1

[State 9000, 13]
type = Explod
trigger1 = time = 635
anim = F20008
pos = 240*const(size.xscale),220*const(size.xscale)
;vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 3
ownpal = 1
removetime = -1

[State 9000, 13]
type = Explod
trigger1 = time = 635
anim = F20008
pos = 260*const(size.xscale),220*const(size.xscale)
;vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 3
ownpal = 1
removetime = -1

[State 9000, 13]
type = Explod
trigger1 = time = 635
anim = F20011
pos = 65*const(size.xscale),70*const(size.xscale)
ID = 333
;vel = 0,-12
postype = left
facing = 1
;ontop = 1
sprpriority = 5
ownpal = 1
removetime = -1

[State 240, 3]
type = ChangeAnim
trigger1 = Time = 633
value = 5080

[State 240, 3]
type = ChangeAnim
trigger1 = Time = 750
value = 5120

[State 240, 3]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 5120
value = 5300

[State 240, 3345]
type = ChangeAnim
trigger1 = Time = 839
value = 888

[State 240, 343]
type = Velset
trigger1 = Time >= 633
trigger1 = time <= 850
X = 0
Y = 0

[State 5, Pod]
type = PlaySnd
trigger1 = Time = 70
value = 4,1

[State 235, sss]
type = envshake
trigger1 = time = 68
trigger2 = time = 638
trigger3 = time = 860
trigger4 = time = 865
time = 15
freq = 140
ampl = 22

[State 9000, 1]
type = Explod
trigger1 = time = 77 
;trigger1 = facing = 1
anim = F20009
pos = -10*const(size.xscale),80*const(size.xscale)
vel = 5,-1
postype = left
sprpriority = -5
ontop = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = time = 76
;trigger1 = facing = 1
anim = F20009
pos = -20*const(size.xscale),90*const(size.xscale)
vel = 4,3
postype = left
sprpriority = -5
ontop = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = time = 76
;trigger1 = facing = 1
anim = F20009
pos = -30*const(size.xscale),87*const(size.xscale)
vel = 3,4
postype = left
sprpriority = -5
ontop = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = time = 79
;trigger1 = facing = 1
anim = F20009
pos = -40*const(size.xscale),66*const(size.xscale)
vel = 3,3
postype = left
sprpriority = -5
ontop = 1
removetime = 100

[State 9000, 1]
type = Explod
trigger1 = time = 80
;trigger1 = facing = 1
anim = F20009
pos = -30*const(size.xscale),85*const(size.xscale)
vel = 4,-1
postype = left
sprpriority = -5
ontop = 1
removetime = 100

[State 9000, 1]
type = Explod
trigger1 = time = 78
;trigger1 = facing = 1
anim = F20009
pos = -20*const(size.xscale),80*const(size.xscale)
vel = 3,4
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 76
;trigger1 = facing = 1
anim = F20009
pos = -30*const(size.xscale),88*const(size.xscale)
vel = 6,4
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 77
;trigger1 = facing = 1
anim = F20009
pos = -30*const(size.xscale),80*const(size.xscale)
vel = 3,2
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 81
;trigger1 = facing = 1
anim = F20009
pos = 0*const(size.xscale),83*const(size.xscale)
vel = 4,5
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 79
;trigger1 = facing = 1
anim = F20009
pos = -10*const(size.xscale),80*const(size.xscale)
vel = 6,3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 83
;trigger1 = facing = 1
anim = F20009
pos = 15*const(size.xscale),85*const(size.xscale)
vel = 2,3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 77
;trigger1 = facing = 1
anim = F20009
pos = -20*const(size.xscale),90*const(size.xscale)
vel = 4,4
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 81
;trigger1 = facing = 1
anim = F20009
pos = -10*const(size.xscale),90*const(size.xscale)
vel = 3,3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 79
;trigger1 = facing = 1
anim = F20009
pos = 0*const(size.xscale),90*const(size.xscale)
vel = 6,2
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 83
;trigger1 = facing = 1
anim = F20009
pos = 20*const(size.xscale),70*const(size.xscale)
vel = 2,2
postype = left
sprpriority = -5
ontop = 1
removetime = 200

;---
[State 9000, 1]
type = Explod
trigger1 = time = 77
;trigger1 = facing = 1
anim = F20009
pos = -20*const(size.xscale),90*const(size.xscale)
vel = 5,3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 81
;trigger1 = facing = 1
anim = F20009
pos = -10*const(size.xscale),90*const(size.xscale)
vel = 3,4
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 79
;trigger1 = facing = 1
anim = F20009
pos = 0*const(size.xscale),78*const(size.xscale)
vel = 4,3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 82
;trigger1 = facing = 1
anim = F20009
pos = -20*const(size.xscale),80*const(size.xscale)
vel = 2,3
postype = left
sprpriority = -5
ontop = 1
removetime = 200
;000

[State 9000, 1]
type = Explod
trigger1 = time = 73
;trigger1 = facing = 1
anim = F20009
pos = -40*const(size.xscale),80*const(size.xscale)
vel = 8,-3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 84
;trigger1 = facing = 1
anim = F20009
pos = -50*const(size.xscale),80*const(size.xscale)
vel = 4,1
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 75
;trigger1 = facing = 1
anim = F20009
pos = 0*const(size.xscale),79*const(size.xscale)
vel = 6,-4
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 86
;trigger1 = facing = 1
anim = F20009
pos = 40*const(size.xscale),80*const(size.xscale)
vel = 4,-3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 77
;trigger1 = facing = 1
anim = F20009
pos = -27*const(size.xscale),88*const(size.xscale)
vel = 5,-5
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 81
;trigger1 = facing = 1
anim = F20009
pos = -23*const(size.xscale),80*const(size.xscale)
vel = 5,-3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 78
;trigger1 = facing = 1
anim = F20009
pos = -7*const(size.xscale),75*const(size.xscale)
vel = 6,-6
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 83
;trigger1 = facing = 1
anim = F20009
pos = -13*const(size.xscale),80*const(size.xscale)
vel = 5,-4
postype = left
sprpriority = -5
ontop = 1
removetime = 200
;----
[State 9000, 1]
type = Explod
trigger1 = time = 79
;trigger1 = facing = 1
anim = F20009
pos = -20*const(size.xscale),85*const(size.xscale)
vel = 3,1
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 88
;trigger1 = facing = 1
anim = F20009
pos = -46*const(size.xscale),90*const(size.xscale)
vel = 3,2
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 79
;trigger1 = facing = 1
anim = F20009
pos = 17*const(size.xscale),87*const(size.xscale)
vel = 6,2
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 87
;trigger1 = facing = 1
anim = F20009
pos = 50*const(size.xscale),86*const(size.xscale)
vel = 7,1
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 76
;trigger1 = facing = 1
anim = F20009
pos = -43*const(size.xscale),80*const(size.xscale)
vel = 4,1
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 85
;trigger1 = facing = 1
anim = F20009
pos = -37*const(size.xscale),80*const(size.xscale)
vel = 6,2
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 74
;trigger1 = facing = 1
anim = F20009
pos = 7*const(size.xscale),83*const(size.xscale)
vel = 8,3
postype = left
sprpriority = -5
ontop = 1
removetime = 200

[State 9000, 1]
type = Explod
trigger1 = time = 83
;trigger1 = facing = 1
anim = F20009
pos = 10*const(size.xscale),86*const(size.xscale)
vel = 5,-1
postype = left
sprpriority = -5
ontop = 1
removetime = 200


[State 9000, 123]
type = Explod
trigger1 = time = 858
anim = F17
postype = p1
pos = 150,-90
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 858
anim = F17
postype = p1
pos = 150,-40
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 858
anim = F17
postype = p1
pos = 150,0
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1


[State 9000, 123]
type = Explod
trigger1 = time = 839
anim = 5050
postype = p1
pos = 0,0
vel = 9,-1
facing = -1
sprpriority = 3
;ontop = 1
ownpal = 1
removetime = 15


[State 240, 335]
type = SelfState
trigger1 = Time = 869
value = 5150
;ctrl = 1

[State 240, 332345]
type = Sprpriority
trigger1 = Time = 865
value = -1


[State 240, 43]
type = LifeSet
trigger1 = time = 867
value = 0

[State 240, 4233]
type = playsnd
trigger1 = time = 640
value = F7,0

[State 240, 4232343]
type = playsnd
trigger1 = time = 845
value = F5,1

[State 240, 4232343]
type = playsnd
trigger1 = time = 850
value = F5,27

[State 240, 32343]
type = playsnd
trigger1 = time = 75
value = F5,28
loop = 1

[State 2440, 4233]
type = playsnd
trigger1 = time = 638
value = 3,0

[State 24, 33]
type = playsnd
trigger1 = time = 840
value = 3,2


[State 240, 4233]
type = playsnd
trigger1 = time = 634
trigger2 = time = 855
value = F5,21

[State 240, 42334]
type = playsnd
trigger1 = time = 850
trigger2 = time = 856
value = F5,16

[State 240, 42334]
type = playsnd
trigger1 = time = 852
trigger2 = time = 855
value = F5,17

[State 240, 42334]
type = playsnd
trigger1 = time = 851
trigger2 = time = 855
value = F5,18

[State 240, 42334]
type = playsnd
trigger1 = time = 850
trigger2 = time = 856
value = F5,19

[State 242, 100]
type = VarSet
trigger1 = 1
v = 2
value = 1

[State 9000, 000]
type = Explod
trigger1 = time = 700
anim = 888
ID = 333
postype = p1
pos = -50,-90
facing = 1
sprpriority = 2
removetime = -1
ontop = 1
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 854
anim = 43051
postype = p1
pos = 180,-130
vel = -7 , 5
;postype = front
bindtime = 1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 854
anim = 43052
postype = p1
pos = 170,-130
vel = 5 , -5
;postype = front
bindtime = 1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 854
anim = 43052
postype = p1
facing = -1
pos = 180,-130
vel = 3 , 5
;postype = front
bindtime = 1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1


[State 9000, 123]
type = Explod
trigger1 = time = 854
anim = 43053
postype = p1
pos = 170,-130
vel = -2 , -6
;postype = front
bindtime = 1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 856
anim = 43053
postype = p1
pos = 180,-130
vel = 4 , 5
facing = -1
;postype = front
bindtime = 1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 856
anim = 43054
postype = p1
pos = 170,-130
vel = 3,-6
;postype = front
bindtime = 1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 858
anim = F16
postype = p1
pos = 150,-40
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 855
anim = F16
postype = p1
pos = 150,0
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 860
anim = F16
postype = p1
pos = 150,-110
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1

;--------------------------
;bloodbath
[Statedef 4308]
type    = S
movetype= A
physics = S
juggle  = 8
ctrl = 0
anim = 430
sprpriority = 4

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[State 9000, 1]
type = TargetFacing
trigger1 = time >= 1
trigger1 = time <= 10
value = -1

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 11
channel = 1

[State 430, 2]
type = HitDef
trigger1 = !MoveContact 
trigger1 = var(30) = 10004
attr = C, NA
damage    = 200, 50
animtype  = Heavy
getpower = 200,50 
hitflag = MAF ;HAF
guardflag = HL
pausetime = 30,2
;p1stateno = 431
numhits = -1
p2stateno = 4309
sparkno = -1
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
guardsound = 5,14
ground.cornerpush.veloff = -5
ground.type = High
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.slidetime = 20
ground.hittime  = 20
ground.velocity = -1.8,-12
air.velocity = -1.8,-12
yaccel = 0.38
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 9000, 123]
type = Explod
trigger1 = time = 1
trigger1 = anim = 430
anim = F15
postype = p1
pos = 35,-105
ID = 20005
bindtime = -1
facing = 1
ontop = 1
ownpal = 1
removetime = 70

[State 43000, Hide]
type = Changeanim
trigger1 = animtime = 0
trigger1 = anim = 430
value = 0

[State 430, 4]
type = Selfstate
trigger1 = Time = 200
value = 0
ctrl = 1

[State 43005, VeX]
type = sprpriority
trigger1 = Time >= 50
value = 4


[Statedef 4309]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 888
sprpriority = 4

[State 9000, 123]
type = Explod
trigger1 = time = 0
anim = 5050
postype = p1
pos = 0,0
vel = -1 , -10
;postype = front
;bindtime = 1
facing = 1
sprpriority = 5
ontop = 1
ownpal = 1
removetime = 200


[State 430, 1]
type = PlaySnd
trigger1 = Time = 92
value = F7, 0


[State 9000, 51]
type = Explod
trigger1 = time = 150
anim = F9
postype = Left
pos = -80,146
vel = 7 , 0
;postype = front
;bindtime = 1
facing = 1
sprpriority = -2
ownpal = 1
removetime = 27

[State 9000, 51]
type = Explod
trigger1 = time = 150
anim = F9
postype = Left
pos = 400,146
vel = -7 , 0
;postype = front
;bindtime = 1
facing = -1
sprpriority = -1
ownpal = 1
removetime = 27

[State 9000, 51]
type = Explod
trigger1 = time = 177
anim = F9
postype = Left
pos = 115,146
;postype = front
;bindtime = 1
facing = 1
sprpriority = -2
ownpal = 1
removetime = -2

[State 9000, 51]
type = Explod
trigger1 = time = 177
anim = F9
postype = Left
pos = 186,146
;postype = front
;bindtime = 1
facing = -1
sprpriority = -1
ownpal = 1
removetime = -2

[State 90, 51]
type = Explod
trigger1 = time = 175
anim = F16
postype = Left
pos = 150,120
facing = 1
sprpriority = -1
ownpal = 1

[State 90, 51]
type = Explod
trigger1 = time = 175
anim = F16
postype = Left
pos = 150,90
facing = -1
sprpriority = -1
ownpal = 1

[State 90, 51]
type = Explod
trigger1 = time = 175
anim = F16
postype = Left
pos = 150,50
facing = 1
sprpriority = -1
ownpal = 1

[State 90, 51]
type = Explod
trigger1 = time = 175
anim = F17
postype = Left
pos = 150,100
facing = -1
sprpriority = -1
ownpal = 1

[State 90, 51]
type = Explod
trigger1 = time = 175
anim = F17
postype = Left
pos = 150,50
facing = 1
sprpriority = -1
ownpal = 1


[State 345, pughp]
type = PlaySnd
trigger1 = time = 175
value = F5, 18
volume = 50

[State 345, pughp]
type = PlaySnd
trigger1 = time = 177
value = F5, 19
volume = 50

[State 345, pughp]
type = PlaySnd
trigger1 = time = 176
value = F5, 17
volume = 90

[State 345, pughp]
type = PlaySnd
trigger1 = time = 175
value = F5, 16
volume = 90

[State 345, ghp]
type = PlaySnd
trigger1 = time = 171
value = F5, 0
volume = 130

[State 345, pughp]
type = PlaySnd
trigger1 = time = 172
value = 4, 1
volume = 50

[State 345, g666hp]
type = PlaySnd
trigger1 = time = 145
value = F5, 30
volume = 130


[State 345, hp]
type = Removeexplod
trigger1 = time >= 175
ID = 1512

[State 235, sss]
type = envshake
trigger1 = time = 92
time = 15
freq = 50
ampl = 3

[State 235, s]
type = envshake
trigger1 = time = 173
time = 15
freq = 80
ampl = 9


[State -34, ony]
type = Helper
trigger1 = time = 40
ID = 5050
stateno = 4310
pos = 156, -540
postype = Left
size.xscale = .7
size.yscale = .7
facing = -1
size.shadowoffset = -1000

[State 345, hp]
type = LifeSet
trigger1 = time >= 175
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 177
value = 5150

[StateDef 4310]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5050
sprpriority = -5

[State 9000, 123]
type = VelAdd
trigger1 = time = 0
Y = 9

[State 9000, 34123]
type = VelSet
trigger1 = time = 50
Y = 0

[State 9000, 45123]
type = changeanim
trigger1 = time = 50
value = 5080


[State 9000, 45123]
type = changeanim
trigger1 = time = 80
;trigger1 = facing = 1
;trigger1 = facing != -1
value = 5120



[State 9000, 5341]
type = changeanim
trigger1 = animtime = 0
trigger1 = anim = 5120
value = 5300


[State 9000, 5341]
type = changeanim
trigger1 = time = 150
value = 5016

;------------------------------------saw (sierra de decapitación)
[Statedef 767]
type    = S
movetype= A
physics = S
;juggle  = 2
ctrl = 0
velset = 0,0,0
anim = 13

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1

[State 181, DerI]
type = Explod
triggerall = time = 0
trigger1 = roundstate = 0
trigger2 = roundstate = 1
trigger3 = roundstate = 2
anim = F13
pos = -340,-18
postype = Left
facing = 1
removeongethit = 0
sprpriority = 5
ownpal = 1
time = -1
removetime = -1


[State 430, 3451]
type = HitDef
trigger1 = Animelem = 2
triggerall = p2statetype = S
triggerall = p2statetype != A
triggerall = root, Var(59) = 1
trigger1 = RootDist X >= 50
trigger1 = p2bodydist X <= 50
attr = S, NT
animtype = Hard
air.animtype = Back
priority = 1, Miss    
damage = 0,300
fall.recover = 0
hitflag = M
guardflag = M
pausetime = 0,0
sparkno = -1
guard.dist = -90
p1stateno = 768
p2stateno = 6003
guard.sparkno = -1
hitsound   = 5,0
guardsound = 5,26
ground.type = High
kill       = root, Var(9) = 0
fall.kill  = root, Var(9) = 0
guard.kill = root, Var(9) = 0

[State 430, 3123]
type = Playsnd
trigger1 = MoveHit
triggerall = time = 0
value = F5,26

[State 430, 31]
type = Destroyself
trigger1 = p2stateno = 6003

[Statedef 768]
type    = S
movetype= A
physics = S
;juggle  = 2
ctrl = 0
velset = 0,0,0

[State 430, 3123]
type = Playsnd
trigger1 = time = 0
value = F5,26
volume = 90

[State 430, df3123]
type = Changestate
trigger1 = time = 0
value = 767
;-----------------BONUS
[Statedef 770]
type    = S
movetype= I
physics = S
ctrl = 0
velset = 0,0,0
anim = 0

[State 181, Finim]
type = Explod
trigger1 = 1
triggerall = var(30) = 10006
triggerall = NumExplod(18) < 1
anim = 888
ID = 18
pos = 0*const(size.xscale),0*const(size.xscale)
postype = P1
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -1


[State 430, df31]
type = RemoveExplod
triggerall = 1
trigger1 = roundstate = 3
trigger2 = roundstate = 4
ID = 14

[State d430, df31]
type = RemoveExplod
triggerall = 1
trigger1 = roundstate = 3
trigger2 = roundstate = 4
ID = 18

[State 430, df3123]
type = Changestate
trigger1 = 1
trigger1 = command = "x"
triggerall = command != "holddown"
triggerall = roundstate = 2
triggerall = roundstate != 1
triggerall = roundstate != 0
triggerall = stateno != 771
triggerall = stateno != 772
triggerall = stateno != 773
value = 771
ctrl = 0

[State 430, df312332]
type = Changestate
trigger1 = 1
trigger1 = command = "y"
triggerall = command != "holddown"
triggerall = roundstate = 2
triggerall = roundstate != 1
triggerall = roundstate != 0
triggerall = power >= 500
triggerall = stateno != 771
triggerall = stateno != 772
triggerall = stateno != 773
value = 772
ctrl = 0

[State 430, 2]
type = Changestate
triggerall = 1
trigger1 = roundstate = 3
trigger2 = roundstate = 4
value = 0
ctrl = 1

[State 430, df31]
type = VarSet
trigger1 = 1
V = 8
value = 0


[State 430, df3123]
type = Changestate
trigger1 = Stateno = [0,650]
value = 770


;--------------
[Statedef 771]
type    = S
movetype= A
physics = S
ctrl = 0
velset = 0,0,0
anim = 771
vel = 0,0,0
sprpriority = 5

[State 430, df31]
type = VarSet
trigger1 = animelem = 5
V = 8
value = 1

[State 240, 1.5]
type = Playsnd
trigger1 = animelem = 3
value = F5,15

[State 1200, BoltFat]
type = HitDef
trigger1 = animelem = 5
trigger1 = p2stateno != 12001
attr = S, NA
damage = 100,10 
guardflag = MA
hitflag = MAF 
priority = 5, Hit
hitsound = 5, 1    
numhits = -1
sparkno = -1
guard.sparkno = -1
p2stateno = 773
kill       = 0
fall.kill  = 0
guard.kill = 0

[State 430, 4]
type = ChangeState
trigger1 = animTime = 0
value = 770
ctrl = 0

;---------
[Statedef 772]
type    = S
movetype= A
physics = S
ctrl = 0
velset = 0,0,0
anim = 772
vel = 0,0,0
sprpriority = 5

[State 430, df31]
type = VarSet
trigger1 = animelem = 5
V = 8
value = 1


[State 240, 1.5]
type = Playsnd
trigger1 = animelem = 3
value = F5,15

[State 1200, BoltFat]
type = HitDef
trigger1 = animelem = 5
trigger1 = p2stateno != 12001
attr = S, NA
damage = 100,10 
guardflag = MA
hitflag = MAF 
priority = 5, Hit
hitsound = 5, 1    
numhits = -1
sparkno = -1
guard.sparkno = -1
p2stateno = 773
kill       = 0
fall.kill  = 0
guard.kill = 0


[State 430, 4]
type = ChangeState
trigger1 = animTime = 0
value = 770
ctrl = 0

[Statedef 773]
type = S
movetype= I
physics = N
velset = 0,0

[State 240, 1.5]
type = Playsnd
trigger1 = time = 0
value = F5,14
trigger1 = anim != [5000,9999]
volume = 50

[State 240, 12.5]
type = Playsnd
trigger1 = time = 0
value = F5,32
trigger1 = anim != [5000,9999]
volume = 150

[State 240, 12.345]
type = Playsnd
triggerall = time = 0
value = F5,21
triggerall = anim != [5000,9999]
trigger1 = p2stateno= 771
trigger2 = p2stateno= 772
triggerall = life < 70
volume = 150

[State 1005, VELSET]
type = velset
trigger1 = time = 0
X = 0
Y = 0

[State 1005, CS]
type = SelfState
trigger1 = time = 1
trigger1 = Pos Y > -1
value = 770
ctrl = 0

[State -2, 316]
type = LifeAdd
triggerall = p2stateno = 772
trigger1 = time = 0
value = -80

[State -2, 316]
type = LifeAdd
triggerall = p2stateno = 771
trigger1 = time = 0
value = -100
;-------------
[Statedef 774]
type    = S
movetype= I
physics = S
ctrl = 0
velset = 0,0,0
anim = 888

[State 181, Finim]
type = Explod
trigger1 = 1
triggerall = NumExplod(18) < 1
;triggerall = NumExplod(19) < 1
triggerall = root, Var(8) != 1
anim = F21
ID = 18
pos = 0*const(size.xscale),0*const(size.xscale)
postype = P1
bindtime = -1
facing = 1
sprpriority = -2
ownpal = 1
removetime = -1

[State 181, FDinim]
type = RemoveExplod
trigger1 = 1
triggerall = root, Var(8) = 1
id = 18

[State 181, FDinimd]
type = RemoveExplod
trigger1 = 1
triggerall = root, Var(8) = 0
id = 19


[State 181, Finimcxc]
type = Explod
trigger1 = 1
;triggerall = NumExplod(18) < 1
triggerall = NumExplod(19) < 1
triggerall = root, Var(8) = 1
anim = F21
ID = 19
pos = 2*const(size.xscale),0*const(size.xscale)
postype = P1
bindtime = -1
facing = 1
sprpriority = -2
ownpal = 1
removetime = -1


;---------------------subway
[Statedef 780]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
velset = 0,0,0
anim = 13

[State 181, DI]
type = Explod
triggerall = time = 0
trigger1 = roundstate = 0
trigger2 = roundstate = 1
trigger3 = roundstate = 2
trigger1 = root, Var(5) = 0
anim = F78
ID = 7878
pos = 155,-25
postype = Left
facing = 1
removeongethit = 0
sprpriority = -4
ownpal = 0
time = -1
removetime = -1


[State 181, DsdI]
type = Destroyself
;triggerall = time = 0
;trigger1 = roundstate = 0
;trigger2 = roundstate = 1
;trigger3 = roundstate = 2
trigger1 = root, Var(5) = 1
;anim = F78
;ID = 7878
;pos = 5,5
;postype = Left
;facing = 1
;removeongethit = 0
;sprpriority = -4
;ownpal = 0
;time = -1
;removetime = -1

;--------------subway fatal
[Statedef 4320];781
type    = S
movetype= A
physics = S
juggle  = 1
ctrl = 0
anim = 430
sprpriority = 4

[State 9000, 1]
type = TargetFacing
trigger1 = time >= 1
trigger1 = time <= 10
value = -1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 210, 1]
type = Playsnd
trigger1 = time = 1
value = F5,11
volume = 60
channel = 1

[State 430, 2]
type = HitDef
trigger1 = !movecontact;trigger1 = animelem = 5
trigger1 = var(30) = 10007
attr = C, NA
damage    = 200, 50
animtype  = Heavy
getpower = 200,50 
hitflag = MAF ;HAF
guardflag = HL
pausetime = 30,2
;p1stateno = 431
numhits = -1
p2stateno = 782
sparkno = -1
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
guardsound = 5,14
ground.cornerpush.veloff = -5
ground.type = High
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.slidetime = 20
ground.hittime  = 20
ground.velocity = -1.8,-12
air.velocity = -1.8,-12
yaccel = 0.38
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 9000, 123]
type = Explod
trigger1 = animelem = 4
trigger1 = anim = 430
anim = F15
postype = p1
pos = 35,-105
ID = 20005
bindtime = -1
facing = 1
ontop = 1
ownpal = 1
;removetime = 70

[State 430, 4]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 430
value = 0

[State 430, 4sd]
type = SelfState
trigger1 = Time = 150
value = 0
ctrl = 1


[State 43005, VeX]
type = sprpriority
trigger1 = Time >= 50
value = 4


[Statedef 782]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 888
;sprpriority = 4


[State 430, 3]
type = Playsnd
trigger1 = time = 12
value = F5, 35
volume = 250


[State 430, 34]
type = Playsnd
trigger1 = time = 15
value = F5, 37
volume = 150

[State 90, f51]
type = Explod
trigger1 = time = 17
trigger2 = time = 32
trigger3 = time = 47
anim = F30
postype = p2
vel = -1, 8.8
pos = 70 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 15
trigger2 = time = 26
trigger3 = time = 44
anim = F30
postype = p2
vel = 0, 8
pos = 70 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 18
trigger2 = time = 27
trigger3 = time = 42
anim = F30
postype = p2
vel = 1, 8
pos = 180 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 16
trigger2 = time = 23
trigger3 = time = 38
anim = F30
postype = p2
vel = 1, 8.8
pos = 140 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 29
trigger2 = time = 39
trigger3 = time = 44
anim = F31
postype = p2
vel = -1, 8
pos = 60 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 27
trigger2 = time = 31
trigger3 = time = 40
anim = F31
postype = p2
vel = 0, 8.8
pos = 50 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90


[State 90, f5nv1]
type = Explod
trigger1 = time = 33
trigger2 = time = 42
trigger3 = time = 30
trigger4 = time = 59
anim = F34
postype = p2
vel = -1, 0
pos = 66 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, ffg51]
type = Explod
trigger1 = time = 25
trigger2 = time = 32
trigger4 = time = 45
trigger5 = time = 54
trigger6 = time = 63
anim = F34
postype = p2
vel = 1, 0
pos = 50 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, f51s]
type = Explod
trigger1 = time = 26
trigger2 = time = 30
trigger3 = time = 42
trigger4 = time = 50
trigger5 = time = 69
anim = F34
postype = p2
vel = 1.5, 0
pos = 100 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, f51]
type = Explod
trigger1 = time = 14
trigger2 = time = 18
trigger3 = time = 22
anim = F31
postype = p2
vel = -1, 7
pos = 60 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 25
trigger2 = time = 16
trigger3 = time = 24
anim = F31
postype = p2
vel = 0, 8.8
pos = 90 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 14
trigger2 = time = 17
trigger3 = time = 18
anim = F31
postype = p2
vel = 1, 7
pos = 120 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 16
trigger2 = time = 19
trigger3 = time = 14
anim = F31
postype = p2
vel = 1, 8.8
pos = 40 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90


[State 9000, 123]
type = Explod
trigger1 = time = 0
anim = 5050
postype = p1
pos = 0,0
vel = -1 , -10
;postype = front
;bindtime = 1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = 100


[State -34, ony]
type = Helper
trigger1 = time = 40
ID = 5050
stateno = 783
pos = 156, -510
postype = Left
size.xscale = .6
size.yscale = .6
facing = -1

[State 430, 1]
type = PlaySnd
trigger1 = Time = 92
value = F7, 0


[State 9000, 51]
type = Explod
trigger1 = time = 180
anim = F79
postype = Left
pos = -300,-25
vel = 12 , 0
;postype = front
;bindtime = 1
facing = 1
sprpriority = -5
ownpal = 1
removetime = -1


[State 345, ghp]
type = PlaySnd
trigger1 = time = 188
value = F5, 21
volume = 130

[State 345, pughp]
type = PlaySnd
trigger1 = time = 187
value = 4, 1
volume = 50

[State 345, g666hp]
type = PlaySnd
trigger1 = time = 145
value = F5, 33
volume = 130


[State 345, hp]
type = Removeexplod
trigger1 = time >= 190
ID = 1512

[State 235, sss]
type = envshake
trigger1 = time = 92
time = 15
freq = 50
ampl = 3

[State 235, s]
type = envshake
trigger1 = time = 190
time = 15
freq = 80
ampl = 9


[State 345, hp]
type = LifeSet
trigger1 = time >= 220
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 220
value = 5150
;------------------


[Statedef 783]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5050
sprpriority = -5

[State 9000, 123]
type = VelAdd
trigger1 = time = 0
Y = 9

[State 9000, 34123]
type = VelSet
trigger1 = time = 50
Y = 0


[State 9000, 45123]
type = changeanim
trigger1 = time = 50
value = 5080


[State 9000, 45123]
type = changeanim
trigger1 = time = 80
;trigger1 = facing = 1
;trigger1 = facing != -1
value = 5120



[State 9000, 5341]
type = changeanim
trigger1 = animtime = 0
trigger1 = anim = 5120
value = 5300


[State 9000, 5341]
type = changeanim
trigger1 = time = 150
value = 5050

[State 9000, 123]
type = VelAdd
trigger1 = time = 150
X = -9
Y = -1

[State 90, 51]
type = Explod
trigger1 = time = 150
anim = F16
postype = Left
vel = 4,- 1
pos = 150,110
facing = 1
sprpriority = -4
ownpal = 1


;------------------
[Statedef 790]
type    = S
movetype= A
physics = S
;juggle  = 2
ctrl = 0
velset = 0,0,0
anim = 9000

[State 1200, BoltFat]
type = HitDef
;trigger1 = 1
trigger1 = ParentDist X >= -610
trigger1 = p2stateno != 791
trigger1 = p2stateno = 792
attr = S, NA
damage = 0,0 
guardflag = A
hitflag = HLFAM 
priority = 5, Hit
hitsound = -1
numhits = -1
sparkno = -1
guard.sparkno = -1
guard.dist = -90
p2stateno = 791
kill       = 0
fall.kill  = 0
guard.kill = 0

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[Statedef 791]
type    = S
movetype= H
physics = S
;juggle  = 2
ctrl = 0
velset = -10,0,0
anim = 5080

[State 1200, tFt]
type = PosSet
trigger1 = time = 0
Y = -50

[State 1200, BoltFt]
type = Changestate
trigger1 = time = 430
value = 0
ctrl = 1

[State 181, DI]
type = Explod
trigger1 = time = 1
anim = F20
ID = 791
pos = 289,175
postype = Left
facing = 1
removeongethit = 0
sprpriority = 4
;ontop = 1
ownpal = 1
time = -1
removetime = -1

[State 181, DI]
type = Explod
trigger1 = time = 40
anim = F17
pos = 265,175
postype = Left
facing = 1
removeongethit = 0
sprpriority = 5
ownpal = 1

[State 181, DI]
type = Explod
trigger1 = time = 40
anim = F16
pos = 265,175
postype = Left
facing = 1
removeongethit = 0
sprpriority >= 4
ownpal = 1

[State 181, DI]
type = Explod
trigger1 = time = 45
anim = F16
pos = 295,175
postype = Left
facing = 1
removeongethit = 0
ontop = 1
ownpal = 1
facing = -1

[State 181, DI]
type = Explod
trigger1 = time = 45
anim = F16
pos = 275,175
postype = Left
facing = 1
removeongethit = 0
ontop = 1
ownpal = 1
facing = -1

[State 181, DI]
type = Explod
trigger1 = time = 40
anim = F16
pos = 265,175
postype = Left
facing = 1
removeongethit = 0
ontop = 1
ownpal = 1
facing = 1

[State 345, pughp]
type = PlaySnd
trigger1 = time = 45
value = F5, 18
volume = 50

[State 345, pughp]
type = PlaySnd
trigger1 = time = 42
value = F5, 19
volume = 50

[State 345, pughp]
type = PlaySnd
trigger1 = time = 44
value = F5, 17
volume = 90

[State 345, pughp]
type = PlaySnd
trigger1 = time = 43
value = F5, 16
volume = 90

[State 345, ghp]
type = PlaySnd
trigger1 = time = 41
value = F5, 0
volume = 130

[State 345, pughp]
type = PlaySnd
trigger1 = time = 1
value = F7, 0
volume = 50

[State 345, g666hp]
type = PlaySnd
trigger1 = time = 10
value = F5, 30
volume = 130

[State 345, g66sp]
type = Changeanim
trigger1 = time = 50
value = 888


[State 9000, 123]
type = Explod
trigger1 = time = 40
anim = 43051
postype = p1
pos = -80,0
vel = 5 , 2
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 40
anim = 43052
postype = p1
pos = -10,0
vel = 6 , -6
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 40
anim = 43052
postype = p1
facing = -1
pos = -40,0
vel = 6 , -9
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1


[State 9000, 123]
type = Explod
trigger1 = time = 40
anim = 43053
postype = p1
pos = -30,0
vel = 7 , -2
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 9000, 123]
type = Explod
trigger1 = time = 40
anim = 43053
postype = p1
pos = -50,0
vel = 4 , -8
facing = -1
;postype = front
bindtime = 1
facing = 1
sprpriority = 3
ontop = 1
ownpal = 1
removetime = -1

[State 345, hp]
type = LifeSet
trigger1 = time >= 148
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 150
value = 5150

;-----------------------
[Statedef 4312];793 press
type    = S
movetype= A
physics = S
ctrl = 0
velset = 0,0,0
anim = 240

[State 240, 1.5]
type = Playsnd
trigger1 = animelem = 3
value = F5,15

[State 210, 1]
type = Playsnd
trigger1 = time = 1
value = F5,11
volume = 60
channel = 1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[State 240, 2]
type = HitDef
trigger1 = !movecontact;trigger1 = AnimElem = 5;
attr = S, NA
animtype  = Back
damage    = 166, 22
guardflag = HL
hitflag = MAF
pausetime = 0, 2
sparkno = 16
sparkxy = -55,-95
guard.sparkno = -1
hitsound = 5,0
guardsound = 5,14
ground.type = High
ground.slidetime = 30
p2facing = 1
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.hittime  = 30
ground.velocity = -5,-5            
p2stateno = 792
air.velocity = -5,-6
air.hittime = 17  
ground.cornerpush.veloff = -25
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 240, 3]
type = ChangeState
trigger1 = AnimTime = 0
value = 0
ctrl = 1

[Statedef 792]
type    = S
movetype= H
physics = S
ctrl = 0
velset = 0,0,0
anim = 5035

[State 240, 3]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 5035
value = 5050

[State 240, 3]
type = VelAdd
trigger1 = Time >= 0
;trigger1 = time <= 10
X = - 8
Y = - 1.4

[State 240, 3a]
type = VelSet
trigger1 = Time >= 7
;trigger2 = time >= 15
Y = 0

[State 240, 23]
type = VelAdd
trigger1 = Time >= 8
Y = 3

[State 240, 3]
type = ChangeState
trigger1 = Time = 30
value = 5100

;-------------throne
[Statedef 799]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
velset = 0,0,0
anim = 888

[State 181, DI]
type = Explod
triggerall = time = 0
trigger1 = roundstate = 0
trigger2 = roundstate = 1
trigger3 = roundstate = 2
anim = F22
ID = 799
pos = 160,191
postype = Left
facing = 1
removeongethit = 0
sprpriority = -4
ownpal = 1
time = -1
removetime = -1



;-----------------courtyard
[Statedef 821]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 181, goros cell]
type = Explod
triggerall = p2stateno != 713
triggerall = p2stateno != 712
trigger1 = root, Var(24) = 0
triggerall = time = 0
trigger1 = roundstate = 0
trigger2 = roundstate = 1
trigger3 = roundstate = 2
triggerall = Numexplod(1010) < 1
anim = F24
ID = 1010
postype = p1
pos = -349,-400
facing = 1
removeongethit = 0
sprpriority = -5
ownpal = 0
bindtime = -1
removetime = -1

[State -2, cccourtxa]
type = Explod
trigger1 = root, Var(24) = 0
;triggerall = time = 5
trigger1 = p2stateno = 713
;trigger1 = stateno = 431
trigger1 = root, Var(22) = 1
;trigger2 = roundstate = 1
;trigger3 = roundstate = 2
triggerall = Numexplod(101) < 1
;triggerall = var(30) = 10010
;triggerall = var(6) = 0
;trigger1 = facing = 1
anim = F25
ID = 101
postype = p1
pos = -349,-400
facing = 1
removeongethit = 0
sprpriority = -3
ownpal = 0
bindtime = -1

[State -2, cccourtxa]
type = RemoveExplod
trigger5 = numexplod(101) = 1
trigger1 = p2stateno = 713
trigger2 = p2stateno = 712
trigger3 = stateno = 713
trigger4 = stateno = 712
ID = 1010

[State 2, ourtxa]
type = destroyself
trigger1 = p2stateno = 713
trigger2 = p2stateno = 712
trigger3 = stateno = 713
trigger4 = stateno = 712
;trigger3 = root, Var(23) = 1
;trigger4 = Numexplod(712) = 0


;------------------uppercut
[Statedef 712]
type    = S
movetype= I
physics = S
ctrl = 0
anim = 431
sprpriority = 4

[State 90, 51]
type = Explod
trigger1 = time = 0
anim = F16
postype = p1
vel = 0,10
pos = 50,-100
facing = -1
ontop = 1
ownpal = 1

[State 202, ly]
type = VarSet
trigger1 = anim = 41
v = 24
value = 1


[State 202, NotFriendly]
type = VarSet
trigger1 = Time = 0
v = 5
value = 1

[State 202, Notrly]
type = VElADD
trigger1 = Time >= 0
trigger1 = time <= 20
Y = 2

[State 202, No]
type = Pause
trigger1 = Time = 12
trigger2 = Time = 15
trigger3 = Time = 17
trigger4 = Time = 19
time = 1

[State 202, Notrlysdsds]
type = VElSet
trigger1 = Time = 16
X = 0
Y = 0

[State 202, Notrlysdsds]
type = PosSet
trigger1 = Time >= 150
Y = 0

[State 202, Notrlysdsds]
type = Changeanim
trigger1 = Time = 22
value = 41

[State 202, Notrlsdavysds]
type = VElADD
trigger1 = Time >= 18
trigger1 = time <= 30
Y = -1.4

[State 202,lsdavysds]
type = VElSet
trigger1 = time = 55
Y = 0

[State 202,lssds]
type = Changeanim
trigger1 = time = 65
value = 47

[State 202,lssds]
type = ChangeState
trigger1 = animtime = 0
trigger1 = anim = 47
value = 0
ctrl = 1

[State 202, dly]
type = RemoveExplod
trigger1 = animtime = 0
trigger1 = anim = 47
ID = 712

[State 202, NotFriendly]
type = VarSet
trigger1 = Time = 0
v = 5
value = 1

[State 431, 3.2]
type = VarRandom
trigger1 = Time = 10
v = 11
range = 1, 140

[State 431, 3.5]
type = Playsnd
trigger1 = p2movetype = H
trigger1 = Var(11) = [1, 20]
trigger1 = time = 15
value = F5, 13
volume = 50

[State 431, 3.6]
type = Playsnd
trigger1 = p2movetype = H
trigger1 = Var(11) = [21, 40]
trigger1 = time = 15
value = F5, 6
volume = 50

[State 431, 3.7]
type = Playsnd
trigger1 = p2movetype = H
trigger1 = Var(11) = [41, 60]
trigger1 = time = 15
value = F5, 5
volume = 50

[State 431, 3.8]
type = Playsnd
trigger1 = p2movetype = H
trigger1 = Var(11) = [61, 80]
trigger1 = time = 15
value = F0, 21
volume = 50

[State 430, 3.9]
type = Playsnd
trigger1 = p2movetype = H
trigger1 = Var(11) = [81, 100]
trigger1 = time = 15
value = F5, 4
volume = 50

[State 430, 33.9]
type = Playsnd
trigger1 = p2movetype = H
trigger1 = Var(11) = [101, 120]
trigger1 = time = 15
value = F5, 3
volume = 50

[State 430, 3]
type = Playsnd
trigger1 = p2movetype = H
trigger1 = Var(11) = [121, 139]
trigger1 = time = 15
value = F6, 0
volume = 50

[State 431, 3.99999]
type = Varset
trigger1 = AnimTime = 0
v = 11
value = 0

[State 431, 4]
type = ChangeState
trigger1 = Time = 200
value = 11
ctrl = 1

[Statedef 713]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5035
sprpriority = 4

[State 9000, 123]
type = changeanim
trigger1 = animtime = 0
trigger1 = anim = 5035
value = 5050

[State 9000, 12sd3]
type = changeanim
trigger1 = time = 42
;trigger1 = anim = 5050
value = 5080

[State 202, Notrlycx]
type = VElADD
trigger1 = Time <= 10
Y = - .1

[State 202, Notrlcycx]
type = VElSet
trigger1 = Time >= 42
Y = 0

[State 202, Notasrlycx]
type = VElADD
trigger1 = Time >= 30
trigger1 = Time <= 35
Y = .8

[State 202, Notrasdalcycx]
type = VElSet
trigger1 = Time >= 40
Y = 0

[State 202, lys]
type = VarSet
trigger1 = anim = 5080
v = 24
value = 1

[State 430, 3]
type = Playsnd
trigger1 = time = 5
value = F5, 35
volume = 150

[State 430, 3d]
type = Playsnd
trigger1 = time = 0
value = 3, 2

[State 90, 51]
type = Explod
trigger1 = time = 19
anim = F26
postype = p1
vel = .1,.2
pos = 15,-8
facing = -1
;bindtime = -1
ontop = 1
ownpal = 1

[State 90, 51]
type = Explod
trigger1 = time = 17
anim = F26
postype = p1
vel = -.1,.2
pos = -15 ,-8
facing = 1
;bindtime = -1
ontop = 1
ownpal = 1

[State 90, f51]
type = Explod
trigger1 = time = 17
trigger2 = time = 23
anim = F30
postype = p1
vel = -4,-4
pos = 0 ,10
facing = 1
ontop = 1
ownpal = 1
removetime = 70

[State 90, f51]
type = Explod
trigger1 = time = 18
trigger2 = time = 28
trigger3 = time = 30
anim = F30
postype = p1
vel = -6, -1
pos = 0 ,10
facing = 1
ontop = 1
ownpal = 1
removetime = 70

[State 90, f51]
type = Explod
trigger1 = time = 18
trigger2 = time = 30
trigger3 = time = 36
anim = F30
postype = p1
vel = 6, -1
pos = 0 ,18
facing = 1
ontop = 1
ownpal = 1
removetime = 70


[State 90, f51]
type = Explod
trigger1 = time = 19
trigger2 = time = 25
trigger3 = time = 32
anim = F30
postype = p1
vel = 5,-4
pos = 0 ,18
facing = 1
ontop = 1
ownpal = 1
removetime = 70

[State 90, f51]
type = Explod
trigger1 = time = 18
trigger2 = time = 25
trigger3 = time = 30
anim = F30
postype = p1
vel = -2, -6
pos = 0 ,28
facing = 1
ontop = 1
ownpal = 1
removetime = 70

[State 90, f51]
type = Explod
trigger1 = time = 33
trigger2 = time = 37
trigger3 = time = 27
anim = F30
postype = p1
vel = 2, -7
pos = 0 ,28
facing = 1
ontop = 1
ownpal = 1
removetime = 70

[State 90, f51]
type = Explod
trigger1 = time = 46
trigger2 = time = 47
anim = F34
postype = p1
vel = 2, 0
pos = 50 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, f51]
type = Explod
trigger1 = time = 46
trigger2 = time = 47
anim = F34
postype = p1
vel = -2, 0
pos = -70 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, f51]
type = Explod
trigger1 = time = 45
trigger2 = time = 49
anim = F34
postype = p1
vel = 2, 0
pos = 90 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, f51]
type = Explod
trigger1 = time = 45
trigger2 = time = 49
anim = F34
postype = p1
vel = -2, 0
pos = -110 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, f51]
type = Explod
trigger1 = time = 10
anim = F35
postype = p1
vel = 0, 10
pos = 0 ,-164
facing = 1
sprpriority = -2
ownpal = 1


[State 430, 3]
type = Playsnd
trigger1 = time = 22
value = F5, 37
volume = 150


[State 9000, 12sd3]
type = SelfState
trigger1 = time = 50
;trigger1 = anim = 5050
value = 5100
ctrl = 1

;--------------------

[Statedef 4314];715 golden
type    = S
movetype= A
physics = S
juggle  = 8
ctrl = 0
anim = 430
sprpriority = 2

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 11
channel = 1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[State 430, 2]
type = HitDef
trigger1 = !MoveContact 
attr = C, NA
damage    = 200, 50
animtype  = Heavy
hitflag = MAF ;HAF
guardflag = HL
pausetime = 0,0
sparkno = 15
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
ground.cornerpush.veloff = -30
p2stateno = 716
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 430, 4]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 430
value = 11

[State 430, sd4]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 11
value = 0

[State 430, sdsd4]
type = ChangeState
trigger1 = Time = 130
value = 0
ctrl = 1

[Statedef 716]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5035
sprpriority = 4

[State 9000, 123]
type = changeanim
trigger1 = animtime = 0
trigger1 = anim = 5035
value = 5050

[State 9000, 12sd3]
type = changeanim
trigger1 = time = 52
value = 5080


[State 202, Notrly]
type = VElADD
trigger1 = Time >= 0
trigger1 = time <= 4
Y = -2

[State 202, Nsdotrzly]
type = VElSet
trigger1 = Time >= 14
X = 0

[State 202, Notrlycx]
type = VElADD
trigger1 = Time <= 10
X = -.7

[State 202, Notrlcfycx]
type = VElSet
trigger1 = Time >= 14
trigger1 = Time <= 28
Y = 0

[State 202, Notrlyxcz]
type = VElADD
trigger1 = Time >= 40
trigger1 = time <= 44
Y = 2.2

[State 202, Nsdotrzlbvxzy]
type = VElSet
trigger1 = Time >= 53
Y = 0

[State 430, 3]
type = Playsnd
trigger1 = time = 51
value = F7, 0
volume = 150

[State 90, f51]
type = Explod
trigger1 = time = 17
trigger2 = time = 32
trigger3 = time = 47
anim = F30
postype = p2
vel = -1, 8.8
pos = 70 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 15
trigger2 = time = 26
trigger3 = time = 44
anim = F30
postype = p2
vel = 0, 8
pos = 90 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 18
trigger2 = time = 27
trigger3 = time = 42
anim = F30
postype = p2
vel = 1, 8
pos = 180 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 16
trigger2 = time = 23
trigger3 = time = 38
anim = F30
postype = p2
vel = 1, 8.8
pos = 140 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 19
trigger2 = time = 29
trigger3 = time = 44
anim = F31
postype = p2
vel = -1, 8
pos = 70 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 17
trigger2 = time = 21
trigger3 = time = 30
anim = F31
postype = p2
vel = 0, 8.8
pos = 90 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90


[State 90, f5nv1]
type = Explod
trigger1 = time = 43
trigger2 = time = 72
trigger3 = time = 80
trigger4 = time = 89
anim = F34
postype = p2
vel = -1, 0
pos = 70 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, ffg51]
type = Explod
trigger1 = time = 45
trigger2 = time = 52
trigger4 = time = 65
trigger5 = time = 74
trigger6 = time = 83
anim = F34
postype = p2
vel = 1, 0
pos = 160 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, f51s]
type = Explod
trigger1 = time = 46
trigger2 = time = 50
trigger3 = time = 62
trigger4 = time = 70
trigger5 = time = 79
anim = F34
postype = p2
vel = 1.5, 0
pos = 120 ,0
facing = 1
ontop = 1
ownpal = 1

[State 235, sss]
type = envshake
trigger1 = time = 15
time = 10
freq = 190
ampl = 8

[State 430, 3]
type = Playsnd
trigger1 = time = 7
trigger2 = time = 111
value = F5, 35
volume = 200

[State 430, 3sdz]
type = Playsnd
trigger1 = time = 105
value = F5, 0


[State 430, 3]
type = Playsnd
trigger1 = time = 18
value = F5, 37
volume = 150

[State 90, f51]
type = Explod
trigger1 = time = 54
trigger2 = time = 58
trigger3 = time = 62
anim = F31
postype = p2
vel = -1, 7
pos = 70 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 56
trigger2 = time = 60
trigger3 = time = 64
anim = F31
postype = p2
vel = 0, 8.8
pos = 90 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 44
trigger2 = time = 70
trigger3 = time = 82
anim = F31
postype = p2
vel = 1, 7
pos = 120 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 90, f51]
type = Explod
trigger1 = time = 56
trigger2 = time = 90
trigger3 = time = 74
anim = F31
postype = p2
vel = 1, 8.8
pos = 180 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90

[State 9000, ds12sd3]
type = changeanim
trigger1 = time = 70
value = 5120

[State 9000, ds12sd3vcx]
type = changeanim
trigger1 = animtime = 0
trigger1 = anim = 5120
value = 5300

[State 90, vbf51]
type = Explod
trigger1 = time = 100
anim = F36
postype = p1
vel = 0, 12
pos = 0 ,-280
facing = 1
ontop = 1
ownpal = 1
removetime = 25

[State 90, vbf51]
type = Explod
trigger1 = time = 125
anim = F36
postype = p1
pos = 0 ,0
facing = 1
ontop = 1
ownpal = 1
removetime = -1

[State 9000, ds12sdzx3vcx]
type = changeanim
trigger1 = time = 116
value = 888

[State 9000, 123]
type = Explod
trigger1 = time = 115
anim = F17
postype = p1
pos = 0,0
facing = -1
;postype = front
bindtime = 1
facing = 1
sprpriority = 4
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 114
anim = F17
postype = p1
pos = 0,-40
facing = 1
;postype = front
bindtime = 1
facing = 1
sprpriority = 4
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 114
anim = F16
postype = p1
pos = -10,-70
facing = 1
;postype = front
bindtime = 1
facing = 1
sprpriority = 4
ownpal = 1

[State 9000, 123]
type = Explod
trigger1 = time = 113
anim = F17
postype = p1
pos = 20,-85
facing = -1
;postype = front
bindtime = 1
facing = 1
sprpriority = 4
ownpal = 1


[State 235, ssscx]
type = envshake
trigger1 = time = 123
time = 20
freq = 250
ampl = 10

[State 345, pup]
type = PlaySnd
trigger1 = time = 110
value = F5,16

[State 345, pup]
type = PlaySnd
trigger1 = time = 111
value = F5,16


[State 345, pughp]
type = PlaySnd
trigger1 = time = 112
value = F5, 17

[State 345, pughp]
type = PlaySnd
trigger1 = time = 113
value = F5, 17


[State 345, pughp]
type = PlaySnd
trigger1 = time = 114
value = F5, 18

[State 345, pughp]
type = PlaySnd
trigger1 = time = 115
value = F5, 19

[State 345, hp]
type = LifeSet
trigger1 = time >= 128
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 130
value = 5150

;---------------------
[Statedef 4316];801 slaughter house
type    = S
movetype= A
physics = S
juggle  = 1
ctrl = 0
anim = 430
sprpriority = 4

[State 9000, 1]
type = TargetFacing
trigger1 = time >= 1
trigger1 = time <= 10
value = -1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1

[State 9000, 1]
type = Explod
trigger1 = time = 1
anim = 888
pos = -160*const(size.xscale),-130*const(size.xscale)
ID = 2000
postype = left
facing = 1
;sprpriority = 1
removetime = -1


[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 210, 1]
type = Playsnd
trigger1 = time = 1
value = F5,11
volume = 60
channel = 1

[State 430, 2]
type = HitDef
trigger1 = !movecontact;trigger1 = animelem = 5
;trigger1 = var(30) = 10007
attr = C, NA
;damage    = 200, 50
animtype  = Heavy
getpower = 200,50 
hitflag = MAF ;HAF
guardflag = HL
pausetime = 30,2
;p1stateno = 431
numhits = -1
p2stateno = 802
sparkno = -1
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
guardsound = 5,14
ground.cornerpush.veloff = -5
ground.type = High
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.slidetime = 20
ground.hittime  = 20
ground.velocity = -1.8,-12
air.velocity = -1.8,-12
yaccel = 0.38
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 430, 4]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 430
value = 0

[State 430, 4sd]
type = SelfState
trigger1 = Time = 340
value = 0
ctrl = 1


[State 43005, VeX]
type = sprpriority
trigger1 = Time >= 50
value = -2
;---------------
[Statedef 802]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 888
;sprpriority = 4

[State 9000, 123]
type = Explod
trigger1 = time = 0
anim = F15
postype = p2
pos = 35,-105
ID = 30
bindtime = -1
facing = 1
ontop = 1
ownpal = 1
;removetime = 70


[State 430, 3]
type = Playsnd
trigger1 = time = 12
TRIGGER2 = TIME = 186
value = F5, 35
volume = 250

[State 430, 3DF]
type = Playsnd
trigger1 = time = 25
value = 4, 1

[State 90, f51]
type = Explod
trigger1 = time = 17
trigger2 = time = 32
trigger3 = time = 47
anim = F30
postype = p2
vel = -1, 8.8
pos = 70 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 15
trigger2 = time = 26
trigger3 = time = 44
anim = F30
postype = p2
vel = 0, 8
pos = 70 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 18
trigger2 = time = 27
trigger3 = time = 42
anim = F30
postype = p2
vel = 1, 8
pos = 180 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 16
trigger2 = time = 23
trigger3 = time = 38
anim = F30
postype = p2
vel = 1, 8.8
pos = 140 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 29
trigger2 = time = 39
trigger3 = time = 44
anim = F31
postype = p2
vel = -1, 8
pos = 60 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 27
trigger2 = time = 31
trigger3 = time = 40
anim = F31
postype = p2
vel = 0, 8.8
pos = 50 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30


[State 90, f5nv1]
type = Explod
trigger1 = time = 33
trigger2 = time = 42
trigger3 = time = 30
trigger4 = time = 59
anim = F34
ID = 30
postype = p2
vel = -1, 0
pos = 66 ,0
facing = 1
ontop = 1
ownpal = 1

[State 90, ffg51]
type = Explod
trigger1 = time = 25
trigger2 = time = 32
trigger4 = time = 45
trigger5 = time = 54
anim = F34
postype = p2
vel = 1, 0
pos = 50 ,0
facing = 1
ontop = 1
ownpal = 1
ID = 30

[State 90, f51s]
type = Explod
trigger1 = time = 26
trigger2 = time = 30
trigger3 = time = 42
trigger4 = time = 50
anim = F34
postype = p2
vel = 1.5, 0
pos = 100 ,0
facing = 1
ontop = 1
ownpal = 1
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 14
trigger2 = time = 18
trigger3 = time = 22
anim = F31
postype = p2
vel = -1, 7
pos = 60 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 25
trigger2 = time = 16
trigger3 = time = 24
anim = F31
postype = p2
vel = 0, 8.8
pos = 90 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 14
trigger2 = time = 17
trigger3 = time = 18
anim = F31
postype = p2
vel = 1, 7
pos = 120 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 16
trigger2 = time = 19
trigger3 = time = 14
anim = F31
postype = p2
vel = 1, 8.8
pos = 40 ,-250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30


[State 9000, 123]
type = Explod
trigger1 = time = 0
anim = 5050
postype = p1
pos = 0,0
vel = -1 , -10
;postype = front
;bindtime = 1
facing = 1
sprpriority = 2
;ontop = 1
ownpal = 1
removetime = 100


[State -34, ony]
type = Helper
trigger1 = time = 60
trigger1 = facing = -1
trigger1 = facing != 1
ID = 5050
stateno = 803
pos = 156, 350
postype = Left
size.xscale = 1
size.yscale = 1
facing = -1

[State -34, ony]
type = Helper
trigger1 = time = 60
trigger1 = facing != -1
trigger1 = facing = 1
ID = 5050
stateno = 803
pos = 156, 350
postype = Left
size.xscale = 1
size.yscale = 1
facing = 1


[State 430, 1]
type = PlaySnd
trigger1 = Time = 92
value = F7, 0

[State 430, 13]
type = PlaySnd
trigger1 = Time = 295
value = F5, 41
VOLUME = 200

;[State 345, ghp]
;type = PlaySnd
;trigger1 = time = 188
;value = F5, 21
;volume = 130

;[State 345, pughp]
;type = PlaySnd
;trigger1 = time = 187
;value = 4, 1
;volume = 50


[State 345, hp]
type = Removeexplod
trigger1 = time = 60
ID = 30

[State 235, sss]
type = envshake
trigger1 = time = 189
time = 15
freq = 50
ampl = 3

;[State 235, s]
;type = envshake
;trigger1 = time = 190
;time = 15
;freq = 80
;ampl = 9


[State 345, hp]
type = LifeSet
trigger1 = time >= 315
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 320
value = 5150



;------------------

[Statedef 803]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5050
sprpriority = 5

[State 9000, 123]
type = VelAdd
trigger1 = time = 0
Y = -10

[State 9000, 1233]
type = VelAdd
trigger1 = time = 72
Y = 13


[State 9000, 34123]
type = VelSet
trigger1 = time = 66
Y = 0

[State 9000, 51]
type = Explod
trigger1 = time = 0
anim = F45
postype = Left
pos = 150,240
vel = 0 , 0
;postype = front
;bindtime = 1
facing = 1
sprpriority = 2
ownpal = 1
removetime = -1


[State 9000, 514]
type = Explod
trigger1 = time = 120
anim = F42
postype = Left
pos = 155,210
vel = 0 , 0
;postype = front
;bindtime = 1
facing = 1
sprpriority = 5
ownpal = 1
removetime = -1

[State 9000, 514r]
type = Explod
trigger1 = time = 120
anim = F43
postype = Left
pos = 155,210
vel = 0 , 0
;postype = front
;bindtime = 1
facing = 1
sprpriority = 3
ownpal = 1
removetime = -1

[State 9000, 5FG14r]
type = Explod
trigger1 = time = 120
anim = F46
postype = Left
pos = 155,210
vel = 0 , 0
;postype = front
;bindtime = 1
facing = 1
sprpriority = 4
ownpal = 1
removetime = -1


[State 9000, 5123]
type = Explod
trigger1 = time = 120
anim = F44
postype = Left
pos = 155,210
vel = 0 , 0
;postype = front
;bindtime = 1
facing = 1
sprpriority = 5
ownpal = 1
removetime = -1

[State 90, 5fd1]
type = posset
trigger1 = time = 180
Y = - 500


[State 90, 51]
type = sprpriority
trigger1 = time = 120
value = 4


[State 90, f51]
type = Explod
trigger1 = time = 170
trigger2 = time = 166
trigger3 = time = 154
anim = F30
postype = LEFT
vel = 0, 8
pos = 70 ,-250
facing = 1
sprpriority = 5
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 156
trigger2 = time = 163
trigger3 = time = 148
anim = F30
postype = LEFT
vel = 1, 8.8
pos = 140 ,-250
facing = 1
sprpriority = 5
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 149
trigger2 = time = 159
trigger3 = time = 144
anim = F31
postype = LEFT
vel = -1, 8
pos = 160 ,-250
facing = 1
sprpriority = 5
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 157
trigger2 = time = 153
trigger3 = time = 154
anim = F31
postype = LEFT
vel = 0, 8.8
pos = 150 ,-250
facing = 1
sprpriority = 5
ownpal = 1
removetime = 90
ID = 30


[State 90, f51]
type = Explod
trigger1 = time = 164
trigger2 = time = 177
trigger3 = time = 158
anim = F31
postype = LEFT
vel = 0, 7
pos = 150 ,-250
facing = 1
sprpriority = 5
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 166
trigger2 = time = 159
trigger3 = time = 164
anim = F31
postype = LEFT
vel = 0, 8.8
pos = 140 ,-250
facing = 1
sprpriority = 5
ownpal = 1
removetime = 90
ID = 30




[State 90, f51]
type = Explod
trigger1 = time = 7
trigger2 = time = 22
trigger3 = time = 47
anim = F30
postype = LEFT
vel = 4, -15
pos = 170 ,250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 5
trigger2 = time = 16
trigger3 = time = 34
anim = F30
postype = LEFT
vel = 2, -10
pos = 140 ,250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 4
trigger2 = time = 17
trigger3 = time = 22
anim = F30
postype = LEFT
vel = 2, -14
pos = 180 ,250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 6
trigger2 = time = 13
trigger3 = time = 28
anim = F30
postype = LEFT
vel = -2, -13
pos = 140 ,250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 19
trigger2 = time = 29
trigger3 = time = 44
anim = F31
postype = LEFT
vel = 2,-12
pos = 160 ,250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

[State 90, f51]
type = Explod
trigger1 = time = 2
trigger2 = time = 23
trigger3 = time = 34
anim = F31
postype = LEFT
vel = 3, -12
pos = 150 ,250
facing = 1
ontop = 1
ownpal = 1
removetime = 90
ID = 30

;-------------------

[Statedef 4318];804 Pit II
type    = S
movetype= A
physics = S
juggle  = 1
ctrl = 0
anim = 430
sprpriority = 4

[State 9000, 1]
type = TargetFacing
triggerall = time = 1
trigger1 = facing = -1
trigger2 = facing = 1
value = -1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1

[State 9130, Setal]
type = Varset
trigger1 = time = 200
V = 30
value = 22


[State 9000, 1]
type = Explod
trigger1 = time = 1
anim = 888
pos = -160*const(size.xscale),-130*const(size.xscale)
ID = 2200
postype = left
facing = 1
;sprpriority = 1
removetime = -1

[State 9000, 1]
type = Explod
trigger1 = time = 1
anim = 888
pos = -160*const(size.xscale),-130*const(size.xscale)
ID = 2000
postype = left
facing = 1
;sprpriority = 1
removetime = -1


[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 210, 1]
type = Playsnd
trigger1 = time = 1
value = F5,11
volume = 60
channel = 1

[State 430, 2]
type = HitDef
trigger1 = !movecontact;trigger1 = animelem = 5
;trigger1 = var(30) = 10007
attr = C, NA
;damage    = 200, 50
animtype  = Heavy
getpower = 200,50 
hitflag = MAF ;HAF
guardflag = HL
pausetime = 30,2
;p1stateno = 431
numhits = -1
p2stateno = 805
sparkno = -1
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
p2facing = 1
guardsound = 5,14
ground.cornerpush.veloff = -5
ground.type = High
guard.ctrltime = 20
guard.velocity = -25
guard.slidetime = 20
ground.slidetime = 20
ground.hittime  = 20
ground.velocity = -1.8,-12
air.velocity = -1.8,-12
yaccel = 0.38
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 430, 4]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 430
value = 180

[State 430, 4sd]
type = SelfState
trigger1 = Time = 340
value = 0
ctrl = 1

[State 43, AssertSpecial]
type = AssertSpecial
trigger1 = time >= 95
trigger2 = roundstate = 3
trigger4 = roundstate = 4
trigger1 = NumExplod(2200) = 1
flag = noFG

[State 43005, VeX]
type = sprpriority
trigger1 = Time >= 50
value = -2
;---------------
[Statedef 805]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 5050
;sprpriority = 4

[State 9000, 123]
type = Explod
trigger1 = time = 0
anim = F15
postype = p2
pos = 35,-105
ID = 30
bindtime = -1
facing = 1
ontop = 1
ownpal = 1
;removetime = 70

[State 430, DF]
type = Playsnd
trigger1 = time = 0
value = 3, 2


[State 430, 3DF]
type = Playsnd
trigger1 = time = 60
value = 4, 1

[State 9000, 514]
type = Explod
trigger1 = time = 60
anim = 5050
pos = 50, 350
postype = p1
vel = -2 , 15
facing = 1
ontop = 1
ownpal = 1
removetime = -1


[State -34, ony]
type = Helper
trigger1 = time = 60
ID = 5050
stateno = 806
pos = 0, 520
postype = p1
size.xscale = .5
size.yscale = .5
size.shadowoffset = -1000


[State 9000, 123]
type = VelSet
trigger1 = time = 0
Y = -13
X = -2

[State 9000, 54123]
type = VelSet
trigger1 = time >= 60
Y = 0
X = 0

[State 9000, 34123]
type = PosSet
trigger1 = time = 80
Y = 444

[State 430, 13]
type = PlaySnd
trigger1 = Time = 269
value = F5, 0
VOLUME = 200

[State 345, ghp]
type = PlaySnd
trigger1 = time = 268
value = F5, 16
volume = 130

[State 345, pughp]
type = PlaySnd
trigger1 = time = 268
value = F5, 17
volume = 50

[State 345, pup]
type = PlaySnd
trigger1 = time = 267
trigger2 = time = 269
value = F5, 18
volume = 50


[State 345, hp]
type = Removeexplod
trigger1 = time = 60
ID = 30

;[State 235, sss]
;type = envshake
;trigger1 = time = 189
;time = 15
;freq = 50
;ampl = 3


[State 345, hp]
type = LifeSet
trigger1 = time >= 315
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 320
value = 5150


;------------------

[Statedef 806]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 888
sprpriority = 5

[State 9000, 1233]
type = VelSet
trigger1 = time = 70
Y = 1.8
X = -.2

[State 9000, 123sd3]
type = posSet
trigger1 = time = 0
X = 0


[State 9000, 33]
type = changeanim
trigger1 = time = 110
value = 5050


[State 9000, 51]
type = Explod
trigger1 = time = 75
anim = F51
postype = Left
pos = 0,0
vel = 0 , 0
facing = 1
sprpriority = 2
ownpal = 1
removetime = -1


[State -34, onyd]
type = Helper
trigger1 = time = 75
ID = 5051
stateno = 807
pos = 0, -200
postype = left
size.xscale = 1
size.yscale = 1
size.shadowoffset = -1000


[State 90, 51]
type = sprpriority
trigger1 = time >= 0
value = 4

[State 9000, 34]
type = changeanim
trigger1 = time = 224
value = 888

[State 235, s]
type = envshake
trigger1 = time = 221
time = 15
freq = 80
ampl = 9


[State 9000, 51]
type = Explod
trigger1 = time = 220
anim = F17
postype = p1
pos = 0,-30
vel = 0 , 0
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6

[State 9000, 51d]
type = Explod
trigger1 = time = 223
anim = F16
postype = p1
pos = 0,-30
vel = 0 , 0
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6

[State 9000, 51fd]
type = Explod
trigger1 = time = 227
anim = F16
postype = p1
pos = 0,-30
vel = 0 , 0
facing = -1
ontop  =1
ownpal = 1
scale = .6,.6


[State 9000, 51df]
type = Explod
trigger1 = time = 222
anim = 43051
postype = p1
pos = 0,-30
vel = -1 , -6
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6
removetime = 200

[State 9000, 51dff]
type = Explod
trigger1 = time = 227
anim = 43052
postype = p1
pos = 0,-30
vel = 4 , 1
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6
removetime = 200

[State 9000, 51ddf]
type = Explod
trigger1 = time = 224
anim = 43052
postype = p1
pos = 0,-30
vel = -3 , -2
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6
removetime = 200

[State 9000, 51dfv]
type = Explod
trigger1 = time = 227
anim = 43053
postype = p1
pos = 0,-30
vel = -5 , -1
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6
removetime = 200

[State 9000, 51dfc]
type = Explod
trigger1 = time = 224
anim = 43053
postype = p1
pos = 0,-30
vel = 3 , -2
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6
removetime = 200

[State 9000, 5c]
type = Explod
trigger1 = time = 228
anim = 43054
postype = p1
pos = 0,-30
vel = 1 , 4
facing = 1
ontop  =1
ownpal = 1
scale = .6,.6
removetime = 200


[Statedef 807]
type    = S
movetype = A
physics = N
ctrl = 0
anim = 888
sprpriority = 5

[State 9000, 514]
type = Explod
trigger1 = time = 0
anim = F52
postype = p1
pos = 0,0
bindtime = -1
facing = 1
sprpriority = 3
ownpal = 1
removetime = -1


[State 9000, 1233]
type = VelSet
trigger1 = time = 20
Y = -3.1

[State 9000, 123sd3]
type = VelSet
trigger1 = time >= 140
Y = 0


;-------TOMB
[Statedef 4322];808 Kombat Tomb
type    = S
movetype= A
physics = S
juggle  = 8
ctrl = 0
anim = 430
sprpriority = 2

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 15

[State 430, 1]
type = PlaySnd
trigger1 = Time = 1
value = F5, 11
channel = 1

[State 9130, SetFatal]
type = Varset
trigger1 = movehit
V = 4
value = 1


[State 430, 2]
type = HitDef
trigger1 = !MoveContact 
attr = C, NA
damage    = 200, 50
animtype  = Heavy
hitflag = MAF ;HAF
guardflag = HL
pausetime = 50,0
sparkno = 15
sparkxy = -15,-95
guard.sparkno = -1
hitsound   = 5,0
;p2facing = 1
ground.cornerpush.veloff = -30
p2stateno = 809
envshake.time = 20
envshake.freq = 30
envshake.ampl = 15
fall = 1
fall.recover = 0
kill       = (Var(9) = 0)
fall.kill  = (Var(9) = 0)
guard.kill = (Var(9) = 0)

[State 430, 4]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 430
value = 11

[State 430, sd4]
type = ChangeAnim
trigger1 = AnimTime = 0
trigger1 = anim = 11
value = 0

[State 430, sdsd4]
type = ChangeState
trigger1 = Time = 150
value = 0
ctrl = 1

[Statedef 809]
type    = S
movetype = H
physics = N
ctrl = 0
anim = 888
;sprpriority = 4

[State 9000, 123]
type = Explod
trigger1 = time = 0
anim = 5050
postype = p1
pos = 0,0
ID = 30
Vel = 0,-12
;facing = 1
sprpriority = 2
ownpal = 1
removetime = 15

[State 9000, 123]
type = Explod
trigger1 = time = 15
anim = 5160
postype = p1
pos = 0,-10
ID = 30
;facing = 1
sprpriority = 2
ownpal = 1
removetime = -1

[State 9000, 123s]
type = Explod
trigger1 = time = 15
anim = F16
postype = p1
pos = 30,0
ID = 30
facing = 1
sprpriority = 5
ownpal = 1

[State 9000, 123ss]
type = Explod
trigger1 = time = 15
anim = F16
postype = p1
pos = -30,0
ID = 30
facing = -1
sprpriority = 5
ownpal = 1

[State 430, 3DF]
type = Playsnd
trigger1 = time = 15
value = 4, 1

[State 9000, 514]
type = Explod
trigger1 = time = 0
anim = F53
pos = 0, -65
postype = left
facing = 1
sprpriority = 4
ownpal = 1
removetime = -1


[State 9000, 123]
type = VelSet
trigger1 = time = 0
Y = -16

[State 9000, 54123]
type = VelSet
trigger1 = time >= 80
Y = 0
X = 0

[State 9000, 34123]
type = PosSet
trigger1 = time = 180
Y = 444

[State 430, 13]
type = PlaySnd
trigger1 = Time = 13
value = F5, 0
VOLUME = 200

[State 345, ghp]
type = PlaySnd
trigger1 = time = 14
value = F5, 16
volume = 130

[State 235, sss]
type = envshake
trigger1 = time = 14
time = 15
freq = 60
ampl = 6


[State 345, hp]
type = LifeSet
trigger1 = time >= 185
value = 0

[State 240, 335]
type = SelfState
trigger1 = Time = 190
value = 5150


[Statedef 810]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 181, goros cell]
type = Explod
triggerall = 1
trigger1 = roundstate = 0
trigger2 = roundstate = 1
trigger3 = roundstate = 2
triggerall = p2name != "shao kahn,"
triggerall = Numexplod(1010) < 1
trigger4 = Numexplod(1011) < 1
trigger4 = roundstate != 0
trigger4 = roundstate != 1
anim = F56
ID = 1010
postype = p1
pos = 0,0
facing = 1
removeongethit = 0
sprpriority = -3
ownpal = 0
bindtime = -1
removetime = -1


[State 9000, 54123]
type = RemoveExplod
trigger1 = p2stateno = 431
trigger2 = root, stateno = 431
triggerall = roundstate = 2
;triggerall = roundstate != 4
Id = 1010

[State 181, go4]
type = Explod
;trigger1 = p2stateno = 431
trigger1 = root, stateno = 431
;triggerall = facing = 1
triggerall = 1
triggerall = roundstate != 0
triggerall = roundstate != 1
;triggerall = Numexplod(1010) != 1
triggerall = Numexplod(1011) < 1
triggerall = p2name != "shao kahn,"
anim = F55
ID = 1011
postype = p1
pos = 0,0
facing = 1
removeongethit = 0
sprpriority = -3
ownpal = 0
bindtime = -1
;removetime = -1

[State 9000, 54]
type = RemoveExplod
trigger1 = p2stateno = 431
trigger2 = root, stateno = 431
triggerall = Numexplod(1011) > 2
Id = 1011
;--------------
[Statedef 30]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F2
ID = 2
postype = p1
pos = 50,-110
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5

[State 200, Blood11]
type = Explod
trigger1 = time = 0
TRIGGER1 = NUMEXPLOD(3) < 2
anim = F57
ID = 3
postype = p1
pos = 50,-110
ownpal = 1
VEL = 2,0
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5


[State 181, BLOOd]
type = destroyself
trigger1  = time = 2

;-------------------------

[Statedef 27]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 200, Blood11]
type = Explod
trigger1 = time = 0
TRIGGER1 = NUMEXPLOD(3) < 2
anim = F57
ID = 3
postype = p1
pos = 50,-110
ownpal = 1
VEL = 2,0
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F1
ID = 2
postype = p1
pos = 50,-110
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5

;[State 430, 13]
;type = PlaySnd
;trigger1 = Time = 48
;value = F5, 43

[State 181, BLOOd]
type = destroyself
trigger1  = time = 5

;------------
[Statedef 28]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F1
ID = 2
postype = p1
pos = 60,-110
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5
FACING = -1

[State 200, Blood11]
type = Explod
trigger1 = time = 0
TRIGGER1 = NUMEXPLOD(3) < 2
anim = F57
ID = 3
postype = p1
pos = 80,-100
ownpal = 1
VEL = -2,0
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5
FACING = -1

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F15
ID = 2
postype = p1
pos = 65,-100
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5

;[State 430, 13]
;type = PlaySnd
;trigger1 = Time = 50
;trigger2 = Time = 65
;value = F5, 43

[State 181, BLOOd]
type = destroyself
trigger1  = time = 5


;-----------------
[Statedef 29]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F1
ID = 2
postype = p1
pos = 50,-110
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5
;FACING = -1

[State 200, Blood11]
type = Explod
trigger1 = time = 0
TRIGGER1 = NUMEXPLOD(3) < 2
anim = F57
ID = 3
postype = p1
pos = 80,-105
ownpal = 1
VEL = -2,0
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5
FACING = -1

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F15
ID = 2
postype = p1
pos = 65,-100
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5

;[State 430, 13]
;type = PlaySnd
;trigger1 = Time = 45
;trigger2 = Time = 65
;value = F5, 43

[State 181, BLOOd]
type = destroyself
trigger1  = time = 5


[Statedef 31]
type    = S
movetype= I
physics = S
;juggle  = 2
ctrl = 0
anim = 888

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F2
ID = 2
postype = p1
pos = 60,-110
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5
FACING = 1

[State 200, Blood11]
type = Explod
trigger1 = time = 0
TRIGGER1 = NUMEXPLOD(3) < 2
anim = F57
ID = 3
postype = p1
pos = 80,-100
ownpal = 1
VEL = -2,0
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5
FACING = -1

[State 200, Blood1]
type = Explod
trigger1 = time = 0
anim = F16
ID = 2
postype = p1
pos = 65,-100
ownpal = 1
persistent = 0
bindtime = 1
ignorehitpause = 1
sprpriority = 5

[State 181, BLOOd]
type = destroyself
trigger1  = time = 5


