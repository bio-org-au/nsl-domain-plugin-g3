-- An audit history is important on most tables. Provide an audit trigger that logs to
-- a dedicated audit table for the major relations.
--
-- This file should be generic and not depend on application roles or structures,
-- as it's being listed here:
--
--    https://wiki.postgresql.org/wiki/Audit_trigger_91plus
--
-- This trigger was originally based on
--   http://wiki.postgresql.org/wiki/Audit_trigger
-- but has been completely rewritten.
--
-- Should really be converted into a relocatable EXTENSION, with control and upgrade files.

CREATE EXTENSION IF NOT EXISTS hstore;

CREATE SCHEMA if NOT EXISTS audit;

drop table if exists audit.logged_actions cascade;

REVOKE ALL ON SCHEMA audit FROM public;

COMMENT ON SCHEMA audit IS 'Out-of-table audit/history logging tables and trigger functions';

--
-- Audited data. Lots of information is available, it's just a matter of how much
-- you really want to record. See:
--
--   http://www.postgresql.org/docs/9.1/static/functions-info.html
--
-- Remember, every column you add takes up more audit table space and slows audit
-- inserts.
--
-- Every index you add has a big impact too, so avoid adding indexes to the
-- audit table unless you REALLY need them. The hstore GIST indexes are
-- particularly expensive.
--
-- It is sometimes worth copying the audit table, or a coarse subset of it that
-- you're interested in, into a temporary table where you CREATE any useful
-- indexes and do your analysis.
--
CREATE TABLE audit.logged_actions (
  event_id bigserial primary key,
  schema_name text not null,
  table_name text not null,
  relid oid not null,
  session_user_name text,
  action_tstamp_tx TIMESTAMP WITH TIME ZONE NOT NULL,
  action_tstamp_stm TIMESTAMP WITH TIME ZONE NOT NULL,
  action_tstamp_clk TIMESTAMP WITH TIME ZONE NOT NULL,
  transaction_id bigint,
  application_name text,
  client_addr inet,
  client_port integer,
  client_query text,
  action TEXT NOT NULL CHECK (action IN ('I','D','U', 'T')),
  row_data hstore,
  changed_fields hstore,
  statement_only boolean not null,
  id int8
);

REVOKE ALL ON audit.logged_actions FROM public;

