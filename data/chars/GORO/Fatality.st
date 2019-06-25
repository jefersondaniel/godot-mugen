[Statedef 9000]
type    = S
movetype= A
physics = S
juggle  = 0
velset = 0,0
anim = 9000
ctrl = 0

[State 9000, 5]
type = HitDef
trigger1 = p2life < 2
trigger1 = p2movetype != H
attr = A, HT
numhits = -1
guardflag = A
hitflag = LAMF
;priority  = 7,Hit
sparkno = -1
p2stateno = 9001;9010
damage = 99999,9999
kill = 0
ground.velocity = 0,50
air.velocity = 0,50
air.recovery = 0
recovery = 0

[State 9000, 5.5]
type = ParentVarset
trigger1 = time = 0
V = 13
value = 400

[State 9000, 6d]
type = TargetState
trigger1 = 1
value = 9001;9010

[State 9000, 6]
type = Destroyself
trigger1 = time >= 1
trigger2 = p2stateno = 9001;9010
trigger3 = roundstate = 3
trigger4 = roundstate = 4

;---------------------------------------------------------------------------
;Fatality time
[Statedef 9001]
type    = S
movetype= H
physics = S
velset = 0,0
ctrl = 0

;
[State 987123, 1]
type = SelfState
trigger1 = time = 1
value = 9010

;-----------------------

;Fatality time
[Statedef 9010]
type    = S
movetype= H
physics = S
velset = 0,0
ctrl = 0

;FINISH SOUND music
[State 2, 5.999]
type = Playsnd
trigger1 = time = 0
value = F5, 22
Channel = 1
persistent = 3
volume = 50

; hara kiri humano/cpu
[State 987123, 1]
type = changestate
triggerall= p2stateno != [3000, 3999]
trigger1 = command = "harakiri"
trigger2 = var(50) = 1
trigger2 = time = 1
trigger2 = random%5 = 1
triggerall = animexist(3500)
value = 3500

[State 9873, 1]
type = LifeSet
trigger1 = Animelem = 1
value = 1

[State 9873, 1]
type = PosSet
trigger1 = 1
Y = 0

[State 9873, 1324]
type = LifeSet
trigger1 = time = 1
value = 1


[State 9873, 13234]
type = NotHitBy
value = , AP
trigger1 = 1

[State 987123, 1]
type = LifeAdd
triggerall = Time = 350
trigger1 = p2stateno != [3000,3999]
value = -500

; After 600 ticks and with no fatality, p2 falls down
[State 987123, 1]
type = changestate;SelfState
triggerall = Time = 350
trigger1 = p2stateno != [3000,3999]
value = 5050
ctrl = 0

[State 9010, 0.1]
type = Changeanim
trigger1 = statetype != A
trigger1 = animexist(5300)
trigger1 = anim != 5300
value = 5300

[State 9010, 1]
type = Changeanim2
trigger1 = !animexist(5300)
trigger1 = anim != 9010
trigger1 = statetype != A
value = 9010

[State 9010, 034.1]
type = PosSet
trigger1 = p2stateno =[0,9999]
Y = 0

;-------------------------------------------------------------------------------


[Statedef 9011]
type    = S
movetype= H
physics = S
juggle  = -10
ctrl = 0
velset = 0,0,0

[State 987123, 1]
type = LifesET
trigger1 = 1
value = 4

; Dizzying animation
[State 987124, 2]
type = ChangeAnim 
trigger1 = AnimExist(5300)
trigger1 = Anim != 5300
value = 5300

;-------------------------------------------------------------------------------
;Shows Mercy bastardo!
[Statedef 3997]
type    = S
movetype= I
physics = S
anim = 0
ctrl = 0

;sonido de shows mercy
[State 210, 1]
type = Playsnd
trigger1 = time = 60
value = 6,2
volume = 60

;cartel de mercy
[State 181, cartel]
type = Explod
trigger1 = time = 60
ID = 200
anim = F200
pos = 156,0
postype = left
bindtime = -1
facing = 1
sprpriority = 2
ontop = 1
ownpal = 1
removetime = -2

;explod invisible, para que no se pueda hacer 2 veces la mercy
[State 181, cartel]
type = Explod
trigger1 = time = 0
ID = 3800
anim = 888
removetime = -1

;manda a custom sin control
[State 430, 31sdaa]
type = helper
trigger1 = time = 0
stateno = 3998
postype = p1

