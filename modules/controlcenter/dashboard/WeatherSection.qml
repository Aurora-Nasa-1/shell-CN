import ".."
import "../components"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

SectionContainer {
    id: root

    required property var rootItem

    Layout.fillWidth: true
    alignTop: true

    StyledText {
        text: I18n.tr("天气设置")
        font.pointSize: Tokens.font.size.normal
        font.weight: 600
    }

    // ── 天气地点输入 ──
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        StyledText {
            text: I18n.tr("天气地点")
            font.pointSize: Tokens.font.size.small
            color: Colours.palette.m3onSurfaceVariant
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: locationRow.implicitHeight + Tokens.padding.normal * 2
            radius: Tokens.rounding.small
            color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

            RowLayout {
                id: locationRow

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Tokens.padding.normal
                spacing: Tokens.spacing.normal

                MaterialIcon {
                    text: "location_on"
                    font.pointSize: Tokens.font.size.large
                    color: Colours.palette.m3secondary
                }

                StyledInputField {
                    id: locationField

                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignLeft
                    text: GlobalConfig.services.weatherLocation || ""

                    onEditingFinished: {
                        const val = locationField.text.trim();
                        if (val !== GlobalConfig.services.weatherLocation) {
                            GlobalConfig.services.weatherLocation = val;
                            Weather.reload();
                        }
                    }
                }

                StyledText {
                    visible: GlobalConfig.services.weatherLocation !== "" && Weather && Weather.city !== ""
                    text: Weather.city || ""
                    color: Colours.palette.m3outline
                    font.pointSize: Tokens.font.size.smaller
                    elide: Text.ElideRight
                }
            }
        }

        StyledText {
            text: I18n.tr("输入城市名称（如「北京」）或经纬度坐标（如「39.9042,116.4074」）")
            font.pointSize: Tokens.font.size.smaller
            color: Colours.palette.m3outline
            wrapMode: Text.WordWrap
        }
    }

    // ── 常用中国城市快捷选择 ──
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        StyledText {
            text: I18n.tr("快速选择中国城市")
            font.pointSize: Tokens.font.size.small
            font.weight: 600
            color: Colours.palette.m3onSurfaceVariant
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.maximumHeight: 300
            columns: 5
            rowSpacing: Tokens.spacing.small
            columnSpacing: Tokens.spacing.small

            CityButton { city: "北京"; coord: "39.9042,116.4074" }
            CityButton { city: "上海"; coord: "31.2304,121.4737" }
            CityButton { city: "天津"; coord: "39.3434,117.3616" }
            CityButton { city: "重庆"; coord: "29.4316,106.9123" }
            CityButton { city: "广州"; coord: "23.1291,113.2644" }

            CityButton { city: "深圳"; coord: "22.5431,114.0579" }
            CityButton { city: "杭州"; coord: "30.2741,120.1551" }
            CityButton { city: "成都"; coord: "30.5728,104.0668" }
            CityButton { city: "武汉"; coord: "30.5928,114.3055" }
            CityButton { city: "南京"; coord: "32.0603,118.7969" }

            CityButton { city: "西安"; coord: "34.3416,108.9398" }
            CityButton { city: "长沙"; coord: "28.2282,112.9388" }
            CityButton { city: "郑州"; coord: "34.7466,113.6253" }
            CityButton { city: "沈阳"; coord: "41.8057,123.4315" }
            CityButton { city: "青岛"; coord: "36.0671,120.3826" }

            CityButton { city: "苏州"; coord: "31.2990,120.5853" }
            CityButton { city: "昆明"; coord: "25.0389,102.7183" }
            CityButton { city: "大连"; coord: "38.9140,121.6147" }
            CityButton { city: "厦门"; coord: "24.4798,118.0894" }
            CityButton { city: "哈尔滨"; coord: "45.8038,126.5350" }

            CityButton { city: "福州"; coord: "26.0745,119.2965" }
            CityButton { city: "合肥"; coord: "31.8206,117.2272" }
            CityButton { city: "济南"; coord: "36.6512,116.9972" }
            CityButton { city: "南宁"; coord: "22.8170,108.3665" }
            CityButton { city: "贵阳"; coord: "26.6470,106.6302" }

            CityButton { city: "拉萨"; coord: "29.6500,91.1000" }
            CityButton { city: "乌鲁木齐"; coord: "43.8256,87.6168" }
            CityButton { city: "呼和浩特"; coord: "40.8422,111.7498" }
            CityButton { city: "兰州"; coord: "36.0611,103.8343" }
            CityButton { city: "西宁"; coord: "36.6171,101.7782" }

            CityButton { city: "银川"; coord: "38.4872,106.2309" }
            CityButton { city: "海口"; coord: "20.0440,110.3499" }
            CityButton { city: "台北"; coord: "25.0330,121.5654" }
            CityButton { city: "香港"; coord: "22.3193,114.1694" }
            CityButton { city: "澳门"; coord: "22.1987,113.5439" }
        }
    }

    // ── 快捷操作 ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.normal

        ActionButton {
            icon: "my_location"
            text: I18n.tr("自动检测位置")
            accent: true
            onClicked: {
                GlobalConfig.services.weatherLocation = "";
                Weather.reload();
            }
        }

        ActionButton {
            icon: "refresh"
            text: I18n.tr("刷新天气")
            onClicked: {
                Weather.reload();
            }
        }
    }

    // ── 温度单位切换 ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.normal

        SwitchRow {
            Layout.fillWidth: true
            label: I18n.tr("华氏温度 (°F)")
            checked: GlobalConfig.services.useFahrenheit
            onToggled: checked => {
                GlobalConfig.services.useFahrenheit = checked;
            }
        }

        SwitchRow {
            Layout.fillWidth: true
            label: I18n.tr("12小时制")
            checked: GlobalConfig.services.useTwelveHourClock
            onToggled: checked => {
                GlobalConfig.services.useTwelveHourClock = checked;
            }
        }
    }

    // ── 城市按钮 ──
    component CityButton: StyledRect {
        id: cityRoot

        property string city
        property string coord

        Layout.preferredHeight: cityLabel.implicitHeight + Tokens.padding.small * 2
        Layout.preferredWidth: cityLabel.implicitWidth + Tokens.padding.normal * 2
        radius: Tokens.rounding.small
        color: cityMouse.containsMouse ? Colours.layer(Colours.palette.m3surfaceContainer, 3) : Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.width: GlobalConfig.services.weatherLocation === coord ? 1 : 0
        border.color: Colours.palette.m3primary

        StyledText {
            id: cityLabel

            anchors.centerIn: parent
            text: cityRoot.city
            font.pointSize: Tokens.font.size.smaller
            color: GlobalConfig.services.weatherLocation === coord ? Colours.palette.m3primary : Colours.palette.m3onSurface
        }

        MouseArea {
            id: cityMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                GlobalConfig.services.weatherLocation = cityRoot.coord;
                Weather.reload();
                locationField.text = cityRoot.coord;
            }
        }
    }

    // ── 操作按钮 ──
    component ActionButton: StyledRect {
        id: actionRoot

        property string icon
        property string text
        property bool accent: false
        signal clicked

        Layout.fillWidth: true
        implicitHeight: actionRow.implicitHeight + Tokens.padding.normal * 2
        radius: Tokens.rounding.small
        color: actionMouse.containsMouse
            ? (accent ? Colours.layer(Colours.palette.m3primaryContainer, 2) : Colours.layer(Colours.palette.m3surfaceContainer, 3))
            : (accent ? Colours.layer(Colours.palette.m3primaryContainer, 1) : Colours.layer(Colours.palette.m3surfaceContainer, 2))

        RowLayout {
            id: actionRow

            anchors.centerIn: parent
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: actionRoot.icon
                font.pointSize: Tokens.font.size.large
                color: actionRoot.accent ? Colours.palette.m3primary : Colours.palette.m3tertiary
            }

            StyledText {
                text: actionRoot.text
                color: actionRoot.accent ? Colours.palette.m3primary : Colours.palette.m3tertiary
                font.pointSize: Tokens.font.size.small
                font.weight: 500
            }
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: actionRoot.clicked()
        }
    }
}
