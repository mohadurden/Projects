-- =========================================
-- 1. DROP EXISTING OBJECTS (Optional)
-- =========================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ALERTS CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE MARKS CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ATTENDANCE CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE STUDENTS CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE COURSES CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE STUDENTS_SEQ';
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE ALERTS_SEQ';
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =========================================
-- 2. CREATE TABLES
-- =========================================
CREATE TABLE COURSES (
    COURSE_ID   VARCHAR2(10) PRIMARY KEY,
    COURSE_NAME VARCHAR2(50),
    PROFESSOR   VARCHAR2(30)
);

CREATE TABLE STUDENTS (
    STUDENT_ID NUMBER PRIMARY KEY,
    FIRST_NAME VARCHAR2(30),
    LAST_NAME  VARCHAR2(30),
    DOB        DATE,
    COURSE_ID  VARCHAR2(10),
    CONSTRAINT FK_STUDENT_COURSE FOREIGN KEY (COURSE_ID) REFERENCES COURSES(COURSE_ID)
);

CREATE TABLE MARKS (
    STUDENT_ID NUMBER,
    COURSE_ID  VARCHAR2(10),
    QUIZ_SCORE NUMBER(5,2),
    EXAM_SCORE NUMBER(5,2),
    FINAL_GRADE NUMBER(5,2),
    CONSTRAINT PK_MARKS PRIMARY KEY (STUDENT_ID, COURSE_ID),
    CONSTRAINT FK_MARKS_STUDENT FOREIGN KEY (STUDENT_ID) REFERENCES STUDENTS(STUDENT_ID),
    CONSTRAINT FK_MARKS_COURSE FOREIGN KEY (COURSE_ID) REFERENCES COURSES(COURSE_ID)
);

CREATE TABLE ATTENDANCE (
    STUDENT_ID NUMBER,
    COURSE_ID  VARCHAR2(10),
    ATTENDANCE_DATE DATE,
    PRESENT CHAR(1),
    CONSTRAINT PK_ATTENDANCE PRIMARY KEY (STUDENT_ID, COURSE_ID, ATTENDANCE_DATE),
    CONSTRAINT FK_ATTENDANCE_STUDENT FOREIGN KEY (STUDENT_ID) REFERENCES STUDENTS(STUDENT_ID),
    CONSTRAINT FK_ATTENDANCE_COURSE FOREIGN KEY (COURSE_ID) REFERENCES COURSES(COURSE_ID)
);

CREATE TABLE ALERTS (
    ALERT_ID NUMBER PRIMARY KEY,
    STUDENT_ID NUMBER,
    COURSE_ID VARCHAR2(10),
    ALERT_MESSAGE VARCHAR2(100),
    CREATED_ON DATE,
    CONSTRAINT FK_ALERT_STUDENT FOREIGN KEY (STUDENT_ID) REFERENCES STUDENTS(STUDENT_ID),
    CONSTRAINT FK_ALERT_COURSE FOREIGN KEY (COURSE_ID) REFERENCES COURSES(COURSE_ID)
);

-- =========================================
-- 3. CREATE SEQUENCES
-- =========================================
CREATE SEQUENCE STUDENTS_SEQ START WITH 2023114 INCREMENT BY 1;
CREATE SEQUENCE ALERTS_SEQ START WITH 4 INCREMENT BY 1;

-- =========================================
-- 4. CREATE TRIGGERS
-- =========================================
CREATE OR REPLACE TRIGGER trg_marks_final
BEFORE INSERT OR UPDATE ON MARKS
FOR EACH ROW
BEGIN
    :NEW.FINAL_GRADE := NVL(:NEW.QUIZ_SCORE,0) + NVL(:NEW.EXAM_SCORE,0);
END;
/

