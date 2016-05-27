import QtQuick 2.5
import BayToCore 1.0

//顶部栏
Rectangle{
    width: parent.width
    height: 60

    property Suggestion suggestion
    property BaiduMusic baiduMusic
    property Skin skin
    property bool maxed: false

    //自定义左上角LOGO
    Rectangle {
        id: brand
        width: root.width*0.2
        height: parent.height
        anchors.top: parent.top
        anchors.left: parent.left
        color:parent.color
        Image{
            id:titLogo
            width: 78
            height: 60
            source:"qrc:/image/logo"
            anchors.top: parent.top
            anchors.left: parent.left
        }
        Text{
            id:titEg
            color:"#345678"
            text:"BayToMusic"
            font.family: "Brush Script MT"
            font.italic: true
            style: Text.Raised
            font.pixelSize: 26
            anchors.top: parent.center
            anchors.left: titLogo.right
        }
        Text{
            id:titCn
            color:"black"
            text:"北途音乐"
            font.family: "方正舒体"
            font.bold: true
            font.italic: true
            font.pixelSize: 28
            anchors.top: titEg.bottom
            anchors.left: titLogo.right
        }
    }
    Rectangle {
        //自定义设置按钮，用于更改皮肤及字体
        id: setarea
        width: 100
        height: parent.height
        anchors.top: parent.top
        x:parent.width-100
        color:"transparent"
        Image {
            id: seticon
            width:24
            height:24
            source: "qrc:/image/image/theme.png"
            anchors.top: parent.top
            anchors.left: parent.left
            states: State {
                name: "defalut"
                PropertyChanges { target: seticon; rotation: 180 }
            }
            transitions: Transition {
                RotationAnimation { duration: 1000; direction: RotationAnimation.Clockwise }
            }
            MouseArea{
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked:
                {
                    if(mouse.button == Qt.LeftButton)
                    {
                        if(seticon.state == "defalut")
                        {
                            seticon.state =""
                        }else
                            seticon.state = "defalut" ;
                        skin.changeSkin();
                    }
                    else
                    {
                        if(seticon.state == "defalut")
                        {
                            seticon.state =""
                        }else
                            seticon.state = "defalut" ;
                        skin.chooseSkin();
                    }
                }
            }
        }
        Image {
            //自定义最小化按钮及响应
            id: minicon
            width:24
            height:24
            source: "qrc:/image/image/min.png"
            anchors.top: parent.top
            anchors.left: seticon.right
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.showMinimized();
                }
            }
        }
        Image {
            //自定义最大化按钮及响应
            id: maxicon
            width:24
            height:24
            source: "qrc:/image/image/max.png"
            anchors.top: parent.top
            anchors.left: minicon.right
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    if(!maxed){
                        root.showFullScreen();//铺满全屏
                        maxicon.source="qrc:/image/image/mdw.png";
                        maxed=true;
                    }
                    else
                    {
                        root.showNormal();//还原
                        maxicon.source="qrc:/image/image/max.png";
                        maxed=false;
                    }
                }
            }
        }
        Image {
            //自定义关闭按钮及响应
            id: clcon
            width:24
            height:24
            source: "qrc:/image/image/close.png"
            anchors.top: parent.top
            anchors.left: maxicon.right
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    Qt.quit();
                }
            }
        }
    }
    //搜索框输入栏
    Rectangle {
        id:serchinput
        width: root.width*0.28
        height: 28
        radius: 14
        opacity:0.9
        color: "lightblue"
        anchors.left: brand.right
        anchors.leftMargin: 15
        anchors.verticalCenter: parent.verticalCenter
        //输入框
        TextInput {
            id:input
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: searchButton.left
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize:15
            clip: true
            text:"请输入歌曲、歌手名进行搜索"
            font.bold: true
            focus: true

            //输入改变
            onTextChanged:{
                if(text === "请输入歌曲、歌手名进行搜索"||""){
                    suggestion.hide();
                    return;
                }else if(text === "请输入歌曲、歌手名进行搜"){
                    text="";
                    return;
                }else
                    baiduMusic.getSuggestion(text)
            }
            onFocusChanged: {
                if(!focus){
                    suggestion.hide();
                }
            }
            //编辑完成回车，接收按键事件
            onAccepted :{
                search();
            }
        }

        Rectangle {
            //自定义搜索按钮
            id:searchButton
            height: 24
            width: 24
            color: "transparent"
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            Image {
                id: searchIcon
                anchors.fill: parent
                source: "qrc:/image/image/search.png"
            }
            MouseArea{
                anchors.fill: parent
                onClicked:  search()
            }
        }
    }
    //底边条以分割布局
    Rectangle {
        width: parent.width
        height: 2
        color: "#788"
        anchors.bottom: parent.bottom
    }
    /*以下为私有方法*/
    //点击搜索按钮或按回车
    function search(){
        if(input.text == ""){
            return;
        }
        baiduMusic.search(input.text,1);
        suggestion.hide();
    }
}

