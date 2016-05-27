import QtQuick 2.5
import QtQuick.Controls 1.4

//歌曲列表视图
Rectangle {
    width:root.width*0.8
    height:500
    property Playlist playlist

    property string lsinger: ""
    property string lsname: ""

    TableView {
        //表格视图
        width: parent.width
        anchors.fill: parent
        onDoubleClicked: {
            playlist.setIndex(row);
        }
        rowDelegate: Rectangle {
            height: 25
            color: styleData.selected ? "#789" : (styleData.alternate? "#eee" : "#fff")
        }
        TableViewColumn {
            role:"listIndex"
            title:"  "
            width: 50
        }

        TableViewColumn {
            role: "sname"
            title: "歌曲名称"
            width: 200
        }
        TableViewColumn {
            role: "singer"
            title: "歌手"
            width: 100
        }
        model: listModel
    }
    //歌单列表数据模型
    ListModel {
        id: listModel
    }
    /*以下为私有方法*/
    //更新列表
    function update(listname){
        listModel.clear();
        var list = playlist.getSongList(listname);
        for(var i=0;i<list.length;i++){
            list[i].listIndex = i + 1;
            listModel.append(list[i])
            };
        }
}
