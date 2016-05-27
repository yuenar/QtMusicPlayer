import QtQuick 2.5
import QtMultimedia 5.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import BayToCore 1.0

ApplicationWindow{
    /*主界面*/
    id:root
    width:960
    height:600
    minimumHeight: 300
    minimumWidth: 480
    visible: true
    property string skinColor: "#678"
    property real skinOpac: 0.5


    //设置无边框
    flags: Qt.FramelessWindowHint | Qt.WindowSystemMenuHint| Qt.WindowMinimizeButtonHint| Qt.Window
    opacity: 0.9
    style: ApplicationWindowStyle {
        background:skin
    }
    MediaPlayer {//实例化播放器
        id: mediaplayer
    }
    ReadWrite {  //实例化工具函数
        id:readWrite
    }
    BaiduMusic {//百度音乐Api
        id: baiduMusic
    }
    Playlist {//播放列表
        id:playlist
        mediaPlayer: mediaplayer
        baiduMusic: baiduMusic
        readWrite:readWrite
    }

    /*以下为界面相关布局实例化*/
    Skin{//背景皮肤
        id:skin
        readWrite:readWrite

    }  
    TopBar{//顶栏
        id:topBar
        color: skinColor
        opacity: skinOpac
        anchors.left: parent.left
        anchors.right: parent.right
        baiduMusic: baiduMusic
        suggestion: suggestion
        skin:skin
    }

    BottomBar {//底部栏
        id:bottomBar
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: parent.width
        color: "#345678"
        opacity: skinOpac
        mediaPlayer: mediaplayer
        playlist: playlist
        baiduMusic: baiduMusic

        onLyricHiddenChanged: {
            lyricView.visible = !lyricHidden;
        }
    }
    SideBar {//侧边栏
        id:sideBar
        color: skinColor
        opacity: skinOpac
        anchors.left: parent.left
        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        playlist: playlist
        mediaPlayer: mediaplayer
        container: container
        onRmindexChanged: {
            if(rmindex>1)
            {
            localSong.rmSong(rmindex);
            }
        }
    }
    //搜索建议框
    Suggestion{
        id:suggestion
        anchors.left:sideBar.right
        anchors.leftMargin: 28
        anchors.top: topBar.bottom
        anchors.topMargin: -15
        z:100
        baiduMusic: baiduMusic
        playlist: playlist
    }
    //歌词
    Lyric{
        id:lyricView
        color: skinColor
        baiduMusic:baiduMusic
        playlist:playlist
        readWrite:readWrite
        mediaPlayer:mediaplayer

        z:200
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: sideBar.top
        anchors.bottom: bottomBar.top
        visible: false
    }//弹窗歌词
    DeskLrc
    {
        id:dLrc
        x:100
        y:600
        width: 900
        height: 100
        visible: false
        color: "transparent"
        baiduMusic:baiduMusic
        playlist:playlist
        readWrite:readWrite
        mediaPlayer:mediaplayer

    }
    //内容区域
    Container{
        id:container
        lyric:lyricView
        anchors.left:sideBar.right
        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        anchors.right: parent.right
        baiduMusic: baiduMusic
        playlist: playlist
    }
    /*以下为事件响应*/
    MouseArea{
        //鼠标事件
        property variant previousPosition
        anchors.fill: parent
        z:-1
        onClicked: {
            suggestion.hide();
        }
        onPressed: {
            previousPosition = Qt.point(mouseX, mouseY)
        }//重写主界面鼠标拖动事件
        onPositionChanged: {
            var dx = mouseX - previousPosition.x;
            var dy = mouseY - previousPosition.y;
            if(pressedButtons == Qt.LeftButton)
            {
                root.x+= dx
                root.y+= dy
            }
        }
    }
    //析构完成
    Component.onDestruction: {
        //保存播放列表
        playlist.saveTo("resentlist");
    }

    //构造完成
    Component.onCompleted: {
        //加载播放列表
        playlist.loadFrom("resentlist");
        sideBar.update();
        //列表中第一首为默认播放歌曲
        if(playlist.count()>0){
            playlist.index = 0;
        }
    }
}


