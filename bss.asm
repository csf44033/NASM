; qword buffers
    ppTag1              resq 1
    ppTag2              resq 1
    ppIFactory          resq 1
    pphwndRenderTarget  resq 1
    ppredBrush          resq 1
    ppwhiteBrush        resq 1
    ppWindow            resq 1
    pResult             resq 1
    ListenSocket        resq 1
    CLASS_ATOM          resq 1
    ppWriteFactory      resq 1
    ppFontCollection    resq 1
    ppWriteTextFormat   resq 1
    ppFontFamily        resq 1
    ppFamilyNames       resq 1
; dword buffers
    half_width          resd 1
    half_height         resd 1
    length              resd 1
; word buffers
    localeName          resw 84
    fontFamilyName      resw 84
    scorebuf            resw 10
; byte buffers
    keybuf              resb 32
    MessageBuffer       resb 28
    otherName           resb 7