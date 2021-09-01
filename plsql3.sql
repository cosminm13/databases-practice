DROP PACKAGE gcd;
DROP PACKAGE BODY gcd;

CREATE OR REPLACE PACKAGE gcd IS
     PROCEDURE CMMDC (x INTEGER, y INTEGER);
     PROCEDURE CMMMC (x INTEGER, y INTEGER);
END gcd;

CREATE OR REPLACE PACKAGE BODY gcd IS
    PROCEDURE CMMDC (x INTEGER, y INTEGER) IS 
    num1 INTEGER;  
    num2 INTEGER;  
    t    INTEGER;
    BEGIN
    num1 := x;  
    num2 := y;  
    WHILE MOD(num2, num1) != 0 LOOP  
        t := MOD(num2, num1);  
  
        num2 := num1;  
  
        num1 := t;  
    END LOOP;  
    dbms_output.Put_line('CMMDC intre numerele '||x||' si '||y||' este '||num1);
    END CMMDC;
    
    PROCEDURE CMMMC (x INTEGER, y INTEGER) IS 
    num1 INTEGER;  
    num2 INTEGER;  
    t    INTEGER;
    res  INTEGER;
    BEGIN
    num1 := x;  
    num2 := y;  
    WHILE MOD(num2, num1) != 0 LOOP  
        t := MOD(num2, num1);  
  
        num2 := num1;  
  
        num1 := t;  
    END LOOP;
    res := (x * y)/num1;
    dbms_output.Put_line('CMMMC intre numerele '||x||' si '||y||' este '||res);
    END CMMMC;
END gcd;

set serveroutput on;
GRANT EXECUTE on gcd to sys;
declare
    begin
    gcd.CMMDC(24,32);
    gcd.CMMMC(24,32);
end;