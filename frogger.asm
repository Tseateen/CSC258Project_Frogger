#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Yide Ma, 1005915734
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1, 2, 3, 4, 5
#
# Which approved additional features have been implemented?
# 5 Easy Features, and 2 Hard Features
# Easy Features:
#	1. Display the number of lives remaining in left bottom
#	2. Retry option
#	3. Difficulty increase as game progresses( get into the second level, the speed will increase)
#	4. Diff line objects have diff speed
#	5.Display a death/respawn animation each time the player loses a frog
#
# Hard Features:
# 	1.Make a second level that starts after the player completes the first level.
#		-First level: lower speed of wood and car; 1 goal
#		-Second level: higher speed; 3 goal
#
#	2.Add sound effects for movement, collisions, game end and reaching the goal area. 
#
# Any additional information that the TA needs to know:
# w, a, s, d to move
# After the second level passed, code will sleep for 2 sec and restart 1 level

.data
displayAddress: .word 0x10008000
car: .word 0xff0000
wood: .word 0xcc6600
startArea: .word 0xb3ffcc
river: .word 0x0099ff
road: .word 0x666699
frogger: .word 0x009933
blackscreen: .word 0x000000
rebrith: .word 0xffff00
blood: .word 0xcc0000

lives: .word 3

midpoint: .word 0x10008038
leftpoint: .word 0x10008018
rightpoint: .word 0x10008058

.text
main:
	lw $t1, startArea
	lw $t4, frogger
	lw $t5, car
	lw $t6, wood
	
FoggLocation:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	
Hearts:
	lw $t2, lives
	
WoodLocation:
	li $s6, 0
	li $s7, 0
Start:
	lw $t0, displayAddress
	addi $t7, $t0, 512
	
DrawGoal:
	lw $t1, startArea
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, DrawGoal
	addi $t7, $t7, 1024
	
DrawRiver:
	lw $t1, river
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, DrawRiver
	addi $t7, $t7, 512
	
DrawSafe:
	lw $t1, startArea
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, DrawSafe
	addi $t7, $t7, 1024

DrawRoad:
	lw $t1, road
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, DrawRoad
	addi $t7, $t7, 1024
	
DrawStart:
	lw $t1, startArea
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, DrawStart

ResetWood:
	li $t7, 0
	addi $s6, $s6, 4
	beq $s6, 64, CycleBackWood1
	lw $s2, displayAddress
	addi $s2, $s2, 512
	jal UpRowCheck
	addi $s1, $s2, 64
	add $s2, $s2, $s6
	addi $s4, $s2, 32
	bge $s4, $s1, CycleBackWood2
	j DrawWood

UpRowCheck:
	bge $s0, $s2, UpRowCheck1
	jr $ra

UpRowCheck1:
	addi $t8, $s2, 124
	ble $s0, $t8, UpRowCheck2
	jr $ra

UpRowCheck2:
	li $t7, 1
	jr $ra

CycleBackWood1:
	subi $s6, $s6, 64
	lw $s2, displayAddress
	addi $s2, $s2, 512
	addi $s1, $s2, 64
	add $s2, $s2, $s6
	addi $s4, $s2, 32
	bge $s4, $s1, CycleBackWood2
	j DrawWood
	
CycleBackWood2:
	subi $s4, $s4, 64
	
DrawWood:
	sw $t6, 0($s2)
	sw $t6, 64($s2)
	sw $t6, 128($s2)
	sw $t6, 192($s2)
	sw $t6, 256($s2)
	sw $t6, 320($s2)
	sw $t6, 384($s2)
	sw $t6, 448($s2)
	jal WoodCollFogg
	addi $s2, $s2, 4
	beq $s2, $s1, CycleBackWood
	beq $s2, $s4, ResetWood2
	j DrawWood

WoodCollFogg:
	beq $t7, 1, WoodCollFogg1
	jr $ra

