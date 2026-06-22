import QtQuick

Rectangle {
    id: settingsPanel

    readonly property int _gap: 10
    readonly property int _margin: 2 * _gap
    readonly property int _spacing: 16
    readonly property int _btnS: 44
    readonly property int _titleH: 28
    readonly property int _closeM: 4
    readonly property int _spaceS: 8
    readonly property int _spaceMin: 4
    readonly property int _scrollOff: 12 * _gap
    readonly property int _spacerExp: 8 * _gap
    readonly property int _panelW: 320
    readonly property int _panelH: 520
    readonly property int _radiusOpen: 24
    readonly property int _radiusClosed: 22
    readonly property int _animOpen: 280
    readonly property int _animRadius: 220
    readonly property int _animContent: 180
    readonly property int _iconS: 16
    readonly property int _iconL: 20
    property bool sOpen: false
    property int animDuration: 300
    property int syncDelay: 150
    property real bgBlur: 0.5
    property int powerOverlay: 60
    property int powerBlur: 100
    property var localeManager: null
    property bool welcomeEnabled: true
    property real mainCardBlur: parseFloat(config.mainCardBlurAmount) || 1
    property real mainCardOpacity: parseFloat(config.mainCardComponentsOpacity) || 1
    property bool mainCardBgBlurEnabled: config.mainCardBgBlur === "true"
    property bool sessionPickerEnabled: config.sessionPicker !== "false"
    property bool powerConfirmEnabled: config.powerConfirmEnabled !== "false"
    property bool apEnabled: config.ap === "true"
    property string avatarShape: config.AvatarShape || "hexagon"
    property real welcomeBgBlurAmountVal: parseFloat(config.welcomeBgBlurAmount) || 1
    property bool welcomeBgBlurVal: config.welcomeBgBlur === "true"
    property real welcomeColorOpacityVal: parseFloat(config.welcomeColorOpacity) || 0.7
    property real mainCardColorOpacityVal: parseFloat(config.mainCardColorOpacity) || 0.9
    property bool _contentReady: false

    signal openChanged(bool open)

    function close() {
        contentTimer.stop();
        settingsPanel._contentReady = false;
        closeTimer.restart();
    }

    z: 100
    width: sOpen ? _panelW : _btnS
    height: sOpen ? _panelH : _btnS
    radius: sOpen ? _radiusOpen : _radiusClosed
    color: sOpen ? "transparent" : Qt.rgba(0, 0, 0, 0.35)
    onSOpenChanged: {
        settingsPanel.openChanged(settingsPanel.sOpen);
        if (!sOpen)
            settingsPanel._contentReady = false;

    }

    BackgroundCardStyle {
        anchors.fill: parent
        radius: settingsPanel.radius
        visible: settingsPanel.sOpen
    }

    Timer {
        id: contentTimer

        onTriggered: settingsPanel._contentReady = true
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: _spaceS
        height: _titleH
        visible: sOpen

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: _margin
            text: config.settingsTitle
            color: config.text
            font.family: "Rubik"
            font.pixelSize: 18
            font.bold: true

            Behavior on color {
                ColorAnimation {
                    duration: settingsPanel.animDuration
                }

            }

        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: _closeM
            anchors.verticalCenter: parent.verticalCenter
            width: _titleH
            height: _titleH
            radius: _titleH / 2
            color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)

            Text {
                anchors.centerIn: parent
                text: "\ue5cd"
                font.family: "Material Symbols Rounded"
                font.pointSize: _iconS
                color: config.text
            }

            MouseArea {
                id: closeMouse

                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    contentTimer.stop();
                    settingsPanel._contentReady = false;
                    closeTimer.restart();
                }
            }

        }

    }

    Timer {
        id: closeTimer

        interval: _animContent
        onTriggered: settingsPanel.sOpen = false
    }

    Rectangle {
        id: gearBtn

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 0
        anchors.topMargin: 0
        width: _btnS
        height: _btnS
        radius: _btnS / 2
        visible: !sOpen
        color: gearMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)

        Text {
            anchors.centerIn: parent
            text: "\ue8b8"
            font.family: "Material Symbols Rounded"
            font.pointSize: _iconL
            color: config.text
        }

        MouseArea {
            id: gearMouse

            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                closeTimer.stop();
                settingsPanel.sOpen = true;
                contentTimer.interval = _animOpen;
                contentTimer.restart();
            }
        }

    }

    Item {
        id: panelContent

        visible: opacity > 0
        anchors.fill: parent
        anchors.leftMargin: _margin
        anchors.rightMargin: _margin
        anchors.topMargin: _btnS
        anchors.bottomMargin: _margin
        opacity: _contentReady ? 1 : 0

        Flickable {
            id: settingsFlickable

            anchors.fill: parent
            clip: true
            contentHeight: settingsColumn.height
            interactive: contentHeight > height

            Column {
                id: settingsColumn

                width: parent.width
                spacing: _spacing

                Rectangle {
                    height: 1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: -_margin
                    anchors.rightMargin: -_margin
                    color: config.surfaceVariant || Qt.rgba(1, 1, 1, 0.06)
                }

                SliderRow {
                    labelText: config.animationSpeed
                    sliderValue: settingsPanel.animDuration
                    maxValue: 1000
                    valueText: settingsPanel.animDuration === 0 ? "off" : settingsPanel.animDuration + "ms"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showAnimSpeed !== "false"
                    onValueModified: settingsPanel.animDuration = value
                }

                SliderRow {
                    labelText: config.syncDelay
                    sliderValue: settingsPanel.syncDelay
                    maxValue: 500
                    valueText: settingsPanel.syncDelay + "ms"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showSyncDelay !== "false"
                    rowEnabled: settingsPanel.animDuration !== 0
                    onValueModified: settingsPanel.syncDelay = value
                }

                SliderRow {
                    labelText: config.backgroundBlur
                    sliderValue: Math.round(settingsPanel.bgBlur * 100)
                    maxValue: 100
                    stepSize: 1
                    valueText: Math.round(settingsPanel.bgBlur * 100) + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showBgBlur !== "false"
                    onValueModified: settingsPanel.bgBlur = value / 100
                }

                SliderRow {
                    labelText: config.overlayDarkness
                    sliderValue: settingsPanel.powerOverlay
                    maxValue: 100
                    stepSize: 1
                    valueText: settingsPanel.powerOverlay + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showPowerOverlay !== "false"
                    onValueModified: settingsPanel.powerOverlay = value
                }

                SliderRow {
                    labelText: config.powerDialogBlur
                    sliderValue: settingsPanel.powerBlur
                    maxValue: 100
                    stepSize: 1
                    valueText: settingsPanel.powerBlur + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showPowerBlur !== "false"
                    onValueModified: settingsPanel.powerBlur = value
                }

                SliderRow {
                    labelText: config.welcomeBgBlurLabel
                    sliderValue: Math.round(settingsPanel.welcomeBgBlurAmountVal * 100)
                    maxValue: 100
                    stepSize: 1
                    valueText: Math.round(settingsPanel.welcomeBgBlurAmountVal * 100) + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showWelcomeBgBlurAmount !== "false"
                    onValueModified: settingsPanel.welcomeBgBlurAmountVal = value / 100
                }

                SliderRow {
                    labelText: config.welcomeColorOpacityLabel
                    sliderValue: Math.round(settingsPanel.welcomeColorOpacityVal * 100)
                    maxValue: 100
                    stepSize: 1
                    valueText: Math.round(settingsPanel.welcomeColorOpacityVal * 100) + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showWelcomeColorOpacity !== "false"
                    onValueModified: settingsPanel.welcomeColorOpacityVal = value / 100
                }

                SliderRow {
                    labelText: config.cardColorOpacityLabel
                    sliderValue: Math.round(settingsPanel.mainCardColorOpacityVal * 100)
                    maxValue: 100
                    stepSize: 1
                    valueText: Math.round(settingsPanel.mainCardColorOpacityVal * 100) + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showMainCardColorOpacity !== "false"
                    onValueModified: settingsPanel.mainCardColorOpacityVal = value / 100
                }

                SliderRow {
                    labelText: config.cardBlurLabel
                    sliderValue: Math.round(settingsPanel.mainCardBlur * 100)
                    maxValue: 100
                    stepSize: 1
                    valueText: Math.round(settingsPanel.mainCardBlur * 100) + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showMainCardBlur !== "false"
                    onValueModified: settingsPanel.mainCardBlur = value / 100
                }

                SliderRow {
                    labelText: config.cardOpacityLabel
                    sliderValue: Math.round(settingsPanel.mainCardOpacity * 100)
                    maxValue: 100
                    stepSize: 1
                    valueText: Math.round(settingsPanel.mainCardOpacity * 100) + "%"
                    animDuration: settingsPanel.animDuration
                    showWhen: config.showMainCardOpacity !== "false"
                    onValueModified: settingsPanel.mainCardOpacity = value / 100
                }

                Item {
                    height: _spaceS
                    width: 1
                }

                ToggleRow {
                    labelText: config.welcomeMessageLabel
                    toggleChecked: settingsPanel.welcomeEnabled
                    showWhen: config.showWelcomeToggle !== "false"
                    onToggled: settingsPanel.welcomeEnabled = value
                }

                ToggleRow {
                    labelText: config.welcomeBgBlurLabel
                    toggleChecked: settingsPanel.welcomeBgBlurVal
                    showWhen: config.showWelcomeBgBlur !== "false"
                    onToggled: settingsPanel.welcomeBgBlurVal = value
                }

                ToggleRow {
                    labelText: config.apLabel
                    toggleChecked: settingsPanel.apEnabled
                    showWhen: config.showAp !== "false"
                    onToggled: settingsPanel.apEnabled = value
                }

                ToggleRow {
                    labelText: config.sessionPickerLabel
                    toggleChecked: settingsPanel.sessionPickerEnabled
                    showWhen: config.showSessionPicker !== "false"
                    onToggled: settingsPanel.sessionPickerEnabled = value
                }

                ToggleRow {
                    labelText: config.powerConfirmLabel
                    toggleChecked: settingsPanel.powerConfirmEnabled
                    showWhen: config.showPowerConfirm !== "false"
                    onToggled: settingsPanel.powerConfirmEnabled = value
                }

                ToggleRow {
                    labelText: config.cardBlurToggleLabel
                    toggleChecked: settingsPanel.mainCardBgBlurEnabled
                    showWhen: config.showMainCardBgBlur !== "false"
                    onToggled: settingsPanel.mainCardBgBlurEnabled = value
                }

                Item {
                    height: _spaceS
                    width: 1
                }

                Text {
                    visible: config.showAvatarShape !== "false"
                    text: config.avatarShapeLabel
                    color: config.textDark
                    font.family: "Rubik"
                    font.pixelSize: 13
                }

                DropdownStyle {
                    id: avatarShapeDD

                    visible: config.showAvatarShape !== "false"
                    model: [config.hexagonLabel, config.circleLabel]
                    iconChar: "hexagon"
                    animDuration: settingsPanel.animDuration
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - _margin
                    Component.onCompleted: {
                        var shape = settingsPanel.avatarShape.toLowerCase();
                        currentIndex = shape === "circle" ? 1 : 0;
                    }
                    onActivated: function(index) {
                        var val = index === 1 ? "circle" : "hexagon";
                        settingsPanel.avatarShape = val;
                        config.AvatarShape = val;
                    }
                    on_OpenChanged: {
                        if (_open) {
                            var myY = avatarShapeDD.mapToItem(settingsColumn, 0, 0).y;
                            settingsFlickable.contentY = Math.max(0, myY + avatarShapeDD.height - settingsFlickable.height + _scrollOff);
                        }
                    }
                }

                Item {
                    height: avatarShapeDD._open ? _spacerExp : _spaceMin
                    width: 1
                }

                Text {
                    visible: config.showLanguage !== "false"
                    text: config.language
                    color: config.textDark
                    font.family: "Rubik"
                    font.pixelSize: 13
                }

                LanguagePicker {
                    id: langPicker

                    visible: config.showLanguage !== "false"
                    localeManager: settingsPanel.localeManager
                    animDuration: settingsPanel.animDuration
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - _margin
                    onExpandedChanged: {
                        if (expanded) {
                            var myY = langPicker.mapToItem(settingsColumn, 0, 0).y;
                            settingsFlickable.contentY = Math.max(0, myY + langPicker.height - settingsFlickable.height + _scrollOff);
                        }
                    }
                }

                Item {
                    height: langPicker.expanded ? _spacerExp : 0
                    width: 1
                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: _animContent
            }

        }

    }

    Behavior on width {
        NumberAnimation {
            duration: _animOpen
            easing.type: Easing.OutQuint
        }

    }

    Behavior on height {
        NumberAnimation {
            duration: _animOpen
            easing.type: Easing.OutQuint
        }

    }

    Behavior on radius {
        NumberAnimation {
            duration: _animRadius
            easing.type: Easing.OutQuint
        }

    }

    Behavior on color {
        ColorAnimation {
            duration: settingsPanel.animDuration
        }

    }

}
