pragma ComponentBehavior: Bound

import ".."
import QtQuick
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.utils

CollapsibleSection {
    title: I18n.tr("Theme mode")
    description: I18n.tr("Light or dark theme")
    showBackground: true

    SwitchRow {
        label: I18n.tr("Dark mode")
        checked: !Colours.currentLight
        onToggled: checked => {
            Colours.setMode(checked ? "dark" : "light");
        }
    }
}
