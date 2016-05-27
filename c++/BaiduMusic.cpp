#include <QDebug>
#include <QUrl>
#include <QNetworkRequest>
#include <QByteArray>
#include <QStringList>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QRegularExpressionMatchIterator>
#include "c++/BaiduMusic.h"
#pragma execution_character_set("utf-8")

//歌单界面每页数目
const int PAGESIZE = 20;

/*
 * @brief 音乐搜索API
 * @param 参数%1：搜索关键字
 * @param 参数%2： 起始位置，为(page-1)*20
 */

const QString ApiOfSearch = "http://music.baidu.com/search?key=%1&start=%2&size=20&s=1";

/*
 * @brief 搜索建议API
 * @param 参数%1：歌曲id
 */

const QString ApiOfSuggestion = "http://sug.music.baidu.com/info/suggestion?format=json&word=%1&version=2&from=0";


/*
 * @brief 歌曲信息API
 * @param 参数%1：歌曲id
 */

const QString ApiOfSongInfo = "http://play.baidu.com/data/music/songinfo?songIds=%1";

/*
 * @brief 歌曲链接API
 * @param 参数%1：歌曲id
 */

const QString ApiOfSongLink = "http://play.baidu.com/data/music/songlink?songIds=%1&type=m4a,mp3";

BaiduMusic::BaiduMusic(QObject *parent) : QObject(parent)
{
    //初始化所有响应值为0
    searchReply = 0;
    suggestionReply = 0;
    songInfoReply = 0;
    songLinkReply = 0;
    lyricReply = 0;
}

BaiduMusic::~BaiduMusic()
{

}

//搜索关键字
void BaiduMusic::search(const QString &keyword, int page)
{
    //删除原来的响应
    if(searchReply){
        searchReply->deleteLater();
    }

    //起始位置
    int start = (page-1)*PAGESIZE;

    //构造百度音乐API搜索请求的url
    QUrl url = QUrl(ApiOfSearch.arg(keyword).arg(start));
    searchReply = manager.get(QNetworkRequest(url));
    connect(searchReply,SIGNAL(finished()),this,SLOT(searchReplyFinished()));
}

void BaiduMusic::getSuggestion(QString keyword)
{
    //删除原来的响应
    if(suggestionReply){
        suggestionReply->deleteLater();
    }

    //构造百度音乐API搜索歌曲id的url
    QUrl url = QUrl(ApiOfSuggestion.arg(keyword));
    suggestionReply = manager.get(QNetworkRequest(url));
    connect(suggestionReply,SIGNAL(finished()),this,SLOT(suggestionReplyFinished()));
}

void BaiduMusic::getSongInfo(QString songId)
{
    //删除原来的响应
    if(songInfoReply){
        songInfoReply->deleteLater();
    }
    //构造百度音乐API搜索歌曲信息的url
    QUrl url = QUrl(ApiOfSongInfo.arg(songId));
    songInfoReply = manager.get(QNetworkRequest(url));
    connect(songInfoReply,SIGNAL(finished()),this,SLOT(songInfoReplyFinished()));
}

void BaiduMusic::getSongLink(QString songId)
{
    //删除原来的响应
    if(songLinkReply){
        songLinkReply->deleteLater();
    }
  //构造百度音乐API获取歌曲的url
    QUrl url = QUrl(ApiOfSongLink.arg(songId));
    songLinkReply = manager.get(QNetworkRequest(url));
    connect(songLinkReply,SIGNAL(finished()),this,SLOT(songLinkReplyFinished()));
}

void BaiduMusic::getLyric(QString url)
{
    //删除原来的响应
    if(lyricReply){
        lyricReply->deleteLater();
    }
    //构造百度音乐API获取歌词的url
    lyricReply = manager.get(QNetworkRequest(QUrl(url)));
    connect(lyricReply,SIGNAL(finished()),this,SLOT(lyricReplyFinished()));
}

