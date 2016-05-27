import QtQuick 2.5
import QtQuick.Controls 1.4
import Qt.labs.controls 1.0
import BayToCore 1.0
import "func.js" as Func

//搜索结果
Rectangle {
    width:800
    height:500
    property int currentPage: 1
    property int pageCount: 1
    property string keyword: ""
    property BaiduMusic baiduMusic
    property Playlist playlist


    TableView {
        //表格视图
        id: resultView
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: bottomTools.top
        onDoubleClicked: {
            var song = resultModel.get(row);
            playlist.addSong(Func.objClone(song));
            var last = playlist.count() - 1;
            playlist.setIndex(last);
        }
        rowDelegate: Rectangle {
            height: 25
            color: styleData.selected ? "#678" : (styleData.alternate? "#eee" : "#fff")
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
        model: resultModel

    }
    //歌曲搜索结果列表数据模型
    ListModel {
        id: resultModel
    }

    //底部页面指示栏
    Rectangle {
        id: bottomTools
        width: parent.width
        height: 40
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        Component {
            id:pageDelegate
            Item{
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter;
                Text {
                    anchors.centerIn: parent
                    text: linkText
                    onLinkActivated: {
                        var pagenum = parseInt(link);
                        console.log(pagenum);
                        if(pagenum){
                            baiduMusic.search(keyword,pagenum);
                        }
                    }
                }
            }
        }

        ListModel {
            id:pageModel
        }
        Button {
            //上一页按钮
            id:prevPageButton
            enabled: false
            text:"<<"
            width: 30
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if(currentPage>1){
                    baiduMusic.search(keyword,currentPage - 1);
                }
            }
        }
        ListView {
            id:pageView
            height: 30
            width: 60
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: prevPageButton.right
            anchors.leftMargin: 20

            model:pageModel
            delegate: pageDelegate
            orientation : ListView.LeftToRight
        }

        Button {
            //下一页按钮
            enabled: false
            width: 30
            anchors.left: pageView.right
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            id:nextPageButton
            text:">>"
            onClicked: {
                if(currentPage<pageCount){
                    baiduMusic.search(keyword,currentPage + 1);
                }
            }
        }
    }
    /*以下为私有方法*/
    //获取歌曲条目
    function getItems(){
        var items = [];
        for(var i=0;i<resultModel.count;i++){
            items.push(resultModel.get(i));
        }
        return items;
    }
    //显示搜索结果
    function setResultInfo(curpage,pagecount,keyword_,songList){
        resultModel.clear();
        keyword = keyword_;

    //更新页面链接,只显示3页
    function updatePageLink(cur,count){
            pageModel.clear();
            console.log("cur:"+cur+"count:"+count);

            //显示的第一页和最后一页
            var beginPage = cur<3 ? 1 : cur-1;
            var endPage = cur<count-1 ? cur+1 : count;

            //如果当前页为第一页，则最后一页为3
            if(cur==1 && count>=3){
                endPage = 3;
            }

            //如果当前页为最后一页，则起始页为pagecount - 2;
            if(cur==count && count>=3){
                beginPage = count - 2;
            }

            //调整页码宽度
            if(count<3){
                pageView.width = 20 * count;
            } else {
                pageView.width = 60;
            }
            prevPageButton.enabled = true;
            nextPageButton.enabled = true;

            if(cur == 1){
                prevPageButton.enabled = false;
            }
            if(cur == count){
                nextPageButton.enabled = false;
            }
            console.log(beginPage + "------------" + endPage);
            for(var i=beginPage;i<=endPage;i++){
                var link = "<a href=\""+i+"\">"+i+"</a>";
                if(i == cur){
                    link = "" + i;
                }
                pageModel.append({linkText:link});
            }
        }
        try{
            currentPage = curpage;
            pageCount = pagecount;
            updatePageLink(currentPage,pageCount)
            //添加歌曲列表
            for(var i in songList){
                songList[i].songItem.listIndex = parseInt(i) + 1; //序号
                songList[i].songItem.sid = "" + songList[i].songItem.sid; //sid转换为字符串
                resultModel.append(songList[i].songItem);
            }
        }catch(e){
            console.log("SearchResult[setResultInfo:]"+e);
        }
    }
}

