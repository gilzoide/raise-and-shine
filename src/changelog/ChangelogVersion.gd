# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

const CURRENT_VERSION = 2
const DATE_FMT = "{year}-{month}-{day}"
const BBCODE_FMT = """[u][b]Build {build_number}[/b]  ({date})[/u]
{content}"""

export(int) var build_number = 0
export(String) var date = DATE_FMT.format(OS.get_date())
export(String, MULTILINE) var description = ""
export(PoolStringArray) var added = PoolStringArray()
export(PoolStringArray) var changed = PoolStringArray()
export(PoolStringArray) var fixed = PoolStringArray()
export(PoolStringArray) var removed = PoolStringArray()


func generate_bbcode() -> String:
	var content = PoolStringArray()
	if not description.empty():
		content.append(description)
		content.append("")
	if not added.empty():
		content.append("[u]Added:[/u]\n• %s" % added.join("\n• "))
	if not changed.empty():
		content.append("[u]Changed:[/u]\n• %s" % changed.join("\n• "))
	if not fixed.empty():
		content.append("[u]Fixed:[/u]\n• %s" % fixed.join("\n• "))
	if not removed.empty():
		content.append("[u]Removed:[/u]\n• %s" % removed.join("\n• "))
	return BBCODE_FMT.format({
		build_number = build_number,
		date = date,
		content = content.join("\n"),
	})
