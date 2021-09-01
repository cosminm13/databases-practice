set serveroutput on;

-- view
create or replace view catalog as
select s.nume, s.prenume, c.titlu_curs, n.valoare from note n join studenti s on s.id=n.id_student join cursuri c on c.id=n.id_curs;

select * from studenti;

-- insert
create or replace trigger insert_catalog
instead of insert
on catalog
for each row
declare
    v_exista_student NUMBER(38,0);
    v_exista_curs NUMBER(38,0);
    v_random_id_student NUMBER(38,0);
    v_random_id_curs NUMBER(38,0);
    v_random_nr_matricol NUMBER(38,0);
    v_random_id_nota NUMBER(38,0);
begin 
--    select count(*) into v_exista_student from studenti where studenti.nume = :NEW.nume and studenti.prenume = :NEW.prenume;
--    select count(*) into v_exista_curs from cursuri where cursuri.titlu_curs = :NEW.titlu_curs;

    v_random_id_curs:=dbms_random.value(10000,99999);
    v_random_id_student:=dbms_random.value(10000,99999);
    v_random_nr_matricol:=dbms_random.value(10000,99999);
    v_random_id_nota:=dbms_random.value(10000,99999);
    
    insert into studenti(id, nr_matricol, nume, prenume) values(v_random_id_student, v_random_nr_matricol, :NEW.nume, :NEW.prenume);
    insert into cursuri(id, titlu_curs) values(v_random_id_curs, :NEW.titlu_curs);
    insert into note(id, id_student, id_curs, valoare) values(v_random_id_nota, v_random_id_student, v_random_id_curs, :NEW.valoare);
end;


-- delete
create or replace trigger delete_catalog
instead of delete
on catalog
for each row
declare
    v_id_curs NUMBER(38, 0);
    v_id_student NUMBER(38, 0);
begin
    select id into v_id_curs from cursuri where titlu_curs=:NEW.titlu_curs;
    select id into v_id_student from studenti where nume=:NEW.nume and prenume=:NEW.prenume;
    
    if :NEW.titlu_curs is not null then
        delete from note where id_curs=v_id_curs;
        delete from cursuri where titlu_curs=:NEW.titlu_curs;
    end if;
    
    if :NEW.nume is not null then
        delete from studenti where nume=:NEW.nume and prenume=:NEW.prenume;
        delete from note where id_student=v_id_student;
    end if;
end;


-- update
create or replace trigger update_catalog
instead of update
on catalog
for each row
declare
    v_id_student NUMBER(38, 0);
    v_id_curs NUMBER(38, 0);
begin
    select id into v_id_student from studenti where nume=:OLD.nume and prenume=:OLD.prenume;
    select id into v_id_curs from cursuri where titlu_curs=:OLD.titlu_curs;
    
    update note set valoare=:NEW.valoare, updated_at=sysdate where id_curs=v_id_curs and id_student=v_id_student and valoare<:NEW.valoare;
end;


-------------------
-- testing triggers
select * from catalog order by 1, 2;


-- update
update catalog set valoare=10 where nume='Adascalitei' and titlu_curs='Baze de date';
select * from note where id_student=307; --id_curs=10


-- insert
insert into catalog (nume, prenume, titlu_curs, valoare) values ('Aaaa', 'Bbbb', 'Materie de test', 10);
declare
    v_id_std_inserat NUMBER;
begin
    select id into v_id_std_inserat from studenti where nume='Aaaa';
    dbms_output.put_line(v_id_std_inserat);
end;


-- delete
delete from catalog where nume='Aaaa' and prenume='Bbbb' and titlu_curs='Materie de test' and valoare=10;