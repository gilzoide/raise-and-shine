# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends TabContainer


func select_next_tab() -> void:
	current_tab = posmod(current_tab + 1, get_tab_count())


func select_previous_tab() -> void:
	current_tab = posmod(current_tab - 1, get_tab_count())
