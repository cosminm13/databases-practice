set serveroutput on;

drop type studenti_bursieri;
/
drop table bursieri;
/

create or replace type studenti_bursieri as object
(id_student NUMBER(38, 0),
nume_student VARCHAR2(15),
prenume_student VARCHAR2(15),
bursa NUMBER(6, 2),
constructor function studenti_bursieri(id_student NUMBER, nume_student VARCHAR2, prenume_student VARCHAR2, bursa NUMBER)
    return self as result,
constructor function studenti_bursieri
    return self as result,
member procedure afiseaza_student,
NOT FINAL member procedure schimba_bursa (v_bursa NUMBER),
map member function get_bursa return NUMBER
) NOT FINAL;
/
create or replace type body studenti_bursieri as
    constructor function studenti_bursieri(id_student NUMBER, nume_student VARCHAR2, prenume_student VARCHAR2, bursa NUMBER)
        return self as result
        as
        begin
            self.id_student:=id_student;
            self.nume_student:=nume_student;
            self.prenume_student:=prenume_student;
            self.bursa:=bursa;
        return;
    end;
    
    constructor function studenti_bursieri
        return self as result
        as
        begin
            self.id_student:=0;
            self.nume_student:='';
            self.prenume_student:='';
            self.bursa:=0;
        return;
    end;
    
    member procedure afiseaza_student is
    begin
        dbms_output.put_line('(' || id_student || ', ' || nume_student || ', ' || prenume_student || ', ' || bursa || ')');
    end afiseaza_student;
    
    member procedure schimba_bursa(v_bursa NUMBER) is
    begin
        bursa:=v_bursa;
    end schimba_bursa;
    
    map member function get_bursa return NUMBER is
    begin
        return self.bursa;
    end;
end;
/
drop table bursieri;
/
create table bursieri(
    id NUMBER,
    student studenti_bursieri
);
/  

declare
    v_student1 studenti_bursieri;
    v_student2 studenti_bursieri;
    v_student3 studenti_bursieri;
begin
    v_student1 := studenti_bursieri(1, 'Nume1', 'Prenume1', 100);
    v_student2 := studenti_bursieri(2, 'Nume2', 'Prenume2', 200);
    v_student3 := studenti_bursieri(3, 'Nume3', 'Prenume3', 300);
    
    v_student1.afiseaza_student();
    v_student2.schimba_bursa(250);
    
    if(v_student1 > v_student2) then
        dbms_output.put_line('Primul student are bursa mai mare!');
     else
        dbms_output.put_line('Al doilea student are bursa mai mare!');
    end if;
    
    insert into bursieri (id, student) values (1, v_student1);
    insert into bursieri (id, student) values (2, v_student2);
    insert into bursieri (id, student) values (3, v_student3);
end;
/
select * from bursieri order by 2 desc;
/


drop type studenti_bursieri_subclasa;
/

create or replace type studenti_bursieri_subclasa under studenti_bursieri(
overriding member procedure schimba_bursa(v_bursa NUMBER)
);
/
create or replace type body studenti_bursieri_subclasa as
    overriding member procedure schimba_bursa(v_bursa NUMBER) is
    begin
        bursa:=bursa-v_bursa;
    end schimba_bursa;
end;
/

declare
    v_student4 studenti_bursieri_subclasa;
begin
    v_student4 := studenti_bursieri_subclasa(4, 'Nume4', 'Prenume4', 400);
    v_student4.afiseaza_student();
    v_student4.schimba_bursa(100);
    v_student4.afiseaza_student();
end;