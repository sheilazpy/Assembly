;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Erik Anderson
;              Montana State University
;
; Date:        October 23, 2013
;
; Description: This program uses a timer interrupt to increment a 16-bit counter.
;
;***************************************************************************************************

;***************************************************************************************************
;*** Export Symbols to Linker Parameter File

            XDEF Entry, _Startup, main ; we use export 'Entry' as symbol. This allows us to
            XDEF TOI_ISR               ; reference 'Entry' either in the linker .prm file

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack


;***************************************************************************************************
;*** Equate & Constant Definitions (no memory allocated)

PortA       EQU    $0000               ; Memory Address for Port A
DDRA        EQU    $0002               ; Data Direction Register for Port A (0=Input=Default, 1=Output)
PortB       EQU    $0001               ; Memory Address for Port B
DDRB        EQU    $0003               ; Data Direction Register for Port B (0=Input=Default, 1=Output)

TSCR1       EQU    $0046               ; Timer control registers
TSCR2       EQU    $004D
TFLG2       EQU    $004F
PACTL       EQU    $0060

TOF         EQU    %10000000           ; Timer overflow flag (also used for TOI flag)


;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION
Count       DS.W   1                   ; Counter variable
TOF_Count   DS.B   1                   ; TOF counter variable

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer

            BSET   DDRA, %11111111     ; Set PortA to output
            BSET   DDRB, %11111111     ; Set PortB to output
            
            BSET   TSCR1,%10000000     ; Set up timer system
            BCLR   TSCR2,%00000111
            BCLR   PACTL,%00001100
            BSET   TFLG2,TOF
            BSET   TSCR2,TOF           ; Enable interrupt
            
            LDAA   #3
            STAA   TOF_Count           ; Set TOF counter to 3
            
            LDD    #0
            STD    Count               ; Set count to 0
            STD    PortA
            
            CLI                        ; Global enable interrupts
            
Main_Loop:
            WAI                        ; Wait for TOF bit to be set
            BRA    Main_Loop           
            
TOI_ISR:
            DEC    TOF_Count           ; Decrement TOF counter
            BNE    Return              ; Skip subroutine if less than 3 TOFs
            
            LDD    Count               ; Increment counter
            ADDD   #1              
            STD    Count
            STD    PortA               ; Store counter to PortA:PortB
            LDAA   #3
            STAA   TOF_Count           ; Reset TOF counter
Return:            
            BSET   TFLG2,TOF           ; Reset TOF flag
            BSET   TSCR2,TOF           ; Reenable interrupt
            RTI
            
;***************************************************************************************************
