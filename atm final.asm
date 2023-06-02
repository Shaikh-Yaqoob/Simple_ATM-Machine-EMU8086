.MODEL SMALL

.DATA
    ;Account number
    ACC_PROMPT DB 0AH, " Enter your account number: $"
    ACC_WRONG DB 0AH, 0AH, 0DH, " Account number does not exist.$"
    ACC_NUM DB "0123456789$"
    ACC_LEN DW $-(OFFSET ACC_NUM)-1
    ENTERED_ACC_LEN DW 0H
    
    ;Password data
    PWD_PROMPT DB 0AH, 0DH, " Enter your password: $"
    PWD_WRONG DB 0AH, 0AH, 0DH, " Invalid password$"
    PWD DB "test1234$"
    PWD_LEN DW $-(OFFSET PWD)-1
    ENTERED_PWD_LEN DW 0H
       
    ;Menu options
    WEL_MSG DB 0AH, 0AH, 0AH, 0DH, "**************************  Welcome to your account  ***************************$"
    BAL_MENU DB 0AH, 0AH, 0DH, " 1. Check your balance$"
    WITH_MENU DB 0AH, 0DH, " 2. Withdraw money$"
    DEP_MENU DB 0AH, 0DH, " 3. Deposit money$"
    CHANGE_PWD_MENU DB 0AH, 0DH, " 4. Change password$"
    EXIT_MENU DB 0AH, 0DH, " 5. Exit$"
    
    ;Messages
    THANK DB 0AH, 0AH, 0AH, 0DH, "                          Thank you for banking with us!$"
    INVALID DB 0AH, 0AH, 0DH, " Invalid input. Please choose a different option.$"
    CHOOSE DB 0AH, 0AH, 0DH, " Enter option: $"
    SUCCESS DB 0AH, 0AH, 0DH, " Transaction successful$"
    LIM_EXCEED DB 0AH, 0AH, 0DH, " Limit exceeded (Maximum amount = Rs. 5000)$"
       
    ;Balance
    CUR_BAL DW 20000
    CUR_BAL_MSG DB 0AH, 0AH, 0DH, " Current balance = Rs. $"
    
    ;Withdraw
    WITH_PROMPT DB 0AH, 0AH, 0DH, " Enter amount to withdraw: Rs. $"
    WITH_AMT DW 0H 
    BAL_LOW DB 0AH, 0AH, 0DH, " Insufficient balance$"
    
    ;Deposit
    DEP_PROMPT DB 0AH, 0AH, 0DH, " Enter amount to deposit: Rs. $"
    DEP_AMT DW 0H
    
    ;Change password
    REENTER DB 0AH, 0AH, 0DH, " Re-enter your password: $"
    NEW_PWD_PROMPT DB 0AH, 0DH, " Enter new password: $"
    NEW_PWD DB 0AH, 0AH, 0DH, " Password has been changed to $"
    RESTRICT DB 0AH, 0AH, 0DH, " Password restricted to 8 characters.$"
            
    ;Amount options
    ABOVE1000 DB 0AH, 0AH, 0DH, " 1. Rs.1000 - Rs.5000$"
    ABOVE100 DB 0AH, 0DH, " 2. Rs.100 - Rs.999$" 
    MAX_LIM DW 5000
    MIN_LIM DW 100
      
    ;Digit place
    TH DW 1000
    H DB 100
    T DB 10

     
     
