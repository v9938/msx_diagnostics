;***********************************************************
;
;	N'gine para MSX Asm Z80
;	Version 0.3.4-alpha
;
;	(cc) 2018-2020 Cesar Rincon "NightFox"
;	https://nightfoxandco.com
;
;	Rutinas de acceso al teclado
;
;***********************************************************



; ----------------------------------------------------------
; NGN_KEYBOARD_READ
; Lee las teclas definidas
; Modifica A, BC, DE, HL
; ----------------------------------------------------------

NGN_KEYBOARD_READ:

	; Deshabilita las interrupciones
	di

	; Resetea el registro de estado para NGN_KEY_ANY
	ld d, $00

	; Lee los 8 bits de las 11 filas de la matriz del teclado
	ld hl, NGN_KEY_0			; Puntero donde esta la primera tecla
	ld bc, $0000				; Reset de fila y BIT
	@@ROW_LOOP:
		ld c, 1					; Reset del BIT
		@@BIT_LOOP:
			call @@GET_KEY		; Actualiza el estado de la tecla
			inc hl				; Siguiente tecla
			ld a, c
			cp $80				; Si has leido el bit 7,
			jr z, @@NEXT_ROW	; lee la siguiente fila
			sla c				; Siguiente BIT
			jr @@BIT_LOOP
		@@NEXT_ROW:
			inc b				; Siguiente fila
			ld a, b
			cp 12				; Si ya se han leido todas las filas
								; Modify FS-A1 FS-A1WSX/FS-A1WSX/FS-A1ST/FS-A1GT
			jr nz, @@ROW_LOOP	; Si no, siguiente fila

	; Habilita las interrupciones
	ei

	; Actualiza el estado de NGN_KEY_ANY
	call @@KEY_ANY
		
	; Limpia el buffer del teclado con la rutina de BIOS [KILBUF]
	jp $0156

	; El RET lo aplica la propia rutina de BIOS



	

	; @@GET_KEY
	; Lee el estado de la tecla solicitada usando los puertos $A9 y $AA
	; Usa el registro BC para pasar la fila (B) y el BIT (C)
	; Usa el registro HL para la direccion de la variable asignada a cada tecla

	@@GET_KEY:
		ld a, b						; @patched @v9938
		cp 11						; S1985の場合BCDデコードが74LS145+74LS38で行われていて、
		jr nz, @@GET_KEY_ROW0to10	; Y10のデコードを簡易的に行っている機種があるのでその対策
		call @@GET_KEY_ROW11
		jr @@CHK_KEY_X_COLUMN		; 通常ルーチンへ戻る

	@@GET_KEY_ROW0to10:
	
		in a, [$AA]			; Lee el contenido del selector de filas
		and $F0				; Manten los datos de los BITs 4 a 7 (resetea los bits 0 a 3)
		or b				; Indica la fila
		out [$AA], a		; y seleccionala
		in a, [$A9]			; Lee el contenido de la fila
	@@CHK_KEY_X_COLUMN:
		and c				; Lee el estado de la tecla segun el registro C
		jr z, @@KEY_HELD	; En caso de que se haya pulsado, salta

		; Si no se ha pulsado
		ld a, [hl]
		and $08				; Pero lo estabas
		jr z, @@NO_KEY
		ld [hl], $04		; B0100
		ret

		; La tecla no se ha pulsado ni estaba pulsada
		@@NO_KEY:
		ld [hl], $00		; B0000
		ret

		; Si se ha pulsado
		@@KEY_HELD:
		; Actualiza el estado de NGN_KEY_ANY
		ld d, $FF
		; Analiza si la pulsacion es nueva
		ld a, [hl]			; Carga el estado anterior
		and $08				; Si no estava pulsada...
		jr z, @@KEY_PRESS	; Salta a NEW PRESS
		ld [hl], $09		; Si ya estava pulsada, B1001
		ret

		; Si era una nueva pulsacion
		@@KEY_PRESS:
		ld [hl], $0B		; B1011
		ret



	; Actualiza el estado de  NGN_KEY_ANY
	@@KEY_ANY:

		ld hl, NGN_KEY_ANY		; Apunta a la tecla

		; Analiza si hay pulsacion
		ld a, d
		cp $FF
		jr z, @@KEY_ANY_HELD	; Hay pulsacion

		; Si no se ha pulsado
		ld a, [hl]
		and $08					; Pero lo estabas
		jr z, @@KEY_ANY_NONE
		ld [hl], $04			; B0100
		ret

		; No se ha pulsado ni no estaba
		@@KEY_ANY_NONE:
		ld [hl], $00			; B0000
		ret

		; Si se ha pulsado
		@@KEY_ANY_HELD:
		ld a, [hl]				; Carga el estado anterior
		and $08					; Si no estava pulsada...
		jr z, @@KEY_ANY_PRESS	; Salta a NEW PRESS
		ld [hl], $09			; B1001
		ret

		; Si era una nueva pulsacion
		@@KEY_ANY_PRESS:
		ld [hl], $0B			; B1011
		ret

	; @patched @v9938
	; 10キーはY9/10,実行キーなどはY11に割り当てられている。
	; S1985などY COLUMNのデコードが必要な機種で10キーに対応している機種では
	; BCDデコーダ74LS145はY0-Y9までしか対応できず、Y10デコードは74LS38で行っている。
	; そしてY10デコードをBIT3とBIT2をNANDした信号をY10としている機種がある(主にSONY機)
	; 結果当該機種ではY10とY11,Y14,Y15はY10をSCANしていることになるので判別が必要
	
	; Models that use the S1985 require Y COLUMN decoding. 
	; This decoding is performed using the 74LS145 and 74LS38. 
	; 74LS145 handles the decoding for Y0-Y9, while Y10 is decoded using the 74LS38. 
	;
	; In some models (mainly SONY machines), the logic for Y10 is Y10 = ~(BIT3 & BIT2).  
	; For these models, since Y10, Y11, Y14, and Y15 are all equivalent to Y10, 
	; distinguishing between them is necessary.
		
		@@GET_KEY_ROW11:
		in a, [$AA]					; PPIのRead
		and $F0						; 上位4BITは他用途なのでそのまま素通し
		or 10						; Y10を一旦セット
		out [$AA], a				; Y設定
		in a, [$A9]					; XRead(10) 
		ld e,a						; ※in eは使えないらしい
		and $F0						; 上位4BITは他用途なのでそのまま素通し
		or b						; Y11をセット
		out [$AA], a				; Y設定
		in a, [$A9]					; XRead(B)
		cp e						; Y10とY(B)の結果を比較して同じ値ならY(B)は無効値とする
		ret nz						; 有効値なので戻る
		ld a,$ff					; 無効またはキー入力無し
		ret
		




;***********************************************************
; Fin del archivo
;***********************************************************
NGN_KEYBOARD_EOF: