;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Erik Anderson
;              Montana State University
;
; Date:        October 23, 2013
;
; Description: This program displays a pattern on the LEDS on the APS12-C128 processor board.
;              A button-press will trigger an interrupt to display the pattern.
;
;***************************************************************************************************

;***************************************************************************************************
;*** Export Symbols to Linker Parameter File

            XDEF Entry, _Startup, main ; we use export 'Entry' as symbol. This allows us to
            XDEF PortP_ISR             ; reference 'Entry' either in the linker .prm file

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack


;***************************************************************************************************
;*** Equate & Constant Definitions (no memory allocated)

PortA       EQU    $0000               ; Memory Address for Port A
DDRA        EQU    $0002               ; Data Direction Register for Port A (0=Input=Default, 1=Output)
PortB       EQU    $0001               ; Memory Address for Port B
DDRB        EQU    $0003               ; Data Direction Register for Port B (0=Input=Default, 1=Output)
PTP         EQU    $0258               ; Memory Address for Port P
DDRP        EQU    $025A               ; Data Direction Register for Port P (0=Input=Default, 1=Output)
PERP        EQU    $025C               ; Addresses of pull-up/pull-down control registers
PPSP        EQU    $025D
PIFP        EQU    $025F               ; Interrupt Flag Register for Port P
PIEP        EQU    $025E               ; Local enable register for Port P

SW1         EQU    %00000001           ; Mask for last bit of Port P

DELAY1      EQU    $ffff               ; Inner Delay Loop Counter
DELAY2      EQU    $0004               ; Outer Delay Loop Counter

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

            BSET   DDRA, %11111111     ; Set PortA to output
            BSET   DDRB, %11110000     ; Set PortB[7:4] to outputs to drive LEDs1-4
            BCLR   DDRP, SW1           ; Set PortP[0] to input
            BSET   PERP, SW1           ; Enable pull-up/pull-down on PortP[0]
            BCLR   PPSP, SW1           ; Set PortP[0] to pull-up
            BSET   PIFP, SW1           ; Clear PortP interrupt flag
            BSET   PIEP, SW1           ; Enable PortP interrupts
            
            LDAA   #%11111111          ; LEDs off initially
            STAA   PortB               ; Initialize LEDs
            
            LDAA   #$AA                ; Initialize registers for stack exploration
            LDAB   #$BB                
            LDX    #$CCDD
            LDY    #$EEFF
            
            CLI                        ; Enable interrupts globally


Main_Loop:
            BRA    Main_Loop           ; This instruction will cause the code to start executing
                                       ; at the Main_Loop location in order to run the program
                                       ; forever.
            
PortP_ISR:
            TSX                        ; Transfer stack pointer to X
            LDAB   #0
Copy_Loop:
            LDAA   B,X                 ; Store stack values to PortA for observation
            STAA   PortA
            INCB
            CMPB   #9
            BLO    Copy_Loop           ; Loop 9 times
            
            LDAA   #%11101111          ; Show pattern on LEDs
            STAA   PortB
            JSR    Delay_Sub
            ROLA
            STAA   PortB
            JSR    Delay_Sub
            ROLA 
            STAA   PortB
            JSR    Delay_Sub
            ROLA
            STAA   PortB
            JSR    Delay_Sub
            ROLA
            STAA   PortB     
            
            BSET   PIFP, SW1           ; Reset interrupt flag
            RTI                        ; Return from subroutine

;***************************************************************************************************
; Subroutine : Simple Delay
Delay_Sub:
            PSHX                      ; Save registers
            PSHY 
            PSHC     

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
           PULC
           PULY                        ; Restore the registers
           PULX
           RTS          
           
;***************************************************************************************************
