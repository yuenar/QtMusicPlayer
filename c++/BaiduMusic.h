#ifndef BAIDUMUSIC_H
#define BAIDUMUSIC_H
#pragma execution_character_set("utf-8")
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkCookieJar>
#include <QNetworkReply>

//百度音乐接口类
class BaiduMusic : public QObject
{
    Q_OBJECT
public:
    explicit BaiduMusic(QObject *parent = 0);
    ~BaiduMusic();

public slots:
    //公有方法

    /*
     * @brief 搜索歌曲
     * @param keyword 关键字
     * @param page	页数
     */
    void search(const QString& keyword, int page);

    /*
     * @brief 获取搜索建议
     * @param keyword 百度音乐歌曲id
     */
    void getSuggestion(QString keyword);

    /*
     * @brief 获取歌曲信息
     * @param songId
     */
    void getSongInfo(QString songId);

    /*
     * @brief 获取歌曲链接，包括下载链接和歌词连接等
     * @param songId
     */
    void getSongLink(QString songId);

    /*
     * @brief 根据歌词链接下载歌词
     * @param url
     */
    void getLyric(QString url);


private:
    //私有属性
    QNetworkAccessManager manager;
    QNetworkReply* searchReply;
    QNetworkReply* suggestionReply;
    QNetworkReply* songInfoReply;
    QNetworkReply* songLinkReply;
    QNetworkReply* lyricReply;

    //统一结果，如songid转换为sid，songname转换为sname
    QString unifyResult(QString r);
private slots:
    //私有方法
    void searchReplyFinished();//搜索请求已完成
    void suggestionReplyFinished();//搜索建议已完成
    void songInfoReplyFinished();//歌曲信息已回应
    void songLinkReplyFinished();//歌曲链接已回应
    void lyricReplyFinished();//歌词链接已回应
signals:
    //信号量
    /*
     * @brief searchComplete 搜索完毕
     * @param currentPage 当前页
     * @param pageCount 总页数
     * @param keyword 关键字
     * @param songList 歌曲列表,json数据
     */
    void searchComplete(int currentPage,int pageCount,QString keyword, QString songList);

    /*
     * @brief getSuggestionComplete 获取搜索建议完毕
     * @param suggestion 搜索建议json数据
     * {
     *    "data": {
     *     "song":[{"bitrate_fee":"{\"0\":\"0|0\",\"1\":\"0|0\"}",
     *     "yyr_artist":"0",
     *     "sname":"怒放的生命",
     *     "singer":"汪峰",
     *     "sid":"233076",
     *     "has_mv":"1",
     *     "encrypted_sid":"300538e740956e93ea1L"},]
     *   }
     *
     */
    void getSuggestionComplete(QString suggestion);

    /*
     * @brief  获取歌曲简介完毕
     * @param songInfo 歌曲简介
     */
    void getSongInfoComplete(QString songInfo);

    /*
     * @brief  获取歌曲连接完毕
     * @param songLink 歌曲链接
     */
    void getSongLinkComplete(QString songLink);

    /*
     * @brief  获取歌词连接完毕
     * @param url 歌词链接
     * @param lyricContent 歌词条目
     */
    void getLyricComplete(QString url,QString lyricContent);

};

#endif // BAIDUMUSIC_H
