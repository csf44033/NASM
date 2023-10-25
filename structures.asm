wc:
    istruc WNDCLASS
    at .style,           dd classStyle
    at .lpfnWndProc,     dq wndproc
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
color_red:
    istruc d3dcolorvalue
    at .r, dd 1.0
    at .g, dd 0.0
    at .b, dd 0.0
    at .a, dd 1.0
    iend
color_white:
    istruc d3dcolorvalue
    at  .r, dd 1.0
    at  .g, dd 1.0
    at  .b, dd 1.0
    at  .a, dd 1.0
    iend
color_nothing:
    istruc d3dcolorvalue
    at .r, dd 0.0
    at .g, dd 0.0
    at .b, dd 0.0
    at .a, dd 0.0
    iend
pad:
    istruc rect
    at .left,   dd -5.0
    at .top,    dd -25.0
    at .right,  dd 5.0
    at .bottom, dd 25.0
    iend
ball:
    istruc d2d1_ellipse
    at .x,          dd 0.0
    at .y,          dd 0.0
    at .radiusX,    dd 5.0
    at .radiusY,    dd 5.0
    iend
velocity:
    istruc d2d_point_2f
    at .x,  dd 1
    at .y,  dd 1
    iend
IdentityMatrix:
    istruc matrix3x2f
    at ._11,    dd 1.0
    at ._12,    dd 0.0
    at ._21,    dd 0.0
    at ._22,    dd 1.0
    at ._31,    dd 0.0
    at ._32,    dd 0.0
    iend
Matrix0:
    istruc matrix3x2f
    at ._11,    dd 1.0
    at ._12,    dd 0.0
    at ._21,    dd 0.0
    at ._22,    dd 1.0
    at ._31,    dd 20.0
    at ._32,    dd 100.0
    iend
Matrix1:
    istruc matrix3x2f
    at ._11,    dd 1.0
    at ._12,    dd 0.0
    at ._21,    dd 0.0
    at ._22,    dd 1.0
    at ._31,    dd 200.0
    at ._32,    dd 100.0
    iend
TextBox0:
    istruc rect
    at .left,   dd 0.0
    at .top,    dd 0.0
    at .right,  dd 300.0
    at .bottom, dd 72.0
    iend
; Winsocks
    SocketVersion:
        istruc MAKEWORD
        at .bLow,   db 2
        at .bHigh,  db 2
        iend
    WSADATA:
        istruc WSAData
        iend
    ServerHints:
        istruc addrinfo
        at .ai_flags,       dd 1
        at .ai_family,      dd 2
        at .ai_socktype,    dd 2
        at .ai_protocol,    dd 17
        at .ai_addrlen,     dq 0
        at .ai_canonname,   dq 0
        at .ai_addr,        dq 0
        at .ai_next,        dq 0
        iend
    ClientHints:
        istruc addrinfo
        at .ai_flags,       dd 0
        at .ai_family,      dd 2
        at .ai_socktype,    dd 2
        at .ai_protocol,    dd 17
        at .ai_addrlen,     dq 0
        at .ai_canonname,   dq 0
        at .ai_addr,        dq 0
        at .ai_next,        dq 0
        iend