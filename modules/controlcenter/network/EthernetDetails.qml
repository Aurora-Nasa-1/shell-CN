pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

DeviceDetails {
    id: root

    required property Session session
    readonly property var ethernetDevice: root.session.ethernet.active

    device: ethernetDevice

    Component.onCompleted: {
        if (ethernetDevice && ethernetDevice.interface) {
            Nmcli.getEthernetDeviceDetails(ethernetDevice.interface, () => {});
        }
    }

    onEthernetDeviceChanged: {
        if (ethernetDevice && ethernetDevice.interface) {
            Nmcli.getEthernetDeviceDetails(ethernetDevice.interface, () => {});
        } else {
            Nmcli.ethernetDeviceDetails = null;
        }
    }

    headerComponent: Component {
        ConnectionHeader {
            icon: "cable"
            title: root.ethernetDevice?.interface ?? I18n.tr("Unknown")
        }
    }

    sections: [
        Component {
            ColumnLayout {
                spacing: Tokens.spacing.normal

                SectionHeader {
                    title: I18n.tr("Connection status")
                    description: I18n.tr("Connection settings for this device")
                }

                SectionContainer {
                    ToggleRow {
                        label: I18n.tr("Connected")
                        checked: root.ethernetDevice?.connected ?? false
                        toggle.onToggled: {
                            if (checked) {
                                Nmcli.connectEthernet(root.ethernetDevice?.connection || "", root.ethernetDevice?.interface || "", () => {});
                            } else {
                                if (root.ethernetDevice?.connection) {
                                    Nmcli.disconnectEthernet(root.ethernetDevice.connection, () => {});
                                }
                            }
                        }
                    }
                }
            }
        },
        Component {
            ColumnLayout {
                spacing: Tokens.spacing.normal

                SectionHeader {
                    title: I18n.tr("Device properties")
                    description: I18n.tr("Additional information")
                }

                SectionContainer {
                    contentSpacing: Tokens.spacing.small / 2

                    PropertyRow {
                        label: I18n.tr("Interface")
                        value: root.ethernetDevice?.interface ?? I18n.tr("Unknown")
                    }

                    PropertyRow {
                        showTopMargin: true
                        label: I18n.tr("Connection")
                        value: root.ethernetDevice?.connection || I18n.tr("Not connected")
                    }

                    PropertyRow {
                        showTopMargin: true
                        label: I18n.tr("State")
                        value: root.ethernetDevice?.state ?? I18n.tr("Unknown")
                    }
                }
            }
        },
        Component {
            ColumnLayout {
                spacing: Tokens.spacing.normal

                SectionHeader {
                    title: I18n.tr("Connection information")
                    description: I18n.tr("Network connection details")
                }

                SectionContainer {
                    ConnectionInfoSection {
                        deviceDetails: Nmcli.ethernetDeviceDetails
                    }
                }
            }
        }
    ]
}
