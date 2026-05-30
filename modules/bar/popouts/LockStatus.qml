import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

ColumnLayout {
    spacing: Tokens.spacing.small

    StyledText {
        text: I18n.tr("Capslock: %1").arg(Hypr.capsLock ? "Enabled" : "Disabled")
    }

    StyledText {
        text: I18n.tr("Numlock: %1").arg(Hypr.numLock ? "Enabled" : "Disabled")
    }
}
