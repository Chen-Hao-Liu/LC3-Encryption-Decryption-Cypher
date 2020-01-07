.ORIG x3000

BRnzp		 Main      ;Skip over to Main
;=============================================================================
;Labels Section. There are many label sections spread throughout the code to
;accomodate for the "labels too far away" errors.
;=============================================================================
Instruction       .STRINGZ  "\nENTER: E TO ENCRYPT, D TO DECRYPT, X TO EXIT: "
Invalid           .STRINGZ  "\nINVALID ENTRY, PLEASE TRY AGAIN"
TempMessage       .FILL     x4300
char_E            .FILL #69
char_e            .FILL #101
char_D            .FILL #68
char_d            .FILL #100
char_X            .FILL #88
char_x            .FILL #120
;=============================================================================
Main		  LEA       R0, Greeting 	; Prompts
		  PUTS	    	         	; Display Greeting message in the console

                  LD        R1, lastAddress     ; First initialize lastAddress
                  LD        R2, MESSAGE         ; to the MESSAGE
	          STR       R2, R1, #0          ; MESSAGE pointer 
                  
while		  LEA 	    R0, Instruction     ; Prompts
                  PUTS                          ; Display menu choices for users to select
		  
		  GETC			        ; Aquire input
                  OUT			        ; Echo it
        
        	  LD  	    R1, char_E          ; Load ASCII code of char 'E' into R1
         	  NOT	    R1, R1
        	  ADD 	    R1, R1, #1          ; 2's complement of R1
        	  ADD 	    R2, R0, R1          ; R2 = R0 - R1
        	  BRz 	    Encrypt        
        
          	  LD 	    R1, char_e          ; Load ASCII code of char 'e' into R1
        	  NOT 	    R1, R1
        	  ADD 	    R1, R1, #1          ; 2's complement of R1
        	  ADD 	    R2, R0, R1          ; R2 = R0 - R1
        	  BRz 	    Encrypt        

      		  LD 	    R1, char_D          ; Load ASCII code of char 'D' into R1
        	  NOT 	    R1, R1
        	  ADD 	    R1, R1, #1          ; 2's complement of R1
        	  ADD 	    R2, R0, R1          ; R2 = R0 - R1
        	  BRz 	    Decrypt   

 	          LD 	    R1, char_d          ; Load ASCII code of char 'd' into R1
        	  NOT 	    R1, R1
        	  ADD 	    R1, R1, #1          ; 2's complement of R1
        	  ADD 	    R2, R0, R1          ; R2 = R0 - R1
        	  BRz 	    Decrypt  

	          LD 	    R1, char_X          ; Load ASCII code of char 'X' into R1
	          NOT 	    R1, R1
       		  ADD 	    R1, R1, #1          ; 2's complement of R1
       	 	  ADD 	    R2, R0, R1          ; R2 = R0 - R1
        	  BRz 	    DONE

      	 	  LD 	    R1, char_x          ; Load ASCII code of char 'x' into R1
       	          NOT 	    R1, R1
        	  ADD 	    R1, R1, #1          ; 2's complement of R1
                  ADD 	    R2, R0, R1          ; R2 = R0 - R1
        	  BRz 	    DONE
        
        	  LEA 	    R0, Invalid
        	  PUTS                          ; Display Invalid then loop back 
        	  BRnzp     while               ; Loops back to front

Encrypt           JSR       CollectKey          ; Collect the input key from user
                  JSR       CollectText  	; Collect the 10 character max string from user

                  JSR       Caesar              ; Encrypt, after we have successfully collected key and string
		  JSR       Vigenere            ; Encrypt Vig after Caesar
		  JSR       Shift               ; Encrypt Shift after Vig
                  BRnzp     while

