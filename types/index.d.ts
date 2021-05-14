interface Window {
    AppUpdate: AppUpdate;
}

/**
 * Плагин для доступа к номерам версий в app-сторах
 */
interface AppUpdate {
    /**
     * Получить данные о версии приложения из App Store (iOS) и Google Play (Android)
     * @param successCallback Обратный вызов при успешном доступе к сторам
     * @param errorCallback   Обратный вызов при возникновении ошибок
     */
    getMetadata(
        successCallback: (data: AppStoreData) => void,
        errorCallback?: (error: any) => void,
    ): void;
}

/**
 * Информация о текущем приложении в сторах
 */
interface AppStoreData {
    /**
     * Статус версии приложения в сторах в сравнении с текущей версией приложения
     */
    updateAvailable: AppVersionStatus;
    /**
     * Идентификатор текущего приложения
     */
    appId: string;
    /**
     * Версия текущего приложения
     */
    currentVersion: string;
    /**
     * Версия приложения в сторе
     */
    storeVersion: string;
    /**
     * Ссылка на домашнюю страницу для обновления приложения в сторе
     */
    storeUrl: string;
}

/**
 * Статус версии приложения в сторах в сравнении с текущей версией приложения
 */
declare enum AppVersionStatus {
    /**
     * Текущая версия является последней версией в сторе, обновление не требуется
     */
    Latest = 0,
    /**
     * Текущая версия устарела, есть более новая версия в сторе
     */
    Outdated = 1,
    /**
     * Текущая версия новее, чем опубликованная
     */
    Beta = 2,
    /**
     * Не удалось получить версию из стора
     */
    Unknown = 3,
}
