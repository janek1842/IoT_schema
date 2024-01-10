SET GLOBAL event_scheduler = ON; 

-- Events for automatically updating update_date 

DROP TRIGGER IF EXISTS iot_project.update_date_please_alarms;
DROP TRIGGER IF EXISTS iot_project.update_date_please_devices;
DROP TRIGGER IF EXISTS iot_project.update_date_please_logs;
DROP TRIGGER IF EXISTS iot_project.update_date_please_notifications;
DROP TRIGGER IF EXISTS iot_project.update_date_please_users;

DELIMITER //
CREATE TRIGGER iot_project.update_date_please_alarms
BEFORE UPDATE ON iot_project.alarms
FOR EACH ROW
SET NEW.update_date = NOW();
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER iot_project.update_date_please_devices
BEFORE UPDATE ON iot_project.devices
FOR EACH ROW
SET NEW.update_date = NOW();
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER iot_project.update_date_please_logs
BEFORE UPDATE ON iot_project.logs
FOR EACH ROW
SET NEW.update_date = NOW();
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER iot_project.update_date_please_notifications
BEFORE UPDATE ON iot_project.notifications 
FOR EACH ROW
SET NEW.update_date = NOW();
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER iot_project.update_date_please_users
BEFORE UPDATE ON iot_project.users 
FOR EACH ROW
SET NEW.update_date = NOW();
//
DELIMITER ;

-- Events for dropping expired logs

DROP EVENT IF EXISTS iot_project.drop_expired_logs;
CREATE EVENT IF NOT EXISTS iot_project.drop_expired_logs ON SCHEDULE EVERY 1 DAY STARTS NOW() DO DELETE FROM iot_project.logs l  WHERE l.insert_date < DATE_SUB(NOW(), INTERVAL 7 DAY) AND l.log_type ="temp";

-- Events for deactivating devices and sending alarms

DROP EVENT IF EXISTS iot_project.deactivate_device;
DELIMITER //

CREATE EVENT IF NOT EXISTS iot_project.deactivate_device
ON SCHEDULE EVERY 30 SECOND
STARTS NOW()
DO
BEGIN
	UPDATE iot_project.devices d
	SET d.active = 0
	WHERE d.update_date < DATE_SUB(NOW(), INTERVAL 30 SECOND) AND d.update_date > DATE_SUB(NOW(), INTERVAL 60 SECOND);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS iot_project.droper;
DROP TRIGGER IF EXISTS iot_project.before_update_device;
DROP EVENT IF EXISTS iot_project.alarm_expiration;

DELIMITER //
CREATE PROCEDURE iot_project.droper()
       BEGIN
         INSERT INTO iot_project.alarms (alarm_status, alarm_message, id_device, id_user)
	SELECT
		'active' AS alarm_status,
		CONCAT('Utracono aktywność urządzenia o ID ', d.id_device) AS alarm_message,
		d.id_device  AS id_device,
		u.id_user  AS id_user
	FROM
		iot_project.users u
	JOIN
		iot_project.devices d ON JSON_CONTAINS(u.user_devices, CAST(d.id_device  AS JSON), '$') = 1
	WHERE
		d.active = 1 AND d.update_date < DATE_SUB(NOW(), INTERVAL 30 SECOND) AND d.update_date > DATE_SUB(NOW(), INTERVAL 60 SECOND);
       END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER iot_project.before_update_device
BEFORE UPDATE
ON iot_project.devices FOR EACH ROW
BEGIN
    IF NEW.active = 0 THEN
        CALL iot_project.droper();
    END IF;
END //
DELIMITER ;

-- Events for alarm expiration

DELIMITER //

CREATE EVENT IF NOT EXISTS iot_project.alarm_expiration
ON SCHEDULE EVERY 30 MINUTE  
STARTS NOW()
DO
BEGIN
	UPDATE iot_project.alarms a
	SET a.alarm_status = IF(a.alarm_status = "active", "expired", a.alarm_status)
	WHERE a.update_date < DATE_SUB(NOW(), INTERVAL 1 DAY);
END //
DELIMITER ;

-- Events for generating notifications

DROP EVENT IF EXISTS iot_project.alarm_summary_daily_notification;
DROP EVENT IF EXISTS iot_project.alarm_summary_weekly_notification;
DROP EVENT IF EXISTS iot_project.alarm_summary_monthly_notification;

DELIMITER //
CREATE EVENT IF NOT EXISTS iot_project.alarm_summary_daily_notification
ON SCHEDULE EVERY 1 DAY STARTS NOW()
DO
BEGIN
    -- Zlicz alarmy dla każdego użytkownika w danym dniu
    INSERT INTO iot_project.notifications (
        notification_type,
        alarm_summary_type,
        notification_content,
        id_user
    )
    SELECT
        'info',
        'daily',
        CONCAT('Liczba alarmów w dniu ', CURDATE(), ': ', COUNT(a.id_alarm)),
        u.id_user
    FROM
        iot_project.users u
    LEFT JOIN
        iot_project.alarms a ON u.id_user = a.id_user AND DATE(a.insert_date) = CURDATE()
    GROUP BY
        u.id_user;
END;
//
DELIMITER ;

DELIMITER //
CREATE EVENT IF NOT EXISTS iot_project.alarm_summary_weekly_notification
ON SCHEDULE EVERY 1 WEEK
DO
BEGIN
    -- Zlicz alarmy dla każdego użytkownika w danym tygodniu
    INSERT INTO iot_project.notifications (
        notification_type,
        alarm_summary_type,
        notification_content,
        id_user
    )
    SELECT
        'info',
        'weekly',
        CONCAT('Liczba alarmów w tygodniu ', YEARWEEK(CURDATE()), ' : ', COUNT(a.id_alarm)),
        u.id_user
    FROM
        iot_project.users u
    LEFT JOIN
        iot_project.alarms a ON u.id_user = a.id_user AND YEARWEEK(a.insert_date) = YEARWEEK(CURDATE())
    GROUP BY
        u.id_user;
END;
//
DELIMITER ;

DELIMITER //
CREATE EVENT IF NOT EXISTS iot_project.alarm_summary_monthly_notification
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
    -- Zlicz alarmy dla każdego użytkownika w danym miesiącu
    INSERT INTO iot_project.notifications (
        notification_type,
        alarm_summary_type,
        notification_content,
        id_user
    )
    SELECT
        'info',
        'monthly',
        CONCAT('Liczba alarmów w miesiącu ', DATE_FORMAT(CURDATE(), '%Y-%m'), ': ', COUNT(a.id_alarm)),
        u.id_user
    FROM
        iot_project.users u
    LEFT JOIN
        iot_project.alarms a ON u.id_user = a.id_user AND MONTH(a.insert_date) = MONTH(CURDATE()) AND YEAR(a.insert_date) = YEAR(CURDATE())
    GROUP BY
        u.id_user;
END;
//
DELIMITER ;






