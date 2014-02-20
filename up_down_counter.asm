;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Brock J. LaMeres, Erik Anderson
;              Montana State University
;
; Date:        9/11/2013
;
; Description: This program will output a DOWN counter to PortA and a UP counter to PortB.
;              Since the APS12-C128 LEDs are connected to PortB[7:4], the upper four bits of the
;              UP counter will be visible.  
;              A delay is generated using a subroutine in order to slow down the pattern so that
;              it is visible by the human eye.
;
;***************************************************************************************************

;***************************************************************************************************
;*** Export Symbols to Linker Parameter File

            XDEF Entry, _Startup, main ; we use export 'Entry' as symbol. This allows us to
                                       ; reference 'Entry' either in the linker .prm file

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack


;***************************************************************************************************
;*** Equate & Constant Definitions (no memory allocated)

PortA       EQU    $0000               ; Memory Address for Port A
DDRA        EQU    $0002               ; Data Direction Register for Port A (0=Input=Default, 1=Output)
PortB       EQU    $0001               ; Memory Address for Port B
DDRB        EQU    $0003               ; Data Direction Register for Port B (0=Input=Default, 1=Output)

DELAY1      EQU    $2fff               ; Inner Delay Loop Counter
DELAY2      EQU    $0002               ; Outer Delay Loop Counter

;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION
                                       ; Define Variables Here

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer

            BSET   DDRA, %11111111     ; Set PortA[7:0] to outputs 
            BSET   DDRB, %11111111     ; Set PortB[7:0] to outputs 

            LDAA   #%00000000          ; Initialize PortA and PortB to 0
            STAA   PortA
            STAA   PortB

Main_Loop:
            INC    PortA               ; Increment PortA by 1
            DEC    PortB               ; Decrement PortB by 1
            
            JSR    Delay_Sub           ; Call a delay subroutine in order to slow down counter
                                       
            BRA    Main_Loop           ; This instruction will cause the code to start executing
                                       ; at the Main_Loop location in order to run the program
                                       ; forever.

;***************************************************************************************************
; Subroutine : Simple Delay
Delay_Sub:
            PSHX                      ; Save registers
            PSHY      

; DO (outer loop)
            LDY    #DELAY2            ; Initialize Outer Loop
outer:
; WHILE (y != 0)
;    y = y-1           
 
            DEY              
            BEQ    all_done            ; Branch to end when y=0        

;     DO (inner loop)
            LDX    #DELAY1             ; Initialize Inner Loop
inner:
;     WHILE (x != 0)
;       x = x-1          
      
            DEX    
            BNE    inner          
           
;     ENDWHILE (outer loop)           
            BRA    outer
               
; ENDWHILE (inner loop)
all_done:
           PULY                        ; Restore the registers
           PULX
           RTS          
           
;***************************************************************************************************




