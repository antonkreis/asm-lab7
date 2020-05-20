
.model small
.stack 100h  

.data 
    overlay_seg dw ?
    overlay_offset dw ?
    code_seg dw ?  
    overlay_path db "OVER.bin", 0
    overlay_path_add db "add.bin", 0 
    overlay_path_sub db "sub.bin", 0 
    overlay_path_mul db "mul.bin", 0
    overlay_path_div db "div.bin", 0
    ;file_path db "file.txt", 0 
    file_path db 126 dup ('$')
    a db "aaaaa", 10, 13, '$' 
    newline db 10,13, '$' 
    commandline_not_found_message db "Please, enter the path of file in the command line", 10, 13, '$' 
    change_size_error_message db "Change size error!", 10, 13, '$' 
    allocation_error_message db "Allocation error!", 10, 13, '$'
    memory_managemnt_blocks_destroyed_message db "Error! Memory managemnt blocks destroyed.", 10, 13, '$' 
    not_enough_memory_message db "Error! Not enough memory.", 10, 13, '$'
    wrong_address_message db "Error! Wrong address in ES register.", 10, 13, '$'    
    unexpected_error_message db "Unexpected error!", 10, 13, '$'    
    overlay_not_found_message db "Error! Overlay not found.", 10, 13, '$'
    file_access_forbidden_message db "Error! File access forbidden.", 10, 13, '$' 
    wrong_environment_message db "Error! Wrong environment.", 10, 13, '$'
    wrong_format_message db "Error! Wrong format.", 10, 13, '$'
    file_not_found_message db "Error! File not found.", 10, 13, '$'   
    path_not_found_message db "Error! Path not found.", 10, 13, '$'
    too_many_opened_files_message db "Error! To many files are opened.", 10, 13, '$'
    access_forbidden_message db "Error! Access is forbidden.", 10, 13, '$'
    wrong_access_mode_message db "Error! Wrong access mode.", 10, 13, '$' 
    read_access_forbidden_message db "Error! Read access is forbidden.", 10, 13, '$'
    wrong_id_message db "Error! Wrong file ID.", 10, 13, '$'
    unexpected_open_error_message db "Unexpected open error!", 10, 13, '$'  
    unexpected_close_error_message db "Unexpected close error!", 10, 13, '$' 
    unexpected_read_error_message db "Unexpected read error!", 10, 13, '$' 
    div_overflow_message db  10, 13, "Error! Division by 0.", 10, 13, '$' 
    mul_overflow_message db  10, 13, "Error! Multiplication overflow.", 10, 13, '$'
    add_overflow_message db  10, 13, "Error! Addition overflow.", 10, 13, '$' 
    sub_overflow_message db  10, 13, "Error! Substraction overflow.", 10, 13, '$'  
    minus_flag db 0    
    allocation_flag db 0
    input_message db "Your input:", 10, 13, '$' 
    wrong_input_message db 10, 13, "Wrong input! Check your file.", 10, 13, '$'
    frame db "================================================================================", 10, 13, '$'
    ;buffer db "50*2$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$" 
    buffer db 288 dup ('$')  
    checked_buffer db 289 dup ('$')
    ;test_buffer db "8*7-90*8*20+8/1+"  
    ;test_buffer db "8*7-90*8*20+8/1+"
    checked_test_buffer db 288 dup ('$')
    amount_of_operands equ 7
    
    operand1 db 7 dup ('$')
    operand2 db 7 dup ('$') 
    operand_address dw ? 
    result_position dw ?
    result_end_position dw ? 
    result_size dw 0
    sign db ? 
    
    read_block_size equ 288
    
    negate_flag db 0
    arithmetic_error_flag db 0
    exit_flag db 0
    wrong_input_flag db 0
    param_block dw 2 dup (?) 
    entry dd ?
    file_id dw ?
    read_amount dw ?
    dec_flag db 0 
    
.code 


print_string macro string 
    mov ah, 9
    mov dx, offset string 
    int 21h 