WoodCollFogg1:
	beq $s2, $s0, WoodCollFogg2
	addi $s3, $s0, 12
	beq $s2, $s3, WoodCollFogg2
	addi $s5, $s2, 56
	beq $s5,$s0, WoodCollFogg2
	addi $s5, $s2, 64
	beq $s5,$s3, WoodCollFogg2
	jr $ra

WoodCollFogg2:
	li $t7, 2
	jr $ra

CycleBackWood:
	subi $s2, $s2, 64
	beq $s2, $s4, ResetWood2
	j DrawWood
	
ResetWood2:
	li $t8, 0
	addi $s7, $s7, 8
	beq $s7, 64, CycleBackWood3
	lw $s2, displayAddress
	addi $s2, $s2, 1024
	jal DownRowCheck
	addi $s1, $s2, 64
	add $s2, $s2, $s7
	addi $s4, $s2, 32
	bge $s4, $s1, CycleBackWood4
	j DrawWood2
	
DownRowCheck:
	bge $s0, $s2, DownRowCheck1
	jr $ra

DownRowCheck1:
	addi $s3, $s2, 124
	ble $s0, $s3, DownRowCheck2
	jr $ra

DownRowCheck2:
	li $t8, 1
	jr $ra
	
CycleBackWood3:
	subi $s7, $s7, 64
	lw $s2, displayAddress
	addi $s2, $s2, 1024
	addi $s1, $s2, 64
	add $s2, $s2, $s7
	addi $s4, $s2, 32
	bge $s4, $s1, CycleBackWood4
	j DrawWood2
	
CycleBackWood4:
	subi $s4, $s4, 64
	
DrawWood2:
	sw $t6, 0($s2)
	sw $t6, 64($s2)
	sw $t6, 128($s2)
	sw $t6, 192($s2)
	sw $t6, 256($s2)
	sw $t6, 320($s2)
	sw $t6, 384($s2)
	sw $t6, 448($s2)
	jal WoodCollFogg3
	addi $s2, $s2, 4
	beq $s2, $s1, CycleBackWood5
	beq $s2, $s4, FinalCheckWood
	j DrawWood2
	
WoodCollFogg3:
	beq $t8, 1, WoodCollFogg4
	jr $ra

WoodCollFogg4:
	beq $s2, $s0, WoodCollFogg5
	addi $s3, $s0, 16
	beq $s2, $s3, WoodCollFogg5
	addi $s5, $s2, 56
	beq $s5, $s0, WoodCollFogg5
	addi $s5, $s2, 64
	beq $s5, $s3, WoodCollFogg5
	jr $ra

WoodCollFogg5:
	li $t8, 2
	jr $ra
	
CycleBackWood5:
	subi $s2, $s2, 64
	beq $s2, $s4, FinalCheckWood
	j DrawWood2
	
FinalCheckWood:
	beq $t7, 1, WoodResetFogg
	beq $t8, 1, WoodResetFogg
	beq $t7, 2, WoodWithFoggUp
	beq $t8, 2, WoodWithFoggDown
	j ResetCar1
	
WoodResetFogg:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1 
	li $v0, 31
	li $a0, 30
	li $a1, 1000
	li $a2, 113
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck
	j ResetCar1

WoodWithFoggUp:
	addi $s0, $s0, 4
	j ResetCar1
	
WoodWithFoggDown:
	addi $s0, $s0, 8
	j ResetCar1
	
ResetCar1:	
	lw $s2, displayAddress
	addi $s2, $s2, 2048
	addi $s1, $s2, 64
	add $s2, $s2, $s6
	addi $s4, $s2, 16
	bge $s4, $s1, CycleBackCar1
	j DrawCar1
	
	
CycleBackCar1:
	subi $s4, $s4, 64
	
DrawCar1:
	sw $t5, 0($s2)
	sw $t5, 64($s2)
	sw $t5, 128($s2)
	sw $t5, 192($s2)
	sw $t5, 256($s2)
	sw $t5, 320($s2)
	sw $t5, 384($s2)
	sw $t5, 448($s2)
	jal CarCollFogg
	addi $s2, $s2, 4
	beq $s2, $s1, CycleBackCar
	beq $s2, $s4, ResetCar2
	j DrawCar1

