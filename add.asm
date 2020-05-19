CSEG SEGMENT PARA PUBLIC 'CODE' 
   
ASSUME cs:CSEG;, ds:DSEG 
overlay proc far 
;    push ds 
;    
;    mov dx,  DSEG
;    mov ds, dx     
    add ax, bx 
;    
;    mov ah, 9 
;    ;xor bx, bx
;    ;mov dx,  ds:[bx] 
;    mov dx, offset string
;    int 21h
;    
;    pop ds
    ret  
overlay endp
CSEG ENDS  

;DSEG SEGMENT  PARA PUBLIC 'DATA'  
;    string db "aaa", 10, 13, '$'    
;DSEG ENDS  
  
END 