#include <windows.h>

LANGUAGE LANG_ENGLISH, SUBLANG_ENGLISH_US

VS_VERSION_INFO VERSIONINFO
    FILEVERSION %VERSION_MAJOR,%VERSION_MINOR,%VERSION_REVISION,%VERSION_BUILD
    PRODUCTVERSION %VERSION_MAJOR,%VERSION_MINOR,%VERSION_REVISION,%VERSION_BUILD
    FILEFLAGSMASK VS_FFI_FILEFLAGSMASK
    FILEFLAGS 0x0L
    FILEOS VOS_NT_WINDOWS32
%IFDEF APP_FILENAME
    FILETYPE VFT_APP
%ELSE
    FILETYPE VFT_DLL
%ENDIF
    FILESUBTYPE VFT2_UNKNOWN
{
    BLOCK "StringFileInfo"
    {
        BLOCK "040904b0"
        {
            VALUE "CompanyName", "Yegor Mialyk"
            VALUE "FileDescription", "%NAME"
            VALUE "FileVersion", "%VERSION_MAJOR.%VERSION_MINOR.%VERSION_REVISION"
            VALUE "LegalCopyright", "Copyright (C) 1995-%CURRENT_YEAR, Yegor Mialyk. All Rights Reserved."
%IFDEF APP_FILENAME
            VALUE "InternalName", "%APP_FILENAME"
            VALUE "OriginalFilename", "%APP_FILENAME.exe"
%ELSE
            VALUE "InternalName", "%DLL_FILENAME"
            VALUE "OriginalFilename", "%DLL_FILENAME.dll"
%ENDIF
            VALUE "ProductName", "%NAME"
            VALUE "ProductVersion", "%VERSION_MAJOR.%VERSION_MINOR.%VERSION_REVISION"
        }
    }
    BLOCK "VarFileInfo"
    {
        VALUE "Translation", 0x409, 1200
    }
}