-- =========================================
-- 5. CREATE PACKAGE
-- =========================================
CREATE OR REPLACE PACKAGE student_pkg IS
    PROCEDURE add_student(
        p_student_id IN STUDENTS.STUDENT_ID%TYPE DEFAULT NULL,
        p_first_name IN STUDENTS.FIRST_NAME%TYPE,
        p_last_name  IN STUDENTS.LAST_NAME%TYPE,
        p_dob        IN STUDENTS.DOB%TYPE,
        p_course_id  IN STUDENTS.COURSE_ID%TYPE
    );

    PROCEDURE update_student(
        p_student_id IN STUDENTS.STUDENT_ID%TYPE,
        p_first_name IN STUDENTS.FIRST_NAME%TYPE,
        p_last_name  IN STUDENTS.LAST_NAME%TYPE,
        p_dob        IN STUDENTS.DOB%TYPE,
        p_course_id  IN STUDENTS.COURSE_ID%TYPE
    );

    PROCEDURE delete_student(p_student_id IN STUDENTS.STUDENT_ID%TYPE);

    PROCEDURE add_alert(
        p_student_id IN ALERTS.STUDENT_ID%TYPE,
        p_course_id  IN ALERTS.COURSE_ID%TYPE,
        p_message    IN ALERTS.ALERT_MESSAGE%TYPE
    );

    FUNCTION get_avg_marks(p_student_id IN NUMBER, p_course_id IN COURSES.COURSE_ID%TYPE) RETURN NUMBER;
    FUNCTION attendance_percentage(p_student_id IN NUMBER, p_course_id IN COURSES.COURSE_ID%TYPE) RETURN NUMBER;
END student_pkg;
/

CREATE OR REPLACE PACKAGE BODY student_pkg IS
    PROCEDURE add_student(
        p_student_id IN STUDENTS.STUDENT_ID%TYPE DEFAULT NULL,
        p_first_name IN STUDENTS.FIRST_NAME%TYPE,
        p_last_name  IN STUDENTS.LAST_NAME%TYPE,
        p_dob        IN STUDENTS.DOB%TYPE,
        p_course_id  IN STUDENTS.COURSE_ID%TYPE
    ) IS
    BEGIN
        INSERT INTO STUDENTS (STUDENT_ID, FIRST_NAME, LAST_NAME, DOB, COURSE_ID)
        VALUES (NVL(p_student_id, STUDENTS_SEQ.NEXTVAL), p_first_name, p_last_name, p_dob, p_course_id);
    END add_student;

    PROCEDURE update_student(
        p_student_id IN STUDENTS.STUDENT_ID%TYPE,
        p_first_name IN STUDENTS.FIRST_NAME%TYPE,
        p_last_name  IN STUDENTS.LAST_NAME%TYPE,
        p_dob        IN STUDENTS.DOB%TYPE,
        p_course_id  IN STUDENTS.COURSE_ID%TYPE
    ) IS
    BEGIN
        UPDATE STUDENTS
        SET FIRST_NAME = p_first_name,
            LAST_NAME  = p_last_name,
            DOB        = p_dob,
            COURSE_ID  = p_course_id
        WHERE STUDENT_ID = p_student_id;
    END update_student;

    PROCEDURE delete_student(p_student_id IN STUDENTS.STUDENT_ID%TYPE) IS
    BEGIN
        DELETE FROM ATTENDANCE WHERE STUDENT_ID = p_student_id;
        DELETE FROM MARKS WHERE STUDENT_ID = p_student_id;
        DELETE FROM ALERTS WHERE STUDENT_ID = p_student_id;
        DELETE FROM STUDENTS WHERE STUDENT_ID = p_student_id;
    END delete_student;

    PROCEDURE add_alert(
        p_student_id IN ALERTS.STUDENT_ID%TYPE,
        p_course_id  IN ALERTS.COURSE_ID%TYPE,
        p_message    IN ALERTS.ALERT_MESSAGE%TYPE
    ) IS
    BEGIN
        INSERT INTO ALERTS (ALERT_ID, STUDENT_ID, COURSE_ID, ALERT_MESSAGE, CREATED_ON)
        VALUES (ALERTS_SEQ.NEXTVAL, p_student_id, p_course_id, p_message, SYSDATE);
    END add_alert;

    FUNCTION get_avg_marks(p_student_id IN NUMBER, p_course_id IN COURSES.COURSE_ID%TYPE) RETURN NUMBER IS
        v_avg NUMBER;
    BEGIN
        SELECT AVG(FINAL_GRADE) INTO v_avg
        FROM MARKS
        WHERE STUDENT_ID = p_student_id AND COURSE_ID = p_course_id;
        RETURN NVL(v_avg,0);
    END get_avg_marks;

    FUNCTION attendance_percentage(p_student_id IN NUMBER, p_course_id IN COURSES.COURSE_ID%TYPE) RETURN NUMBER IS
        v_total NUMBER;
        v_present NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total
        FROM ATTENDANCE
        WHERE STUDENT_ID = p_student_id AND COURSE_ID = p_course_id;

        SELECT COUNT(*) INTO v_present
        FROM ATTENDANCE
        WHERE STUDENT_ID = p_student_id AND COURSE_ID = p_course_id AND PRESENT = 'Y';

        IF v_total = 0 THEN
            RETURN 0;
        ELSE
            RETURN (v_present / v_total) * 100;
        END IF;
    END attendance_percentage;
