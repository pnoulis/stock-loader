#!/bin/bash

PNAME='stock-loader'
DPROJ='stockLoader.dproj'
PROOT="$(dirname "$(dirname "$(realpath "$0")")")"
PLATFORM='Win32'
TARGET='Release'
VERSION=''
PBUILD_OUTPUT_NAME=''
COMPRESS=''

function formatSrc() {
    # -r -> recursive
    # -delphi -> formats only those filse with known delphi extensions
    # -d -> format all files with delphi extensions within the directory
    # -config -> configuration options for the formatter
    tools/Formatter.exe -delphi -r -config:"config/pa.config" -d:"src/"
}

function usage() {
    echo "Usage: $(basename $0) [-b] [-f] [-c [zip | tarball]]"
    exit 1
}

function clean() {
    rm -drf build/*
    mkdir -p build/"$PBUILD_OUTPUT_NAME"/{bin,config}
}

function initBuild() {
    local succeeded=0;
    preBuild
    succeeded=$?
    build
    succeeded=$?
    if [ $succeeded -eq 0 ]; then
        postBuild
    else
        echo Build Failed
    fi
}

function postBuild() {
    mv build/$PLATFORM/$TARGET/${DPROJ/dproj/exe} build/${PBUILD_OUTPUT_NAME}/bin
    rm -drf build/$PLATFORM
    compress
}

function build() {
    export dproj=src/$DPROJ
    export platform=$PLATFORM
    WSLENV=$WSLENV:dproj/w:platform/w powershell.exe -File ./scripts/build.ps1
    return $?
}

function preBuild() {
    formatSrc
    clean
    make_config
}



function get_version() {
    awk --field-separator '=' '$1 == "version" {print $2}' config/config.ini
}

function make_pbuild_output_name() {
    echo "${PNAME}-${PLATFORM}-${VERSION}"
}

function make_config() {
    awk '\
$0 ~ /^\[.*\]$/ {section = $0; target = ""}
section == "[DBCONN_MSSQL_RELEASE]" {target = "dbconn"}
section == "[ABOUT]" {target = "about"}
target == "dbconn" {print $0}
target == "about" {print $0}' config/config.ini > build/"$PBUILD_OUTPUT_NAME"/config/config.ini
}

function compress() {
    if [ "$COMPRESS" = "zip" ]; then
        zip build/"$PBUILD_OUTPUT_NAME".zip build/"$PBUILD_OUTPUT_NAME"
    elif [ "$COMPRESS" = "tarball" ]; then
        tar -caf build/"$PBUILD_OUTPUT_NAME".tar.gz build/"$PBUILD_OUTPUT_NAME"
    else
        zip build/"$PBUILD_OUTPUT_NAME".zip build/"$PBUILD_OUTPUT_NAME"
    fi
}


cd "$PROOT"
VERSION="$(get_version)"
PBUILD_OUTPUT_NAME="$(make_pbuild_output_name)"

while getopts ':fc:' OPTION; do
    case "$OPTION" in
        f)
            formatSrc
            exit 0
            ;;
        c)
            COMPRESS="$OPTARG"
            ;;
        ?)
        usage
        ;;
    esac
done

initBuild;

