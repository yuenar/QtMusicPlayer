import QtQuick 2.5
import QtMultimedia 5.5
import BayToCore 1.0

Item {//歌词列表
    property var playlists: {"最近点播":[]}
    property string currentList: "最近点播"
    property MediaPlayer mediaPlayer
    property BaiduMusic baiduMusic
    property ReadWrite readWrite
    property string currentSid
    property int rmid

    property bool selcp: false
    property bool updated: false
    property bool playing: false
    property int index: -1
    property int sindex: 1
    property int cindex: 1


    Binding{
        //与桌面歌词播放状态的数据绑定
        target: dLrc
        property: "played"
        value: playing
    }
    /*以下为调用外部类槽函数的连接*/
    Connections{
        target: baiduMusic
        //歌曲播放地址获取完毕
        onGetSongLinkComplete:{
            try{
                var link = JSON.parse(songLink);
                //如果还是当前播放歌曲，则立即播放，否则不处理
                if(playlists[currentList][index].sid == link.data.songList[0].sid){
                    var mp3link = link.data.songList[0].songLink;
                    mediaPlayer.source = mp3link;
                    mediaPlayer.play();
                }
            }catch(e){
                console.log("getLink:"+e);
            }
        }
        onGetLyricComplete:{
            lyricView.flush();//清空之前的歌词显示
            lyricView.parseLyric(lyricContent);//解析歌词
            dLrc.flush();//清空之前的桌面歌词
            dLrc.parseLyric(lyricContent);//解析歌词
            var curName=playlists[currentList][index].sname;
            console.log("自动保存歌词文件:"+curName+".lrc");
            readWrite.saveLrc(curName,lyricContent);
        }
    }
    Connections
    {
        target:localSong
        onSetSongPath:
        {//当次添加随即播放
            try
            {
                sindex=listLength;
                cindex=sindex;
                var locSong= localSong.getSong(cindex);
                mediaPlayer.source=locSong;
                console.log("当前歌曲列表长度是:"+sindex);
                mediaPlayer.play();

            }
            catch(e){
                console.log("添加状态:"+e);
            }
        }
        onDirCount:{
            var temp=localSong.getSong(length);
            var currentLrc=readWrite.readLrc(temp);
            console.log("读取歌词文件:"+temp);
            lyricView.flush();//清空之前的歌词显示
            lyricView.parseLyric(currentLrc);//解析歌词
            dLrc.flush();//清空之前的桌面歌词
            dLrc.parseLyric(currentLrc);//解析歌词
        }
    }
    Connections{
        target: mediaPlayer
        onStopped: {
            if(mediaplayer.status == MediaPlayer.EndOfMedia){
                next();
            }
        }
    }
    /*以下为私有方法*/
    //列表中的歌曲数目
    function count(list){
        var listname = list ? list : currentList;
        console.log("listname:"+listname);
        if(typeof playlists[listname] == 'undefined'){
            playlists[listname] = [];
        }
        return playlists[listname].length;
    }

    function getSong(i,list){
        var listname = list ? list : currentList;
        return playlists[listname][i];
    }

    //返回指定列表的歌曲
    function getSongList(list){
        var listname = list? list : currentList;
        return playlists[listname];
    }

    //当前播放位置
    function currentIndex(){
        return index;
    }

    //添加歌曲到默认列表
    function addSong(song,list){
        if(typeof playlists[currentList] == 'undefined'){
            playlists[currentList] = [];
        }
        else
        {
            playlists[currentList].push(song);
        }
    }

    //插入到指定位置
    function insertSong(pos,song,list){
        playlists[list].splice(pos,0,song);
    }

    //替换列表中的歌曲
    function replace(pos,song,list){
        playlists[list].splice(pos,1,song);
    }
    //播放指定位置歌曲
    function setIndex(i){
        mediaPlayer.pause();//切歌先暂停播放
        index = i;
        //如果是缓存音乐，则直接播放
        if(playlists[currentList][index].localpath){
            mediaPlayer.source =  playlists[currentList][index].localpath;
            mediaPlayer.play();
            return;
        }
        else
        {
            console.log("setIndex:"+i + "  length:" + playlists[currentList].length);
            if(i<0 || i>(playlists[currentList].length - 1))
            {
                return;

            }
            var curSid = playlists[currentList][index].sid;
            currentSid = curSid;
            //如果不是缓存音乐，则重新获取歌曲链接
            baiduMusic.getSongLink(curSid);
            //获取专辑图片
            baiduMusic.getSongInfo(curSid);
        }
    }
    //点击下一首的响应
    function next(){
        if(true==bottomBar.sequence)
        {//循环模式
            if(selcp)
            {
                if(cindex==sindex)
                {
                    cindex=1;
                    mediaPlayer.source= localSong.getSong(cindex);
                }
                else
                {
                    cindex+=1;
                    mediaPlayer.source= localSong.getSong(cindex);
                }
                console.log("当前歌曲序号是:"+cindex);
                updated=!updated;
                mediaPlayer.play();
            }else{
                if(index ===(playlists[currentList].length-1))
                {
                    setIndex(0);
                }
                else setIndex(index + 1);
            }
        }
        else if(true==bottomBar.random)
        {//随机播放
            if(selcp)
            {//本地列表
                cindex=Math.random()*sindex;
                mediaPlayer.source= localSong.getSong(cindex);
                updated=!updated;
                mediaPlayer.play();
            }else{
                setIndex(Math.random()*(playlists[currentList].length-1));
            }
        }
        else if(true==bottomBar.sincle)
        {//单曲循环
            if(selcp)
            {
                mediaPlayer.source= localSong.getSong(cindex);
                mediaPlayer.play();

            }else
                setIndex(currentIndex());
        }
        else if(true==bottomBar.once)
        {//单曲播放，点击则停止
            mediaPlayer.stop();
        }
        console.log("更新歌曲信息完成");
        return;
    }
    //点击上一首的响应
    function previous(){
        if(true==bottomBar.sequence)
        {//循环模式
            if(selcp)
            {//本地列表
                if(cindex==1)
                {
                    cindex=sindex;
                    mediaPlayer.source= localSong.getSong(cindex);
                }
                else
                {
                    cindex-=1;
                    mediaPlayer.source= localSong.getSong(cindex);
                }
                console.log("当前歌曲序号是:"+cindex);
                updated=!updated;
                mediaPlayer.play();
            }else{
                if(index==0)
                {
                    setIndex(playlists[currentList].length-1);
                }
                else setIndex(index - 1);
            }
        }
        else if(true==bottomBar.random)
        {//随机播放
            if(selcp)
            {//本地列表
                cindex=Math.random()*sindex;
                mediaPlayer.source= localSong.getSong(cindex);
                updated=!updated;
                mediaPlayer.play();
            }else{
                setIndex(Math.random()*(playlists[currentList].length-1));
            }
        }
        else if(true==bottomBar.sincle)
        {//单曲循环
            if(selcp)
            {
                mediaPlayer.source= localSong.getSong(cindex)
                mediaPlayer.play();
            }else
                setIndex(currentIndex());
        }
        else if(true==bottomBar.once)
        {//单曲播放，点击则停止
            mediaPlayer.stop();
        }
        console.log("更新歌曲信息完成");
        return;
    }
    //播放当前歌曲的响应
    function play(){
        if(mediaPlayer.source==""){
            setIndex(index);
            return;
        }
        else
        {
         mediaPlayer.play();
         playing=true;
        }

    }
    //暂停播放的响应
    function pause(){
        mediaPlayer.pause();
        playing=false;
    }
    //从临时文件加载播放列表
    function loadFrom(filename){
        try{
            var savedList = JSON.parse(readWrite.readFile(filename));
            for(var i in savedList){
                playlists[i] = savedList[i];
            }
            index = 0;
        }catch(e){
            console.log("Playlist[loadFrom]:"+e);
        }
    }
    //保存文件
    function saveTo(filename){
        readWrite.saveFile(filename,JSON.stringify(playlist.playlists));
    }
}
