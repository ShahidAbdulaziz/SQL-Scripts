USE AP;

/*Problem 1*/

/*Write a SELECT statement that returns two columns based on the Vendors table. The first column, Contract, is the vendor contact name in this format: first name followed by last initial (for example, "John S."). The second column, Phone, is the VendorPhone column without the area code. 
Only return rows for those vendors in the 559 area code. Sort the result set by first name, then last name.*/

GO
USE AP;

GO

SELECT
VendorContactFName +' '+ SUBSTRING(VendorContactLName,1,1)+'.' Contract,
right(VendorPhone,9) Phone
FROM Vendors
where cast(right(left(VendorPhone,4),3) as INT) = 559
Order BY
VendorContactFName,
VendorContactLName;

/*Problem 2

Write a SELECT statement that returns the InvoiceNumber and balance due for every invoice with a non-zero balance and an InvoiceDueDate that's less than 30 days from today.
*/

GO
USE AP;

GO

SELECT
InvoiceNumber,
InvoiceTotal -(PaymentTotal+CreditTotal) BalanceDue
FROM Invoices
where InvoiceTotal -(PaymentTotal+CreditTotal) > 0
and DATEDIFF(DAY,InvoiceDueDate,getdate()) < 30;

/*Problem 3
Modify the search expression for InvoiceDueDate from the solution for exercise 2. Rather than 30 days from today, return invoices due before the last day of the current month.
*/




GO
USE AP;

GO

SELECT
InvoiceNumber,
InvoiceTotal -(PaymentTotal+CreditTotal) BalanceDue
FROM Invoices
where InvoiceTotal -(PaymentTotal+CreditTotal) > 0
and invoiceDueDate > eomonth(getdate());

/*Problem 4
Write a summary query WITH CUBE that returns LineItemSum (which is the sum of InvoiceLineItemAmount) grouped by Account (an alias for AccountDescription) and State (an alias for VendorState). 
Use the CASE and GROUPING function to substitute the literal value "*ALL*" for the summary rows with null values.


*/
GO
USE AP;

GO

SELECT 
sum(lineIt.InvoiceLineItemAmount) LineItemSum,
accdesc.AccountDescription Account,
CASE WHEN GROUPING(VendorState) = 1 then '*ALL*' else VendorState END State
FROM InvoiceLineItems lineIt INNER JOIN vendors ven
ON ven.DefaultAccountNo = lineIt.AccountNo
INNER JOIN GLAccounts accdesc 
ON accdesc.AccountNo = lineIt.AccountNo
Group BY accdesc.AccountDescription, VendorState WITH CUBE;


/*Problem 5
Add a column to the query described in exercise 2 that uses the RANK() function to return a column named BalanceRank that ranks the balance due in descending order.
*/

GO
USE AP;

SELECT
InvoiceNumber,
InvoiceTotal -(PaymentTotal+CreditTotal) BalanceDue,
RANK() OVER (ORDER BY (InvoiceTotal + CreditTotal) - 
    PaymentTotal DESC) As BalanceRank
FROM Invoices
where InvoiceTotal -(PaymentTotal+CreditTotal) > 0
and DATEDIFF(DAY,InvoiceDueDate,getdate()) < 30;


/*Part B*/

/*Problem 1
Write a CREATE VIEW statement that defines a view named InvoiceBasic that returns three columns: VendorName, InvoiceNumber, and InvoiceTotal. Then, write a SELECT statement that returns all of the columns in the view, sorted by VendorName, where the first letter of the vendor name is N, O, or P.

*/

GO
USE AP;

GO
DROP VIEW IF EXISTS InvoiceBasic ;
GO

 CREATE VIEW InvoiceBasic

 AS

 SELECT 
 ven.VendorName,
 InvoiceID,
 InvoiceTotal
 FROM Vendors ven INNER JOIN Invoices inv
 ON ven.VendorID = inv.VendorID

 GO

 Select *
 FROM InvoiceBasic
 where VendorName LIKE '[N-P]%'

 /*Problem 2
 
 Create a view named Top10PaidInvoices that returns three columns for each vendor: VendorName, LastInvoice (the most recent invoice date), and SumOfInvoices (the sum of the InvoiceTotal column). 
 Return only the 10 vendors with the largest SumOfInvoices and include only paid invoices.
 
 */

