set serveroutput on;

ALTER TABLE note ADD CONSTRAINT unique_val UNIQUE (id_student, id_curs);

-----------------------------------------------------------------------------------------

DROP FUNCTION inserare_nota_cu_verificare;

CREATE OR REPLACE FUNCTION inserare_nota_cu_verificare(pi_id_student IN studenti.id%type)
RETURN INTEGER
AS 
    mesaj VARCHAR2(100);
    counter INTEGER := 0;
    iteratii INTEGER := 0;
    nr_inserari INTEGER := 0;
BEGIN
    WHILE (iteratii < 1000000) LOOP
        SELECT COUNT(*) into counter from note WHERE id_student=pi_id_student AND id_curs=1;
        IF counter = 0 THEN
            INSERT INTO note(id_student, id_curs, valoare) VALUES(pi_id_student, 1, 10);
            nr_inserari := nr_inserari + 1;
        END IF;
        iteratii := iteratii + 1;
    END LOOP;
    return nr_inserari;
END inserare_nota_cu_verificare;

-----------------------------------------------------------------------------------------

DROP FUNCTION inserare_nota_cu_exceptie;

CREATE OR REPLACE FUNCTION inserare_nota_cu_exceptie(pi_id_student IN studenti.id%type)
RETURN INTEGER
AS 
    mesaj VARCHAR2(100);
    counter INTEGER := 0;
    iteratii INTEGER := 0;
    nr_inserari INTEGER := 0;
    inserare_imposibila EXCEPTION;
    PRAGMA EXCEPTION_INIT (inserare_imposibila, -20001);
BEGIN
    WHILE (iteratii < 1000000) LOOP
        SELECT COUNT(*) into counter from note WHERE id_student=pi_id_student AND id_curs=1;
        IF counter != 0 THEN
            return nr_inserari;
            raise inserare_imposibila;
        ELSE
            INSERT INTO note(id_student, id_curs, valoare) VALUES(pi_id_student, 1, 10);
            nr_inserari := nr_inserari + 1;
        END IF;
        iteratii := iteratii + 1;
    END LOOP;
    return nr_inserari;
EXCEPTION
WHEN inserare_imposibila THEN
    null;
END;


select inserare_nota_cu_verificare(1) from dual; -- 6.592 secunde

DECLARE
    iter INTEGER := 0;
    r INTEGER;
BEGIN
    WHILE (iter < 1000000) LOOP
        select inserare_nota_cu_exceptie(1) into r from dual; -- 0.003 secunde
        iter := iter + 1;
    END LOOP;
END; -- 19.896 secunde
-----------------------------------------------------------------------------------------

DROP FUNCTION verificare_medie;

CREATE OR REPLACE FUNCTION verificare_medie(v_nume studenti.nume%TYPE, v_prenume studenti.prenume%TYPE)
RETURN NUMBER
AS
    medie NUMBER;
    id_stud studenti.id%TYPE;
    student_inexistent EXCEPTION;
    PRAGMA EXCEPTION_INIT(student_inexistent, -20002);
BEGIN
    SELECT id INTO id_stud FROM studenti WHERE nume=v_nume and prenume=v_prenume;
    IF id_stud = 0 THEN
        raise student_inexistent;
    END IF;
    SELECT AVG(valoare) INTO medie FROM note WHERE id_student=id_stud;
return medie;
EXCEPTION
WHEN student_inexistent THEN
  raise_application_error (-20002,'Studentul cu numele ' || v_nume || ' ' || v_prenume || ' nu exista in baza de date.');
  return 0;
END;

-----------------------------------------------------------------------------------------

DECLARE
    m NUMBER;
    
    TYPE lista_studenti_rec is RECORD (
    nume studenti.nume%TYPE,
    prenume studenti.prenume%TYPE
    );
    
    TYPE lista_studenti_v is VARRAY(10) OF lista_studenti_rec;
    
    lista lista_studenti_v;
BEGIN
--    select verificare_medie('Gherca', 'Irinel') into m from dual;
    lista := lista_studenti_v(null);
    lista.EXTEND(6);
    lista(1).nume := 'Gherca';
    lista(1).prenume := 'Irinel';
    lista(2).nume := 'Cristea';
    lista(2).prenume := 'Alina';
    lista(3).nume := 'Chelmu';
    lista(3).prenume := 'Dragos';
    lista(4).nume := 'abcde';
    lista(4).prenume := 'abcde';
    lista(5).nume := 'abcdef';
    lista(5).prenume := 'abcdef';
    lista(6).nume := 'abcdefg';
    lista(6).prenume := 'abcfefg';
    FOR s in lista.first..lista.last LOOP
        select verificare_medie(lista(s).nume, lista(s).prenume) into m from dual;
        DBMS_OUTPUT.PUT_LINE(m);
    END LOOP;
END;