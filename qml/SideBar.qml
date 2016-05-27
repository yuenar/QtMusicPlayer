import QtQuick 2.5
import QtMultimedia 5.5
import QtQuick.Dialogs 1.2
import QtQml 2.2
import BayToCore 1.0

//左侧边栏
Rectangle {
    id: leftList
    width: root.width*0.2
    property Playlist playlist
    property Container container
    property MediaPlayer mediaPlayer
    property bool selectLocal
    property int rmindex
    property int sindex:playlist.sindex

    Component {
        //上部为点播列表
        id:topListViewDelegate
        Item {
            width: root.width*0.2
            height: 20
            Rectangle{
                anchors.fill: parent
                color:"#778899"
                Text {
                    anchors.centerIn: parent
                    text:listname
                }
                MouseArea{
                    id:mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:{
                        selectLocal=false;
                        console.log("已选中最近点播");
                        container.updatePlaylist("最近点播");
                        container.showPlaylist();
                    }
                }
            }
        }
    }
    Component {
        //下部为本地音乐列表
        id:downListViewDelegate
        Item {
            width: root.width*0.2
            height: 20
            Rectangle{
                anchors.fill: parent
                color:"#778899"
                Text {
                    anchors.centerIn: parent
                    text:song
                }
                MouseArea{
                    id:mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked:{//左键选中则播放
                        downListView.currentIndex=index;
                        console.log("当前选中歌曲序号"+downListView.currentIndex);
                        selectLocal=true;
                        console.log("已选中本地列表");
                        if(mouse.button == Qt.LeftButton)
                        {
                            mediaPlayer.source=localSong.getSong(index+1);
                            playlist.cindex=index+1;//更新底部栏Tag
                            playlist.updated=!playlist.updated;
                            mediaPlayer.play();
                        }
                        else
                        {
                            rmindex=index;
                            console.log("选中歌曲ID号："+index);
                            console.log("待删除歌曲ID号："+rmindex);
                            if(index>0)
                            {//很多歌曲时删除则播放上一曲
                                mediaPlayer.source=localSong.getSong(index);
                                playlist.cindex=index;//更新底部栏Tag
                                playlist.updated=!playlist.updated;
                                mediaPlayer.play();
                                downListModel.remove(rmindex,1);
                                console.log("删除当前歌曲...");
                                downListView.currentIndex=index;
                                downListModel.remove(sindex,1);
                            }
                            else if(sindex<=1)
                            {//列表只剩一首歌时清空
                                downListModel.clear();
                                playlist.pause();
                                localSong.reset();
                            }
                            else if(index==0)
                            {//删除第一首歌曲手动跳到最后
                                mediaPlayer.source=localSong.getSong(sindex);
                                playlist.cindex=sindex;//更新底部栏Tag
                                playlist.updated=!playlist.updated;
                                mediaPlayer.play();
                                downListModel.remove(0,1);
                                localSong.rmSong(0);//删除第一首
                                downListView.currentIndex=sindex-1;
                            }
                        }
                    }
                }
            }
        }
    }
    //与播放列表的数据绑定
    Binding
    {
        target: playlist
        property: "selcp"
        value: selectLocal
    }
    ListModel {
        id:topListModel
    }
    ListModel {
        id:downListModel
    }
    ListView {
        id:topListView
        anchors.top: parent.top
        anchors.left: parent.left
        width:parent.width
        height: parent.height*0.1
        delegate: topListViewDelegate
        model: topListModel
        clip: true
        focus: true

        highlight:Component{
            Rectangle{
                radius:3
                gradient: Gradient {
                    GradientStop {
                        position: 0.00;
                        color: "#80a9ccf3";
                    }
                    GradientStop {
                        position: 1.00;
                        color: "#808abae6";
                    }
                }

            }
        }
        header: Component {
            Item {
                width: root.width*0.2
                height: 30
                Rectangle{
                    anchors.fill: parent
                    color:"#678999"
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize:16
                        text:"播放列表"
                    }
                }
            }
        }
    }
    ListView {
        id:downListView
        anchors.top: topListView.bottom
        anchors.left: parent.left
        width:parent.width
        height: parent.height*0.9
        delegate: downListViewDelegate
        model: downListModel
        clip: true
        focus: true

        highlight:Component{
            Rectangle{
                radius:3
                gradient: Gradient {
                    GradientStop {
                        position: 0.00;
                        color: "#80a9ccf3";
                    }
                    GradientStop {
                        position: 1.00;
                        color: "#808abae6";
                    }
                }

            }
        }
        header: Component {
            Item {
                width: root.width*0.2
                height: 30
                Rectangle{
                    anchors.fill: parent
                    color:"#678999"
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize:16
                        text:"本地音乐"
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked:
                        {
                            if(mouse.button == Qt.LeftButton)
                            {
                                if(downListModel.count==0)
                                {
                                    localSong.readList("locallist");
                                }
                                else localSong.openFile();
                            }
                            else
                                localSong.addDir();
                        }
                        onDoubleClicked: localSong.openFile();
                    }
                }
            }
        }
    }
    /*以下为调用外部类槽函数的连接*/
    Connections
    {
        target:localSong
        onSetSongPath:
        {//首次添加插入列表
            try
            {
                sindex=listLength;//列表长度的信号先接收
            }
            catch(e){
                console.log("列表更新状况:"+e);
            }
        }
        onSetSongInfo:
        {
            try
            {//歌曲信息信号后接收
                downListModel.append({"song":sindex+":"+singer+"-"+sname});
            }
            catch(e){
                console.log("歌曲更新状况:"+e);
            }
        }
    }
    /*以下为私有方法*/
    //更新列表
    function update(){
        for(var i in playlist.playlists){
            topListModel.append({"listname":i});
        }
        container.updatePlaylist("最近点播");
        container.showPlaylist();
    }
}