Decrypt           LD        R0, lastAddress     ; Temporarily store lastAddress for CollectText
                  LD        R3, tempLastAddress ; so that CollectKey, which
                  LDR       R1, R0, #0          ; also uses lastAddress
                  STR       R1, R3, #0          ; does not overwrite it

                  JSR       CollectKey          ; Collect the input key from user
       		  
                  LD        R0, tempLastAddress ; Restore the lastAddress
                  LD        R3, lastAddress     ; after JSR CollectKey
                  LDR       R1, R0, #0          ; from tempLastAddress
                  STR       R1, R3, #0          ; into lastAddress                 

		  LD        R2, MESSAGE  	; Acquire the pointer of MESSAGE String
                  NOT       R2, R2       	; Acquire two's complement
                  ADD       R2, R2, #1   	; of R2
                  LD        R6, lastAddress	; LD the last address of the
                  LDR       R6, R6, #0          ; 10-character-max string into R6
                  ADD       R6, R6, R2          ; Subtract in order to get the counter for the cypher

		  LD        R1, MESSAGE         ; Temporarily store original MESSAGE
                  LD        R2,	TempMessage     ; into TempMessage just in case key is wrong
	
copyLoop 	  LDR       R0, R1, #0          ; Copy over 
                  STR       R0, R2, #0          ; to TempMessage

		  ADD       R1, R1, #1          ; Increment MESSAGE pointer
		  ADD       R2, R2, #1          ; Increment TempMessage pointer
                  ADD       R6, R6, #-1         ; Decrement counter
                  BRp       copyLoop            ; Loop until zero

		  JSR       sDecrypt            ; Decrypt, testing
		  JSR       Vigenere            ; Decrypt, testing
	          JSR       cDecrypt            ; Decrypt, testing

		  LD        R2, MESSAGE  	; Acquire the pointer of MESSAGE String
                  NOT       R2, R2       	; Acquire two's complement
                  ADD       R2, R2, #1   	; of R2
                  LD        R6, lastAddress	; LD the last address of the
                  LDR       R6, R6, #0          ; 10-character-max string into R6
                  ADD       R6, R6, R2          ; Subtract in order to get the counter for the cypher

		  LD        R1, TempMessage     ; Restore original MESSAGE
                  LD        R2,	MESSAGE         ; by copying over from TempMessage
	
copyBack 	  LDR       R0, R1, #0          ; Copy over 
                  STR       R0, R2, #0          ; to MESSAGE

		  ADD       R1, R1, #1          ; Increment TempMessage pointer
		  ADD       R2, R2, #1          ; Increment MESSAGE pointer
                  ADD       R6, R6, #-1         ; Decrement counter
                  BRp       copyBack            ; Loop until zero

		  BRnzp     while

DONE              LD        R1, MESSAGE    ;R1 points to string being generated 
  
		  AND       R3, R3, #0     ;Set R3 to 0 
                  STR       R3, R1, #0     ;Clear MESSAGE Char 0
                  STR       R3, R1, #1     ;Clear MESSAGE Char 1
                  STR       R3, R1, #2     ;Clear MESSAGE Char 2
                  STR       R3, R1, #3     ;Clear MESSAGE Char 3
                  STR       R3, R1, #4     ;Clear MESSAGE Char 4
                  STR       R3, R1, #5     ;Clear MESSAGE Char 5
                  STR       R3, R1, #6     ;Clear MESSAGE Char 6
                  STR       R3, R1, #7     ;Clear MESSAGE Char 7
                  STR       R3, R1, #8     ;Clear MESSAGE Char 8
                  STR       R3, R1, #9     ;Clear MESSAGE Char 9  
		  HALT                     ; Stop the program
;=============================================================================
;Labels Section
;=============================================================================
tempLastAddress   .FILL     x4200
Greeting          .STRINGZ  "Starting Privacy Module!\n"
N                 .FILL     #128
printCaesar       .STRINGZ  "\nAfter Caesar Encryption: "
printVig          .STRINGZ  "\nAfter Vigenere Encryption/Decryption: "
lastAddress       .FILL     x4110
MESSAGE  	  .FILL     x4000	
printShift        .STRINGZ  "\nAfter Encryption: "
printCDecrypt     .STRINGZ  "\nAfter Decryption: "
printSDecrypt     .STRINGZ  "\nAfter Shift Decryption: "
;=============================================================================
;Caesar cipher: Performs modulo N operations on the user entered string  
;=============================================================================
Caesar   	  LD        R1, return_AddressA ; Temporary address storage
   		  STR       R7, R1, #0		; Stores return address
                  
		  LD        R2, MESSAGE  	; Acquire the pointer of MESSAGE String
                  NOT       R2, R2       	; Acquire two's complement
                  ADD       R2, R2, #1   	; of R2
                  LD        R6, lastAddress	; LD the last address of the
                  LDR       R6, R6, #0          ; 10-character-max string into R6
                  ADD       R6, R6, R2          ; Subtract in order to get the counter for the cypher

                  LD        R4, MESSAGE         ; Acquire the pointer of MESSAGE String again

                  LD        R5, yValue          ; Acquire the
                  LDR       R5, R5, #0          ; yValue (K) from the input key and load into R5

		  LD        R1, N               ; Load N (128), into R1
                 
                  ;LEA       R0, printCaesar 	; Display
		  ;PUTS	    	         	; Caesar Encryption