print_string endm 



open_file proc near    
    mov ah, 3Dh
    mov al, 0 ;mode: 11000001 - 7: not inherited, 100: no restrictions for other proc, 00: reserved, 0 - cannot write, 1 can read
    mov dx, offset file_path  
    mov cl, 0
    int 21h
    jc open_error 
    mov file_id, ax
    jmp end_open_file_proc:
open_error: 
    mov bl, 1
    mov exit_flag, bl
file_not_found:
    cmp ax, 02h
    jne path_not_found
    print_string file_not_found_message
    jmp end_open_file_proc  
path_not_found:
    cmp ax, 03h 
    jne too_many_opened_files
    print_string path_not_found_message 
    jmp end_open_file_proc
too_many_opened_files:  
    cmp ax, 04h  
    jne access_forbidden 
    print_string access_forbidden_message 
    jmp end_open_file_proc
access_forbidden:  
    cmp ax, 05h 
    jne wrong_access_mode
    print_string wrong_access_mode_message 
    jmp end_open_file_proc  
wrong_access_mode:
    cmp ax, 0Ch
    jmp unexpected_open_error
    print_string wrong_access_mode_message  
    jmp end_open_file_proc 
unexpected_open_error:
    print_string unexpected_open_error_message    
end_open_file_proc: 
    ret        
open_file endp 




close_file proc near   
    mov ah, 3Eh
    mov bx, file_id
    int 21h
    jc close_error
    jmp end_close_file_proc 
close_error:
    cmp ax, 06h
    jne unexpected_close_error
    print_string wrong_id_message
    jmp end_close_file_proc
unexpected_close_error:
    print_string unexpected_close_error_message    
end_close_file_proc:    
    ret
close_file endp  







 
read_file proc near    
    mov ax, @data
    mov es, ax   
    cld   
    xor ax, ax 
    mov ah, 3fh
    mov bx, file_id
    mov cx, read_block_size
    mov dx, offset buffer
    int 21h 
    jc read_error 
    mov read_amount, ax 
    jmp read 
read_error:
    push ax
    call close_file
    pop ax
    mov bl, 1
    mov exit_flag, bl
read_access_forbidden:
    cmp ax, 05h
    jne wrong_id
    print_string read_access_forbidden_message
    jmp end_read_file_proc
wrong_id:
    cmp ax, 06h
    jne unexpected_read_error    
    print_string wrong_id_message 
    jmp end_read_file_proc
unexpected_read_error:
    print_string unexpected_read_error_message  
    jmp end_read_file_proc 
read: 
 
    ;print_string frame
    ;call convert 
    print_string buffer 
   ;jmp begin_read_file
end_read_file_proc:    
    ret
read_file endp     



 
check_input proc near
    mov cx, read_amount
    ;mov cx, 16
    cmp cx, 0  
    mov bx, 0 ; size of operands
    mov dx, 0 ; amount of operands
     
    ;je end_check_input_proc 
    mov di, offset buffer    
   
    mov al, '0' 
    cmp ds:[di],al
    jl input_error 
    mov al, '9' 
    cmp ds:[di],al
    jg input_error
    
    
    
check_symbols:
    mov al, ds:[di]
    cmp al, '$' 
    je end_check_input_proc 
    cmp al, '0'
    jl check_if_sign
    cmp al, '9'
    jg input_error
    inc bx 
    
    mov al, ds:[di+1]
    cmp al, '$'
    jne continue
    inc dx
continue:    
    inc di   
    loop check_symbols
    jmp end_check_input_proc 
check_if_sign:
    cmp al, '+'
    je check_if_first
    cmp al, '*'
    je check_if_first
    cmp al, '/'
    je check_if_first
    cmp al, '-'
    je check_if_first
    jmp input_error 
