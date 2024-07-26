#define __SFR_OFFSET 0x00
#include "avr/io.h"
#include <avr/interrupt.h>
;------------------------
.global main

;========================================================================
main:
;------------------------------------------------------------------
; This is the assembly code to turn ADC value of LDR into hash key
; The hash key will later be used to hash the given data (Data is stored in the last line of this program)
; Potentiometer in pin A01 can be used to determine the period of hash key generated every 0.5 - 2 sec
; There is also a second potentiometer that is connected to pin A02, which is used for disturbance led
; Disturbance leds are useful to manipulate light intensity with human interference
; This makes the hashed key more unpredictable
;
; Author: Evandita Wiratama Putra
; Student Id: 2206059572
;
;------------------------------------------------------------------
    RCALL init_serial                   ; Initialize Serial Communication
    RCALL init_disturbance_led          ; Set all port B to output for led
main_loop:
    RCALL init_ADC0                     ; Initialize pin A0 for analog input
    RCALL read_ADC                      ; Get analog value of LDR in pin A0
    
    RCALL print_key                     ; Print the hash key of ADC
    RCALL hash_data                     ; Print the hashed data using the key from LDR

    RCALL init_ADC2                     ; Initialize pin A1 for analog input
    RCALL read_ADC                      ; Get analog value of Potentiometer in pin A2
    RCALL display_disturbance_led       ; Set disturbance led based on the ADC value

    RCALL init_ADC1                     ; Initialize pin A1 for analog input
    RCALL read_ADC                      ; Get analog value of Potentiometer in pin A1
    
    RCALL delay                         ; 0.5 - 2 second delay depending of Potentiometer ADC value
    rjmp main_loop
;========================================================================






;========================================================================
init_disturbance_led:
;------------------------------------------------------------------
; Uses R16 temporarily
; Set all pin D to output pins
;------------------------------------------------------------------
    LDI   R16, 0xff
    OUT   DDRD, R16
    RET
;========================================================================





;========================================================================
display_disturbance_led:
;------------------------------------------------------------------
; Uses R18, R19, R20 temporarily
; Takes the ADC value of pin A02, and mapped it in 1 of 6 possibilities for the leds
; Possibility 1: all disturbance leds are off
; Possibility 2: 1 disturbance led is on
; Possibility 3: 2 disturbance leds are on
; Possibility 4: 3 disturbance leds are on
; Possibility 5: 4 disturbance leds are on
; Possibility 6: 5 disturbance leds are on
;------------------------------------------------------------------
    SBRC R19, 1
    RJMP led_345          ;if ADC value is around 1X XXXX XXXX, then there might be 3, 4, or 5 on leds

    SBRC R19, 0
    RJMP led_2            ;if ADC value is around 01 XXXX XXXX, then 2 leds are on

    SBRC R18, 7
    RJMP led_1            ;if ADC value is around 00 1XXX XXXX, then 1 led is on

    rcall led_off         ;if none requirements are met, then all leds are off
    RET         

led_1:
    SBIS PORTD, 7         ;turn off all leds first
    rcall led_off
    LDI R20, 0b10000000   ;then turn on 1 led
    OUT PORTD, R20
    RET

led_2:
    SBIS PORTD, 6         ;turn off all leds first
    rcall led_off
    LDI R20, 0b11000000   ;then turn on 2 leds
    OUT PORTD, R20
    RET

led_345:
    SBRC R19, 0           ;if ADC value is around 11 XXXX XXXX, then there might be 4 or 5 on leds
    RJMP led_45
    SBIS PORTD, 5         ;turn off all leds first
    rcall led_off
    LDI R20, 0b11100000   ;then turn on 3 leds
    OUT PORTD, R20
    RET

led_45:
    SBRC R18, 7           ;if ADC value is around 11 1XXX XXXX, then there are 5 on leds
    RJMP led_5
    SBIS PORTD, 4         ;turn off all leds first
    rcall led_off
    LDI R20, 0b11110000   ;then turn on 4 leds
    OUT PORTD, R20
    RET

led_5:
    SBIS PORTD, 3         ;turn off all leds first
    rcall led_off
    LDI R20, 0b11111000   ;then turn on 5 leds
    OUT PORTD, R20
    RET
led_off:
    LDI R20, 0b00000000   ;subroutine to turn off all leds
    OUT PORTD, R20
    RET

;========================================================================





;========================================================================
init_ADC0:
;------------------------------------------------------------------
; Uses R20 temporarily
; Input in pin PC0
;------------------------------------------------------------------
    SBI   DDRC, 0     ;set pin PC0 as i/p for ADC0
    ;--------------------------------------------------------------
    LDI   R20, 0x40   ;internal 2.56V, right-justified data, ADC0
    STS   ADMUX, R20
    LDI   R20, 0x87   ;enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R20
    RET
