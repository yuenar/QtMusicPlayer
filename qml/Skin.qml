import QtQuick 2.5
import QtQml 2.2
import QtQuick.Dialogs 1.2
import BayToCore 1.0

Item {
    width: parent.width
    height:parent.height
    visible: true
    property ReadWrite readWrite
    property int skid: 2
    property string skpath


    Image {
        id: img
        width: parent.width
        height:parent.height
        source: "qrc:/image/image/skin.png"
    }
    FileDialog
    {
        id:imgDialog
        title: qsTr("选择一张图片作为皮肤")
        folder: shortcuts.home
        nameFilters: [ "JPG格式图片 (*.jpg)", "PNG格式图片 (*.png)", "BMP格式图片 (*.bmp)" ]
        onAccepted: {
            var tempath=imgDialog.fileUrl;
            img.source=tempath;
            skpath=tempath;
            console.log("选择的图片路径为"+skpath);
        }
        onRejected: {
            console.log("Canceled!")
        }
    }
    function changeSkin()
    {
        if(skid<5)
        {

            var skin="qrc:/image/image/skin%1.png";
            img.source=skin.arg(skid);
            skid+=1;
        }else
        {
            img.source= "qrc:/image/image/skin.png";
            skid=2;
        }
    }
    function chooseSkin()
    {
        imgDialog.open();
    }
    //析构完成
    Component.onDestruction: {
        //保存播放列表
        readWrite.saveSkin(skpath);
        console.log("自定义皮肤已保存!")
    }

    //构造完成
    Component.onCompleted: {
        skpath=readWrite.loadSkin();
        if(skpath!="error")
        {
        img.source=skpath;
        console.log("自定义皮肤已应用!")
        }else
        img.source="qrc:/image/image/skin.png";
    }
}
