import QtQuick

Item {
    id: row
    property string labelText: ""
    property real sliderValue: 0
    property real maxValue: 100
    property int stepSize: 50
    property string valueText: ""
    property int animDuration: 300
    property bool showWhen: true
    property bool rowEnabled: true
    readonly property int _spacing: 16
    readonly property int _rowSpacing: 12
    readonly property int _sliderW: 60
    readonly property int _valueH: 32
    readonly property int _fontS: 13

    signal valueModified(real value)

    visible: showWhen
    width: parent.width
    height: col.height

    Column {
        id: col

        width: parent.width
        spacing: _spacing

        Text {
            text: labelText
            color: config.textDark
            font.family: "Rubik"
            font.pixelSize: _fontS
            opacity: rowEnabled ? 1 : 0.3
        }

        Row {
            spacing: _rowSpacing
            width: parent.width
            opacity: rowEnabled ? 1 : 0.3
            enabled: rowEnabled

            SliderStyle {
                width: parent.width - _sliderW
                value: sliderValue
                maxValue: row.maxValue
                stepSize: row.stepSize
                onValueChanged: {
                    if (value !== sliderValue)
                        valueModified(value);

                }
            }

            Text {
                text: valueText
                color: config.primary
                font.family: "Rubik"
                font.pixelSize: _fontS
                verticalAlignment: Text.AlignVCenter
                height: _valueH

                Behavior on color {
                    ColorAnimation {
                        duration: animDuration
                    }

                }

            }

        }

    }

}
