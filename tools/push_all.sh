#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."

butler push --if-changed "$project_root/build/SpriteHeightNormalEditor_web.zip"      gilzoide/sprite-height-normal-editor:web
butler push --if-changed "$project_root/build/SpriteHeightNormalEditor_win32.zip"  gilzoide/sprite-height-normal-editor:win32
butler push --if-changed "$project_root/build/SpriteHeightNormalEditor_linux32.zip"  gilzoide/sprite-height-normal-editor:linux32
butler push --if-changed "$project_root/build/SpriteHeightNormalEditor_linux64.zip"  gilzoide/sprite-height-normal-editor:linux64
butler push --if-changed "$project_root/build/SpriteHeightNormalEditor_osx.zip"      gilzoide/sprite-height-normal-editor:osx

