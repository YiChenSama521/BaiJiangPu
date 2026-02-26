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

  property var cards: []
  property var skills: []
  property var selected: []
  property int min
  property int max
  property string prompt
  property bool cancelable: false

  title.text: Util.processPrompt(prompt)
  // TODO: 当卡牌超过7张时，调整UI设计
  width: 50 + Math.max(4, cards.length) * 100
  height: 400

  Component {
    id: cardDelegate
    GeneralCardItem {
      name: modelData
      autoBack: false
      selectable: true

      onRightClicked: {
        roomScene.startCheat("GeneralDetail", { generals: [modelData] });
      }
    }
  }

  Row {
    id: generalArea
    x: 20
    y: 35
    spacing: 5
    Repeater {
      id: to_select
      model: cards
      delegate: cardDelegate
    }
  }

  Flickable {
    id: flickableContainer
    ScrollBar.horizontal: ScrollBar {}

    flickableDirection: Flickable.VerticalFlick
    anchors.fill: parent
    anchors.topMargin: 175
    anchors.leftMargin: 5
    anchors.rightMargin: 5
    anchors.bottomMargin: 90

    contentWidth: skillColumn.width
    contentHeight: skillColumn.height
    clip: true

    RowLayout {
      id: skillColumn
      x: 22
      y: 0
      spacing: 18

      Repeater {
        id: skillList
        model: skills

        ColumnLayout {
          id: skillRow
          x: 0
          y: 0
          spacing: 5
          Layout.alignment: Qt.AlignTop

          Repeater {
            model: modelData
            id: skill_buttons

            ColumnLayout {
              spacing: 4
            
              SkillButton {
                id: skillBtn
                skill: Lua.tr(modelData)
                type: "active"
                enabled: true
                orig: modelData

                onPressedChanged: {
                  if (pressed) {
                    root.selected.push(this);

                    root.selected.length > max && (root.selected[0].pressed = false);
                  } else {
                    root.selected.splice(root.selected.findIndex(item => item.orig === orig), 1);
                  }

                  root.updateSelectable();
                }
              }
            
              Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignHCenter
                radius: 4
                color: detailMA.pressed ? "#A0A0A0" : "#D0D0D0"
                border.color: "#808080"
                border.width: 1
              
                Text {
                  anchors.centerIn: parent
                  text: "查看技能"
                  font.pixelSize: 12
                  color: "#000000"
                }
              
                MouseArea {
                  id: detailMA
                  anchors.fill: parent
                  hoverEnabled: true
                
                  onClicked: {
                    skillDetailPopup.skillName = modelData;
                    skillDetailPopup.open();
                  }
                }
              }
            }
          }
        }

      }
    }
  }

  Row {
    id: buttons
    anchors.margins: 16
    anchors.top: flickableContainer.bottom
    anchors.topMargin: 20
    anchors.horizontalCenter: root.horizontalCenter
    spacing: 32

    MetroButton {
      width: 100
      Layout.fillWidth: true
      text: Lua.tr("OK")
      id: buttonConfirm
      enabled: root.selected.length >= min

      onClicked: {
        close();
        roomScene.state = "notactive";
        ClientInstance.replyToServer("", JSON.stringify(root.selected.map(item => item.orig)));
      }
    }

    MetroButton {
      width: 100
      Layout.fillWidth: true
      text: Lua.tr("Cancel")
      visible: cancelable

      onClicked: {
        root.close();
        roomScene.state = "notactive";
        ClientInstance.replyToServer("", JSON.stringify([]));
      }
    }
  }

  function updateSelectable() {
    buttonConfirm.enabled = (selected.length <= max && selected.length >= min);
  }

  function loadData(data) {
    [cards, skills, min, max, prompt, cancelable] = data
    updateSelectable()
  }

  // 添加全局技能详情弹窗
  Popup {
    id: skillDetailPopup
    property string skillName: ""
    
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(contentWidth, root.width * 0.8)
    height: Math.min(contentHeight + 24, root.height * 0.8)
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 12
    modal: true
    
    background: Rectangle {
      color: "#EEEEEEEE"
      radius: 5
      border.color: "#A6967A"
      border.width: 1
    }
    
    contentItem: Text {
      text: skillDetailPopup.skillName ? "<b>" + Lua.tr(skillDetailPopup.skillName) + "</b>: " + Lua.tr(":" + skillDetailPopup.skillName) : ""
      font.pixelSize: 20
      wrapMode: Text.WordWrap
      textFormat: TextEdit.RichText
    }
  }
}

