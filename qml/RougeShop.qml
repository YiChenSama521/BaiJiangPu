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

    property bool can_refresh: true
    property var result: []
    property int money: 0
    property int refresh_count: 0
    property int refresh_cost: 10

    title.text: Lua.tr("YC_YQS_shop") + "\n" + Util.processPrompt("#YC_YQS_current:::" + Lua.tr("YC_YQS_shop_gold") + "x" + money)
    width: Math.max(140, body.width + 20)
    height: buttons.height + body.height + title.height + 20

    Component {
        id: talentOrSkill
        Flickable {
            property var modelValue: [0, 0, "slash"]
            x: 4
            contentHeight: detail.height
            clip: true
            Text {
                id: detail
                width: parent.width
                text: `<h3>${Lua.tr(modelValue[2])}</h3>${Lua.tr(":" + modelValue[2])}`
                color: "white"
                wrapMode: Text.WordWrap
                font.pixelSize: 16
                textFormat: TextEdit.RichText
            }
        }
    }

    Component {
        id: cardDelegate
        Item {
            property var modelValue: [0, 0, "slash", 7, 0]
            CardItem {
                anchors.centerIn: parent
                name: parent.modelValue[2]
                number: parent.modelValue[3]
                suit: (["spade", "club", "heart", "diamond"])[parent.modelValue[4] - 1]
            }
        }
    }

    ListView {
        id: body
        x: 10
        y: title.height + 5
        width: 880
        height: 300
        orientation: ListView.Horizontal
        clip: true
        spacing: 20

        model: []

        delegate: Item {
            width: 200
            height: 290

            MetroToggleButton {
                id: choicetitle
                width: parent.width
                text: Lua.tr("YC_YQS_shop_gold") + "x" + modelData[1]
                triggered: root.result.includes(index)
                textFont.pixelSize: 24
                anchors.top: choiceDetail.bottom
                anchors.topMargin: 8
                enabled: {
                    if (triggered)
                        return true;
                    let rest_money = root.money;
                    root.result.forEach(idx => rest_money -= body.model[idx][1]);
                    return modelData[1] <= rest_money;
                }

                onClicked: {
                    if (triggered) {
                        root.result.push(index);
                    } else {
                        root.result.splice(root.result.indexOf(index), 1);
                    }
                    root.result = root.result;
                }
            }

            Loader {
                id: choiceDetail
                width: parent.width
                height: parent.height - choicetitle.height
                sourceComponent: {
                    switch (modelData[0]) {
                    case 'talent':
                    case 'skill':
                        return talentOrSkill;
                    case 'card':
                        return cardDelegate;
                    default:
                        return;
                    }
                }
                Binding {
                    target: choiceDetail.item
                    property: "modelValue"
                    value: modelData
                }
            }
        }
    }

    Row {
        id: buttons
        anchors.margins: 8
        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: body.bottom
        spacing: 32

        MetroButton {
            id: buttonRefresh
            width: 200
            Layout.fillWidth: true
            text: Lua.tr("YC_YQS_shop_refresh") + "（" + Lua.tr("YC_YQS_shop_gold") + "x" + root.refresh_cost + "）"
            enabled: root.money >= root.refresh_cost
            visible: can_refresh

            onClicked: {
                root.money -= root.refresh_cost;
                close();
                roomScene.state = "notactive";
                const result = [-10, root.result.map(idx => body.model[idx])];
                ClientInstance.replyToServer("", JSON.stringify(result));
            }
        }

        MetroButton {
            id: buttonConfirm
            width: 200
            Layout.fillWidth: true
            text: Lua.tr("YC_YQS_shop_ok")

            onClicked: {
                close();
                roomScene.state = "notactive";
                const result = [2, root.result.map(idx => body.model[idx])];
                ClientInstance.replyToServer("", JSON.stringify(result));
            }
        }

        MetroButton {
            id: buttonCancel
            width: 200
            Layout.fillWidth: true
            text: Lua.tr("YC_YQS_shop_cancel")

            onClicked: {
                close();
                roomScene.state = "notactive";
                ClientInstance.replyToServer("", "");
            }
        }
    }

    function loadData(data) {
        root.money = Lua.evaluate('Self:getMark("YC_YQS_shop_gold")');
        body.model = data.items !== undefined ? data.items : data;
        root.refresh_cost = data.refresh_cost !== undefined ? data.refresh_cost : 10;
    }
}
