#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QCoreApplication>
#include <QtQml/qqml.h>

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

        const QVariantMap defaultProvider = {
            {"id", QStringLiteral("deepseek")},
            {"name", QStringLiteral("DeepSeek")},
            {"description", QStringLiteral("DeepSeek chat and reasoning models")},
            {"base_url", QStringLiteral("https://api.deepseek.com")},
            {"api_key", QString()},
            {"model", QStringLiteral("deepseek-v4-flash")},
            {"temperature", 0.2},
            {"provider_options", QString()},
            {"headers", QStringLiteral("{}")},
            {"features", QVariantMap({
                {QStringLiteral("page_translation"), true},
                {QStringLiteral("video_subtitles"), true},
                {QStringLiteral("selection_toolbar_translation"), true},
                {QStringLiteral("input_translation"), true},
                {QStringLiteral("language_detection"), true},
                {QStringLiteral("dictionary"), true}
            })}
        };

        QVariantList providers = settings.value("providers/list").toList();
        if (providers.isEmpty()) {
            providers << defaultProvider;
        } else {
            for (int i = 0; i < providers.size(); ++i) {
                QVariantMap provider = providers.at(i).toMap();
                if (!provider.contains("id")) provider["id"] = QStringLiteral("deepseek");
                if (!provider.contains("name")) provider["name"] = QStringLiteral("DeepSeek");
                if (!provider.contains("description")) provider["description"] = QStringLiteral("DeepSeek chat and reasoning models");
                if (!provider.contains("base_url")) provider["base_url"] = settings.value("deepseek/base_url", QStringLiteral("https://api.deepseek.com")).toString();
                if (!provider.contains("api_key")) provider["api_key"] = settings.value("deepseek/api_key", QString()).toString();
                if (!provider.contains("model")) provider["model"] = settings.value("deepseek/model", QStringLiteral("deepseek-v4-flash")).toString();
                if (!provider.contains("temperature")) provider["temperature"] = settings.value("deepseek/temperature", 0.2).toDouble();
                if (!provider.contains("provider_options")) provider["provider_options"] = QString();
                if (!provider.contains("headers")) provider["headers"] = QStringLiteral("{}");
                if (!provider.contains("features")) {
                    QVariantMap features;
                    features["page_translation"] = true;
                    features["video_subtitles"] = true;
                    features["selection_toolbar_translation"] = true;
                    features["input_translation"] = true;
                    features["language_detection"] = true;
                    features["dictionary"] = true;
                    provider["features"] = features;
                }
                providers[i] = provider;
            }
        }

        config["providers"] = providers;
        config["active_provider"] = settings.value("providers/active", QStringLiteral("deepseek")).toString();

        const QString activeProviderId = settings.value("providers/active", QStringLiteral("deepseek")).toString();
        QVariantMap activeProvider = providers.isEmpty() ? defaultProvider : providers.first().toMap();
        for (const QVariant &entry : providers) {
            QVariantMap candidate = entry.toMap();
            if (candidate.value("id").toString() == activeProviderId || candidate.value("uuid").toString() == activeProviderId) {
                activeProvider = candidate;
                break;
            }
        }

        config["base_url"] = activeProvider.value("base_url", settings.value("deepseek/base_url", QStringLiteral("https://api.deepseek.com"))).toString();
        config["api_key"] = activeProvider.value("api_key", settings.value("deepseek/api_key", QString())).toString();
        config["model"] = activeProvider.value("model", settings.value("deepseek/model", QStringLiteral("deepseek-v4-flash"))).toString();
        config["temperature"] = activeProvider.value("temperature", settings.value("deepseek/temperature", 0.2)).toDouble();
        config["provider_options"] = activeProvider.value("provider_options", QString()).toString();
        config["headers"] = activeProvider.value("headers", QStringLiteral("{}")).toString();
        config["font_size"] = settings.value("ui/font_size", 13).toInt();
        config["first_language"] = settings.value("ui/first_language", QStringLiteral("en")).toString();
        config["second_language"] = settings.value("ui/second_language", QStringLiteral("en")).toString();

        return config;
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

        QVariantList providers = config.value("providers").toList();
        if (providers.isEmpty()) {
            QVariantMap defaultProvider;
            defaultProvider["id"] = QStringLiteral("deepseek");
            defaultProvider["name"] = QStringLiteral("DeepSeek");
            defaultProvider["description"] = QStringLiteral("DeepSeek chat and reasoning models");
            defaultProvider["base_url"] = config.value("base_url", QStringLiteral("https://api.deepseek.com"));
            defaultProvider["api_key"] = config.value("api_key", QString());
            defaultProvider["model"] = config.value("model", QStringLiteral("deepseek-v4-flash"));
            defaultProvider["temperature"] = config.value("temperature", 0.2);
            defaultProvider["provider_options"] = config.value("provider_options", QString());
            defaultProvider["headers"] = config.value("headers", QStringLiteral("{}"));
            QVariantMap features;
            features["page_translation"] = true;
            features["video_subtitles"] = true;
            features["selection_toolbar_translation"] = true;
            features["input_translation"] = true;
            features["language_detection"] = true;
            features["dictionary"] = true;
            defaultProvider["features"] = features;
            providers << defaultProvider;
        }

        const QVariantMap fallbackProvider = providers.isEmpty() ? QVariantMap() : providers.first().toMap();
        const QString activeProviderId = config.value("active_provider", fallbackProvider.value("id", QStringLiteral("deepseek"))).toString();
        QVariantMap currentProvider = fallbackProvider;

        for (const QVariant &entry : providers) {
            QVariantMap candidate = entry.toMap();
            if (candidate.value("id").toString() == activeProviderId) {
                currentProvider = candidate;
                break;
            }
        }

        settings.setValue("providers/list", providers);
        settings.setValue("providers/active", activeProviderId);
        settings.setValue("deepseek/base_url", currentProvider.value("base_url", config.value("base_url", QStringLiteral("https://api.deepseek.com"))));
        settings.setValue("deepseek/api_key", currentProvider.value("api_key", config.value("api_key", QString())));
        settings.setValue("deepseek/model", currentProvider.value("model", config.value("model", QStringLiteral("deepseek-v4-flash"))));
        settings.setValue("deepseek/temperature", currentProvider.value("temperature", config.value("temperature", 0.2)));
        settings.setValue("ui/font_size", config.value("font_size", 13));
        settings.setValue("ui/first_language", config.value("first_language", QStringLiteral("en")));
        settings.setValue("ui/second_language", config.value("second_language", QStringLiteral("en")));

        settings.sync();
        return settings.status() == QSettings::NoError;
    }

private:
    QQmlApplicationEngine *m_engine = nullptr;
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("m-translate-qt"));
    QCoreApplication::setApplicationName(QStringLiteral("AI Translation Studio"));

    QQmlApplicationEngine engine;
    DeepSeekConfigManager *configManager = new DeepSeekConfigManager(&app);
    configManager->setEngine(&engine);
    qmlRegisterSingletonInstance<DeepSeekConfigManager>("m.translate.qt", 1, 0, "DeepSeekConfigManager", configManager);
    engine.rootContext()->setContextProperty("deepSeekConfigManager", configManager);
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
