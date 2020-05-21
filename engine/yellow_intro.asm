PlayIntroScene: ; (located @ 3E:582D)
	ld a, [rIE]
	push af
	xor a
	ld [rIF], a
	ld a, $f
	ld [rIE], a
	ld a, $8
	ld [rSTAT], a
	call InitYellowIntroGFXAndMusic
	call DelayFrame
.loop
	; If bit 7 of [wYellowIntroCurrentScene] is set, go to the title screen
	; It is set by the last intro scene
	ld a, [wYellowIntroCurrentScene]
	bit 7, a
	jr nz, .go_to_title_screen

	; If the A, B, or start button is pressed, go to the title screen
	call JoypadLowSensitivity
	ld a, [hJoyPressed]
	and A_BUTTON | B_BUTTON | START
	jr nz, .go_to_title_screen

	call ExecuteCurrentSceneSubroutine

	ld a, $0
	ld [wCurrentAnimatedObjectOAMBufferOffset], a

	call RunObjectAnimations

	ld a, [wYellowIntroCurrentScene]

	; If wYellowIntroCurrentScene equals 7 (surfing Pikachu scene)
	cp $7
	call z, UpdateSurfingPikachuPalette
	
	; If wYellowIntroCurrentScene equals 11 (wait after flying pika)
	cp $b
	call z, UpdateFlyingPikachuPalette

	call DelayFrame ; Wait for the next VBlank

	jr .loop ; Continue the loop

.go_to_title_screen
	call YellowIntro_BlankPalettes
	xor a
	ld [hLCDCPointer], a
	call DelayFrame
	xor a
	ld [rIF], a
	pop af
	ld [rIE], a
	ld a, $90
	ld [hWY], a
	call ClearObjectAnimationBuffers
	ld hl, wTileMap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	xor a
	call Bank3E_FillMemory
	call YellowIntro_BlankOAMBuffer
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call DelayFrame
	call DelayFrame
	call DelayFrame
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ret

; Sets the palette of sprites 9, 15, 17, 19, and 20 to 1
UpdateSurfingPikachuPalette:
	ld a, [wOAMBuffer + 8 * 4 + 3]
	or $1
	ld [wOAMBuffer + 8 * 4 + 3], a

	ld a, [wOAMBuffer + 14 * 4 + 3]
	or $1
	ld [wOAMBuffer + 14 * 4 + 3], a

	ld a, [wOAMBuffer + 16 * 4 + 3]
	or $1
	ld [wOAMBuffer + 16 * 4 + 3], a

	ld a, [wOAMBuffer + 18 * 4 + 3]
	or $1
	ld [wOAMBuffer + 18 * 4 + 3], a

	ld a, [wOAMBuffer + 19 * 4 + 3]
	or $1
	ld [wOAMBuffer + 19 * 4 + 3], a
	ret

; Sets the palette of sprites 19, 20, 21, 26, 27, and 29 to 1
UpdateFlyingPikachuPalette:
	ld a, [wOAMBuffer + 18 * 4 + 3]
	or $1
	ld [wOAMBuffer + 18 * 4 + 3], a

	ld a, [wOAMBuffer + 19 * 4 + 3]
	or $1
	ld [wOAMBuffer + 19 * 4 + 3], a

	ld a, [wOAMBuffer + 20 * 4 + 3]
	or $1
	ld [wOAMBuffer + 20 * 4 + 3], a

	ld a, [wOAMBuffer + 25 * 4 + 3]
	or $1
	ld [wOAMBuffer + 25 * 4 + 3], a

	ld a, [wOAMBuffer + 26 * 4 + 3]
	or $1
	ld [wOAMBuffer + 26 * 4 + 3], a

	ld a, [wOAMBuffer + 28 * 4 + 3]
	or $1
	ld [wOAMBuffer + 28 * 4 + 3], a
	ret

