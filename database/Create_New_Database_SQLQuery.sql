USE master;
GO

--check using the databse name if it exsists, if it exsists drop the database
IF EXISTS(select * from sys.databases where name = 'simiyu_r_db')
DROP DATABASE simiyu_r_db;
go

--if the database does not exsist or has been dropped create a new one
CREATE DATABASE simiyu_r_db;
GO