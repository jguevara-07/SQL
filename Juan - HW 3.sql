--1
--Write a query to display the truck, assignment date, truck capacity, target payload, 
--the total product weight that is currently scheduled for that assignment, and the difference between the assigned weight and target capacity.
--Sort the results by the truck number in ascending order, then by assignment date in ascending order.

SELECT 
	TRUCK.TRUCK_NUM, ASSIGN_DATE, 
	TRUCK_CAPACITY AS 'Max Payload', 
	TRUCK_CAPACITY * .75 AS 'Target Payload', 
	SUM(PROD_WEIGHT) AS 'Assigned Payload', 
	(TRUCK_CAPACITY*.75) -SUM(PROD_WEIGHT) AS 'Remaining Capacity'
FROM TOM.TRUCK JOIN TOM.ASSIGNMENT ON TRUCK.TRUCK_NUM = ASSIGNMENT.TRUCK_NUM
	JOIN TOM.PRODUCT ON ASSIGNMENT.ASSIGN_NUM = PRODUCT.ASSIGN_NUM
GROUP BY 
	TRUCK.TRUCK_NUM, 
	ASSIGN_DATE, 
	TRUCK_CAPACITY;

--2
--Write a query to display the product number, product description, installation minutes, and total labor charge for the installation.
--Sort the results by labor change in descending order, then by product number in ascending order

SELECT 
	PROD_NUM, 
	PROD_DESCRIPT, 
	PROD_INSTALL_MINUTES, 
	FORMAT(SUM((PROD_INSTALL_MINUTES / 60.0) * EMP_WAGE), 'C') AS 'LABOR CHARGE'
FROM TOM.PRODUCT JOIN TOM.ASSIGNMENT ON PRODUCT.ASSIGN_NUM = ASSIGNMENT.ASSIGN_NUM
	JOIN TOM.CREW ON ASSIGNMENT.ASSIGN_NUM = CREW.ASSIGN_NUM
	JOIN TOM.EMPLOYEE ON EMPLOYEE.EMP_NUM = CREW.EMP_NUM
GROUP BY 
	PROD_NUM, 
	PROD_DESCRIPT, 
	PROD_INSTALL_MINUTES
ORDER BY SUM((PROD_INSTALL_MINUTES / 60.0) * EMP_WAGE) DESC, PROD_NUM;

--3
--Write a query to display the employee number and employee name for all employees that have not been involved in installing an island.
--Sort the results by employee last name in ascending order, and then by first name.

SELECT 
	EMP_NUM, 
	CONCAT(EMP_LNAME, ', ', EMP_FNAME) AS EMPLOYEE
FROM TOM.EMPLOYEE
WHERE EMP_NUM NOT IN (
	SELECT EMPLOYEE.EMP_NUM
	FROM TOM.EMPLOYEE JOIN TOM.CREW ON EMPLOYEE.EMP_NUM = CREW.EMP_NUM
		JOIN TOM.ASSIGNMENT ON ASSIGNMENT.ASSIGN_NUM = CREW.ASSIGN_NUM
		JOIN TOM.PRODUCT ON ASSIGNMENT.ASSIGN_NUM = PRODUCT.ASSIGN_NUM
	WHERE PROD_DESCRIPT LIKE '%island%'
)
ORDER BY EMP_LNAME, EMP_FNAME;

--4
--Write a query to display the site number, site contact person, street and city, contact phone number, and the number of trips that trucks have taken to each site.
--Include sites that have not been visited by any truck yet.
--Sort the results by the number of visits in ascending order, then by site number in ascending order.

SELECT
	SITE.SITE_NUM, 
	SITE_CONTACT, 
	SITE_STREET, 
	SITE_CITY, 
	SITE_PHONE,
	COUNT(DISTINCT ASSIGN_NUM) AS VISITS
FROM TOM.SITE LEFT JOIN TOM.PRODUCT ON SITE.SITE_NUM = PRODUCT.SITE_NUM
GROUP BY 
	SITE.SITE_NUM, 
	SITE_CONTACT, 
	SITE_STREET, 
	SITE_CITY, 
	SITE_PHONE
ORDER BY VISITS, SITE_NUM;

--5
--Write a query to display the product number, product description, installation minutes, installation minutes per pound of the product,
--the contact person for the site where the product is installed, the contact phone number, the date it was installed,
--and the employee that was the leader of the crew installing the product. Include products that have not been delivered and installed yet.
--Limit the results to:
--Kitchen products with a 2-hole sink with installation time above 70 minutes.
--Any product with a 3-hole sink with installation time below 70 minutes.
--Sort the results by minutes per pound in descending order, then by product number in ascending order.

SELECT 
	PROD_NUM, 
	PROD_DESCRIPT, 
	PROD_INSTALL_MINUTES, 
	ROUND(PROD_INSTALL_MINUTES / PROD_WEIGHT, 3) AS 'MINUTES / POUND', 
	SITE_CONTACT, 
	SITE_PHONE, 
	ASSIGN_DATE, 
	CONCAT(EMP_FNAME, ' ', EMP_LNAME) AS 'CREW LEAD'
FROM TOM.PRODUCT LEFT JOIN TOM.SITE ON PRODUCT.SITE_NUM = SITE.SITE_NUM
	LEFT JOIN TOM.ASSIGNMENT ON PRODUCT.ASSIGN_NUM = ASSIGNMENT.ASSIGN_NUM
	LEFT JOIN TOM.CREW ON ASSIGNMENT.ASSIGN_NUM = CREW.ASSIGN_NUM
	LEFT JOIN TOM.EMPLOYEE ON EMPLOYEE.EMP_NUM = CREW.EMP_NUM
WHERE 
	(CREW_ROLE = 'Lead' OR CREW_ROLE IS NULL) AND (
	(PROD_DESCRIPT LIKE '%Kitchen%' AND PROD_DESCRIPT LIKE '%2-hole sink%' AND PROD_INSTALL_MINUTES > 70) OR
	(PROD_DESCRIPT LIKE '%3-hole sink%' AND PROD_INSTALL_MINUTES < 70))
ORDER BY ROUND(PROD_INSTALL_MINUTES / PROD_WEIGHT, 3) DESC, PROD_NUM;
