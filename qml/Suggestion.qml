import QtQuick 2.5
import BayToCore 1.0
import "func.js" as Func

//搜索建议弹出框
Rectangle{
    color: "white"
    visible: false
    opacity: 0.8
    width: root.width*0.26
    height: 200

    property Playlist playlist
    property BaiduMusic baiduMusic

    //建议歌曲数据模型
    ListModel {
        id: suggestionModel
    }
    Component  {
        id: suggestionDelegate
        Item {
            id: wrapper
            width:root.width*0.2
            height: 20
            Rectangle{
                Text {
                    text: sname + '-' + singer
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    wrapper.ListView.view.currentIndex = index;
                    hide();
                    var song = suggestionModel.get(index);
                    playlist.addSong(Func.objClone(song));
                    var last = playlist.count() - 1;
                    playlist.setIndex(last);
                }
            }
        }
    }
    //建议歌曲列表视图
    ListView {
        id:suggestionView
        height: parent.height
        width: parent.width
        model: suggestionModel
        delegate: suggestionDelegate
        clip: true
    }
    /*以下为调用外部类槽函数的连接*/
    Connections{
        target:baiduMusic
        onGetSuggestionComplete: {
            try{
                var sug = JSON.parse(suggestion);
                var data = sug.data
                var songs = data.song
                setDisplaySongs(songs);
                show();
            }catch(e){
                console.log("Suggestion[onGetSuggestionComplete]:"+e);
            }
        }
    }
    /*以下为私有方法*/
    //显示搜索建议
    function show(){
        visible = true;
    }

    //隐藏搜索建议
    function hide(){
        visible = false;
    }

    //设置显示的歌曲
    function setDisplaySongs(songs){
        suggestionModel.clear();
        for(var i in songs){
            //转换为字符串
            songs[i].sid = "" + songs[i].sid;
            suggestionModel.append(songs[i]);
        }
    }


}


