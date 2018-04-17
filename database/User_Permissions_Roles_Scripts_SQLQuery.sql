USE [master]
GO
CREATE LOGIN [OAF_SIMIYU\SIMIYU01] FROM WINDOWS WITH DEFAULT_DATABASE=[simiyu_r_db]
GO


USE [master]
GO
-- Create Windows login for user and set default database to simiyu_r_db
--CREATE LOGIN [OAF_SIMIYU\SIMIYU01] FROM WINDOWS WITH DEFAULT_DATABASE=[simiyu_r_db]
GO
USE [simiyu_r_db];
GO
-- Add user login to database
CREATE USER [OAF_SIMIYU\SIMIYU01] FOR LOGIN [OAF_SIMIYU\SIMIYU01];
GO
-- Configure default schema for user
ALTER USER [OAF_SIMIYU\SIMIYU01] WITH DEFAULT_SCHEMA=dbo;
GO

-- Add user to database roles to grant read, write, and execute DDL permissions
-- Add read permissions to database
ALTER ROLE [db_datareader] ADD MEMBER [OAF_SIMIYU\SIMIYU01];
GO
-- Add write permissions to databse
ALTER ROLE [db_datawriter] ADD MEMBER [OAF_SIMIYU\SIMIYU01];
GO
-- Add ddl permissions to database
ALTER ROLE [db_ddladmin] ADD MEMBER [OAF_SIMIYU\SIMIYU01];
GO
-- Grant permission to execute r script to user
GRANT EXECUTE ANY EXTERNAL SCRIPT TO [OAF_SIMIYU\SIMIYU01];
GO