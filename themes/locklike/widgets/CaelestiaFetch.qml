import "../components"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property bool firstInput
    required property string currentSession
    required property string currentUser
    required property int rectHeight


    property string os: (config.os || "Arch").split(" ")[0]
    property string host: config.host || "localhost"
    property string session: (root.currentSession || "Hyprland").split(" ")[0]

    RowLayout {
        Rectangle {
            width: 33
            height: 35
            radius: 13
            Layout.leftMargin: 23
            Layout.topMargin: 25
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            color: config.secondary
            Behavior on color { ColorAnimation { duration: root.animDuration } }
            Text {
                renderType: Text.NativeRendering
                anchors.centerIn: parent
                color: "#111111"
                text: ">"
                font.family: "CaskaydiaCove NF"
                font.pointSize: 15
            }
        }

        Text {
            renderType: Text.NativeRendering
            color: config.text
            Behavior on color { ColorAnimation { duration: root.animDuration } }
            text: config.fetchTitle
            font.family: "CaskaydiaCove NF"; font.pointSize: 13
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.topMargin: 32
            Layout.leftMargin: 8
        }
    }

    ColumnLayout {
        Item {
            width: 30
            height: 30
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            Logo {
                skipIntroAnimation: root.firstInput
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.leftMargin: 25
                Layout.topMargin: 50
                Layout.preferredWidth: 130
                Layout.preferredHeight: 130
            }

            RowLayout {
                spacing: 10

                Text {
                    renderType: Text.NativeRendering
                    Layout.leftMargin: 12; Layout.topMargin: root.rectHeight / 10
                    text: (config.fetchLabels || "").replace(/\\n/g, "\n")
                    color: config.text
                    Behavior on color { ColorAnimation { duration: root.animDuration } }
                    font.pixelSize: parseInt(config.fetchFontSize) || 18
                    font.family: "CaskaydiaCove NF"
                    lineHeight: 30
                    lineHeightMode: Text.FixedHeight
                    Layout.preferredWidth: 80
                }

                Text {
                    renderType: Text.NativeRendering
                    Layout.leftMargin: 0
                    Layout.topMargin: root.rectHeight / 10
                    implicitHeight: sessionText.height + 90

                    Text {
                        id: sessionText
                        text: root.session
                        color: config.text
                        Behavior on color { ColorAnimation { duration: root.animDuration } }
                        font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        lineHeight: 30; lineHeightMode: Text.FixedHeight
                    }

                    Item {
                        y: 30
                        width: 100; height: userNameA.height
                        Text {
                            id: userNameA
                            color: config.text
                            Behavior on color { ColorAnimation { duration: root.animDuration } }
                            font.pixelSize: 18
                            font.family: "CaskaydiaCove NF"
                            lineHeight: 30; lineHeightMode: Text.FixedHeight
                            opacity: _activeUserName === 0 ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
                            }
                        }
                        Text {
                            id: userNameB
                            color: config.text
                            Behavior on color { ColorAnimation { duration: root.animDuration } }
                            font.pixelSize: 18
                            font.family: "CaskaydiaCove NF"
                            lineHeight: 30; lineHeightMode: Text.FixedHeight
                            opacity: _activeUserName === 0 ? 0 : 1
                            Behavior on opacity {
                                NumberAnimation { duration: root.animDuration; easing: Easing.InOutCubic }
                            }
                        }
                    }

                    Text {
                        y: 60
                        text: root.os
                        color: config.text
                        Behavior on color { ColorAnimation { duration: root.animDuration } }
                        font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        lineHeight: 30; lineHeightMode: Text.FixedHeight
                    }

                    Text {
                        y: 90
                        text: root.host
                        color: config.text
                        Behavior on color { ColorAnimation { duration: root.animDuration } }
                        font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        lineHeight: 30; lineHeightMode: Text.FixedHeight
                    }
                }
            }
        }

        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 30
            Layout.topMargin: 4

            Rectangle { width: 30; height: 30; color: config.background; radius: 12; Behavior on color { ColorAnimation { duration: root.animDuration } } }
            Rectangle { width: 30; height: 30; color: config.primary; radius: 12; Behavior on color { ColorAnimation { duration: root.animDuration } } }
            Rectangle { width: 30; height: 30; color: config.text; radius: 12; Behavior on color { ColorAnimation { duration: root.animDuration } } }
            Rectangle { width: 30; height: 30; color: config.textDark; radius: 12; Behavior on color { ColorAnimation { duration: root.animDuration } } }
            Rectangle { width: 30; height: 30; color: config.secondary; radius: 12; Behavior on color { ColorAnimation { duration: root.animDuration } } }
            Rectangle { width: 30; height: 30; color: config.onSuccess; radius: 12; Behavior on color { ColorAnimation { duration: root.animDuration } } }
            Rectangle { width: 30; height: 30; color: config.inverseOnSurface; radius: 12; Behavior on color { ColorAnimation { duration: root.animDuration } } }
        }
    }
}