ExecuteCurrentSceneSubroutine:
	ld a, [wYellowIntroCurrentScene]
	ld hl, SceneSubroutineJumptable
	call LoadSceneSubroutineAddress
	jp hl

; Main intro scene jumptable
SceneSubroutineJumptable:
	dw YellowIntroScene12 ; pika close up
	dw YellowIntroScene13 ; wait last
	dw YellowIntroScene14 ; pika thunderbolt
	dw YellowIntroScene15 ; wait last
	dw YellowIntroScene16 ; fade to white
	dw YellowIntroScene17 ; wait and quit

YellowIntro_NextScene:
	ld hl, wYellowIntroCurrentScene
	inc [hl]
	ret

; Tile ID table for the big clefairy in scene 12
YellowIntroScene12TileTable:
	db $00, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $0a, $09, $08, $00
	db $00, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $1a, $19, $18, $00
	db $00, $29, $2a, $03, $2b, $2c, $2d, $2e, $2f, $03, $2a, $29, $00
	db $00, $00, $3b, $03, $3c, $3d, $3e, $3f, $03, $03, $3b, $00, $00
	db $4d, $4e, $4f, $03, $03, $03, $03, $03, $03, $03, $4f, $4e, $4d
	db $5b, $5c, $03, $03, $5d, $5e, $5f, $5e, $5d, $03, $03, $5c, $5b
	db $6b, $6c, $6d, $03, $03, $6e, $6f, $6e, $03, $03, $6d, $6c, $6b
	db $00, $7d, $7e, $7f, $03, $03, $03, $03, $03, $7f, $7e, $7d, $79

YellowIntroScene12:
	call YellowIntro_BlankPalsDelay2AndDisableLCD ; Changes palettes 'n' stuff

	ld c, $5
	call UpdateMusicCTimes

	xor a
	ld [hLCDCPointer], a

	; Clear memory
	ld hl, vBGMap0
	ld bc, $80
	ld a, $1
	call Bank3E_FillMemory

	ld hl, $9880
	ld bc, $140
	xor a
	call Bank3E_FillMemory

	ld hl, $99c0
	ld bc, $80
	ld a, $1
	call Bank3E_FillMemory

	ld hl, $98c3 	; Starting address
	ld de, YellowIntroScene12TileTable
	ld b, $8		; Height of the Clefairy
.row
	ld c, $d		; Width
	push hl
.col
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, .col

	pop hl
	push bc
	ld bc, $20
	add hl, bc
	pop bc
	dec b
	jr nz, .row

	; lb de, y-coord, x-coord
	lb de, $68, $54
	ld a, $9
	call YellowIntro_SpawnAnimatedObjectAndSavePointer
	xor a
	call Func_f9e9a
	ld c, $e
	callba LoadBGMapAttributes
	call YellowIntro_SetTimerFor128Frames
	call YellowIntro_NextScene
	ret

YellowIntroScene13:
	call YellowIntro_CheckFrameTimerDecrement
	ret nc
	lb de, $68, $58
	ld a, $a
	call SpawnAnimatedObject
	call YellowIntro_NextScene
	ret

YellowIntroScene14:
	ld de, YellowIntroPalSequence_f9dd6
	call YellowIntro_LoadDMGPalAndIncrementCounter
	jr c, .expired
	ld [rBGP], a
	ld [rOBP0], a
	and $f0
	ld [rOBP1], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	call UpdateGBCPal_OBP1
	ret

.expired
	call MaskAllAnimatedObjectStructs
	call YellowIntro_BlankOAMBuffer
	ld hl, wTileMap
	ld bc, $50
	ld a, $1
	call Bank3E_FillMemory
	coord hl, 0, 4
	ld bc, CopyVideoDataAlternate
	xor a
	call Bank3E_FillMemory
	coord hl, 0, 14
	ld bc, $50
	ld a, $1
	call Bank3E_FillMemory
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call DelayFrame
	call DelayFrame
	call DelayFrame
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld a, $e4
	ld [rOBP0], a
	ld [rBGP], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	lb de, $58, $58
	ld a, $7
	call YellowIntro_SpawnAnimatedObjectAndSavePointer
	call YellowIntro_NextScene
	ld a, $28
	ld [wYellowIntroSceneTimer], a
	ret