;========================================================================





;========================================================================
init_ADC1:
;------------------------------------------------------------------
; Uses R20 temporarily
; Input in pin PC1
;------------------------------------------------------------------
    SBI   DDRC, 1     ;set pin PC1 as i/p for ADC1
    ;--------------------------------------------------------------
    LDI   R20, 0x41   ;internal 2.56V, right-justified data, ADC1
    STS   ADMUX, R20
    LDI   R20, 0x87   ;enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R20
    RCALL read_ADC
    RET
;========================================================================





;========================================================================
init_ADC2:
;------------------------------------------------------------------
; Uses R20 temporarily
; Input in pin P2
;------------------------------------------------------------------
    SBI   DDRC, 2     ;set pin PC1 as i/p for ADC1
    ;--------------------------------------------------------------
    LDI   R20, 0x42   ;internal 2.56V, right-justified data, ADC2
    STS   ADMUX, R20
    LDI   R20, 0x87   ;enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R20
    RET
;========================================================================





;========================================================================
read_ADC:
;------------------------------------------------------------------
; Uses R17, R20, R21 temporarily
; R18 stores bit 0-7 of ADC conversion
; R19 stores bit 8-9 of ADC conversion
;------------------------------------------------------------------
    LDI   R20, 0xC7   ;set ADSC in ADCSRA to start conversion
    STS   ADCSRA, R20
    ;--------------------------------------------------------------
wait_ADC:
    LDS   R21, ADCSRA ;check ADIF flag in ADCSRA
    SBRS  R21, 4      ;skip jump when conversion is done (flag set)
    RJMP  wait_ADC    ;loop until ADIF flag is set
    ;--------------------------------------------------------------
    LDI   R17, 0xD7   ;set ADIF flag again
    STS   ADCSRA, R17 ;so that controller clears ADIF
    ;--------------------------------------------------------------
    LDS   R18, ADCL   ;get low-byte result from ADCL
    LDS   R19, ADCH   ;get high-byte result from ADCH
    RET
;========================================================================





;========================================================================
init_serial:
;------------------------------------------------------------------
; Uses R24 temporarily
; Initialisz UART Serial Communication Protocol for printing key and hashed data
;------------------------------------------------------------------
    CLR   R24
    STS   UCSR0A, R24                 ;clear UCSR0A register
    STS   UBRR0H, R24                 ;clear UBRR0H register
    LDI   R24, 51                     ;& store in UBRR0L 51 value
    STS   UBRR0L, R24                 ;to set baud rate 19200
    LDI   R24, 1<<RXEN0 | 1<<TXEN0    ;enable RXB & TXB
    STS   UCSR0B, R24
    LDI   R24, 1<<UCSZ00 | 1<<UCSZ01  ;asynch, no parity, 1 stop, 8 bits
    STS   UCSR0C, R24
    RET
;========================================================================





;========================================================================
print_key:
;------------------------------------------------------------------
; Uses R16, R23, R27, R28 temporarily
; Print the hash key from LDR
; Store digit-1 of key in R22
; Store digit-2 of key in R25
; Store digit-3 of key in R26
;------------------------------------------------------------------
    MOV   R26, R19
    ANDI  R26, 3        ;save digit-3 in R26 

    MOV   R23, R19
    MOV   R16, R19
    RCALL ASCII_LSD
    RCALL LCD_buffer
    STS   UDR0, R16     ;print digit-1 of 10-bit result
    ;----------------------------------------------------------------
    MOV   R16, R18
    RCALL ASCII_MSD
    RCALL LCD_buffer
    STS   UDR0, R16     ;print digit-2 of 10-bit result
    ;----------------------------------------------------------------
    MOV   R16, R18
    RCALL ASCII_LSD
    RCALL LCD_buffer
    STS   UDR0, R16     ;print digit-3 of 10-bit result
    ;----------------------------------------------------------------
    LDI   R16, 0x20
    RCALL LCD_buffer
    STS   UDR0, R16     ;space in Serial
    ;--------------------------------------------------------------------   
    LDI   R16, 0x0D
    RCALL LCD_buffer
    STS   UDR0, R16     ;finish Statement
    ;--------------------------------------------------------------------   
    RET                 ;return to loop()
;====================================================================
LCD_buffer:
    LDS   R27, UCSR0A
    SBRS  R27, UDRE0    ;test data buffer if data can be sent
    RJMP  LCD_buffer
    RET
