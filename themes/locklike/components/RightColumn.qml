import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../widgets"

ColumnLayout {
    id: root

    property bool firstInput: false
    property real mainCardComponentsOpacity: 1
    property int animDuration: 300
    property real smallRadius: 35
    property real mainCardRadius: 70
    property bool welcomeEnabled: true
    property bool sessionPickerEnabled: false
    property bool powerConfirmEnabled: true
    property bool apEnabled: false
    property string avatarShape: "hexagon"
    property var localeManager: null
    property bool settingsOpen: false
    property int syncDelay: 150
    property real bgBlur: 0.5
    property int powerOverlay: 60
    property int powerBlur: 100
    property real mainCardBlur: parseFloat(config.mainCardBlurAmount) || 1.0
    property real mainCardOpacity: parseFloat(config.mainCardComponentsOpacity) || 1.0
    property bool mainCardBgBlurEnabled: config.mainCardBgBlur === "true"
    property real welcomeBgBlurAmountVal: parseFloat(config.welcomeBgBlurAmount) || 1.0
    property bool welcomeBgBlurVal: config.welcomeBgBlur === "true"
    property real welcomeColorOpacityVal: parseFloat(config.welcomeColorOpacity) || 0.7
    property real mainCardColorOpacityVal: parseFloat(config.mainCardColorOpacity) || 0.9
    property int settingsFontSize: parseInt(config.settingsFontSize) || 18
    property int settingsTitleSize: parseInt(config.settingsTitleSize) || 24

    function closeSettings() {
        settingsOpen = false;
    }

    spacing: 13
    Layout.alignment: Qt.AlignRight

    Rectangle {
        width: 400
        height: 355
        color: config.subComponents
        radius: root.smallRadius
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

        Behavior on color {
            ColorAnimation { duration: root.animDuration }
        }

        RandomQuote {
            maxWidth: parent.width - 40
            color: config.text
        }

        Behavior on opacity {
            NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
        }
    }

    Rectangle {
        width: 400
        height: 355
        color: config.subComponents
        bottomRightRadius: root.mainCardRadius / 1.9
        radius: root.mainCardRadius / 4
        opacity: root.firstInput ? 0 : root.mainCardComponentsOpacity

        Behavior on color {
            ColorAnimation { duration: root.animDuration }
        }

        Behavior on opacity {
            NumberAnimation { duration: root.animDuration; easing.type: Easing.OutBack }
        }

        Image {
            id: dino
            width: 300
            height: 150
            source: "../assets/dino.png"
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectCrop
            visible: !root.settingsOpen
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: config.inverseOnSurface

                Behavior on color {
                    ColorAnimation { duration: root.animDuration }
                }
            }
        }

        Text {
            renderType: Text.NativeRendering
            text: config.unlockForNotifications
            color: config.inverseOnSurface
            font.family: "CaskaydiaCove NF"
            font.pointSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            visible: !root.settingsOpen

            Behavior on color {
                ColorAnimation { duration: root.animDuration }
            }
        }

        Rectangle {
            anchors.right: parent.right; anchors.top: parent.top
            anchors.rightMargin: 8; anchors.topMargin: 8
            width: 36; height: 36; radius: 18
            color: gearMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)
            visible: !root.settingsOpen

            Text {
                anchors.centerIn: parent
                text: "\ue8b8"
                font.family: "Material Symbols Rounded"
                font.pointSize: 18
                color: config.text
            }

            MouseArea {
                id: gearMouse
                anchors.fill: parent; hoverEnabled: true
                onClicked: root.settingsOpen = true
            }
        }

        Item {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: 52
            visible: root.settingsOpen

            Text {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16
                text: config.settingsTitle
                color: config.text
                font.family: "Rubik"; font.pixelSize: root.settingsTitleSize; font.bold: true
                Behavior on color { ColorAnimation { duration: root.animDuration } }
            }

            Rectangle {
                anchors.right: parent.right; anchors.top: parent.top
                anchors.rightMargin: 8; anchors.topMargin: 8
                width: 36; height: 36; radius: 18
                color: headerCloseMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)
                Text {
                    anchors.centerIn: parent
                    text: "\ue5cd"
                    font.family: "Material Symbols Rounded"
                    font.pointSize: 18
                    color: config.text
                }
                MouseArea {
                    id: headerCloseMouse
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: root.closeSettings()
                }
            }
        }

        Flickable {
            id: settingsFlickable
            anchors.fill: parent
            anchors.topMargin: 52
            anchors.leftMargin: 16; anchors.rightMargin: 16
            anchors.bottomMargin: 16
            clip: true
            visible: root.settingsOpen
            contentHeight: settingsColumn.height
            interactive: contentHeight > height

            Column {
                id: settingsColumn
                width: parent.width
                spacing: 8

                SettingsGroup {
                    groupTitle: "Animations"
                    groupVisible: config.showAnimationSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.animationSpeed
                        sliderValue: root.animDuration
                        maxValue: 1000
                        valueText: root.animDuration === 0 ? "off" : root.animDuration + "ms"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showAnimSpeed !== "false"
                        onValueModified: root.animDuration = value
                    }

                    SliderRow {
                        labelText: config.syncDelay
                        sliderValue: root.syncDelay
                        maxValue: 500
                        valueText: root.syncDelay + "ms"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showSyncDelay !== "false"
                        rowEnabled: root.animDuration !== 0
                        onValueModified: root.syncDelay = value
                    }
                }

                SettingsGroup {
                    groupTitle: "Fonts"
                    groupVisible: config.showFontSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.settingsFontSizeLabel
                        sliderValue: root.settingsFontSize
                        maxValue: 30
                        stepSize: 1
                        valueText: root.settingsFontSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        onValueModified: root.settingsFontSize = value
                    }

                    SliderRow {
                        labelText: config.settingsTitleSizeLabel
                        sliderValue: root.settingsTitleSize
                        maxValue: 36
                        stepSize: 1
                        valueText: root.settingsTitleSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        onValueModified: root.settingsTitleSize = value
                    }
                }

                SettingsGroup {
                    groupTitle: "Main Card"
                    groupVisible: config.showMainCardSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.cardBlurLabel
                        sliderValue: Math.round(root.mainCardBlur * 100)
                        maxValue: 100
                        stepSize: 1
                        valueText: Math.round(root.mainCardBlur * 100) + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showMainCardBlur !== "false"
                        onValueModified: root.mainCardBlur = value / 100
                    }

                    SliderRow {
                        labelText: config.cardOpacityLabel
                        sliderValue: Math.round(root.mainCardOpacity * 100)
                        maxValue: 100
                        stepSize: 1
                        valueText: Math.round(root.mainCardOpacity * 100) + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showMainCardOpacity !== "false"
                        onValueModified: root.mainCardOpacity = value / 100
                    }

                    SliderRow {
                        labelText: config.cardColorOpacityLabel
                        sliderValue: Math.round(root.mainCardColorOpacityVal * 100)
                        maxValue: 100
                        stepSize: 1
                        valueText: Math.round(root.mainCardColorOpacityVal * 100) + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showMainCardColorOpacity !== "false"
                        onValueModified: root.mainCardColorOpacityVal = value / 100
                    }

                    ToggleRow {
                        labelText: config.cardBlurToggleLabel
                        toggleChecked: root.mainCardBgBlurEnabled
                        fontSize: root.settingsFontSize
                        showWhen: config.showMainCardBgBlur !== "false"
                        onToggled: root.mainCardBgBlurEnabled = value
                    }
                }

                SettingsGroup {
                    groupTitle: "Welcome"
                    groupVisible: config.showWelcomeSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    ToggleRow {
                        labelText: config.welcomeMessageLabel
                        toggleChecked: root.welcomeEnabled
                        fontSize: root.settingsFontSize
                        showWhen: config.showWelcomeToggle !== "false"
                        onToggled: root.welcomeEnabled = value
                    }

                    ToggleRow {
                        labelText: config.welcomeBgBlurLabel
                        toggleChecked: root.welcomeBgBlurVal
                        fontSize: root.settingsFontSize
                        showWhen: config.showWelcomeBgBlur !== "false"
                        onToggled: root.welcomeBgBlurVal = value
                    }

                    SliderRow {
                        labelText: config.welcomeBgBlurLabel
                        sliderValue: Math.round(root.welcomeBgBlurAmountVal * 100)
                        maxValue: 100
                        stepSize: 1
                        valueText: Math.round(root.welcomeBgBlurAmountVal * 100) + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showWelcomeBgBlurAmount !== "false"
                        onValueModified: root.welcomeBgBlurAmountVal = value / 100
                    }

                    SliderRow {
                        labelText: config.welcomeColorOpacityLabel
                        sliderValue: Math.round(root.welcomeColorOpacityVal * 100)
                        maxValue: 100
                        stepSize: 1
                        valueText: Math.round(root.welcomeColorOpacityVal * 100) + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showWelcomeColorOpacity !== "false"
                        onValueModified: root.welcomeColorOpacityVal = value / 100
                    }
                }

                SettingsGroup {
                    groupTitle: "Power"
                    groupVisible: config.showPowerSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.overlayDarkness
                        sliderValue: root.powerOverlay
                        maxValue: 100
                        stepSize: 1
                        valueText: root.powerOverlay + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showPowerOverlay !== "false"
                        onValueModified: root.powerOverlay = value
                    }

                    SliderRow {
                        labelText: config.powerDialogBlur
                        sliderValue: root.powerBlur
                        maxValue: 100
                        stepSize: 1
                        valueText: root.powerBlur + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showPowerBlur !== "false"
                        onValueModified: root.powerBlur = value
                    }

                    ToggleRow {
                        labelText: config.powerConfirmLabel
                        toggleChecked: root.powerConfirmEnabled
                        fontSize: root.settingsFontSize
                        showWhen: config.showPowerConfirm !== "false"
                        onToggled: root.powerConfirmEnabled = value
                    }
                }

                SettingsGroup {
                    groupTitle: "System"
                    groupVisible: config.showSystemSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.backgroundBlur
                        sliderValue: Math.round(root.bgBlur * 100)
                        maxValue: 100
                        stepSize: 1
                        valueText: Math.round(root.bgBlur * 100) + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showBgBlur !== "false"
                        onValueModified: root.bgBlur = value / 100
                    }

                    ToggleRow {
                        labelText: config.apLabel
                        toggleChecked: root.apEnabled
                        showWhen: config.showAp !== "false"
                        fontSize: root.settingsFontSize
                        onToggled: root.apEnabled = value
                    }

                    ToggleRow {
                        labelText: config.sessionPickerLabel
                        toggleChecked: root.sessionPickerEnabled
                        showWhen: config.showSessionPicker !== "false"
                        fontSize: root.settingsFontSize
                        onToggled: root.sessionPickerEnabled = value
                    }
                }

                SettingsGroup {
                    groupTitle: "Avatar"
                    groupVisible: config.showAvatarSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    Text {
                        visible: config.showAvatarShape !== "false"
                        text: config.avatarShapeLabel
                        color: config.textDark
                        font.family: "Rubik"; font.pixelSize: root.settingsFontSize
                    }

                    Item {
                        width: parent.width
                        height: avatarShapeDD.height
                        visible: config.showAvatarShape !== "false"
                        DropdownStyle {
                            id: avatarShapeDD
                            model: [config.hexagonLabel, config.circleLabel]
                            iconChar: "hexagon"
                            animDuration: root.animDuration
                            anchors.horizontalCenter: parent.horizontalCenter
                            Component.onCompleted: {
                                currentIndex = root.avatarShape === "circle" ? 1 : 0;
                            }
                            onActivated: function(index) {
                                root.avatarShape = index === 1 ? "circle" : "hexagon";
                            }
                            on_OpenChanged: {
                                if (_open) {
                                    var myY = avatarShapeDD.mapToItem(settingsColumn, 0, 0).y;
                                    settingsFlickable.contentY = Math.max(0, myY + avatarShapeDD.height - settingsFlickable.height + 120);
                                }
                            }
                        }
                    }

                    Item { height: avatarShapeDD._open ? 100 : 4; width: 1 }
                }

                SettingsGroup {
                    groupTitle: "Language"
                    groupVisible: config.showLanguageSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    Text {
                        visible: config.showLanguageDropdown !== "false"
                        text: config.language
                        color: config.textDark
                        font.family: "Rubik"; font.pixelSize: root.settingsFontSize
                    }

                    Item {
                        width: parent.width
                        height: langPicker.height
                        visible: config.showLanguageDropdown !== "false"
                        LanguagePicker {
                            id: langPicker
                            localeManager: root.localeManager
                            animDuration: root.animDuration
                            anchors.horizontalCenter: parent.horizontalCenter
                            onExpandedChanged: {
                                if (expanded) {
                                    var myY = langPicker.mapToItem(settingsColumn, 0, 0).y;
                                    settingsFlickable.contentY = Math.max(0, myY + langPicker.height - settingsFlickable.height + 120);
                                }
                            }
                        }
                    }

                    Item { height: langPicker.expanded ? 100 : 0; width: 1 }
                }
            }
        }
    }
}
