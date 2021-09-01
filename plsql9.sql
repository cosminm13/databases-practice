set serveroutput on;

create or replace procedure catalog_materie(id_materie in NUMBER) as
    v_cursor_id NUMBER;
    v_cursor_id2 NUMBER;
    v_cursor_id3 NUMBER;
    v_cursor_id4 NUMBER;
    v_ok INTEGER;
    v_ok2 INTEGER;
    v_ok3 INTEGER;
    v_ok4 INTEGER;
    
    v_valoare NUMBER(2,0);
    v_data_notare DATE;
    v_nume VARCHAR2(15);
    v_prenume VARCHAR2(30);
    v_nr_matricol VARCHAR2(6);
    
    v_nume_materie VARCHAR2(40);
begin
    v_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor_id, 'select n.valoare, n.data_notare, s.nume, s.prenume, s.nr_matricol 
        from note n join cursuri c on n.id_curs=c.id
            join studenti s on n.id_student=s.id
                where c.id='||id_materie, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_valoare);
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 2, v_data_notare);
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 3, v_nume, 15);
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 4, v_prenume, 30);
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 5, v_nr_matricol, 6);
    v_ok := DBMS_SQL.EXECUTE(v_cursor_id);
    
    v_cursor_id2 := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor_id2, 'select titlu_curs from cursuri where id='||id_materie, DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id2, 1, v_nume_materie, 40);
    v_ok2 := DBMS_SQL.EXECUTE(v_cursor_id2);
    
    if DBMS_SQL.FETCH_ROWS(v_cursor_id2)>0 then 
        DBMS_SQL.COLUMN_VALUE(v_cursor_id2, 1, v_nume_materie);
--        DBMS_OUTPUT.PUT_LINE(v_nume_materie);
        
        v_nume_materie := replace(v_nume_materie, ' ', '');
        
        v_cursor_id3 := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_cursor_id3, 'create table ' || v_nume_materie || '(valoare NUMBER(2,0), data_notare DATE, nume VARCHAR2(15), prenume VARCHAR2(30), nr_matricol VARCHAR2(6) primary key)', DBMS_SQL.NATIVE);
        v_ok3 := DBMS_SQL.EXECUTE(v_cursor_id3);
    end if;
    
    v_cursor_id4 := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_cursor_id4, 
        'insert into ' || v_nume_materie || 
        ' values (:v_valoare_bind, :v_data_notare_bind, :v_nume_bind, :v_prenume_bind, :v_nr_matricol_bind)', DBMS_SQL.NATIVE);
    
    loop
        if DBMS_SQL.FETCH_ROWS(v_cursor_id)>0 then 
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_valoare);
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 2, v_data_notare);
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 3, v_nume);
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 4, v_prenume);
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 5, v_nr_matricol);
 
--            DBMS_OUTPUT.PUT_LINE(v_valoare || '   ' || v_data_notare || '    ' || v_nume || '    ' || v_prenume || '    ' || v_nr_matricol);            
                
            DBMS_SQL.BIND_VARIABLE(v_cursor_id4, ':v_valoare_bind', v_valoare);
            DBMS_SQL.BIND_VARIABLE(v_cursor_id4, ':v_data_notare_bind', v_data_notare);
            DBMS_SQL.BIND_VARIABLE(v_cursor_id4, ':v_nume_bind', v_nume);
            DBMS_SQL.BIND_VARIABLE(v_cursor_id4, ':v_prenume_bind', v_prenume);
            DBMS_SQL.BIND_VARIABLE(v_cursor_id4, ':v_nr_matricol_bind', v_nr_matricol);
            
            v_ok4 := DBMS_SQL.EXECUTE(v_cursor_id4);
        else
            exit; 
        end if;
    end loop;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
end;
/

begin
    catalog_materie(2);
end;
/
-- fara exception handling pentru tabel existent
select * from "MATEMATICÃ";
/
drop table "MATEMATICÃ";