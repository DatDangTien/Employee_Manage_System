-- INSERT INTO user (username, password, name, is_backofficer, is_active, date_joined, email, birth, phone)
-- VALUES ('Dat', '1234', 'DANGDAT', 0, 0, '2021-01-01', 'dat1direction', '2000-1-1', '0935234235');

-- INSERT INTO asset (`is_vehicle`, `longtitude`, `latitude`, `load`, `capacity`)
-- VALUES (1, 123.34, 18.59, 2950.4, 2500.6);

-- INSERT INTO vehicle (`asset_id`, `type`)
-- VALUES (1, 'trolley');

-- INSERT INTO employee (user_id, vehicle_id, is_working, is_collector, salary)
-- VALUES (1, 1, 1, 0, 50000000);

-- INSERT INTO asset (`is_vehicle`, `longtitude`, `latitude`, `load`, `capacity`)
-- VALUES (0, 75.34, 100.59, 2950.4, 500.6);

-- INSERT INTO mcp (asset_id, pop_density, janitor_count)
-- VALUES (2, 47583, 5);

-- INSERT INTO janitor (work_radius, employee_id, mcp_id)
-- VALUES (656.78, 1, 2);

INSERT INTO worktime (start, end, weekday, employee_id)
VALUES (time('14:30:00'), time('20:30:00'),'Mon', 1);

UPDATE employee 
	SET vehicle_id = 13
	WHERE user_id = 4;
UPDATE employee 
	SET vehicle_id = 14
	WHERE user_id = 6;
UPDATE employee 
	SET vehicle_id = 15
	WHERE user_id = 8;
UPDATE collector 
	SET route_id = 1
	WHERE employee_id = 4;
UPDATE collector 
	SET route_id = 1
	WHERE employee_id = 6;
UPDATE collector 
	SET route_id = 1
	WHERE employee_id = 8;
UPDATE asset
	SET capacity = 800
    WHERE id = 14;
SELECT GetMaxCapacity(1);
INSERT INTO route
VALUES (NULL, DEFAULT, DEFAULT, NULL, NULL);

UPDATE asset
	SET `load` = 400 
    WHERE id = 1;
UPDATE asset
	SET `load` = 500 
    WHERE id = 3;
UPDATE asset
	SET `load` = 350 
    WHERE id = 4;  
UPDATE asset
	SET `load` = 200 
    WHERE id = 8;


SET @temp_id = last_insert_id();
CALL InsertMCPToRoute(1, 1, 1);
CALL InsertMCPToRoute(3, 1, 3);
CALL InsertMCPToRoute(4, 1, 4);
CALL InsertMCPToRoute(8, 1, 8);
SELECT GetRouteLoad(1);

SELECT user_id  
		FROM back_officer, asset_supervisors
        WHERE 
			asset_supervisors.asset_id = 2 AND
			back_officer.user_id = asset_supervisors.backofficer_id;
SELECT backofficer_id 
					FROM asset_supervisors
					WHERE asset_id = 1;

SET SQL_SAFE_UPDATES = 0;                    
UPDATE back_officer
			SET vehicle_count = vehicle_count + 1
            WHERE
				`user_id` IN (SELECT backofficer_id 
					FROM asset_supervisors
					WHERE asset_id = 1);
SET SQL_SAFE_UPDATES = 1;
INSERT INTO asset (`is_vehicle`, `longtitude`, `latitude`, `load`, `capacity`)
VALUES (0, 100.34, 100.59, 294.4, 504.6);
INSERT INTO asset (`is_vehicle`, `longtitude`, `latitude`, `load`, `capacity`)
VALUES (0, 150, 140.59, 290.4, 500.6);
INSERT INTO asset (`is_vehicle`, `longtitude`, `latitude`, `load`, `capacity`)
VALUES (1, 56.34, 103.59, 2950.4, 3000.6);
INSERT INTO asset (`is_vehicle`, `longtitude`, `latitude`, `load`, `capacity`)
VALUES (1, 124.34, 14.59, 2939.4, 4000.6);
INSERT INTO asset (`is_vehicle`, `longtitude`, `latitude`, `load`, `capacity`)
VALUES (1, 83.34, 120.59, 2350.4, 5000.6);

-- Insert back officer
INSERT INTO `user`
VALUES (NULL,'VitNguNgok21',sha2('lulucc1122',0),'Le Van Luyen',1,0,SYSDATE(),NULL,NULL,'male',NULL,'duyvt763@gmail.com',NULL);
SET @temp_id = last_insert_id();
INSERT INTO back_officer
VALUES (@temp_id,DEFAULT,DEFAULT,DEFAULT,DEFAULT);

INSERT INTO `user`
VALUES (NULL,'ChienHugo33',sha2('BukBuky320',0),'Ho Thanh Than',1,0,SYSDATE(),NULL,NULL,'male',NULL,'BukBuk321@gmail.com',NULL);
SET @temp_id = last_insert_id();
INSERT INTO back_officer
VALUES (@temp_id,DEFAULT,DEFAULT,DEFAULT,DEFAULT);
SET @latest_bo_id = @temp_id;

INSERT INTO asset_supervisors
VALUES (1,1);
INSERT INTO asset_supervisors
VALUES (2,1);
INSERT INTO asset_supervisors
VALUES (3,1);
INSERT INTO asset_supervisors
VALUES (4,2);
INSERT into asset_supervisors
VALUES (5,2);

-- Insert vehicle
INSERT INTO asset_supervisors
VALUES (13,1);
INSERT INTO asset_supervisors
VALUES (14,2);
INSERT into asset_supervisors
VALUES (15,2);

UPDATE asset_supervisors
	SET backofficer_id = 2
	WHERE asset_id = 1 OR asset_id = 13;
-- Trigger route
UPDATE route
	SET manager_id = 1
	WHERE id = 1;

-- Trigger janitor in mcp count
UPDATE janitor
	SET mcp_id = 1
    WHERE employee_id = 3 OR employee_id = 5 OR employee_id = 7;
UPDATE janitor 
	SET mcp_id = 2
    WHERE employee_id = 3;
DELETE FROM janitor WHERE employee_id = 3;
    
SELECT CountVehicle(1);
SELECT COUNT(backofficer_id) INTO count_mcp
		FROM asset_supervisors, asset
		WHERE 
			asset_supervisors.asset_id = asset.id AND
            asset.is_vehicle = 0;
CALL CountAll();

INSERT INTO worktime (start, end, weekday, employee_id)
VALUES (time('15:00:00'), time('15:00:00'),'Fri', 4);