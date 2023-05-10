USE `uwc_2.0`
-- function to get total load of a route
DELIMITER |
DROP FUNCTION IF EXISTS `GetRouteLoad`|
CREATE FUNCTION `GetRouteLoad` 
	(route_id BIGINT)
RETURNS NUMERIC(9,3)
READS SQL DATA
DETERMINISTIC
BEGIN
	DECLARE S_val NUMERIC(9,3);
	SELECT SUM(`load`) INTO S_val 
	FROM route, contains_mcp, asset
	WHERE route.id = route_id AND
		  contains_mcp.route_id = route.id AND
		  contains_mcp.mcp_id = asset.id;
	RETURN S_val;
END |

-- procedure to insert employee
DELIMITER |
DROP PROCEDURE IF EXISTS `InsertEmployee`|
CREATE PROCEDURE `InsertEmployee`(
    p_username varchar(150), 
    p_password varchar(128), 
    p_name varchar(150), 
    p_mgr BIGINT,
    p_active BOOL, 
    p_djoin datetime(6),
    p_addr varchar(100),
    p_bd date,
    p_gender enum('male','female'),
    p_phone varchar(15),
    p_email varchar(254),
    p_role BOOL,
    p_sal bigint
)
BEGIN
	DECLARE temp_id BIGINT;
	INSERT INTO `user`(id,username,`password`,`name`,is_backofficer,is_active,date_joined,address,birth,gender,phone,email,last_login) 
    VALUES (NULL,p_username,p_password,p_name,0,p_active,p_djoin,p_addr,p_bd,p_gender,p_phone,p_email,NULL);
    
    SET temp_id=last_insert_id();
    
    INSERT INTO employee(user_id,manager_id,vehicle_id,is_working,is_collector,start_date,salary)
    VALUES (temp_id,p_mgr,NULL,p_active,p_role,NULL,p_sal);
    
    IF p_role = 0 THEN 
		INSERT INTO janitor(mcp_start_date,work_radius,employee_id,mcp_id)
        VALUES (DEFAULT,NULL,temp_id,NULL);
	ELSE 
		INSERT INTO collector(employee_id,route_id)
        VALUES (temp_id,NULL);
	END IF;
	CALL GetUser(temp_id);
END |

-- procedure to update employee data
DELIMITER |
DROP PROCEDURE IF EXISTS `UpdateEmployee`|
CREATE PROCEDURE `UpdateEmployee`(
	p_id bigint, 
    p_username varchar(150), 
    p_password varchar(128), 
    p_name varchar(150), 
    p_isbackofficer BOOL,
    p_active BOOL, 
    p_djoin datetime(6),
    p_addr varchar(100),			/*NULL*/
    p_bd date,					/*NULL*/
    p_gender enum('male','female'),/*NULL*/
    p_phone varchar(15),			/*NULL*/
    p_email varchar(254),
    p_mngrID bigint,				/*more of employee NULL*/ /*NULL*/
    p_vecID bigint,				/*NULL*/
    p_start date,				/*NULL*/
    p_radius decimal(9,3),		/*janitor*/	/*NULL*/
    p_mcpID bigint,				/*NULL*/
    p_routeID bigint,    		/*collector*/ /*NULL*/
    p_role BOOL,			
    p_sal bigint
)
BEGIN
	UPDATE `user`
		SET
		username=p_username,`password`=p_password,`name`=p_name,
		is_backofficer=p_isbackofficer,is_active=p_active,
		date_joined=p_djoin,address=p_addr,birth=p_bd,
		gender=p_gender,phone=p_phone,email=p_email,last_login=NULL
		WHERE id=p_id;
    UPDATE employee
		SET
        manager_id=p_mngrID,
        vehicle_id=p_vecID,
        is_working=p_active,
        salary=p_sal
        WHERE user_id=p_id; 
    IF p_role = 0 THEN
		UPDATE `janitor`
			SET
            mcp_start_date=p_start,work_radius=p_radius,mcp_id=p_mcpID
            WHERE employee_id=p_id;
	ELSE
		UPDATE `collector`
        SET
		route_id=p_routeID
        WHERE employee_id=p_id;
	END IF;
END |

DELIMITER |
DROP PROCEDURE IF EXISTS `DeleteEmployee`|
CREATE PROCEDURE `DeleteEmployee`(IN p_id bigint,IN p_role BOOL)
BEGIN
	IF p_role=0 THEN
		DELETE FROM janitor where employee_id = p_id;
	ELSE
		DELETE FROM collector where employee_id = p_id;
	END IF;
	DELETE FROM employee WHERE user_id=p_id;
	DELETE FROM `user` WHERE id=p_id;
