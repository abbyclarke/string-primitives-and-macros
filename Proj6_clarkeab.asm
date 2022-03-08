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
; Receives: prompt (Offset of a prompt), userString (offset of empty string), size (length of string- input value), bytesRead 
;
; Returns:
; -------------------------------------------------------------------
mGetString	MACRO prompt, userString, size, bytesRead
  push	EAX
  push	ECX
  push	EDX
  push	EDI
  
  mov	EDX, OFFSET prompt
  call	WriteString
  mov	ECX, size
  mov	EDX, OFFSET userString
  call	ReadString
  mov	EDI, OFFSET bytesRead
  mov	[EDI], ECX

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

  mov	EDX, OFFSET printString
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


; (insert variable definitions here)

.code
main PROC
  
  mGetString	prompt1, string1, sMax, sLength
  call	CrLf
  mDisplayString	string1	

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