GO
USE AP;

GO
DROP VIEW IF EXISTS Top10PaidInvoices

GO
CREATE VIEW Top10PaidInvoices

AS

SELECT top(10) 
ven.VendorName,
max(InvoiceDate) LastInvoice,
sum(InvoiceTotal) SumOfInvoices
FROM Vendors ven INNER JOIN Invoices inv
ON ven.VendorID = inv.VendorID
where PaymentTotal = CreditTotal+InvoiceTotal
GROUP BY ven.VendorName, InvoiceDate
Order by sum(InvoiceTotal) DESC

/*Problem 3
Create an adaptable view named VendorAddress that returns the VendorID, both address columns, and the city, state, and zip code columns for each vendor. Then, write a SELECT query to examine the result set where VendorID=4. 
Next, write an UPDATE statement that changes the address so that the suite number (Ste 260) is stored in VendorAddress2 rather than in VendorAddress1. To verify the change, rerun your SELECT query.
*/

GO
USE AP;

GO

DROP VIEW IF EXISTS VendorAddress 
GO

CREATE VIEW VendorAddress 

AS

select 
VendorID,
VendorAddress1,
VendorAddress2,
VendorCity,
VendorState,
VendorZipCode
from vendors
GO

Select * 
FROM VendorAddress
where VendorID = 4;

UPDATE VendorAddress 
SET VendorAddress2 = 'Ste 260',
VendorAddress1 = REPLACE(VendorAddress1,'Ste 260','')
WHERE VendorAddress1 LIKE '%Ste 260%'
GO

Select * 
FROM VendorAddress
where VendorID = 4;

/*Problem 4
Write a SELECT statement that selects all of the columns for the catalog view that returns information about foreign keys.  How many foreign keys are defined in the AP database?
*/

SELECT * FROM sys.foreign_keys Go


/*Part C*/

/*Problem 1
Create a stored procedure named spBalanceRange that accepts three optional parameters. The procedure should return a result set consisting of VendorName, InvoiceNumber, and Balance for each invoice with a balance due, sorted with largest balance due first.
The parameter @VendorVar is a mask that's used with a LIKE operator to filter by vendor name, as shown in figure 15-5. @BalanceMin and @BalanceMax are parameters used to specify the requested range of balances due. If called with no parameters or with a maximum value of 0, 
the procedure should return all invoices with a balance due.

*/

USE AP;
GO

CREATE PROCEDURE spBalanceRange(
@VendorVar varchar(50) = '%' ,
@BalanceMin money = 0,
@BalanceMax money = 0
)

AS
IF @BalanceMax = 0 

SELECT 
ven.VendorName,
inv.InvoiceNumber,
inv.InvoiceTotal - (PaymentTotal+CreditTotal) Balance
FROM ap.dbo.vendors ven LEFT JOIN ap.dbo.Invoices Inv
ON ven.VendorID = Inv.VendorID
WHERE inv.InvoiceTotal <> (PaymentTotal+CreditTotal)
Order By 
Balance

ELSE

SELECT 
ven.VendorName,
inv.InvoiceNumber,
inv.InvoiceTotal - (PaymentTotal+CreditTotal) Balance
FROM ap.dbo.vendors ven LEFT JOIN ap.dbo.Invoices Inv
ON ven.VendorID = Inv.VendorID
WHERE (inv.InvoiceTotal <> (PaymentTotal+CreditTotal) 
AND ven.VendorName like @VendorVar)
AND inv.InvoiceTotal - (PaymentTotal+CreditTotal) <= @BalanceMax 
AND inv.InvoiceTotal - (PaymentTotal+CreditTotal) >= @BalanceMin
Order By 
Balance;
GO


/*Problem 2

Code three calls to the procedure created in exercise 
1:passed by position with @VendorMar='M%' and no balance range
2: passed by name with @VendorMar omitted and a balance range from $200 to $1000
3: passed by position with a balance due that's less than $200 filtering for vendors whose names begin with C or F



*/

