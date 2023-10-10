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
    at .alphaMode,  dd 3
    at .dpiX,       dd 0.0
    at .dpiY,       dd 0.0
    at .usage,      dd 0
    at .minLevel,   dd 0
    iend
color_black:
    istruc d3dcolorvalue
    at .r, dd 1.0
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
draw_rect2:
    istruc rect
    at .left,   dd 100.0
    at .top,    dd 100.0
    at .right,  dd 125.0
    at .bottom, dd 150.0
    iend
p0:
    istruc d2d_point_2f
    at .x,  dd 0.0
    at .y,  dd 0.0
    iend
p1:
    istruc d2d_point_2f
    at .x,  dd 50.0
    at .y,  dd 50.0
    iend
ellipse:
    istruc d2d1_ellipse
    at .x,          dd 200.0
    at .y,          dd 100.0
    at .radiusX,    dd 25.0
    at .radiusY,    dd 25.0
    iend