caesarLoop        LDR       R0, R4, #0          ; Load the first character ascii value into R0
                  ADD       R0, R0, R5          ; ADD K to the ascii value
		  JSR       MODULO              ; Call MODULO for Caesar Cypher, result is stored in R2  
                  STR       R2, R4, #0          ; Store encrypted char                  
                  
                  ;ADD       R0, R2, #0          ; R0 = R2
                  ;PUTC                          ; to print out onto screen

                  ADD       R4, R4, #1          ; Increment MESSAGE pointer
                  ADD       R6, R6, #-1         ; Decrement counter
                  BRp       caesarLoop          ; Loop until zero
               
                  LD        R1, return_AddressA ; Restore the
   		  LDR       R7, R1, #0		; return address to R7
                
                  RET		
;=============================================================================
;Vigenere Cypher: Performs bitwise XOR operations on the MESSAGE characters 
;after the Caesar Cypher operations
;Also serves as the decrypt method. Decrypting is simply 
;encrypted char XOR key (K)
;=============================================================================
Vigenere   	  LD        R1, return_AddressA ; Temporary address storage
   		  STR       R7, R1, #0		; Stores return address
                  
		  LD        R2, MESSAGE  	; Acquire the pointer of MESSAGE String
                  NOT       R2, R2       	; Acquire two's complement
                  ADD       R2, R2, #1   	; of R2
                  LD        R6, lastAddress	; LD the last address of the
                  LDR       R6, R6, #0          ; 10-character-max string into R6
                  ADD       R6, R6, R2          ; Subtract in order to get the counter for the cypher

                  LD        R4, MESSAGE         ; Acquire the pointer of MESSAGE String again

                  LEA	    R1, ASCIIBUFF       ; Acquire from key
                  ADD       R1, R1, #1          ; K = x1 (non digit character)
		  LDR       R1, R1, #0          ; Load K (x1), into R1

		  ;LEA       R0, printVig 	; Display
		  ;PUTS	    	         	; Vigenere Encryption
                  
vigLoop           LDR       R0, R4, #0          ; Load the first character ascii value into R0 
                  JSR       XOR                 ; Call XOR
                  STR       R2, R4, #0          ; Store encrypted char  
	
		  ;ADD       R0, R2, #0          ; R0 = R2
                  ;PUTC                          ; to print out onto screen                

                  ADD       R4, R4, #1          ; Increment MESSAGE pointer
                  ADD       R6, R6, #-1         ; Decrement counter
                  BRp       vigLoop             ; Loop until zero
               
                  LD        R1, return_AddressA ; Restore the
   		  LDR       R7, R1, #0		; return address to R7
                
                  RET
;=============================================================================
;Shift Cypher: Performs a left shift based on the key K (z1)
;=============================================================================
Shift   	  LD        R1, return_AddressA ; Temporary address storage
   		  STR       R7, R1, #0		; Stores return address
                  
		  LD        R2, MESSAGE  	; Acquire the pointer of MESSAGE String
                  NOT       R2, R2       	; Acquire two's complement
                  ADD       R2, R2, #1   	; of R2
                  LD        R6, lastAddress	; LD the last address of the
                  LDR       R6, R6, #0          ; 10-character-max string into R6
                  ADD       R6, R6, R2          ; Subtract in order to get the counter for the cypher

                  LD        R4, MESSAGE         ; Acquire the pointer of MESSAGE String again

                  LEA	    R1, ASCIIBUFF       ; Acquire from key
		  LDR       R1, R1, #0          ; Load K (z1), into R1
		  LD        R3, NegASCIIOffset  ; Acquire negative offset
                  ADD       R1, R1, R3          ; Acquire actual digit by adding NegASCIIOffset
	
		  LEA       R0, printShift 	; Display
		  PUTS	    	         	; Shift Encryption
                  
