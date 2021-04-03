# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

const CURRENT_VERSION = 1
const DATE_FMT = "{year}-{month}-{day}"
const BBCODE_FMT = """
[u][b]Build {build_number}[/b]  ({date})[/u]
{description}
{added}{changed}{fixed}{removed}
"""

export(int) var build_number = CURRENT_VERSION
export(String) var date = DATE_FMT.format(OS.get_date())
export(String, MULTILINE) var description = ""
export(PoolStringArray) var added = PoolStringArray()
export(PoolStringArray) var changed = PoolStringArray()
export(PoolStringArray) var fixed = PoolStringArray()
export(PoolStringArray) var removed = PoolStringArray()


func generate_bbcode() -> String:
	var added_text = "\nAdded:\n• %s" % added.join('\n• ') if not added.empty() else ""
	var changed_text = "\nChanged:\n%s" % changed.join('\n') if not changed.empty() else ""
	var fixed_text = "\nFixed:\n%s" % fixed.join('\n') if not fixed.empty() else ""
	var removed_text = "\nRemoved:\n%s" % removed.join('\n') if not removed.empty() else ""
	return BBCODE_FMT.format({
		'build_number': build_number,
		'date': date,
		'description': description,
		'added': added_text,
		'changed': changed_text,
		'fixed': fixed_text,
		'removed': removed_text,
	})