END student_pkg;
/

-- =========================================
-- 6. INSERT SAMPLE DATA
-- =========================================
-- Courses
INSERT INTO COURSES VALUES ('CS101','Computer Science 101','Dr. Issa');
INSERT INTO COURSES VALUES ('CS102','Data Structures','Dr. Ayman');
INSERT INTO COURSES VALUES ('DB2','Databases','Dr. Wafaa');
INSERT INTO COURSES VALUES ('ALG1','Algorithms','Dr. Marwa');
INSERT INTO COURSES VALUES ('ML01','Machine Learning','Dr. Amjad');

-- Students
EXEC student_pkg.add_student(NULL,'Mohammad','Al-Yousef',TO_DATE('2004-07-31','YYYY-MM-DD'),'CS101');
EXEC student_pkg.add_student(NULL,'Ibrahim','Ahmad',TO_DATE('2003-05-20','YYYY-MM-DD'),'DB2');
EXEC student_pkg.add_student(NULL,'Abood','Mommani',TO_DATE('2005-02-15','YYYY-MM-DD'),'CS101');
EXEC student_pkg.add_student(NULL,'Mousa','Omar',TO_DATE('2004-12-01','YYYY-MM-DD'),'ALG1');
EXEC student_pkg.add_student(NULL,'Tala','Al-Yousef',TO_DATE('2005-01-30','YYYY-MM-DD'),'ML01');
EXEC student_pkg.add_student(NULL,'Osama','Ali',TO_DATE('2005-09-19','YYYY-MM-DD'),'CS102');

-- Marks
INSERT INTO MARKS VALUES (1,'ML01',30,45,NULL);
INSERT INTO MARKS VALUES (2022,'DB2',30,70,NULL);
INSERT INTO MARKS VALUES (1,'DB2',22,33,NULL);
INSERT INTO MARKS VALUES (2023111,'CS101',28,65,NULL);
INSERT INTO MARKS VALUES (3,'CS101',30,70,NULL);
INSERT INTO MARKS VALUES (55,'ML01',27,66,NULL);
INSERT INTO MARKS VALUES (2023113,'CS102',25,60,NULL);

-- Attendance
INSERT INTO ATTENDANCE VALUES (1,'CS101',SYSDATE,'Y');
INSERT INTO ATTENDANCE VALUES (2022,'DB2',SYSDATE,'Y');
INSERT INTO ATTENDANCE VALUES (2023111,'CS101',SYSDATE,'N');
INSERT INTO ATTENDANCE VALUES (3,'ALG1',SYSDATE,'Y');
INSERT INTO ATTENDANCE VALUES (55,'ML01',SYSDATE,'Y');
INSERT INTO ATTENDANCE VALUES (2023113,'CS102',SYSDATE,'Y');

-- Alerts
EXEC student_pkg.add_alert(2023111,'CS101','Low attendance warning!');
EXEC student_pkg.add_alert(55,'ML01','Excellent participation!');
EXEC student_pkg.add_alert(2023113,'CS102','Welcome to Data Structures!');

COMMIT;
