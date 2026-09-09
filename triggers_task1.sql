CREATE TABLE employee(
    empid INT PRIMARY KEY,
    ename VARCHAR(50),
    designation VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2)
);
CREATE TABLE employee_history(
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(200),
    created_on DATETIME
);
CREATE TABLE salary_log(
    id INT AUTO_INCREMENT PRIMARY KEY,
    empid INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    updated_on DATETIME
);
CREATE TABLE employee_backup(
    empid INT,
    ename VARCHAR(50),
    designation VARCHAR(50),
    email VARCHAR(100),
    salary DECIMAL(10,2),
    deleted_on DATETIME
);
use trigger_;

-- 1. Create a **BEFORE INSERT** trigger to prevent inserting an employee with a negative salary.
delimiter @@
create trigger negitive_sal
before insert
on employee
for each row
begin
if new.salary<0 then
signal sqlstate '45000'
set message_text='salary should not be negitive';
end if;
end @@
delimiter ;
insert into employee1 values(101,'mallika','manager','mallika@gmail.com',-900);
insert into employee1 values(101,'mallika','manager','mallika@gmail.com',900);



-- 2. Create a **BEFORE INSERT** trigger to automatically set the salary to **₹15,000** if it is entered as **NULL**.
delimiter !!
create trigger automatic_sal
before insert
on employee
for each row
begin
if new.salary is null then
set new.salary=15000;
end if;
end !!
delimiter ;
insert into employee values(101,'mallika','manager','mallika@gmail.com',null);
select * from employee;

-- 3. Create a **BEFORE INSERT** trigger to change the salary to **₹10,000** if the entered salary is less than **₹10,000**.

DELIMITER //
CREATE TRIGGER update_low_salary
BEFORE INSERT
ON employee
FOR EACH ROW
BEGIN
IF NEW.salary < 10000 THEN
SET NEW.salary = 10000;
END IF;
END //
DELIMITER ;
insert into employee values(102,'mallika','manager','malli@gmail.com',2000);
select * from employee;

-- 4. Create an **AFTER INSERT** trigger to store a message like **"Employee <Employee_Name> Added Successfully"** 
-- along with the current date and time in the `employee_history` table whenever a new employee is added.
DELIMITER $$
CREATE TRIGGER employee_after_insert
after INSERT
ON employee
FOR EACH ROW
BEGIN
insert into  employee_history(message,created_on) values(concat('employee', new.ename, 'added succesfully'),now());
end $$
delimiter ;
insert into employee values(103,'rama','developer','rama@gmail.com',25000);
select * from employee_history;


-- 5. Create an **AFTER UPDATE** trigger to store **Employee ID, Old Salary, New Salary, and Updated Date & Time** 
-- in the `salary_log` table whenever an employee's salary is updated.
delimiter %%
create trigger salary_after_update
after update
on employee
for each row
begin
if old.salary<>new.salary then
insert into salary_log(empid,old_salary,new_salary,updated_on) values(new.empid,old.salary,new.salary,now());
end if;
end%%
delimiter ;
update employee set salary=34000 where empid=101;
select * from salary_log;


-- 6. Create a **BEFORE UPDATE** trigger to prevent reducing an employee's salary. 
-- Display the message **"Salary Cannot Be Reduced"**.
delimiter @@
create trigger salary_before_update
before update
on employee
for each row
begin
if new.salary<old.salary then
signal sqlstate'45000'
set message_text='salary should not be reduced';
end if;
end @@
delimiter ;
update employee set salary=44000 where empid=101;
select * from employee;


-- 7. Create a **BEFORE DELETE** trigger to prevent deleting employees whose designation is **"Manager"**. 
-- Display the message **"Managers Cannot Be Deleted"**.
DELIMITER //

CREATE TRIGGER prevent_manager_delete
BEFORE DELETE
ON employee
FOR EACH ROW
BEGIN
    IF old.empid='101' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Managers Cannot Be Deleted';
    END IF;
END //
DELIMITER ;
delete from employee where empid=101;
select * from employee;


