; Socket Constants
    AI_PASSIVE:         dd 1
    AF_INET:            dd 2
    SOCK_DGRAM:         dd 2
    IPPROTO_UDP:        dd 17
    DEFAULT_PORT:       db "27015", 0
; Start Box
    StartBoxText:       db "Join as client.", 0
    StartBoxCaption:    db "Select", 0
    StartBoxType:       dd 4
; Abort Box
    AbortBoxType:       dd 5