.CODE
    
    MAIN PROC
    MOV AX, DATA
    MOV DS, AX
    
    ;Check account number
    LEA SI, ACC_NUM ;Store offset of existing account number in SI
    MOV CX, ACC_LEN ;Loop ACC_LEN times as account number is ACC_LEN characters long
    
    MOV AH, 09H
    LEA DX, ACC_PROMPT
    INT 21H
    
    VERIFY_ACC: MOV AH, 01H
                INT 21H
                    
                CMP AL, 0DH
                JE BREAKA
                    
                INC ENTERED_ACC_LEN
                CMP AL, [SI] ;Compare with actual account number
                JNE SET_ACC_FLAG
                JMP CONTA
                             
                SET_ACC_FLAG: MOV BL, 01H 
                             
                CONTA: INC SI
                JMP VERIFY_ACC 
                
    ;checking acc num                
    BREAKA: CMP CX, ENTERED_ACC_LEN
            JL ACC_FAIL
            JG ACC_FAIL
               
            CMP BL, 01H
            JE ACC_FAIL
            JNE RETURNA
        
    ACC_FAIL: LEA DX, ACC_WRONG
              JMP WRONG 
                                   
    RETURNA:
    
    
    ;Check password
    MOV AH, 09H
    LEA DX, PWD_PROMPT
    INT 21H
    
    CALL CHECK_PWD
    JMP MENU      
    
         
    ;Incorrect verification handling
    WRONG: MOV AH, 09H
           INT 21H
           ;exiting the program
           MOV AH, 4CH
           INT 21H
           
           
           
    ;Display the menu
    MENU: MOV AH, 09H
          LEA DX, WEL_MSG
          INT 21H
          
          MOV AH, 09H
          LEA DX, BAL_MENU
          INT 21H
          
          MOV AH, 09H
          LEA DX, WITH_MENU
          INT 21H
          
          MOV AH, 09H
          LEA DX, DEP_MENU
          INT 21H
          
          MOV AH, 09H
          LEA DX, CHANGE_PWD_MENU
          INT 21H
          
          MOV AH, 09H
          LEA DX, EXIT_MENU
          INT 21H
    
    
    CHOOSE_OPTION:
          
          MOV AH, 09H
          LEA DX, CHOOSE
          INT 21H
    
          
          MOV AH, 01H
          INT 21H
          
          ;Comparing with ASCII code of decimal numbers
          CMP AL, 49
          JE BALANCE
          
          CMP AL, 50
          JE WITHDRAW
          
          CMP AL, 51
          JE DEPOSIT
          
          CMP AL, 52
          JE CHANGE_PWD
          
          CMP AL, 53
          JE EXIT
          
          JMP INP_ERROR
                    
                      
                        
    ;Display the current balance
    BALANCE: MOV AH, 0H ;To check for a keystroke like press any key to continue.
             INT 16H
             
             MOV AH, 09H
             LEA DX, CUR_BAL_MSG
             INT 21H
                   
             XOR AX, AX
             MOV AX, CUR_BAL
             CALL DISPLAY_NUM
             
             JMP CHOOSE_OPTION      
                 
                    
                    
    ;Withdraw money from account
    WITHDRAW: MOV AH, 0H
              INT 16H
                    
              MOV AH, 09H
              LEA DX, ABOVE1000
              INT 21H
              
              MOV AH, 09H
              LEA DX, ABOVE100
              INT 21H
              
              MOV AH, 09H
              LEA DX, CHOOSE
              INT 21H
              
              MOV AH, 01H
              INT 21H
              
              ;Check withdrawal amount option
              CMP AL, 49
              JE WITH_ABOVE1000
              CMP AL, 50
              JE WITH_ABOVE100
              JMP INP_ERROR
                    
                       
    ;If withdrawal amount is between Rs.1000 and Rs.5000
    WITH_ABOVE1000: MOV AH, 09H
                    LEA DX, WITH_PROMPT
                    INT 21H
                                  
                    CALL INPUT_4DIGIT_NUM
                    MOV WITH_AMT, BX
                    
                    CMP BX, MAX_LIM
                    JG EXCEED_ERROR
                    JMP WITH_TRANSACT
                                        
                    
    ;If withdrawal amount is between Rs.100 and Rs.999
    WITH_ABOVE100: MOV AH, 09H
                   LEA DX, WITH_PROMPT
                   INT 21H
                                  
                   CALL INPUT_3DIGIT_NUM
                   MOV WITH_AMT, BX
                    
                   JMP WITH_TRANSACT                
    
    
    ;Start the withdrawal transaction
    WITH_TRANSACT: CMP BX, CUR_BAL
                   JG BAL_LOW_ERROR
                   
                   MOV BX, CUR_BAL
                   SUB BX, WITH_AMT
                   MOV CUR_BAL, BX
                       
                   MOV AH, 0H
                   INT 16H
                   CALL SUCCESS_MSG
                   JMP BACK
              
                                                                                                   
    ;If the current balance is lower than the withdrawal amount
    BAL_LOW_ERROR: MOV AH, 0H
                   INT 16H
                   MOV AH, 09H
                   LEA DX, BAL_LOW
                   INT 21H
                   JMP BACK       
                    
                    
                    
    ;Deposit money to account
    DEPOSIT: MOV AH, 0H
             INT 16H
                    
             MOV AH, 09H
             LEA DX, ABOVE1000
             INT 21H
              
             MOV AH, 09H
             LEA DX, ABOVE100
             INT 21H
              
             MOV AH, 09H
             LEA DX, CHOOSE
             INT 21H
              
             MOV AH, 01H
             INT 21H
              
             ;Check deposit amount option
             CMP AL, 49
             JE DEP_ABOVE1000
             CMP AL, 50
             JE DEP_ABOVE100
             JMP INP_ERROR 
    
             
    ;If deposit amount is between Rs.1000 and Rs.5000
    DEP_ABOVE1000: MOV AH, 09H
                   LEA DX, DEP_PROMPT
                   INT 21H
                                  
                   CALL INPUT_4DIGIT_NUM
                   MOV DEP_AMT, BX
                    
                   CMP BX, MAX_LIM
                   JG EXCEED_ERROR
                   JMP DEP_TRANSACT
                                        
                    
    ;If deposit amount is between Rs.100 and Rs.999
    DEP_ABOVE100: MOV AH, 09H
                  LEA DX, DEP_PROMPT
                  INT 21H
                                  
                  CALL INPUT_3DIGIT_NUM
                  MOV DEP_AMT, BX
                  
                  JMP DEP_TRANSACT
                                 
    
    ;Start the deposit transaction
    DEP_TRANSACT: MOV BX, CUR_BAL
                  ADD BX, DEP_AMT
                  MOV CUR_BAL, BX
                       
                  MOV AH, 0H
                  INT 16H
                  CALL SUCCESS_MSG
                  JMP BACK
                       
                       
                   
    ;Change password
    CHANGE_PWD: 
              
                MOV AH, 09H
                LEA DX, REENTER
                INT 21H
                
                CALL CHECK_PWD
                
                MOV AH, 09H
                LEA DX, NEW_PWD_PROMPT
                INT 21H
                
                LEA SI, PWD
                XOR BX, BX
                                
    CHANGE_LOOP: MOV AH, 08H
                 INT 21H
                 
                 CMP AL, 0DH
                 JE BREAKC
                 
                 INC BX
                 CMP BX, 08H
                 JG EXCEED
                 MOV [SI], AL
                                  
                 MOV AH, 02H 
                 MOV DL, 23H
                 INT 21H
                      
                 INC SI
                 JMP CHANGE_LOOP
                 
    EXCEED: MOV AH, 09H
            LEA DX, RESTRICT
            INT 21H
            DEC BX
                
    BREAKC: MOV [SI], "$"
            MOV PWD_LEN, BX
            
            MOV AH, 09H
            LEA DX, NEW_PWD
            INT 21H                
                              
            MOV AH, 09H
            LEA DX, PWD
            INT 21H
            
            JMP BACK    
               
                    
                      
    ;Exit the application                 
    EXIT: MOV AH, 0H
          INT 16H
          
          MOV AH, 09H
          LEA DX, THANK
          INT 21H
          
          MOV AH, 4CH
          INT 21H                   
           
    
    
    ;If user enters incorrect option
    INP_ERROR: MOV AH, 09H
               LEA DX, INVALID
               INT 21H
               JMP BACK
               
               
               
    ;If amount exceeds specified limit
    EXCEED_ERROR: MOV AH, 0H
                  INT 16H
                  MOV AH, 09H
                  LEA DX, LIM_EXCEED
                  INT 21H
                  JMP BACK
                       
        
        
    ;Return to main menu
    BACK: MOV AH, 0H
          INT 16H   ;waiting for enter any key
           
          MOV AH, 0H
          MOV AL, 03H
          INT 10H ;clear the screen
          
          JMP MENU
           
              MAIN ENDP  
                
    ;Procedure to input a 4digit decimal number
    INPUT_4DIGIT_NUM PROC NEAR
        MOV AH, 01H
        INT 21H
        
        ;Check whether character is a digit
        CMP AL, 30H
        JL INP_ERROR
        CMP AL, 39H
        JG INP_ERROR 
        
        SUB AL, 30H
        MOV AH, 0
        MUL TH ;1st digit
        MOV BX, AX
        
        MOV AH, 01H
        INT 21H
        
        ;Check whether character is a digit
        CMP AL, 30H
        JL INP_ERROR
        CMP AL, 39H
        JG INP_ERROR
        
        SUB AL, 30H
        MUL H ;2nd digit
        ADD BX, AX
        
        MOV AH, 01H
        INT 21H
        
        ;Check whether character is a digit
        CMP AL, 30H
        JL INP_ERROR
        CMP AL, 39H
        JG INP_ERROR
        
        SUB AL, 30H
        MUL T ;3rd digit
        ADD BX, AX               
        
        MOV AH, 01H
        INT 21H
        
        ;Check whether character is a digit
        CMP AL, 30H
        JL INP_ERROR
        CMP AL, 39H
        JG INP_ERROR
        
        SUB AL, 30H ;4th digit
        MOV AH, 0
        ADD BX, AX
        
        RET
          
    
    ;Procedure to input a 3digit decimal number
    INPUT_3DIGIT_NUM PROC NEAR
        MOV AH, 01H
        INT 21H
        
        ;Check whether character is a digit
        CMP AL, 30H
        JL INP_ERROR
        CMP AL, 39H
        JG INP_ERROR
        
        SUB AL, 30H
        MOV AH, 0
        MUL H ;1st digit
        MOV BX, AX
        
        MOV AH, 01H
        INT 21H
        
        ;Check whether character is a digit
        CMP AL, 30H
        JL INP_ERROR
        CMP AL, 39H
        JG INP_ERROR
        
        SUB AL, 30H
        MUL T ;2nd digit
        ADD BX, AX               
        
        MOV AH, 01H
        INT 21H
        
        ;Check whether character is a digit
        CMP AL, 30H
        JL INP_ERROR
        CMP AL, 39H
        JG INP_ERROR
        
        SUB AL, 30H ;3rd digit
        MOV AH, 0
        ADD BX, AX
        
        RET
        
              
    ;Procedure to display a 16bit decimal number
    DISPLAY_NUM PROC NEAR
        XOR CX, CX ;To count the digits
        MOV BX, 10 ;Fixed divider
        
        DIGITS:
        XOR DX, DX ;Zero DX for word division
        DIV BX
        PUSH DX ;Remainder (0,9)
        INC CX
        TEST AX, AX
        JNZ DIGITS ;Continue until AX is empty
        
        NEXT:
        POP DX
        ADD DL, 30H
        MOV AH, 02H
        INT 21H
        LOOP NEXT
        
        RET
          
          
    ;Procedure to display a successful transaction message
    SUCCESS_MSG PROC NEAR
        MOV AH, 09H
        LEA DX, SUCCESS
        INT 21H
        
        MOV AH, 09H
        LEA DX, CUR_BAL_MSG
        INT 21H
        
        XOR AX, AX
        MOV AX, CUR_BAL
        CALL DISPLAY_NUM
        
        RET
        
    
    ;Procedure to verify password
    CHECK_PWD PROC ;NEAR
        MOV ENTERED_PWD_LEN, 0H
        MOV BL, 0H ;Flag stored in BL
        LEA SI, PWD ;Store offset of correct password in SI
        MOV CX, PWD_LEN ;Length of entered password has to be compard with actual password length.
        
        VERIFY_PWD: MOV AH, 08H ;Character input without echo to output device.
                    INT 21H
                                
                    CMP AL, 0DH ;Break if user presses enter key.
                    JE BREAKP
                        
                    INC ENTERED_PWD_LEN
                    CMP AL, [SI] ;Compare with actual password.
                    JNE SET_PWD_FLAG
                    JE CONTP
                           
                    SET_PWD_FLAG: MOV BL, 01H
                       
                    CONTP: MOV AH, 02H 
                           MOV DL, 23H ;Hide password characters with *.
                           INT 21H
                      
                    INC SI
                    JMP VERIFY_PWD
                          
        BREAKP: CMP CX, ENTERED_PWD_LEN
                JL PWD_FAIL
                JG PWD_FAIL
                   
                CMP BL, 01H
                JE PWD_FAIL
                JNE RETURNP
            
        PWD_FAIL: LEA DX, PWD_WRONG
                  JMP WRONG 
                                       
        RETURNP: RET
    
                                       
    END MAIN