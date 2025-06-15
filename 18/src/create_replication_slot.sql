-- Check needed GUC for Physical Replication
SELECT name, setting FROM pg_settings WHERE name=ANY(ARRAY['wal_level', 'max_wal_senders']);

-- Create or replace replication slot
DROP FUNCTION IF EXISTS create_my_replication_slot;
CREATE FUNCTION create_my_replication_slot()
    RETURNS void AS $$
DECLARE
    slot_exists boolean := EXISTS(SELECT 1 FROM pg_replication_slots WHERE slot_name='replica');
BEGIN
    IF slot_exists THEN
        PERFORM pg_drop_replication_slot('replica');
    END IF;
    PERFORM pg_create_physical_replication_slot('replica');
END;
$$ LANGUAGE plpgsql;

SELECT create_my_replication_slot();

-- Check created replication slot
SELECT slot_name, slot_type, restart_lsn, wal_status FROM pg_replication_slots WHERE slot_name='replica';