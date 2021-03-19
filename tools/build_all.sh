#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."

mkdir -p "$project_root/build/web"

project_file="$project_root/src/project.godot"
godot --no-window --export "HTML5" "../build/web/index.html" "$project_file"
godot --no-window --export "Windows x32" "../build/RaiseAndShine_win32.exe" "$project_file"
godot --no-window --export "Windows x64" "../build/RaiseAndShine_win64.exe" "$project_file"
godot --no-window --export "Mac OSX" "../build/RaiseAndShine_osx.zip" "$project_file"
godot --no-window --export "Linux/X11 x32" "../build/RaiseAndShine_linux32.x86" "$project_file"
godot --no-window --export "Linux/X11 x64" "../build/RaiseAndShine_linux64.x86_64" "$project_file"