check_if_first:    
    cmp cx, read_amount   
    ;cmp cx, 16  ; sign is the first
    je input_error 
    mov al, ds:[di+1]
    cmp al, '+'
    je input_error 
    cmp al, '-'
    je input_error
    cmp al, '*'
    je input_error
    cmp al, '/'
    je input_error
    ;cmp cx, 1  ; sign is the last
    ;je input_error
check_operand_size:    
    cmp bx, 5 ; max number length
    jg input_error
    mov bx, 0 
    
    inc dx  
    
    
    
end_check_symbols_iteration: 
    inc di   
    loop check_symbols
    jmp end_check_input_proc  
    
check_amount_of_operands:
    cmp dx, amount_of_operands
    jne end_check_symbols_iteration 
    dec cx
    jmp end_check_input_proc
    
     
input_error: 
    print_string wrong_input_message 
    mov al, 1        
    mov wrong_input_flag, al 
    mov bx, 0
end_check_input_proc: 
    cmp bx, 5 ; max number length
    jg input_error 
    push es
    push ds
    pop es
    lea si, buffer
    lea di, checked_buffer
    mov ax, 16
    sub ax, cx
    mov cx, ax
    rep movsb   
    mov di, 16
    mov al, '0'
    cmp checked_buffer[di - 1], al
    jnl no_sign_at_the_end
    mov al, '$'
    mov checked_buffer[di - 1], al
no_sign_at_the_end:        
    pop es
    ret
check_input endp    
 
 




calculations proc near
    mov di, offset checked_buffer
    
devisions_multiplications:  
    mov bx, 0
    mov dx, di ; the beginning of the 1 operand
    mov result_position, dx
search_for_1_operand:
    mov al, '$'
    cmp ds:[di], al
    je end_devisions_multiplications
    mov al, '0'
    cmp ds:[di], al
    jl operand_1_found
    inc di
    inc bx ; 1 operand length
    jmp search_for_1_operand  
     
operand_1_found:

    mov al, '*' 
    cmp ds:[di], al
    je copy_sign
    mov al, '/' 
    cmp ds:[di], al
    je copy_sign
    inc di
    mov bx, 0 
    jmp devisions_multiplications
  
    
copy_sign:    
    
    mov al, ds:[di]
    mov sign, al 
    
;=============================================copy to operand1 buffer
    push ds
    pop es    
    push di
    cld
    mov si, dx 
    mov cx, bx 
    mov di, offset operand1
    rep movsb       
    pop di
;============================================/copy to operand1 buffer 
    
    inc di 
    mov bx, 0
    mov dx, di
    jmp search_for_2_operand      
search_for_2_operand: 
    mov al, '$'
    cmp ds:[di], al
    je check_if_2_operand_found
    mov al, '0'
    cmp ds:[di], al
    jl operand_2_found
    inc di
    inc bx ; 2 operand length
    jmp search_for_2_operand  

check_if_2_operand_found:  

    cmp bx, 0
    je end_devisions_multiplications   
    
    
operand_2_found: 
    push dx    
    mov dx, di
    mov result_end_position, dx 
    pop dx  
    ;=============================================copy to operand2 buffer
    push ds
    pop es    
    push di
    cld
    mov si, dx 
    mov cx, bx 
    mov di, offset operand2
    rep movsb       
    pop di
    ;============================================/copy to operand2 buffer 

    
    
    push ds
    pop es
    mov si, offset operand1
    mov ax, si
    mov operand_address, ax
    call atoi 
    

    
    mov bx, ax ; converted 1 operand
    

    mov si, offset operand2
    mov ax, si
    mov operand_address, ax
    push bx
    call atoi  ; in ax - converted 2 operand
    pop bx
    mov dl, sign
    cmp dl, '*'
    jne operands_division 
    

;
    push ax
    push bx    
    mov ax, ds
    mov es, ax 
    mov bx, offset param_block 
    mov dx, offset overlay_path_mul
    mov ah, 4bh
    mov al, 3
    int 21h 
    jc load_error 
    pop bx 
    pop ax
    call dword ptr overlay_offset 

    ;mul bx ; in ax - result   
    
    cmp ax, 32767
    ja mul_overflow 
    cmp dx, 0
    jne mul_overflow   
    
   
    jc mul_overflow
    jmp not_operands_division