END |

-- procedure to retrieve user from login data
DELIMITER |
DROP PROCEDURE IF EXISTS `GetUserFromLogin`|
CREATE PROCEDURE `GetUserFromLogin` (
	username varchar(150),
	`password` varchar(128)
)
BEGIN
	DECLARE hashpass varchar(128);
	IF NOT exists(SELECT * 
			  	  FROM `user` 
			  	  WHERE `user`.username=username)
	THEN SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'No username matched';
	END IF;

	SELECT `user`.`password` INTO hashpass
	FROM `user`
	WHERE `user`.username = username;

	IF sha2(`password`,0) <> hashpass
	THEN SIGNAL SQLSTATE '77777'
		SET MESSAGE_TEXT = 'Wrong password';
	END IF;

	SELECT *
	FROM `user`
	WHERE `user`.username = username;
END |

-- procedure to acquire user
DELIMITER |
DROP PROCEDURE IF EXISTS `GetUser`|
CREATE PROCEDURE `GetUser`(user_id BIGINT)
BEGIN
	DECLARE temp_var BOOL;
	SELECT is_backofficer INTO temp_var
	FROM `user`
	WHERE `user`.id = user_id;

	IF temp_var = 1 THEN 
		SELECT * # get backofficer
		FROM `user`, back_officer
		WHERE `user`.id = back_officer.user_id AND 
			  `user`.id = user_id;
	ELSE 
		SELECT is_collector INTO temp_var
		FROM employee
		WHERE employee.user_id = user_id;
		IF temp_var = 0 THEN
			SELECT * # get janitor
			FROM `user`, employee, janitor
			WHERE `user`.id = employee.user_id AND
				  employee.user_id = janitor.employee_id AND
                  janitor.employee_id = user_id;
		ELSE 
			SELECT * # get collector
			FROM `user`, employee, collector
			WHERE `user`.id = employee.user_id AND
				  employee.user_id = collector.employee_id AND
                  collector.employee_id = user_id;
		END IF;
	END IF;
END |

-- procedure to acquire all employees under some back officer
DELIMITER |
DROP PROCEDURE IF EXISTS `GetEmployees`|
CREATE PROCEDURE `GetEmployees` (mgr_id BIGINT)
BEGIN
	SELECT *
	FROM `user`, employee
	WHERE id = user_id AND
		  manager_id = mgr_id;
END |

-- procedure to insert a new route to database
DELIMITER |
DROP PROCEDURE IF EXISTS `InsertRoute`|
CREATE PROCEDURE `InsertRoute`(
	id BIGINT,
	mgr_id BIGINT
) 
BEGIN
	INSERT INTO route
	VALUES (id,DEFAULT,DEFAULT,NULL,mgr_id);
	SELECT last_insert_id();
END |

-- procedure to insert a MCP to a route
DELIMITER |
DROP PROCEDURE IF EXISTS `InsertMCPToRoute`|
CREATE PROCEDURE `InsertMCPToRoute`(
	mcp_id BIGINT, 
    route_id BIGINT,
    `order` SMALLINT
)
BEGIN
	INSERT INTO contains_mcp
    VALUES (`order`, mcp_id, route_id);
END |

-- procedure to delete a route
DELIMITER |
DROP PROCEDURE IF EXISTS `DeleteRoute`|
CREATE PROCEDURE `DeleteRoute`(route_id BIGINT)
BEGIN
	DELETE FROM route 
	WHERE id = route_id;
END |

-- procedure to delete MCPs from one route
DELIMITER |
DROP PROCEDURE IF EXISTS `DeleteMCPsFromRoute`;
CREATE PROCEDURE `DeleteMCPsFromRoute`(route_id BIGINT)
BEGIN
	DELETE FROM contains_mcp
	WHERE contains_mcp.route_id = route_id;
END |

-- procedure to acquire full map
DELIMITER |
DROP PROCEDURE IF EXISTS `RetrieveMap`|
CREATE PROCEDURE `RetrieveMap`(mgr_id BIGINT)
BEGIN
	SELECT mcp.asset_id, longtitude, latitude, `load`, `load`/capacity as percentage, pop_density, janitor_count
	FROM asset, mcp, asset_supervisors asp
	WHERE asset.id = mcp.asset_id AND
	 	  mcp.asset_id = asp.asset_id AND
		  backofficer_id = mgr_id; 
END |

