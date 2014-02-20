;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Erik Anderson
;              Montana State University
;
; Date:        October 2, 2013
;
; Description: This program will turn on the LEDS on the APS12-C128 processor board when a button is pushed.
;
;***************************************************************************************************

;***************************************************************************************************
;*** Export Symbols to Linker Parameter File

            XDEF Entry, _Startup, main ; we use export 'Entry' as symbol. This allows us to
                                       ; reference 'Entry' either in the linker .prm file

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack


;***************************************************************************************************
;*** Equate & Constant Definitions (no memory allocated)

PortB       EQU    $0001               ; Memory Address for Port B
DDRB        EQU    $0003               ; Data Direction Register for Port B (0=Input=Default, 1=Output)
PTP         EQU    $0258               ; Memory Address for Port P
DDRP        EQU    $025A               ; Data Direction Register for Port P (0=Input=Default, 1=Output)
PERP        EQU    $025C               ; Addresses of pull-up/pull-down control registers
PPSP        EQU    $025D

SW1         EQU    %00000001           ; Mask for last bit of Port P

;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer

            BSET   DDRB, %11110000     ; Set PortB[7:4] to outputs to drive LEDs1-4
            BCLR   DDRP, SW1           ; Set PortP[0] to input
            BSET   PERP, SW1           ; Enable pull-up/pull-down on PortP[0]
            BCLR   PPSP, SW1           ; Set PortP[0] to pull-up
            
            LDAA   #%11110000          ; Mask for LEDs off
            LDAB   #%00000000          ; Mask for LEDs on
            STAA   PortB               ; Initialize LEDs off


Main_Loop:
            BRSET  PTP,SW1,LED_Off     ; Skip to LED_Off if PTP[0] is set
            STAB   PortB               ; Turn on LEDs (only executes if PTP[0] is cleared)
LED_Off:
            BRCLR  PTP,SW1,Main_Loop   ; Skip to top if PTP[0] is cleared
            STAA   PortB               ; Turn off LEDs (only executes if PTP[0] is set)
            
            BRA    Main_Loop           ; This instruction will cause the code to start executing
                                       ; at the Main_Loop location in order to run the program
                                       ; forever.