mul_overflow:
    print_string mul_overflow_message 
    mov al, 1
    mov arithmetic_error_flag, al
    jmp end_additions_substractions     
div_overflow:
    print_string div_overflow_message
    mov al, 1
    mov arithmetic_error_flag, al
    jmp end_additions_substractions     
     
operands_division:
    xchg ax, bx
    xor dx, dx
    cmp bx, 0
    je div_overflow 
    
    push ax
    push bx
    mov ax, ds
    mov es, ax  
    mov bx, offset param_block
    mov dx, offset overlay_path_div
    mov ah, 4bh
    mov al, 3
    int 21h 
    jc load_error  
    pop bx
    pop ax  
    xor dx, dx
    call dword ptr overlay_offset
    
       
    ;div bx
     
not_operands_division:     
    call itoa 
    
    mov ax, result_position 
    mov bx, result_size
    add ax, bx
    
    
    mov di, ax 
    mov ax, result_end_position
    mov bx, result_position
    sub ax, bx  ;  
    mov bx, result_size 
    sub ax, bx  ; 
    xchg ax, bx
    
mov_left:  
    mov al, ds:[di]
    cmp al, '$'
    je end_mov_left
    mov al, ds:[di+bx]
    mov ds:[di], al
    inc di
    jmp mov_left    
end_mov_left:    
   
    

    mov di, offset operand1    
    mov ax, '$' 
    mov cx, 6
    rep stosb 
    
    mov di, offset operand2    
    mov ax, '$' 
    mov cx, 6
    rep stosb
   
    mov di, result_position 
    mov ax, 0
    mov result_size, ax
    jmp devisions_multiplications
    
end_devisions_multiplications:    
    

;==============================================================================================        
        
        
        
    mov di, offset checked_buffer
    
additions_substractions:  
    mov bx, 0
    mov dx, di ; the beginning of the 1 operand
    mov result_position, dx 
    jmp search_for_1_operand1
    
test_bx_1:
    cmp bx, 0
    jne operand_1_found1 
    inc bx
    inc di
    
search_for_1_operand1:
    mov al, '$'
    cmp ds:[di], al
    je end_additions_substractions
    mov al, '-'
    cmp ds:[di], al
    je test_bx_1
    mov al, '0'
    cmp ds:[di], al
    jl operand_1_found1
    inc di
    inc bx ; 1 operand length
    jmp search_for_1_operand1  
     
operand_1_found1:   
copy_sign1:    
    
    mov al, ds:[di]
    mov sign, al 
    
;=============================================copy to operand1 buffer
    push ds
    pop es    
    push di
    cld
    mov si, dx 
    mov cx, bx 
    mov di, offset operand1
    rep movsb       
    pop di
;============================================/copy to operand1 buffer 
    
    inc di 
    mov bx, 0
    mov dx, di
    jmp search_for_2_operand1
    
    
test_bx_2:
    cmp bx, 0
    jne operand_2_found1 
    inc bx
    inc di    
    
    
    
          
search_for_2_operand1: 
    mov al, '$'
    cmp ds:[di], al  
    mov al, '-'
    cmp ds:[di], al
    je test_bx_2
    je check_if_2_operand_found1
    mov al, '0'
    cmp ds:[di], al
    jl operand_2_found1
    inc di
    inc bx ; 2 operand length
    jmp search_for_2_operand1  

check_if_2_operand_found1:  

    cmp bx, 0
    je end_additions_substractions   
    
    
