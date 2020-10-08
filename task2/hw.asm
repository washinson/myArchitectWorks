; 18 вариант - с уменьшением всех элементов до первого положительного на 5

; Разработать программу, которая вводит одномерный массив A[N], формирует из элементов массива A новый массив B по правилам,
; указанным в таблице, и выводит его. Память под массивы может выделяться как статически, так и динамически по выбору разработчика.

; Разбить решение задачи на функции следующим образом:

;     Ввод и вывод массивов оформить как подпрограммы.
;     Выполнение задания по варианту оформить как процедуру
;     Организовать вывод как исходного, так и сформированного массивов
; 
; Указанные процедуры могут использовать данные напрямую (имитация процедур без параметров). Имитация работы с параметрами также допустима.

; 18 вариант - с уменьшением всех элементов до первого положительного на 5

format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        str_input_n db 'Input n: ', 0
        str_read_d  db '%d', 0
        str_vector_i db '[%d]? ', 0
        str_out_first_array db 'First array[%d] = %d', 10, 0
        str_out_second_array db 'Second array[%d] = %d', 10, 0
        str_incorrect_n db 'Incorrect n', 10, 0

        vec1        rd 100
        vec2        rd 100
        n1          dd ?
        n2          dd ?
        tmp         dd ?
        i           dd ?

section '.code' code readable executable

start:
        call read_first_array 
        call calculace_second_array
        call print_first_array
        call print_second_array
finish:
        call [getch]

        push 0
        call [ExitProcess]

read_first_array:
        push str_input_n
        call [printf]
        add esp, 4

        push n1
        push str_read_d
        call [scanf]
        add esp, 8

        mov eax, [n1]
        cmp eax, 0
        jle incorrect_input
        cmp eax, 100
        jle start_input
incorrect_input:
        push str_incorrect_n
        call [printf]

        call [getch]
        push -1
        call [ExitProcess]
start_input:
        xor ecx, ecx
        mov ebx, vec1
loop_input:
        mov [tmp], ebx
        cmp ecx, [n1]
        jge end_loop_input      

        mov [i], ecx
        push ecx
        push str_vector_i
        call [printf]
        add esp, 8

        mov ebx, [tmp]
        push ebx
        push str_read_d
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp loop_input
end_loop_input:             
        ret

;----

calculace_second_array:
        xor ecx, ecx 
        mov ebx, vec1
        mov eax, vec2
start_first_loop:
        mov [i], ecx

        cmp ecx, [n1]
        jge end_first_loop

        mov ecx, [ebx]
        cmp ecx, 0
        jg end_first_loop

        mov ecx, [ebx]
        sub ecx, 5
        mov [eax], ecx

        mov ecx, [i]
        inc ecx
        add ebx, 4
        add eax, 4
        jmp start_first_loop
end_first_loop:
        mov ecx, [i]
start_second_loop:
        mov [i], ecx

        cmp ecx, [n1]
        jge end_second_loop

        mov ecx, [ebx]
        mov [eax], ecx

        mov ecx, [i]
        inc ecx
        add ebx, 4
        add eax, 4
        jmp start_second_loop
end_second_loop:
        ret
        
;----

print_first_array:
        xor ecx, ecx 
        mov ebx, vec1
start_print_loop:
        mov [i], ecx
        mov [tmp], ebx

        cmp ecx, [n1]
        jge end_print_loop

        mov ebx, [ebx]
        push ebx
        push ecx
        push str_out_first_array
        call [printf]
        add esp, 12

        mov ecx, [i]
        mov ebx, [tmp]
        inc ecx
        add ebx, 4
        jmp start_print_loop
end_print_loop:
        ret

;----

print_second_array:
        xor ecx, ecx 
        mov ebx, vec2
start_second_print_loop:
        mov [i], ecx
        mov [tmp], ebx

        cmp ecx, [n1]
        jge end_second_print_loop

        mov ebx, [ebx]
        push ebx
        push ecx
        push str_out_second_array
        call [printf]
        add esp, 12

        mov ecx, [i]
        mov ebx, [tmp]
        inc ecx
        add ebx, 4
        jmp start_second_print_loop
end_second_print_loop:
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