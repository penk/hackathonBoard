#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>
#if QT_VERSION > QT_VERSION_CHECK(5, 1, 0)
#include <QQmlApplicationEngine>
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

#if QT_VERSION > QT_VERSION_CHECK(5, 1, 0)
    QQmlApplicationEngine engine(QUrl("qrc:///main.qml"));
#else
    QQuickView view;
    view.setSource(QUrl("qrc:///main.qml"));
    view.show();
#endif

    return app.exec();
}
