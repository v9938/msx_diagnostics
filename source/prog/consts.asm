;***********************************************************
;
;   MSX DIAGNOSTICS
;   Version 1.2.0
;   ASM Z80 MSX
;   Definicion de constantes
;   (cc) 2018-2020 Cesar Rincon "NightFox"
;   https://nightfoxandco.com
;
;***********************************************************



; ----------------------------------------------------------
; Sistema
; ----------------------------------------------------------

SYSTEM_KEYS_NUMBER      .EQU	6		; Numero de teclas de sistema

@@SYSTEM:



; ----------------------------------------------------------
; Menu principal
; ----------------------------------------------------------

MAINMENU_ITEM_START		        .EQU	7		; Offset del cursor en Y
MAINMENU_FIRST_OPTION_P1	    .EQU	0		; (1 - 1)
MAINMENU_LAST_OPTION_P1		    .EQU	9		; (8 + 1)
MAINMENU_FIRST_OPTION_P2        .EQU	0		; (1 - 1)
MAINMENU_LAST_OPTION_P2		    .EQU	9		; (8 + 1)

@@MAIN_MENU:



; ----------------------------------------------------------
; Test SCREEN 2
; ----------------------------------------------------------

SCR2TEST_FIRST_IMAGE        .EQU	0	; (1 - 1)	Idx al que saltar a la ultima imagen	
SCR2TEST_LAST_IMAGE		    .EQU	5	; (4 + 1)	Idx al que saltar a la primera imagen

@@SCREEN2_TEST:




; ----------------------------------------------------------
; Test SCREEN 3
; ----------------------------------------------------------

SCR3TEST_FIRST_PATTERN      .EQU	0	; (1 - 1)	Idx al que saltar a la ultimo patron
SCR3TEST_LAST_PATTERN		.EQU	8	; (7 + 1)	Idx al que saltar a la primer patron

@@SCREEN3_TEST:



; ----------------------------------------------------------
; Test JOYSTICK
; ----------------------------------------------------------

JOYTEST1_COLOR_OFF      .EQU	4
JOYTEST1_COLOR_ON		.EQU	10
JOYTEST2_COLOR_OFF		.EQU	6
JOYTEST2_COLOR_ON		.EQU	12

@@JOY_TEST:



; ----------------------------------------------------------
; Test PSG
; ----------------------------------------------------------

PSGTEST_ITEM_START              .EQU	4		; Offset del cursor en Y
PSGTEST_FIRST_OPTION		    .EQU	0		; (1 - 1)
PSGTEST_LAST_OPTION		        .EQU	9		; (8 + 1)
PSGTEST_FREQ_X_START            .EQU    11      ; Offset del cursor X
PSGTEST_FREQ_X_GAP              .EQU    8       ; Espacio entre columnas
PSGTEST_VOL_X_START             .EQU    17      ; Offset del cursor X
PSGTEST_NOISE_CHAN_X_START      .EQU    18      ; Offset del cursor X
PSGTEST_NOISE_CHAN_X_GAP        .EQU    6       ; Espacio entre columnas
PSGTEST_NOISE_FREQ_X_START      .EQU    17      ; Offset del cursor X


; Usa el NGN_RAM_BUFFER, para las variables, define aqui los offsets

PSG_TEST_OPTION_SELECTED    .EQU    0		; Opcion seleccionada del menu (1-3 Freq, 4-6 Vol, 7 Noise Chan, 8 Noise Freq)
SNDCHN1_FRQ                 .EQU    1		; Frecuencia de cada canal (0:off, 1:500Hz, 2:1kHz, 3:2kHz)
SNDCHN2_FRQ                 .EQU	2
SNDCHN3_FRQ                 .EQU	3
SNDCHN1_VOL                 .EQU	4		; Volumen de cada canal (0 - 15)
SNDCHN2_VOL                 .EQU	5
SNDCHN3_VOL                 .EQU	6
SNDNOISE_CHAN               .EQU	7       ; Canal asignado al noise (0:off, 1-3:ON)
SNDNOISE_FRQ                .EQU	8       ; Frecuencia del canal (0 - 15 niveles)
PSG_TEST_CURSOR_X           .EQU    9       ; Posicion del cursor
PSG_TEST_CURSOR_Y           .EQU    10
PSG_TEST_CURSOR_OLD_X       .EQU    11
PSG_TEST_CURSOR_OLD_Y       .EQU    12
PSG_TEST_CHANNEL            .EQU    13       ; Canal actual (1-4)
PSG_TEST_VOLUME             .EQU    14       ; Volumen actual
PSG_TEST_FREQ               .EQU    15       ; Frecuencia actual

