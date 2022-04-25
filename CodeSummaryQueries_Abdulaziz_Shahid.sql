/*Part A*/

/*Problem 1

Write a SELECT statement that returns the same result set as this SELECT statement. Substitute a subquery in a WHERE clause for the inner join.
SELECT DISTINCT VendorName
FROM Vendors JOIN Invoices
          ON Vendors.VendorID = Invoices.VendorID
ORDER BY VendorName;
*/

SELECT DISTINCT VendorName
FROM Vendors
WHERE Vendors.VendorID in (SELECT DISTINCT VendorID FROM Invoices)
ORDER BY VendorName;

/*Problem 2
Write a SELECT statement that answers this question: Which invoices have a PaymentTotal that's greater than the average PaymentTotal for all paid invoices? Return the InvoiceNumber and InvoiceTotal for each invoice.
*/

SELECT
InvoiceID,
InvoiceTotal
FROM Invoices
WHERE InvoiceTotal > (SELECT avg(InvoiceTotal) FROM Invoices)

/*Problem 3

Write a SELECT statement that answers this question: Which invoices have a PaymentTotal that's greater than the median PaymentTotal for all paid invoices? (The median marks the midpoint in a set of values; an equal number of values lie above and below it.) 
Return the InvoiceNumber and InvoiceTotal for each invoice. Hint: Begin with the solution to exercise 2, then use the ALL keyword in the WHERE clause and code "TOP 50 PERCENT PaymentTotal" in the subquery.
*/

Select VendorId, PaymentTotal, InvoiceNumber, InvoiceTotal
From Invoices
Where PaymentTotal > All
(SELECT TOP 50 Percent(PaymentTotal)
From Invoices
ORDER BY PaymentTotal)

/*Problem 4
Write a SELECT statement that returns two columns from the GLAccounts table: AccountNo and Account Description. The result set should have one row for each account number that has never been used. Use a correlated subquery introduced with the NOT EXISTS operator. Sort the final result set by AccountNo.

*/

SELECT
AccountNo,
AccountDescription
FROM GLAccounts
WHERE NOT EXISTS (SELECT * FROM Vendors where Vendors.DefaultAccountNo = GLAccounts.AccountNo)

/*Problem 5

Write a SELECT statement that returns four columns: VendorName, InvoiceID, InvoiceSequence, and InvoiceLineItemAmount for each invoice that has more than one line item in the InvoiceLineItems table. Hint: Use a subquery that tests for InvoiceSequence > 1.

*/

SELECT
ven.VendorName,
inv.InvoiceID,
invLine.InvoiceSequence,
invLine.InvoiceLineItemAmount
FROM Vendors ven LEFT JOIN Invoices inv
ON ven.VendorID = inv.VendorID
LEFT JOIN InvoiceLineItems invLine
ON invLine.InvoiceID = inv.InvoiceID
Where invLine.InvoiceID IN (SELECT InvoiceID FROM InvoiceLineItems Group By InvoiceID Having count(InvoiceID) > 1)

/*Problem 6
Write a SELECT statement that returns a single value that represents the sum of the largest unpaid invoices submitted by each vendor. Use a derived table that returns MAX(InvoiceTotal) grouped by VendorID, filtering for invoices with a balance due.
*/

Select
MAX(UnpaidInvoice) LargestUnpaidAmount
FROM (
Select
VendorID,
sum(InvoiceTotal - (PaymentTotal+CreditTotal)) UnpaidInvoice
FROM Invoices
WHERE InvoiceTotal <> PaymentTotal + CreditTotal
Group BY VendorID

) unpaidInvoice

/*Problem 7
Write a SELECT statement that returns the name, city, and state of each vendor that's located in a unique city and state. In other words, don't include vendors that have a city and state in common with another vendor.
*/

SELECT
VendorName,
VendorCity,
VendorState
from Vendors
WHERE concat(VendorState,VendorCity) in (
	SELECT concat(VendorState,VendorCity)
	FROM Vendors
	GROUP BY concat(VendorState,VendorCity)
	HAVING count(concat(VendorState,VendorCity)) = 1
	)

/*Problem 8
Write a SELECT statement that returns four columns: VendorName, InvoiceNumber, InvoiceDate, and InvoiceTotal. Return one row per vendor, representing the vendor's invoice with the earliest date.
*/

SELECT 
ven.VendorName,
inv.InvoiceNumber,
inv.InvoiceDate,
InvoiceTotal
FROM  Vendors ven LEFT JOIN Invoices inv 
ON ven.VendorID = inv.VendorID
INNER JOIN (SELECT VendorID, min(InvoiceDate) EarlyInv
			FROM Invoices 
			GROUP BY VendorID
			
			
			) EarliestDate
ON EarliestDate.VendorID = inv.VendorID AND inv.InvoiceDate = EarliestDate.EarlyInv

/*Problem 9
Rewrite exercise 6 so it uses a common table expression (CTE) instead of a derived table.
*/

WITH unpaid AS
(Select
VendorID,
sum(InvoiceTotal - (PaymentTotal+CreditTotal)) UnpaidInvoice
FROM Invoices
WHERE InvoiceTotal <> PaymentTotal + CreditTotal
Group BY VendorID)

select max(UnpaidInvoice) maxUnpaidInv
FROM unpaid

/*Part B*/

