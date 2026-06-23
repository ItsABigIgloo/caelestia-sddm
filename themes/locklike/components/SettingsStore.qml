import QtQml
import QtQuick.LocalStorage 2.0

QtObject {
    id: root

    function getDb() {
        return LocalStorage.openDatabaseSync("CaelestiaSDDM", "1.0", "Caelestia SDDM settings", 10000);
    }

    function get(key, fallback) {
        try {
            var db = getDb();
            var result = fallback;
            db.transaction(function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings (key TEXT UNIQUE, value TEXT)');
                var rs = tx.executeSql('SELECT value FROM settings WHERE key=?', [key]);
                if (rs.rows.length > 0)
                    result = rs.rows.item(0).value;
            });
            return result;
        } catch(e) { return fallback; }
    }

    function set(key, value) {
        try {
            var db = getDb();
            db.transaction(function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings (key TEXT UNIQUE, value TEXT)');
                tx.executeSql('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)', [key, String(value)]);
            });
        } catch(e) {}
    }
}
