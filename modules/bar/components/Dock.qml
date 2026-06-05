pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    required property var bar
    property int modelUpdateTrigger: 0
    property var launchingApps: ({})

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

        property var _appsValues: DesktopEntries.applications.values
        on_AppsValuesChanged: root.rebuildModel()
        
        Behavior on implicitWidth {
            enabled: bar.isHorizontal
            Anim { type: Anim.DefaultSpatial }
        }
        Behavior on implicitHeight {
            enabled: !bar.isHorizontal
            Anim { type: Anim.DefaultSpatial }
        }

        Item {
            id: layout
            
            anchors.centerIn: parent
            implicitWidth: listView.width
            implicitHeight: listView.height

            ListView {
                id: listView
                anchors.centerIn: parent
                width: bar.isHorizontal ? contentWidth : Tokens.sizes.bar.innerWidth * 0.8
                height: bar.isHorizontal ? Tokens.sizes.bar.innerWidth * 0.8 : contentHeight
                orientation: bar.isHorizontal ? ListView.Horizontal : ListView.Vertical
                spacing: root.spacing
                interactive: false

                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 250; easing.type: Easing.OutCubic }
                }
                moveDisplaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 250; easing.type: Easing.OutCubic }
                }
                
                model: DelegateModel {
                    id: visualModel
                    model: root.modelDataArray
                    delegate: dockDelegate
                }
            }
        }

        function saveNewOrder(): void {
            const newArr = [];
            const newFavs = [];
            
            for (let i = 0; i < root.currentOrder.length; ++i) {
                const mData = root.currentOrder[i];
                if (!mData) continue;
                
                if (!mData.isPinned) {
                    mData.isPinned = true;
                }
                
                newArr.push(mData);
                newFavs.push(mData.id);
            }
            
            GlobalConfig.launcher.favouriteApps = newFavs;
            root.modelDataArray = newArr;
        }

        Component {
            id: dockDelegate

            Item {
                id: delegateContainer
                width: Tokens.sizes.bar.innerWidth * 0.8
                height: Tokens.sizes.bar.innerWidth * 0.8
                implicitWidth: width
                implicitHeight: height

                required property var modelData
                required property int index

                DropArea {
                    anchors.fill: parent
                    onEntered: drag => {
                        const from = drag.source.delegateIndex;
                        const to = delegateContainer.index;
                        if (from !== undefined && to !== undefined && from !== to) {
                            visualModel.items.move(from, to);
                            const movedItem = root.currentOrder.splice(from, 1)[0];
                            root.currentOrder.splice(to, 0, movedItem);
                        }
                    }
                    onDropped: drag => {
                        root.saveNewOrder();
                    }
                }

                Item {
                    id: delegateItem
                    width: delegateContainer.width
                    height: delegateContainer.height
                    
                    property int delegateIndex: delegateContainer.index

                    Drag.active: dragArea.drag.active
                    Drag.source: delegateItem
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: height / 2

                    StateLayer {
                        id: stateLayer
                        anchors.fill: parent
                        radius: Tokens.rounding.normal
                        
                        color: delegateItem.isActive ? Colours.palette.m3onSurface : "transparent"
                        opacity: delegateItem.isActive ? 0.1 : 0
                        
                        acceptedButtons: Qt.NoButton
                        
                        onEntered: {
                            if (bar.popouts.hasCurrent && bar.popouts.currentName === "dockcontext") return;
                            bar.popouts.currentName = "dockhover";
                            bar.popouts.currentCenter = bar.isHorizontal ? delegateItem.mapToItem(null, delegateItem.width / 2, 0).x : (delegateItem.mapToItem(null, 0, delegateItem.height / 2).y ?? 0);
                            bar.popouts.dockModel = modelData;
                            bar.popouts.hasCurrent = true;
                        }
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        drag.target: delegateItem
                        drag.axis: bar.isHorizontal ? Drag.XAxis : Drag.YAxis
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        
                        onPressed: mouse => {
                            stateLayer.press(mouse.x, mouse.y);
                        }
                        
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                if (modelData.toplevels.length > 0) {
                                    Hypr.dispatch(`focuswindow address:${modelData.toplevels[0].address}`);
                                } else if (modelData.entry) {
                                    // Mark as launching
                                    let newLaunching = Object.assign({}, root.launchingApps);
                                    newLaunching[modelData.appClass || modelData.id] = true;
                                    root.launchingApps = newLaunching;
                                    
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
                                bar.popouts.currentName = "dockcontext";
                                bar.popouts.currentCenter = bar.isHorizontal ? delegateItem.mapToItem(null, delegateItem.width / 2, 0).x : (delegateItem.mapToItem(null, 0, delegateItem.height / 2).y ?? 0);
                                bar.popouts.dockModel = modelData;
                                bar.popouts.hasCurrent = true;
                            }
                        }
                        
                        onReleased: {
                            delegateItem.parent = delegateContainer;
                            delegateItem.x = 0;
                            delegateItem.y = 0;
                            delegateItem.z = 0;
                            delegateItem.opacity = 1;
                            root.saveNewOrder();
                        }
                    }

                    states: [
                        State {
                            when: dragArea.drag.active
                            ParentChange {
                                target: delegateItem
                                parent: listView
                            }
                            AnchorChanges {
                                target: delegateItem
                                anchors.horizontalCenter: undefined
                                anchors.verticalCenter: undefined
                            }
                            PropertyChanges {
                                target: delegateItem
                                opacity: 0.8
                                z: 999
                            }
                        }
                    ]

                    property bool isActive: {
                        const activeTop = Hyprland.activeToplevel;
                        if (!activeTop) return false;
                        
                        if (activeTop.lastIpcObject && modelData.appClass) {
                            const activeClass = (activeTop.lastIpcObject.class || activeTop.lastIpcObject.initialClass || "").toLowerCase();
                            const appId = modelData.appClass.toLowerCase();
                            if (activeClass && (activeClass === appId || activeClass.includes(appId) || appId.includes(activeClass))) {
                                return true;
                            }
                        }
                        
                        for (const top of modelData.toplevels) {
                            if (top.address && top.address === activeTop.address) return true;
                        }
                        return false;
                    }

                    property bool hasWindows: {
                        const dummy = root.modelUpdateTrigger;
                        return modelData.toplevels.length > 0;
                    }



                    IconImage {
                        id: icon
                        anchors.centerIn: parent
                        implicitSize: Math.round(((delegateItem.width || 0) * 0.7) / 2) * 2 || 0
                        source: Icons.getAppIcon(modelData.iconName, "image-missing")
                        asynchronous: true
                    }

                    Loader {
                        anchors.fill: icon
                        anchors.margins: -Tokens.padding.small
                        active: root.launchingApps[modelData.appClass || modelData.id] || false
                        sourceComponent: CircularIndicator {
                            running: true
                            strokeWidth: 2
                        }
                    }

                    Row {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 0
                        spacing: 2
                        visible: delegateItem.hasWindows
                        
                        Repeater {
                            model: {
                                const dummy = root.modelUpdateTrigger;
                                return Math.min(2, modelData.toplevels.length);
                            }
                            
                            delegate: Rectangle {
                                required property int index
                                width: (index === 0 && delegateItem.isActive) ? 16 : 2
    
                                height: 2
    
                                radius: 1
    
                                color: delegateItem.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurface
    
                                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                                Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation { duration: 250 } }
                            }
                        }
                    }
                }
            }
        }
    }

    function handleHover(relPos: real, isHorizontal: bool): void {
        // Don't close dock context menu
        if (bar.popouts.hasCurrent && bar.popouts.currentName === "dockcontext") return;

        const itemSize = Tokens.sizes.bar.innerWidth * 0.8;
        const itemWidthWithSpacing = itemSize + spacing;
        const adjustedPos = isHorizontal ? relPos - container.x - padding : relPos - container.y - padding;
        
        // Only close if cursor is completely outside dock bounds
        if (adjustedPos < 0 || adjustedPos >= modelDataArray.length * itemWidthWithSpacing) {
            bar.popouts.hasCurrent = false;
            return;
        }
        
        const index = Math.floor(adjustedPos / itemWidthWithSpacing);
        
        if (index >= 0 && index < modelDataArray.length) {
            bar.popouts.currentName = "dockhover";
            const centerOffset = index * itemWidthWithSpacing + itemSize / 2;
            const absoluteCenter = isHorizontal 
                ? container.mapToItem(null, padding + centerOffset, 0).x 
                : container.mapToItem(null, 0, padding + centerOffset).y;
            
            bar.popouts.currentCenter = absoluteCenter;
            bar.popouts.dockModel = modelDataArray[index];
            bar.popouts.hasCurrent = true;
        }
    }

    property var modelDataArray: []
    property var currentOrder: []
    onModelDataArrayChanged: currentOrder = [...modelDataArray]

    function rebuildModel(): void {
        const apps = [];

        const pinnedIds = GlobalConfig.launcher.favouriteApps || [];
        
        for (const pid of pinnedIds) {
            for (const entry of DesktopEntries.applications.values) {
                if (Strings.testRegexList([pid], entry.id)) {
                    if (!apps.some(a => a.id === entry.id)) {
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
            }
        }
        
        for (const toplevel of Hyprland.toplevels.values) {
            const ipc = toplevel.lastIpcObject;
            if (!ipc) continue;
            const appClass = ipc.class || ipc.initialClass;
            if (!appClass) continue;
            
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
        
        let newLaunching = Object.assign({}, root.launchingApps);
        let launchingChanged = false;

        for (const app of apps) {
            if (app.toplevels.length > 0) {
                if (newLaunching[app.appClass]) {
                    delete newLaunching[app.appClass];
                    launchingChanged = true;
                }
                if (newLaunching[app.id]) {
                    delete newLaunching[app.id];
                    launchingChanged = true;
                }
            }
        }
        
        if (launchingChanged) {
            root.launchingApps = newLaunching;
        }

        let changed = apps.length !== root.modelDataArray.length;
        if (!changed) {
            for (let i = 0; i < apps.length; i++) {
                if (apps[i].id !== root.modelDataArray[i].id || apps[i].toplevels.length !== root.modelDataArray[i].toplevels.length) {
                    changed = true;
                    break;
                }
                for (let j = 0; j < apps[i].toplevels.length; j++) {
                    if (apps[i].toplevels[j].address !== root.modelDataArray[i].toplevels[j].address) {
                        changed = true;
                        break;
                    }
                }
                if (changed) break;
            }
        }
        
        if (changed) {
            root.modelDataArray = apps;
        }
        
        root.modelUpdateTrigger += 1;
    }

    property var _toplevels: Hyprland.toplevels.values
    on_ToplevelsChanged: {
        root.rebuildModel()
        delayedRebuildTimer.restart()
    }
    
    Timer {
        id: delayedRebuildTimer
        interval: 100
        repeat: false
        onTriggered: root.rebuildModel()
    }
    
    property var activeTop: Hyprland.activeToplevel
    onActiveTopChanged: {
        root.rebuildModel()
        delayedRebuildTimer.restart()
    }

    Connections {
        target: GlobalConfig.launcher
        function onFavouriteAppsChanged(): void {
            root.rebuildModel();
        }
    }

    Component.onCompleted: root.rebuildModel()
}