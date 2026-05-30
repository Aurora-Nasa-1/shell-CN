import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

SectionContainer {
    id: root

    required property var rootItem
    // GPU toggle is hidden when gpuType is "NONE" (no GPU data available)
    readonly property bool gpuAvailable: SystemUsage.gpuType !== "NONE"
    // Battery toggle is hidden when no laptop battery is present
    readonly property bool batteryAvailable: UPower.displayDevice.isLaptopBattery

    Layout.fillWidth: true
    alignTop: true

    StyledText {
        text: I18n.tr("Performance Resources")
        font.pointSize: Tokens.font.size.normal
    }

    ConnectedButtonGroup {
        rootItem: root.rootItem
        options: {
            let opts = [];
            if (root.batteryAvailable)
                opts.push({
                    "label": I18n.tr("Battery"),
                    "propertyName": "showBattery",
                    "onToggled": function (checked) {
                        root.rootItem.showBattery = checked;
                        root.rootItem.saveConfig();
                    }
                });

            if (root.gpuAvailable)
                opts.push({
                    "label": I18n.tr("GPU"),
                    "propertyName": "showGpu",
                    "onToggled": function (checked) {
                        root.rootItem.showGpu = checked;
                        root.rootItem.saveConfig();
                    }
                });

            opts.push({
                "label": I18n.tr("CPU"),
                "propertyName": "showCpu",
                "onToggled": function (checked) {
                    root.rootItem.showCpu = checked;
                    root.rootItem.saveConfig();
                }
            }, {
                "label": I18n.tr("Memory"),
                "propertyName": "showMemory",
                "onToggled": function (checked) {
                    root.rootItem.showMemory = checked;
                    root.rootItem.saveConfig();
                }
            }, {
                "label": I18n.tr("Storage"),
                "propertyName": "showStorage",
                "onToggled": function (checked) {
                    root.rootItem.showStorage = checked;
                    root.rootItem.saveConfig();
                }
            }, {
                "label": I18n.tr("Network"),
                "propertyName": "showNetwork",
                "onToggled": function (checked) {
                    root.rootItem.showNetwork = checked;
                    root.rootItem.saveConfig();
                }
            });
            return opts;
        }
    }

    SliderInput {
        Layout.fillWidth: true

        label: I18n.tr("Resource update interval")
        value: root.rootItem.resourceUpdateInterval
        from: 100
        to: 10000
        stepSize: 100
        suffix: "ms"
        validator: IntValidator {
            bottom: 100
            top: 10000
        }
        formatValueFunction: val => Math.round(val).toString()
        parseValueFunction: text => parseInt(text)

        onValueModified: newValue => {
            root.rootItem.resourceUpdateInterval = Math.round(newValue);
            root.rootItem.saveConfig();
        }
    }
}