COMMENT ON TABLE audit.logged_actions IS 'History of auditable actions on audited tables, from audit.if_modified_func()';
COMMENT ON COLUMN audit.logged_actions.event_id IS 'Unique identifier for each auditable event';
COMMENT ON COLUMN audit.logged_actions.schema_name IS 'Database schema audited table for this event is in';
COMMENT ON COLUMN audit.logged_actions.table_name IS 'Non-schema-qualified table name of table event occured in';
COMMENT ON COLUMN audit.logged_actions.relid IS 'Table OID. Changes with drop/create. Get with ''tablename''::regclass';
COMMENT ON COLUMN audit.logged_actions.session_user_name IS 'Login / session user whose statement caused the audited event';
COMMENT ON COLUMN audit.logged_actions.action_tstamp_tx IS 'Transaction start timestamp for tx in which audited event occurred';
COMMENT ON COLUMN audit.logged_actions.action_tstamp_stm IS 'Statement start timestamp for tx in which audited event occurred';
COMMENT ON COLUMN audit.logged_actions.action_tstamp_clk IS 'Wall clock time at which audited event''s trigger call occurred';
COMMENT ON COLUMN audit.logged_actions.transaction_id IS 'Identifier of transaction that made the change. May wrap, but unique paired with action_tstamp_tx.';
COMMENT ON COLUMN audit.logged_actions.client_addr IS 'IP address of client that issued query. Null for unix domain socket.';
COMMENT ON COLUMN audit.logged_actions.client_port IS 'Remote peer IP port address of client that issued query. Undefined for unix socket.';
COMMENT ON COLUMN audit.logged_actions.client_query IS 'Top-level query that caused this auditable event. May be more than one statement.';
COMMENT ON COLUMN audit.logged_actions.application_name IS 'Application name set when this audit event occurred. Can be changed in-session by client.';
COMMENT ON COLUMN audit.logged_actions.action IS 'Action type; I = insert, D = delete, U = update, T = truncate';
COMMENT ON COLUMN audit.logged_actions.row_data IS 'Record value. Null for statement-level trigger. For INSERT this is the new tuple. For DELETE and UPDATE it is the old tuple.';
COMMENT ON COLUMN audit.logged_actions.changed_fields IS 'New values of fields changed by UPDATE. Null except for row-level UPDATE events.';
COMMENT ON COLUMN audit.logged_actions.statement_only IS '''t'' if audit event is from an FOR EACH STATEMENT trigger, ''f'' for FOR EACH ROW';

CREATE INDEX logged_actions_relid_idx ON audit.logged_actions(relid);
CREATE INDEX logged_actions_action_tstamp_tx_idx ON audit.logged_actions using btree(action_tstamp_tx);
CREATE INDEX logged_actions_action_idx ON audit.logged_actions(action);
CREATE INDEX logged_actions_id_idx ON audit.logged_actions(id);

CREATE OR REPLACE FUNCTION audit.if_modified_func() RETURNS TRIGGER AS $body$
DECLARE
    audit_row audit.logged_actions;
    excluded_cols text[] = ARRAY[]::text[];
    included_cols text[];
    xtra_cols text[];
    monitored_fields hstore;
BEGIN
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as an AFTER trigger';
    END IF;
    audit_row = ROW(
        nextval('audit.logged_actions_event_id_seq'), -- event_id
        TG_TABLE_SCHEMA::text,                        -- schema_name
        TG_TABLE_NAME::text,                          -- table_name
        TG_RELID,                                     -- relation OID for much quicker searches
                session_user::text,                           -- session_user_name
                current_timestamp,                            -- action_tstamp_tx
        statement_timestamp(),                        -- action_tstamp_stm
        clock_timestamp(),                            -- action_tstamp_clk
        txid_current(),                               -- transaction ID
        current_setting('application_name'),          -- client application
        inet_client_addr(),                           -- client_addr
        inet_client_port(),                           -- client_port
        current_query(),                              -- top-level query or queries (if multistatement) from client
        substring(TG_OP,1,1),                         -- action
        NULL, NULL,                                   -- row_data, changed_fields
        'f',                                           -- statement_only
        NULL                                        -- id of tuple
        );

    IF NOT TG_ARGV[0]::boolean IS DISTINCT FROM 'f'::boolean THEN
        audit_row.client_query = NULL;
    END IF;

    IF TG_LEVEL = 'ROW' THEN
        IF TG_ARGV[1] = 'i' THEN
            included_cols = TG_ARGV[2]::text[];
        ELSIF TG_ARGV[1] = 'e' THEN
            excluded_cols = TG_ARGV[2]::text[];
        END IF;
        xtra_cols = TG_ARGV[3]::text[];
        IF TG_OP = 'UPDATE' THEN
            audit_row.row_data = hstore(OLD.*);
            monitored_fields = (slice(hstore(NEW.*),included_cols) - audit_row.row_data) - excluded_cols;
            audit_row.changed_fields = monitored_fields || slice(hstore(NEW.*),xtra_cols);
            IF monitored_fields = hstore('') THEN
                -- All changed fields are ignored. Skip this update.
                RETURN NULL;
            END IF;
        ELSIF TG_OP = 'DELETE' THEN
            audit_row.row_data = (slice(hstore(OLD.*),included_cols) - excluded_cols) || slice(hstore(OLD.*),xtra_cols);
        ELSIF TG_OP = 'INSERT' THEN
            audit_row.row_data = (slice(hstore(NEW.*),included_cols) - excluded_cols) || slice(hstore(NEW.*),xtra_cols);
        END IF;
    ELSIF (TG_LEVEL = 'STATEMENT' AND TG_OP IN ('INSERT','UPDATE','DELETE','TRUNCATE')) THEN
        audit_row.statement_only = 't';
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
    INSERT INTO audit.logged_actions VALUES (audit_row.*);
    RETURN NULL;
END;
$body$
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = pg_catalog, public;

COMMENT ON FUNCTION audit.if_modified_func() IS $body$
Track changes to a table at the statement and/or row level.

Optional parameters to trigger in CREATE TRIGGER call:

param 0: boolean, whether to log the query text. Default 't'.

param 1: text[], columns to ignore in updates. Default [].

         Updates to ignored cols are omitted from changed_fields.

         Updates with only ignored cols changed are not inserted
         into the audit log.

         Almost all the processing work is still done for updates
         that ignored. If you need to save the load, you need to use
         WHEN clause on the trigger instead.

         No warning or error is issued if ignored_cols contains columns
         that do not exist in the target table. This lets you specify
         a standard set of ignored columns.

There is no parameter to disable logging of values. Add this trigger as
a 'FOR EACH STATEMENT' rather than 'FOR EACH ROW' trigger if you do not
want to log row values.

Note that the user name logged is the login role for the session. The audit trigger
cannot obtain the active role because it is reset by the SECURITY DEFINER invocation
of the audit trigger its self.
$body$;



CREATE OR REPLACE FUNCTION audit.if_modified_tree_element() RETURNS TRIGGER AS $body$
DECLARE
    audit_row audit.logged_actions;
    excluded_cols text[] = ARRAY[]::text[];
    included_cols text[];
    xtra_cols text[];
    monitored_fields hstore;
    old_distribution text;
    old_comment text;
    new_distribution text;
    new_comment text;
    updated_at text;
    updated_by text;
    tree record;
BEGIN
    select * from tree into tree;
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as an AFTER trigger';
    END IF;
    audit_row = ROW(
        nextval('audit.logged_actions_event_id_seq'), -- event_id
        TG_TABLE_SCHEMA::text,                        -- schema_name
        TG_TABLE_NAME::text,                          -- table_name
        TG_RELID,                                     -- relation OID for much quicker searches
                session_user::text,                           -- session_user_name
                current_timestamp,                            -- action_tstamp_tx
        statement_timestamp(),                        -- action_tstamp_stm
        clock_timestamp(),                            -- action_tstamp_clk
        txid_current(),                               -- transaction ID
        current_setting('application_name'),          -- client application
        inet_client_addr(),                           -- client_addr
        inet_client_port(),                           -- client_port
        current_query(),                              -- top-level query or queries (if multistatement) from client
        substring(TG_OP,1,1),                         -- action
        NULL, NULL,                                   -- row_data, changed_fields
        'f',                                           -- statement_only
        NULL                                        -- id of tuple
        );

    IF NOT TG_ARGV[0]::boolean IS DISTINCT FROM 'f'::boolean THEN
        audit_row.client_query = NULL;
    END IF;

    IF TG_LEVEL = 'ROW' THEN
        IF TG_ARGV[1] = 'i' THEN
            included_cols = TG_ARGV[2]::text[];
        ELSIF TG_ARGV[1] = 'e' THEN
            excluded_cols = TG_ARGV[2]::text[];
        END IF;
        xtra_cols = TG_ARGV[3]::text[];
        IF TG_OP = 'UPDATE' THEN
            audit_row.row_data = hstore(OLD.*);
            monitored_fields = (slice(hstore(NEW.*),included_cols) - audit_row.row_data) - excluded_cols;
            new_distribution = NEW.profile -> (tree.config ->> 'distribution_key') ->> 'value';
            new_comment = NEW.profile -> (tree.config ->> 'comment_key') ->> 'value';
            old_distribution = OLD.profile -> (tree.config ->> 'distribution_key') ->> 'value';
            old_comment = OLD.profile -> (tree.config ->> 'comment_key') ->> 'value';
            IF old_distribution <> new_distribution or old_distribution is null or new_distribution is null THEN
                updated_at = NEW.profile -> (tree.config ->> 'distribution_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = NEW.profile -> (tree.config ->> 'distribution_key') ->> 'updated_by';
                audit_row.changed_fields = hstore(ARRAY['id', NEW.id::text, 'distribution', new_distribution, 'updated_at', updated_at, 'updated_by', updated_by]);
                updated_at = OLD.profile -> (tree.config ->> 'distribution_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = OLD.profile -> (tree.config ->> 'distribution_key') ->> 'updated_by';
                audit_row.row_data = hstore(ARRAY['id', OLD.id::text, 'distribution', old_distribution, 'updated_at', updated_at, 'updated_by', updated_by]);
                INSERT INTO audit.logged_actions VALUES (audit_row.*);
            END IF;
            IF old_comment <> new_comment or old_comment is null or new_comment is null THEN
                audit_row.event_id = nextval('audit.logged_actions_event_id_seq');
                updated_at = NEW.profile -> (tree.config ->> 'comment_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = NEW.profile -> (tree.config ->> 'comment_key') ->> 'updated_by';
                audit_row.changed_fields = hstore(ARRAY['id', NEW.id::text, 'comment', new_comment, 'updated_at', updated_at, 'updated_by', updated_by]);
                updated_at = OLD.profile -> (tree.config ->> 'comment_key') ->> 'updated_at';
                updated_at = REPLACE(updated_at, 'T', ' ');
                updated_by = OLD.profile -> (tree.config ->> 'comment_key') ->> 'updated_by';
                audit_row.row_data = hstore(ARRAY['id', OLD.id::text, 'comment', old_comment, 'updated_at', updated_at, 'updated_by', updated_by]);
                INSERT INTO audit.logged_actions VALUES (audit_row.*);
            END IF;
        ELSIF TG_OP = 'DELETE' THEN
        ELSIF TG_OP = 'INSERT' THEN
        END IF;
    ELSIF (TG_LEVEL = 'STATEMENT' AND TG_OP IN ('INSERT','UPDATE','DELETE','TRUNCATE')) THEN
        audit_row.statement_only = 't';
        INSERT INTO audit.logged_actions VALUES (audit_row.*);
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
    RETURN NULL;
END;
$body$
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = pg_catalog, public;

COMMENT ON FUNCTION apni.audit.if_modified_tree_element() IS $body$
Track changes to tree_element at the statement and/or row level.
$body$;

CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, column_style text, cols text[], xtra_cols text[], audit_func text) RETURNS void AS $body$
DECLARE
    stm_targets text = 'INSERT OR UPDATE OR DELETE OR TRUNCATE';
    _q_txt text;
    _cols_snip text = '';
    _xtra_cols_snip text = '';
    _style text = '';
BEGIN

    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_row ON ' || target_table;
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_stm ON ' || target_table;
    IF audit_func IS NULL THEN
        audit_func = 'audit.if_modified_func';
    END IF;
    IF audit_rows THEN
        IF array_length(cols,1) > 0 THEN
            _cols_snip = ', ' || quote_literal(cols);
        END IF;
        IF array_length(xtra_cols,1) > 0 THEN
            _xtra_cols_snip = ', ' || quote_literal(xtra_cols);
        END IF;
        IF column_style IS NOT NULL THEN
            _style = ', ' || column_style;
        END IF;
        _q_txt = 'CREATE TRIGGER audit_trigger_row AFTER INSERT OR UPDATE OR DELETE ON ' ||
                 target_table ||
                 ' FOR EACH ROW EXECUTE PROCEDURE ' || audit_func || '(' ||
                 quote_literal(audit_query_text) || _style || _cols_snip || _xtra_cols_snip || ');';
        RAISE NOTICE '%',_q_txt;
        EXECUTE _q_txt;
        stm_targets = 'TRUNCATE';
    END IF;

    _q_txt = 'CREATE TRIGGER audit_trigger_stm AFTER ' || stm_targets || ' ON ' ||
             target_table ||
             ' FOR EACH STATEMENT EXECUTE PROCEDURE ' || audit_func || '('||
             quote_literal(audit_query_text) || ');';
    RAISE NOTICE '%',_q_txt;
    EXECUTE _q_txt;
END;
$body$
    language 'plpgsql';

COMMENT ON FUNCTION audit.audit_table(regclass, boolean, boolean, text[]) IS $body$
Add auditing support to a table.

Arguments:
   target_table:     Table name, schema qualified if not on search_path
   audit_rows:       Record each row change, or only audit at a statement level
   audit_query_text: Record the text of the client query that triggered the audit event?
   ignored_cols:     Columns to exclude from update diffs, ignore updates that change only ignored cols.
$body$;

-- Pg doesn't allow variadic calls with 0 params, so provide a wrapper
CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean) RETURNS void AS $body$
SELECT audit.audit_table($1, $2, $3, NULL, ARRAY[]::text[]);
$body$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, column_style text, cols text[], xtra_cols text[]) RETURNS void AS $body$
SELECT audit.audit_table($1, $2, $3, $4, $5, $6, 'audit.if_modified_func');
$body$ LANGUAGE SQL;

-- And provide a convenience call wrapper for the simplest case
-- of row-level logging with no excluded cols and query logging enabled.
--
CREATE OR REPLACE FUNCTION audit.audit_table(target_table regclass) RETURNS void AS $$
SELECT audit.audit_table($1, BOOLEAN 't', BOOLEAN 't');
$$ LANGUAGE 'sql';

COMMENT ON FUNCTION audit.audit_table(regclass) IS $body$
Add auditing support to the given table. Row-level changes will be logged with full client query text. No cols are ignored.
$body$;

-- set up triggers using the following selects after import
-- select * from information_schema.triggers;
--
-- select audit.audit_table('author');
-- select audit.audit_table('instance');
select audit.audit_table('author', 't', 't', 'i',
                         ARRAY['id', 'abbrev', 'duplicate_of_id', 'full_name', 'name', 'notes', 'ipni_id', 'valid_record']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('reference', 't', 't', 'i',
                         ARRAY['id', 'bhl_url', 'doi', 'duplicate_of_id', 'edition', 'isbn', 'iso_publication_date', 'issn',
                             'language_id', 'notes', 'pages', 'parent_id', 'publication_date', 'published', 'published_location',
                             'publisher', 'ref_author_role_id', 'ref_type_id', 'title', 'volume', 'year', 'tl2', 'valid_record',
                             'verbatim_author', 'verbatim_citation', 'verbatim_reference']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('name', 't', 't', 'i',
                         ARRAY['id', 'author_id', 'base_author_id', 'duplicate_of_id', 'ex_author_id', 'ex_base_author_id', 'family_id',
                             'full_name', 'name_rank_id', 'name_status_id', 'name_type_id', 'parent_id', 'sanctioning_author_id',
                             'second_parent_id', 'verbatim_name_string', 'orth_var', 'changed_combination',
                             'valid_record', 'published_year']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('comment', 't', 't', 'i',
                         ARRAY['id', 'author_id', 'name_id', 'reference_id', 'instance_id', 'text']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('instance', 't', 't', 'i',
                         ARRAY['id', 'bhl_url', 'cites_id', 'cited_by_id', 'draft', 'instance_type_id', 'name_id',
                             'page', 'page_qualifier', 'parent_id', 'reference_id',
                             'verbatim_name_string', 'nomenclatural_status', 'valid_record']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('instance_note', 't', 't', 'i',
                         ARRAY['id', 'instance_note_key_id', 'value']::text[],
                         ARRAY['created_at', 'created_by', 'updated_at', 'updated_by']::text[]);

select audit.audit_table('public.tree_element', 't', 't', 'i', ARRAY['id']::text[],
                         ARRAY[]::text[], 'audit.if_modified_tree_element');