;previene fallo si tenemos poca energia
[State 9130, SetFatal]
type = lifeset
trigger1 = life < 2
value = 2

;variables de finish
[State 9130, SetFatal]
type = Varset
trigger1 = time = 0
V = 3
value = 0

[State 9130, SetFatal]
type = Varset
trigger1 = time = 0
V = 13
value = 0

[State 9130, SetFatal]
type = Varset
trigger1 = time = 0
V = 9
value = 0

[State 9130, SetFatal]
type = Varset
trigger1 = time = 0
V = 19
value = 0

[State 9130, SetFatal]
type = Varset
trigger1 = time = 0
V = 4
value = 0
;fin de cosas lokas de finish

[State 8000, sadsd]
type = BGPalFX
trigger1 = numexplod(200)=1
time = 9999
add = 0, 0, 0

;cuando termina la anim de mercy vuelve a tener control
[State 430, 31sdaa]
type = changestate
trigger1 = time > 60
trigger1 = numexplod(200)=0
value = 0
ctrl = 1

;helper que golpea a pl2
[Statedef 3998]
type    = S
movetype= A
physics = S
anim = 9000
ctrl = 0

;manda a custom (si no fallaba)
[State 1200, BoltFat]
type = HitDef
trigger1 = time = 0
attr = S, NT
hitflag = MAFD
guardflag = A
damage = -60
sparkno = -1
p2stateno = 3999

[State 430, 31sdaa]
type = destroyself
trigger1 = movehit

;custom state
[Statedef 3999]
type    = S
movetype= H
physics = S
ctrl = 0

;vuelve a tener control
[State 430, 31sdaa]
type = selfstate
trigger1 = time = 138
value = 0
ctrl = 1

; -----------------

[Statedef 3500]
type    = S
movetype= A
physics = S
;anim = 0
ctrl = 0

;arregla el bug del tiempo
[State 9873, 1]
type = AssertSpecial
trigger1 = 1
flag = timerfreeze

[State 430, 31sdaa]
type = helper
trigger1 = time = 0
stateno = 3501
postype = p1

[State 430, 31sdaa]
type = changestate
trigger1 = Time = 0;60
value = 3503

[State 430, 31sdaa]
type = NotHitBy
trigger1 = 1
value = SCA

; Golpeamos al oponente y lo mandamos al custom state sin control...
[Statedef 3501]
type    = S
movetype= A
physics = S
anim = 9000
ctrl = 0

[State 1200, BoltFat]
type = HitDef
trigger1 = p2statetype = S
attr = S, NT
hitflag = MAFD
guardflag = A
sparkno = -1
p2stateno = 3502

[State 200, 7]
type = destroyself
trigger1 = movehit

; El oponente queda sin control, la variable se pone en valor "hara kiri" y espera a que muera el otro para festejar.
[Statedef 3502]
movetype= H
ctrl = 0

[State 9130, SetFatal]
type = Varset
trigger1 = time = 0
V = 4
value = 6

[State 3105, end]
type = changeanim
trigger1 = time = 0
value = 0

[State 430, 31sdaa]
type = selfstate
trigger1 = p2life <=0
value = 0
ctrl = 1

;--- Cosas de Fatales ---

;- Para fatal de jade, classic sub-zero... -
[Statedef 6001]
type    = S
movetype= I
physics = N
anim = 888

[State 3105, queda clavado]
type = Explod
trigger1 = time = 0
anim = 6001
pos = 0,0
postype = p1
sprpriority = 1
id = 6001

[State 3105, chau explod]
type = removeExplod
trigger1 = time = 41
id = 6001

[State 2, sangre y mas sangre]
type = explod
trigger1 = time = 0
trigger2 = time = 10
trigger3 = time = 20
trigger4 = time = 30
trigger5 = time = 40
pos = -4, -51
postype = p1
anim = F80; arreglar anim de sangre
ontop = 1

[State 200, grito]
type = playsnd
trigger1 = Time = 0
value = 4,1

[State 200, 7]
type = lifeadd
trigger1 = Time = 41
value = -9999

[State 200, 7]
type = selfstate
trigger1 = Time = 41
value = 5150

;--- Para Friendship --- (queda mareandose)

[Statedef 6002]
type    = S
movetype= I
physics = N
velset = 0, 0
ctrl = 0

[State 3100, asigna anim]
type = varset
trigger1 = time = 1
v = 45
value = 5300

