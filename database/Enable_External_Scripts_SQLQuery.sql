USE master;
go
--check if configuration property is set
SELECT name, description, value
FROM sys.configurations
WHERE name = 'external scripts enabled';

--ifvalue is 0, reset the configuration to enable
EXEC sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;