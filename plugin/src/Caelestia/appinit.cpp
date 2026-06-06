// SPDX-License-Identifier: GPL-3.0-only
// SPDX-FileCopyrightText: (C) 2025 Caelestia Contributors
//
// This file ensures QCoreApplication organizationName and organizationDomain
// are set before any QML Settings {} component tries to use QSettings.
// Without these identifiers, QSettings cannot determine where to store data:
//
//   WARN scene: QML Settings at .../AIState.qml[47:33]: Failed to initialize
//     QSettings instance. Status code is: 1
//   WARN scene: QML Settings at .../AIState.qml[47:33]: The following
//     application identifiers have not been set:
//     QList("organizationName", "organizationDomain")

#include <qcoreapplication.h>

namespace {

// Static object whose constructor runs when this shared library is loaded
// (during QML import resolution for "Caelestia"). By that time Quickshell
// has already created QCoreApplication, so the setters work correctly.
// This must complete before any QML file instantiates a Settings {} component.
struct CaelestiaAppInit {
    CaelestiaAppInit() {
        QCoreApplication::setOrganizationName(QStringLiteral("Caelestia"));
        QCoreApplication::setOrganizationDomain(QStringLiteral("caelestia-dots.github.io"));
        QCoreApplication::setApplicationName(QStringLiteral("caelestia-shell"));
    }
};

// Static storage duration ensures initialization at library load time.
// The compiler is allowed to elide this (constant initialization), but
// since we call non-constexpr functions, it must perform dynamic init.
CaelestiaAppInit init;

} // anonymous namespace
