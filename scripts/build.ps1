$ENV:BDS="C:\Program Files (x86)\Embarcadero\Studio\22.0"
$ENV:FrameworkDir="C:\Windows\Microsoft.NET\Framework\v4.0.30319"
$ENV:FrameworkVersion="v4.5"

msbuild $env:dproj /t:Build /p:configuration=release /p:platform=$env:platform

if ($?) {
    exit 0;
} else {
    exit 1;
}