/*Problem 1
Write SELECT INTO statements to create two test tables named VendorCopy and InvoiceCopy that are complete copies of the Vendors and Invoices tables. If VendorCopy and InvoiceCopy already exist, first code two DROP TABLE statements to delete them.
*/

DROP TABLE IF EXISTS VendorCopy GO
DROP TABLE IF EXISTS InvoiceCopy GO

SELECT *
INTO VendorCopy
FROM vendors

SELECT *
INTO InvoiceCopy
FROM Invoices

/*Problem 2
Write an INSERT statement that adds a row to the InvoiceCopy table with the following values:
VendorID: 32
InvoiceTotal: $434.58
TermsID: 2
InvoiceNumber: AX-014-027
PaymentTotal: $0.00
InvoiceDueDate: 07/8/12
InvoiceDate: 6/21/12
CreditTotal: $0.00
PaymentDate: null

*/

INSERT INTO InvoiceCopy(VendorID,InvoiceTotal,TermsID,InvoiceNumber,PaymentTotal,InvoiceDueDate,InvoiceDate,CreditTotal,PaymentDate)
VALUES
(32,434.58,2,'AX-014-027',0,'07/8/12','6/21/12',0,NULL)

/*Problem 3
Write an INSERT statement that adds a row to the VendorCopy table for each non-California vendor in the Vendors table. (This will result in duplicate vendors in the VendorCopy table.)
*/

INSERT INTO VendorCopy(VendorName, VendorAddress1, VendorAddress2, VendorCity, VendorState, VendorZipCode, VendorPhone, VendorContactLName, VendorContactFName,DefaultTermsID, DefaultAccountNo)
SELECT 
VendorName, 
VendorAddress1,
VendorAddress2, 
VendorCity, 
VendorState, 
VendorZipCode, 
VendorPhone, 
VendorContactLName, 
VendorContactFName,
DefaultTermsID, 
DefaultAccountNo
FROM Vendors AS vnd
WHERE VendorState <> 'CA'

/*Problem 4
Write an UPDATE statement that modifies the VendorCopy table. Change the default account number to 403 for each vendor that has a default account number of 400.

*/

UPDATE VendorCopy
SET
DefaultAccountNo = 403
WHERE DefaultAccountNo = 400

/*Problem 5
Write an UPDATE statement that modifies the InvoiceCopy table. Change the PaymentDate to today's date and the PaymentTotal to the balance due for each invoice with a balance due. Set today's date with a leteral date string, or use the GETDATE() function.

*/

UPDATE InvoiceCopy
SET
PaymentDate = GETDATE()
WHERE InvoiceTotal <> PaymentTotal + CreditTotal

/*Problem 6
Write an UPDATE statement that modifies the InvoiceCopy table. Change TermsID to 2 for each invoice that's from a vendor with a DefaultTermsID of 2. Use a subquery.
*/

UPDATE InvoiceCopy
SET
TermsID = 2
WHERE VendorID IN
(SELECT VendorID
FROM VendorCopy
WHERE DefaultTermsID = 2);

/*Problem 7
Solve exercise 6 using a join rather than a subquery.
*/

UPDATE InvoiceCopy
SET 
TermsID = 2
FROM InvoiceCopy INNER JOIN VendorCopy
ON InvoiceCopy.VendorID = VendorCopy.VendorID
WHERE DefaultTermsID = 2;

/*Problem 8
Write a DELETE statement that deletes all vendors in the state of Minnesota from the VendorCopy table.

*/

DELETE FROM VendorCopy
WHERE VendorState = 'MN'

/*Problem 9
Write a DELETE statement for the VendorCopy table. Delete the vendors that are located in states frmo which no vendor has ever sent an invoice. Hint: Use a subquery coded with "SELECT DISTINCT VendorState" introduced with the NOT IN operator.

*/

DELETE FROM VendorCopy
WHERE VendorState NOT IN
(SELECT DISTINCT VendorState
FROM VendorCopy INNER JOIN InvoiceCopy
ON VendorCopy.VendorID = InvoiceCopy.VendorID);


/*Part C*/

/*Problem 1
Write a SELECT statement that returns four columns based on the InvoiceTotal column of the Invoices table:
Use the CAST function to return the first column as data type decimal with 2 digits to the right of the decimal point.
Use CAST to return the second column as a varchar.
Use the CONVERT function to return the third column as the same data type as the first column.
Use CONVERT to return the fourth column as a varchar, using style 1.
*/

Select 
CAST(InvoiceTotal as decimal(10,1)) Column1,
CAST(InvoiceTotal as varchar(50)) Column2,
CONVERT(decimal(10,2), InvoiceTotal) Column3,
CONVERT(varchar(50), InvoiceTotal) Column4
FROM Invoices

/*Problem 2
Write a SELECT statement that returns four columns based on the InvoiceDate column of the Invoices table:
Use the CAST function to return the first column as data type varchar.
Use the CONVERT function to return the second and third columns as a varchar, using style 1 and style 10, respectively.
Use the CAST function to return the fourth column as data type real.
*/

SELECT
CAST(InvoiceDate as varchar(20)) Column1,
Convert(varchar,invoicedate, 1) as column2,
Convert(varchar,invoicedate ,10) as column3,
cast(invoicedate as real) as column4
FROM Invoices