operand_2_found1: 
    push dx    
    mov dx, di
    mov result_end_position, dx 
    pop dx  
    ;=============================================copy to operand2 buffer
    push ds
    pop es    
    push di
    cld
    mov si, dx 
    mov cx, bx 
    mov di, offset operand2
    rep movsb       
    pop di
    ;============================================/copy to operand2 buffer 

    
    
    push ds
    pop es
    mov si, offset operand1
    mov ax, si
    mov operand_address, ax
    call atoi
    mov bx, ax ; converted 1 operand 
    mov si, offset operand2
    mov ax, si
    mov operand_address, ax
    push bx
    call atoi  ; in ax - converted 2 operand
    pop bx
    mov dl, sign
    cmp dl, '+'
    jne operands_substraction    
     
     
     
     
     
    push ax
    push bx 
    mov ax, ds
    mov es, ax 
    mov bx, offset param_block 
    mov dx, offset overlay_path_add
    mov ah, 4bh
    mov al, 3
    int 21h
    jc load_error   
    pop bx
    pop ax 
    call dword ptr overlay_offset
     
    ;add ax, bx ; in ax - result 
    jc add_overflow  
    cmp ax, 32767
    ja add_overflow 
    
    mov bx, 2
m: 
    dec bx
    neg ax
    js m    
    mov minus_flag, bl
    
    
    
    
    jmp not_operands_substraction 
    
    
    
    
add_overflow:
    print_string add_overflow_message 
    mov al, 1
    mov arithmetic_error_flag, al
    jmp end_additions_substractions     
sub_overflow:
    cmp ax, 0
    jng not_overflow  
   ; pop dx
    print_string sub_overflow_message
    mov al, 1
    mov arithmetic_error_flag, al 
    jmp end_additions_substractions       
    
    
    
    
    

operands_substraction:
    xchg ax, bx
    
    push ax
    push bx
    mov ax, ds
    mov es, ax  
    mov bx, offset param_block
    mov dx, offset overlay_path_sub
    mov ah, 4bh
    mov al, 3
    int 21h
    jc load_error  
    pop bx
    pop ax
    
        
    ;sub ax, bx   
     
    ; push dx
     cmp ax, bx
jnb nm
     mov dl, 1
nm: 
    
    
    call dword ptr overlay_offset  
    
    cmp dl, 1
    je sub_overflow
        
    ;jc sub_overflow 
    
   ; cmp ax, 32767
    ;js sub_overflow   
    ;cmp ax, -32767
    ;jl sub_overflow 

    
    
    
not_overflow:

    cmp ax, 32768  
    jne sign_check:
    mov bx, 1
    mov minus_flag, bl 
    jmp not_operands_substraction

sign_check:
  
    mov bx, 2 
  ;  pop dx
m1: 
    dec bx
    neg ax
    js m1    
    mov minus_flag, bl 
    
    
        
    
not_operands_substraction:     
    call itoa 
    
    mov ax, result_position 
    mov bx, result_size  
    
    
    

    add ax, bx
    
    
    mov di, ax 
    mov ax, result_end_position
    mov bx, result_position
    sub ax, bx  ;  
    mov bx, result_size 
    
    
   
    sub ax, bx
     
    
    
    
    xchg ax, bx
    
mov_left1:  
    mov al, ds:[di]
    cmp al, '$'
    je end_mov_left1
    mov al, ds:[di+bx]
    mov ds:[di], al
    inc di
    jmp mov_left1    
end_mov_left1:    
   
    

    mov di, offset operand1    
    mov ax, '$' 
    mov cx, 6
    rep stosb 
    
    mov di, offset operand2    
    mov ax, '$' 
    mov cx, 6
    rep stosb
   
    mov di, result_position 
    mov ax, 0
    mov minus_flag, al
    mov result_size, ax
    jmp additions_substractions
    
    
load_error:
overlay_not_found:
    cmp ax, 02h
    jne file_access_forbidden
    print_string overlay_not_found_message
    jmp program_end  
file_access_forbidden:
    cmp ax, 05h 
    jne load_not_enough_memory
    print_string file_access_forbidden_message 
    jmp program_end 
load_not_enough_memory:
    cmp ax, 08h 
    jne wrong_environment
    print_string not_enough_memory_message 
    jmp program_end      
