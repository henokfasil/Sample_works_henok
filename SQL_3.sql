#num_of_sessions #poste_appannie_usagehistory_metrics_allplatform #column total_sessions
#use mwr_poste_app_monitoring;

#UPDATE mwr_poste_app_monitoring.poste_appannie_usagehistory_metrics_allplatform
#SET Value = REPLACE(Value, '123', '')
-- select dimensions
-- from(
select date, dimensions, CAST(value as int) AS value
        from (
        SELECT padsa.`date` AS date, 
        	 CASE  WHEN padsa.store_name = 'Google Play' THEN  'Android' 
	  			   WHEN padsa.store_name = 'Apple Store' THEN  'IOS'       
	  			   ELSE 'NC' END AS dimensions, SUM(padsa.total_sessions ) AS value
            FROM poste_appannie_usagehistory_metrics_allplatform padsa
            GROUP BY padsa.`date` , padsa.store_name 
            UNION ALL
         SELECT padsa.`date` AS date, concat(
            CASE  WHEN padsa.store_name = 'Google Play' THEN  'Android' 
	  			   WHEN padsa.store_name = 'Apple Store' THEN  'IOS'       
	  			   ELSE 'NC' END  
            ,' -> ', 
             CASE   WHEN padsa.app_name = 'Bancoposta' THEN 'Bancoposta' 
				  	WHEN padsa.app_name = 'Postepay' THEN 'Postepay'
				  	WHEN padsa.app_name = 'PosteID' THEN 'PosteID'
				  	WHEN padsa.app_name = 'Ufficio Postale' THEN 'Ufficiopostale'  
		  			ELSE 'NC' END  ) AS dimensions, 
             SUM(padsa.total_sessions ) AS value
             FROM poste_appannie_usagehistory_metrics_allplatform padsa
             GROUP BY padsa.`date` , padsa.store_name , padsa.app_name 
             ) as a
              where date >= '2015-01-01' and date < SUBDATE(NOW(),1);
         --   ) AS a
        --   where dimensions = 'NC'; 
 
            
--- END 
            
SELECT DISTINCT store_name FROM poste_appannie_usagehistory_metrics_allplatform ;
SELECT DISTINCT app_name FROM poste_appannie_usagehistory_metrics_allplatform;


            