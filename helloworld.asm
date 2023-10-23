default rel
global  main
%include    "externals.asm"

%define PM_REMOVE 1h
; define data
segment .bss
    MessageBuffer resb 28
    otherName     resb 7
segment .data
    %include    "window_constants.asm"
    %include    "riid.asm"
    %include    "structuredefs.asm"
    %include    "structures.asm"
    %include    "variables.asm"
    classStyle		equ cs_vredraw|cs_hredraw|cs_dblclks|cs_owndc|cs_parentdc
    main_style		equ WS_VISIBLE|WS_TILEDWINDOW|WS_POPUP|WS_BORDER
    IDI_APPLICATION equ 32512
    IDC_ARROW       equ 32512
    localeName:         times 84 dw 0
    fontFamilyName:     times 84 dw 0
    scorebuf:           times 10 dw 0
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
    message2:           db "%ls",0xa, 0
    format0:            db "%",0,"s",0," ",0,"%",0,"d",0,0,0
    score:              dd 0
    mscore:             db "Score",0
    ErrorAbort:         db "Program Aborted: 0x%x", 0
;dwrite values
    dwrite_factory_type_shared:     dq 0
    dwrite_factory_type_isolated:   dq 1
    DWRITE_FONT_WEIGHT_THIN:        dq 100
    DWRITE_FONT_WEIGHT_EXTRA_LIGHT: dq 200
    DWRITE_FONT_WEIGHT_ULTRA_LIGHT: dq 200
    DWRITE_FONT_WEIGHT_LIGHT:       dq 300
    DWRITE_FONT_WEIGHT_SEMI_LIGHT:  dq 350
    DWRITE_FONT_WEIGHT_NORMAL:      dq 400
    DWRITE_FONT_WEIGHT_REGULAR:     dq 400
    DWRITE_FONT_WEIGHT_MEDIUM:      dq 500
    DWRITE_FONT_WEIGHT_DEMI_BOLD:   dq 600
    DWRITE_FONT_WEIGHT_SEMI_BOLD:   dq 600
    DWRITE_FONT_WEIGHT_BOLD:        dq 700
    DWRITE_FONT_WEIGHT_EXTRA_BOLD:  dq 800
    DWRITE_FONT_WEIGHT_ULTRA_BOLD:  dq 800
    DWRITE_FONT_WEIGHT_BLACK:       dq 900
    DWRITE_FONT_WEIGHT_HEAVY:       dq 900
    DWRITE_FONT_WEIGHT_EXTRA_BLACK: dq 950
    DWRITE_FONT_WEIGHT_ULTRA_BLACK: dq 950
    DWRITE_FONT_STYLE_NORMAL:       dq 0
    DWRITE_FONT_STYLE_OBLIQUE:      dq 1
    DWRITE_FONT_STYLE_ITALIC:       dq 2
    DWRITE_FONT_STRETCH_UNDEFINED:  dq 0
    DWRITE_FONT_STRETCH_ULTRA_CONDENSED: dq 1
    DWRITE_FONT_STRETCH_EXTRA_CONDENSED: dq 2
    DWRITE_FONT_STRETCH_CONDENSED:  dq 3
    DWRITE_FONT_STRETCH_SEMI_CONDENSED: dq 4
    DWRITE_FONT_STRETCH_NORMAL:     dq 5
    DWRITE_FONT_STRETCH_MEDIUM:     dq 5
    DWRITE_FONT_STRETCH_SEMI_EXPANDED: dq 6
    DWRITE_FONT_STRETCH_EXPANDED:   dq 7
    DWRITE_FONT_STRETCH_EXTRA_EXPANDED: dq 8
    DWRITE_FONT_STRETCH_ULTRA_EXPANDED: dq 9
    DWRITE_TEXT_ALIGNMENT_LEADING:  dq 0
    DWRITE_TEXT_ALIGNMENT_TRAILING: dq 1
    DWRITE_TEXT_ALIGNMENT_CENTER:   dq 2
    DWRITE_TEXT_ALIGNMENT_JUSTIFIED:dq 3
    DWRITE_PARAGRAPH_ALIGNMENT_NEAR:    dq 0
    DWRITE_PARAGRAPH_ALIGNMENT_FAR:     dq 1
    DWRITE_PARAGRAPH_ALIGNMENT_CENTER:  dq 2
    ppWriteFactory:                 dq 0
    ppFontCollection:               dq 0
    ppWriteTextFormat:              dq 0
    ppFontFamily:                   dq 0
    ppFamilyNames:                  dq 0
    length:                         dd 0
