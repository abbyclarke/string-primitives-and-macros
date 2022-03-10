TITLE String Primitives and Macros     (Proj6_clarkeab.asm)

; Author: Abby Clarke 
; Last Modified: 3/7/2022
; OSU email address: clarkeab@oregonstate.edu
; Course number/section:   CS271 Section 02
; Project Number: 6                Due Date: 3/13/2022
; Description: 

INCLUDE Irvine32.inc

; (insert macro definitions here)
; -------------------------------------------------------------------
; Name: mGetString
;
; Description:
;
; Preconditions:
;
; Receives: prompt (Offset of a prompt), userString (offset of empty string), size (length of string- input value), bytesRead (offset)
;
; Returns:
; -------------------------------------------------------------------
mGetString	MACRO prompt, userString, size, bytesRead
  push	EAX
  push	ECX
  push	EDX
  push	EDI
  
  mov	EDX, prompt
  call	WriteString
  mov	ECX, size
  mov	EDX, userString
  call	ReadString
  mov	EDI, bytesRead
  mov	[EDI], EAX

  pop	EDI
  pop	EDX
  pop	ECX
  pop	EAX
ENDM

; -------------------------------------------------------------------
; Name: mDisplayString
;
; Description:
;
; Preconditions:
;
; Receives: printString (Offset of string to be printed)
;
; Returns:
; -------------------------------------------------------------------
mDisplayString	MACRO	printString
  push	EAX
  push	EDX

  mov	EDX, printString
  call	WriteString

  pop EDX
  pop EAX
ENDM

; (insert constant definitions here)

.data
prompt1		BYTE	"Please enter a signed number: ", 0
string1		BYTE	11 DUP(?)
sMax		DWORD	11
sLength		DWORD	?
newInt		SDWORD	?
errorMsg	BYTE	"ERROR: You did not enter a signed number of your number was too big.", 13,10
			BYTE	"Please try again: ", 0




; (insert variable definitions here)

.code
main PROC
  
  push	OFFSET errorMsg
  push	OFFSET newInt
  push	OFFSET prompt1
  push	OFFSET string1
  push	sMax
  push	OFFSET sLength
  call	ReadVal
  call	CrLf
  mov	EAX, newInt
  call	WriteInt
  
  

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ------------------------------------------------------------
; name: ReadVal

; description: 
;
; preconditions: ebp+8 = Offset sLength, ebp+12 = sMax, ebp+16 = offset string1, ebp+20=offset prompt1, ebp+24=offset newInt,
; ebp+28= offset errorMsg
;
; postconditions: 
;
; receives: 
;
; returns: 
; ---------------------------------------------------------------
ReadVal PROC
  LOCAL	signFlag: DWORD, multiply: DWORD			; 0 for positive, 1 for negative
  push	EAX
  push	EBX
  push	ECX
  push	EDX
  push	EDI
  push	ESI
  mov	signFlag, 0
  mov	multiply, 1									; will increase by 10s
  mGetString	[EBP + 20], [EBP + 16], [EBP + 12], [EBP + 8]
  
_start_over:  
  mov	EDX, [EBP + 8]
  mov	ECX, [EDX]
  mov	ESI, [EBP + 16]
  add	ESI, ECX
  dec	ESI
  mov	EDI, [EBP + 24]
  mov	EAX, 0
  mov	[EDI], EAX
  mov	EBX, multiply

_start_loop:
  STD
  LODSB
  cmp	AL, 48
  jl	_check_sign
  cmp	AL, 57
  jg	_invalid
  sub	AL, 48
  mov	BL, AL
  mov	EAX, 0			;set EAX to 0 to prepare for moving previous contents of AL into EAX to multiply
  movsx	EAX, BL
  mov	EBX, multiply		; multiply by decimal place one, ten, hundred, etc
  mul	EBX
  add	EAX, [EDI]
  mov	[EDI], EAX
 _continue:
  dec	ECX
  cmp	ECX, 0
  je	_switch_sign
  mov	EAX, multiply
  mov	EBX, 10
  mul	EBX
  mov	multiply, EAX
  jmp	_start_loop


_check_sign:
  cmp	ECX, 1
  jne	_invalid
  cmp	AL, 45
  jne	_check_pos
  mov	signFlag, 1
  jmp	_continue

_check_pos:
  cmp	AL, 43
  jne	_invalid
  mov	signFlag, 0
  jmp	_continue

_invalid:
  mGetString	[EBP + 28], [EBP + 16], [EBP + 12], [EBP + 8]
  jmp	_start_over

_switch_sign:
  cmp	signFlag, 0
  je	_done
  mov	EAX, [EDI]
  neg	EAX
  mov	[EDI], EAX

_done:

  pop	ESI
  pop	EDI
  pop	EDX
  pop	ECX
  pop	EBX
  pop	EAX
  ret	24
ReadVal ENDP

; ------------------------------------------------------------
; name: WriteVal
;
; description: 
;
; preconditions: 
;
; postconditions: 
;
; receives: 
;
; returns: 
; ---------------------------------------------------------------
WriteVal PROC
  push	EBP
  mov	EBP, ESP


  pop	EBP
  ret
WriteVal ENDP

END main
