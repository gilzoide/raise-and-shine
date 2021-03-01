#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."
pushd "$project_root/build"

zip SpriteHeightNormalEditor_win32 -j SpriteHeightNormalEditor_win32.{exe,pck}
zip SpriteHeightNormalEditor_linux32 -j SpriteHeightNormalEditor_linux32.{x86,pck}
zip SpriteHeightNormalEditor_linux64 -j SpriteHeightNormalEditor_linux64.{x86_64,pck}
zip SpriteHeightNormalEditor_web -j web/*

popd
