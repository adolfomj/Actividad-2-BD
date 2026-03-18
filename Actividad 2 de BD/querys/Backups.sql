BACKUP DATABASE jardineria
TO DISK = 'C:\Backup\jardineria.bak'
WITH FORMAT, INIT, NAME = 'Backup Jardineria';
--------------------
--------------------
BACKUP DATABASE Staging
TO DISK = 'C:\Backup\staging.bak'
WITH FORMAT, INIT, NAME = 'Backup Staging';