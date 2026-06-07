#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QTranslator>
#include <QCoreApplication>
#include <QLocale>

class DeepSeekConfigManager : public QObject
{
    Q_OBJECT
public:
    explicit DeepSeekConfigManager(QObject *parent = nullptr) : QObject(parent) {}

    void setEngine(QQmlApplicationEngine *engine) { m_engine = engine; }

    Q_INVOKABLE QVariantMap loadConfig() const
    {
        QSettings settings;
        QVariantMap config;
        config["base_url"] = settings.value("deepseek/base_url", QStringLiteral("https://api.deepseek.com")).toString();
        config["api_key"] = settings.value("deepseek/api_key", QString()).toString();
        config["model"] = settings.value("deepseek/model", QStringLiteral("deepseek-v4-flash")).toString();
        config["temperature"] = settings.value("deepseek/temperature", 0.2).toDouble();
        config["top_p"] = settings.value("deepseek/top_p", 1.0).toDouble();
        config["max_tokens"] = settings.value("deepseek/max_tokens", 4096).toInt();
        config["system_prompt"] = settings.value("deepseek/system_prompt", QStringLiteral("你是专业翻译引擎，逐句忠实翻译，不添加解释")).toString();
        config["style"] = settings.value("deepseek/style", QStringLiteral("fluent")).toString();
        config["glossary"] = settings.value("deepseek/glossary", true).toBool();
        config["preserve_format"] = settings.value("deepseek/preserve_format", true).toBool();
        config["context_mode"] = settings.value("deepseek/context_mode", QStringLiteral("document")).toString();
        config["chunk_size"] = settings.value("deepseek/chunk_size", 1000).toInt();
        config["consistency_mode"] = settings.value("deepseek/consistency_mode", true).toBool();
        config["language"] = settings.value("ui/language", QStringLiteral("system")).toString();
        config["font_size"] = settings.value("ui/font_size", 13).toInt();
        return config;
    }

    Q_INVOKABLE QString currentLanguage() const
    {
        QSettings settings;
        return settings.value("ui/language", QStringLiteral("system")).toString();
    }

    Q_INVOKABLE bool setLanguage(const QString &language)
    {
        QSettings settings;
        const QString value = language.isEmpty() ? QStringLiteral("system") : language;
        settings.setValue("ui/language", value);
        settings.sync();

        QCoreApplication::removeTranslator(&m_translator);
        const QString localeName = value == QLatin1String("system")
            ? QLocale::system().name().replace('_', '-')
            : value;

        const bool useEnglish = localeName.startsWith("en", Qt::CaseInsensitive) || value == QLatin1String("en");
        if (useEnglish && m_translator.load(QStringLiteral(":/translations/m-translate-qt_en.qm")))
        {
            QCoreApplication::installTranslator(&m_translator);
        }

        if (m_engine)
            m_engine->retranslate();
        return settings.status() == QSettings::NoError;
    }

    Q_INVOKABLE QVariantMap loadWindowGeometry() const
    {
        return loadWindowGeometry(QStringLiteral("home"));
    }

    Q_INVOKABLE QVariantMap loadWindowGeometry(const QString &windowName) const
    {
        QSettings settings;
        const QString prefix = QStringLiteral("window/%1/").arg(windowName);
        QVariantMap geometry;
        geometry["x"] = settings.value(prefix + QStringLiteral("x"), 100).toInt();
        geometry["y"] = settings.value(prefix + QStringLiteral("y"), 100).toInt();
        geometry["width"] = settings.value(prefix + QStringLiteral("width"), 330).toInt();
        geometry["height"] = settings.value(prefix + QStringLiteral("height"), 600).toInt();
        return geometry;
    }

    Q_INVOKABLE bool saveWindowGeometry(int x, int y, int width, int height)
    {
        return saveWindowGeometry(QStringLiteral("home"), x, y, width, height);
    }

    Q_INVOKABLE bool saveWindowGeometry(const QString &windowName, int x, int y, int width, int height)
    {
        QSettings settings;
        const QString prefix = QStringLiteral("window/%1/").arg(windowName);
        settings.setValue(prefix + QStringLiteral("x"), x);
        settings.setValue(prefix + QStringLiteral("y"), y);
        settings.setValue(prefix + QStringLiteral("width"), width);
        settings.setValue(prefix + QStringLiteral("height"), height);
        settings.sync();
        return settings.status() == QSettings::NoError;
    }

    Q_INVOKABLE bool saveConfig(const QVariantMap &config)
    {
        QSettings settings;
        settings.setValue("deepseek/base_url", config.value("base_url", QStringLiteral("https://api.deepseek.com")));
        settings.setValue("deepseek/api_key", config.value("api_key", QString()));
        settings.setValue("deepseek/model", config.value("model", QStringLiteral("deepseek-v4-flash")));
        settings.setValue("deepseek/temperature", config.value("temperature", 0.2));
        settings.setValue("deepseek/top_p", config.value("top_p", 1.0));
        settings.setValue("deepseek/max_tokens", config.value("max_tokens", 4096));
        settings.setValue("deepseek/system_prompt", config.value("system_prompt", QStringLiteral("你是专业翻译引擎，逐句忠实翻译，不添加解释")));
        settings.setValue("deepseek/style", config.value("style", QStringLiteral("fluent")));
        settings.setValue("deepseek/glossary", config.value("glossary", true));
        settings.setValue("deepseek/preserve_format", config.value("preserve_format", true));
        settings.setValue("deepseek/context_mode", config.value("context_mode", QStringLiteral("document")));
        settings.setValue("deepseek/chunk_size", config.value("chunk_size", 1000));
        settings.setValue("deepseek/consistency_mode", config.value("consistency_mode", true));
        settings.setValue("ui/language", config.value("language", QStringLiteral("system")));
        settings.setValue("ui/font_size", config.value("font_size", 13));
        settings.sync();
        return settings.status() == QSettings::NoError;
    }

private:
    QTranslator m_translator;
    QQmlApplicationEngine *m_engine = nullptr;
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("m-translate-qt"));
    QCoreApplication::setApplicationName(QStringLiteral("AI Translation Studio"));

    QQmlApplicationEngine engine;
    DeepSeekConfigManager configManager;
    configManager.setEngine(&engine);
    configManager.setLanguage(configManager.currentLanguage());
    engine.rootContext()->setContextProperty("deepSeekConfigManager", &configManager);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("m.translate.qt", "Main");

    return app.exec();
}

#include "main.moc"
