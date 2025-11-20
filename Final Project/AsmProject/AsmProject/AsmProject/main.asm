INCLUDE asmlib.inc

.data
eflags      DWORD   ?    ; stores eflags register value
regNameEAX  BYTE "EAX: ",0 ; label for eax
regNameEBX  BYTE "EBX: ",0 ; label for ebx
regNameECX  BYTE "ECX: ",0 ; label for ecx
regNameEDX  BYTE "EDX: ",0 ; label for edx
regNameESI  BYTE "ESI: ",0 ; label for esi
regNameEDI  BYTE "EDI: ",0 ; label for edi
regNameEBP  BYTE "EBP: ",0 ; label for ebp
regNameESP  BYTE "ESP: ",0 ; label for esp
regNameEIP  BYTE "EIP: ",0 ; label for eip
regNameEFL  BYTE "EFL: ",0 ; label for eflags
tabStr      BYTE "    ",0   ; tab spacing string

flagStr BYTE "  XX=",0   ; template string to display individual flag name and value
flagVal BYTE ?,0         ; stores flag value as character '0' or '1'

.code

tab MACRO
    mov edx, OFFSET tabStr         ; move address of tab string to edx
    call WriteString               ; print the tab string
ENDM

; I was facing errors with the one supplied so here is a modified version of the showflag macro
; instead of taking a flag name, it uses a patchable string (flagStr)
; each call should update flagStr+2 and flagStr+3 to show the flag name

ShowFlag MACRO shiftCount
    LOCAL L1
    push eax                       ; save eax
    push edx                       ; save edx

    mov  eax, eflags               ; load eflags value into eax
    mov  flagVal, '1'              ; assume flag is set
    shr  eax, shiftCount           ; shift flag into carry
    jc   L1                        ; if carry is set, skip setting to '0'
    mov  flagVal, '0'              ; set flagVal to '0' if carry not set
L1:
    mov  edx, OFFSET flagStr       ; set edx to flag string address
    call WriteString               ; print flag label
    mov  al, flagVal               ; move flag value to al
    call WriteChar                 ; print '0' or '1'

    pop  edx                       ; restore edx
    pop  eax                       ; restore eax
ENDM

showRegister PROTO regName:PTR BYTE, regValue:DWORD

dumpRegisters PROC
    pushad                         ; save all general-purpose registers
    pushfd                         ; push flags to stack
    pop eax                        ; pop into eax
    mov eflags, eax                ; store flags in eflags variable

    lea esi, [esp]                 ; point esi to current stack location

    ; display general-purpose registers
    mov eax, [esi+28]              ; load saved eax
    invoke showRegister, OFFSET regNameEAX, eax
    tab
    mov eax, [esi+16]              ; load saved ebx
    invoke showRegister, OFFSET regNameEBX, eax
    tab
    mov eax, [esi+24]              ; load saved ecx
    invoke showRegister, OFFSET regNameECX, eax
    tab
    mov eax, [esi+20]              ; load saved edx
    invoke showRegister, OFFSET regNameEDX, eax
    endl

    ; display index and base pointer registers
    mov eax, [esi+4]               ; load saved esi
    invoke showRegister, OFFSET regNameESI, eax
    tab
    mov eax, [esi+0]               ; load saved edi
    invoke showRegister, OFFSET regNameEDI, eax
    tab
    mov eax, [esi+8]               ; load saved ebp
    invoke showRegister, OFFSET regNameEBP, eax
    tab
    mov eax, [esi+12]              ; load saved esp
    invoke showRegister, OFFSET regNameESP, eax
    endl

    ; display instruction pointer and eflags
    mov eax, [esi+32]              ; approximate return address (eip)
    invoke showRegister, OFFSET regNameEIP, eax
    tab
    mov eax, eflags                ; get saved eflags
    invoke showRegister, OFFSET regNameEFL, eax
    tab

    ; manually update flagStr for each flag and display it
    mov byte ptr [flagStr+2],'C'   ; label = CF
    mov byte ptr [flagStr+3],'F'
    ShowFlag 0                     ; show carry flag

    mov byte ptr [flagStr+2],'S'   ; label = SF
    mov byte ptr [flagStr+3],'F'
    ShowFlag 7                     ; show sign flag

    mov byte ptr [flagStr+2],'Z'   ; label = ZF
    mov byte ptr [flagStr+3],'F'
    ShowFlag 6                     ; show zero flag

    mov byte ptr [flagStr+2],'O'   ; label = OF
    mov byte ptr [flagStr+3],'F'
    ShowFlag 11                    ; show overflow flag

    mov byte ptr [flagStr+2],'A'   ; label = AF
    mov byte ptr [flagStr+3],'F'
    ShowFlag 4                     ; show auxiliary carry flag

    mov byte ptr [flagStr+2],'P'   ; label = PF
    mov byte ptr [flagStr+3],'F'
    ShowFlag 2                     ; show parity flag

    endl

    popad                          ; restore all general-purpose registers
    ret
dumpRegisters ENDP

showRegister PROC regName:PTR BYTE, regValue:DWORD
    push eax                       ; save eax
    push edx                       ; save edx
    mov edx, regName               ; load address of register name
    call WriteString               ; print the name
    mov eax, regValue              ; load the value
    call WriteHex                  ; print value in hex
    pop edx                        ; restore edx
    pop eax                        ; restore eax
    ret
showRegister ENDP

main PROC
    call dumpRegisters
    exit
main ENDP

END main
