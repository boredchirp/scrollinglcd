;sfr P0 = 0x80     ; Port 0
;sfr P1 = 0x90     ; Port 1
;sfr P2 = 0xA0     ; Port 2
;sfr P3 = 0xB0     ; Port 3

sbit rs = P3^5    ; Register select (RS)
sbit en = P3^6    ; Enable (EN) pin
sbit rw = P3^7    ; Read write (RW) pin

text:   db "sanika and team's project        ", 0

delay:  mov r2, #20         ; Outer loop counter
delay_outer:
        mov r1, #250       ; Inner loop counter
delay_inner:
        nop                ; 1 cycle delay
        nop
        nop
        nop
        djnz r1, delay_inner
        djnz r2, delay_outer
        ret

; Function to send values to the command register of LCD
lcdcmd:
        mov P1, a          ; Send value to Port 1
        clr rs             ; RS = 0 (Command mode)
        clr rw             ; RW = 0 (Write mode)
        setb en            ; Enable LCD
        call delay
        clr en             ; Disable LCD
        ret

; Function to send values to the data register of LCD
display:
        mov P1, a          ; Send value to Port 1
        setb rs            ; RS = 1 (Data mode)
        clr rw             ; RW = 0 (Write mode)
        setb en            ; Enable LCD
        call delay
        clr en             ; Disable LCD
        ret

; Function to initialize the LCD
lcdint:
        mov P1, #0          ; Initialize Port 1
        mov P3, #0x03       ; Initialize Port 3
        call delay
        mov a, #0x30
        call display        ; Display initialization command 1
        mov a, #0x30
        call display        ; Display initialization command 2
        mov a, #0x30
        call display        ; Display initialization command 3
        mov a, #0x38
        call lcdcmd         ; Set function mode: 2 lines, 5x8 font
        mov a, #0x0F
        call lcdcmd         ; Display on, cursor blinking
        mov a, #0x01
        call lcdcmd         ; Clear display
        mov a, #0x06
        call lcdcmd         ; Entry mode, auto-increment cursor
        mov a, #0x8F
        call lcdcmd         ; Set DDRAM address
        ret

main:
        mov dptr, #text     ; Load address of text into DPTR
        mov r7, #0          ; Initialize index register
loop:
        movx a, @dptr       ; Load character from text
        jz end_loop         ; If character is null, end loop
        call display        ; Display character
        call delay          ; Delay
        mov a, #0x18
        call lcdcmd         ; Shift display left
        call delay          ; Delay
        inc dptr            ; Increment data pointer
        inc r7              ; Increment index
        sjmp loop           ; Repeat loop
end_loop:
        sjmp $              ; End of program
end