shiftLoop         LDR       R0, R4, #0          ; Load the first character ascii value into R0 
                  JSR       Shift_Func          ; Call Shift_Func
                  STR       R2, R4, #0          ; Store encrypted char  
	
		  ADD       R0, R2, #0          ; R0 = R2
                  PUTC                          ; to print out onto screen                

                  ADD       R4, R4, #1          ; Increment MESSAGE pointer
                  ADD       R6, R6, #-1         ; Decrement counter
                  BRp       shiftLoop           ; Loop until zero
               
                  LD        R1, return_AddressA ; Restore the
   		  LDR       R7, R1, #0		; return address to R7
                
                  RET
;=============================================================================
;Caesar decrypt:
;Decrypting: If (modResult + N) - key > 127, Original MESSAGE = modResult - key
;=============================================================================
cDecrypt   	  LD        R1, return_AddressA ; Temporary address storage
   		  STR       R7, R1, #0		; Stores return address
                  
		  LD        R2, MESSAGE  	; Acquire the pointer of MESSAGE String
                  NOT       R2, R2       	; Acquire two's complement
                  ADD       R2, R2, #1   	; of R2
                  LD        R6, lastAddress	; LD the last address of the
                  LDR       R6, R6, #0          ; 10-character-max string into R6
                  ADD       R6, R6, R2          ; Subtract in order to get the counter for the cypher

                  LD        R4, MESSAGE         ; Acquire the pointer of MESSAGE String again

                  LD        R5, yValue          ; Acquire the
                  LDR       R5, R5, #0          ; yValue (K) from the input key and load into R5
                  NOT       R5, R5              ; 2's complement
                  ADD       R5, R5, #1          ; of R5 (K)

		  LD        R1, N               ; Load N (128), into R1
                  ADD       R3, R1, #0          ; R3 = 128 
                  NOT       R3, R3              ; 2's complement
                  ADD       R3, R3, #1          ; R3 to get -128
                 
                  LEA       R0, printCDecrypt 	; Display
		  PUTS	    	         	; Caesar Decrypt

cdLoop            LDR       R0, R4, #0          ; Load the first character ascii value into R0
                  ADD       R0, R0, R1          ; ADD R1 to R0
	          ADD       R2, R0, R5          ; Subtract K from R0
                  ADD       R0, R2, R3          ; Subtract 128
                  BRzp      greater             ; Checks to see if greater than 127
	  
storeResult       STR       R2, R4, #0          ; Store encrypted char                  
                  
                  ADD       R0, R2, #0          ; R0 = R2
                  PUTC                          ; to print out onto screen

                  ADD       R4, R4, #1          ; Increment MESSAGE pointer
                  ADD       R6, R6, #-1         ; Decrement counter
                  BRp       cdLoop              ; Loop until zero
               
                  LD        R1, return_AddressA ; Restore the
   		  LDR       R7, R1, #0		; return address to R7
                
                  RET

greater           LDR       R0, R4, #0          ; Reload the character ascii value into R0
                  ADD       R2, R0, R5          ; Subtract key from result to decrypt
                  BRnzp     storeResult         ; Branch back to store result  
;=============================================================================
;Decrypt Shift: Performs a right shift based on the key K (z1)
;=============================================================================
sDecrypt   	  LD        R1, return_AddressA ; Temporary address storage
   		  STR       R7, R1, #0		; Stores return address
                  
		  LD        R2, MESSAGE  	; Acquire the pointer of MESSAGE String
                  NOT       R2, R2       	; Acquire two's complement
                  ADD       R2, R2, #1   	; of R2
                  LD        R6, lastAddress	; LD the last address of the
                  LDR       R6, R6, #0          ; 10-character-max string into R6
                  ADD       R6, R6, R2          ; Subtract in order to get the counter for the cypher

                  LD        R4, MESSAGE         ; Acquire the pointer of MESSAGE String again
	
		  ;LEA       R0, printSDecrypt 	; Display
		  ;PUTS	    	         	; Shift decryption
                  
