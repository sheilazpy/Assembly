;***************************************************************************************************
;
; Filename:    main.asm
;
; Author:      Brock J. LaMeres, Erik Anderson
;              Montana State University
;
; Date:        10/16/2013
;
; Description: This program will test the speed of instructions by performing various loads/stores 
;              to PortA and PortB for observation with the logic analyzer
;              
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
VAR1        EQU    $50                 ; Unused register for storing DIR data
VAR2        EQU    $51                 ; Unused register for storing DIR data
VAR3        EQU    $52                 ; Unused register for storing DIR data

;***************************************************************************************************
;*** Variable/data memory allocation 
DEFAULT_RAM:SECTION

;***************************************************************************************************
;*** Constant Definitions (ROM memory allocated for each constant)
MyConst:    SECTION
EXT_Data1:  DC.B   $77
EXT_Data2:  DC.B   $88
EXT_Data3:  DC.B   $99
IND_Data1:  DC.B   $AA,$BB,$CC,$00,$00,$00,$00,$00,$00,$00
PADDING10   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING20   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING30   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING40   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING50   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING60   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING70   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING80   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING90   DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING100  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING110  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING120  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING130  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING140  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING150  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING160  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING170  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING180  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING190  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING200  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING210  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING220  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING230  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING240  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING250  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING260  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING270  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING280  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PADDING290  DC.B   $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
IND_Data2:  DC.B   $DD,$EE,$FF

;***************************************************************************************************
;*** Code Section 
MyCode:     SECTION
main:       
_Startup:
Entry:
            LDS    #__SEG_END_SSTACK   ; initialize the stack pointer

            BSET   DDRA, %11111111     ; Set PortA[7:0] to outputs 
            BSET   DDRB, %11111111     ; Set PortB[7:0] to outputs 

            BSET   $40, %11111111      ; configure register $50,$51,$52 so they can be used
                                       ; as fast storate.  NEVER do this!!!

            LDAA   #$44                ; Initialize VAR1-3 with values to be read later.
            STAA   VAR1                ; using direct addressing to addresses $50,$51,$52 

            LDAA   #$55
            STAA   VAR2

            LDAA   #$66
            STAA   VAR3

            LDX    #IND_Data1          ; Point X to the beggining of IND_Data1 in ROM


;************************************************************************************
; The code below continually writes to PortA/B using various addressing modes
                                       
Main_Loop:

; Test 1 = Pattern $11,$22,$33,$11,$22,$33 written to Port A
; LOAD using IMMEDIATE Addressing 
; STORE using DIRECT Addressing
  
            LDAA   #%00000000          ; Initialize PortA and PortB to 0, this will put a known pattern
            STAA   PortA               ; on both ports for easy observation with the logic analyzer
            STAA   PortB

            LDAA   #$11                
            STAA   PortA                

            LDAA   #$22                 
            STAA   PortA                

            LDAA   #$33                 
            STAA   PortA                

            LDAA   #$11                
            STAA   PortA                

            LDAA   #$22                 
            STAA   PortA                

            LDAA   #$33                 
            STAA   PortA                


; Test 2 = Pattern $44,$55,$66,$44,$55,$66 written to Port B
; LOAD using DIRECT Addressing
; STORE using DIRECT Addressing  

            LDAA   #%00000000          ; Initialize PortA and PortB to 0, this will put a known pattern
            STAA   PortA               ; on both ports for easy observation with the logic analyzer
            STAA   PortB

            LDAA   VAR1                
            STAA   PortB                

            LDAA   VAR2                
            STAA   PortB                

            LDAA   VAR3                
            STAA   PortB                

            LDAA   VAR1                
            STAA   PortB                

            LDAA   VAR2                
            STAA   PortB                

            LDAA   VAR3                
            STAA   PortB                

; Test 3  = Pattern $77,$88,$99,$77,$88,$99 written to Port A
; LOAD using EXTENDED Addressing 
; STORE using DIRECT Addressing 

            LDAA   #%00000000          ; Initialize PortA and PortB to 0, this will put a known pattern
            STAA   PortA               ; on both ports for easy observation with the logic analyzer
            STAA   PortB

            LDAA   EXT_Data1                
            STAA   PortA                

            LDAA   EXT_Data2                 
            STAA   PortA                

            LDAA   EXT_Data3             
            STAA   PortA                

            LDAA   EXT_Data1                
            STAA   PortA                

            LDAA   EXT_Data2                 
            STAA   PortA                

            LDAA   EXT_Data3             
            STAA   PortA                


; Test 4 = Pattern $AA,$BB,$CC,$AA,$BB,$CC written to Port B
; LOAD using INDEXED Addressing w 5-bit offset 
; STORE using DIRECT Addressing  

            LDAA   #%00000000          ; Initialize PortA and PortB to 0, this will put a known pattern
            STAA   PortA               ; on both ports for easy observation with the logic analyzer
            STAA   PortB

            LDAA   0,X                
            STAA   PortB                

            LDAA   1,X                
            STAA   PortB           

            LDAA   2,X                
            STAA   PortB                

            LDAA   0,X                
            STAA   PortB                

            LDAA   1,X                
            STAA   PortB                

            LDAA   2,X                
            STAA   PortB 

; Test 5 = Pattern $DD,$EE,$FF,$DD,$EE,$FF written to Port A
; LOAD using INDEXED Addressing w 9-bit offset
; STORE using DIRECT Addressing  

            LDAA   #%00000000          ; Initialize PortA and PortB to 0, this will put a known pattern
            STAA   PortA               ; on both ports for easy observation with the logic analyzer
            STAA   PortB

            LDAA   300,X                
            STAA   PortA

            LDAA   301,X                
            STAA   PortA           

            LDAA   302,X                
            STAA   PortA                

            LDAA   300,X                
            STAA   PortA                

            LDAA   301,X                
            STAA   PortA                

            LDAA   302,X                
            STAA   PortA 


            JMP    Main_Loop           ; Loop Forever, need to use JMP since the Main_Loop
                                       ; label is too far away


;************************************************************************************
