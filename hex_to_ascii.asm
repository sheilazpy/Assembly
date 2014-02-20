;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Brock J. LaMeres, Erik Anderson
;              Montana State University
;
; Date:        9/25/2013
;
; Description: This program contains a subroutine which will convert HEX nibbles into their equivalent
;              ASCII codes.  The subroutine takes in two nibbles passed in using ACCB.  The nibble
;              The upper nibble ACCB[7:4] will be converted to ASCII and written to PortA.
;              The lower nibble ACCB[3:0] will be converted to ASCII and written to PortB.
;
;              The subroutine is tested in the main program loop using a variety of inputs.
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
            INPUT: DS.B 1              ; Memory location to store the input

;***************************************************************************************************
;*** Constant Definitions (ROM memory allocated for each constant)
MyConst:    SECTION
            TABLE: DC.B "0123456789ABCDEF" ; Look-up table

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS    #__SEG_END_SSTACK   ; initialize the stack pointer

            BSET   DDRA, %11111111     ; Set PortA[7:0] to outputs 
            BSET   DDRB, %11111111     ; Set PortB[7:0] to outputs 


;************************************************************************************
; The code below will test the subrouting "hex_to_ASCII" using every possible
; HEX value.

Main_Loop:
            LDAA   #%00000000          ; Set PortA and PortB to 0 each time through the loop 
            STAA   PortA               ; for easy observation with the logic analyzer
            STAA   PortB

            LDAB   #$01                ; Test ASCII convertion for '0 and '1
            JSR    hex_to_ASCII

            LDAB   #$23                ; Test ASCII convertion for '2 and '3
            JSR    hex_to_ASCII

            LDAB   #$45                ; Test ASCII convertion for '4 and '5
            JSR    hex_to_ASCII

            LDAB   #$67                ; Test ASCII convertion for '6 and '7
            JSR    hex_to_ASCII

            LDAB   #$89                ; Test ASCII convertion for '8 and '9
            JSR    hex_to_ASCII

            LDAB   #$AB                ; Test ASCII convertion for 'A and 'B
            JSR    hex_to_ASCII

            LDAB   #$CD                ; Test ASCII convertion for 'C and 'D
            JSR    hex_to_ASCII

            LDAB   #$EF                ; Test ASCII convertion for 'E and 'F
            JSR    hex_to_ASCII   

            BRA    Main_Loop           ; Loop Forever

                                       
;************************************************************************************
; Subroutine: hex_to_ASCII
;
; Inputs:      ACCB
; Outputs:     PortA and PortB
;
; Description: This subroutine will take in two HEX nibbles in ACCB and convert them
;              to their equivalent ASCII codes.
;              The upper nibble ACCB[7:4] will be converted to ASCII and written to PortA.
;              The lower nibble ACCB[3:0] will be converted to ASCII and written to PortB.

hex_to_ASCII:

            PSHX                       ; Save registers
            PSHY      

            LDX    #TABLE              ; Load look-up table into register X
            STAB   INPUT               ; Save ACCB to memory
            
            LSRB                       ; Shift ACCB right 4 times to capture the upper nibble
            LSRB
            LSRB
            LSRB
            LDAA   B,X                 ; Load ACCA with the ASCII conversion of the upper nibble
            STAA   PortA               ; Store ACCA out to PortA
            
            LDAB   INPUT               ; Restore ACCB to its initial value
            ANDB   #%00001111          ; Clear the upper nibble of ACCB and capture the lower nibble
            LDAA   B,X                 ; Load ACCA with the ASCII conversion of the lower nibble
            STAA   PortB               ; Store ACCA out to PortB

            PULY                       ; Restore the registers
            PULX
           
            RTS                        ; Return from Subroutine          

;************************************************************************************
