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
string1		BYTE	32 DUP(?)
string2		BYTE	32 DUP(?)
listNums	BYTE	32 DUP(?)
sMax		DWORD	32
sLength		DWORD	?
newInt		SDWORD	?
errorMsg	BYTE	"ERROR: You did not enter a signed number of your number was too big.", 13,10
			BYTE	"Please try again: ", 0
counter		DWORD	?
yourNums	BYTE	"You entered the following numbers: ",13,10,0
yourSum		BYTE	"The sum of these numbers is: ",0
numSum		SDWORD	?



; (insert variable definitions here)

.code
main PROC
  
  mov	counter, 4
  mov	EDI, OFFSET listNums
_get10Nums:
  push	OFFSET errorMsg
  push	OFFSET newInt
  push	OFFSET prompt1
  push	OFFSET string1
  push	sMax
  push	OFFSET sLength
  call	ReadVal
;add integer to list of 10 integers from user
  mov	EAX, newInt
  mov	[EDI], EAX
  add	EDI, 4
  dec	counter
  cmp	counter, 0
  jg	_get10Nums



;display the integers  
  mov	EDX, OFFSET yourNums
  call	WriteString
;convert each int in listNums to ascii string
  mov	ESI, OFFSET listNums
  mov	counter, 4
_display10Nums:
  mov	EAX, [ESI]
  mov	newInt, EAX
  push	OFFSET string2
  push	newInt
  call	WriteVal
  mov	AL, 32
  call	WriteChar
  add	ESI, 4
  dec	counter
  cmp	counter, 0
  jg	_display10Nums
  call	CrLf


;calculate the sum
  mov	ESI, OFFSET listNums
  mov	EDI, OFFSET numSum
  mov	counter, 4
  mov	EAX, [ESI]
_sumLoop:
  add	ESI, 4
  mov	EBX, [ESI]
  add	EAX, EBX
  dec	counter
  cmp	counter, 0
  jg	_sumLoop
  mov	[EDI], EAX


;display the sum
  mov	EDX, OFFSET yourSum
  call	WriteString
  push	OFFSET string2
  push	numSum
  call	WriteVal
  call	CrLf

  
  
  
  

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ------------------------------------------------------------
; name: ReadVal

; description: ReadVal uses mGetString maco to get user input in form of a string of digits. It converts the string of 
; ascii digits to its numeric value representation in a SDOWRD. It validates the user's input is a valid number (no letters, symbols)
; and ensures it fits in an SDWORD without overflow.
;
; preconditions: ebp+8 = Offset sLength, ebp+12 = sMax, ebp+16 = offset string1, ebp+20=offset prompt1, ebp+24=offset newInt,
; ebp+28= offset errorMsg
;
; postconditions: newInt value changed. registers preserved.
;
; receives: (listed above) offset sLength, sMax, offset string1, offset prompt1, offset newInt, offset errorMsg
;
; returns: converted value in SDWORD newInt
; ---------------------------------------------------------------
ReadVal PROC
  LOCAL	signFlag: DWORD, multiply: DWORD			; signFlag: 0 for positive, 1 for negative
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
  mov	multiply, 1
  mov	signFlag, 0
  mov	EDX, [EBP + 8]
  mov	ECX, [EDX]
  mov	ESI, [EBP + 16]
  add	ESI, ECX
  dec	ESI
  mov	EDI, [EBP + 24]
  mov	EAX, 0
  mov	[EDI], EAX			;clear newInt 
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
  jc	_invalid			; check if carry flag was set
  add	EAX, [EDI]
  js	_invalid			; check if overflow flag was set
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
  cmp	EAX, -2147483648			; check for edge case- this number is valid
  je	_edge_case
  mGetString	[EBP + 28], [EBP + 16], [EBP + 12], [EBP + 8]
  jmp	_start_over

_switch_sign:
  cmp	signFlag, 0
  je	_done
  mov	EAX, [EDI]
  neg	EAX
  mov	[EDI], EAX
  jmp	_done
  
_edge_case:
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
; preconditions: ebp+8 = value in listNums, ebp+12 = string2
;
; postconditions: 
;
; receives: numeric SDWORD value (listNums)
;
; returns: 
; ---------------------------------------------------------------
WriteVal PROC
  LOCAL	divide: DWORD, quotient: SDWORD, signFlag: DWORD 		; signFlag 0 for positive, 1 for negative
  push	EAX
  push	EBX
  push	ECX
  push	EDX
  push	EDI
  push	ESI
  mov	signFlag, 0
  mov	divide, 10
  mov	ESI, [EBP + 8]
  mov	EDI, [EBP + 12]
  mov	quotient, ESI
  mov	ECX, 1   ;will count the created string, starting at 1 to account for pushed 0 below
  cld

;push a null byte so string will end after correct number of values stored
  mov	EAX, 0
  push	EAX
_saveSign:
  mov	EAX, ESI
  cmp	EAX, 0
  jge	_convertInt
;check if int is negative, set signFlag
  mov	signFlag, 1

_convertInt:
  mov	EAX, quotient
  cdq
  mov	EBX, divide
  idiv	EBX
;save quotient for next division
  mov	quotient, EAX
;check if remainder is negative and neg
  mov	EAX, EDX
  cmp	EAX, 0
  jge	_toAscii
  neg	EAX
;convert remainder to ascii by adding 48
_toAscii:
  add	EAX, 48
  push	EAX			;save in register
  inc	ECX
;check if quotient is zero (number is done), if not continue loop
  mov	EAX, quotient
  cmp	EAX, 0
  jne	_convertInt

;check if we need to add a negative sign
  cmp	signFlag, 1
  jne	_popAscii
  mov	EAX, 45
  STOSB
  

;add values to string list
_popAscii:  
  pop	EAX
  STOSB
  dec	ECX
  cmp	ECX, 0
  jg	_popAscii

  mDisplayString	[EBP + 12]

  pop	ESI
  pop	EDI
  pop	EDX
  pop	ECX
  pop	EBX
  pop	EAX
  ret	4
WriteVal ENDP

END main
