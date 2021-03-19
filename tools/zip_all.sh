#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."
pushd "$project_root/build"

zip RaiseAndShine_win32 -j RaiseAndShine_win32.{exe,pck} height_algorithm_win32.dll
zip RaiseAndShine_win64 -j RaiseAndShine_win64.{exe,pck} height_algorithm_win64.dll
zip RaiseAndShine_linux32 -j RaiseAndShine_linux32.{x86,pck} height_algorithm_linux32.so
zip RaiseAndShine_linux64 -j RaiseAndShine_linux64.{x86_64,pck} height_algorithm_linux64.so
zip RaiseAndShine_web -j web/*

popd