;====================================================================
ASCII_MSD:
    MOV   R23, R16      ;save copy of result
    ANDI  R16, 0xF0     ;extract & swap high-nibble
    SWAP  R16
    MOV   R25, R16      ;Save digit2 in R25 
    SUBI  R16, -48      ;R16 = R16 - (48) = R16 + 48
    MOV   R28, R16      ;save a copy of high-byte result
    SUBI  R28, 58       ;if +ve       
    BRPL  A_F_D1        ;branch & add 7 to get ASCII A to F
adc_loop1: RET
;====================================================================
ASCII_LSD:
    MOV   R16, R23      ;restore copy of result
    ANDI  R16, 0x0F     ;extract low-nibble
    MOV   R22, R16      ;Save digit1 in R22
    SUBI  R16, -48      ;R16 = R16 - (48) = R16 + 48
    MOV   R28, R16      ;save a copy of high-byte result
    SUBI  R28, 58       ;if +ve
    BRPL  A_F_D0        ;branch & add 7 to get ASCII A to F
adc_loop2: RET    
;====================================================================
A_F_D1:
    SUBI  R16, -7       ;R16 = R16 - (7) = R16 + 7
    RJMP  adc_loop1
;---------------------------------------------------------------
A_F_D0:
    SUBI  R16, -7       ;R16 = R16 - (7) = R16 + 7
    RJMP  adc_loop2
;========================================================================





;========================================================================
delay:                
;------------------------------------------------------------------
; Gives 0.5 - 2 seconds delay
;------------------------------------------------------------------
delay_loop:
    DEC   R19
    RCALL delay_timer1
    BRGE  delay_loop
    RET
;========================================================================





;========================================================================
delay_timer1:             
;------------------------------------------------------------------
; Uses R20 temporarily
; Uses built-in timer component of Arduino for precise delay
; Create 0.5 sec delay
;------------------------------------------------------------------
.EQU value, 57724         ;value to give 0.5 sec delay
    LDI   R20, hi8(value)
    STS   TCNT1H, R20
    LDI   R20, lo8(value)
    STS   TCNT1L, R20     ;initialize counter TCNT1 = value
    ;-------------------------------------------------------
    LDI   R20, 0b00000000
    STS   TCCR1A, R20
    LDI   R20, 0b00000101
    STS   TCCR1B, R20     ;normal mode, prescaler = 1024
    ;-------------------------------------------------------
timer_loop: 
    IN    R20, TIFR1      ;get TIFR1 byte & check
    SBRS  R20, TOV1       ;if TOV1=1, skip next instruction
    RJMP  timer_loop      ;else, loop back & check TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 1<<TOV1
    OUT   TIFR1, R20      ;clear TOV1 flag
    ;-------------------------------------------------------
    LDI   R20, 0b00000000
    STS   TCCR1B, R20     ;stop timer0
    RET
;========================================================================





;========================================================================
hash_data:
;------------------------------------------------------------------
; Uses R16, R17, R18, R19, R30, R31 temporarily
; Announce the game is about to start
;------------------------------------------------------------------
    LDI   R30, lo8(data)
    LDI   R31, hi8(data)      ; Z points to string message
    MOV   R19, R26            ; Load xor hash counter
hash_agn:
    LPM   R18, Z+             ;load char of string onto R18
    CPI   R18, 0              ;check if R18=0 (end of string)
    BREQ  hash_exit           ;if yes, exit
    ;--------------------------------------------------------------------
hash_loop:
    LDS   R17, UCSR0A
    SBRS  R17, UDRE0          ;test data buffer if data can be sent
    RJMP  hash_loop
    CPI   R18, 96
    BRGE  hash_a_z
    ADD   R18, R22
    RJMP  hash_xor
hash_a_z:
    SUB   R18, R22
hash_xor:
    DEC   R19
    BRGE  print_hash          ; if (hash counter > 0) don't do hash xor
    MOV   R19, R26            ; Load hash xor counter again
    EOR   R18, R25            ; Do hash xor
print_hash:
    STS   UDR0, R18           ;send char in R18 to serial monitor
    ;--------------------------------------------------------------------
    RJMP  hash_agn            ;loop back & get next character
    ;--------------------------------------------------------------------
hash_exit:
    ;----------------------------------------------------------------
    LDI   R16, 0x0A
    RCALL LCD_buffer
    STS   UDR0, R16           ;Enter in Serial
    ;--------------------------------------------------------------------   
    LDI   R16, 0x0D
    RCALL LCD_buffer
    STS   UDR0, R16           ;Finish Statement
    ;--------------------------------------------------------------------   
    RET
;------------------------------------------------------------------------
data:                         ; This is the data that is going to be hashed
    .ascii "This Contains Credential Information"       
    .byte 0
;========================================================================





