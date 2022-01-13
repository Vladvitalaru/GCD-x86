;Vlad Vitalaru
;GCD CS 261 - Paul Bonamy

global readNumber, makeDecimal, gcd, getInt

SECTION .data

	UserPrompt: db	"Enter a positive integer: ", 0 ;defines sequence of bites, forming a string 
	upLength: equ $-UserPrompt 						;length of UserPrompt

	AnswerPrompt: db "Greatest Common divisor = ", 0 ;defines sequence of bites, forming a string 
	apLength: equ $-AnswerPrompt

	newLine: db 10			;newline character
	nlLength: equ $-newLine

	error: db "Bad Number ", 10
	eLength: equ $-error


SECTION .bss

	words: equ 20 		;Length of words
	buffer: resb words  ;buffer for words
	character: resb 20	;allocating bites
	n: resb 20 			;allocating bites for n
	m: resb 20			;allocating bites for m
	answer: resb 20		;allocating bites for answer
	result: resb 20		;allocating bites for result
	temp: resb 20 		;allocating bites for temp

SECTION .text

global _start
	restart:
	call readNumber 		;get n from user by calling readNumber
	mov [n], eax 	     

	call readNumber 		;get m from user by calling readNumber
	mov [m], eax 		

	mov eax, [n] 			;move into register 
	push eax 				;push onto stack

	mov edx, [m] 			;move into register 
	push edx 				;push onto stack

		
	call gcd 				;call gcd
	mov [answer], eax 		;move answer into memory
	add esp, 8				;restore pointer

	mov eax, 0x4			;4 is print
	mov ebx, 1				;to standard out (1)
	mov ecx, AnswerPrompt   ;ecx gets the adress of AnswerPrompt
	mov edx, apLength 		;edx holds length of prompted message
	int 80H					;interrupt and syscall

	mov eax, [answer] 		;move answer back into register
	push eax 				;push onto stack
	call makeDecimal

	mov eax, 0x4			;4 is print
	mov ebx, 1				;to standard out (1)
	mov ecx, newLine  		;ecx gets the adress of newLine
	mov edx, nlLength 		;edx holds length of prompted message
	int 80H			

	mov eax, 1 				;exit program syscall
	mov ebx, 0
	int 80H



readNumber: 		;procedure that takes integer input from user 

	push ebp 	 	;set up standard stack frame
	mov ebp, esp

	push ebx		;push registers which are used onto stack
	push ecx
	push edx

	mov eax, 0x4		;4 is print
	mov ebx, 1			;to standard out (1)
	mov ecx, UserPrompt ;ecx gets the adress of UserPrompt
	mov edx, upLength 	;edx holds length of prompted message
	int 80H				;interrupt and syscall

	mov eax, 0x3 		;3 is read
	mov ebx, 0			;from standard input (0)
	mov ecx, buffer 	;into input buffer
	mov edx, 20			;20 bytes
	int 80H				;interrupt and syscall

	mov eax, buffer 	;move number into eax, the return register

	;pop the registers after work is done
	pop edx
	pop ecx
	pop ebx

	push eax 			;push number held in eax register onto stack
	call getInt			

	leave 				;break down stack frame

	ret 				;return

makeDecimal:

	push ebp			;set up standard stack frame
	mov ebp, esp

	push ebx			;push registers which are used onto stack
	push ecx
	push edx

	mov edx, 0 			;need to clear edx first
	mov eax, [ebp+8] 	;offset base pointer
	mov ecx, 0xa 		;move 10 into ecx to become operand
	div ecx				;div eax by ecx

	cmp eax, 0x0 		;compare the quotient to 0
	jle jump          	;if eax <= 0, jump over recursion call


	push eax 			;push recursion paramter onto stack
	call makeDecimal 	;call makeDecimal to initiate recursion 
	add esp, 4

	jump:				;continue from here if eax <= 0
	add edx, '0'		;convert remainder into character
	mov [character],edx ;store character in allocated memory

	mov eax, 0x4		;print syscall
	mov ebx, 1	 		;to standard out (1)
	mov ecx, character 	;print out character
	mov edx, 20			;20 bytes
	int 0x80			;interrupt and syscall

	;pop the registers after work is done
	pop edx
	pop ecx
	pop ebx

	leave				;break down stack frame

	ret 				;return


gcd:

	push ebp 	 		;set up standard stack frame
	mov ebp, esp		

	mov eax, [ebp+8] 	;load n into eax from memory
	mov edx, [ebp+12] 	;load m into edx from memory
	cmp eax, edx 		;compare to
	ja greater 			;if n > m, jump to greater
	jb less 			;if n < m, jump to less
	jmp continue 		;continue to return


	greater:			;if n > m, begin here

	sub eax, edx		;n - m
	push eax			;push n
	push edx			;push m
	call gcd			;recursion call
	add esp, 8			;restore pointer
	jmp continue		;jump to continue once done


	less:

	sub edx, eax 		;m - n
	push eax			;push n
	push edx			;push m
	call gcd 			;recursion call
	add esp, 8			;restore pointer

	continue:

	leave 				;break down stack frame

	ret 				;return


getInt:

	push ebp 	 		;set up standard stack frame
	mov ebp, esp		

	mov ecx, 0 			;set loop counter register to 0

	mov edx, eax 		;store copy of string in edx
	mov esi, [ebp+8]

	loop:      			
		LODSB 	 		;reads a byte from DS : ESI into AL, then increments ESI
		cmp 	AL, 10 	;sets ZF if AL has a newline 
		jz  	end 	;end loop if newLine is found
		inc 	ecx 	;continue to increment counter if newline is not found
		jmp 	loop 	;jump to loop
	
	end:

	sub esi, 1 			;move esi to obtain valid char
	mov eax, 0 			;reset eax and ebx
	mov ebx, 1
	mov [result], eax


	loop2: 
	mov edx, [ebp+8] 	;move string into edx
	sub esi, 1 			;sub 1 from esi
	cmp esi, edx		;compare esi and edx, jump to return if esi < edx
	jb return
	mov AL, [esi] 		;move character into AL
	cmp AL, '0' 		;if character is less than 0, jump to badNumber
	jb badNumber
	cmp AL, '9' 		;if character is greater than 9, jump to badNumber
	ja badNumber

	sub AL, '0' 		;*digit - '0' instruction
	mov [temp], AL 		;value
	mov eax, [temp] 	;move into register
	mul ebx				;mul by value
	add [result], eax 	;add to result

	mov eax, ebx 	
	mov ecx, 10
	mul ecx

	mov ebx, eax 		;resets ebx to eax

	jmp loop2 			;jumpt to loop2

	badNumber:

	mov eax, 0x4		;4 is print
	mov ebx, 1			;to standard out (1)
	mov ecx, error  	;ecx gets the adress of badNumber
	mov edx, eLength 	;edx holds length of prompted message
	int 80H		

	jmp restart 		;if bad number is given, restart program!


	return: 

	mov eax, [result]
	push eax

	leave 

	ret