--
-- Basic tests
--

-- Create a replication slot
SELECT slot_name FROM pg_create_logical_replication_slot('custom_slot', 'decoder_raw');

-- DEFAULT case with PRIMARY KEY
CREATE TABLE aa (a int primary key, b text NOT NULL);
INSERT INTO aa VALUES (1, 'aa'), (2, 'bb');
-- Update of Non-selective column
UPDATE aa SET b = 'cc' WHERE a = 1;
-- Update of only selective column
UPDATE aa SET a = 3 WHERE a = 1;
-- Update of both columns
UPDATE aa SET a = 4, b = 'dd' WHERE a = 2;
DELETE FROM aa WHERE a = 4;
-- Have a look at changes with different modes.
-- In the second call changes are consumed to not impact the next cases.
SELECT data FROM pg_logical_slot_peek_changes('custom_slot', NULL, NULL, 'include_transaction', 'off');
SELECT data FROM pg_logical_slot_get_changes('custom_slot', NULL, NULL, 'include_transaction', 'on');
DROP TABLE aa;

-- DEFAULT case without PRIMARY KEY
CREATE TABLE aa (a int, b text NOT NULL);
INSERT INTO aa VALUES (1, 'aa'), (2, 'bb');
-- Update of Non-selective column
UPDATE aa SET b = 'cc' WHERE a = 1;
-- Update of only selective column
UPDATE aa SET a = 3 WHERE a = 1;
-- Update of both columns
UPDATE aa SET a = 4, b = 'dd' WHERE a = 2;
DELETE FROM aa WHERE a = 4;
-- Have a look at changes with different modes.
-- In the second call changes are consumed to not impact the next cases.
SELECT data FROM pg_logical_slot_peek_changes('custom_slot', NULL, NULL, 'include_transaction', 'off');
SELECT data FROM pg_logical_slot_get_changes('custom_slot', NULL, NULL, 'include_transaction', 'on');
DROP TABLE aa;

-- INDEX case
CREATE TABLE aa (a int NOT NULL, b text);
CREATE UNIQUE INDEX aai ON aa(a);
ALTER TABLE aa REPLICA IDENTITY USING INDEX aai;
INSERT INTO aa VALUES (1, 'aa'), (2, 'bb');
-- Update of Non-selective column
UPDATE aa SET b = 'cc' WHERE a = 1;
-- Update of only selective column
UPDATE aa SET a = 3 WHERE a = 1;
-- Update of both columns
UPDATE aa SET a = 4, b = 'dd' WHERE a = 2;
DELETE FROM aa WHERE a = 4;
-- Have a look at changes with different modes
SELECT data FROM pg_logical_slot_peek_changes('custom_slot', NULL, NULL, 'include_transaction', 'off');
SELECT data FROM pg_logical_slot_get_changes('custom_slot', NULL, NULL, 'include_transaction', 'on');
DROP TABLE aa;

-- FULL case
CREATE TABLE aa (a int primary key, b text NOT NULL);
ALTER TABLE aa REPLICA IDENTITY FULL;
INSERT INTO aa VALUES (1, 'aa'), (2, 'bb');
-- Update of Non-selective column
UPDATE aa SET b = 'cc' WHERE a = 1;
-- Update of only selective column
UPDATE aa SET a = 3 WHERE a = 1;
-- Update of both columns
UPDATE aa SET a = 4, b = 'dd' WHERE a = 2;
DELETE FROM aa WHERE a = 4;
-- Have a look at changes with different modes
SELECT data FROM pg_logical_slot_peek_changes('custom_slot', NULL, NULL, 'include_transaction', 'off');
SELECT data FROM pg_logical_slot_get_changes('custom_slot', NULL, NULL, 'include_transaction', 'on');
DROP TABLE aa;

-- NOTHING case
CREATE TABLE aa (a int primary key, b text NOT NULL);
ALTER TABLE aa REPLICA IDENTITY NOTHING;
INSERT INTO aa VALUES (1, 'aa'), (2, 'bb');
UPDATE aa SET b = 'cc' WHERE a = 1;
UPDATE aa SET a = 3 WHERE a = 1;
DELETE FROM aa WHERE a = 4;
-- Have a look at changes with different modes
SELECT data FROM pg_logical_slot_peek_changes('custom_slot', NULL, NULL, 'include_transaction', 'off');
SELECT data FROM pg_logical_slot_get_changes('custom_slot', NULL, NULL, 'include_transaction', 'on');
DROP TABLE aa;

-- Drop replication slot
SELECT pg_drop_replication_slot('custom_slot');
