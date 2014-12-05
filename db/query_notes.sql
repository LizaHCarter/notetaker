create or replace function query_notes (uid integer, lmt integer, ofst integer)
returns table (note_id integer, title varchar, body text, updated_at timestamp, tag_ids integer[], tag_names varchar[]) AS $$
declare
begin

  return query
    select n.id as note_id, n.title, n.body, n.updated_at, array_agg(t.id) as tag_ids, array_agg(t.name) as tag_names
    from notes_tags nt
    inner join notes n on n.id = nt.note_id
    inner join tags t on t.id = nt.tag_id
    where n.user_id = uid
    group by n.id
    order by updated_at desc
    offset ofst
    limit lmt;

end;
$$ language plpgsql;
