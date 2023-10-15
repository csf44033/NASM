default rel
global  main
extern  printf, GetModuleHandleA, LoadIconA, LoadCursorA, RegisterClassA, DefWindowProcA, GetLastError, CreateWindowExA, ShowWindow, D2D1CreateFactory, GetClientRect, ValidateRect, PostQuitMessage, PeekMessageA, TranslateMessage, DispatchMessageA
%define PM_REMOVE 1h
; define data
segment .bss
    MessageBuffer resb 28
segment .data
    %include    "window_constants.asm"
    %include    "riid.asm"
    %include    "structuredefs.asm"
    %include    "structures.asm"
    classStyle		equ cs_vredraw|cs_hredraw|cs_dblclks|cs_owndc|cs_parentdc
    main_style		equ WS_VISIBLE|WS_TILEDWINDOW|WS_POPUP|WS_BORDER
    IDI_APPLICATION equ 32512
    IDC_ARROW       equ 32512
    keybuf:             times 32 db 0
    half_height:        dd 0
    half_width:         dd 0
    WINDW_NAME: 	    db "All Assembly DirectX Sample", 0
    CLASS_NAME:         db "My Class", 0
    CLASS_ATOM:         dq 0
    float_None:         dd -1.0
    float_zero:         dd 0.0
    float_one:          dd 1.0
    float_two:          dd 2.0
    float_fifty:        dd 50.0
    ppTag1:             dq 0
    ppTag2:             dq 0
    ppIFactory:         dq 0
    pphwndRenderTarget: dq 0
    ppredBrush:         dq 0
    ppwhiteBrush:       dq 0
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

    movss   xmm1, [float_two]
    mov     rax, [ppWindow]
    mov     [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.hwnd], rax
    mov     eax, [client_rect + rect.right]
;get half width in 32 bit float
    mov     ebx, eax
    shr     ebx, 1
    mov     [half_width], ebx
    mov     [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.width], eax
    mov     eax, [client_rect + rect.bottom]
;get half height in 32 bit float
    mov     ebx, eax
    shr     ebx, 1
    mov     [half_height], ebx
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

; create red brush
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, color_red
    xor     r8, r8
    mov     r9, ppredBrush
    call    qword [rbx+0x40]
; create white brush
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, color_white
    xor     r8, r8
    mov     r9, ppwhiteBrush
    call    qword [rbx+0x40]

    mov     rcx, message
    mov     edx, [half_width]
    call    printf
myloop:
    mov     rcx, MessageBuffer
    xor     rdx, rdx
    xor     r8, r8
    xor     r9, r9
    mov     qword[rsp+0x20], PM_REMOVE
    call    PeekMessageA
    cmp     rax, 0
    je      myDraw
    mov     rcx, MessageBuffer
    call    TranslateMessage
    mov     rcx, MessageBuffer
    call    DispatchMessageA
myDraw:
;up key check
    mov     rcx, keybuf
    mov     rdx, 4
    xor     r8, r8
    mov     r8b, [rcx + rdx]
    shr     r8b, 6
    and     r8b, 1
    jz      c1
    cvtss2si    rax, [Matrix0 + matrix3x2f._32]
    sub         rax, 1
    cvtsi2ss    xmm0, rax
    movss       [Matrix0 + matrix3x2f._32], xmm0
c1:
;down key check
    mov     rcx, keybuf
    mov     rdx, 5
    xor     r8, r8
    mov     r8b, [rcx + rdx]
    and     r8b, 1
    jz      c2
    cvtss2si    rax, [Matrix0 + matrix3x2f._32]
    add         rax, 1
    cvtsi2ss    xmm0, rax
    movss       [Matrix0 + matrix3x2f._32], xmm0
c2:
; move ball
    mov         r8d, [half_width]
    cvtss2si    ecx, [Matrix1 + matrix3x2f._31]
    add         ecx, [velocity + d2d_point_2f.x]
    xor         rax, rax
    mov         eax, ecx
    sub         eax, r8d
    mov         edx, eax
    neg         edx
    cmovs       edx, eax
    cmp         edx, r8d
    jb          c3
    mov         eax, [velocity + d2d_point_2f.x]
    mul         r8d
    add         eax, r8d
    mov         ecx, eax
    neg         dword[velocity + d2d_point_2f.x]
c3:
; update position
    cvtsi2ss    xmm0, ecx
    movss       [Matrix1 + matrix3x2f._31], xmm0

    mov         r8d, [half_height]
    cvtss2si    ecx, [Matrix1 + matrix3x2f._32]
    add         ecx, [velocity + d2d_point_2f.y]
    xor         rax, rax
    mov         eax, ecx
    sub         eax, r8d
    mov         edx, eax
    neg         edx
    cmovs       edx, eax
    cmp         edx, r8d
    jb          c4
    mov         eax, [velocity + d2d_point_2f.y]
    mul         r8d
    add         eax, r8d
    mov         ecx, eax
    neg         dword[velocity + d2d_point_2f.y]
c4:
; update position
    cvtsi2ss    xmm0, ecx
    movss       [Matrix1 + matrix3x2f._32], xmm0
; begin draw
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    call    qword [rbx + 0x180]
; clear canvas
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    xor     rdx, rdx
    call    qword [rbx+0x178]
;draw pad
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, Matrix0
    call    qword [rbx + 0xf0]
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, pad
    mov     r8, [ppwhiteBrush]
    call    qword [rbx + 0x88]
;draw ball
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, Matrix1
    call    qword [rbx + 0xf0]
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, ball
    mov     r8, [ppredBrush]
    call    qword [rbx + 0xa8]
; end draw
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, ppTag1
    mov     r8, ppTag2
    call    qword [rbx + 0x188]
    
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
    cmp     rdx, wm_keyup
    je      Lkeyup
    cmp     rdx, wm_keydown
    je      Lkeydown
    jmp     Ldefault
Lkeyup:
    mov cl, r8b
    and cl, 7
    mov al, 1
    shl al, cl
    xor al, 0xff
    mov rbx, r8
    shr rbx, 3
    mov rcx, keybuf
    and byte [rcx + rbx], al

    mov rcx, [rsp + 0x20]
    mov rdx, [rsp + 0x28]
    mov r8, [rsp + 0x30]
    mov r9, [rsp + 0x38]
    jmp     Ldefault
Lkeydown:
    mov cl, r8b
    and cl, 7
    mov al, 1
    shl al, cl
    mov rbx, r8
    shr rbx, 3
    mov rcx, keybuf
    or byte [rcx + rbx], al

    mov rcx, message
    xor rdx, rdx
    mov dl, al
    call printf
    mov rcx, message
    mov rdx, rbx
    call printf

    mov rcx, [rsp + 0x20]
    mov rdx, [rsp + 0x28]
    mov r8, [rsp + 0x30]
    mov r9, [rsp + 0x38]
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