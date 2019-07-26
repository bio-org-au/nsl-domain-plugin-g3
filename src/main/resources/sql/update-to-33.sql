alter table reference drop column if exists iso_publication_date;

alter table reference add column iso_publication_date varchar(10);

drop function if exists is_iso8601(varchar);
create or replace function is_iso8601(isoString varchar) returns boolean as $$
DECLARE match boolean;
begin
    match := isoString ~ '^[1,2][0-9]{3}$' or
             isoString ~ '^[1,2][0-9]{3}-(01|02|03|04|05|06|07|08|09|10|11|12)$';
    if match then
        return true;
    end if;
    perform isoString::TIMESTAMP;
    return true;
exception when others then
    return false;
end;
$$ language plpgsql;

alter table reference add constraint check_iso_date check(is_iso8601(iso_publication_date));

update reference set iso_publication_date = year::text where year is not null;

-- version
UPDATE db_version
SET version = 33
WHERE id = 1;