-- procedure to acquire MCPs from a route
DELIMITER |
DROP PROCEDURE IF EXISTS `RetrieveMCPsFromRoute`|
CREATE PROCEDURE `RetrieveMCPsFromRoute`(route_id BIGINT)
BEGIN
	SELECT id, `order`, longtitude, latitude, `load`, capacity, `load`/capacity as percentage
	FROM contains_mcp, asset
	WHERE contains_mcp.route_id = route_id AND 
		  contains_mcp.mcp_id = asset.id;
END |

-- procedure to acquire all routes
DELIMITER |
DROP PROCEDURE IF EXISTS `RetrieveRoutes`|
CREATE PROCEDURE `RetrieveRoutes` (mgr_id BIGINT)
BEGIN
	SELECT * 
	FROM route
	WHERE manager_id = mgr_id;
END |

-- procedure to update total distance of a route 
DELIMITER |
DROP PROCEDURE IF EXISTS `UpdateDistance`|
CREATE PROCEDURE `UpdateDistance` (
	route_id BIGINT, 
	distance NUMERIC(9,3)
)
BEGIN
	UPDATE route 
	SET route.distance = distance 
	WHERE route.id = route_id;
END |

-- procedure to assign area to a janitor
DELIMITER |
DROP PROCEDURE IF EXISTS `AssignAreaToJanitor`|
CREATE PROCEDURE `AssignAreaToJanitor` (
	work_radius NUMERIC(9,3),
	mcp_id BIGINT,
	start_date date,
	jan_id BIGINT
)
BEGIN
	UPDATE janitor jan
	SET jan.mcp_start_date = start_date, 
		jan.work_radius = work_radius,
		jan.mcp_id = mcp_id
	WHERE id = jan_id;
END |

-- procedure to assign route to a collector
DELIMITER |
DROP PROCEDURE IF EXISTS `AssignRouteToCollector`|
CREATE PROCEDURE `AssignRouteToCollector` (
	route_id BIGINT,
	col_id BIGINT
)
BEGIN 
	UPDATE collector col
	SET col.route_id = route_id
	WHERE id = col_id;
END |

-- procedure to insert shift into schedule of one employee
DELIMITER |
DROP PROCEDURE IF EXISTS `InsertShift`|
CREATE PROCEDURE `InsertShift` (
	start_time time(6), 
	end_time time(6), 
	weekday enum('Mon','Tue','Wed','Thur','Fri','Sat','Sun'), 
	emp_id BIGINT
)
BEGIN
	INSERT INTO worktime
	VALUES (start_time, end_time, weekday, emp_id, NULL);
END |

-- procedure to acquire schedule of an employee
DELIMITER |
DROP PROCEDURE IF EXISTS `RetrieveSchedule`|
CREATE PROCEDURE `RetrieveSchedule` (emp_id BIGINT)
BEGIN
	SELECT *
	FROM worktime
	WHERE employee_id = emp_id;
END |

-- procedure to insert MCP
DELIMITER |
DROP PROCEDURE IF EXISTS `InsertMCP`|
CREATE PROCEDURE `InsertMCP` (
	id BIGINT,
	longtitude NUMERIC(10,7),
	latitude NUMERIC(10,7),
	`load` NUMERIC(9,3),
	capacity NUMERIC(9,3),
	pop_density NUMERIC(9,3),
	janitor_count BIGINT	
)
BEGIN
	DECLARE temp_id BIGINT;
	INSERT INTO asset
	VALUES (id, 0, longtitude, latitude, `load`, capacity);
	SET temp_id=last_insert_id();
	INSERT INTO mcp
	VALUES (temp_id, pop_density, janitor_count);
END |

-- procedure to insert vehicle
DELIMITER |
DROP PROCEDURE IF EXISTS `InsertVehicle`|
CREATE PROCEDURE `InsertVehicle` (
	id BIGINT,
	longtitude NUMERIC(10,7),
	latitude NUMERIC(10,7),
	`load` NUMERIC(9,3),
	capacity NUMERIC(9,3),
	`type` enum('truck','trolley')
)
BEGIN
	DECLARE temp_id BIGINT;
	INSERT INTO asset
	VALUES (id, 1, longtitude, latitude, `load`, capacity);
    SET temp_id=last_insert_id();
	INSERT INTO vehicle
	VALUES (temp_id, type);
END |

-- procedure to delete shift
DELIMITER |
DROP PROCEDURE IF EXISTS `DeleteShift`|
CREATE PROCEDURE `DeleteShift` (id BIGINT)
BEGIN
	DELETE FROM worktime
	WHERE worktime.id = id;
END |