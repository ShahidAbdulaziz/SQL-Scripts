/*Problem 1
Create a new database named Membership.
*/
Create Database Membership;

/*Problem 2
Write the CREATE TABLE statements needed to implement the following design in the Membership database. Include foreign key constraints. Define IndividualID and GroupID as identity columns. 
Decide which columns should allow null values, if any, and explain your decision. Define the Dues column with a default of zero and a check constraint to allow only positive values.

*/

Create Table Individuals 
(
IndividualID int NOT NULL IDENTITY PRIMARY KEY,
FirstName varchar(50) NOT NULL,
LastName varchar(50) NOT NULL,
Address varchar(50) NULL,
Phone varchar(50) NULL
);

Create Table GroupMembership 
(
GroupID int REFERENCES Groups(GroupID),
IndividualID int REFERENCES Individuals(IndividualID) PRIMARY KEY (GroupID, IndividualID) /*I never seen it done this way. I like it a lot*/
);

Create Table Groups
(
GroupID int NOT NULL IDENTITY PRIMARY KEY,
GroupName varchar(50) NOT NULL,
DUES money NOT NULL DEFAULT 0 CHECK (Dues >=0)
);

/*Problem 3
Write the CREATE INDEX statements to create a clustered index on the GroupID column and a nonclustered index on the IndividualID column of the GroupMembership table.

*/

CREATE CLUSTERED INDEX CL_GroupID
ON GroupMemberShip (GroupID ASC) 

CREATE INDEX CL_IndividualID
ON GroupMemberShip (IndividualID ASC)

/*Problem 4 
Write an ALTER TABLE statement that adds a new column, DuesPaid, to the Individuals table. Use the bit data type, disallow null values, and assign a default Boolean value of False.

*/

ALTER TABLE Individuals
ADD DuesPaid bit  NOT NULL  DEFAULT 'False'

/*Problem 5 
Write an ALTER TABLE statement that adds two new check constraints to the Invoices table of the AP database. The first should allow (1) PaymentDate to be null only if Payment PaymentTotal is zero and (2) PaymentDate to be not null only if PaymentTotal is greater than zero. 
The second constraint should prevent the sum of PaymentTotal and CreditTotal from being greater than InvoiceTotal.
*/

ALTER TABLE AP.Invoices 
ADD CHECK ((PaymentDate IS NULL     AND PaymentTotal = 0) OR
           (PaymentDate IS NOT NULL AND PaymentTotal > 0)),
    CHECK ((PaymentTotal + CreditTotal) <= InvoiceTotal);

/* Problem 6 
Delete the GroupMembership table from the Membership database. Then, write a CREATE TABLE statement that recreates the table, this time with a unique constraint that prevents an individual from being a member in the same group twice.
*/
DROP TABLE GroupMembership;

CREATE Table GroupMembership
(GroupID int REFERENCES Groups(GroupID),
 IndividualID int REFERENCES Individuals(IndividualID),
 UNIQUE(GroupID, IndividualID));

