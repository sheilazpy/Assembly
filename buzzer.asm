;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Erik Anderson
;              Montana State University
;
; Date:        November 20, 2013
;
; Description: This program creates an oscillating signal to sound a buzzer.
;              The frequency is set by a button press and displayed on the LEDs.
;              The buzzer is enabled and disabled by a button press.
;
;***************************************************************************************************

;***************************************************************************************************
;*** Export Symbols to Linker Parameter File

            XDEF Entry, _Startup, main ; we use export 'Entry' as symbol. This allows us to
            XDEF TOC_ISR, PortP_ISR    ; reference 'Entry' either in the linker .prm file

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack


;***************************************************************************************************
;*** Equate & Constant Definitions (no memory allocated)

PortA       EQU    $0000               ; Memory Address for Port A
DDRA        EQU    $0002               ; Data Direction Register for Port A (0=Input=Default, 1=Output)
PortB       EQU    $0001               ; Memory Address for Port B
DDRB        EQU    $0003               ; Data Direction Register for Port B (0=Input=Default, 1=Output)
PortT       EQU    $0240               ; Memory Address for Port T
DDRT        EQU    $0242               ; Data Direction Register for Port T (0=Input=Default, 1=Output)

PortP       EQU    $0258               ; Memory Address for Port P
DDRP        EQU    $025A               ; Data Direction Register for Port P (0=Input=Default, 1=Output)
PERP        EQU    $025C               ; Addresses of pull-up/pull-down control registers
PPSP        EQU    $025D
PIFP        EQU    $025F               ; Interrupt Flag Register for Port P
PIEP        EQU    $025E               ; Local enable register for Port P

TIOS        EQU    $0040               ; Timer control registers
TCNT        EQU    $0044
TSCR1       EQU    $0046               
TCTL2       EQU    $0049
TIE         EQU    $004C
TSCR2       EQU    $004D
TFLG1       EQU    $004E
TC0         EQU    $0050
PACTL       EQU    $0060

Bit0        EQU    %00000001           ; Bit 0 mask
Bit1        EQU    %00000010           ; Bit 1 mask

SWS         EQU    %00000011           ; Mask for both switches

DELAY       EQU    $FFFF               ; Delay Loop Counter


;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION


;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION
            Count:     DS.B 1          ; Value on LEDs
            TOC_Count: DS.W 1          ; Current number of cycles between interrupts

;***************************************************************************************************
;*** Constant Definitions (ROM memory allocated for each constant)
MyConst:    SECTION
            Cycles:    DC.W 2000,1000,500,333,250,200,167,143,125,111,100,91,83,77,71,67 ; Number of cycles between interrupts based on LED value

;***************************************************************************************************

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer

            BSET   DDRT, Bit0          ; Set PortT[0] to output
            BSET   DDRB, %11110000     ; Set PortB[7:4] to outputs to drive LEDs1-4
            BCLR   DDRP, SWS           ; Set PortP[1:0] to input
            
            BSET   PERP, SWS           ; Enable pull-up/pull-down on PortP[1:0]
            BCLR   PPSP, SWS           ; Set PortP[1:0] to pull-up
            BSET   PIFP, SWS           ; Clear PortP interrupt flags
            BSET   PIEP, SWS           ; Enable PortP interrupts
            
            BSET   TSCR1,%10000000     ; Set up timer system
            BCLR   TSCR2,%00000111
            BCLR   PACTL,%00001100
            BSET   TIOS, Bit0          ; Enable TC0
            BCLR   TCTL2,Bit1          ; Toggle TC0 automatically
            BSET   TCTL2,Bit0
            
            LDX    #Cycles             ; Initialize values
            LDAB   #0
            STAB   Count
            LDD    0,X
            STD    TOC_Count
            BSET   PortB,%11111111
            BCLR   PortT,Bit0
            
            LDD    TCNT                ; Set first value of TC0
            ADDD   TOC_Count
            STD    TC0
            
            BSET   TFLG1,Bit0          ; Reset TOC[0] flag
            BSET   TIE,  Bit0          ; Local interrupt enable

            CLI                        ; Global interrupt enable
            
Main_Loop:
            WAI                        ; Wait for TOC[0] flag
            BRA    Main_Loop           
            
TOC_ISR:
            LDAA   PortT               ; Toggle PortT[0]
            EORA   #Bit0
            STAA   PortT
            
            LDD    TC0                 ; Set next value of TC0
            ADDD   TOC_Count
            STD    TC0
            
            BSET   TFLG1,Bit0          ; Reset TOC[0] flag
            RTI
            
PortP_ISR:
            SEI                        ; Disable interrupts
            LDAA   PIFP                ; Load interrupt flag register into ACCA
            CMPA   #Bit0                ; Check if switch 1
            BEQ    Switch1
                           
Switch2:                               ; Check failed; switch 2 pressed
            LDAA   TIE                 ; Toggle TC0 interrupt enable
            EORA   #Bit0
            STAA   TIE
            BCLR   PortT,Bit0
            BSET   PIFP, Bit1          ; Reenable interrupts
            CLI
            RTI                        ; Return from subroutine
            
Switch1:                               ; Check passed; switch 1 pressed
            LDAB   PortB               ; Load LEDs into ACCB
            SUBB   #%00010000          ; Increment by 1
            STAB   PortB
            INC    Count
            INC    Count
            LDX    #Cycles
            LDAA   Count
            LDY    A,X                 ; Update TOC value
            STY    TOC_Count
            JSR    Delay_Sub           ; Prevent debounce
            BSET   PIFP, Bit0          ; Reenable interrupts
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
