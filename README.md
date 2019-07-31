# CoverEars-Qt

“迅雷不及掩耳”

Qt版多线程下载器

还有个golang版本的，[golang版CoverEars](https://github.com/jaredtao/CoverEars)

# 徽章

|[Ubuntu/MacOS][lin-link] | [Windows][win-link] |[License][license-link] |
| :---------------: | :-----------------: | :-----------------:|
| ![lin-badge]      | ![win-badge]        | ![license-badge] |

[lin-badge]: https://travis-ci.com/jaredtao/CoverEars-Qt.svg?branch=master "Travis build status"
[lin-link]: https://travis-ci.com/jaredtao/CoverEars-Qt "Travis build status"
[win-badge]: https://ci.appveyor.com/api/projects/status/i7y38qfakacsehgf?svg=true "AppVeyor build status"
[win-link]: https://ci.appveyor.com/project/jaredtao/CoverEars-Qt "AppVeyor build status"
[license-link]: https://github.com/jaredtao/CoverEars-Qt/blob/master/LICENSE "LICENSE"
[license-badge]: https://img.shields.io/badge/license-MIT-blue.svg "MIT"

# 原理

## 基本

发http请求，收数据等基本操作。

注意打开重定向。req.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true)

只请求head获取文件大小,以及是否支持Range。

## 多线程下载

每个线程下一部分，通过设置http头部"Range:bytes=%1-%2"

## 写文件方式

单线程使用file.write(reply->readAll())

多线程使用mapping-file映射内存文件, 之后 reply->readAll() + memcpy 存入

(尝试过seek的方式,多线程写会出问题，需要加锁。后来就换成内存映射文件了)

# 性能记录

测试环境

家里台式机, Win10 1903专业版, 无线网卡最大速度65MBps

测试了两个文件

|文件名|大小|路径|
|---------------|-----------------|-----------------|
|qtlinguistinstaller-5.12.2.exe| 36.2MB |http://download.qt.io/linguist_releases/qtlinguistinstaller-5.12.2.exe|
|qt-everywhere-src-5.12.4.tar.xz| 484MB |http://download.qt.io/official_releases/qt/5.12/5.12.4/single/qt-everywhere-src-5.12.4.tar.xz|


耗时统计使用QTime, 从发起网络请求开始，到文件写入完成。


测试大致结果

|编号|次数|文件|耗时(ms)|线程数|备注|
|---------------|---------------|--------------- |----------------- |-----------------|-----------------|
|1|-|qtlinguistinstaller-5.12.2.exe|-|1|单线程测试|
|1|1||10493|||
|1|2||17644|||
|1|3||11840|||
|2|-|qtlinguistinstaller-5.12.2.exe|-|6|多线程测试|
|2|1||22201||最后一段数据卡的有点久 ??|
|2|2||27494||最后一段数据卡的有点久 ??|
|2|3||28214||最后一段数据卡的有点久 ??|
|3|-|qtlinguistinstaller-5.12.2.exe|-|6| readAll 换成固定buffer,减少QByteArray的内存分配，增加了memcpy的次数 |
|3|1||20780|| 最后一段数据仍然卡的有点久。总时间比readAll稍微好点 |
|3|2||22178|| 同上 |
|3|3||12078|| 什么情况？快这么多？网络波动吗?再来一次呢？|
|3|4||20937|| 正常了，3-3应该是网络波动|
|4|-|qt-everywhere-src-5.12.4.tar.xz|-|1|单线程测试|
|4|1||152142|||
|5|-|qt-everywhere-src-5.12.4.tar.xz|-|6|多线程测试|
|5|1||339700||我搞懂Qt这个坑了，第六个线程在排队！QNetworkAccessManager最大支持6！算上主线程它是第七个！那我试试5线程|
|6|-|qt-everywhere-src-5.12.4.tar.xz|-|5|5线程测试|
|6|1||143216||果然。比单线程快一点。|
|7|-|qtlinguistinstaller-5.12.2.exe|-|5|5线程测试，小文件也来一发|
|7|1||10916||再次验证5线程。不过小文件用多线程没有优势。|
