# install postgres
sudo apt-get -y install postgresql

# start postgres on startup
sudo update-rc.d postgresql enable
sudo service postgresql start

# create easytrain database
sudo -u postgres psql -U postgres -c "CREATE DATABASE easytrain;"

sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE payment (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   full_name VARCHAR(255),
   phone_number VARCHAR(255),
   email VARCHAR(255),
   address VARCHAR(255),
   balance DOUBLE PRECISION NOT NULL,
   card_number VARCHAR(255),
   card_holder VARCHAR(255),
   expiry_date VARCHAR(255),
   cvc VARCHAR(255),
   encrypted_data VARCHAR(255),
   CONSTRAINT pk_payment PRIMARY KEY (id)
);"

# create users table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE users (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   title VARCHAR(255),
   first_name VARCHAR(255) NOT NULL,
   last_name VARCHAR(255) NOT NULL,
   age INTEGER NOT NULL,
   email VARCHAR(255) NOT NULL,
   phone_number VARCHAR(255),
   password VARCHAR(255) NOT NULL,
   enabled BOOLEAN,
   verification_code VARCHAR(64),
   street_name VARCHAR(255),
   street_number VARCHAR(255),
   city VARCHAR(255),
   postal_code VARCHAR(255),
   CONSTRAINT pk_users PRIMARY KEY (id)
);"

# create roles table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE roles (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   name VARCHAR(255),
   user_id BIGINT NOT NULL,
   CONSTRAINT pk_roles PRIMARY KEY (id)
);

ALTER TABLE roles ADD CONSTRAINT FK_ROLES_ON_USER FOREIGN KEY (user_id) REFERENCES users (id);"

# create booking table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE booking (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   to_location VARCHAR(255),
   date date,
   arrival_time time WITHOUT TIME ZONE,
   departure_time time WITHOUT TIME ZONE,
   trains_destination VARCHAR(255),
   journey_details VARCHAR(1000),
   journey_price DOUBLE PRECISION NOT NULL,
   duration DOUBLE PRECISION NOT NULL,
   train_number VARCHAR(255),
   platform_number VARCHAR(255),
   finalized BOOLEAN NOT NULL,
   user_id BIGINT NOT NULL,
   from_location VARCHAR(255) NOT NULL,
   CONSTRAINT pk_booking PRIMARY KEY (id)
);

ALTER TABLE booking ADD CONSTRAINT FK_BOOKING_ON_USER FOREIGN KEY (user_id) REFERENCES users (id);"

# create connections table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE connections (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   connection VARCHAR(255),
   date date,
   time time WITHOUT TIME ZONE,
   booking_id BIGINT NOT NULL,
   CONSTRAINT pk_connections PRIMARY KEY (id)
);

ALTER TABLE connections ADD CONSTRAINT FK_CONNECTIONS_ON_BOOKING FOREIGN KEY (booking_id) REFERENCES booking (id);"

# create tickets table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE tickets (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   gender VARCHAR(20),
   full_name VARCHAR(100),
   to_location VARCHAR(255),
   connection_stop VARCHAR(255),
   carriage_class INTEGER NOT NULL,
   final_price DOUBLE PRECISION NOT NULL,
   under_age BOOLEAN NOT NULL,
   email VARCHAR(255),
   booking_id BIGINT NOT NULL,
   discount DOUBLE PRECISION NOT NULL,
   CONSTRAINT pk_tickets PRIMARY KEY (id)
);

ALTER TABLE tickets ADD CONSTRAINT FK_TICKETS_ON_BOOKING FOREIGN KEY (booking_id) REFERENCES booking (id);"

# create stations table
# sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE stations (
#   id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
#    eva_number VARCHAR(255),
#    station_name VARCHAR(255),
#    station_prefix VARCHAR(255),
#    station_code VARCHAR(255),
#    CONSTRAINT pk_stations PRIMARY KEY (id)
# );"

sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE stations (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   eva_number VARCHAR(255),
   station_name VARCHAR(255),
   station_prefix VARCHAR(255),
   station_code VARCHAR(255),
   CONSTRAINT pk_stations PRIMARY KEY (id)
);"


