default rel
global  main
extern  printf, GetModuleHandleA, LoadIconA, LoadCursorA, RegisterClassA, DefWindowProcA, GetLastError, CreateWindowExA, ShowWindow, D2D1CreateFactory, GetClientRect

; define data
segment .data
    %include    "window_constants.asm"
    %include    "riid.asm"
    struc d3dcolorvalue
        .r: resd 1
        .g: resd 1
        .b: resd 1
        .a: resd 1
    endstruc
    struc d2d1_hwnd_render_target_properties
        .hwnd:              resq 1
        .width:             resd 1
        .height:            resd 1
        .presentOptions:    resd 1
                            alignb 8
    endstruc
    struc d2d1_render_target_properties
        ._type:     resd 1
        .format:    resd 1
        .alphaMode: resd 1
        .dpiX:      resd 1
        .dpiY:      resd 1
        .usage:     resd 1
        .minLevel:  resd 1
                    alignb 8
    endstruc
    struc WNDCLASS
        .style:         resd 1
                        alignb 8
        .lpfnWndProc:   resq 1
        .cbClsExtra:    resd 1
        .cbWndExtra:    resd 1
        .hInstance:     resq 1
        .hIcon:         resq 1
        .hCursor:       resq 1
        .hbrBackground: resq 1
        .lpszMenuName:  resq 1
        .lpszClassName: resq 1
    endstruc
    struc rect
        .left:      resd 1
        .top:       resd 1
        .right:     resd 1
        .bottom:    resd 1
    endstruc
    classStyle		equ cs_vredraw|cs_hredraw|cs_dblclks|cs_owndc|cs_parentdc
    main_style		equ WS_VISIBLE|WS_TILEDWINDOW|WS_POPUP|WS_BORDER
    IDI_APPLICATION equ 32512
    IDC_ARROW       equ 32512
    WINDW_NAME: 	    db "All Assembly DirectX Sample", 0
    CLASS_NAME:         db "My Class", 0
    CLASS_ATOM:         dq 0
    float_one:          dd 1
    ppIFactory:         dq 0
    pphwndRenderTarget: dq 0
    ppsolidColorBrush:  dq 0
    ppWindow:           dq 0
    message:            db "%p", 0xa, 0
    wc:
        istruc WNDCLASS
            at .style,           dd classStyle
            at .lpfnWndProc,     dq DefWindowProcA
            at .cbClsExtra,      dd 0
            at .cbWndExtra,      dd 0
            at .hInstance,       dq 0
            at .hIcon,           dq 0
            at .hCursor,         dq 0
            at .hbrBackground,   dq 0
            at .lpszMenuName,    dq 0
            at .lpszClassName,   dq CLASS_NAME
        iend
    client_rect:
        istruc rect
        iend
    hwnd_render_target_properties:
        istruc d2d1_hwnd_render_target_properties
            at .hwnd,           dq 0
            at .width,          dd 0
            at .height,         dd 0
            at .presentOptions, dd 0
        iend
    render_target_properties:
        istruc d2d1_render_target_properties
            at ._type,      dd 0
            at .format,     dd 0
            at .alphaMode,  dd 0
            at .dpiX,       dd 0.0
            at .dpiY,       dd 0.0
            at .usage,      dd 0
            at .minLevel,   dd 0
        iend
    color_black:
        istruc d3dcolorvalue
            at .r, dd 0.0
            at .g, dd 0.0
            at .b, dd 0.0
            at .a, dd 1.0
        iend
    draw_rect:
        istruc rect
            at .left,   dd 0.0
            at .top,    dd 0.0
            at .right,  dd 50.0
            at .bottom, dd 50.0
        iend
; main code
section .text
    main:
        sub     rsp, 104             ; home space
        ;---------------------------------------
        ; Register class
        ;---------------------------------------
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
        ;---------------------------------------
        ; Create window
        ;-----------------------------------------------
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

        mov     rcx, [ppIFactory]
        mov     rbx, [rcx]
        mov     rdx, render_target_properties
        mov     r8, hwnd_render_target_properties
        mov     r9, pphwndRenderTarget
        call    qword [rbx + 0x70]

        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        mov     rdx, color_black
        mov     r8, ppsolidColorBrush
        call    qword [rbx + 0x40]
;pRT->BeginDraw();
        mov     rcx, [pphwndRenderTarget]
        mov     rbx, [rcx]
        call    qword [rbx + 0x180]
;pRT->DrawRectangle(
        mov         rcx, [pphwndRenderTarget]
        mov         rbx, [rcx]
        mov         rdx, draw_rect
        mov         r8, [ppsolidColorBrush]
        cvtsi2sd    xmm3, [float_one]
        mov         qword [rsp + 0x20], 0
        call        qword [rbx + 0x80]
;HRESULT hr = pRT->EndDraw();  

        mov     rcx, message
        mov     edx, [client_rect + rect.right]
        call    printf
        mov     rcx, message
        mov     rdx, [pphwndRenderTarget]
        call    printf
        ;myloop:
        ;jmp myloop
        add     rsp, 104             ; clear stack
        ret