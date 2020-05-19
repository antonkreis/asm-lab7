CSEG SEGMENT PARA PUBLIC 'CODE' 
overlay proc far    
ASSUME cs:CSEG      
    sub ax, bx
    ret  
overlay endp
CSEG ENDS
END 