CarCollFogg:
	beq $s2, $s0, CarResetFogg
	addi $t7, $s0, 16
	beq $s2, $t7, CarResetFogg
	addi $s5, $s2, 64
	beq $s5,$s0, CarResetFogg
	beq $s5,$t7, CarResetFogg
	jr $ra

CarResetFogg:
	addi $t0, $ra, 0
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1
	li $v0, 31
	li $a0, 65
	li $a1, 1000
	li $a2, 127
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck
	jr $t0

CycleBackCar:
	subi $s2, $s2, 64
	beq $s2, $s4, ResetCar2
	j DrawCar1
	
ResetCar2:	
	lw $s2, displayAddress
	addi $s2, $s2, 2560
	addi $s1, $s2, 64
	add $s2, $s2, $s7
	addi $s4, $s2, 16
	bge $s4, $s1, CycleBackCar3
	j DrawCar2
	
CycleBackCar3:
	subi $s4, $s4, 64
	
DrawCar2:
	sw $t5, 0($s2)
	sw $t5, 64($s2)
	sw $t5, 128($s2)
	sw $t5, 192($s2)
	sw $t5, 256($s2)
	sw $t5, 320($s2)
	sw $t5, 384($s2)
	sw $t5, 448($s2)
	jal CarCollFogg
	addi $s2, $s2, 4
	beq $s2, $s1, CycleBackCar2
	beq $s2, $s4, KeyStart
	j DrawCar2
	
CycleBackCar2:
	subi $s2, $s2, 64
	beq $s2, $s4, KeyStart
	j DrawCar2
	

KeyStart:
	lw $k0, 0xffff0000
	beq $k0, 1, KeyBoard
	j DrawFogg

KeyBoard:
	lw $k1, 0xffff0004
	beq $k1, 0x61, RespondA
	beq $k1, 0x64, RespondD
	beq $k1, 0x73, RespondS
	beq $k1, 0x77, RespondW
	j JudgeFoggLoc

RespondA:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	subi $s0, $s0, 16
	j JudgeFoggLoc

RespondD:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	addi $s0, $s0, 16
	j JudgeFoggLoc

RespondS:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	addi $s0, $s0, 512
	j JudgeFoggLoc

RespondW:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	subi $s0, $s0, 512
	j JudgeFoggLoc
	
JudgeFoggLoc:
	lw $s1, displayAddress
	addi $s2, $s1, 116
	addi $s3, $s1, 3968
	j JudgeFoggLoc1

JudgeFoggLoc1:
	beq $s1, $s0, DrawFogg
	addi $s1, $s1, 4
	beq $s1, $s2, JudgeFoggLoc2
	j JudgeFoggLoc1
	
JudgeFoggLoc2:
	subi $s1, $s1, 116
	addi $s1, $s1, 512
	addi $s2, $s1, 116
	bge $s1, $s3, ResetFogg
	j JudgeFoggLoc1
	
ResetFogg:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1
	li $v0, 31
	li $a0, 80
	li $a1, 100
	li $a2, 95
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck
	
DrawFogg:
	sw $t4, 0($s0)
	sw $t4, 12($s0)
	sw $t4, 128($s0)
	sw $t4, 132($s0)
	sw $t4, 136($s0)
	sw $t4, 140($s0)
	sw $t4, 260($s0)
	sw $t4, 264($s0)
	sw $t4, 384($s0)
	sw $t4, 396($s0)
	jal DrawHreat

DrawMidPoint:
	lw $s1, midpoint
	jal DrawPoint
	lw $s1, midpoint
	jal FinalPointFoggCheck
	j NonExit
	
	
