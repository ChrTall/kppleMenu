#  SPDX-FileCopyrightText: 2024 Christian Tallner <chrtall@gmx.de>
#
#  SPDX-License-Identifier: GPL-2.0-or-later
cmake_minimum_required(VERSION 3.16 FATAL_ERROR)
project(com.github.chrtall.kppleMenu)

set(VERSION 6.0.0)
set(AUTHOR, "ChrTall")
set(EMAIL, "chrtall@gmx.de")
set(PLASMA_MIN_VERSION "6.0.0")
set(KF6_MIN_VERSION "6.0.0")
set(QT_MIN_VERSION "6.6.0")
set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS 1)

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

find_package(Qt6 CONFIG REQUIRED NO_MODULE COMPONENTS
        Gui
        Qml
        Quick
        Core
)
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
        CoreAddons
        Declarative
        Kirigami
        Package
        Svg
)
find_package(KF6KirigamiAddons 0.10 REQUIRED)
find_package(Plasma ${PLASMA_MIN_VERSION} REQUIRED)

include(ECMFindQmlModule)
include(CheckIncludeFiles)
include(QtVersionOption)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

plasma_install_package(package com.github.chrtall.kppleMenu)

#add_subdirectory(package)
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
