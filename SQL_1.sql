#HENOK Fasil Telila
#Number_of_downloads_google_console
#create view demo as ..
#Table name : poste_appannie_download_stats_allplatform
#DONE
USE mwr_poste_app_monitoring;
-- select dimensions
-- from(
-- create table atest1
	select date, dimensions, CAST(value as int) AS value
        from (
        SELECT padsa.`day` AS date, 
        	CASE  WHEN padsa.store_name = 'Google Play' THEN  'Android' 
	  			   WHEN padsa.store_name = 'Apple Store' THEN  'IOS'       
	  			   ELSE 'NC' END  AS dimensions, 
        	SUM(padsa.estimate ) AS value
          	FROM poste_appannie_download_stats_allplatform padsa
            GROUP BY padsa.`day` , padsa.store_name 
            UNION ALL     
        SELECT padsa.`day` AS date, concat(
             CASE  WHEN padsa.store_name = 'Google Play' THEN  'Android' 
	  			   WHEN padsa.store_name = 'Apple Store' THEN  'IOS'       
	  			   ELSE 'NC' END 
	  			   ,' -> ',
  	  		 CASE   WHEN padsa.app_name = 'Bancoposta' THEN 'Bancoposta' 
				  	WHEN padsa.app_name = 'Postepay' THEN 'Postepay'
				  	WHEN padsa.app_name = 'PosteID' THEN 'PosteID'
				  	WHEN padsa.app_name = 'Ufficio Postale' THEN 'Ufficiopostale'  
		  			ELSE 'NC' END 	  
 			) AS dimensions, 
	  			SUM(padsa.estimate ) AS value
             FROM poste_appannie_download_stats_allplatform padsa
             GROUP BY padsa.`day` , padsa.store_name , padsa.app_name 
             ) as a
             where date >= '2015-01-01' and date < SUBDATE(NOW(),1);
         --   ) AS a
          --  where dimensions = 'NC';
             
             ;           

  -- END
 select padsa.`day` AS date, padsa.estimate from poste_appannie_download_stats_allplatform padsa
 					where day >= '2015-01-01' and day < SUBDATE(NOW(),1); 
            
            
            
CASE  WHEN padsa.store_name = 'Google Play' THEN  'Android' 
	  WHEN padsa.store_name = 'Apple Store' THEN  'IOS'    ELSE 'NC' END
CASE  WHEN padsa.app_name = 'Ufficio Postale' THEN 'Ufficiopostale' ELSE 'NC' END

SELECT DISTINCT store_name FROM poste_appannie_download_stats_allplatform ; 
SELECT DISTINCT app_name FROM poste_appannie_download_stats_allplatform; 
   'Google Play'  'Apple Store'
	"IOS" and "Android"
	
-- Other trials
select date, dimensions, value
        from (
            SELECT padsa.`day` AS date, padsa.store_name AS dimensions, SUM(padsa.estimate ) AS value
             FROM poste_appannie_download_stats_allplatform padsa
            GROUP BY padsa.`day` , padsa.store_name 
            UNION ALL 
            SELECT padsa.`day` AS date, concat(padsa.store_name ,' -> ', padsa.app_name ) AS dimensions, SUM(padsa.estimate ) AS value
             FROM poste_appannie_download_stats_allplatform padsa
             GROUP BY padsa.`day` , padsa.store_name , padsa.app_name 
             ) as a
             where date < SUBDATE(NOW(),1);	