[State 9399, 3]
type = Lifeadd
trigger1 = Time > 150
trigger1 = animtime = 0
Value = -9999

[State 9399, 2]
type = selfstate
trigger1 = time > 150
trigger1 = animtime = 0
value = 5150

;--- Para fatales de decapitación tipo la de cage ---

[Statedef 6003];661
type    = S
movetype= H
physics = S
ctrl = 0
velset = 0,0,0
anim = 661

[State 9399, 2]
type = varset
trigger1 = time = 0
v = 45
value = 6611

[State 1200, 2at]
type = Explod
trigger1 = time = 1
trigger1 = FrontEdgeDist > 130
anim = 662
pos = 0,0
postype = p1
facing = -1
ID = 662
sprpriority  >= 2

[State 1200, 2at]
type = Explod
trigger1 = time = 1
trigger1 = FrontEdgeDist < 131
anim = 662
pos = 0,0
postype = p1
facing = 1
ID = 662
sprpriority  >= 2

[State 1200, 2at]
type = Explod
trigger1 = time = 0
anim = F16
pos = 10,-118
postype = p1
sprpriority  >= 4

[State 1200, at]
type = Explod
trigger1 = time = 5
trigger2 = time = 12
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
anim = F1
pos = 0,-105
postype = p1
;facing = 1
sprpriority  >= 3

[State 1200, at]
type = Explod
trigger1 = time = 8
trigger2 = time = 14
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
anim = F1
pos = 0,-105
postype = p1
facing = -1
sprpriority  >= 3

[State 22, round hit]
type = EnvShake
trigger1 = time = 45
trigger2 = time = 55
freq = 48
time = 10
ampl = 4

[State 1200, ound]
type = PlaySnd
trigger1 = time = 44
trigger2 = time = 55
value = F5, 17
channel = 4

[State 1200, 45ound]
type = PlaySnd
trigger1 = time = 8
trigger2 = time = 14
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
value = F5, 19

[State 9010, 0.1]
type = Sprpriority
trigger1 = time = 50
value  >= 4

[State 9399, 2]
type = Selfstate
trigger1 = Animtime = 0
value = 5150

[State 9399, 3]
type = Lifeadd
trigger1 = Time = 30
Value = -9999

[State 5150, 8]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1
ctrl = 1

; --- Para fatales de decapitación tipo martillazo de Shao Kahn ---

[Statedef 6004];6612
type    = S
movetype= H
physics = S
ctrl = 0
velset = 0,0,0
anim = 661

[State 9399, 2]
type = varset
trigger1 = time = 0
v = 45
value = 6611

[State 1200, 2at]
type = Explod
trigger1 = time = 0
anim = F16
pos = 10,-117
postype = p1
sprpriority  >= 4

[State 1200, at]
type = Explod
trigger1 = time = 5
trigger2 = time = 12
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
anim = F1
pos = 0,-105
postype = p1
sprpriority  >= 3

[State 1200, at]
type = Explod
trigger1 = time = 8
trigger2 = time = 14
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
anim = F1
pos = 0,-105
postype = p1
facing = -1
sprpriority  >= 3

[State 1200, 45ound]
type = PlaySnd
trigger1 = time = 8
trigger2 = time = 14
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
value = F5, 19

[State 9010, 0.1]
type = Sprpriority
trigger1 = time = 50
value  >= 4

[State 9399, 2]
type = Selfstate
trigger1 = Animtime = 0
value = 5150

[State 9399, 3]
type = Lifeadd
trigger1 = Time = 30
Value = -9999

[State 5150, 8]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1
ctrl = 1

;--- Cabeza ?
[Statedef 6005];6613
type    = S
movetype= H
physics = S
ctrl = 0
velset = 0,0,0
anim = 661

[State 9399, 2]
type = varset
trigger1 = time = 0
v = 45
value = 6611

[State 1200, 2at]
type = Explod
trigger1 = time = 0
anim = F16
pos = 10,-118
postype = p1
sprpriority  >= 4

[State 1200, at]
type = Explod
trigger1 = time = 5
trigger2 = time = 12
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
anim = F1
pos = 0,-105
postype = p1
;facing = 1
sprpriority  >= 3

[State 1200, at]
type = Explod
trigger1 = time = 8
trigger2 = time = 14
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
anim = F1
pos = 0,-105
postype = p1
facing = -1
sprpriority  >= 3