YellowIntroScene15:
	call YellowIntro_CheckFrameTimerDecrement
	jr c, .expired
	ld a, [wYellowIntroSceneTimer]
	and $3
	ret nz
	ld a, [rOBP0]
	xor $ff
	ld [rOBP0], a
	ld a, [rBGP]
	xor $3
	ld [rBGP], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	ret

.expired
	xor a
	ld [hLCDCPointer], a
	ld a, $e4
	ld [rBGP], a
	ld [rOBP0], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	call YellowIntro_NextScene
YellowIntroScene16:
	ld de, YellowIntroPalSequence_f9e0a
	call YellowIntro_LoadDMGPalAndIncrementCounter
	jr c, .expired
	ld [rOBP0], a
	ld [rBGP], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	ret

.expired
	call YellowIntro_NextScene
	ret

YellowIntroPalSequence_f9dd6:
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $e4
	db $e4, $c0, $c0, $ff

YellowIntroPalSequence_f9e0a:
	db $e4, $90, $90, $40
	db $40, $00, $00, $ff

YellowIntroScene17:
	ld c, 64
	call DelayFrames
	ld hl, wYellowIntroCurrentScene
	set 7, [hl]
	ret

YellowIntro_SpawnAnimatedObjectAndSavePointer:
	call SpawnAnimatedObject
	ld a, c
	ld [wYellowIntroAnimatedObjectStructPointer], a
	ld a, b
	ld [wYellowIntroAnimatedObjectStructPointer + 1], a
	ret

YellowIntro_MaskCurrentAnimatedObjectStruct:
	ld a, [wYellowIntroAnimatedObjectStructPointer]
	ld c, a
	ld a, [wYellowIntroAnimatedObjectStructPointer + 1]
	ld b, a
	call MaskCurrentAnimatedObjectStruct
	ret

YellowIntro_SetTimerFor128Frames:
	ld a, 128
	ld [wYellowIntroSceneTimer], a
	ret

YellowIntro_SetTimerFor88Frames:
	ld a, 88
	ld [wYellowIntroSceneTimer], a
	ret

YellowIntro_CheckFrameTimerDecrement:
	ld hl, wYellowIntroSceneTimer
	ld a, [hl]
	and a
	jr z, .asm_f9e4b
	dec [hl]
	and a
	ret

.asm_f9e4b
	scf
	ret

YellowIntro_LoadDMGPalAndIncrementCounter:
	ld hl, wYellowIntroSceneTimer
	ld a, [hl]
	inc [hl]
	ld l, a
	ld h, $0
	add hl, de
	ld a, [hl]
	cp $ff
	jr z, .asm_f9e5d
	and a
	ret

.asm_f9e5d
	scf
	ret

Func_f9e5f:
	ld hl, vBGMap0
	ld bc, $80
	ld a, $1
	call Bank3E_FillMemory
	ld hl, $9880
	ld bc, $140
	xor a
	call Bank3E_FillMemory
	ld hl, $99c0
	ld bc, $80
	ld a, $1
	call Bank3E_FillMemory
	ret

YellowIntro_BlankPalsDelay2AndDisableLCD:
	xor a
	ld [rBGP], a
	ld [rOBP0], a
	ld [rOBP1], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	call UpdateGBCPal_OBP1
	call DelayFrame
	call DelayFrame
	call DisableLCD
	ret

