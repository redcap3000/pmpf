CREATE TABLE mp_groups(
  usergroup SERIAL PRIMARY KEY,
  group_title varchar(255) NOT NULL,
  group_alias varchar(255) NOT NULL,
  group_level INTEGER NOT NULL
);
-- so we can have a default value... cant seem to select a null integer column to filter them in/out
INSERT INTO mp_groups (group_name,usergroup,group_level) VALUES 
('System Administrators','SystemGOD',1),
('Module Administrators','ModulesGOD',2),
('Guests','ViewPublished',100),
('Banned users','ViewPublished',101),
('Normal User','normal',4),
('employees','employees',4);


CREATE table mp_versions(
	v_id serial PRIMARY KEY,
	r_id integer,
	v_table varchar(512) NOT NULL,
	v_dat text[1][128],
	v_time timestamp DEFAULT localtimestamp
);
-- make an array whose first value is an identifier and second value is independent of that?

CREATE TABLE mp_options(
 o_id serial,
 b_options text[]
 );
 
CREATE TABLE mp_selects(
 select_id serial,
 master_select text
) inherits (mp_options);


CREATE TABLE mp_content(
 c_id serial,
 b_content text
 ) inherits (mp_selects);


-- give default usergroup of 'Guests' or level 100 ...
CREATE TABLE mp_blocks(
  id SERIAL PRIMARY KEY,
  usergroup integer REFERENCES mp_groups default 3,
  block_name varchar(255) NOT NULL,
  urls VARCHAR(512) NOT NULL,
  block_type block_types,
  block_order SMALLINT,
  status statuses DEFAULT 'active'
  ) inherits (mp_content);
  -- ideally should make something to generate this, or a function so
  -- users can easily add new logs 

CREATE TABLE mp_users(
  userid SERIAL PRIMARY KEY,
  username varchar(100) NOT NULL,
  full_name varchar(255)NOT NULL,
  pass_word varchar(100),
  usergroup int NOT NULL,
  email varchar(255)NOT NULL,
  first_ip varchar(45),
  first_login timestamp,
  last_login timestamp,
  logins_number integer,
  randkey varchar(255),
  is_active smallint,
  UNIQUE (username,email)
);

CREATE TABLE mp_sessions(
  session_id SERIAL PRIMARY KEY,
  userid SERIAL REFERENCES mp_users,
  session_start INTEGER,
  last_hit INTEGER,
  user_session varchar(255),
  hits INTEGER,
  last_ip varchar(45)
);