DrawPoint:
	lw $t1, river
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	addi $s1, $s1, 4
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	addi $s1, $s1, 4
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	addi $s1, $s1, 4
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	jr $ra
	
FinalPointFoggCheck:
	li $t7, 0
	lw $s2, displayAddress
	bge $s0, $s2, FinalPointFoggCheck1
	j NonExit

FinalPointFoggCheck1:
	li $t7, 0
	addi $s2, $s2, 112
	ble $s0, $s2, FinalPointFoggCheck2
	j NonExit
	
FinalPointFoggCheck2:
	addi $s3, $s0, 12
	blt $s3, $s1, FinalPointFoggCheck3
	addi $s3, $s1, 12
	blt $s3, $s0, FinalPointFoggCheck3
	li $t7, 2
	j FinalJudgeFogg
	
FinalPointFoggCheck3:
	li $t7, 1
	j FinalJudgeFogg
	
FinalJudgeFogg:
	beq $t7, 1, FinalResetFogg
	beq $t7, 2, GateSign
	
FinalResetFogg:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1
	li $v0, 31
	li $a0, 80
	li $a1, 100
	li $a2, 95
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck

NonExit:
	li $v0, 32
	li $a0, 200
	syscall
	j Start
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall

GateSign:
	li $v0, 31
	li $a0, 90
	li $a1, 1000
	li $a2, 7
	li $a3, 127
	syscall
	li $t9, 0
	
SecFoggLocation:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	
SecWoodLocation:
	li $s6, 0
	li $s7, 0
SecStart:
	lw $t0, displayAddress
	addi $t7, $t0, 512
	
SecDrawGoal:
	lw $t1, startArea
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, SecDrawGoal
	addi $t7, $t7, 1024
	
SecDrawRiver:
	lw $t1, river
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, SecDrawRiver
	addi $t7, $t7, 512
	
SecDrawSafe:
	lw $t1, startArea
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, SecDrawSafe
	addi $t7, $t7, 1024

SecDrawRoad:
	lw $t1, road
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, SecDrawRoad
	addi $t7, $t7, 1024
	
SecDrawStart:
	lw $t1, startArea
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	bne $t0, $t7, SecDrawStart

SecResetWood:
	li $t7, 0
	addi $s6, $s6, 4
	beq $s6, 64, SecCycleBackWood1
	lw $s2, displayAddress
	addi $s2, $s2, 512
	jal SecUpRowCheck
	addi $s1, $s2, 64
	add $s2, $s2, $s6
	addi $s4, $s2, 32
	bge $s4, $s1, SecCycleBackWood2
	j SecDrawWood

SecUpRowCheck:
	bge $s0, $s2, SecUpRowCheck1
	jr $ra

SecUpRowCheck1:
	addi $t8, $s2, 124
	ble $s0, $t8, SecUpRowCheck2
	jr $ra

SecUpRowCheck2:
	li $t7, 1
	jr $ra

SecCycleBackWood1:
	subi $s6, $s6, 64
	lw $s2, displayAddress
	addi $s2, $s2, 512
	addi $s1, $s2, 64
	add $s2, $s2, $s6
	addi $s4, $s2, 32
	bge $s4, $s1, SecCycleBackWood2
	j SecDrawWood
	
SecCycleBackWood2:
	subi $s4, $s4, 64
	
SecDrawWood:
	sw $t6, 0($s2)
	sw $t6, 64($s2)
	sw $t6, 128($s2)
	sw $t6, 192($s2)
	sw $t6, 256($s2)
	sw $t6, 320($s2)
	sw $t6, 384($s2)
	sw $t6, 448($s2)
	jal SecWoodCollFogg
	addi $s2, $s2, 4
	beq $s2, $s1, SecCycleBackWood
	beq $s2, $s4, SecResetWood2
	j SecDrawWood

SecWoodCollFogg:
	beq $t7, 1, SecWoodCollFogg1
	jr $ra