[State 22, round hit]
type = EnvShake
trigger1 = time = 45
trigger2 = time = 55
freq = 48
time = 10
ampl = 4

[State 1200, ound]
type = PlaySnd
trigger1 = time = 44
trigger2 = time = 55
value = F5, 17
channel = 4

[State 1200, 45ound]
type = PlaySnd
trigger1 = time = 8
trigger2 = time = 14
trigger3 = time = 22
trigger4 = time = 28
trigger5 = time = 34
trigger6 = time = 40
trigger7 = time = 45
trigger8 = time = 50
trigger9 = time = 55
value = F5, 19

[State 9010, 0.1]
type = Sprpriority
trigger1 = time = 50
value  >= 4

[State 9399, 2]
type = Selfstate
trigger1 = Animtime = 0
value = 5150

[State 9399, 3]
type = Lifeadd
trigger1 = Time = 30
Value = -9999

[State 5150, 8]
type = NotHitBy
trigger1 = 1
value = SCA
time = 1
ctrl = 1

[State 1200, er2at]
type = Explod
trigger1 = time = 1
anim = 6612
ID = 6612
pos = 0,-115
postype = p1
sprpriority  = 4
removetime = 5

[State 1200, er2at]
type = Explod
trigger1 = time = 3
anim = 6612
ID = 6612
pos = 0,-117
postype = p1
sprpriority  = 5
scale = 1.5,1.5
removetime = 2

[State 1200, er2at]
type = Explod
trigger1 = time = 5
anim = 6612
ID = 6612
pos = 2,-119
postype = p1
sprpriority  = 5
scale = 2,2
removetime = 2

[State 1200, er2at]
type = Explod
trigger1 = time = 7
anim = 6612
ID = 6612
pos = 4,-121
postype = p1
sprpriority = 5
scale = 2.5,2.5
removetime = 2

[State 1200, er2at]
type = Explod
trigger1 = time = 9
anim = 6612
ID = 6612
pos = 6,-123
postype = p1
sprpriority  = 5
scale = 3,3
removetime = 3

[State 1200, er2at]
type = Explod
trigger1 = time = 12
anim = 6612
ID = 6612
pos = 8,-125
postype = p1
sprpriority  = 5
scale = 3.5,3.5
removetime = 6

[State 1200, er2at]
type = Explod
trigger1 = time = 15
anim = 6612
ID = 6612
pos = 10,-128
postype = p1
sprpriority  = 5
scale = 4,4
removetime = 3

[State 1200, er2at]
type = Explod
trigger1 = time = 18
anim = 6612
ID = 6612
pos = 12,-130
postype = p1
sprpriority  = 5
scale = 4.8,4.8
removetime = 50

[State 1200, er2at]
type = Explod
trigger1 = time = 68
anim = 6612
ID = 6612
Vel = 0,7
pos = 12,-130
postype = p1
sprpriority  = 5
scale = 4.8,4.8
removetime = 60

[State 1200, er2at]
type = Explod
trigger1 = time = 16
anim = F17
pos = 12,-150
postype = p1
sprpriority  = 5
;removetime = -1

[State 1200, er2at]
type = Explod
trigger1 = time = 16
anim = F17
pos = 12,-110
postype = p1
sprpriority  = 5
;removetime = -1

[State 1200, er2at]
type = Explod
trigger1 = time = 18
anim = F10
pos = 12,-150
postype = p1
ontop = 1
removetime = -1


[State 22, roundt]
type = EnvShake
trigger1 = time = 18
freq = 88
time = 10
ampl = 7

[State 22, rndt]
type = Playsnd
trigger1 = time = 18
value = F5,21
;volume = 100

[State 22, 245t]
type = Playsnd
trigger1 = time = 18
value = F5,31
volume = 100

;--- Para quedar decapitado en el suelo ---

[Statedef 6006];6614
type    = S
movetype= H
physics = S
ctrl = 0

[State 9399, 2]
type = varset
trigger1 = time = 0
v = 45
value = 6611

[State 9399, 2]
type = Selfstate
trigger1 = time = 0
value = 5150

; Invisible al final :P
[Statedef 6007]
type    = S
movetype= H
physics = S
ctrl = 0
velset = 0,0,0

[State 9399, 2]
type = varset
trigger1 = time = 0
v = 45
value = 888

[State 9399, 2]
type = Selfstate
trigger1 = time = 0
value = 5150