QString BaiduMusic::unifyResult(QString r)
{
    //整合信息，songid转换为sid，songname转换为sname，author转换为singger
    return r.replace(QRegularExpression("songid|songId"),"sid")
            .replace(QRegularExpression("author|artistname"),"singer")
            .replace(QRegularExpression("songname|songName"),"sname");
}

void BaiduMusic::searchReplyFinished()
{
    //搜索请求已完成
    QString url = searchReply->request().url().toString();

    int keywordBegin = url.indexOf("key=") + 4;
    int keywordEnd = url.indexOf("&start=");

    int pageBeginPos = url.indexOf("start=") + 6;
    int pageEndPos = url.indexOf("&size=");

    //当前页
    int currentPage = url.mid(pageBeginPos,pageEndPos-pageBeginPos).toInt()/PAGESIZE + 1;

    //关键字
    QString keyword = url.mid(keywordBegin,keywordEnd-keywordBegin);
    if(searchReply->error()){

        //如果出错，pageCount为-1;
        emit searchComplete(currentPage,1,keyword,"{error:"+searchReply->errorString()+"}");//异常信息写入信号并发出
        return;
    }

    //TODO:未搜索到内容的判断

    QString html = searchReply->readAll();
    QStringList songList;
    QRegularExpression re("<li data-songitem = '(.+?)'");
    QRegularExpressionMatchIterator i = re.globalMatch(html);

    while(i.hasNext()) {
        QRegularExpressionMatch match = i.next();
        QString songData = match.captured(1);
        //&quot; 替换为 " ;删除<em>和</em>
        songData = songData.replace("&quot;","\"").replace("&lt;em&gt;","").replace("&lt;\\/em&gt;","");
        songList << songData;
    }

    //构造json数组
    QString songArray = "[" + songList.join(",") + "]";
    QString result = unifyResult(songArray);
    //匹配总页数
    QRegularExpression pageCountRe("\">(\\d+)</a>\\s*<a class=\"page-navigator-next\"");
    QRegularExpressionMatch match = pageCountRe.match(html);

    //页面总数
    int pageCount = match.captured(1).toInt();

    //如果没有 pageCount，则 pageCount 设为 1;
    pageCount = pageCount>0 ? pageCount : 1;

    emit searchComplete(currentPage,pageCount,keyword,result);//页面信息写入信号并发出
}

void BaiduMusic::suggestionReplyFinished()
{
    //搜索建议已完成
    if(suggestionReply->error()){
        emit getSuggestionComplete("{error:"+suggestionReply->errorString()+"}");//异常信息写入信号并发出
        return;//搜索出错返回
    }
    QString sug = suggestionReply->readAll();//获取建议字段
    emit getSuggestionComplete(unifyResult(sug));//字段写入信号并发出
}

void BaiduMusic::songInfoReplyFinished()
{
    //歌曲信息已回应
    if(songInfoReply->error()){
        emit getSongInfoComplete("{error:"+songInfoReply->errorString()+"}");//异常信息写入信号并发出
        return;//响应异常则返回
    }
    
    QString songinfo = songInfoReply->readAll();//获取歌曲信息字段
    emit getSongInfoComplete(songinfo);//字段写入信号并发出
}

void BaiduMusic::songLinkReplyFinished()
{
    //歌曲链接已回应
    if(songLinkReply->error()){
        emit getSongLinkComplete("{error:"+songLinkReply->errorString()+"}");//异常信息写入信号并发出
        return;//响应异常则返回
    }
    
    QString songlink = songLinkReply->readAll();//获取歌曲链接字段

    emit getSongLinkComplete(unifyResult(songlink));//字段写入信号并发出
}

void BaiduMusic::lyricReplyFinished()
{
    //歌词链接已回应
    QString url = lyricReply->url().toString();
    if(lyricReply->error()){
        emit getLyricComplete(url,"error");//空字段
        return;//响应异常则返回
    }
    qDebug()<<"歌词头部信息："<<lyricReply->rawHeaderList();//异常则返回错误信息
    QByteArray bytes = lyricReply->readAll();  //获取字节
    QString result(bytes);  //转化为字符串
    emit getLyricComplete(url,result);//字段写入信号并发出
}
