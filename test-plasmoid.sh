#!/bin/bash
#  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
#
#  SPDX-License-Identifier: GPL-2.0-or-later
QT_LOGGING_RULES="qml.debug=true" plasmoidviewer -s 800x800 -f horizontal -x 2200 -y 200 -a package/
