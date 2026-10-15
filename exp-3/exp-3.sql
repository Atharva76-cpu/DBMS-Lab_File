-- EXPERIMENT 3
-- Employee-Department-Project relational database and basic SQL queries.
-- MySQL: run this setup section once in a fresh environment.

CREATE DATABASE CompanyDB;
USE CompanyDB;

-- 1. Department table: stores the five departments.
CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

-- 2. Project table: each project is associated with a department.
CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- 3. Employee table: each employee references a department and project.
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    project_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

-- Insert five departments.
INSERT INTO Department VALUES
(1, 'Engineering'),
(2, 'Human Resources'),
(3, 'Finance'),
(4, 'Sales'),
(5, 'Logistics');

-- Insert eight projects.
INSERT INTO Project VALUES
(101, 'E-Commerce Platform', 175000, 1),
(102, 'Cyber Security System', 225000, 1),
(103, 'Employee Management', 95000, 2),
(104, 'Budget Automation', 130000, 3),
(105, 'Sales Optimization', 110000, 4),
(106, 'Warehouse Management', 190000, 5),
(107, 'Customer Mobile App', 155000, 1),
(108, 'Training Management', 70000, 2);

-- Insert 30 employees.
INSERT INTO Employee VALUES
(1, 'Aryan', 68000, '2022-02-14', 1, 101),
(2, 'Vihaan', 76000, '2021-05-18', 1, 102),
(3, 'Krish', 59000, '2023-07-22', 1, 107),
(4, 'Raghav', 85000, '2020-09-16', 1, 101),
(5, 'Shaurya', 71000, '2022-12-08', 1, 102),
(6, 'Ivaan', 64000, '2024-03-12', 1, 107),
(7, 'Ritika', 55000, '2022-05-19', 2, 103),
(8, 'Nisha', 50000, '2023-02-26', 2, 108),
(9, 'Kavya', 63000, '2021-08-23', 2, 103),
(10, 'Pihu', 57000, '2022-10-11', 2, 108),
(11, 'Aditi', 49000, '2024-04-17', 2, 103),
(12, 'Simran', 61000, '2020-12-15', 2, 108),
(13, 'Varun', 78000, '2021-03-21', 3, 104),
(14, 'Mohit', 70000, '2022-06-13', 3, 104),
(15, 'Harsh', 88000, '2019-11-24', 3, 104),
(16, 'Akash', 65000, '2023-09-18', 3, 104),
(17, 'Rahul', 74000, '2021-12-05', 3, 104),
(18, 'Ankit', 58000, '2024-02-10', 3, 104),
(19, 'Sneha', 56000, '2022-03-29', 4, 105),
(20, 'Isha', 67000, '2021-07-20', 4, 105),
(21, 'Neha', 59000, '2023-05-14', 4, 105),
(22, 'Shreya', 69000, '2020-10-12', 4, 105),
(23, 'Mahi', 53000, '2024-03-01', 4, 105),
(24, 'Jhanvi', 73000, '2022-12-27', 4, 105),
(25, 'Kunal', 62000, '2021-02-16', 5, 106),
(26, 'Aman', 75000, '2020-05-28', 5, 106),
(27, 'Ritesh', 69000, '2022-08-21', 5, 106),
(28, 'Siddharth', 61000, '2023-06-03', 5, 106),
(29, 'Varun', 79000, '2019-09-15', 5, 106),
(30, 'Manish', 66000, '2024-02-22', 5, 106);

-- QUERY 1: Selection
-- Return complete employee records for salaries greater than 70,000.
SELECT *
FROM Employee
WHERE salary > 70000;

-- QUERY 2: Projection
-- Return only employee names and salaries, rather than every column.
SELECT emp_name, salary
FROM Employee;

-- QUERY 3: Aggregate functions
-- Calculate the employee count, average/highest/lowest salary, and salary total.
SELECT
    COUNT(*) AS total_employees,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary,
    SUM(salary) AS total_salary
FROM Employee;

-- QUERY 4: GROUP BY
-- Calculate employee count and average salary separately for each department.
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- QUERY 5: HAVING
-- Keep only departments whose average salary is greater than 65,000.
SELECT
    d.dept_name,
    AVG(e.salary) AS average_salary
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 65000;

-- QUERY 6: CASE expression
-- Assign a salary label to every employee according to the specified ranges.
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary >= 75000 THEN 'High Salary'
        WHEN salary >= 60000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM Employee;

-- QUERY 7: ORDER BY
-- List employees from highest salary to lowest salary.
SELECT emp_name, salary
FROM Employee
ORDER BY salary DESC;

-- QUERY 8: Three-table JOIN
-- Combine employee, department, and project details in one result.
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
JOIN Project p ON e.project_id = p.project_id
ORDER BY d.dept_name, e.emp_name;
