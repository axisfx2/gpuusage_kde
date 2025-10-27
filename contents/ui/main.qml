import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root
    property var gpus: []
    property int circleSize: 38
    property Item compactRef: null

    // --- Data collection ---
    PlasmaCore.DataSource {
        id: nvidiaSource
        engine: "executable"
        connectedSources: []
        interval: 5000

        onNewData: function (source, data) {
            if (!data["stdout"]) return
            var lines = data["stdout"].trim().split("\n")
            var results = []
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split(",")
                if (parts.length >= 6) {
                    var name = parts[0].trim()
                    var gpu = parseInt(parts[1])
                    var memUsed = parseInt(parts[2])
                    var memTotal = parseInt(parts[3])
                    var temp = parseInt(parts[4])
                    var index = parseInt(parts[5])
                    var memPercent = Math.round((memUsed / memTotal) * 100)
                    var tempPercent = Math.min(100, Math.round((temp / 100) * 100))
                    results.push({
                        name: name,
                        gpu: gpu,
                        mem: memPercent,
                        memUsed: memUsed,
                        memTotal: memTotal,
                        temp: tempPercent,
                        tempRaw: temp,
                        index: index
                    })
                }
            }
            root.gpus = results
        }

        function update() {
            var cmd = "/usr/bin/nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu,index --format=csv,noheader,nounits"
            connectedSources = [cmd]
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: nvidiaSource.update()
    }

    Component.onCompleted: nvidiaSource.update()

    // --- Compact taskbar widget ---
    Plasmoid.compactRepresentation: Item {
        id: compactItem
        Component.onCompleted: root.compactRef = compactItem

        Layout.preferredHeight: root.circleSize
        Layout.minimumHeight: root.circleSize
        Layout.preferredWidth: (root.circleSize + 10) * Math.max(1, root.gpus.length)
        Layout.minimumWidth: Layout.preferredWidth

        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: root.gpus
                delegate: Item {
                    width: root.circleSize
                    height: root.circleSize

                    // Extract first number token (e.g. "4090")
                    property string shortLabel: {
                        var match = modelData.name.match(/\b\d+\b/)
                        return match ? match[0] : ("GPU" + modelData.index)
                    }

                    GPUCircle {
                        anchors.centerIn: parent
                        gpuPercent: modelData.gpu
                        memPercent: modelData.mem
                        tempPercent: modelData.temp
                        circleSize: width
                    }

                    Label {
                        anchors.centerIn: parent
                        text: shortLabel
                        color: "white"
                        font.bold: false
                        font.pixelSize: Math.max(9, width * 0.32)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        z: 10
                        style: Text.Outline
                        styleColor: "#000000aa"
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (popupDialog.visible)
                    popupDialog.visible = false
                else
                    popupDialog.openRelativeToPanel()
            }
        }
    }

    // --- Popup dialog ---
    PlasmaCore.Dialog {
        id: popupDialog
        visible: false
        flags: Qt.WindowStaysOnTopHint | Qt.Tool
        location: PlasmaCore.Types.Floating
        type: PlasmaCore.Dialog.PopupMenu
        backgroundHints: PlasmaCore.Dialog.StandardBackground

        function openRelativeToPanel() {
            if (!root.compactRef)
                return

            var screen = Qt.application.screens[0]
            var panelEdge = plasmoid.location

            var pos = root.compactRef.mapToItem(null, 0, 0)
            var globalX = pos.x + (root.compactRef.width / 2) - (popupRect.width / 2)
            var globalY = pos.y

            if (panelEdge === PlasmaCore.Types.BottomEdge)
                globalY = screen.height - root.compactRef.height - popupRect.height - 8
            else if (panelEdge === PlasmaCore.Types.TopEdge)
                globalY = root.compactRef.height + 8
            else if (panelEdge === PlasmaCore.Types.LeftEdge)
                globalX = root.compactRef.width + 8
            else if (panelEdge === PlasmaCore.Types.RightEdge)
                globalX = screen.width - root.compactRef.width - popupRect.width - 8

            x = Math.max(0, globalX)
            y = Math.max(0, globalY)
            visible = true
            requestActivate()
        }

        onActiveChanged: if (visible && !active) visible = false

        mainItem: Rectangle {
            id: popupRect
            width: 600
            color: "#2b2b2b"
            radius: 8
            border.color: "#555"
            border.width: 1

            ColumnLayout {
                id: popupLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Label {
                    text: "GPU Usage"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignHCenter
                }

                Repeater {
                    model: root.gpus
                    delegate: ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: 12
                            Layout.fillWidth: true

                            GPUCircle {
                                gpuPercent: modelData.gpu
                                memPercent: modelData.mem
                                tempPercent: modelData.temp
                                circleSize: 50
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                Label {
                                    text: modelData.name
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 14
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                }

                                RowLayout {
                                    spacing: 6
                                    Rectangle { width: 8; height: 8; radius: 4; color: "#00ff00" }
                                    Label {
                                        text: "Utilization: " + modelData.gpu + "%"
                                        color: "white"
                                        font.pixelSize: 12
                                    }
                                }

                                RowLayout {
                                    spacing: 6
                                    Rectangle { width: 8; height: 8; radius: 4; color: "#4aa3ff" }
                                    Label {
                                        text: "Memory: " + modelData.memUsed + " MB / " + modelData.memTotal + " MB (" + modelData.mem + "%)"
                                        color: "white"
                                        font.pixelSize: 12
                                    }
                                }

                                RowLayout {
                                    spacing: 6
                                    Rectangle { width: 8; height: 8; radius: 4; color: "#ff1744" }
                                    Label {
                                        text: "Temperature: " + modelData.tempRaw + "°C"
                                        color: "white"
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#444"
                            visible: index < root.gpus.length - 1
                        }
                    }
                }
            }

            implicitHeight: popupLayout.implicitHeight + 30
        }
    }
}
