/*
 *  SPDX-FileCopyrightText: 2020 Kpple <info.kpple@gmail.com>
 *  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.0
import org.kde.plasma.configuration 2.0 as PlasmaConfig

PlasmaConfig.ConfigModel {

    PlasmaConfig.ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "config/configGeneral.qml"
    }
}

 
