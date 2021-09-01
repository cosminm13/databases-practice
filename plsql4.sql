DROP TYPE medii_student;
/
CREATE OR REPLACE TYPE medii_student AS TABLE OF NUMBER;
/
ALTER TABLE studenti
  ADD (medii medii_student) NESTED TABLE medii STORE AS lista;
/
CREATE OR REPLACE PACKAGE medii_semestriale IS
    TYPE input_unit IS RECORD(v_stud_id NUMBER);
    TYPE my_input_type IS TABLE OF input_unit;
    PROCEDURE get_medii(v_studs IN my_input_type);
END medii_semestriale;
/
CREATE OR REPLACE PACKAGE BODY medii_semestriale IS
    PROCEDURE get_medii(v_studs IN my_input_type) AS
        v_id NUMBER;
        v_medii medii_student;
        v_counter NUMBER;
    BEGIN
        for i in v_studs.first..v_studs.last loop
            if(v_studs(i).v_stud_id IS NOT NULL) THEN
                SELECT s.id, AVG(n.valoare) INTO v_id, v_medii FROM note n JOIN cursuri c ON n.id_curs=c.id JOIN studenti s ON s.id=n.id_student WHERE n.id_student=v_studs(i).v_stud_id GROUP BY c.an, c.semestru, s.id;
            
                if(v_medii IS NULL) THEN
                    DBMS_OUTPUT.PUT_LINE('IS NULL');
                    v_medii:=medii_student();
                end if;
                
                UPDATE studenti SET medii=v_medii WHERE id=v_studs(i).v_stud_id;
            end if;
        end loop;
    END get_medii;
END medii_semestriale;
/

CREATE OR REPLACE PROCEDURE get_count (id_stud studenti.id%type) AS
v_count INTEGER;
BEGIN
    select count(medii) into v_count from studenti where id=id_stud;
        DBMS_OUTPUT.PUT_LINE(v_count);
END get_count;
/
BEGIN
	get_count(1);
END;