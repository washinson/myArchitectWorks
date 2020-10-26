format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        str_input_data db 'Input a, b and left, right side via space: ', 0
        str_read_data  db '%lf%lf%lf%lf', 0
        str_result db 'Result is: %lf', 10, 0
        str_d db '%lf', 0

        n           dd 200
        tmp         dd ?
        h           dq ?
        a           dq ?
        b           dq ?
        l           dq ?
        r           dq ?
        sum         dq 0
        result      dq ?

section '.code' code readable executable

start:
        invoke printf, str_input_data
        invoke scanf, str_read_data, a, b, l, r

        finit
        stdcall calculate_h

        fldz
        fst [sum]   ; sum = 0
        ffree st0

        fld [l]
        stdcall f
        stdcall add_result_to_sum

        fld [r]
        stdcall f
        stdcall add_result_to_sum

        stdcall calculate_2i_minus_1_cicrle
        stdcall calculate_2i_cicrle

        fld [h]
        fmul [sum]
        mov [tmp], 3
        fidiv [tmp]
        fst [result]
        ffree st0
        invoke printf, str_result, dword[result], dword[result + 4]

finish:
        call [getch]

        push 0
        call [ExitProcess]

calculate_h:
        fld [r]
        fsub [l]
        fidiv [n]
        fst [h]
        ffree st0
        ret

add_result_to_sum:
        fld [sum]
        fadd st, st1 
        fst [sum] ; sum += stack_top
        ffree st1
        ffree st0
        ret

calculate_2i_minus_1_cicrle:
        mov ebx, 1
start_2i_minus_1_loop:
        cmp ebx, [n]
        jge end_2i_minus_1_loop
        fld [h]
        mov [tmp], ebx
        fimul [tmp]
        fadd [l]     ; h*i + l
        stdcall f    ; f(h*i + l)
        mov [tmp], 4
        fimul [tmp]  ; 4*f(h*i + l)
        stdcall add_result_to_sum
        add ebx, 2
        jmp start_2i_minus_1_loop
end_2i_minus_1_loop:
        ret

calculate_2i_cicrle:
        mov ebx, 2
start_2i_loop:
        cmp ebx, [n]
        jge end_2i_loop
        fld [h]
        mov [tmp], ebx
        fimul [tmp]
        fadd [l]     ; h*i + l
        stdcall f    ; f(h*i + l)
        mov [tmp], 2
        fimul [tmp]  ; 2*f(h*i + l)
        stdcall add_result_to_sum
        add ebx, 2
        jmp start_2i_loop
end_2i_loop:
        ret

f:
        fld1
        fmul st0,st1
        fmul st,st1 ; x*x
        fld [b]
        fdiv st,st1 ; b / x*x
        fadd [a]    ; b / x*x + a
        ffree st1
        ffree st2
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
        import kernel,\
                   ExitProcess, 'ExitProcess',\
                   HeapCreate,'HeapCreate',\
                   HeapAlloc,'HeapAlloc'
include 'api\kernel32.inc'
        import msvcrt,\
                   printf, 'printf',\
                   scanf, 'scanf',\
                   getch, '_getch'