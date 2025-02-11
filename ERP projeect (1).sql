CREATE DATABASE erp_system;
USE erp_system;
CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    manager_id INT
);
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department_id INT,
    email VARCHAR(100),
    phone_number VARCHAR(15),
    hire_date DATE,
    job_title VARCHAR(50),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
CREATE TABLE Financials (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    department_id INT,
    description VARCHAR(255),
    transaction_type ENUM('Credit', 'Debit') NOT NULL,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    supplier_id INT,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
CREATE TABLE Sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    inventory_id INT,
    quantity_sold INT NOT NULL,
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);
CREATE TABLE Procurement (
    procurement_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    supplier_id INT,
    inventory_id INT,
    quantity_ordered INT NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);
CREATE TABLE Employee_Salary (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    salary_amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    bonus DECIMAL(10, 2),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Leave') NOT NULL,
    check_in_time TIME,
    check_out_time TIME,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
INSERT INTO Departments (department_name, manager_id) VALUES 
('Human Resources', 1),
('Finance', 2),
('Supply Chain', 3),
('Sales', 4),
('Procurement', 5);
INSERT INTO Employees (first_name, last_name, department_id, email, phone_number, hire_date, job_title) VALUES
('John', 'Doe', 1, 'johndoe@example.com', '1234567890', '2022-01-15', 'HR Manager'),
('Jane', 'Smith', 2, 'janesmith@example.com', '0987654321', '2021-05-23', 'Finance Manager'),
('Alice', 'Johnson', 3, 'alicejohnson@example.com', '1230984567', '2020-09-10', 'Supply Chain Manager'),
('Bob', 'Williams', 4, 'bobwilliams@example.com', '4567891230', '2021-03-14', 'Sales Manager'),
('Charlie', 'Brown', 5, 'charliebrown@example.com', '7894561230', '2022-11-30', 'Procurement Manager');
INSERT INTO Financials (transaction_date, amount, department_id, description, transaction_type) VALUES
('2024-08-01', 5000.00, 1, 'Office Supplies', 'Debit'),
('2024-08-05', 20000.00, 2, 'Monthly Budget Allocation', 'Credit'),
('2024-08-10', 3000.00, 3, 'Logistics', 'Debit'),
('2024-08-15', 15000.00, 4, 'Product Sales Revenue', 'Credit');
INSERT INTO Inventory (item_name, quantity, unit_price, supplier_id, department_id) VALUES
('Laptop', 50, 800.00, 1, 3),
('Printer', 20, 200.00, 2, 1),
('Office Chair', 100, 75.00, 3, 2),
('Desk', 30, 150.00, 4, 4);
INSERT INTO Sales (sale_date, customer_name, amount, inventory_id, quantity_sold) VALUES
('2024-08-01', 'Acme Corp', 4000.00, 1, 5),
('2024-08-05', 'Global Inc', 3000.00, 4, 10);
INSERT INTO Procurement (order_date, supplier_id, inventory_id, quantity_ordered, total_cost) VALUES
('2024-08-01', 1, 1, 10, 8000.00),
('2024-08-05', 2, 3, 50, 3750.00);
INSERT INTO Employee_Salary (employee_id, salary_amount, payment_date, bonus) VALUES
(1, 5000.00, '2024-07-31', 500.00),
(2, 6000.00, '2024-07-31', 600.00),
(3, 5500.00, '2024-07-31', 550.00);
INSERT INTO Attendance (employee_id, date, status, check_in_time, check_out_time) VALUES
(1, '2024-08-01', 'Present', '09:00:00', '17:00:00'),
(2, '2024-08-01', 'Present', '09:15:00', '17:15:00'),
(3, '2024-08-01', 'Absent', NULL, NULL);

DELIMITER $$
CREATE PROCEDURE GetEmployeesByDepartment(IN dept_name VARCHAR(100))
BEGIN
    SELECT e.employee_id, e.first_name, e.last_name, d.department_name, e.job_title, e.email
    FROM Employees e
    JOIN Departments d ON e.department_id = d.department_id
    WHERE d.department_name = dept_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetTotalSalesByItem(IN item_name VARCHAR(100))
BEGIN
    SELECT i.item_name, SUM(s.quantity_sold * i.unit_price) AS total_sales
    FROM Sales s
    JOIN Inventory i ON s.inventory_id = i.inventory_id
    WHERE i.item_name = item_name
    GROUP BY i.item_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetTotalSalaryPaid(IN month_num INT, IN year_num INT)
BEGIN
    SELECT SUM(s.salary_amount + s.bonus) AS total_salary_paid
    FROM Employee_Salary s
    WHERE MONTH(s.payment_date) = month_num AND YEAR(s.payment_date) = year_num;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetEmployeesWithHighAbsenteeism(IN month_num INT, IN year_num INT, IN absence_threshold INT)
BEGIN
    SELECT e.employee_id, e.first_name, e.last_name, COUNT(a.status) AS absent_days
    FROM Attendance a
    JOIN Employees e ON a.employee_id = e.employee_id
    WHERE a.status = 'Absent' AND MONTH(a.date) = month_num AND YEAR(a.date) = year_num
    GROUP BY e.employee_id
    HAVING absent_days > absence_threshold;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetLowStockItems(IN stock_threshold INT)
BEGIN
    SELECT inventory_id, item_name, quantity
    FROM Inventory
    WHERE quantity < stock_threshold;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetFinancialTransactionsByDepartment(IN dept_name VARCHAR(100))
BEGIN
    SELECT f.transaction_id, f.transaction_date, f.amount, f.transaction_type, f.description
    FROM Financials f
    JOIN Departments d ON f.department_id = d.department_id
    WHERE d.department_name = dept_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetProcurementOrdersBySupplier(IN supplier_id INT)
BEGIN
    SELECT p.procurement_id, p.order_date, p.inventory_id, i.item_name, p.quantity_ordered, p.total_cost
    FROM Procurement p
    JOIN Inventory i ON p.inventory_id = i.inventory_id
    WHERE p.supplier_id = supplier_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetAttendanceByMonth(IN month_num INT, IN year_num INT)
BEGIN
    SELECT a.attendance_id, e.first_name, e.last_name, a.date, a.status, a.check_in_time, a.check_out_time
    FROM Attendance a
    JOIN Employees e ON a.employee_id = e.employee_id
    WHERE MONTH(a.date) = month_num AND YEAR(a.date) = year_num;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetSalesByCustomer(IN customer_name VARCHAR(100))
BEGIN
    SELECT s.sale_id, s.sale_date, s.amount, s.quantity_sold, i.item_name
    FROM Sales s
    JOIN Inventory i ON s.inventory_id = i.inventory_id
    WHERE s.customer_name = customer_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetSalaryDetailsByEmployee(IN emp_id INT)
BEGIN
    SELECT es.salary_id, es.salary_amount, es.bonus, es.payment_date
    FROM Employee_Salary es
    WHERE es.employee_id = emp_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetDepartmentsByManager(IN manager_id INT)
BEGIN
    SELECT department_id, department_name
    FROM Departments
    WHERE manager_id = manager_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetEmployeesAndManagers()
BEGIN
    SELECT e.employee_id, e.first_name, e.last_name, m.first_name AS manager_first_name, m.last_name AS manager_last_name
    FROM Employees e
    JOIN Employees m ON e.department_id = m.department_id
    WHERE e.employee_id != m.employee_id AND e.department_id IN (SELECT department_id FROM Departments WHERE manager_id = m.employee_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetFinancialSummaryByDepartment(IN dept_name VARCHAR(100))
BEGIN
    SELECT d.department_name,
           SUM(CASE WHEN f.transaction_type = 'Credit' THEN f.amount ELSE 0 END) AS total_credits,
           SUM(CASE WHEN f.transaction_type = 'Debit' THEN f.amount ELSE 0 END) AS total_debits
    FROM Financials f
    JOIN Departments d ON f.department_id = d.department_id
    WHERE d.department_name = dept_name
    GROUP BY d.department_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetSalesSummaryByItem()
BEGIN
    SELECT i.item_name, SUM(s.quantity_sold) AS total_quantity_sold, SUM(s.quantity_sold * i.unit_price) AS total_sales
    FROM Sales s
    JOIN Inventory i ON s.inventory_id = i.inventory_id
    GROUP BY i.item_name;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetProcurementSummaryBySupplier()
BEGIN
    SELECT p.supplier_id, SUM(p.quantity_ordered) AS total_quantity_ordered, SUM(p.total_cost) AS total_procurement_cost
    FROM Procurement p
    GROUP BY p.supplier_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetAttendanceSummaryByMonth(IN month_num INT, IN year_num INT)
BEGIN
    SELECT a.employee_id,
           SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days,
           SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_days,
           SUM(CASE WHEN a.status = 'Leave' THEN 1 ELSE 0 END) AS leave_days
    FROM Attendance a
    WHERE MONTH(a.date) = month_num AND YEAR(a.date) = year_num
    GROUP BY a.employee_id;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE GetProcurementOrdersAfterDate(IN date_from DATE)
BEGIN
    SELECT p.procurement_id, p.order_date, p.supplier_id, p.inventory_id, p.quantity_ordered, p.total_cost
    FROM Procurement p
    WHERE p.order_date > date_from;
END$$
DELIMITER ;

CALL GetEmployeesByDepartment('Human Resources');
CALL GetTotalSalesByItem('Laptop');
CALL GetTotalSalaryPaid(7, 2024); 
CALL GetFinancialTransactionsByDepartment('Finance');
CALL GetProcurementOrdersBySupplier(1);  
CALL GetSalesByCustomer('Acme Corp');
CALL GetSalaryDetailsByEmployee(1); 
CALL GetDepartmentsByManager(1); 
CALL GetFinancialSummaryByDepartment('Sales');
CALL GetSalesSummaryByItem();
CALL GetProcurementSummaryBySupplier();
CALL GetProcurementOrdersAfterDate('2024-08-01');  





























