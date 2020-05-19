CSEG SEGMENT PARA PUBLIC 'CODE' 
overlay proc far    
ASSUME cs:CSEG      
    div ax
    ret  
overlay endp
CSEG ENDS
END 