Func_f9e9a:
	ld e, a ; e = 0
	callab YellowIntroPaletteAction

	; Clefairy is 13 tiles wide, we need to offset everything by 4 pixels in order for it to be centered.
	ld a, -4
	ld [hSCX], a

	xor a
	ld [hSCY], a
	ld a, $90
	ld [hWY], a
	ld a, $e3
	ld [rLCDC], a
	ld a, $e4
	ld [rBGP], a
	ld [rOBP0], a
	ld a, $e0
	ld [rOBP1], a

	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	call UpdateGBCPal_OBP1

	ret

YellowIntro_Copy8BitSineWave:
	; Copy this sine wave into wLYOverridesBuffer 8 times (end just before wc900)
	ld de, wLYOverridesBuffer
	ld a, $8
.loop
	push af
	ld hl, .SineWave
	ld bc, .SineWaveEnd - .SineWave
	call Bank3E_CopyData
	pop af
	dec a
	jr nz, .loop
	ret

.SineWave:
; a sine wave with amplitude 4
	db  0,  0,  1,  2,  2,  3,  3,  3
	db  4,  3,  3,  3,  2,  2,  1,  0
	db  0,  0, -1, -2, -2, -3, -3, -3
	db -4, -3, -3, -3, -2, -2, -1,  0
.SineWaveEnd:

Request7TileTransferFromC810ToC710:
	ld a, $10
	ld [H_VBCOPYSRC], a
	ld a, wLYOverridesBuffer / $100
	ld [H_VBCOPYSRC + 1], a
	ld a, $10
	ld [H_VBCOPYDEST], a
	ld a, wLYOverrides / $100
	ld [H_VBCOPYDEST + 1], a
	ld a, $7
	ld [H_VBCOPYSIZE], a
	ret

InitYellowIntroGFXAndMusic:
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld [hSCX], a
	ld [hSCY], a
	ld [H_AUTOBGTRANSFERDEST], a
	ld a, $98
	ld [H_AUTOBGTRANSFERDEST + 1], a
	call YellowIntro_BlankTileMap
	ld hl, wTileMap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	ld a, $1
	call Bank3E_FillMemory
	coord hl, 0, 4
	ld bc, CopyVideoDataAlternate
	xor a
	call Bank3E_FillMemory
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	call DelayFrame
	call DelayFrame
	call DelayFrame
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	call LoadYellowIntroGraphics
	call ClearObjectAnimationBuffers
	call LoadYellowIntroObjectAnimationDataPointers
	ld b, $8
	call RunPaletteCommand
	xor a
	ld hl, wYellowIntroCurrentScene
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, MUSIC_INTRO_BATTLE
	ld c, BANK(Music_IntroBattle)
	call PlayMusic
	ret

LoadYellowIntroGraphics:
	ld de, YellowIntroGraphics + $800
	ld hl, $8000
	ld bc, $3eff
	call CopyVideoData
	ld de, YellowIntroGraphics
	ld hl, $9000
	ld bc, $3e80
	call CopyVideoData
	ret

LoadYellowIntroObjectAnimationDataPointers:
	ld a, YellowIntro_AnimatedObjectSpawnStateData % $100
	ld [wAnimatedObjectSpawnStateDataPointer], a
	ld a, YellowIntro_AnimatedObjectSpawnStateData / $100
	ld [wAnimatedObjectSpawnStateDataPointer + 1], a
	ld a, YellowIntro_AnimatedObjectJumptable % $100
	ld [wAnimatedObjectJumptablePointer], a
	ld a, YellowIntro_AnimatedObjectJumptable / $100
	ld [wAnimatedObjectJumptablePointer + 1], a
	ld a, YellowIntro_AnimatedObjectOAMData % $100
	ld [wAnimatedObjectOAMDataPointer], a
	ld a, YellowIntro_AnimatedObjectOAMData / $100
	ld [wAnimatedObjectOAMDataPointer + 1], a
	ld a, YellowIntro_AnimatedObjectFramesData % $100
	ld [wAnimatedObjectFramesDataPointer], a
	ld a, YellowIntro_AnimatedObjectFramesData / $100
	ld [wAnimatedObjectFramesDataPointer + 1], a
	ret

