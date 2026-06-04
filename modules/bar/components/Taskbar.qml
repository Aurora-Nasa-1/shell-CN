pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

Item {
    id: root

    required property var bar

    readonly property int padding: Tokens.padding.normal
    readonly property int spacing: Tokens.spacing.small

    anchors.fill: parent

    StyledRect {
        id: container

        color: root.modelDataArray.length > 0 ? Colours.tPalette.m3surfaceContainer : "transparent"
        radius: Tokens.rounding.full

        implicitWidth: bar.isHorizontal ? layout.implicitWidth + padding * 2 : Tokens.sizes.bar.innerWidth
        implicitHeight: bar.isHorizontal ? Tokens.sizes.bar.innerWidth : layout.implicitHeight + padding * 2

        x: bar.width / 2 - width / 2 - (root.parent ? root.parent.x : 0)
        y: bar.height / 2 - height / 2 - (root.parent ? root.parent.y : 0)
        
        Behavior on implicitWidth {
            enabled: bar.isHorizontal
            Anim { type: Anim.DefaultSpatial }
        }
        Behavior on implicitHeight {
            enabled: !bar.isHorizontal
            Anim { type: Anim.DefaultSpatial }
        }

        Grid {
            id: layout
            
            anchors.centerIn: parent
            columns: bar.isHorizontal ? 999 : 1
            rows: bar.isHorizontal ? 1 : 999
            flow: bar.isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
            spacing: root.spacing

            Repeater {
                id: repeater

                delegate: Item {
                    id: delegateItem
                    width: Tokens.sizes.bar.innerWidth * 0.8
                    height: Tokens.sizes.bar.innerWidth * 0.8
                    implicitWidth: width
                    implicitHeight: height

                    required property var modelData

                    property bool isActive: {
                        const activeTop = Hypr.activeToplevel;
                        if (!activeTop) return false;
                        for (const top of modelData.toplevels) {
                            if (top.address === activeTop.address) return true;
                        }
                        return false;
                    }

                    property bool hasWindows: modelData.toplevels.length > 0

                    StateLayer {
                        anchors.fill: parent
                        radius: Tokens.rounding.normal
                        
                        color: delegateItem.isActive ? Colours.palette.m3onSurface : "transparent"
                        opacity: delegateItem.isActive ? 0.1 : 0
                        
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                if (modelData.toplevels.length > 0) {
                                    Hypr.dispatch(`focuswindow address:${modelData.toplevels[0].address}`);
                                } else if (modelData.entry) {
                                    if (modelData.entry.runInTerminal) {
                                        Quickshell.execDetached({
                                            command: ["app2unit", "--", ...GlobalConfig.general.apps.terminal, `${Quickshell.shellDir}/assets/wrap_term_launch.sh`, ...modelData.entry.command],
                                            workingDirectory: modelData.entry.workingDirectory
                                        });
                                    } else {
                                        Quickshell.execDetached({
                                            command: ["app2unit", "--", ...modelData.entry.command],
                                            workingDirectory: modelData.entry.workingDirectory
                                        });
                                    }
                                }
                            } else if (mouse.button === Qt.RightButton) {
                                bar.popouts.currentName = "taskbarcontext";
                                bar.popouts.currentCenter = bar.isHorizontal ? delegateItem.mapToItem(null, delegateItem.width / 2, 0).x : (delegateItem.mapToItem(null, 0, delegateItem.height / 2).y ?? 0);
                                bar.popouts.taskbarModel = modelData;
                                bar.popouts.hasCurrent = true;
                            }
                        }
                        
                        onEntered: {
                            bar.popouts.currentName = "taskbarhover";
                            bar.popouts.currentCenter = bar.isHorizontal ? delegateItem.mapToItem(null, delegateItem.width / 2, 0).x : (delegateItem.mapToItem(null, 0, delegateItem.height / 2).y ?? 0);
                            bar.popouts.taskbarModel = modelData;
                            bar.popouts.hasCurrent = true;
                        }
                    }

                    IconImage {
                        id: icon
                        anchors.centerIn: parent
                        implicitSize: Math.round((delegateItem.width * 0.7) / 2) * 2
                        source: Icons.getAppIcon(modelData.iconName, "image-missing")
                        asynchronous: true
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: icon.horizontalCenter
                        anchors.bottomMargin: 0
                        width: Math.round((delegateItem.width * 0.3) / 2) * 2
                        height: 2
                        radius: 1
                        color: delegateItem.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurface
                        opacity: delegateItem.hasWindows ? 1 : 0
                        visible: delegateItem.hasWindows

                        Behavior on opacity { Anim {} }
                    }
                }
            }
        }
    }

    function handleHover(relPos: real, isHorizontal: bool): void {
        const itemSize = Tokens.sizes.bar.innerWidth * 0.8;
        const itemWidthWithSpacing = itemSize + spacing;
        const adjustedPos = isHorizontal ? relPos - container.x - padding : relPos - container.y - padding;
        if (adjustedPos < 0) {
            bar.popouts.hasCurrent = false;
            return;
        }
        const index = Math.floor(adjustedPos / itemWidthWithSpacing);
        
        const item = repeater.itemAt(index);
        if (item) {
            bar.popouts.currentName = "taskbarhover";
            bar.popouts.currentCenter = isHorizontal ? item.mapToItem(null, item.implicitWidth / 2, 0).x : (item.mapToItem(null, 0, item.implicitHeight / 2).y ?? 0);
            bar.popouts.taskbarModel = modelDataArray[index];
            bar.popouts.hasCurrent = true;
        } else {
            bar.popouts.hasCurrent = false;
        }
    }

    property var modelDataArray: []

    function rebuildModel(): void {
        const apps = [];
        const pinnedIds = GlobalConfig.launcher.favouriteApps || [];
        
        for (const entry of DesktopEntries.applications.values) {
            if (Strings.testRegexList(pinnedIds, entry.id)) {
                apps.push({
                    id: entry.id,
                    isPinned: true,
                    entry: entry,
                    toplevels: [],
                    appClass: entry.id.replace(".desktop", ""),
                    iconName: entry.id
                });
            }
        }
        
        for (const toplevel of Hyprland.toplevels.values) {
            if (!toplevel.lastIpcObject || !toplevel.lastIpcObject.class) continue;
            const appClass = toplevel.lastIpcObject.class;
            
            let found = false;
            for (const app of apps) {
                if (app.appClass.toLowerCase() === appClass.toLowerCase() || 
                    app.id.toLowerCase().includes(appClass.toLowerCase()) || 
                    appClass.toLowerCase().includes(app.id.toLowerCase().replace(".desktop", ""))) {
                    app.toplevels.push(toplevel);
                    found = true;
                    break;
                }
            }
            
            if (!found) {
                const entry = DesktopEntries.applications.values.find(e => e.id.toLowerCase().includes(appClass.toLowerCase()) || appClass.toLowerCase().includes(e.id.toLowerCase().replace(".desktop", ""))) || null;
                apps.push({
                    id: appClass,
                    isPinned: false,
                    entry: entry,
                    toplevels: [toplevel],
                    appClass: appClass,
                    iconName: entry ? entry.id : appClass
                });
            }
        }
        
        root.modelDataArray = apps;
        repeater.model = apps;
    }

    Connections {
        target: Hyprland
        function onToplevelsChanged(): void {
            root.rebuildModel();
        }
    }

    Connections {
        target: GlobalConfig.launcher
        function onFavouriteAppsChanged(): void {
            root.rebuildModel();
        }
    }

    Component.onCompleted: root.rebuildModel()
}
