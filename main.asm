; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $0400  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.


; code section
            ORG   ROMStart
_Startup
Entry

;================================================================
; This portion of code signals to the programmer that the program
; has begun.
;================================================================

             LDAA   #$01
             STAA   DDRJ ; Configure PortJ's LSb as output
             STAA   PTJ ; turn on uC LED (PJb0) to show "I'malive!"
             
;================================================================
; Configure PortAD [PT1AD] as gernal purpose I/O
; For ths lab, we will set inputs on b3-b0 and outputs b7-b4.
; Note the lab doesn't require output bits, but by moving your
; read-in bits to the output bits, it is an easy check to see if
; your code is receiving the expected data. 
;================================================================
             LDD    #$000F
             STD    ATDDIEN ;Configure PT1AD3-PT1AD0 as digital Inputfor toggle switches. (Default is analog for ADC)
             STAB   PER1AD ;Enable internal pull up resistors to avoidindeterminate state when not connected

             LDAA   #$F0
             STAA   DDR1AD ; set b7-b4 as digital output pins
                           ; set b3-b0 as digital input pins
                                  
                         
LOOP         LDAA   PTI1AD ; load A with toggle switch values (readfrom PortAD Input Buffer)

             CMPA   #$F0
             BEQ    led_off
             CMPA   #$F8
             BEQ    led_25
             CMPA   #$FC
             BEQ    led_50
             CMPA   #$FE
             BEQ    led_75
             CMPA   #$FF
             JMP    led_on
            

led_off      LDAA   #$00

             STAA   PTJ
             JMP    LOOP
             
;The following segment is 25% duty cycle
;Assuming an E-clock f = 6.25MHz (T = 160ns), each iteration is 6*160ns =960ns = 0.96us
led_25       LDAA   #$01
             STAA   PTJ
             LDY    #10 ; 10 * .025s = 0.25s
LOOPON_OUT   LDX    #9766 ; 25000 us in 25ms
LOOPON_IN    NOP

             NOP
             NOP
             
             dbne x,LOOPON_IN ; 3 E cycles
             dbne y,LOOPON_OUT ; 3 E cycles
             
;This segment will turn OFF the EsduinoXtreme's onboard LED
             LDAB #$00
             STAB PTJ


             LDY    #10 ; 10 * .075s = 0.75s
LOOPOFF_OUT1 LDX    #29297 ; 75000us in 75ms
LOOPOFF_IN1  NOP ; 1 E cycle
             NOP
             NOP
             dbne x,LOOPOFF_IN1 ; 3 E cycles
             dbne y,LOOPOFF_OUT1 ; 3 E cycles

             JMP LOOP



;The following segment is 50% duty cycle
;Assuming an E-clock f = 6.25MHz (T = 160ns), each iteration is 6*160ns =960ns = 0.96us

led_50       LDAA #$01
             STAA PTJ
             LDY #10 ; 10 * .05s = 0.5s
LOOPON_OUT2  LDX #52083 ; 50000 us in 50ms (0.05s)
LOOPON_IN2   NOP
             NOP
             NOP
             dbne x,LOOPON_IN2 ; 3 E cycles
             dbne y,LOOPON_OUT2 ; 3 E cycles
             
;This segment will turn OFF the EsduinoXtreme's onboard LED
             LDAB #$00
             STAB PTJ


             LDY #10 ; 10 * .05s = 0.5s
LOOPOFF_OUT3 LDX #52083 ; 50000us in 50ms (0.05s)
LOOPOFF_IN3  NOP ; 1 E cycle
             NOP
             NOP
             dbne x,LOOPOFF_IN3 ; 3 E cycles
             dbne y,LOOPOFF_OUT3 ; 3 E cycles

             JMP LOOP




;The following segment is a 75% duty cycle
;Assuming an E-clock f = 6.25MHz (T = 160ns), each iteration is 6*160ns =960ns = 0.96us

led_75       LDAA #$01
             STAA PTJ
             LDY #10 ; 10 * .075s = 0.75s
LOOPON_OUT4  LDX #29297 ; 75000 us in 75ms
LOOPON_IN4   NOP
             NOP
             NOP
             dbne x,LOOPON_IN4 ; 3 E cycles
             dbne y,LOOPON_OUT4 ; 3 E cycles
             
;This segment will turn OFF the EsduinoXtreme's onboard LED
             LDAB #$00
             STAB PTJ


             LDY #10 ; 10 * .025s = 0.25s
LOOPOFF_OUT5 LDX #9766 ; 25000us in 25ms
LOOPOFF_IN5  NOP ; 1 E cycle
             NOP
             NOP
             dbne x,LOOPOFF_IN5 ; 3 E cycles
             dbne y,LOOPOFF_OUT5 ; 3 E cycles

             JMP LOOP

led_on       LDAA #$01
 STAA        PTJ


             STAA PT1AD ; save input switch values to outputpins/LEDS
             JMP LOOP ; forever
             
;**************************************************************
;*                    Interrupt Vectors                       *
;**************************************************************
 ORG $FFFE
 DC.W Entry ; Reset Vector
