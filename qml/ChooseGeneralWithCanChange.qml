// SPDX-License-Identifier: GPL-3.0-or-later
// 不支持自由选将

import QtQuick
import QtQuick.Layouts
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common

GraphicsBox {
  property string prompt: ""
  property alias generalList: generalList
  property var generals: []
  property var change: []
  property var skills: []
  property int choiceNum: 1
  property bool convertDisabled: false
  property string rule_type: ""
  property var extra_data
  property bool hegemony: false
  property var choices: []
  property var selectedItem: []
  property bool loaded: false
  property bool changeGeneralBtnVisible: true

  ListModel {
    id: generalList
  }

  id: root
  title.text: {
    if (prompt !== "") return Lua.tr(prompt);
    const suffix = Lua.evaluate('ClientInstance:getSettings("enableFreeAssign")') ? `(${Lua.tr("Enable free assign")})` : "";
    const selfseat = roomScene.getPhoto(Self.id) && roomScene.getPhoto(Self.id).seatNumber ? 
    ("你的座次是 %1 ，").arg(Lua.tr("seat#" + roomScene.getPhoto(Self.id).seatNumber)) : "";
    const ret = selfseat + Lua.tr("$ChooseGeneral").arg(choiceNum) + suffix;
    return ret;
  }
  width: generalArea.width + body.anchors.leftMargin + body.anchors.rightMargin
  height: body.implicitHeight + body.anchors.topMargin + body.anchors.bottomMargin

  Column {
    id: body
    anchors.fill: parent
    anchors.margins: 40
    anchors.bottomMargin: 20

    Item {
      id: generalArea
      width: (generalList.count > 8 ? Math.ceil(generalList.count / 2)
                                    : Math.max(3, generalList.count)) * 103 //框的高度
      height: generalList.count > 8 ? 310 : 180  //框的高度
      z: 1

      Repeater {
        id: generalMagnetList
        model: generalList.count

        Item {
          width: 93
          height: 130
          x: {
            const count = generalList.count;
            let columns = generalList.count;
            if (columns > 8) {
              columns = Math.ceil(columns / 2);
            }

            let ret = (index % columns) * 103;  //武将牌的水平间距，原本为98
            if (count > 8 && index > count / 2 && count % 2 == 1)
              ret += 50;
            return ret;
          }
          y: {
            if (generalList.count <= 8)
              return 0;
            return index < generalList.count / 2 ? 0 : 160;  //武将牌的垂直间距，原本为135
          }
        }
      }
    }

    Item {
      id: splitLine
      width: parent.width - 80
      height: 6
      anchors.horizontalCenter: parent.horizontalCenter
      clip: true
    }

    Item {
      width: parent.width
      height: 165
      
      // 按钮容器 - 靠近左侧边界
      Item {
        id: buttonContainer
        width: 50
        height: resultArea.height
        anchors.left: parent.left
        anchors.verticalCenter: resultArea.verticalCenter
        anchors.leftMargin: 10 // 与左侧边界的间距
        
        // 隐藏换将按钮，与显示互斥
        Rectangle {
          id: hideChangeBtn
          width: 100
          height: 50
          visible: root.change && root.change.length > 0 && root.changeGeneralBtnVisible
          enabled: root.change && root.change.length > 0 && root.changeGeneralBtnVisible
          anchors.centerIn: parent
          radius: 4
          border.width: 1
          border.color: enabled ? (hideChangeBtnMouseArea.containsMouse ? "#ff4444" : "#cc3333") : "#555555"
          color: enabled ? (hideChangeBtnMouseArea.containsMouse ? "#cc3333" : "#aa2222") : "#2D2D2D"
          Text {
            anchors.centerIn: parent
            text: "隐藏换将"
            font.family: Config.li2Name
            font.pixelSize: 14
            font.bold: true
            color: enabled ? "#FFFFFF" : "#888888"
          }
          MouseArea {
            id: hideChangeBtnMouseArea
            anchors.fill: parent
            enabled: hideChangeBtn.enabled
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: hideChangeBtn.enabled
            onClicked: {
              root.changeGeneralBtnVisible = false;
            }
          }
        }
        // 显示换将按钮
        Rectangle {
          id: showChangeBtn
          width: 100
          height: 50
          visible: root.change && root.change.length > 0 && !root.changeGeneralBtnVisible
          enabled: root.change && root.change.length > 0 && !root.changeGeneralBtnVisible
          anchors.centerIn: parent
          radius: 4
          border.width: 1
          border.color: enabled ? (showChangeBtnMouseArea.containsMouse ? "#44ff44" : "#33cc33") : "#555555"
          color: enabled ? (showChangeBtnMouseArea.containsMouse ? "#33cc33" : "#22aa22") : "#2D2D2D"
          Text {
            anchors.centerIn: parent
            text: "显示换将"
            font.family: Config.li2Name
            font.pixelSize: 14
            font.bold: true
            color: enabled ? "#FFFFFF" : "#888888"
          }
          MouseArea {
            id: showChangeBtnMouseArea
            anchors.fill: parent
            enabled: showChangeBtn.enabled
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: showChangeBtn.enabled
            onClicked: {
              root.changeGeneralBtnVisible = true;
            }
          }
        }
      }

      // 结果框区域 - 保持居中
      Row {
        id: resultArea
        anchors.centerIn: parent
        spacing: 20  //结果框的间距

        Repeater {
          id: resultList
          model: choiceNum

          Rectangle {
            color: "#1D1E19"
            radius: 3
            width: 93
            height: 130
          }
        }
      }
    }

    Item {
      id: buttonArea
      width: parent.width
      height: 55  //调低按钮位置，原本为40
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        spacing: 10 //按钮之间的间距

        Rectangle {
          id: convertBtn
          visible: Lua.evaluate('ClientInstance:getSettings("NoSameGeneral")') ? false : !convertDisabled
          width: 120
          height: 35

          radius: 6
          border.width: 2
          border.color: enabled ? (convertBtnMouseArea.containsMouse ? "#FF9800" : "#E68900") : "#555555"
          color: enabled ? (convertBtnMouseArea.containsMouse ? "#FF9800" : "#E68900") : "#2D2D2D"

          Text {
            anchors.centerIn: parent
            text: Lua.tr("Same General Convert")
            font.family: Config.li2Name
            font.pixelSize: 15
            font.bold: true
            color: "#FFFFFF"
          }

          MouseArea {
            id: convertBtnMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
              roomScene.startCheat("SameConvert", { cards: generalList, choices: choices });
            }
          }
        }

        Rectangle {
          id: fightButton
          width: 120
          height: 35
          enabled: false
          
          radius: 6
          border.width: 2
          border.color: enabled ? (fightButtonMouseArea.containsMouse ? "#4CAF50" : "#45a049") : "#555555"
          color: enabled ? (fightButtonMouseArea.containsMouse ? "#4CAF50" : "#45a049") : "#2D2D2D"

          Text {
            anchors.centerIn: parent
            text: Lua.tr("OK")
            font.family: Config.li2Name
            font.pixelSize: 16
            font.bold: true
            color: enabled ? "#FFFFFF" : "#888888"
          }

          MouseArea {
            id: fightButtonMouseArea
            anchors.fill: parent
            enabled: fightButton.enabled
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: fightButton.enabled
            onClicked: {
              ClientInstance.notifyServer("PushRequest", "updatemini,select," + root.choices);
              ClientInstance.replyToServer("", root.choices);
              close();
              roomScene.state = "notactive";
            }
          }
        }

        Rectangle {
          id: detailBtn
          width: 120
          height: 35
          enabled: choices.length > 0

          radius: 6
          border.width: 2
          border.color: choices.length > 0 ? (detailBtnMouseArea.containsMouse ? "#2196F3" : "#1976D2") : "#555555"
          color: choices.length > 0 ? (detailBtnMouseArea.containsMouse ? "#2196F3" : "#1976D2") : "#2D2D2D"

          Text {
            anchors.centerIn: parent
            text: Lua.tr("Show General Detail")
            font.family: Config.li2Name
            font.pixelSize: 15
            font.bold: true
            color: choices.length > 0 ? "#FFFFFF" : "#888888"
          }

          MouseArea {
            id: detailBtnMouseArea
            anchors.fill: parent
            enabled: detailBtn.enabled
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: detailBtn.enabled
            onClicked: {
              roomScene.startCheat("GeneralDetail", { generals: choices });
            }
          }
        }

        MetroButton {
          id: skdetailBtn
          width: 80
          height: 40
          text: Lua.tr("@hx__1v2_skill")
          visible: Lua.evaluate('ClientInstance:getSettings("LuandouMode")') ? Lua.evaluate('ClientInstance:getSettings("LuandouMode")') >= 3 : false
          onClicked: {
            let _skills = [];
            if (root.skills.length > 0) {
                _skills = root.skills;
            }
            roomScene.startCheatByPath("packages/utility/qml/SkillDetail", {  skills: _skills  });
          }
        }
      }
    }
  }

  Repeater {
    id: generalCardList
    model: generalList

    GeneralCardItem {
      name: model.name
      selectable: true
      draggable: true

      onClicked: {
        if (!selectable) return;
        let toSelect = true;
        for (let i = 0; i < selectedItem.length; i++) {
          if (selectedItem[i] === this) {
            toSelect = false;
            selectedItem.splice(i, 1);
            break;
          }
        }
        if (toSelect && selectedItem.length < choiceNum)
          selectedItem.push(this);
        updatePosition();
      }

      onRightClicked: {
        // if (selectedItem.indexOf(this) === -1 && (Lua.evaluate('ClientInstance:getSettings("enableFreeAssign")')))
        //   roomScene.startCheat("FreeAssign", { card: this });
        // else
          roomScene.startCheat("GeneralDetail", { generals: [modelData] });
      }

      onReleased: {
        arrangeCards();
      }

      //换将按钮
      Rectangle {
        id: changeGeneralBtn
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.center
        width: 93
        height: 24
        visible: root.changeGeneralBtnVisible && root.change && root.change.length > 0 && !choices.includes(modelData)
        enabled: root.change && root.change.length > 0  //change里没有武将，按钮不可点击

        radius: 4 //圆角
        border.width: 1 // 边框宽度
        // 悬停时边框颜色变亮
        border.color: enabled ? (changeGeneralBtnMouseArea.containsMouse ? "#ffd700" : "#fff28e") : "#d84e4e"
        color: enabled ? (changeGeneralBtnMouseArea.containsMouse ? "#3D3D3D" : "#2D2D2D") : "#1A1A1A"

        Text {
          id: changeGeneralBtnText
          anchors.centerIn: parent
          text: Lua.tr("Change General").arg(root.change.length)
          font.family: Config.li2Name
          font.pixelSize: 15
          font.bold: true
          color: enabled ? (changeGeneralBtnMouseArea.containsMouse ? "#FFFFFF" : "#F5E6D3") : "#666666"
        }

        MouseArea {
          id: changeGeneralBtnMouseArea
          anchors.fill: parent
          enabled: changeGeneralBtn.enabled
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: changeGeneralBtn.enabled
          onClicked: { 
            //判空
            if (root.change && root.change.length > 0) {
              //从change中取出第一个武将作为替换的武将
              let newGeneral = root.change.shift();
              //更新所有按钮！
              root.change = root.change.filter(card => card !== newGeneral);
              if (root.generals && model.name) { 
                //查找被换武将在 root.generals 中的索引
                let index = root.generals.findIndex(card => card === model.name); 
                if (index !== -1) {
                  //替换对应武将
                  if (root.generalList.get(index)) {
                    root.generals[index] = newGeneral;
                    root.generalList.set(index, { "name": newGeneral });
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  function arrangeCards()
  {
    let item, i;

    selectedItem = [];
    for (i = 0; i < generalList.count; i++) {
      item = generalCardList.itemAt(i);
      if (item.y > splitLine.y && item.selectable)
        selectedItem.push(item);
    }

    selectedItem.sort((a, b) => a.x - b.x);

    if (selectedItem.length > choiceNum)
      selectedItem.splice(choiceNum, selectedItem.length - choiceNum);

    updatePosition();
  }

  function updateCompanion(gcard1, gcard2, overwrite) {
    if (Lua.call("IsCompanionWith", gcard1.name, gcard2.name)) {
      gcard1.hasCompanions = true;
    } else if (overwrite) {
      gcard1.hasCompanions = false;
    }
  }

  function updatePosition()
  {
    choices = [];
    let item, magnet, pos, i;
    for (i = 0; i < selectedItem.length && i < resultList.count; i++) {
      item = selectedItem[i];
      choices.push(item.name);
      magnet = resultList.itemAt(i);
      pos = root.mapFromItem(resultArea, magnet.x, magnet.y);
      if (item.origX !== pos.x || item.origY !== item.y) {
        item.origX = pos.x;
        item.origY = pos.y;
        item.goBack(true);
      }
    }
    root.choicesChanged();

    fightButton.enabled = Lua.call("ChooseGeneralFeasible", root.rule_type, root.choices,
                                root.generals, root.extra_data);

    for (i = 0; i < generalCardList.count; i++) {
      item = generalCardList.itemAt(i);
      item.selectable = choices.includes(item.name) ||
              Lua.call("ChooseGeneralFilter", root.rule_type, item.name, root.choices,
                    root.generals, root.extra_data);
      if (hegemony) { // 珠联璧合相关
        item.inPosition = 0;
        if (selectedItem[0]) {
          if (selectedItem[1]) {
            if (selectedItem[0] === item) {
              updateCompanion(item, selectedItem[1], true);
            } else if (selectedItem[1] === item) {
              updateCompanion(item, selectedItem[0], true);
            } else {
              item.hasCompanions = false;
            }
          } else {
            if (selectedItem[0] !== item) {
              updateCompanion(item, selectedItem[0], true);
            } else {
              for (let j = 0; j < generalList.count; j++) {
                updateCompanion(item, generalList.get(j), false);
              }
            }
          }
        } else {
          for (let j = 0; j < generalList.count; j++) {
            updateCompanion(item, generalList.get(j), false);
          }
        }
      }
      if (selectedItem.indexOf(item) != -1)
        continue;

      magnet = generalMagnetList.itemAt(i);
      pos = root.mapFromItem(generalMagnetList.parent, magnet.x, magnet.y);
      if (item.origX !== pos.x || item.origY !== item.y) {
        item.origX = pos.x;
        item.origY = pos.y;
        item.goBack(true);
      }
    }

    if (hegemony) { // 主副将调整阴阳鱼
      if (selectedItem[0]) {
        if (selectedItem[0].mainMaxHp < 0) {
          selectedItem[0].inPosition = 1;
        } else if (selectedItem[0].deputyMaxHp < 0) {
          selectedItem[0].inPosition = -1;
        }
        if (selectedItem[1]) {
          if (selectedItem[1].mainMaxHp < 0) {
            selectedItem[1].inPosition = -1;
          } else if (selectedItem[1].deputyMaxHp < 0) {
            selectedItem[1].inPosition = 1;
          }
        }
      }
    }

    for (let i = 0; i < generalList.count; i++) {
      if (Lua.call("GetSameGenerals", generalList.get(i).name).length > 0) {
        convertBtn.enabled = true;
        return;
      }
    }
    convertBtn.enabled = false;
  }
  
    function loadData(data) {
    root.change = data.change ?? [];
    root.prompt = data.prompt ?? "";
    // let generals = data[1];
    // let n = data[2];
    // let no_convert = data[3];
    // let heg = data[4];
    // let rule = data[5];
    // let extra_data = data[6];
    root.skills = data.skills ?? [];
    root.generals = data.cards ?? [];
    root.choiceNum = data.num ?? 1;
    root.convertDisabled = !!data.no_c ?? false;
    root.hegemony = !!data.heg ?? false;
    root.rule_type = data.type ?? "askForGeneralsChosen"; // 若heg为true，默认应用国战选将
    root.extra_data = data.extra;
    for (let i = 0; i < data.cards.length; i++){
      root.generalList.append({ "name": data.cards[i] });
    }
    root.updatePosition();
    // root.refreshPrompt();
  }

  function updateData(data) {
    let [type, value] = data;
    value = value ?? "";
    if (type == "select") {
    }
  }

  function refreshPrompt() {
    prompt = Util.processPrompt(Lua.call("ChooseGeneralPrompt", rule_type, generals, extra_data))
  }
}