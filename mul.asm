CSEG SEGMENT PARA PUBLIC 'CODE' 
overlay proc far    
ASSUME cs:CSEG      
    mul ax
    ret  
overlay endp
CSEG ENDS
END 