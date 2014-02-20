;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Erik Anderson
;              Montana State University
;
; Date:        October 9, 2013
;
; Description: This program copies a 16-byte page of data from ROM into RAM and uses the stack
;              to reverse the order of the data.
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

Loop        EQU    15                  ; Value of loop counter


;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION
            SWAP:  DS.B 16             ; Memory location to store the data

;***************************************************************************************************
;*** Constant Definitions (ROM memory allocated for each constant)
MyConst:    SECTION
            DATA1: DC.B $00,$11,$22,$33,$44,$55,$66,$77,$88,$99,$AA,$BB,$CC,$DD,$EE,$FF

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS    #__SEG_END_SSTACK   ; initialize the stack pointer

            BSET   DDRA, %11111111     ; Set PortA[7:0] to outputs 
            BSET   DDRB, %11111111     ; Set PortB[7:0] to outputs 
            
            LDAB   #Loop               ; Initialize loop counter
            LDX    #DATA1              ; Set registers to point to data locations
            LDY    #SWAP
            
Copy_Loop:                             ; Copy DATA1 to SWAP
            LDAA   B,X
            STAA   B,Y
            DECB
            BGE    Copy_Loop

Main_Loop:
            LDAB   #Loop               ; Reset loop counter
            
Push_Loop:                             ; Push SWAP values onto stack
            LDAA   B,Y                 ; Load from SWAP[B]
            PSHA                       ; Push onto stack
            TFR    SP,X                ; Transfer SP to X
            STX    PortA               ; Store SP to PortA and PortB for observation
            DECB
            BGE    Push_Loop
            
            LDAB   #Loop               ; Reset loop counter
            
Pull_Loop:                             ; Pull SWAP values off of stack (in reverse order)
            TFR    SP,X                ; Transfer SP to X
            STX    PortA               ; Store SP to PortA and PortB for observation
            PULA                       ; Pull off stack
            STAA   B,Y                 ; Store to SWAP[B]
            DECB
            BGE    Pull_Loop
            
            BRA    Main_Loop           ; This instruction will cause the code to start executing
                                       ; at the Main_Loop location in order to run the program
                                       ; forever.