sdLoop		  LEA	    R1, ASCIIBUFF       ; Acquire from key
		  LDR       R1, R1, #0          ; Load K (z1), into R1
		  LD        R3, NegASCIIOffset  ; Acquire negative offset
                  ADD       R1, R1, R3          ; Acquire actual digit by adding NegASCIIOffset            

		  LDR       R0, R4, #0          ; Load the first character ascii value into R0
                  NOT       R0, R0              ; 2's complement
                  ADD       R0, R0, #1          ; to get negative R0 for comparison purposes later 

                  JSR       sd_Func             ; Call sd_Func
                  STR       R2, R4, #0          ; Store decrypted char  
	
		  ;ADD       R0, R2, #0          ; R0 = R2
                  ;PUTC                          ; to print out onto screen                

                  ADD       R4, R4, #1          ; Increment MESSAGE pointer
                  ADD       R6, R6, #-1         ; Decrement counter
                  BRp       sdLoop              ; Loop until zero
               
                  LD        R1, return_AddressA ; Restore the
   		  LDR       R7, R1, #0		; return address to R7
                
                  RET    

sd_Func           AND       R2, R2, #0          ; Clear R2 (decrypted value stored here)
                  AND       R5, R5, #0          ; Clear R5 (2 incrementer used for division by 2)		  
		  ADD       R0, R0, #0          ; Test if value is already 0
		  BRz       return              
 
divide            ADD       R2, R2, #1          ; Increment R2 everytime 2 will be added to R5
                  ADD       R5, R5, #2          ; ADD 2 until equal to R0
                  ADD       R3, R5, R0          ; Subtract
                  BRnp      divide

                  ADD       R0, R2, #0          ; R0 = R2
                  NOT       R0, R0              ; 2's complement
                  ADD       R0, R0, #1          ; in order to get -R0 
                  
                  ADD       R1, R1, #-1         ; Decrement key counter
		  BRp       sd_Func
                  
return            RET                           ; Return with decrypted value in R2                                                          
;=============================================================================
;Labels Section
;=============================================================================   
TooManyChars     .STRINGZ "Too many characters, please try again\n"
promptInvalid    .STRINGZ "\nInvalid key input, please follow directions and try again!" 
return_AddressA  .FILL    x4100
yValue           .FILL    x4120
ASCIIBUFF      	 .BLKW  6
MESSAGE2         .FILL    x4000 ;A SECOND pointer for MESSAGE because LC3 cannot handle labels being too far away
;=============================================================================
;Collects the max 10-character string to be encrypted/decrypted
;=============================================================================

CollectText	  LD        R1, return_AddressA ; Temporary address storage
   		  STR       R7, R1, #0		; Stores return address
                        
PushChar          LEA       R0, InputMessage    ; Prompt for input key
                  PUTS		  

		  LD        R1, MESSAGE2   ;R1 points to string being generated 
                  LD        R2, MaxLength  ;Keep track of space being used
  
		  AND       R3, R3, #0     ;Set R3 to 0 
                  STR       R3, R1, #0     ;Clear MESSAGE Char 0
                  STR       R3, R1, #1     ;Clear MESSAGE Char 1
                  STR       R3, R1, #2     ;Clear MESSAGE Char 2
                  STR       R3, R1, #3     ;Clear MESSAGE Char 3
                  STR       R3, R1, #4     ;Clear MESSAGE Char 4
                  STR       R3, R1, #5     ;Clear MESSAGE Char 5
                  STR       R3, R1, #6     ;Clear MESSAGE Char 6
                  STR       R3, R1, #7     ;Clear MESSAGE Char 7
                  STR       R3, R1, #8     ;Clear MESSAGE Char 8
                  STR       R3, R1, #9     ;Clear MESSAGE Char 9

