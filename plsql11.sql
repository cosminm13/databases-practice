set serveroutput on;

-- am adaugat constraint_type la afisarea constrangerilor
-- am adaugat index_type, column_name la afisarea indecsilor
-- numarul de inregistrari din fiecare tabel este afisat sub denumirea 'rows'
-- am redenumit 'name' in 'table_name'
-- am eliminat obiectele fara nume
-- am adaugat numarul de linii de cod pentru functii/proceduri/triggere


declare
    v_table_name varchar2(20);
    v_num_rows NUMBER;
    v_nested varchar2(10);
    v_constraint_type varchar2(10);
    v_index_column_name varchar2(30);
    v_deterministic varchar2(10);
    cursor list_tables is
        select table_name, num_rows, nested from all_tables where owner='STUDENT';
begin
    open list_tables;
    loop
        fetch list_tables into v_table_name, v_num_rows, v_nested;
        exit when list_tables%notfound;
        dbms_output.put_line('table_name=' || v_table_name || ', rows=' || v_num_rows || ', nested=' || v_nested);
        for constr in (select constraint_name, column_name from user_cons_columns where table_name=v_table_name) loop
            select constraint_type into v_constraint_type from user_constraints where constraint_name=constr.constraint_name;
            dbms_output.put_line('  constraint_name=' || constr.constraint_name || ', constraint_type=' || v_constraint_type || ', constraint_column_name=' || constr.column_name);
        for ind in (select index_name, index_type from user_indexes where table_name=v_table_name) loop
            for c in (select column_name into v_index_column_name from user_ind_columns where index_name=ind.index_name) loop
                dbms_output.put_line('  index_name=' || ind.index_name || ', index_type=' || ind.index_type || ', index_column_name=' || c.column_name);
            end loop;
        end loop;
        end loop;
        dbms_output.put_line('---------------------------------------');
    end loop;
    dbms_output.put_line('---------------------------------------');
    close list_tables;
    
    for fct in (select procedure_name, object_type, deterministic from user_procedures where object_type in ('FUNCTION', 'PROCEDURE', 'TYPE', 'PACKAGE', 'TRIGGER')) loop
        if fct.procedure_name is not null then
            dbms_output.put_line('name=' || fct.procedure_name || ', object_type=' || fct.object_type || ', deterministic=' || fct.deterministic);
        end if;
    end loop;
    for fct in (select name, type, line from user_source where text='end;') loop
        dbms_output.put_line('name=' || fct.name || ', type=' || fct.type || ', lines=' || fct.line);
    end loop;
    dbms_output.put_line('---------------------------------------');
    dbms_output.put_line('---------------------------------------');
    
    for v in (select view_name from user_views) loop
        dbms_output.put_line('view_name=' || v.view_name);
    end loop;
end;