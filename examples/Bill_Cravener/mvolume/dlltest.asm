; ####################################################
;       William F. Cravener 6/10/2003
; ####################################################
    
        .486
        .model flat,stdcall
        option casemap:none   ; case sensitive
    
; ####################################################
    
        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\comctl32.inc
        include \masm32\include\gdi32.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\comctl32.lib
        includelib \masm32\lib\gdi32.lib

; ####################################################

        ID_SLIDER1 equ 1001

        MIXER_ERROR equ 0FFFFFFFFh

; --------------------------------------------------------
    
        ChangeVolume PROTO :DWORD,:DWORD,:DWORD,:DWORD

; --------------------------------------------------------
    
.data
        DllName       db "VolCtrl.dll",0

        FuncNameGet   db "GetMasterVolume",0
        FuncNameSet   db "SetMasterVolume",0
        FuncNameClose db "CloseMasterVolume",0

        DllNotFound   db "Cannot load VolCtrl.dll",0
        MixerError    db "Error occured accessing Mixer",0
        Dlgname       db "VOLCONTROL",0
        hLibHandle    dd ?

        GetVolAddr    dd ?
        SetVolAddr    dd ?
        CloseVolAddr  dd ?

.data?

        hInstance HINSTANCE ?
        icex INITCOMMONCONTROLSEX <?>

; ###############################################################
    
.code
    
start:
    
        invoke GetModuleHandle,0
        mov hInstance,eax

; -----------------------------
;   Init common control classes
; -----------------------------
        mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
        mov icex.dwICC,0FFFFh
        invoke InitCommonControlsEx,ADDR icex

; ------------------------------------------------
;   Load Volume Control DLL and get proc addresses
; ------------------------------------------------
        invoke LoadLibrary,ADDR DllName
        .if eax == 0
            invoke MessageBox,0,ADDR DllNotFound,0,MB_OK
        .else
            mov hLibHandle,eax
            invoke GetProcAddress,hLibHandle,ADDR FuncNameGet
            mov GetVolAddr,eax
            invoke GetProcAddress,hLibHandle,ADDR FuncNameSet
            mov SetVolAddr,eax
            invoke GetProcAddress,hLibHandle,ADDR FuncNameClose
            mov CloseVolAddr,eax
        .endif

; ---------------------------------------------
;   Call the dialog box stored in resource file
; ---------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR Dlgname,0,ADDR ChangeVolume,0
        invoke FreeLibrary,hLibHandle
        invoke ExitProcess,eax
    
; ###############################################################
    
ChangeVolume proc hWin:DWORD,uMsg:DWORD,aParam:DWORD,bParam:DWORD
    
    LOCAL Ps:PAINTSTRUCT
    
        .if uMsg == WM_INITDIALOG
                    invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_SETRANGEMIN,FALSE,0
                    invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_SETRANGEMAX,FALSE,65535
                    invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_SETLINESIZE,FALSE,65
                    ;-------------------------------------------------------- 
                    ; Open the mixer control and get the current volume value
                    ;--------------------------------------------------------
                    call [GetVolAddr]
                    .if eax == MIXER_ERROR
                        invoke MessageBox,0,ADDR MixerError,0,MB_OK
                        invoke SendMessage,hWin,WM_CLOSE,0,0
                    .else
                        invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_SETPOS,TRUE,eax
                    .endif
                    
        .elseif uMsg == WM_PAINT
                        invoke BeginPaint,hWin,ADDR Ps
                        invoke EndPaint,hWin,ADDR Ps

        .elseif uMsg == WM_CLOSE
                        ;------------------------------------------
                        ; Be sure to close the mixer volume control
                        ; -----------------------------------------  
                        call [CloseVolAddr]
                        invoke EndDialog,hWin,0

        .elseif uMsg == WM_HSCROLL
                        mov eax,aParam
                        and eax,0FFFFh  
                        .if eax == TB_THUMBTRACK or TB_THUMBPOSITION
                            mov eax,aParam
                            shr eax,16
                            ;-------------------------------- 
                            ;Set the new volume control value
                            ;-------------------------------- 
                            push eax
                            call [SetVolAddr]
                 
                    .elseif eax == TB_LINEUP      
                            invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_GETPOS,0,0
                            ;-------------------------------- 
                            ;Set the new volume control value
                            ;-------------------------------- 
                            push eax
                            call [SetVolAddr]
                 
                    .elseif eax == TB_LINEDOWN
                            invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_GETPOS,0,0
                            ;-------------------------------- 
                            ;Set the new volume control value
                            ;-------------------------------- 
                            push eax
                            call [SetVolAddr]
                 
                    .elseif eax == TB_PAGEUP
                            invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_GETPOS,0,0
                            ;-------------------------------- 
                            ;Set the new volume control value
                            ;-------------------------------- 
                            push eax
                            call [SetVolAddr]
                 
                    .elseif eax == TB_PAGEDOWN
                            invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_GETPOS,0,0
                            ;-------------------------------- 
                            ;Set the new volume control value
                            ;-------------------------------- 
                            push eax
                            call [SetVolAddr]

                    .elseif eax == TB_TOP
                            invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_GETPOS,0,0
                            ;-------------------------------- 
                            ;Set the new volume control value
                            ;-------------------------------- 
                            push eax
                            call [SetVolAddr]

                    .elseif eax == TB_BOTTOM
                            invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_GETPOS,0,0
                            ;-------------------------------- 
                            ;Set the new volume control value
                            ;-------------------------------- 
                            push eax
                            call [SetVolAddr]
                    .endif

        .endif
        xor eax,eax
        ret 
    
ChangeVolume endp
    
; ###############################################################

end start