CharLoop	  GETC			  ; Aquire input
                  OUT			  ; Echo it
 
                  ADD	    R3, R0, xFFF6 ; Test for carriage return
		  BRz       GoodInput	  ; if carriage return then end of valid input

                  ADD       R2,R2,#-1     ; Still room for more digits
                  BRn       TooLargeInput ; more than 10 digits entered
              
                  STR       R0,R1,#0      ; Store last character read
                  ADD       R1,R1,#1      ; Increment

		  LD        R6,lastAddress2 ; Temporarily
		  STR       R1,R6,#0       ; store last address of R1

                  BRnzp     CharLoop
;
GoodInput         LD        R1, return_AddressA    ; Restore return address to R7
                  LDR       R7, R1, #0                
		  RET
;
TooLargeInput     GETC                    ; Spin until carriage return
                  OUT                     ; Echo
                  ADD       R3,R0,xFFF6
                  BRnp      TooLargeInput

                  LEA       R0,TooManyChars ;Display TooManyDigits Message
                  PUTS

                  BRnzp     PushChar     ;Branch back to PushChar to acquire new inputs
;=============================================================================
;Labels Section
;=============================================================================
NegASCIIOffset    .FILL  xFFD0
InputMessage	  .STRINGZ "\nEnter input plain text of length at most 10. When done press enter: " 
asterix           .FILL  #42
;=============================================================================
;Acquires the 5 character key with error checking
;=============================================================================	

CollectKey	  LD        R1, return_AddressA ; Temporary address storage
   		  STR       R7, R1, #0		; Stores return address
                        
		  LEA       R3, ASCIIBUFF     ;First, clear current key buffer
                  AND       R1, R1, #0        ;Set R1 to 0
                  STR	    R1, R3, #0        ;Clear ASCIIBUFF 0
                  STR	    R1, R3, #1        ;Clear ASCIIBUFF 1
		  STR	    R1, R3, #2        ;Clear ASCIIBUFF 2
		  STR	    R1, R3, #3        ;Clear ASCIIBUFF 3
		  STR	    R1, R3, #4        ;Clear ASCIIBUFF 4 

PushValue         LEA       R0, InputKey  ; Prompt for input key
                  PUTS		

    		  LEA	    R1,ASCIIBUFF  ; R1 points to string being
		  LD        R2,MaxChars   ; generated

ValueLoop         GETC			  ; Aquire input
		  ADD       R6, R0, #0    ; Temporarily transfer to R6
		  LD        R0, asterix	  ; Load asterix ASCII into R0
                  OUT			  ; Echo it
		  ADD       R0, R6, #0    ; Transfer char back to R0
 
                  ADD	    R3, R0, xFFF6 ; Test for carriage return
		  BRnp 	    Continue      ;
                  
                  ADD       R2,R2,#0      ; Test if input length is not 5
                  BRnp      InvalidNoLoop ; Input length less than expected
                  BRz       CheckInput    ; We found a potential valid input 
         
Continue          ADD 	    R2,R2,#-1     ; Still room for more characters
                  BRn       InvalidInput  ; More than 5 chars entered

                  STR       R0,R1,#0     ; Store last character read
                  ADD       R1,R1,#1     ; Increment

                  LD        R6,lastAddress2 ; Temporarily
		  STR       R1,R6,#0       ; store last address of R1
                  
                  BRnzp     ValueLoop     

CheckInput	  LEA       R3, ASCIIBUFF     ;Acquire ASCIIBUFF
                  LD        R4, NegASCIIOffset;LD the ascii offset into R4

		  ;==================================================================
                  ;Check first character of the string for validity
		  ;==================================================================
		  LDR       R1, R3, #0        ;LD first character into R1
                  ADD       R1, R1, R4        ;Acquire the digit
                  BRnz      InvalidNoLoop     ;If not greater than 0, invalid input
                  ADD       R1, R1, #-8       ;Check to see if it's less than 8
                  BRzp      InvalidNoLoop     ;If not less than 8, invalid input
         	  
 		  ;==================================================================
                  ;Check second character of the string for validity
		  ;==================================================================
                  LDR       R1, R3, #1        ;LD second character into R1
                  ADD       R1, R1, R4        ;Acquire the character
                  BRn       cont              ;If less than 0, the char is valid, continue
                  ADD       R1, R1, #-9       ;If less
                  BRnz      InvalidNoLoop     ;than or equal to 9, invalid input     
                  
		  ;==================================================================
                  ;Check third number, fourth, and fifth digits value for valid digits
		  ;Then check that the number is between 0 and 127 inclusive
		  ;==================================================================
