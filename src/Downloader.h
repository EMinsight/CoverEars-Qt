#pragma once
#include <QObject>
#include <QCoreApplication>
class Downloader : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isDownloading READ isDownloading WRITE setIsDownloading NOTIFY isDownloadingChanged)
    Q_PROPERTY(QString folder READ folder)
public:
    QString folder() const
    {
        return qApp->applicationDirPath();
    }
    bool isDownloading() const
    {
        return m_isDownloading;
    }

signals:

    void isDownloadingChanged(bool isDownloading);

public slots:
    void download(const QString &url, const int CPUCount = 1);

    void setIsDownloading(bool isDownloading)
    {
        if (m_isDownloading == isDownloading)
            return;

        m_isDownloading = isDownloading;
        emit isDownloadingChanged(m_isDownloading);
    }
protected:
    void singleDownload(const QString &url, const qint64 length, const QString &filePath);
    void mulitDownload(const QString &url, const qint64 length, const QString &filePath, const int CPUCount);
private:
    bool m_isDownloading = false;
};