# create timetable table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE timetable (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   starting_point VARCHAR(255),
   destination VARCHAR(255),
   delay VARCHAR(255),
   estimated_trip_time VARCHAR(255),
   arrival_time VARCHAR(255),
   departure_time VARCHAR(255),
   train_number VARCHAR(255),
   platform_number VARCHAR(255),
   planned_arrival_time VARCHAR(255),
   planned_departure_time VARCHAR(255),
   previous_stations VARCHAR(500),
   next_stations VARCHAR(500),
   current_station VARCHAR(60),
   schedule_id VARCHAR(255),
   station_id BIGINT,
   CONSTRAINT pk_timetable PRIMARY KEY (id)
);

ALTER TABLE timetable ADD CONSTRAINT FK_TIMETABLE_ON_STATION FOREIGN KEY (station_id) REFERENCES stations (id);"

# create ice_stations
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE ice_stations (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   station_name VARCHAR(100),
   CONSTRAINT pk_ice_stations PRIMARY KEY (id)
);"

# create journey_udpates table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE journey_updates (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   schedule_id VARCHAR(255),
   delay VARCHAR(500),
   arrival_time VARCHAR(255),
   departure_time VARCHAR(255),
   changed_path_from VARCHAR(255),
   changed_path_to VARCHAR(255),
   train_number VARCHAR(255),
   platform_number VARCHAR(255),
   CONSTRAINT pk_journey_updates PRIMARY KEY (id)
);"

# create payment table
# required by api-payments
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE payment (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
   full_name VARCHAR(255),
   phone_number VARCHAR(255),
   email VARCHAR(255),
   address VARCHAR(255),
   balance DOUBLE PRECISION NOT NULL,
   card_number VARCHAR(255),
   card_holder VARCHAR(255),
   expiry_date VARCHAR(255),
   cvc VARCHAR(255),
   encrypted_data VARCHAR(255),
   CONSTRAINT pk_payment PRIMARY KEY (id)
);"

# create SPRING_SESSION table
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE SPRING_SESSION (
	PRIMARY_ID CHAR(36) NOT NULL,
	SESSION_ID CHAR(36) NOT NULL,
	CREATION_TIME BIGINT NOT NULL,
	LAST_ACCESS_TIME BIGINT NOT NULL,
	MAX_INACTIVE_INTERVAL INT NOT NULL,
	EXPIRY_TIME BIGINT NOT NULL,
	PRINCIPAL_NAME VARCHAR(100),
	CONSTRAINT SPRING_SESSION_PK PRIMARY KEY (PRIMARY_ID)
);

CREATE UNIQUE INDEX SPRING_SESSION_IX1 ON SPRING_SESSION (SESSION_ID);
CREATE INDEX SPRING_SESSION_IX2 ON SPRING_SESSION (EXPIRY_TIME);
CREATE INDEX SPRING_SESSION_IX3 ON SPRING_SESSION (PRINCIPAL_NAME);"

# create SPRING_SESSION_ATTRIBUTES
sudo -u postgres psql -U postgres -d easytrain -c "CREATE TABLE SPRING_SESSION_ATTRIBUTES (
	SESSION_PRIMARY_ID CHAR(36) NOT NULL,
	ATTRIBUTE_NAME VARCHAR(200) NOT NULL,
	ATTRIBUTE_BYTES BYTEA NOT NULL,
	CONSTRAINT SPRING_SESSION_ATTRIBUTES_PK PRIMARY KEY (SESSION_PRIMARY_ID, ATTRIBUTE_NAME),
	CONSTRAINT SPRING_SESSION_ATTRIBUTES_FK FOREIGN KEY (SESSION_PRIMARY_ID) REFERENCES SPRING_SESSION(PRIMARY_ID) ON DELETE CASCADE
);"

# change postgres superuser password
# spring boot needs password to connect to database
sudo -u postgres psql -U postgres -c "ALTER USER postgres PASSWORD 'postgres';"