; main code
section .text
main:
; home space
    sub     rsp, 104
; WSA Startup
    mov     cx, [SocketVersion]
    mov     rdx, WSADATA
    call    WSAStartup
    cmp     rax, 0
    jnz     abort
; start box
    xor     rcx, rcx
    mov     rdx, StartBoxText
    mov     r8, StartBoxCaption
    mov     r9d, [StartBoxType]
    call    MessageBoxA
    cmp     eax, 7
    je      ServerHost
; Server Client
;   ignore client right now because no way to input server
    jmp     OpenWindow
ServerHost:
; Set Server Hints
    mov     eax, [AF_INET]
    mov     dword [SocketHints + addrinfo.ai_family], eax
    mov     eax, [SOCK_DGRAM]
    mov     dword [SocketHints + addrinfo.ai_socktype], eax
    mov     eax, [IPPROTO_UDP]
    mov     dword [SocketHints + addrinfo.ai_protocol], eax
    mov     eax, [AI_PASSIVE]
    mov     dword [SocketHints + addrinfo.ai_flags], eax
; Get Addrinfo
    xor     rcx, rcx
    mov     rdx, DEFAULT_PORT
    mov     r8, SocketHints
    mov     r9, pResult
    call    getaddrinfo
    cmp     rax, 0
    jnz     ClearWSA
; Create socket
    mov     rbx, [pResult]
    mov     ecx, [rbx + addrinfo.ai_family]
    mov     edx, [rbx + addrinfo.ai_socktype]
    mov     r8d, [rbx + addrinfo.ai_protocol]
    call    socket
    cmp     eax, 0xffffffff
    je      FreeADDR
; bind socket and adder
    mov     [ListenSocket], rax
    mov     rcx, rax
    mov     rdx, [rbx + addrinfo.ai_addr]
    mov     r8d, [rbx + addrinfo.ai_addrlen]
    call    bind
    cmp     rax, 0
    jnz     SocketClose
    jmp     OpenWindow
SocketClose:
    mov     rcx, [ListenSocket]
    call    closesocket
FreeADDR:
    mov     rcx, [pResult]
    call    freeaddrinfo
ClearWSA:
    call    WSAGetLastError
    mov     rdx, rax
    call    WSACleanup
    jmp     abort
OpenWindow:
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
; get half width in 32 bit float
    mov     ebx, eax
    shr     ebx, 1
    mov     [half_width], ebx
    mov     [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.width], eax
    mov     eax, [client_rect + rect.bottom]
; get half height in 32 bit float
    mov     ebx, eax
    shr     ebx, 1
    mov     [half_height], ebx
    mov     [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.height], eax

    mov     rcx, [ppIFactory]
    mov     rbx, [rcx]
    lea     rdx, [render_target_properties + d2d1_render_target_properties.dpiX]
    lea     r8, [render_target_properties + d2d1_render_target_properties.dpiY]
    call    qword [rbx + 0x20]
; create render target
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
; create IDWriteFactory
    mov     rcx, [dwrite_factory_type_shared]
    mov     rdx, IID_IDWriteFactory
    mov     r8, ppWriteFactory
    call    DWriteCreateFactory
; getsystemfontcollection
    mov     rcx, [ppWriteFactory]
    mov     rbx, [rcx]
    mov     rdx, ppFontCollection
    xor     r8, r8
    call    [rbx + 0x18]
; get font family
    mov     rcx, [ppFontCollection]
    mov     rbx, [rcx]
    mov     rdx, 0
    mov     r8, ppFontFamily
    call    [rbx + 0x20]
; get font family name
    mov     rcx, [ppFontFamily]
    mov     rbx, [rcx]
    mov     rdx, ppFamilyNames
    call    [rbx + 0x30]
; get user default locale name
    mov     rcx, localeName
    mov     rdx, 85
    call    GetUserDefaultLocaleName
    mov     rcx, message2
    mov     rdx, localeName
    call    printf
; find locale name
    mov     rcx, [ppFamilyNames]
    mov     rbx, [rcx]
    mov     rdx, localeName
    mov     r8, ppTag1
    mov     r9, ppTag2
    call    [rbx + 0x20]
; get string length
    mov     rcx, [ppFamilyNames]
    mov     rbx, [rcx]
    mov     rdx, [ppTag1]
    mov     r8, length
    call    [rbx + 0x38]
    mov     rax, [length]
    add     rax, 1
