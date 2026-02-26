// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common

GraphicsBox {
    id: root
    title.text: "SYSTEM EXPLOIT: CITY HUNTER"
    title.color: "#00FF41"
    width: 650
    height: 450

    Rectangle {
        anchors.fill: parent
        color: "#0D0D0D"
        border.color: "#00FF41"
        border.width: 2
        z: -1
        
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#1A00FF41" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            opacity: 0.1
        }
    }

    property var allGenerals: []
    property int currentGold: 0
    property int currentShuaidian: 0
    property string selectedGeneral: ""
    
    function loadData(data) {
        if (data) {
            if (data.generals) allGenerals = data.generals;
            if (data.gold !== undefined) currentGold = data.gold;
            if (data.shuaidian !== undefined) currentShuaidian = data.shuaidian;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Text {
            text: "> 正在初始化绕过程序..."
            color: "#00FF41"
            font.family: "Courier New"
            font.pixelSize: 14
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 30
            
            ColumnLayout {
                spacing: 8
                Label { 
                    text: "[ 金库 ]"
                    color: "#00FF41"
                    font.bold: true
                    font.family: "Courier New"
                }
                Label { 
                    text: "当前余额: " + currentGold
                    color: "#00FF41"
                    font.family: "Courier New"
                }
                TextField {
                    id: goldInput
                    placeholderText: "偏移值..."
                    placeholderTextColor: "#4400FF41"
                    color: "#00FF41"
                    font.family: "Courier New"
                    background: Rectangle {
                        border.color: "#00FF41"
                        border.width: 1
                        color: "#1A1A1A"
                    }
                    validator: IntValidator {}
                    width: 180
                }
            }

            ColumnLayout {
                spacing: 8
                Label { 
                    text: "[ 官阶状态 ]"
                    color: "#00FF41"
                    font.bold: true
                    font.family: "Courier New"
                }
                Label { 
                    text: "当前帅点: " + currentShuaidian
                    color: "#00FF41"
                    font.family: "Courier New"
                }
                TextField {
                    id: shuaidianInput
                    placeholderText: "偏移值..."
                    placeholderTextColor: "#4400FF41"
                    color: "#00FF41"
                    font.family: "Courier New"
                    background: Rectangle {
                        border.color: "#00FF41"
                        border.width: 1
                        color: "#1A1A1A"
                    }
                    validator: IntValidator {}
                    width: 180
                }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 10

            Label { 
                text: "[ 伪装武将目标 ]"
                color: "#00FF41"
                font.bold: true
                font.family: "Courier New"
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "#1A1A1A"
                border.color: "#00FF41"
                border.width: 1
                clip: true

                ListView {
                    id: generalList
                    anchors.fill: parent
                    anchors.margins: 5
                    model: allGenerals
                    delegate: ItemDelegate {
                        width: parent.width
                        height: 40
                        
                        contentItem: RowLayout {
                            spacing: 10
                            Text {
                                text: root.selectedGeneral === modelData ? ">" : " "
                                color: "#00FF41"
                                font.family: "Courier New"
                                font.bold: true
                            }
                            Text {
                                text: Lua.tr(modelData) + " [" + modelData + "]"
                                color: root.selectedGeneral === modelData ? "#00FF41" : "#8800FF41"
                                font.family: "Courier New"
                                Layout.fillWidth: true
                            }
                        }
                        
                        onClicked: root.selectedGeneral = modelData
                        
                        background: Rectangle {
                            color: root.selectedGeneral === modelData ? "#3300FF41" : "transparent"
                        }
                    }
                    ScrollBar.vertical: ScrollBar {
                        active: true
                        contentItem: Rectangle {
                            implicitWidth: 8
                            color: "#00FF41"
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 20
            
            MetroButton {
                text: "执行"
                onClicked: {
                    let result = {
                        goldChange: parseInt(goldInput.text) || 0,
                        shuaidianChange: parseInt(shuaidianInput.text) || 0,
                        newGeneral: root.selectedGeneral
                    };
                    close();
                    roomScene.state = "notactive";
                    ClientInstance.replyToServer("", JSON.stringify(result));
                }
            }
            
            MetroButton {
                text: "中止"
                onClicked: {
                    close();
                    roomScene.state = "notactive";
                    ClientInstance.replyToServer("", "");
                }
            }
        }
        
        Text {
            text: "系统版本: 1.0.4-EXPLOIT"
            color: "#4400FF41"
            font.family: "Courier New"
            font.pixelSize: 10
            Layout.alignment: Qt.AlignLeft
        }
    }
}
