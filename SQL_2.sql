#num_rating_store: #table: poste_appannie_rating_info #column: average
USE mwr_poste_app_monitoring;

--  select dimensions
 -- from(       
 select date, dimensions, CAST(value as int) AS value
	        from (
	        SELECT padsa.rating_date AS date, 
	        CASE   WHEN padsa.store_name = 'Google Play' THEN  'Android' 
	  			   WHEN padsa.store_name = 'Apple Store' THEN  'IOS'       
	  			   ELSE 'NC' END AS dimensions,  AVG(padsa.allrating_average) AS value
             		FROM poste_appannie_rating_info padsa
            		GROUP BY padsa.rating_date , padsa.store_name , padsa.app_name 
            UNION ALL
	        SELECT padsa.rating_date AS date, concat(
	        CASE  WHEN padsa.store_name = 'Google Play' THEN  'Android' 
	  			   WHEN padsa.store_name = 'Apple Store' THEN  'IOS'       
	  			   ELSE 'NC' END 
	        ,' -> ', 
	        CASE   WHEN padsa.app_name = 'Bancoposta' THEN 'Bancoposta' 
				  	WHEN padsa.app_name = 'Postepay' THEN 'Postepay'
				  	WHEN padsa.app_name = 'PosteID' THEN 'PosteID'
				  	WHEN padsa.app_name = 'Ufficio Postale' THEN 'Ufficiopostale'  
		  			ELSE 'NC' END) 
	        AS dimensions, 
	        AVG(padsa.allrating_average ) AS value
	             FROM poste_appannie_rating_info padsa
             GROUP BY padsa.rating_date , padsa.store_name , padsa.app_name 
             ) as a 
             where date >= '2015-01-01' and date < SUBDATE(NOW(),1);
                    -- order by date ASC;                   
		      --   ) AS a
		       --    where dimensions = 'NC';
 
    -- END         
  
      
            
            
            
SELECT DISTINCT store_name FROM poste_appannie_rating_info ; 'Apple Store'  'Google Play'
SELECT DISTINCT app_name FROM poste_appannie_rating_info;     'BancoPosta', 'PostePay','Ufficio Postale', 'PosteID'       
                       
            
            
 -- draft          
            
            
             where date = '2020-11-08';
             
             
          AVG    
select padsa.rating_date  AS date ,padsa.allrating_average,padsa.store_name from poste_appannie_rating_info padsa where padsa.rating_date = '2020-11-08';

-- draft
select date, dimensions, value 
        from (
            SELECT padsa.rating_date AS date, padsa.store_name AS dimensions,  AVG(padsa.allrating_average) AS value
             FROM poste_appannie_rating_info padsa
            GROUP BY padsa.rating_date , padsa.store_name , padsa.app_name 
            UNION ALL 
            SELECT padsa.rating_date AS date, concat(padsa.store_name ,' -> ', padsa.app_name ) AS dimensions, AVG(padsa.allrating_average ) AS value
             FROM poste_appannie_rating_info padsa
             GROUP BY padsa.rating_date , padsa.store_name , padsa.app_name 
             ) as a 
             where date < SUBDATE(NOW(),1);