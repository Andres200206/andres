use msdb

EXEC sp_add_category
	@class='JOB',
	@type='LOCAL',
	@name='Prueba_Jobs';
GO

EXEC sp_add_job
	@job_name=N'Job_AWOFF',
	@description=N'Job para pasar una base de datos a offline';
GO

EXEC sp_add_job
	@job_name=N'Job_AWON',
	@description=N'Job para pasar un base de datos a online';
GO

exec sp_update_job
	@job_name='Job_AWOFF',
	@category_name='Prueba_Jobs';

exec sp_update_job
	@job_name='Job_AWON',
	@category_name='Prueba_Jobs';

EXEC sp_add_jobstep
	@job_name = N'Job_AWOFF',  
    @step_name = N'Set database offline',   
	@on_success_action=1, --Quit with success
	@on_fail_action=2, --Quit with failure 
	@subsystem = N'TSQL', 
    @command = N'ALTER DATABASE AdventureWorks2017 SET OFFLINE',   
	@database_name=N'AdventureWorks2017',
    @retry_attempts = 5,  
    @retry_interval = 5
GO 

EXEC sp_add_jobstep
	@job_name = N'Job_AWON',  
    @step_name = N'Set database online',   
	@on_success_action=1, --Quit with success
	@on_fail_action=2, --Quit with failure 
	@subsystem = N'TSQL', 
    @command = N'ALTER DATABASE AdventureWorks2017 SET ONLINE',   
	@database_name=N'msdb',
    @retry_attempts = 5,  
    @retry_interval = 5
GO 

EXEC dbo.sp_add_schedule  
    @schedule_name = N'RunWeeklyOffline',  
    @freq_type=8, --Weekly
	@freq_interval=64, --Saturday
	@freq_recurrence_factor=1, 
	@active_start_date=20220521, 
	@active_end_date=20221231, 
	@active_start_time=230000;
GO

EXEC dbo.sp_add_schedule  
    @schedule_name = N'RunWeeklyOnline',  
    @freq_type=8, --Weekly
	@freq_interval=1, --Sunday
	@freq_recurrence_factor=1, 
	@active_start_date=20220522, 
	@active_end_date=20221225, 
	@active_start_time=060000;
GO

EXEC sp_attach_schedule  
   @job_name = N'Job_AWOFF',  
   @schedule_name = N'RunWeeklyOffline';  
GO  

EXEC sp_attach_schedule 
    @job_name = N'Job_AWON', 
	@schedule_name = N'RunWeeklyOnline';
GO

EXEC sp_add_jobserver
	@job_name = N'Job_AWOFF', 
	@server_name = N'(local)'

EXEC sp_add_jobserver
	@job_name = N'Job_AWON', 
	@server_name = N'(local)'
	

ALTER DATABASE AdventureWorks2017 SET ONLINE