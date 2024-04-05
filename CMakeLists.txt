cmake_minimum_required(VERSION 3.16)

project(org.chrtall.kppleMenu)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS 1)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})
include(QtVersionOption)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(FeatureSummary)

find_package(Qt6 CONFIG REQUIRED COMPONENTS
        Qml
        Core
)

find_package(Plasma REQUIRED)

plasma_install_package(package org.chrtall.kppleMenu)

#add_subdirectory(package)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)