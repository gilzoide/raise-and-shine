#!/bin/sh

script_root=$(dirname $(realpath $0))
project_root="$script_root/.."

pushd "$project_root"

butler push "build/RaiseAndShine_web.zip"      gilzoide/raise-and-shine:web
butler push "build/RaiseAndShine_win32.zip"    gilzoide/raise-and-shine:win32
butler push "build/RaiseAndShine_linux32.zip"  gilzoide/raise-and-shine:linux32
butler push "build/RaiseAndShine_linux64.zip"  gilzoide/raise-and-shine:linux64
butler push "build/RaiseAndShine_osx.zip"      gilzoide/raise-and-shine:osx

popd