SecWoodCollFogg1:
	beq $s2, $s0, SecWoodCollFogg2
	addi $t8, $s0, 16
	beq $s2, $t8, SecWoodCollFogg2
	addi $s5, $s2, 64
	beq $s5,$s0, SecWoodCollFogg2
	beq $s5,$t8, SecWoodCollFogg2
	jr $ra

SecWoodCollFogg2:
	li $t7, 2
	jr $ra

SecCycleBackWood:
	subi $s2, $s2, 64
	beq $s2, $s4, SecResetWood2
	j SecDrawWood
	
SecResetWood2:
	li $t8, 0
	addi $s7, $s7, 8
	beq $s7, 64, SecCycleBackWood3
	lw $s2, displayAddress
	addi $s2, $s2, 1024
	jal SecDownRowCheck
	addi $s1, $s2, 64
	add $s2, $s2, $s7
	addi $s4, $s2, 32
	bge $s4, $s1, SecCycleBackWood4
	j SecDrawWood2
	
SecDownRowCheck:
	bge $s0, $s2, SecDownRowCheck1
	jr $ra

SecDownRowCheck1:
	addi $s3, $s2, 124
	ble $s0, $s3, SecDownRowCheck2
	jr $ra

SecDownRowCheck2:
	li $t8, 1
	jr $ra
	
SecCycleBackWood3:
	subi $s7, $s7, 64
	lw $s2, displayAddress
	addi $s2, $s2, 1024
	addi $s1, $s2, 64
	add $s2, $s2, $s7
	addi $s4, $s2, 32
	bge $s4, $s1, SecCycleBackWood4
	j SecDrawWood2
	
SecCycleBackWood4:
	subi $s4, $s4, 64
	
SecDrawWood2:
	sw $t6, 0($s2)
	sw $t6, 64($s2)
	sw $t6, 128($s2)
	sw $t6, 192($s2)
	sw $t6, 256($s2)
	sw $t6, 320($s2)
	sw $t6, 384($s2)
	sw $t6, 448($s2)
	jal SecWoodCollFogg3
	addi $s2, $s2, 4
	beq $s2, $s1, SecCycleBackWood5
	beq $s2, $s4, SecFinalCheckWood
	j SecDrawWood2
	
SecWoodCollFogg3:
	beq $t8, 1, SecWoodCollFogg4
	jr $ra

SecWoodCollFogg4:
	beq $s2, $s0, SecWoodCollFogg5
	addi $s3, $s0, 16
	beq $s2, $s3, SecWoodCollFogg5
	addi $s5, $s2, 64
	beq $s5, $s0, SecWoodCollFogg5
	beq $s5, $s3, SecWoodCollFogg5
	jr $ra

SecWoodCollFogg5:
	li $t8, 2
	jr $ra
	
SecCycleBackWood5:
	subi $s2, $s2, 64
	beq $s2, $s4, SecFinalCheckWood
	j SecDrawWood2
	
SecFinalCheckWood:
	beq $t7, 1, SecWoodResetFogg
	beq $t8, 1, SecWoodResetFogg
	beq $t7, 2, SecWoodWithFoggUp
	beq $t8, 2, SecWoodWithFoggDown
	j SecResetCar1
	
SecWoodResetFogg:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1
	li $v0, 31
	li $a0, 30
	li $a1, 1000
	li $a2, 113
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck
	j SecResetCar1

SecWoodWithFoggUp:
	addi $s0, $s0, 4
	j SecResetCar1
	
SecWoodWithFoggDown:
	addi $s0, $s0, 8
	j SecResetCar1
	
SecResetCar1:	
	lw $s2, displayAddress
	addi $s2, $s2, 2048
	addi $s1, $s2, 64
	add $s2, $s2, $s6
	addi $s4, $s2, 16
	bge $s4, $s1, SecCycleBackCar1
	j SecDrawCar1
	
SecCycleBackCar1:
	subi $s4, $s4, 64
	