wrong_environment:  
    cmp ax, 0Ah  
    jne wrong_format 
    print_string wrong_environment_message 
    jmp program_end 
wrong_format:  
    cmp ax, 0Bh  
    jne load_unexpected_error 
    print_string wrong_format_message 
    jmp program_end    
load_unexpected_error:     
    print_string unexpected_error_message
    jmp program_end     
    
    
    
    
    
end_additions_substractions:        
        
        
        
        
;==============================================================================================        
        
    ret
calculations endp     





itoa proc near 
    mov dx, result_position 
    mov di, dx
    push ds
    pop es
    mov bx, ax
    cmp bx, 0 
    jne not_zero 
    add bl, 30h
    mov es:[di], bl 
    mov bx, 1
    mov result_size, bx
    jmp end_print_array
not_zero:       
    mov si, 0
    mov dl, minus_flag
    cmp dl, 1
    jne not_print_minus
    mov es:[di], '-'
    inc di 
    
    mov dx, result_size
    inc dx
    mov result_size, dx
    
not_print_minus:           
    xor dx, dx 
    push bx 
    mov bx, 10
    mov cx, 5
size:
    cmp ax, 10
    jb incr
    div bx 
    xor dx, dx
    inc si
    loop size 
incr: 
    pop bx      
    inc si        
number:     
    mov ax, bx 
    mov cx, si 
    dec cx 
    push bx
    mov bx, 10
division:
    cmp cx, 0
    je end_division
    div bx
    xor dx, dx 
    loop division 
end_division:     
    push ax 
    mov dl, al  
    add dl, 30h     
    mov es:[di], dl
    mov ax, result_size
    inc ax
    mov result_size, ax
    
    
    inc di  
    pop ax  
    mov cx, si  
    dec cx
multi:
    cmp cx, 0
    je end_multi
    mul bx
    loop multi  
end_multi:
    pop bx
    sub bx, ax 
    dec si
    cmp si, 0
    jne number    
end_print_array:
    ret
itoa endp






atoi proc near  
    xor bx, bx
    push cx
    mov dx, 0   
    cmp ds:[si], '0'
    je only_zero_check
    jmp check_minus ; emount of decimals
only_zero_check:   
    cmp ds:[si+1], '$'
    jne amount
    mov ax, 0 ;   operand 1  
    pop cx
    jmp end_insert 
check_minus:    
    mov al, ds:[si]
    cmp al, '-'
    jne amount  
    mov al, 1
    mov negate_flag, al
    
    inc si 
amount:
    cmp ds:[si], '$'
    je end_amount
    inc dx ; amount of decimals in a number 
    inc si
    jmp amount     
end_amount:
    cmp dx, 5
    jl not_big
    cmp ds:[si], '3'
    jg error
    jl not_big
    inc si
    cmp ds:[si], '2'
    jg error
    jl not_big
    inc si
    cmp ds:[si], '7'
    jg error
    jl not_big
    inc si
    cmp ds:[si],'6'
    jg error
    jl not_big
    inc si
    cmp ds:[si], '7'
    jg error
    jle not_big
not_big: 
    mov cx, dx   
    dec dx
    mov ax, operand_address
    mov si, ax 
    mov al, negate_flag
    cmp al, 1
    jne not_incr
    inc si
not_incr:     
    cmp ds:[si], '0'                    
    jne convert
    inc si
    jmp convert
convert:
    cmp ds:[si], '$'
    je end_convert
    xor ax, ax
    mov al, ds:[si]  
    sub ax, 30h
    push si 
    push cx
    mov cx, dx  
    push dx   
    push bx
    mov bx, 10  
ten:  
    cmp cx, 0
    je end_ten
    mul bx
    dec cx
    jmp ten  
end_ten:
    pop bx
    pop dx 
    dec dx
    pop cx
    pop si
    inc si   
    add bx, ax
    loop convert