cont              LDR       R1, R3, #2        ; LD third character into R1
                  JSR       CheckDigit        ; Check if character is digit
                  
                  LDR       R1, R3, #3        ; LD fourth character into R1
                  JSR       CheckDigit        ; Check if character is digit

		  LDR       R1, R3, #4        ; LD fifth character into R1
                  JSR       CheckDigit        ; Check if character is digit
		  
                  LD        R6,lastAddress2    ; Load lastAddress into R6
                  LDR       R1,R6,#0          ; Obtain address where R1 left off on

		  LEA       R2,ASCIIBUFF      ; Load ASCIIBUFF into R2
                  ADD       R2, R2, #2        ; Increment to the address of y1/y2/y3
                  NOT       R2,R2             ; 2's Complement 
                  ADD       R2,R2,#1          ; of R2
                  ADD       R1,R1,R2          ; R1 now contains no. of char after subtracting R2 from current position
                  JSR       ASCIItoBinary     ; Convert ASCII values to binary  
                  
                  ADD       R1, R0, #0        ; Put R0 into R1
	          LD        R4, upperBound    ; LD the ascii offset into R4
                  ADD       R1, R1, R4        ; If greater than 127
                  BRp       InvalidNoLoop     ; Invalid input 

                  LD        R1, yValue        ; LD yValue address into R1
                  STR       R0, R1, #0        ; Store yValue at that address

                  LD        R1, return_AddressA ; Restore the
   		  LDR       R7, R1, #0		; return address to R7
                  RET                           ; Return now with the proper key inputted by user 
	                    	  
InvalidInput      GETC                        ; Spin until carriage return
                  OUT                         ; Echo
                  ADD       R3,R0,xFFF6
                  BRnp      InvalidInput

InvalidNoLoop     LEA       R0, promptInvalid ; Prompt for invalid input
                  PUTS         

		  LEA       R3, ASCIIBUFF     ;Clear current buffer
                  AND       R1, R1, #0        ;Set R1 to 0
                  STR	    R1, R3, #0        ;Clear ASCIIBUFF 0
                  STR	    R1, R3, #1        ;Clear ASCIIBUFF 1
		  STR	    R1, R3, #2        ;Clear ASCIIBUFF 2
		  STR	    R1, R3, #3        ;Clear ASCIIBUFF 3
		  STR	    R1, R3, #4        ;Clear ASCIIBUFF 4 
 		  BRnzp     PushValue

CheckDigit        ADD       R1, R1, R4        ;Acquire the character
                  BRn       InvalidNoLoop     ;Not a digit, invalid input
                  ADD       R1, R1, #-9       ;If positive after
                  BRp       InvalidNoLoop     ;subtracting 9, invalid input
                  RET                         ;Return if char is valid

;=============================================================================
;Labels Section
;=============================================================================
lastAddress2   .FILL  x4110 ;2nd pointer for lastAddress because LC3 cannot handle labels being too far away
upperBound     .FILL  xFF81
;=============================================================================
;Acquires the decimal value from the ASCII values 
;=============================================================================

ASCIItoBinary  AND    R0,R0,#0      ; R0 will be used for our result 
               ADD    R1,R1,#0      ; Test number of digits.
               BRz    DoneAtoB      ; There are no digits
;
               LD     R3,NegASCIIOffset  ; R3 gets xFFD0, i.e., -x0030
               LEA    R2,ASCIIBUFF
               ADD    R2,R2,#2           ; Increment to the address of y1/y2/y3
               ADD    R2,R2,R1
               ADD    R2,R2,#-1     ; R2 now points to "ones" digit
;              
               LDR    R4,R2,#0      ; R4 <-- "ones" digit
               ADD    R4,R4,R3      ; Strip off the ASCII template
               ADD    R0,R0,R4      ; Add ones contribution
