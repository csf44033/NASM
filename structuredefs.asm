struc matrix3x2f
    ._11: resd 1
    ._12: resd 1
    ._21: resd 1
    ._22: resd 1
    ._31: resd 1
    ._32: resd 1
    endstruc
struc d2d1_ellipse
    .x: resd 1
    .y: resd 1
    .radiusX: resd 1
    .radiusY: resd 1
    endstruc
struc d2d_point_2f
    .x: resd 1
    .y: resd 1
    endstruc
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
struc MAKEWORD
    .bLow:  resb 1
    .bHigh: resb 1
endstruc
struc WSAData
    .wVersion:          resw 1
    .wHighVersion:      resw 1
    .iMaxSockets:       resw 1
    .iMaxUdpDg:         resw 1
    .lpVendorInfo:      resq 1
    .scDescription:     resb 257
    .szSystemStatus:    resb 129
endstruc
struc addrinfo
    .ai_flags:      resd 1
    .ai_family:     resd 1
    .ai_socktype:   resd 1
    .ai_protocol:   resd 1
    .ai_addrlen:    resq 1
    .ai_canonname:  resq 1
    .ai_addr:       resq 1
    .ai_next:       resq 1
endstruc