EXEC spBalanceRange 'M%';
EXEC spBalanceRange @BalanceMin = 200, @BalanceMax = 1000;
EXEC spBalanceRange '[C,F]%', 0, 200;



/*Problem 3
Create a stored procedure named spDateRange that accepts two parameters, @DateMin and @DateMax, with data type varchar and default value null. If called with no parameters or with null values, raise an error that describes the problem. If called with non-null values, validate the parameters.
Test that the literal strings are valid dates and test that @DateMin is earlier than @DateMax. If the parameters are valid, return a result set that includes the InvoiceNumber, InvoiceDate, InvoiceTotal, and Balance for each invoice for which the InvoiceDate is within the date range, sorted with earliest invoice first.
*/

USE AP;
GO

CREATE PROCEDURE spDateRange(
@DateMin varchar(15) = NULL,
@DateMax varchar(15) = NULL
)

AS

IF @DateMax IS NULL

	THROW 50001, 'Null is not an acceptable input for DateMax',1;

IF @DateMin IS NULL

	THROW 50001, 'Null is not an acceptable input for DateMin',1;

IF ISDATE(@DateMax) = 0

	THROW 50001, 'Not a valid date for for DateMax',1;

IF isdate(@DateMin) = 0

	THROW 50001, 'Not a valid date for DateMin',1;

IF CONVERT(datetime,@DateMax) < CONVERT(datetime, @DateMin)
	THROW 50001, '0 is not an acceptable input for DateMin',1;

SELECT 
InvoiceNumber, 
InvoiceDate, 
InvoiceTotal, 
InvoiceTotal- (CreditTotal + PaymentTotal) Balance
FROM Invoices
WHERE InvoiceDate >= @DateMin 
AND InvoiceDate <= @DateMax;



/*Problem 4

Code a call to the stored procedure created in exercise 3 that returns invoices with an InvoiceDate between December 10 and December 20, 2011. This call should also catch any errors that are raised by the procedure and print the error number and description.


*/

EXEC spDateRange '2011-12-10', '2011-12-20';

/*Problem 5

Create a scalar-valued function named fnUnpaidInvoiceID that returns the InvoiceID of the earliest invoice with an unpaid balance. Test the function in the following SELECT statement:
SELECT VendorName, InvoiceNumber, InvoiceDueDate,
              InvoiceTotal - CreditTotal - PaymentTotal AS Balance
FROM Vendors JOIN Invoices
      ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceID = dbo.fnUnpaidInvoiceID();
*/


GO
IF OBJECT_ID('fnUnpaidInvoiceID') IS NOT NULL 
	DROP FUNCTION fnUnpaidInvoiceID
GO
 
CREATE FUNCTION fnUnpaidInvoiceID()
RETURNS INT
BEGIN
RETURN (
	SELECT InvoiceID 
	FROM Invoices
	WHERE InvoiceTotal - (CreditTotal + PaymentTotal) <> 0 AND InvoiceDate = (
		SELECT MIN(InvoiceDate)
		FROM Invoices
		WHERE InvoiceTotal - (CreditTotal + PaymentTotal) <> 0))
END
GO

SELECT VendorName, InvoiceNumber, InvoiceDueDate,
              InvoiceTotal - CreditTotal - PaymentTotal AS Balance
FROM Vendors JOIN Invoices
      ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceID = dbo.fnUnpaidInvoiceID();

/*Problem 6

Create a table-valued function named fnDateRange, similar to the stored procedure of exercise 3. The function requires two parameters of data type smalldatetime.
Don't validate the parameters. Return a result set that includes the InvoiceNumber, InvoiceDate, InvoiceTotal, and Balance for each invoice for which the InvoiceDate is within the date range. Invoke the function from within a SELECT statement to return those invoices with InvoiceDate between December 10 and December 20, 2011.

*/

GO
USE AP;

GO

IF OBJECT_ID('fnDateRange') IS NOT NULL 
	DROP FUNCTION fnDateRange
GO
 
CREATE FUNCTION fnDateRange
	(@DateMin smalldatetime, 
	 @DateMax smalldatetime)
RETURNS table
 
