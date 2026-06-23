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
    property string locale: "en"
    property real smallRadius: 35
    property real mainCardRadius: 70
    property bool welcomeEnabled: true
    property bool sessionPickerEnabled: false
    property bool powerConfirmEnabled: true
    property bool apEnabled: false
    property string avatarShape: config.AvatarShape || "hexagon"
    property var localeManager: null
    property bool settingsOpen: false
    property int syncDelay: 150
    property real bgBlur: 0.5
    property int powerOverlay: 60
    property real mainCardOpacity: parseFloat(config.mainCardComponentsOpacity) || 1.0
    property real welcomeColorOpacityVal: parseFloat(config.welcomeColorOpacity) || 0.7
    property real mainCardColorOpacityVal: parseFloat(config.mainCardColorOpacity) || 0.9
    property int settingsFontSize: parseInt(config.settingsFontSize) || 18
    property int settingsTitleSize: parseInt(config.settingsTitleSize) || 24
    property int welcomeFontSize: parseInt(config.welcomeFontSize) || 40
    property int fetchFontSize: parseInt(config.fetchFontSize) || 18
    property int buttonFontSize: parseInt(config.buttonFontSize) || 14
    property int dialogTitleSize: parseInt(config.dialogTitleSize) || 20
    property int dialogBodySize: parseInt(config.dialogBodySize) || 14
    property int quoteFontSize: parseInt(config.quoteFontSize) || 20
    property int dropdownLabelSize: parseInt(config.dropdownLabelSize) || 14
    property int dropdownItemSize: parseInt(config.dropdownItemSize) || 13

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
            locale: root.locale
            maxWidth: parent.width - 40
            color: config.text
            fontSize: root.quoteFontSize
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
                    groupTitle: config.groupAnimations
                    groupVisible: config.showAnimationSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.animationSpeedLabel
                        sliderValue: root.animDuration
                        maxValue: 1000
                        valueText: root.animDuration === 0 ? "off" : root.animDuration + "ms"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showAnimSpeed !== "false"
                        onValueModified: root.animDuration = value
                    }

                    SliderRow {
                        labelText: config.syncDelayLabel
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
                    groupTitle: config.groupFonts
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

                    SliderRow {
                        labelText: config.welcomeFontSizeLabel
                        sliderValue: root.welcomeFontSize
                        maxValue: 72
                        stepSize: 1
                        valueText: root.welcomeFontSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showWelcomeFontSize !== "false"
                        onValueModified: root.welcomeFontSize = value
                    }

                    SliderRow {
                        labelText: config.quoteFontSizeLabel
                        sliderValue: root.quoteFontSize
                        maxValue: 50
                        stepSize: 1
                        valueText: root.quoteFontSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showQuoteFontSize !== "false"
                        onValueModified: root.quoteFontSize = value
                    }

                    SliderRow {
                        labelText: config.fetchFontSizeLabel
                        sliderValue: root.fetchFontSize
                        maxValue: 30
                        stepSize: 1
                        valueText: root.fetchFontSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showFetchFontSize !== "false"
                        onValueModified: root.fetchFontSize = value
                    }

                    SliderRow {
                        labelText: config.buttonFontSizeLabel
                        sliderValue: root.buttonFontSize
                        maxValue: 24
                        stepSize: 1
                        valueText: root.buttonFontSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showButtonFontSize !== "false"
                        onValueModified: root.buttonFontSize = value
                    }

                    SliderRow {
                        labelText: config.dialogTitleSizeLabel
                        sliderValue: root.dialogTitleSize
                        maxValue: 36
                        stepSize: 1
                        valueText: root.dialogTitleSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showDialogTitleSize !== "false"
                        onValueModified: root.dialogTitleSize = value
                    }

                    SliderRow {
                        labelText: config.dialogBodySizeLabel
                        sliderValue: root.dialogBodySize
                        maxValue: 24
                        stepSize: 1
                        valueText: root.dialogBodySize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showDialogBodySize !== "false"
                        onValueModified: root.dialogBodySize = value
                    }

                    SliderRow {
                        labelText: config.dropdownLabelSizeLabel
                        sliderValue: root.dropdownLabelSize
                        maxValue: 24
                        stepSize: 1
                        valueText: root.dropdownLabelSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showDropdownLabelSize !== "false"
                        onValueModified: root.dropdownLabelSize = value
                    }

                    SliderRow {
                        labelText: config.dropdownItemSizeLabel
                        sliderValue: root.dropdownItemSize
                        maxValue: 24
                        stepSize: 1
                        valueText: root.dropdownItemSize + "px"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showDropdownItemSize !== "false"
                        onValueModified: root.dropdownItemSize = value
                    }
                }

                SettingsGroup {
                    groupTitle: config.groupMainCard
                    groupVisible: config.showMainCardSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

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
                }

                SettingsGroup {
                    groupTitle: config.groupWelcome
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
                    groupTitle: config.groupPower
                    groupVisible: config.showPowerSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.overlayDarknessLabel
                        sliderValue: root.powerOverlay
                        maxValue: 100
                        stepSize: 1
                        valueText: root.powerOverlay + "%"
                        animDuration: root.animDuration
                        fontSize: root.settingsFontSize
                        showWhen: config.showPowerOverlay !== "false"
                        onValueModified: root.powerOverlay = value
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
                    groupTitle: config.groupSystem
                    groupVisible: config.showSystemSettingsGroup !== "false"
                    fontSize: root.settingsFontSize
                    animDuration: root.animDuration

                    SliderRow {
                        labelText: config.backgroundBlurLabel
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
                    groupTitle: config.groupAvatar
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
                    groupTitle: config.groupLanguage
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
