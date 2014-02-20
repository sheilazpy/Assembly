;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Erik Anderson
;              Montana State University
;
; Date:        9/18/13
;
; Description: This program first copy the contents of two, 16-byte pages from ROM (DATA1 & DATA2) .
;              into two 16-byte pages of RAM (BUFFER1 & BUFFER2).
;
;              It will then ADD and XOR the contents of BUFFER1 and BUFFER2 and put the results in
;              BUFFER3 and BUFFER4 respectively.
;              A copy of each operation is stored to PortA PortB for observation by the logic analzyer.
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


;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION

            BUFFER1: DS.B 16
            BUFFER2: DS.B 16
            BUFFER3: DS.B 16
            BUFFER4: DS.B 16

;***************************************************************************************************
;*** Constant Definitions (ROM memory allocated for each constant)
MyConst:    SECTION

            DATA1: DC.B $45,$65,$33,$37,$31,$20,$69,$73,$20,$66,$75,$6E,$20,$21,$20,$21
            DATA2: DC.B $4D,$6F,$6E,$74,$61,$6E,$61,$53,$74,$61,$74,$65,$45,$43,$45,$21

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS    #__SEG_END_SSTACK   ; initialize the stack pointer

            BSET   DDRA, %11111111     ; Set PortA[7:0] to outputs 
            BSET   DDRB, %11111111     ; Set PortB[7:0] to outputs 

Main_Loop:
;************************************************************************************
; The code below will copy the contents of DATA1 and DATA2 into BUFFER1 and BUFFER2

            LDAA   #%00000000          ; Initialize PortA and PortB to 0, this will put a known pattern
            STAA   PortA               ; on both ports for easy observation with the logic analyzer
            STAA   PortB
                                       ; Initialize Registers
            LDAB   #16                 ; Use ACCB for a loop counter, initialize to 16
            LDX    #DATA1              ; Point X to the beginning the address DATA1
            LDY    #BUFFER1            ; Point Y to the beginning the address BUFFER1
Copy_Loop:
            LDAA   0,X                 ; Load the contents of the address that X is pointing (DATA1) to into ACCA
            STAA   0,Y                 ; Store the contents of ACCA to the address that Y is pointing to (BUFFER1)
            STAA   PortA               ; Also store ACCA to PortA for observation with the logic analyzer

            LDAA   16,X                ; Load the contents of the address that X+16 is pointing (DATA2) to into ACCA
            STAA   16,Y                ; Store the contents of ACCA to the address that Y+16 is pointing to (BUFFER2)
            STAA   PortB               ; Also store ACCA to PortB for observation with the logic analyzer

            INX                        ; Increment the X pointer
            INY                        ; Increment the Y pointer
            DECB                       ; Decrement the loop counter

            BNE    Copy_Loop

;************************************************************************************
; The code below will add BUFFER1 to BUFFER2 and store the sum to BUFFER3
; The code below will also XOR BUFFER1 and BUFFER2 and put the result in BUFFER4

            LDAA   #%00000000          ; Initialize PortA and PortB to 0, this will put a known pattern
            STAA   PortA               ; on both ports for easy observation with the logic analyzer
            STAA   PortB
                                       ; Initialize Registers
            LDAB   #16                 ; Use ACCB for a loop counter, initialize to 16
            LDX    #BUFFER1            ; Point X to the beginning the address DATA1
            LDY    #BUFFER3            ; Point Y to the beginning the address BUFFER1
Arith_Loop:
            LDAA   0,X                 ; Load the contents of the address that X is pointing (BUFFER1) to into ACCA
            ADDA   16,X                ; Add the contents of X+16 (BUFFER2) to ACCA
            STAA   0,Y                 ; Store the contents of ACCA to the address that Y is pointing to (BUFFER3)
            STAA   PortA               ; Also store ACCA to PortA for observation with the logic analyzer

            LDAA   0,X                ; Load the contents of the address that X is pointing (BUFFER1) to into ACCA
            EORA   16,X                ; Exlusive or the contents of X+16 (BUFFER2) with ACCA
            STAA   16,Y                ; Store the contents of ACCA to the address that Y+16 is pointing to (BUFFER4)
            STAA   PortB               ; Also store ACCA to PortB for observation with the logic analyzer

            INX                        ; Increment the X pointer
            INY                        ; Increment the Y pointer
            DECB                       ; Decrement the loop counter

            BNE    Arith_Loop
                                        
            BRA   Main_Loop            ; This instruction will cause the code to start executing
                                       ; at the Main_Loop location in order to run the program
                                       ; forever.
                                       
;***************************************************************************************************
