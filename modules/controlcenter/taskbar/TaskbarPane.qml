pragma ComponentBehavior: Bound

import ".."
import "../components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    required property Session session

    property bool activeWindowCompact: Config.bar.activeWindow.compact ?? false
    property bool activeWindowInverted: Config.bar.activeWindow.inverted ?? false
    property bool clockShowIcon: Config.bar.clock.showIcon ?? true
    property bool clockBackground: Config.bar.clock.background ?? false
    property bool clockShowDate: Config.bar.clock.showDate ?? false
    property bool persistent: Config.bar.persistent ?? true
    property bool showOnHover: Config.bar.showOnHover ?? true
    property int dragThreshold: Config.bar.dragThreshold ?? 20
    property string position: Config.bar.position ?? "left"
    property bool showAudio: Config.bar.status.showAudio ?? true
    property bool showMicrophone: Config.bar.status.showMicrophone ?? true
    property bool showKbLayout: Config.bar.status.showKbLayout ?? false
    property bool showNetwork: Config.bar.status.showNetwork ?? true
    property bool showWifi: Config.bar.status.showWifi ?? true
    property bool showBluetooth: Config.bar.status.showBluetooth ?? true
    property bool showBattery: Config.bar.status.showBattery ?? true
    property bool showLockStatus: Config.bar.status.showLockStatus ?? true
    property bool trayBackground: Config.bar.tray.background ?? false
    property bool trayCompact: Config.bar.tray.compact ?? false
    property bool trayRecolour: Config.bar.tray.recolour ?? false
    property int workspacesShown: Config.bar.workspaces.shown ?? 5
    property bool workspacesActiveIndicator: Config.bar.workspaces.activeIndicator ?? true
    property bool workspacesOccupiedBg: Config.bar.workspaces.occupiedBg ?? false
    property bool workspacesShowWindows: Config.bar.workspaces.showWindows ?? false
    property int workspacesMaxWindowIcons: Config.bar.workspaces.maxWindowIcons ?? 0
    property bool workspacesPerMonitor: GlobalConfig.bar.workspaces.perMonitorWorkspaces ?? true
    property bool workspacesUseIcon: Config.bar.workspaces.useIcon ?? false
    property bool scrollWorkspaces: Config.bar.scrollActions.workspaces ?? true
    property bool scrollVolume: Config.bar.scrollActions.volume ?? true
    property bool scrollBrightness: Config.bar.scrollActions.brightness ?? true
    property bool popoutActiveWindow: Config.bar.popouts.activeWindow ?? true
    property bool popoutTray: Config.bar.popouts.tray ?? true
    property bool popoutStatusIcons: Config.bar.popouts.statusIcons ?? true
    property list<string> monitorNames: Hypr.monitorNames()
    property list<string> excludedScreens: Config.bar.excludedScreens ?? []

    function saveConfig(entryIndex, entryEnabled) {
        GlobalConfig.bar.activeWindow.compact = root.activeWindowCompact;
        GlobalConfig.bar.activeWindow.inverted = root.activeWindowInverted;
        GlobalConfig.bar.clock.background = root.clockBackground;
        GlobalConfig.bar.clock.showDate = root.clockShowDate;
        GlobalConfig.bar.clock.showIcon = root.clockShowIcon;
        GlobalConfig.bar.persistent = root.persistent;
        GlobalConfig.bar.showOnHover = root.showOnHover;
        GlobalConfig.bar.dragThreshold = root.dragThreshold;
        GlobalConfig.bar.position = root.position;
        GlobalConfig.bar.status.showAudio = root.showAudio;
        GlobalConfig.bar.status.showMicrophone = root.showMicrophone;
        GlobalConfig.bar.status.showKbLayout = root.showKbLayout;
        GlobalConfig.bar.status.showNetwork = root.showNetwork;
        GlobalConfig.bar.status.showWifi = root.showWifi;
        GlobalConfig.bar.status.showBluetooth = root.showBluetooth;
        GlobalConfig.bar.status.showBattery = root.showBattery;
        GlobalConfig.bar.status.showLockStatus = root.showLockStatus;
        GlobalConfig.bar.tray.background = root.trayBackground;
        GlobalConfig.bar.tray.compact = root.trayCompact;
        GlobalConfig.bar.tray.recolour = root.trayRecolour;
        GlobalConfig.bar.workspaces.shown = root.workspacesShown;
        GlobalConfig.bar.workspaces.activeIndicator = root.workspacesActiveIndicator;
        GlobalConfig.bar.workspaces.occupiedBg = root.workspacesOccupiedBg;
        GlobalConfig.bar.workspaces.showWindows = root.workspacesShowWindows;
        GlobalConfig.bar.workspaces.maxWindowIcons = root.workspacesMaxWindowIcons;
        GlobalConfig.bar.workspaces.perMonitorWorkspaces = root.workspacesPerMonitor;
        GlobalConfig.bar.workspaces.useIcon = root.workspacesUseIcon;
        GlobalConfig.bar.scrollActions.workspaces = root.scrollWorkspaces;
        GlobalConfig.bar.scrollActions.volume = root.scrollVolume;
        GlobalConfig.bar.scrollActions.brightness = root.scrollBrightness;
        GlobalConfig.bar.popouts.activeWindow = root.popoutActiveWindow;
        GlobalConfig.bar.popouts.tray = root.popoutTray;
        GlobalConfig.bar.popouts.statusIcons = root.popoutStatusIcons;
        GlobalConfig.bar.excludedScreens = root.excludedScreens;

        const entries = [];
        for (let i = 0; i < entriesModel.count; i++) {
            const entry = entriesModel.get(i);
            let enabled = entry.enabled;
            if (entryIndex !== undefined && i === entryIndex) {
                enabled = entryEnabled;
            }
            entries.push({
                id: entry.id,
                enabled: enabled
            });
        }
        GlobalConfig.bar.entries = entries;
    }

    anchors.fill: parent

    Component.onCompleted: {
        if (Config.bar.entries) {
            entriesModel.clear();
            let activeWindowIdx = -1;
            let dockIdx = -1;
            for (let i = 0; i < Config.bar.entries.length; i++) {
                const entry = Config.bar.entries[i];
                if (entry.id === "activeWindow") activeWindowIdx = i;
                if (entry.id === "dock") dockIdx = i;
                entriesModel.append({
                    id: entry.id,
                    enabled: entry.enabled !== false
                });
            }
            
            if (activeWindowIdx === -1 && dockIdx !== -1) {
                entriesModel.insert(dockIdx, { id: "activeWindow", enabled: false });
            } else if (dockIdx === -1 && activeWindowIdx !== -1) {
                entriesModel.insert(activeWindowIdx + 1, { id: "dock", enabled: false });
            } else if (activeWindowIdx === -1 && dockIdx === -1) {
                entriesModel.append({ id: "activeWindow", enabled: true });
                entriesModel.append({ id: "dock", enabled: false });
            }
        }
    }

    ListModel {
        id: entriesModel
    }

    ClippingRectangle {
        id: taskbarClippingRect

        anchors.fill: parent
        anchors.margins: Tokens.padding.normal
        anchors.leftMargin: 0
        anchors.rightMargin: Tokens.padding.normal

        radius: taskbarBorder.innerRadius
        color: "transparent"

        Loader {
            id: taskbarLoader

            anchors.fill: parent
            anchors.margins: Tokens.padding.large + Tokens.padding.normal
            anchors.leftMargin: Tokens.padding.large
            anchors.rightMargin: Tokens.padding.large

            asynchronous: true
            sourceComponent: taskbarContentComponent
        }
    }

    InnerBorder {
        id: taskbarBorder

        leftThickness: 0
        rightThickness: Tokens.padding.normal
    }

    Component {
        id: taskbarContentComponent

        StyledFlickable {
            id: sidebarFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: sidebarLayout.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: sidebarFlickable
            }

            ColumnLayout {
                id: sidebarLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                spacing: Tokens.spacing.normal

                RowLayout {
                    spacing: Tokens.spacing.smaller

                    StyledText {
                        text: I18n.tr("Taskbar")
                        font.pointSize: Tokens.font.size.large
                        font.weight: 500
                    }
                }

                SectionContainer {
                    Layout.fillWidth: true
                    alignTop: true

                    StyledText {
                        text: I18n.tr("Status Icons")
                        font.pointSize: Tokens.font.size.normal
                    }

                    ConnectedButtonGroup {
                        rootItem: root

                        options: [
                            {
                                label: I18n.tr("Speakers"),
                                propertyName: "showAudio",
                                onToggled: function (checked) {
                                    root.showAudio = checked;
                                    root.saveConfig();
                                }
                            },
                            {
                                label: I18n.tr("Microphone"),
                                propertyName: "showMicrophone",
                                onToggled: function (checked) {
                                    root.showMicrophone = checked;
                                    root.saveConfig();
                                }
                            },
                            {
                                label: I18n.tr("Keyboard"),
                                propertyName: "showKbLayout",
                                onToggled: function (checked) {
                                    root.showKbLayout = checked;
                                    root.saveConfig();
                                }
                            },
                            {
                                label: I18n.tr("Network"),
                                propertyName: "showNetwork",
                                onToggled: function (checked) {
                                    root.showNetwork = checked;
                                    root.saveConfig();
                                }
                            },
                            {
                                label: I18n.tr("Wifi"),
                                propertyName: "showWifi",
                                onToggled: function (checked) {
                                    root.showWifi = checked;
                                    root.saveConfig();
                                }
                            },
                            {
                                label: I18n.tr("Bluetooth"),
                                propertyName: "showBluetooth",
                                onToggled: function (checked) {
                                    root.showBluetooth = checked;
                                    root.saveConfig();
                                }
                            },
                            {
                                label: I18n.tr("Battery"),
                                propertyName: "showBattery",
                                onToggled: function (checked) {
                                    root.showBattery = checked;
                                    root.saveConfig();
                                }
                            },
                            {
                                label: I18n.tr("Capslock"),
                                propertyName: "showLockStatus",
                                onToggled: function (checked) {
                                    root.showLockStatus = checked;
                                    root.saveConfig();
                                }
                            }
                        ]
                    }
                }

                RowLayout {
                    id: mainRowLayout

                    Layout.fillWidth: true
                    spacing: Tokens.spacing.normal

                    ColumnLayout {
                        id: leftColumnLayout

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: Tokens.spacing.normal

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Workspaces")
                                font.pointSize: Tokens.font.size.normal
                            }

                            StyledRect {
                                Layout.fillWidth: true
                                implicitHeight: workspacesShownRow.implicitHeight + Tokens.padding.large * 2
                                radius: Tokens.rounding.normal
                                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                Behavior on implicitHeight {
                                    Anim {}
                                }

                                RowLayout {
                                    id: workspacesShownRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Tokens.padding.large
                                    spacing: Tokens.spacing.normal

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: I18n.tr("Shown")
                                    }

                                    CustomSpinBox {
                                        min: 1
                                        max: 20
                                        value: root.workspacesShown
                                        onValueModified: value => {
                                            root.workspacesShown = value;
                                            root.saveConfig();
                                        }
                                    }
                                }
                            }

                            StyledRect {
                                Layout.fillWidth: true
                                implicitHeight: workspacesActiveIndicatorRow.implicitHeight + Tokens.padding.large * 2
                                radius: Tokens.rounding.normal
                                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                Behavior on implicitHeight {
                                    Anim {}
                                }

                                RowLayout {
                                    id: workspacesActiveIndicatorRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Tokens.padding.large
                                    spacing: Tokens.spacing.normal

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: I18n.tr("Active indicator")
                                    }

                                    StyledSwitch {
                                        checked: root.workspacesActiveIndicator
                                        onToggled: {
                                            root.workspacesActiveIndicator = checked;
                                            root.saveConfig();
                                        }
                                    }
                                }
                            }

                            StyledRect {
                                Layout.fillWidth: true
                                implicitHeight: workspacesOccupiedBgRow.implicitHeight + Tokens.padding.large * 2
                                radius: Tokens.rounding.normal
                                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                Behavior on implicitHeight {
                                    Anim {}
                                }

                                RowLayout {
                                    id: workspacesOccupiedBgRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Tokens.padding.large
                                    spacing: Tokens.spacing.normal

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: I18n.tr("Occupied background")
                                    }

                                    StyledSwitch {
                                        checked: root.workspacesOccupiedBg
                                        onToggled: {
                                            root.workspacesOccupiedBg = checked;
                                            root.saveConfig();
                                        }
                                    }
                                }
                            }

                            StyledRect {
                                Layout.fillWidth: true
                                implicitHeight: workspacesShowWindowsRow.implicitHeight + Tokens.padding.large * 2
                                radius: Tokens.rounding.normal
                                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                Behavior on implicitHeight {
                                    Anim {}
                                }

                                RowLayout {
                                    id: workspacesShowWindowsRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Tokens.padding.large
                                    spacing: Tokens.spacing.normal

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: I18n.tr("Show windows")
                                    }

                                    StyledSwitch {
                                        checked: root.workspacesShowWindows
                                        onToggled: {
                                            root.workspacesShowWindows = checked;
                                            root.saveConfig();
                                        }
                                    }
                                }
                            }

                            StyledRect {
                                Layout.fillWidth: true
                                implicitHeight: workspacesMaxWindowIconsRow.implicitHeight + Tokens.padding.large * 2
                                radius: Tokens.rounding.normal
                                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                Behavior on implicitHeight {
                                    Anim {}
                                }

                                RowLayout {
                                    id: workspacesMaxWindowIconsRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Tokens.padding.large
                                    spacing: Tokens.spacing.normal

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: I18n.tr("Max window icons")
                                    }

                                    CustomSpinBox {
                                        min: 0
                                        max: 20
                                        value: root.workspacesMaxWindowIcons
                                        onValueModified: value => {
                                            root.workspacesMaxWindowIcons = value;
                                            root.saveConfig();
                                        }
                                    }
                                }
                            }

                            StyledRect {
                                Layout.fillWidth: true
                                implicitHeight: workspacesPerMonitorRow.implicitHeight + Tokens.padding.large * 2
                                radius: Tokens.rounding.normal
                                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                Behavior on implicitHeight {
                                    Anim {}
                                }

                                RowLayout {
                                    id: workspacesPerMonitorRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Tokens.padding.large
                                    spacing: Tokens.spacing.normal

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: I18n.tr("Per monitor workspaces")
                                    }

                                    StyledSwitch {
                                        checked: root.workspacesPerMonitor
                                        onToggled: {
                                            root.workspacesPerMonitor = checked;
                                            root.saveConfig();
                                        }
                                    }
                                }
                            }

                            StyledRect {
                                Layout.fillWidth: true
                                implicitHeight: workspacesUseIconRow.implicitHeight + Tokens.padding.large * 2
                                radius: Tokens.rounding.normal
                                color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

                                Behavior on implicitHeight {
                                    Anim {}
                                }

                                RowLayout {
                                    id: workspacesUseIconRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.margins: Tokens.padding.large
                                    spacing: Tokens.spacing.normal

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: I18n.tr("Use icon")
                                    }

                                    StyledSwitch {
                                        checked: root.workspacesUseIcon
                                        onToggled: {
                                            root.workspacesUseIcon = checked;
                                            root.saveConfig();
                                        }
                                    }
                                }
                            }
                        }

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Scroll Actions")
                                font.pointSize: Tokens.font.size.normal
                            }

                            ConnectedButtonGroup {
                                rootItem: root

                                options: [
                                    {
                                        label: I18n.tr("Workspaces"),
                                        propertyName: "scrollWorkspaces",
                                        onToggled: function (checked) {
                                            root.scrollWorkspaces = checked;
                                            root.saveConfig();
                                        }
                                    },
                                    {
                                        label: I18n.tr("Volume"),
                                        propertyName: "scrollVolume",
                                        onToggled: function (checked) {
                                            root.scrollVolume = checked;
                                            root.saveConfig();
                                        }
                                    },
                                    {
                                        label: I18n.tr("Brightness"),
                                        propertyName: "scrollBrightness",
                                        onToggled: function (checked) {
                                            root.scrollBrightness = checked;
                                            root.saveConfig();
                                        }
                                    }
                                ]
                            }
                        }
                    }

                    ColumnLayout {
                        id: middleColumnLayout

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: Tokens.spacing.normal

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Active window")
                                font.pointSize: Tokens.font.size.normal
                            }
                            
                            SwitchRow {
                                id: activeWindowSwitch
                                label: I18n.tr("Enable")
                                checked: {
                                    for (let i = 0; i < entriesModel.count; i++) {
                                        if (entriesModel.get(i).id === "activeWindow") return entriesModel.get(i).enabled;
                                    }
                                    return false;
                                }
                                onToggled: checked => {
                                    let activeWindowIdx = -1;
                                    let dockIdx = -1;
                                    for (let i = 0; i < entriesModel.count; i++) {
                                        if (entriesModel.get(i).id === "activeWindow") activeWindowIdx = i;
                                        if (entriesModel.get(i).id === "dock") dockIdx = i;
                                    }
                                    
                                    if (activeWindowIdx !== -1) {
                                        entriesModel.setProperty(activeWindowIdx, "enabled", checked);
                                    }
                                    if (checked && dockIdx !== -1) {
                                        entriesModel.setProperty(dockIdx, "enabled", false);
                                        dockSwitch.checked = false;
                                    }
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Compact")
                                checked: root.activeWindowCompact
                                onToggled: checked => {
                                    root.activeWindowCompact = checked;
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Inverted")
                                checked: root.activeWindowInverted
                                onToggled: checked => {
                                    root.activeWindowInverted = checked;
                                    root.saveConfig();
                                }
                            }
                        }

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Dock")
                                font.pointSize: Tokens.font.size.normal
                            }
                            
                            SwitchRow {
                                id: dockSwitch
                                label: I18n.tr("Enable")
                                checked: {
                                    for (let i = 0; i < entriesModel.count; i++) {
                                        if (entriesModel.get(i).id === "dock") return entriesModel.get(i).enabled;
                                    }
                                    return false;
                                }
                                onToggled: checked => {
                                    let activeWindowIdx = -1;
                                    let dockIdx = -1;
                                    for (let i = 0; i < entriesModel.count; i++) {
                                        if (entriesModel.get(i).id === "activeWindow") activeWindowIdx = i;
                                        if (entriesModel.get(i).id === "dock") dockIdx = i;
                                    }
                                    
                                    if (dockIdx !== -1) {
                                        entriesModel.setProperty(dockIdx, "enabled", checked);
                                    }
                                    if (checked && activeWindowIdx !== -1) {
                                        entriesModel.setProperty(activeWindowIdx, "enabled", false);
                                        activeWindowSwitch.checked = false;
                                    }
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Monitor center")
                                checked: Config.bar.dock.monitorCenter ?? true
                                onToggled: checked => {
                                    GlobalConfig.bar.dock.monitorCenter = checked;
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Recolour icons")
                                checked: Config.bar.dock.recolourIcons ?? false
                                onToggled: checked => {
                                    GlobalConfig.bar.dock.recolourIcons = checked;
                                }
                            }
                        }

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Clock")
                                font.pointSize: Tokens.font.size.normal
                            }

                            SwitchRow {
                                label: I18n.tr("Background")
                                checked: root.clockBackground
                                onToggled: checked => {
                                    root.clockBackground = checked;
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Show date")
                                checked: root.clockShowDate
                                onToggled: checked => {
                                    root.clockShowDate = checked;
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Show clock icon")
                                checked: root.clockShowIcon
                                onToggled: checked => {
                                    root.clockShowIcon = checked;
                                    root.saveConfig();
                                }
                            }
                        }

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Bar Behavior")
                                font.pointSize: Tokens.font.size.normal
                            }

                            SwitchRow {
                                label: I18n.tr("Persistent")
                                checked: root.persistent
                                onToggled: checked => {
                                    root.persistent = checked;
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Show on hover")
                                checked: root.showOnHover
                                onToggled: checked => {
                                    root.showOnHover = checked;
                                    root.saveConfig();
                                }
                            }

                            SplitButtonRow {
                                id: positionSelector

                                function syncActiveItem(): void {
                                    if (root.position === "left") {
                                        active = positionLeftItem;
                                        return;
                                    }
                                    if (root.position === "right") {
                                        active = positionRightItem;
                                        return;
                                    }
                                    if (root.position === "top") {
                                        active = positionTopItem;
                                        return;
                                    }
                                    active = positionBottomItem;
                                }

                                Layout.fillWidth: true
                                z: expanded ? 100 : 0
                                label: I18n.tr("Position")
                                menuItems: [positionLeftItem, positionRightItem, positionTopItem, positionBottomItem]

                                Component.onCompleted: syncActiveItem()

                                Connections {
                                    function onPositionChanged(): void {
                                        positionSelector.syncActiveItem();
                                    }

                                    target: root
                                }

                                MenuItem {
                                    id: positionLeftItem

                                    text: I18n.tr("Left")
                                    icon: "align_horizontal_left"
                                    activeText: I18n.tr("Left")
                                    onClicked: {
                                        root.position = "left";
                                        root.saveConfig();
                                    }
                                }

                                MenuItem {
                                    id: positionRightItem

                                    text: I18n.tr("Right")
                                    icon: "align_horizontal_right"
                                    activeText: I18n.tr("Right")
                                    onClicked: {
                                        root.position = "right";
                                        root.saveConfig();
                                    }
                                }

                                MenuItem {
                                    id: positionTopItem

                                    text: I18n.tr("Top")
                                    icon: "vertical_align_top"
                                    activeText: I18n.tr("Top")
                                    onClicked: {
                                        root.position = "top";
                                        root.saveConfig();
                                    }
                                }

                                MenuItem {
                                    id: positionBottomItem

                                    text: I18n.tr("Bottom")
                                    icon: "vertical_align_bottom"
                                    activeText: I18n.tr("Bottom")
                                    onClicked: {
                                        root.position = "bottom";
                                        root.saveConfig();
                                    }
                                }
                            }

                            SectionContainer {
                                contentSpacing: Tokens.spacing.normal

                                SliderInput {
                                    Layout.fillWidth: true

                                    label: I18n.tr("Drag threshold")
                                    value: root.dragThreshold
                                    from: 0
                                    to: 100
                                    suffix: "px"
                                    validator: IntValidator {
                                        bottom: 0
                                        top: 100
                                    }
                                    formatValueFunction: val => Math.round(val).toString()
                                    parseValueFunction: text => parseInt(text)

                                    onValueModified: newValue => {
                                        root.dragThreshold = Math.round(newValue);
                                        root.saveConfig();
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        id: rightColumnLayout

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: Tokens.spacing.normal

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Popouts")
                                font.pointSize: Tokens.font.size.normal
                            }

                            SwitchRow {
                                label: I18n.tr("Active window")
                                checked: root.popoutActiveWindow
                                onToggled: checked => {
                                    root.popoutActiveWindow = checked;
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Tray")
                                checked: root.popoutTray
                                onToggled: checked => {
                                    root.popoutTray = checked;
                                    root.saveConfig();
                                }
                            }

                            SwitchRow {
                                label: I18n.tr("Status icons")
                                checked: root.popoutStatusIcons
                                onToggled: checked => {
                                    root.popoutStatusIcons = checked;
                                    root.saveConfig();
                                }
                            }
                        }

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Tray Settings")
                                font.pointSize: Tokens.font.size.normal
                            }

                            ConnectedButtonGroup {
                                rootItem: root

                                options: [
                                    {
                                        label: I18n.tr("Background"),
                                        propertyName: "trayBackground",
                                        onToggled: function (checked) {
                                            root.trayBackground = checked;
                                            root.saveConfig();
                                        }
                                    },
                                    {
                                        label: I18n.tr("Compact"),
                                        propertyName: "trayCompact",
                                        onToggled: function (checked) {
                                            root.trayCompact = checked;
                                            root.saveConfig();
                                        }
                                    },
                                    {
                                        label: I18n.tr("Recolour"),
                                        propertyName: "trayRecolour",
                                        onToggled: function (checked) {
                                            root.trayRecolour = checked;
                                            root.saveConfig();
                                        }
                                    }
                                ]
                            }
                        }

                        SectionContainer {
                            Layout.fillWidth: true
                            alignTop: true

                            StyledText {
                                text: I18n.tr("Monitors")
                                font.pointSize: Tokens.font.size.normal
                            }

                            ConnectedButtonGroup {
                                rootItem: root
                                // max 3 options per line
                                rows: Math.ceil(root.monitorNames.length / 3)

                                options: root.monitorNames.map(e => ({
                                            label: I18n.tr(e),
                                            propertyName: `monitor${e}`,
                                            onToggled: function (_) {
                                                // if the given monitor is in the excluded list, it should be added back
                                                let addedBack = excludedScreens.includes(e);
                                                if (addedBack) {
                                                    const index = excludedScreens.indexOf(e);
                                                    if (index !== -1) {
                                                        excludedScreens.splice(index, 1);
                                                    }
                                                } else {
                                                    if (!excludedScreens.includes(e)) {
                                                        excludedScreens.push(e);
                                                    }
                                                }
                                                root.saveConfig();
                                            },
                                            state: !Strings.testRegexList(root.excludedScreens, e)
                                        }))
                            }
                        }
                    }
                }
            }
        }
    }
}
