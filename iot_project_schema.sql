-- schemas and previlages
DROP SCHEMA IF EXISTS iot_project;
CREATE SCHEMA iot_project;

-- tables
create table if not exists iot_project.users(
	id_user SERIAL primary key,
	
	user_name varchar(30),
	user_password varchar(300),
	active boolean default false,
	user_devices varchar(50),
	
	insert_date timestamp DEFAULT current_timestamp,
	update_date timestamp DEFAULT current_timestamp
);

create table if not exists iot_project.devices(
	id_device SERIAL primary key,
	
	device_name varchar(20),
	device_desc varchar(50),
	serial_number varchar(100),
	device_type ENUM('camera', 'motion_sensor', 'vibrate_sensor', 'battery_sensor', 'other'),
	
	active boolean default false,
	location varchar(50),
	device_password varchar(300),
	device_attributes varchar(300),
	
	insert_date timestamp DEFAULT current_timestamp,
	update_date timestamp DEFAULT current_timestamp
);

create table if not exists iot_project.notifications(
	id_notification SERIAL primary key,
	
	notification_type ENUM('critical', 'warning', 'error', 'info'),
	alarm_summary_type ENUM('monthly','weekly','daily','na'),
	
	notification_content varchar(500),
	is_confirmed boolean default false,
	
	insert_date timestamp DEFAULT current_timestamp,
	update_date timestamp DEFAULT current_timestamp,
	
	id_user BIGINT UNSIGNED,
	foreign key (id_user) references iot_project.users(id_user)
);

create table if not exists iot_project.alarms(
	id_alarm SERIAL primary key,
	
	alarm_status ENUM('active', 'surpressed', 'archived', 'expired'),
	alarm_correctness boolean default true,
	alarm_message varchar(500),
	
	insert_date timestamp DEFAULT current_timestamp,
	update_date timestamp DEFAULT current_timestamp,
	
	id_device BIGINT UNSIGNED,
	id_user BIGINT UNSIGNED,
	
	foreign key (id_device) references iot_project.devices(id_device),
	foreign key (id_user) references iot_project.users(id_user)
);

create table if not exists iot_project.logs(
	id_log SERIAL primary key,
	
	log_type ENUM('critical', 'warning', 'error', 'info', 'temp') default 'temp',
	log_content varchar(600),
	
	insert_date timestamp DEFAULT current_timestamp,
	update_date timestamp DEFAULT current_timestamp,
	
	id_device BIGINT UNSIGNED,
	foreign key (id_device) references iot_project.devices(id_device)
);