;
               ADD    R1,R1,#-1
               BRz    DoneAtoB      ; The original number had one digit
               ADD    R2,R2,#-1     ; R2  now points to "tens" digit
;
               LDR    R4,R2,#0      ; R4 <-- "tens" digit
               ADD    R4,R4,R3      ; Strip off ASCII  template
               LEA    R5,LookUp10   ; LookUp10 is BASE of tens values
               ADD    R5,R5,R4      ; R5 points to the right tens value
               LDR    R4,R5,#0
               ADD    R0,R0,R4      ; Add tens contribution to total
;
               ADD    R1,R1,#-1
               BRz    DoneAtoB      ; The original number had two digits
               ADD    R2,R2,#-1     ; R2 now points to "hundreds" digit
;        
               LDR    R4,R2,#0      ; R4 <-- "hundreds" digit
               ADD    R4,R4,R3      ; Strip off ASCII template
               LEA    R5,LookUp100  ; LookUp100 is hundreds BASE
               ADD    R5,R5,R4      ; R5 points to hundreds value
               LDR    R4,R5,#0
               ADD    R0,R0,R4      ; Add hundreds contribution to total
;         
DoneAtoB       RET

;=============================================================================
; XOR function for Vigenere Cypher
; R0 = x_Value
; R1 = y_Value
; R2 = results of (x XOR y)
; R3,R5 -> temporary variables
;=============================================================================
XOR  	
  	NOT R5, R1            ; R5 = (NOT y) (Save R1, we will use R1 later)
  	AND R3, R0, R5        ; R3 = ( x AND (NOT y) )

  	NOT R0, R0            ; NOT R0
  	AND R2, R0, R1        ; R2 = ( (NOT x) AND y )
        
        NOT R3, R3            ; NOT R3  
  	NOT R2, R2            ; NOT R2
  	AND R2, R3, R2        ; R2 = ( (NOT R3) AND (NOT R2) )
  	NOT R2, R2            ; NOT R2

        RET   
;=============================================================================
; MODULO function for CAESAR Cypher
; Takes value in R0 and R1 as inputs
; R2 = R0 MODULO R1  
;=============================================================================
MODULO 
    ADD R3, R1, #0   ;Set R3 = R1   
    ADD R2, R0, #0   ;Put previous result in R2
 
    NOT R3, R3       ;2's complement
    ADD R3, R3, #1   ;for subtraction
   
    ADD R0, R0, R3   ;Subtraction

    BRZP MODULO      ;loop when positive or zero. As soon as it hits negative, break from loop
  	    
    RET

;=============================================================================
; Shift function for SHIFT Cypher
; Takes the value in R0 anda R1 as inputs
; Bit-shift R0 left by R1 
; R1 must be greater than 0 and less than 8
;=============================================================================
Shift_Func 
    	ADD R3, R1, #0   ;Set R3 = R1   
    	ADD R2, R0, #0   ;Put original in R2

sLoop   ADD R2, R2, R2   ;Double R2 each shift left   
    	ADD R3, R3, #-1  ;Decrement R3

    	BRp sLoop       ;loop when positive or zero. As soon as it hits negative, break from loop 	    
    	RET
;=============================================================================
;Labels Section
;=============================================================================
MaxLength        .FILL	  x000A
MaxChars         .FILL    x0005
InputKey	 .STRINGZ  "\nENTER KEY (Length 5, non-zero digit less than 8 followed by\n non-numeric character followed by 3 digit number between 0 and 127. When done, press enter.\n *3 digit value MUST be 3 digits, example: 4 = 004): "

LookUp10       .FILL  #0
               .FILL  #10
               .FILL  #20
               .FILL  #30
               .FILL  #40
               .FILL  #50
               .FILL  #60
               .FILL  #70
               .FILL  #80
               .FILL  #90
;
LookUp100      .FILL  #0
               .FILL  #100
               .FILL  #200
               .FILL  #300
               .FILL  #400
               .FILL  #500
               .FILL  #600
               .FILL  #700
               .FILL  #800
               .FILL  #900

DIVIDEND        .FILL    x4170
DIVISOR         .FILL    x4180
Result          .FILL    x4190 ;Result will be in this address	          
.END








