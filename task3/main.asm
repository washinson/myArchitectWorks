; Малышенко Александр Михайлович
; 18 вариант
;
; Задача: 
; Разработать программу интегрирования функции y=a+b*x^-2 (задаётся двумя числами а,b)
; в заданном диапазоне(задаётся так же) методом Симпсона(использовать FPU)
; 
; C++ equivalent solution
;
; int n = 200;
; double h;
; double a, b;
; double l, r;

; double f(double x) {
;     return a + b / (x * x);
; }

; int main() {
;     printf("Input a, b and left, right side via space: ");
;     scanf("%lf%lf%lf%lf", &a, &b, &l, &r);
;     if (l > r) {
;         printf("Left side mustn't be greater then right side");
;         return 0;
;     }
;     h = (r - l) / n;
;     double sum = f(l) + f(r);
;     for (int i = 1; i < n; i += 2) {
;         sum += 4 * f(l + h * i);
;     }
;     for (int i = 2; i < n; i += 2) {
;         sum += 2 * f(l + h * i);
;     }
;     printf("%lf", h * sum / 3);
;     return 0;
; }

format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        str_input_data db 'Input a, b and left, right side via space: ', 0
        str_read_data  db '%lf%lf%lf%lf', 0
        str_result db 'Result is: %lf', 10, 0
        str_left_side_greater_right_side db 'Left side mustn`t be greater then right side', 0
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

        ; comp l and r
        fld [r]
        fld [l]
        fcomi st, st1
        ffree st0
        ffree st1
        jb l_less_or_equal_r

        ; l > r
        invoke printf, str_left_side_greater_right_side
        jmp finish

l_less_or_equal_r:
        stdcall calculate_h ; h = (r - l) / n

        fldz
        fst [sum]   ; sum = 0
        ffree st0

        fld [l]
        stdcall f ; f(l)
        stdcall add_result_to_sum ; sum += f(l)

        fld [r]
        stdcall f ; f(r)
        stdcall add_result_to_sum ; sum += f(r)

        ; for (int i = 1; i < n; i += 2) {
        ;     sum += 4 * f(l + h * i);
        ; }
        stdcall calculate_2i_minus_1_cicrle 
        ; for (int i = 2; i < n; i += 2) {
        ;     sum += 2 * f(l + h * i);
        ; }
        stdcall calculate_2i_cicrle

        fld [h]
        fmul [sum]
        mov [tmp], 3
        fidiv [tmp]
        fst [result] ; result = h * sum / 3
        ffree st0
        invoke printf, str_result, dword[result], dword[result + 4]

finish:
        call [getch]

        push 0
        call [ExitProcess]

; calculate_h(): returns void
; sets h = (r - l) / n 
calculate_h:
        fld [r]
        fsub [l]
        fidiv [n]
        fst [h] ; h = (r - l) / n
        ffree st0
        ret

; add_result_to_sum(double result): returns void
; updates sum += result
; result sends via FPU stack at st(0)
add_result_to_sum:
        fld [sum]
        fadd st, st1 
        fst [sum] ; sum += stack_top (result)
        ffree st1
        ffree st0
        ret

; calculate_2i_minus_1_cicrle(): returns void
; does loop by following C++ instruction:
; for (int i = 1; i < n; i += 2) {
;     sum += 4 * f(l + h * i);
; }
calculate_2i_minus_1_cicrle:
        mov ebx, 1 ; i = 1
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

; calculate_2i_cicrle(): returns void
; does loop by following C++ instruction:
; for (int i = 2; i < n; i += 2) {
;     sum += 2 * f(l + h * i);
; }
calculate_2i_cicrle:
        mov ebx, 2; i = 2
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

; f(double x): returns double result
; calculates f(x) = a+b*x^-2
; x sends via FPU stack at st(0)
; result sends via FPU stack at st(0)
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