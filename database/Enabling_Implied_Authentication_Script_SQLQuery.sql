USE [master]
GO
-- CREATE Windows login for  local window group and set default database 
CREATE LOGIN [OAF_SIMIYU\SIMIYU02] FROM WINDOWS WITH DEFAULT_DATABASE=[master];
GO
