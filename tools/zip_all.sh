#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."
pushd "$project_root/build"

zip RaiseAndShine_win32 -j RaiseAndShine_win32.{exe,pck}
zip RaiseAndShine_linux32 -j RaiseAndShine_linux32.{x86,pck}
zip RaiseAndShine_linux64 -j RaiseAndShine_linux64.{x86_64,pck}
zip RaiseAndShine_web -j web/*

popd
