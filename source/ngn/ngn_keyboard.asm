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
		cp 11						; S1985�̏ꍇBCD�f�R�[�h��74LS145+74LS38�ōs���Ă��āA
		jr nz, @@GET_KEY_ROW0to10	; Y10�̃f�R�[�h���ȈՓI�ɍs���Ă���@�킪����̂ł��̑΍�
		call @@GET_KEY_ROW11
		jr @@CHK_KEY_X_COLUMN		; �ʏ탋�[�`���֖߂�

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
	; 10�L�[��Y9/10,���s�L�[�Ȃǂ�Y11�Ɋ��蓖�Ă��Ă���B
	; S1985�Ȃ�Y COLUMN�̃f�R�[�h���K�v�ȋ@���10�L�[�ɑΉ����Ă���@��ł�
	; BCD�f�R�[�_74LS145��Y0-Y9�܂ł����Ή��ł����AY10�f�R�[�h��74LS38�ōs���Ă���B
	; ������Y10�f�R�[�h��BIT3��BIT2��NAND�����M����Y10�Ƃ��Ă���@�킪����(���SONY�@)
	; ���ʓ��Y�@��ł�Y10��Y11,Y14,Y15��Y10��SCAN���Ă��邱�ƂɂȂ�̂Ŕ��ʂ��K�v
	
	; Models that use the S1985 require Y COLUMN decoding. 
	; This decoding is performed using the 74LS145 and 74LS38. 
	; 74LS145 handles the decoding for Y0-Y9, while Y10 is decoded using the 74LS38. 
	;
	; In some models (mainly SONY machines), the logic for Y10 is Y10 = ~(BIT3 & BIT2).  
	; For these models, since Y10, Y11, Y14, and Y15 are all equivalent to Y10, 
	; distinguishing between them is necessary.
		
		@@GET_KEY_ROW11:
		in a, [$AA]					; PPI��Read
		and $F0						; ���4BIT�͑��p�r�Ȃ̂ł��̂܂ܑf�ʂ�
		or 10						; Y10����U�Z�b�g
		out [$AA], a				; Y�ݒ�
		in a, [$A9]					; XRead(10) 
		ld e,a						; ��in e�͎g���Ȃ��炵��
		and $F0						; ���4BIT�͑��p�r�Ȃ̂ł��̂܂ܑf�ʂ�
		or b						; Y11���Z�b�g
		out [$AA], a				; Y�ݒ�
		in a, [$A9]					; XRead(B)
		cp e						; Y10��Y(B)�̌��ʂ��r���ē����l�Ȃ�Y(B)�͖����l�Ƃ���
		ret nz						; �L���l�Ȃ̂Ŗ߂�
		ld a,$ff					; �����܂��̓L�[���͖���
		ret
		




;***********************************************************
; Fin del archivo
;***********************************************************
NGN_KEYBOARD_EOF: