;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Erik Anderson
;              Montana State University
;
; Date:        October 23, 2013
;
; Description: This program display a counter on the LEDS on the APS12-C128 processor board.
;              A button-press will increment or decrement the counter.
;
;***************************************************************************************************

;***************************************************************************************************
;*** Export Symbols to Linker Parameter File

            XDEF Entry, _Startup, main ; we use export 'Entry' as symbol. This allows us to
            XDEF PortP_ISR             ; reference 'Entry' either in the linker .prm file

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack


;***************************************************************************************************
;*** Equate & Constant Definitions (no memory allocated)

PortB       EQU    $0001               ; Memory Address for Port B
DDRB        EQU    $0003               ; Data Direction Register for Port B (0=Input=Default, 1=Output)
PTP         EQU    $0258               ; Memory Address for Port P
DDRP        EQU    $025A               ; Data Direction Register for Port P (0=Input=Default, 1=Output)
PERP        EQU    $025C               ; Addresses of pull-up/pull-down control registers
PPSP        EQU    $025D
PIFP        EQU    $025F               ; Interrupt Flag Register for Port P
PIEP        EQU    $025E               ; Local enable register for Port P

SW1         EQU    %00000001           ; Mask for PortP[0] (Switch 1)
SW2         EQU    %00000010           ; Mask for PortP[1] (Switch 2)
SWS         EQU    %00000011           ; Mask for both switches

DELAY       EQU    $FFFF               ; Delay Loop Counter

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer

            BSET   DDRB, %11110000     ; Set PortB[7:4] to outputs to drive LEDs1-4
            BCLR   DDRP, SWS           ; Set PortP[1:0] to input
            BSET   PERP, SWS           ; Enable pull-up/pull-down on PortP[1:0]
            BCLR   PPSP, SWS           ; Set PortP[1:0] to pull-up
            BSET   PIFP, SWS           ; Clear PortP interrupt flags
            BSET   PIEP, SWS           ; Enable PortP interrupts
            
            BSET   PortB, #%11111111   ; LEDs off initially
            
            CLI                        ; Enable interrupts globally


Main_Loop:
            BRA    Main_Loop           ; This instruction will cause the code to start executing
                                       ; at the Main_Loop location in order to run the program
                                       ; forever.
            
PortP_ISR:
            SEI                        ; Disable interrupts
            LDAB   PortB               ; Load LEDs into ACCB
            LDAA   PIFP                ; Load interrupt flag register into ACCA
            CMPA   #SW1                ; Check if switch 1
            BEQ    Switch1
                           
Switch2:                               ; Check failed; switch 2 pressed
            ADDB   #%00010000          ; Decrement by 1
            STAB   PortB
            JSR    Delay_Sub           ; Prevent debounce
            BSET   PIFP, SW2           ; Reenable interrupts
            CLI
            RTI                        ; Return from subroutine
            
Switch1:                               ; Check passed; switch 1 pressed
            SUBB   #%00010000          ; Increment by 1
            STAB   PortB
            JSR    Delay_Sub           ; Prevent debounce
            BSET   PIFP, SW1           ; Reenable interrupts
            CLI
            RTI                        ; Return from subroutine

;***************************************************************************************************
; Subroutine : Simple Delay
Delay_Sub:
            PSHX                       ; Save registers
            PSHY 
            PSHC     

            LDX    #DELAY              ; Initialize Loop Counter
inner:
;     WHILE (x != 0)
;       x = x-1          
      
            DEX    
            BNE    inner          
           
            PULC
            PULY                       ; Restore the registers
            PULX
            RTS   
           
;***************************************************************************************************
