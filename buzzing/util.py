# -*- coding: utf-8 -*-

import toml
import os
import sys
import tempfile
import shutil
import filecmp
import pdb
import re
import difflib
import shlex
import subprocess
import argparse

files = [
    "command.proto",
    "entity.proto",
    "error.proto",
    "gateway.proto",
    "sdk.proto",
    "service.proto",
    "user.proto",
    "server.proto",
    "feed.proto",
    "chat.proto",
    "dept.proto",
    "message.proto",
    "pipeline.proto",
    "calendar.proto",
    "meeting.proto",
    "mute.proto",
    "invite.proto",
    "join_request.proto",
    "pin.proto",
    "thread.proto",
    "presence.proto",
    "typing.proto",
    "search.proto",
    "timer.proto",
    "translate.proto",
    "openapp.proto",
    "setting.proto",
]

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def loge(msg):
    print((bcolors.FAIL + msg + bcolors.ENDC))


def logi(msg):
    print((bcolors.OKGREEN + msg + bcolors.ENDC))


def logw(msg):
    print((bcolors.WARNING + msg + bcolors.ENDC))


def install_plugin():
    pass

def protoc_plugin():
    plugin = ''
    if sys.platform == 'win32':
        plugin = '../proto/protobuf/windows/protoc-gen-rust.exe'
    return plugin

def gen_command_dart(p, src, out, plugin):
    source = src + "/" + p
    cmd = (f"protoc "
           f"--proto_path='{src}' "
           f" --dart_out='{out}' '{source}' "
           )
    return cmd

# generate proto files
def gen_pb(fn, args):
    for p in files:
        cmd = fn(p, args.src, args.outdir, args.plugin)
        print(cmd)
        cmd = shlex.split(cmd)
        subprocess.call(cmd)
    pass

windows_target_debug = "./build/windows/x64/runner/Debug/"
windows_target_release = "./build/windows/x64/runner/Release/"
windows_src = "target/release/buzzing.dll"

macos_target_debug = "build/macos/Build/Products/Debug/buzzing.app/Contents/Frameworks"
macos_target_release = "build/macos/Build/Products/Release/buzzing.app/Contents/Frameworks"
macos_src = "target/release/libbuzzing.dylib"

def copy_lib(src, t):
    target = ""
    if sys.platform.startswith("win"):
        if t == "debug":
            target = windows_target_debug
        else:
            target = windows_target_release
        src = src + "/" + windows_src
    elif sys.platform.startswith("darwin"):
        src = src + "/" + macos_src
        if t == "debug":
            target = macos_target_debug
        else:
            target = macos_target_release

    logi(f"start copy lib, src: {src}, target: {target}")
    shutil.copy(src, target)

def build():
    if sys.platform.startswith("win"):
        cmd = "flutter build windows"
    elif sys.platform.startswith("darwin"):
        cmd = "flutter build macos"

    logi(f"start build: {cmd}")
    cmd = shlex.split(cmd)
    subprocess.call(cmd)
    pass

def main():
    parser = argparse.ArgumentParser(prog="pb", description="generate protobuf files")
    parser.add_argument('-c', "--command", default="idl")
    parser.add_argument('-t', '--target')
    parser.add_argument('-o', '--outdir')
    parser.add_argument('-s', '--src')
    parser.add_argument('-p', '--plugin', default=protoc_plugin())
    parser.add_argument('-i', '--input')

    args = parser.parse_args()
    if args.command == "idl":
        f = gen_command_dart
        gen_pb(gen_command_dart, args)
    elif args.command == "lib":
        copy_lib(args.input, args.target)
    elif args.command == "build":
        build()

if __name__ == "__main__":
    main()
