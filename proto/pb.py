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
        plugin = './protobuf/windows/protoc-gen-rust.exe'
    return plugin

def gen_command_rust(src, out, plugin):
    cmd = (f"protoc "
           f"--plugin=protoc-gen-rust='{plugin}'"
           f" --rust_opt='expose_fields=true serde_derive=true serde_derive_cfg=target_arch=\"wasm32\" serde_attr_camelcase=true serde_enum_repr_i32=true'"
           f" --rust_out='{out}'  '{src}'"
           )
    logi(cmd)
    return cmd

def gen_command_dart(src, out, plugin):
    cmd = (f"protoc "
           f"--proto_path=. "
           f" --dart_out='{out}' '{src}' "
           )
    return cmd

def gen_command_go(src, out, plugin):
    logi(src)
    logi(out)
    cmd = (f"protoc "
           f"--proto_path=. "
           f"--go_opt=paths=source_relative "
           f" --go_out='{out}' '{src}' "
           )
    return cmd

def gen_command_python(src, out, plugin):
    cmd = (f"protoc "
           f"--proto_path=. "
           f" --python_out='{out}' '{src}' "
           )
    return cmd


# generate proto files
def gen_pb(configs, f, args):
    protos = configs['proto']
    ignores = configs[args.target]
    for src in protos['files']:
        if ignores.__contains__(src):
            continue
        cmd = f(src, args.outdir, args.plugin)
        print(cmd)
        cmd = shlex.split(cmd)
        subprocess.call(cmd)
    pass

def main():
    parser = argparse.ArgumentParser(prog="pb", description="generate protobuf files")
    parser.add_argument('-c', "--config", default="proto.toml")
    parser.add_argument('-t', '--target', choices=['golang', 'dart', 'rust', 'python'])
    parser.add_argument('-o', '--outdir')
    parser.add_argument('-p', '--plugin', default=protoc_plugin())
    print("hello")
    loge("hello")

    args = parser.parse_args()
    configs = toml.load(args.config)
    loge(str(configs))
    f = gen_command_go
    if args.target == 'golang':
        f = gen_command_go
    elif args.target == 'rust':
        f = gen_command_rust
    elif args.target == 'dart':
        f = gen_command_dart
    elif args.target == 'python':
        f = gen_command_python

    gen_pb(configs, f, args)

if __name__ == "__main__":
    main()