YellowIntro_BlankTileMap:
	ld hl, wTileMap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	ld a, $7f
	call Bank3E_FillMemory
	ret

Bank3E_CopyData:
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ret

; Loads BC bytes with the value of A starting at address HL
Bank3E_FillMemory:
	push de
	ld e, a
.loop
	ld a, e
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .loop
	pop de
	ret

YellowIntro_BlankOAMBuffer:
	ld hl, wOAMBuffer
	ld bc, wOAMBufferEnd - wOAMBuffer
	xor a
	call Bank3E_FillMemory
	ret

YellowIntro_BlankPalettes:
	xor a
	ld [rBGP], a
	ld [rOBP0], a
	ld [rOBP1], a
	call UpdateGBCPal_BGP
	call UpdateGBCPal_OBP0
	call UpdateGBCPal_OBP1
	ret

YellowIntro_AnimatedObjectSpawnStateData:
	db $00, $00, $00
	db $01, $01, $00
	db $02, $01, $00
	db $03, $01, $00
	db $04, $02, $00
	db $05, $03, $00
	db $06, $04, $00
	db $07, $01, $00
	db $08, $05, $00
	db $09, $01, $00
	db $0a, $01, $00

YellowIntro_AnimatedObjectJumptable:
	dw Func_fa007
	dw Func_fa007
	dw Func_fa008
	dw Func_fa014
	dw Func_fa02b
	dw Func_fa062

Func_fa007:
	ret

Func_fa008:
	ld hl, $4
	add hl, bc
	ld a, [hl]
	cp $58
	ret z
	sub $4
	ld [hl], a
	ret

Func_fa014:
	ld hl, $4
	add hl, bc
	ld a, [hl]
	cp $58
	jr z, .asm_fa020
	add $4
	ld [hl], a
.asm_fa020
	ld hl, $5
	add hl, bc
	cp $58
	ret z
	add $1
	ld [hl], a
	ret

Func_fa02b:
	ld hl, $b
	add hl, bc
	ld e, [hl]
	ld d, $0
	ld hl, Jumptable_fa03b
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

Jumptable_fa03b:
	dw Func_fa03f
	dw Func_fa051

Func_fa03f:
	ld hl, $5
	add hl, bc
	ld a, [hl]
	cp $58
	jr z, .asm_fa04c
	sub $2
	ld [hl], a
	ret

.asm_fa04c
	ld hl, $b
	add hl, bc
	inc [hl]
Func_fa051:
	ld hl, $c
	add hl, bc
	ld a, [hl]
	inc [hl]
	ld d, $8
	call Func_fa079
	ld hl, $7
	add hl, bc
	ld [hl], a
	ret

Func_fa062:
	ld hl, $b
	add hl, bc
	ld a, [hl]
	ld hl, $4
	add hl, bc
	add [hl]
	ld [hl], a
	ret

; Loads the address of the scene subroutine into HL
; A is the scene number
; HL is the address of the jumptable
LoadSceneSubroutineAddress:
	ld e, a
	ld d, $0

	add hl, de
	add hl, de

	ld a, [hli]
	ld h, [hl]

	ld l, a
	ret

Func_fa077: ; cosine
	add $10
Func_fa079:
	and $3f
	cp $20
	jr nc, .asm_fa084
	call Func_fa08e
	ld a, h
	ret

.asm_fa084
	and $1f
	call Func_fa08e
	ld a, h
	xor $ff
	inc a
	ret

Func_fa08e:
	ld e, a
	ld a, d
	ld d, $0
	ld hl, Unkn_fa0aa
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, $0
.asm_fa09d
	srl a
	jr nc, .asm_fa0a2
	add hl, de
.asm_fa0a2
	sla e
	rl d
	and a
	jr nz, .asm_fa09d
	ret

Unkn_fa0aa:
	sine_wave $100
