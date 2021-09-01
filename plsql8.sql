-- export
create or replace procedure export_csv as
    cursor c_data is
        select id, id_student, id_curs, valoare, data_notare, created_at, updated_at from note order by id;
    
    v_file UTL_FILE.FILE_TYPE;
begin
    v_file := UTL_FILE.FOPEN(location     => 'MYDIR',
                           filename     => 'note_csv.csv',
                           open_mode    => 'w',
                           max_linesize => 32767);
    
    for line in c_data loop
        UTL_FILE.PUT_LINE(v_file,
                            line.id || ',' ||
                            line.id_student || ',' ||
                            line.id_curs || ',' ||
                            line.valoare || ',' ||
                            line.data_notare || ',' ||
                            line.created_at || ',' ||
                            line.updated_at);
    end loop;
    UTL_FILE.FCLOSE(v_file);
    
exception
  when others then
    UTL_FILE.FCLOSE(v_file);
    raise;
end;

CREATE OR REPLACE DIRECTORY MYDIR as 'D:\STUDENT';
exec export_csv;

-- stergere date
delete from note;


-- import
create or replace procedure import_csv as
    v_file UTL_FILE.FILE_TYPE;
    v_line VARCHAR2(500);
    v_id NUMBER(38,0);
    v_id_student NUMBER(38,0);
    v_id_curs NUMBER(38,0);
    v_valoare NUMBER(2,0);
    v_data_notare DATE;
    v_created_at DATE;
    v_updated_at DATE;
begin
    v_file := UTL_FILE.FOPEN('MYDIR', 'note_csv.csv', 'R');
    if UTL_FILE.IS_OPEN(v_file) then
    loop
        begin
            UTL_FILE.GET_LINE(v_file, v_line, 500);
            if v_line is null then
                exit;
            end if;
            v_id := REGEXP_SUBSTR(v_line, '[^,]+', 1, 1);
            v_id_student := REGEXP_SUBSTR(v_line, '[^,]+', 1, 2);
            v_id_curs := REGEXP_SUBSTR(v_line, '[^,]+', 1, 3);
            v_valoare := REGEXP_SUBSTR(v_line, '[^,]+', 1, 4);
            v_data_notare := REGEXP_SUBSTR(v_line, '[^,]+', 1, 5);
            v_created_at := REGEXP_SUBSTR(v_line, '[^,]+', 1, 6);
            v_updated_at := REGEXP_SUBSTR(v_line, '[^,]+', 1, 7);
            
            insert into note values(v_id, v_id_student, v_id_curs, v_valoare, TO_DATE(v_data_notare, 'DD-MON-YYYY'), TO_DATE(v_created_at, 'DD-MON-YYYY'), TO_DATE(v_updated_at, 'DD-MON-YYYY'));
            commit;
            
            exception
                when NO_DATA_FOUND then exit;
        end;
    end loop;
    end if;
    UTL_FILE.FCLOSE(v_file);
end;

exec import_csv;


-- verificare
select * from note order by 1;