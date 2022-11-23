#disables mounting of ISOs via file explorer. thanks to https://support.huntress.io/hc/en-us/articles/11477430445587-How-to-disable-ISO-mounting#
reg add "HKEY_CLASSES_ROOT\Windows.IsoFile\shell\mount" /v "ProgrammaticAccessOnly" /t REG_SZ /d no /f
