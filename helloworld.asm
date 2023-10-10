default rel
global  main
extern  printf, GetModuleHandleA, LoadIconA, LoadCursorA, RegisterClassA, DefWindowProcA, GetLastError, CreateWindowExA, ShowWindow, D2D1CreateFactory, GetClientRect, ValidateRect, PostQuitMessage

; define data
segment .data
    %include    "window_constants.asm"
    %include    "riid.asm"
    %include    "structuredefs.asm"
    %include    "structures.asm"
    classStyle		equ cs_vredraw|cs_hredraw|cs_dblclks|cs_owndc|cs_parentdc
    main_style		equ WS_VISIBLE|WS_TILEDWINDOW|WS_POPUP|WS_BORDER
    IDI_APPLICATION equ 32512
    IDC_ARROW       equ 32512
    WINDW_NAME: 	    db "All Assembly DirectX Sample", 0
    CLASS_NAME:         db "My Class", 0
    CLASS_ATOM:         dq 0
    float_one:          dq 1.0
    ppTag1:             dq 0
    ppTag2:             dq 0
    ppIFactory:         dq 0
    pphwndRenderTarget: dq 0
    ppsolidColorBrush:  dq 0
    ppWindow:           dq 0
    message:            db "%p", 0xa, 0

; main code
section .text
    main:
        sub     rsp, 104             ; home space

; Register class
        xor     rcx, rcx                        ; [in, optional]    lpModuleName
        call    GetModuleHandleA                ; call
        mov     [wc + WNDCLASS.hInstance], rax  ;
        xor     rcx, rcx                        ; [in, optional]    hInstance
        mov     rdx, IDI_APPLICATION            ; [in]              lpIconName
        call    LoadIconA                       ; call
        mov     [wc + WNDCLASS.hIcon], rax      ;
        xor     rcx, rcx                        ; [in, optional]    hInstance
        mov     rdx, IDI_APPLICATION            ; [in]              lpCursorName
        call    LoadCursorA                     ; call
        mov     [wc + WNDCLASS.hCursor], rax    ; 
        mov     rcx, wc                         ; [in]              lpWndClass
        call    RegisterClassA                  ; call
        mov     [CLASS_ATOM], rax               ;
; Create window
        xor     rcx, rcx                                ; [in]              dwExStyle
        mov     rdx, CLASS_NAME                         ; [in, optional]    lpClassName
        mov     r8, WINDW_NAME                          ; [in, optional]    lpWindowName
        mov     r9, main_style                          ; [in]              dwStyle
        mov     qword [rsp+0x20], 360                   ; [in]              X
        mov     qword [rsp+0x28], 140                   ; [in]              Y
        mov     qword [rsp+0x30], 362                   ; [in]              nWidth
        mov     qword [rsp+0x38], 362                   ; [in]              nHeight
        mov     qword [rsp+0x40], 0                     ; [in, optional]    hWndParent
        mov     qword [rsp+0x48], 0                     ; [in, optional]    hMenu
        mov     rax, qword [wc + WNDCLASS.hInstance]    ;
        mov     qword [rsp+0x50], rax                   ; [in, optional]    hInstance
        mov     qword [rsp+0x58], 0                     ; [in, optional]    lpParam
        call    CreateWindowExA                         ; call
        mov     [ppWindow], rax                         ;
        mov     rcx, rax                                ; [in]              hWnd
        mov     rdx, sw_show                            ; [in]              nCmdShow
        call    ShowWindow                              ; call
        ;-----------------------------------------------
        xor     rcx, rcx
        mov     rdx, IID_ID2D1Factory
        xor     r8, r8
        mov     r9, ppIFactory
        call    D2D1CreateFactory

        mov     rcx, [ppWindow]
        mov     rdx, client_rect
        call    GetClientRect

        mov     rax, [ppWindow]
        mov     [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.hwnd], rax
        xor     rax, rax
        mov     eax, [client_rect + rect.right]
        mov     [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.width], eax
        mov     eax, [client_rect + rect.bottom]
        mov     [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.height], eax

        mov     rcx, [ppIFactory]
        mov     rbx, [rcx]
        lea     rdx, [render_target_properties + d2d1_render_target_properties.dpiX]
        lea     r8, [render_target_properties + d2d1_render_target_properties.dpiY]
        call    qword [rbx + 0x20]
;create render target
        mov     rcx, [ppIFactory]
        mov     rbx, [rcx]
        mov     rdx, render_target_properties
        mov     r8, hwnd_render_target_properties
        mov     r9, pphwndRenderTarget
        call    qword [rbx + 0x70]
; create solid color brush
        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        mov     rdx, color_black
        xor     r8, r8
        mov     r9, ppsolidColorBrush
        call    qword [rbx+0x40]
; begin draw
        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        call    qword [rbx + 0x180]
; draw line
        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        mov     rdx, draw_rect
        mov     r8, [ppsolidColorBrush]
        call    qword [rbx + 0x88]

        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        mov     rdx, draw_rect2
        mov     r8, [ppsolidColorBrush]
        call    qword [rbx + 0x88]

        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        mov     rdx, ellipse
        mov     r8, [ppsolidColorBrush]
        call    qword [rbx + 0xa8]
; end draw
        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        mov     rdx, ppTag1
        mov     r8, ppTag2
        call    qword [rbx + 0x188]
; clear canvas
        ;xor     rax, rax
        ;mov     rcx, [pphwndRenderTarget]
        ;mov     rbx, [rcx]
        ;mov     rdx, color_black
        ;call    qword [rbx+0x178]
        ;mov     rcx, message
        ;mov     rdx, rax
        ;call    printf
        myloop:
        jmp myloop
        add     rsp, 104             ; clear stack
        ret
wndproc:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 64
    mov     qword [rsp+0x20], rcx
    mov     qword [rsp+0x28], rdx
    mov     qword [rsp+0x30], r8
    mov     qword [rsp+0x38], r9
    cmp     rdx, wm_close
    je      Lclose
    cmp     rdx, wm_paint
    je      Lpaint
    cmp     rdx, wm_erasebkgnd
    je      Lerasebkgnd
    jmp     Ldefault
Lclose:
    xor     rcx, rcx
    call    PostQuitMessage
    jmp     Lfinish
Lpaint:
    mov     rcx, qword [rsp+0x20]
    xor     rdx, rdx
    call    ValidateRect
    xor     rax, rax
    jmp     Lfinish
Lerasebkgnd:
    mov     rax, 1
    jmp     Lfinish
Ldefault:
    mov     rcx, qword [rsp+0x20]
    mov     rdx, qword [rsp+0x28]
    mov     r8, qword [rsp+0x30]
    mov     r9, qword [rsp+0x38]
    call    DefWindowProcA
    jmp     Lfinish
Lfinish:
    mov     rsp, rbp
    pop     rbp
    ret