SecDrawCar1:
	sw $t5, 0($s2)
	sw $t5, 64($s2)
	sw $t5, 128($s2)
	sw $t5, 192($s2)
	sw $t5, 256($s2)
	sw $t5, 320($s2)
	sw $t5, 384($s2)
	sw $t5, 448($s2)
	jal SecCarCollFogg
	addi $s2, $s2, 4
	beq $s2, $s1, SecCycleBackCar
	beq $s2, $s4, SecResetCar2
	j SecDrawCar1

SecCarCollFogg:
	beq $s2, $s0, SecCarResetFogg
	addi $t7, $s0, 16
	beq $s2, $t7, SecCarResetFogg
	addi $s5, $s2, 64
	beq $s5,$s0, SecCarResetFogg
	beq $s5,$t7, SecCarResetFogg
	jr $ra

SecCarResetFogg:
	addi $t0, $ra, 0
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1
	li $v0, 31
	li $a0, 65
	li $a1, 1000
	li $a2, 127
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck
	jr $t0

SecCycleBackCar:
	subi $s2, $s2, 64
	beq $s2, $s4, SecResetCar2
	j SecDrawCar1
	
SecResetCar2:	
	lw $s2, displayAddress
	addi $s2, $s2, 2560
	addi $s1, $s2, 64
	add $s2, $s2, $s7
	addi $s4, $s2, 16
	bge $s4, $s1, SecCycleBackCar3
	j SecDrawCar2
	
SecCycleBackCar3:
	subi $s4, $s4, 64
	
SecDrawCar2:
	sw $t5, 0($s2)
	sw $t5, 64($s2)
	sw $t5, 128($s2)
	sw $t5, 192($s2)
	sw $t5, 256($s2)
	sw $t5, 320($s2)
	sw $t5, 384($s2)
	sw $t5, 448($s2)
	jal SecCarCollFogg
	addi $s2, $s2, 4
	beq $s2, $s1, SecCycleBackCar2
	beq $s2, $s4, SecKeyStart
	j SecDrawCar2
	
SecCycleBackCar2:
	subi $s2, $s2, 64
	beq $s2, $s4, SecKeyStart
	j SecDrawCar2
	

SecKeyStart:
	lw $k0, 0xffff0000
	beq $k0, 1, SecKeyBoard
	j SecDrawFogg

SecKeyBoard:
	lw $k1, 0xffff0004
	beq $k1, 0x61, SecRespondA
	beq $k1, 0x64, SecRespondD
	beq $k1, 0x73, SecRespondS
	beq $k1, 0x77, SecRespondW
	j SecJudgeFoggLoc

SecRespondA:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	subi $s0, $s0, 16
	j SecJudgeFoggLoc

SecRespondD:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	addi $s0, $s0, 16
	j SecJudgeFoggLoc

SecRespondS:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	addi $s0, $s0, 512
	j SecJudgeFoggLoc

SecRespondW:
	li $v0, 31
	li $a0, 62
	li $a1, 200
	li $a2, 14
	li $a3, 127
	syscall
	subi $s0, $s0, 512
	j SecJudgeFoggLoc
	
SecJudgeFoggLoc:
	lw $s1, displayAddress
	addi $s2, $s1, 116
	addi $s3, $s1, 3968
	j SecJudgeFoggLoc1

SecJudgeFoggLoc1:
	beq $s1, $s0, SecDrawFogg
	addi $s1, $s1, 4
	beq $s1, $s2, SecJudgeFoggLoc2
	j SecJudgeFoggLoc1
	
SecJudgeFoggLoc2:
	subi $s1, $s1, 116
	addi $s1, $s1, 512
	addi $s2, $s1, 116
	bge $s1, $s3, SecResetFogg
	j SecJudgeFoggLoc1
	
SecResetFogg:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1
	li $v0, 31
	li $a0, 80
	li $a1, 100
	li $a2, 95
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck
	