RETURN
(SELECT 
InvoiceNumber, 
InvoiceDate, 
InvoiceTotal,
InvoiceTotal - (CreditTotal+ PaymentTotal) Balance
FROM Invoices
WHERE InvoiceDate >= @DateMin 
AND InvoiceDate <= @DateMax)

GO
 
SELECT *
FROM dbo.fnDateRange('12/10/11','12/20/11');
 

/*Problem 7

Use the function you created in exercise 6 in a SELECT statement that returns five columns: VendorName and the four columns returned by the function.

*/

SELECT 
VendorName, 
FunctionTable.*
FROM Vendors INNER JOIN Invoices
	ON Vendors.VendorID = Invoices.VendorID
INNER JOIN dbo.fnDateRange('12/10/11','12/20/11') AS FunctionTable
	ON Invoices.InvoiceNumber = FunctionTable.InvoiceNumber;

/*Problem 8

Create a trigger for the Invoices table that automatically inserts the vendor name and address for a paid invoice into a table named ShippingLabels. The trigger should fire any time the PaymentTotal column of the Invoices table is updated. The structure of the ShippingLabels table is as follows:
CREATE TABLE ShippingLabels
 (VendorName            varchar(50),
  VendorAddress1       varchar(50),
  VendorAddress2       varchar(50),
  VendorCity                varchar(50),
  VendorState              char(2),
  VendorZipCode        varchar(20));
Use this UPDATE statement to test the trigger:
  UPDATE Invoices
  SET PaymentTotal = 67.92, PaymentDate = '2012-04-23'
  WHERE InvoiceID = 100;

*/

GO

USE AP

GO

IF OBJECT_ID('ShippingLabels') IS NOT NULL 
	DROP TABLE ShippingLabels
GO
CREATE TABLE ShippingLabels
(VendorName varchar(50),
VendorAddress1  varchar(50), 
VendorAddress2 varchar(50), 
VendorCity varchar(50), 
VendorState char(2), 
VendorZipCode varchar(20));
 
GO

CREATE OR ALTER TRIGGER ShipLabels_Insert
	ON Invoices
	AFTER UPDATE, INSERT
AS
	IF EXISTS
		(SELECT * 
		FROM Invoices
		WHERE ((InvoiceTotal - (CreditTotal + PaymentTotal)) = 0))
			INSERT INTO ShippingLabels
				(VendorName, VendorAddress1, VendorAddress2, VendorCity, VendorState, VendorZipCode)
			SELECT *
			FROM ShippingLabels
GO

UPDATE Invoices
SET PaymentTotal = 67.92, PaymentDate = '2012-04-23'
WHERE InvoiceID = 100;


/*Problem 9

Write a trigger that prohibits duplicate values except for nulls in the NoDupName column of the following table:
  CREATE TABLE TestUniqueNulls
  (RowID                 int    IDENTITY     NOT NULL,
  NoDupName        varchar(20)           NULL);
(Note that you can't do this by using a unique constraint because the constraint wouldn't allow duplicate null values.) If an INSERT or UPDATE statement creates a duplicate value, roll back the statement and return an error message. Write a series of INSERT statements that tests that duplicate null values are allowed but duplicates of other values are not.



*/

IF OBJECT_ID('UniqueTable') IS NOT NULL
	DROP TABLE UniqueTable;
GO
 
CREATE TABLE UniqueTable
 (RowID int IDENTITY NOT NULL,
  NoDupName varchar(20) NULL);
 
GO

CREATE OR ALTER TRIGGER UniqueTestNullAllowed_Trigger
ON UniqueTable
AFTER INSERT, UPDATE

AS

BEGIN
	IF
		(Select 
		Count(main.NoDupName)
		FROM UniqueTable AS main join UniqueTable AS selfjoin
			ON main.NoDupName = selfjoin.noDupName) > 1
	BEGIN
		ROLLBACK TRAN
		RAISERROR ('No duplicate values allowed', 11, 1)
	END
END

GO
 
 
INSERT INTO UniqueTable
Values('test1');

INSERT INTO UniqueTable
Values('name3');

INSERT INTO UniqueTable
Values(NULL);
 
SELECT *
FROM UniqueTable;