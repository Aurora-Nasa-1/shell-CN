#pragma once

#include <qnetworkaccessmanager.h>
#include <qobject.h>
#include <qqmlengine.h>

namespace caelestia {

class Requests : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Requests(QObject* parent = nullptr);

    Q_INVOKABLE void get(
        const QUrl& url, QJSValue callback, QJSValue onError = QJSValue(), QJSValue headers = QJSValue()) const;
    Q_INVOKABLE void postStream(
        const QString& url, const QString& body, QJSValue onChunk, QJSValue onError = QJSValue(), QJSValue headers = QJSValue(), QJSValue onFinished = QJSValue()) const;
    Q_INVOKABLE void resetCookies() const;

private:
    QNetworkAccessManager* m_manager;
};

} // namespace caelestia
