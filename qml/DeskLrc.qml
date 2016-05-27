import QtQuick 2.5
import QtMultimedia 5.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import BayToCore 1.0

Window {
    id:deskLrc
    objectName: "DLC"
    flags: Qt.Popup|Qt.WindowStaysOnTopHint

    property Playlist playlist
    property BaiduMusic baiduMusic
    property MediaPlayer mediaPlayer
    property ReadWrite readWrite
    property int fontSize: 30
    property int lineSpace: 45
    property string dsklyricTxt:"桌面歌词"
    property string foucsColor:"blue"
    property string lostColor:"lightblue"
    property bool locked: false
    property bool boomed: false
    property bool played

    Rectangle {//自定义歌词锁定图标
        id:lockbtn
        anchors.top:parent.top
        anchors.left: lyricView.right
        width: 22
        height: 22
        color: "transparent"
        radius: 4
        border.color: "white"
        border.width: 2
        Text {
            text:  locked?"开":"锁"
            color: "white"
            font.family: "幼圆"
            font.bold: true
            font.pixelSize: 16
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.color= "lightblue"
            onExited: parent.color="transparent"
            onClicked: {
            locked=!locked;
            }
        }
    }
    Image {
        //自定义播放暂停按钮及响应
        id: palyicon
        width:24
        height:24
        source: "qrc:/image/image/pause.png"
        anchors.top: lockbtn.bottom
        anchors.left: lyricView.right
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(!played){//如果暂停就播放
                    playlist.play();
                    palyicon.source="qrc:/image/image/pause.png";
                    played=true;
                }
                else
                {
                    playlist.pause();//如果播放就暂停
                    palyicon.source="qrc:/image/image/play.png";
                    played=false;
                }
            }
        }
    }
    Image {
        //自定义上一曲按钮及响应
        id: lasticon
        width:24
        height:24
        source: "qrc:/image/image/previous.png"
        anchors.top: palyicon.bottom
        anchors.left: lyricView.right
        MouseArea{
            anchors.fill: parent
            onClicked: {
            playlist.previous();
            }
        }
    }
    Image {
        //自定义下一曲按钮及响应
        id: nexticon
        width:24
        height:24
        source: "qrc:/image/image/next.png"
        anchors.top: lasticon.bottom
        anchors.left: lyricView.right
        MouseArea{
            anchors.fill: parent
            onClicked: {
            playlist.next();
            }
        }
    }
    //歌词数据模型
    ListModel{
        id:lyricModel
    }
    //歌词数据显示组件
    Component{
        id:lyricDelegate
        Rectangle{
            id:lyricLineRect
            height: lineSpace
            width: 875
            color:"transparent"
            Text{
                anchors.centerIn: parent
                color:lyricLineRect.ListView.isCurrentItem ? foucsColor:lostColor
                text: String(content)
                font.family: "幼圆"
                font.italic: true
                style: Text.Raised
                font.pointSize:lyricLineRect.ListView.isCurrentItem ? fontSize+2 : fontSize
            }
        }
    }
    //歌词显示列表
    ListView{
        id:lyricView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 875
        spacing:5
        model:lyricModel
        delegate: lyricDelegate
        clip: true
        onCurrentItemChanged: NumberAnimation {
            target: lyricView;
            property: "contentY";
            to:lyricView.currentItem.y-50;
            duration: 500;
            easing.type: Easing.OutSine
        }
        //鼠标操作区域
        MouseArea {
            id: dragRegion
            anchors.fill: parent
            property point clickPos: "0,0"

            onPressed: {
                clickPos  = Qt.point(mouse.x,mouse.y);
            }
            onPositionChanged: {
                //鼠标偏移量
                if(!locked)
                {
                    var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                    deskLrc.setX(deskLrc.x+delta.x);
                    deskLrc.setY(deskLrc.y+delta.y);
                }else
                    console.log("歌词已锁定!");
            }
        }

        /*以下为调用外部类槽函数的连接*/
        Connections{
            target:mediaPlayer
            onPositionChanged:{
                //给0.1s补偿
                var i=getLyricIndex(mediaPlayer.position+100);
                if(i>=0){
                    lyricView.currentIndex=i

                }
            }
        }
    }
    Connections{
        target: baiduMusic
        //歌曲播放地址获取完毕
        onGetSongLinkComplete:{
            try{
                var link = JSON.parse(songLink);
                //如果还是当前播放歌曲，则立即播放，否则不处理
                if(playlist.currentSid == link.data.songList[0].sid){
                    if(link.data.songList[0].lrcLink==''){
                        return;
                    }
                    var url = link.data.songList[0].lrcLink;
                    //获取当前点播歌曲的歌词路径
                    baiduMusic.getLyric(url);
                    console.log("getLrc:"+url)
                }
            }catch(e){
                console.log("getLink:"+e);
            }
        }
    }
    Connections{
        target: playlist
        onIndexChanged:{
            lyricModel.clear();
        }
    }
    /*以下为私有方法*/
    //解析歌词
    function parseLyric(curcontent)
    {
        var temp = curcontent;
        var lines =temp.split('\n');
        lines.forEach(function(line,index){
            var rex=/^((\[\d+:\d+\.\d+\])+)(.*)/;
            var result = line.match(rex);
            if(result){
                var content = result[3];//歌词
                var times = result[1].split(/\[|\]/);   //时间
                times.forEach(function(str){
                    var re =/^(\d+):(\d+)\.(\d+)$/;;
                    var rs = str.match(re);
                    if(rs){
                        var min = parseInt(rs[1]);
                        var sec = parseInt(rs[2]);
                        var ms = parseInt(rs[3])*10; //点后面每单位代表10ms
                        var time = min*60*1000+sec*1000+ms;
                        insertLyric(time,content);
                    }
                });

            }
        });
    }
    //顺序插入
    function insertLyric(time,content){
        var count = lyricModel.count;
        if(count==0){
            lyricModel.append({time:time,content:content});
            return;
        }else if(time<lyricModel.get(0).time){
            lyricModel.insert(0,{time:time,content:content});
            return ;
        }else if(time>lyricModel.get(count-1).time){
            lyricModel.append({time:time,content:content});
            return;
        }

        for(var i=0;i<count;++i){
            if(lyricModel.get(i).time<time && time<lyricModel.get(i+1).time){
                lyricModel.insert(i+1,{time:time,content:content});

            }
        }
    }
    //给定时间显示的歌词
    function getLyricIndex(time){
        var count = lyricModel.count;
        if(count==0){
            return -1;
        }
        if(time<lyricModel.get(0).time){
            return 0;
        }
        for(var i=0;i<count;++i){
            if(lyricModel.get(i).time<=time && time<lyricModel.get(i+1).time){
                return i;
            }
        }
        return count-1;
    }
    //清空歌词缓存
    function flush()
    {
        lyricModel.clear();
    }
}