SecDrawFogg:
	sw $t4, 0($s0)
	sw $t4, 12($s0)
	sw $t4, 128($s0)
	sw $t4, 132($s0)
	sw $t4, 136($s0)
	sw $t4, 140($s0)
	sw $t4, 260($s0)
	sw $t4, 264($s0)
	sw $t4, 384($s0)
	sw $t4, 396($s0)
	jal DrawHreat

SecCheckGate:
	li $t7, 0
	jal GateToCheckFogg
	addi $t8, $t9, 0
	bge $t8, 5, CloseMid
	j SecDrawMidPoint

GateToCheckFogg:
	lw $s2, displayAddress
	bge $s0, $s2, GateToCheckFogg1
	jr $ra

GateToCheckFogg1:
	addi $s2, $s2,120
	bge $s2, $s0, SecPointFoggCheck
	jr $ra

SecPointFoggCheck:
	li $v0, 1
	li $a0, 100
	syscall
	li $t7, 1
	jr $ra
	
CloseMid:
	subi $t8, $t8, 5
	j SecCheckGate1
	
SecCheckGate1:
	bge $t8, 3, CloseLeft
	j SecDrawLeftPoint
	
CloseLeft:
	subi $t8, $t8, 3
	j SecCheckGate2

SecCheckGate2:
	bge $t8, 1, CloseRight
	j SecDrawRightPoint

CloseRight:
	j SecFinalJudgeFogg

SecDrawMidPoint:
	lw $s1, midpoint
	jal SecDrawPoint
	lw $s1, midpoint
	jal SecFinalPointFoggCheck
	j SecCheckGate1
	
SecDrawLeftPoint:
	lw $s1, leftpoint
	jal SecDrawPoint
	lw $s1, leftpoint
	jal SecFinalPointFoggCheck
	j SecCheckGate2
	
SecDrawRightPoint:
	lw $s1, rightpoint
	jal SecDrawPoint
	lw $s1, rightpoint
	jal SecFinalPointFoggCheck
	j SecFinalJudgeFogg
	
	
SecDrawPoint:
	lw $t1, river
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	addi $s1, $s1, 4
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	addi $s1, $s1, 4
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	addi $s1, $s1, 4
	sw $t1, 0($s1)
	sw $t1, 128($s1)
	sw $t1, 256($s1)
	sw $t1, 384($s1)
	jr $ra
	
SecFinalPointFoggCheck:
	beq $t7, 1, SecFinalPointFoggCheck1
	jr $ra
	
SecFinalPointFoggCheck1:
	
	addi $s3, $s0, 12
	blt $s3, $s1, SecFinalPointFoggCheck2
	addi $s3, $s1, 0
	addi $s3, $s3, 12
	blt $s3, $s0, SecFinalPointFoggCheck2
	li $t7, 2
	lw $s3, midpoint
	beq $s3, $s1, MidNum
	lw $s3, leftpoint
	beq $s3, $s1, LeftNum
	lw $s3, rightpoint
	beq $s3, $s1, RightNum
	jr $ra
	
MidNum:
	addi $t9, $t9, 5
	jr $ra

LeftNum:
	addi $t9, $t9, 3
	jr $ra
	
RightNum:
	addi $t9, $t9, 1
	jr $ra	

SecFinalPointFoggCheck2:
	jr $ra
	
SecFinalJudgeFogg:
	beq $t7, 1, SecFinalResetFogg
	beq $t9, 9, End
	beq $t7, 2, SecFinalResetFoggNoReduce
	j SecNonExit
	
SecFinalResetFoggNoReduce:
	li $v0, 31
	li $a0, 90
	li $a1, 100
	li $a2, 7
	li $a3, 127
	syscall
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	j SecNonExit
	
SecFinalResetFogg:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	subi $t2, $t2, 1
	li $v0, 31
	li $a0, 80
	li $a1, 100
	li $a2, 95
	li $a3, 127
	syscall
	jal Rebrith
	jal RemainHeartCheck

SecNonExit:
	li $v0, 32
	li $a0, 100
	syscall
	j SecStart
	