@@PSG_TEST:



; ----------------------------------------------------------
; Informacion del sistema
; ----------------------------------------------------------

; Usa el NGN_RAM_BUFFER, para las variables, define aqui los offsets

SYS_INFO_MODEL      .EQU    $80         ; Modelo de MSX         (Puntero de texto)      2 bytes
SYS_INFO_KB         .EQU    $82         ; Layout de teclado     (Puntero de texto)      2 bytes
SYS_INFO_VRAM       .EQU    $84         ; VRAM                  (BCD)                   2 bytes
SYS_INFO_VDP        .EQU    $86         ; VDP                   (Puntero de texto)      2 bytes
SYS_INFO_HZ         .EQU    $88         ; HZ de refresco        (Puntero de texto)      2 bytes

SYS_INFO_RAM_PAGES_TEXT_POS     .EQU    $100        ; Posicion de escritura     2 bytes

@@SYS_INFO:




; ----------------------------------------------------------
; Test del Color del monitor
; ----------------------------------------------------------

MONITOR_COLOR_ITEM_FIRST        .EQU        1       ; Primer test
MONITOR_COLOR_ITEM_LAST         .EQU        6       ; Ultimo test



; Usa el NGN_RAM_BUFFER, para las variables, define aqui los offsets

MONITOR_COLOR_CURRENT_ITEM      .EQU  0       ; Item seleccionado del test
MONITOR_COLOR_CURRENT_COLOR     .EQU  1       ; Color actual del ciclo de colores
MONITOR_COLOR_DELAY             .EQU  2       ; Numero de frames de espera
MONITOR_COLOR_FRAME             .EQU  3       ; Frame actual

@@MONITOR_COLOR_TEST:



; ----------------------------------------------------------
; Rutinas de configuracion de slots y memoria
; ----------------------------------------------------------

; Puerto para la seleccion de segmento de mapper
; MSX1 BIOSのバグ対応のためテストアドレスを変更した。
MEMORY_MAPPER_TEST_PAGE         .EQU    $8FFF   ; Direccion de la pagina
MEMORY_MAPPER_TEST_PORT         .EQU    $FE     ; Puerto para la pagina [Pagina 2 seleccionada]


; Usa el NGN_RAM_BUFFER, para las variables, define aqui los offsets

MEMORY_PAGE3_SLOT               .EQU    $100    ; Guarda el byte de la seleccion de la pagina 3                     1 byte
MEMORY_IN_CURRENT_SELECTION     .EQU    $101    ; Memoria encontrada en la seleccion actual                         3 bytes
MEMORY_MAPPER_TOTAL_PAGES       .EQU    $104    ; Nº de paginas del mapper                                          2 bytes
MEMORY_MAPPER_PAGES_BACKUP      .EQU    $200    ; Bytes de las paginas del mapper                                   256 bytes

@@MEMORY_ROUTINES:



; ----------------------------------------------------------
; Informes de la memoria RAM
; Test de la memoria RAM
; ----------------------------------------------------------

; Usa el NGN_RAM_BUFFER, para las variables, define aqui los offsets

RAM_TEST_TEMP_CURSOR            .EQU    $200        ; Posicion del cursor (2 bytes)
RAM_TEST_SLOT_INFO_OFFSET       .EQU    $202        ; Offset para poder acceder a la informacion del SLOT (1 byte)
                                                    ; Variable (RAM_SLOT_0...)
RAM_TEST_SLOT_INFO              .EQU    $203        ; Informacion del slot actual   (1 byte)

RAM_TEST_SHOW_ALL_INFO          .EQU    $204        ; Muestra TODA la informacion?      (1 byte)
RAM_TEST_TOTAL_OPTIONS          .EQU    $205        ; Numero de opciones detectadas     (1 byte)
RAM_TEST_OPTION_LIST            .EQU    $206        ; ID's de los slots encontrados (1 byte x 16)
RAM_TEST_SLOT_OK                .EQU    $216        ; El slot/sub-slot actual contiene RAM (1 byte)

RAM_TEST_TEMP_STRING            .EQU    $217        ; Cadena de texto temporal (32 bytes)

@@MEMORY_REPORTS:


;***********************************************************
; Fin del archivo
;***********************************************************
CONSTS_EOF: