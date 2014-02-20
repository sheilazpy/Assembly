;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Brock J. LaMeres, Erik Anderson
;              Montana State University
;
; Date:        9/4/2013
;
; Description: This program will output a pattern to the LEDS on the APS12-C128 processor board.
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

PortB       EQU    $0001               ; Memory Address for Port B
DDRB        EQU    $0003               ; Data Direction Register for Port B (0=Input=Default, 1=Output)

DELAY1      EQU    $ffff               ; Inner Delay Loop Counter
DELAY2      EQU    $0004               ; Outer Delay Loop Counter

;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION
Var1        DS.B   1                   ; Setting up a Variable, not used in this code, just FYI

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer

            BSET   DDRB, %11110000     ; Set PortB[7:4] to outputs to drive LEDs1-4


Main_Loop:
            LDAA   #%11110000          ; Writing a walking pattern to the LEDs
            STAA   PortB               ; The LEDS on the APS12-C128 board are
            JSR    Delay_Sub           ; ON  when driven with a 0 &
                                       ; OFF when driven with a 1
            LDAA   #%11100000          ;
            STAA   PortB               ; We do this by loading a the pattern value into
            JSR    Delay_Sub           ; accumulator A and then storing it to Port B.
                                       ;
            LDAA   #%11010000          ; We call a delay subroutine after each store in order
            STAA   PortB               ; to slow down the update rate of the LEDS so that it
            JSR    Delay_Sub           ; is visible
                                       ;
            LDAA   #%10110000          ; We manually write 5 distinct patterns to the LEDS
            STAA   PortB               ;
            JSR    Delay_Sub           ;
                                       ;
            LDAA   #%01110000          ;
            STAA   PortB               ;
            JSR    Delay_Sub           ;
                                       ;
            STAA   Var1                ; This store is just an example, Var1 is not used.
                                       ;
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