End:	
	li $v0, 31
	li $a0, 90
	li $a1, 2000
	li $a2, 7
	li $a3, 127
	syscall
	li $v0, 32
	li $a0, 2000
	syscall
	j main

RemainHeartCheck:
	beq $t2, 0, Dead
	jr $ra

Dead:
	lw $t0, displayAddress
	addi $t7, $t0, 4096
	jal BlackScreen
	li $v0, 31
	li $a0, 10
	li $a1, 400
	li $a2, 122
	li $a3, 127
	syscall
	jal RetryWord
	jal RetryKeyStart
	li $v0, 32
	li $a0, 200
	syscall
	j Dead
	
BlackScreen:
	lw $t1, blackscreen
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	beq $t0, $t7, DrawScreenEnd
	j BlackScreen
	
DrawScreenEnd:
	jr $ra

RetryWord:
	lw $t0, displayAddress
	addi $t0, $t0, 1304
	lw $t1, blood
	j DrawR

DrawR:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 512($t0)
	sw $t1, 520($t0)
	addi $t0, $t0, 16
	j DrawE

DrawE:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	addi $t0, $t0, 16
	j DrawT

DrawT:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 132($t0)
	sw $t1, 260($t0)
	sw $t1, 388($t0)
	sw $t1, 516($t0)
	addi $t0, $t0, 16
	j DrawR1
	
DrawR1:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 512($t0)
	sw $t1, 520($t0)
	addi $t0, $t0, 16
	j DrawY
	
DrawY:
	sw $t1, 0($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 260($t0)
	sw $t1, 388($t0)
	sw $t1, 516($t0)
	lw $t0, displayAddress
	addi $t0, $t0, 2232
	j DrawR2
	
DrawR2:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 512($t0)
	sw $t1, 520($t0)
	jr $ra

RetryKeyStart:
	lw $k0, 0xffff0000
	beq $k0, 1, RetryKeyBoard
	jr $ra

RetryKeyBoard:
	lw $k1, 0xffff0004
	beq $k1, 0x72, RespondR
	jr $ra

RespondR:
	lw $s0, displayAddress
	addi $s0, $s0, 3632
	jal Rebrith
	j main

Rebrith:
	li $t3, 0
	j Rebrith1

Rebrith1:
	bge $t3, 3, BrithEnd
	addi $t3, $t3, 1
	lw $t4, rebrith
	sw $t4, 0($s0)
	sw $t4, 12($s0)
	sw $t4, 128($s0)
	sw $t4, 132($s0)
	sw $t4, 136($s0)
	sw $t4, 140($s0)
	sw $t4, 260($s0)
	sw $t4, 264($s0)
	sw $t4, 384($s0)
	sw $t4, 396($s0)
	li $v0, 31
	li $a0, 65
	li $a1, 150
	li $a2, 104
	li $a3, 127
	syscall 
	li $v0, 32
	li $a0, 100
	syscall
	lw $t4, frogger
	sw $t4, 0($s0)
	sw $t4, 12($s0)
	sw $t4, 128($s0)
	sw $t4, 132($s0)
	sw $t4, 136($s0)
	sw $t4, 140($s0)
	sw $t4, 260($s0)
	sw $t4, 264($s0)
	sw $t4, 384($s0)
	sw $t4, 396($s0)
	li $v0, 31
	li $a0, 55
	li $a1, 150
	li $a2, 104
	li $a3, 127
	syscall 
	li $v0, 32
	li $a0, 100
	syscall
	j Rebrith1
	
BrithEnd:
	jr $ra
	

DrawHreat:
	li $t7, 0
	lw $t0, displayAddress
	addi $t0, $t0, 3712
	lw $t1, blood
	j DrawHreat1

DrawHreat1:
	bge $t7, $t2, DrawHreat2
	addi $t7, $t7, 1
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	addi $t0, $t0, 12
	j DrawHreat1
	
DrawHreat2:
	jr $ra

