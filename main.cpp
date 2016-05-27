#include<QApplication>
#include<QQmlApplicationEngine>
#include<QQmlContext>
#include<QQmlComponent>
#include<QIcon>
#include<QUrl>
#include "c++/BaiduMusic.h"
#include "c++/ReadWrite.h"
#include "c++/LocalSong.h"
#pragma execution_character_set("utf-8")

int main(int argc,char* argv[])
{
    QApplication app(argc,argv);
    QQmlApplicationEngine  engine;
    qmlRegisterType<BaiduMusic>("BayToCore",1,0,"BaiduMusic");
    qmlRegisterType<ReadWrite>("BayToCore",1,0,"ReadWrite");//注册到QML

    engine.load(QUrl(QStringLiteral("qrc:/qml/qml/Main.qml")));
    LocalSong lSong;//先实例化
    engine.rootContext()->setContextProperty("localSong",&lSong);//放到QML
    app.setWindowIcon((QIcon(":/image/logo")));//设置任务栏图标

    return app.exec();
}
