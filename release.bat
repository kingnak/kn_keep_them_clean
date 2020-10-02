rmdir /Q /S distr
mkdir distr
copy src\ChangeLog.txt distr

mkdir distr\Data
copy src\KN_KeepThemClean.esp distr\Data

mkdir "distr\Data\scripts"
copy src\scripts\AARiftPoolActivator.pex "distr\Data\scripts"
copy src\scripts\KN_KTC_BathPlayerScript.pex "distr\Data\scripts"
copy src\scripts\KN_KTC_BathQuest.pex "distr\Data\scripts"
copy src\scripts\KN_KTC_MaintenanceScript.pex "distr\Data\scripts"
copy src\scripts\KN_KTC_UpdateQuest.pex "distr\Data\scripts"

cd distr
"C:\Program Files\7-Zip\7z.exe" a "KN Keep Them Clean 1.0.7z" *