end_convert: 
    pop cx  
    mov ax, bx  ;operand 1  
    mov bl, negate_flag
    cmp bl, 1
    jne end_insert 
    neg ax 
    mov bl, 0
    mov negate_flag, bl
    jmp end_insert
error:
    mov ah, 9 
    mov dx, offset wrong_input_message
    int 21h 
    
    mov ax, operand_address
    mov di, ax
   ; mov dx, offset operand1    
    mov ax, '$' 
    mov cx, 6
    rep stosb    
    pop cx 
end_insert:  
    ret
atoi endp    


start:    

    mov ax, @data      
    mov ds, ax  
    
    push es
    
    mov cl, es:80h 
    cmp cl, 0
    je file_path_not_found
    mov si, offset file_path 
    mov di, 81h
    mov al, ' '
    repe scasb
    dec di

copy_path:
    mov al, es:[di]
    cmp al, 13
    je end_copy_path
    mov ds:[si], al
    inc si
    inc di 
    jmp copy_path 
 
file_path_not_found:    
    print_string commandline_not_found_message
    jmp program_end                                        
end_copy_path: 
           
    ;print_string file_path 
    mov al, 0
    mov ds:[si], al
;    
    pop es
     
     
     
     
     
    ;call check_input
    ;call calculations 
    ;print_string checked_buffer
    mov code_seg, cs
    mov ax, es ; PSP
    mov bx,  ZSEG
    sub bx, ax 
    mov ah, 4ah   
    int 21h 
    jc change_size_error
    
    
    mov bx, 100h
    mov ah, 48h
    int 21h
    jc allocation_error 
    mov overlay_seg, ax
    mov al, 1
    mov allocation_flag, al  


;===============================optimissation    
    mov bx, offset param_block
    mov ax, overlay_seg
    mov [bx], ax
    mov [bx+2], ax 
;============================================

    
    mov ax, code_seg
    mov bx, overlay_seg
    sub bx, ax
    mov cl, 4
    shl bx, cl
    mov overlay_offset, bx 

    call open_file
    mov al, 1
    cmp exit_flag, al
    je program_end

    call read_file
    call check_input
    mov al, wrong_input_flag
    cmp al, 1
    je program_end 
    call calculations
    mov al, arithmetic_error_flag
    cmp al, 1
    je program_end
    
    print_string newline
    print_string checked_buffer
    
    call close_file 
    jmp program_end  
    
change_size_error:
    push ax 
    print_string change_size_error_message  
    pop ax
change_size_memory_managemnt_blocks_destroyed:
    cmp ax, 07h
    jne change_size_not_enough_memory
    print_string memory_managemnt_blocks_destroyed_message
    jmp program_end  
change_size_not_enough_memory:
    cmp ax, 08h 
    jne change_size_wrong_address
    print_string not_enough_memory_message 
    jmp program_end
change_size_wrong_address:  
    cmp ax, 09h  
    jne change_size_unexpected_error 
    print_string wrong_address_message 
    jmp program_end    
change_size_unexpected_error:     
    print_string unexpected_error_message
    jmp program_end  
    
    
allocation_error:
    push ax
    print_string allocation_error_message
    pop ax 
allocation_memory_managemnt_blocks_destroyed:
    cmp ax, 07h
    jne allocation_not_enough_memory
    print_string memory_managemnt_blocks_destroyed_message
    jmp program_end  
allocation_not_enough_memory:
    cmp ax, 08h 
    jne allocation_unexpected_error
    print_string not_enough_memory_message 
    jmp program_end  
allocation_unexpected_error:     
    print_string unexpected_error_message
    jmp program_end

     
     
program_end: 
;    mov al, allocation_flag
;    cmp al, 1
;    jne not_free 
;    mov ah, 49h
;    push ds
;    pop es
;    mov 
;    mov ax, overlay_seg
;    
;not_free:        
    mov ax, 4c00h
    int 21h 
ZSEG SEGMENT     
ZSEG ENDS    
    
end start