; get string
    mov     rcx, [ppFamilyNames]
    mov     rbx, [rcx]
    mov     rdx, [ppTag1]
    mov     r8, fontFamilyName
    mov     rax, [length]
    add     rax, 1
    mov     r9, rax
    call    [rbx + 0x40]
    mov     rcx, message2
    mov     rdx, fontFamilyName
    call    printf
; create text format
    mov         rcx, [ppWriteFactory]
    mov         rbx, [rcx]
    mov         rdx, fontFamilyName                 ; fontFamilyName
    xor         r8, r8                              ; fontCollection
    mov         r9, [DWRITE_FONT_WEIGHT_REGULAR]       ; fontWeight;
    mov         rax, [DWRITE_FONT_STYLE_NORMAL]
    mov         qword [rsp + 0x20], rax             ; fontStyle
    mov         rax, [DWRITE_FONT_STRETCH_NORMAL]
    mov         qword [rsp + 0x28], rax             ; fontStretch
    mov         rax, 20
    cvtsi2ss    xmm0, rax
    movss       [rsp + 0x30], xmm0                  ; fontSize
    mov         rax, localeName
    mov         qword [rsp + 0x38], rax             ; localeName
    mov         rax, ppWriteTextFormat
    mov         qword [rsp + 0x40], rax             ; textFormat
    call        qword [rbx + 0x78]
; set text alignment
    mov     rcx, [ppWriteTextFormat]
    mov     rbx, [rcx]
    mov     rdx, [DWRITE_TEXT_ALIGNMENT_CENTER]
    call    qword [rbx + 0x18]
; set paragraph alignment
    mov     rcx, [ppWriteTextFormat]
    mov     rbx, [rcx]
    mov     rdx, [DWRITE_PARAGRAPH_ALIGNMENT_CENTER]
    call    qword [rbx + 0x20]
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
; move ball x
    cvtss2si    ecx, [Matrix1 + matrix3x2f._31]
    add         ecx, [velocity + d2d_point_2f.x]
    cmp         ecx, [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.width]
    jb      c3
; past right side of screen
    mov     ecx, [hwnd_render_target_properties + d2d1_hwnd_render_target_properties.width]
    neg     dword [velocity + d2d_point_2f.x]
    add     dword [score], 1
c3:
    mov         rax, rcx
    cvtss2si    rbx, [Matrix0 + matrix3x2f._31]
    sub         rax, rbx
    cvtss2si    rbx, [pad + rect.right]
    sub         rax, rbx
    cmp         rax, 0
    ja          c4
; distance from pad is less than zero
    cvtss2si    eax, [Matrix0 + matrix3x2f._32]
    cvtss2si    ebx, [Matrix1 + matrix3x2f._32]
    sub         ebx, eax
    mov         edx, ebx
    neg         edx
    cmovs       edx, ebx
    cvtss2si    eax, [pad + rect.bottom]
    cmp         eax, edx
    jb          c4
; ball between pad
    cvtss2si    rbx, [pad + rect.right]
    cvtss2si    rcx, [Matrix0 + matrix3x2f._31]
    add         rcx, rbx
    neg         dword [velocity + d2d_point_2f.x]
    add         dword [score], 1
c4:
    cmp     ecx, 0
    ja      c5
    mov     dword [score], 0
    mov     rcx, 200
c5:
; update position
    cvtsi2ss    xmm0, ecx
    movss       [Matrix1 + matrix3x2f._31], xmm0
; mov ball y
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
    jb          c6
    mov         eax, [velocity + d2d_point_2f.y]
    mul         r8d
    add         eax, r8d
    mov         ecx, eax
    neg         dword[velocity + d2d_point_2f.y]
c6:
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
; draw text
    mov     rcx, scorebuf
    mov     rdx, format0
    mov     r8, mscore
    mov     r9d, [score]
    call    __mingw_swprintf
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, IdentityMatrix
    call    qword [rbx + 0xf0]
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, scorebuf
    mov     r8, 10
    mov     r9, [ppWriteTextFormat]
    mov     rax, TextBox0
    mov     qword [rsp + 0x20], rax; layoutRect
    mov     rax, [ppwhiteBrush]
    mov     qword [rsp + 0x28], rax
    mov     qword [rsp + 0x30], 0; options
    mov     qword [rsp + 0x38], 0; measuringMode
    call    qword [rbx + 0xd8]
; end draw
    mov     rcx, [pphwndRenderTarget]
    mov     rbx, [rcx]
    mov     rdx, ppTag1
    mov     r8, ppTag2
    call    qword [rbx + 0x188]
    
    jmp myloop
abort:
    mov     rcx, ErrorAbort
    mov     rdx, rax
    call    printf
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