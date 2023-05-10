-- Insert MCP 
CALL InsertMCP(NULL, 106.657501, 10.773045, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.653745, 10.786654, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.658821, 10.780086, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.663421, 10.775828, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.659960, 10.764715, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.662589, 10.778742, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.666257, 10.776935, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.663459, 10.782816, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.669609, 10.784208, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.664690, 10.786800, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.657961, 10.783208, RAND()*100, RAND()*100+300, 0, 0);
CALL InsertMCP(NULL, 106.653347, 10.770870, RAND()*100, RAND()*100+300, 0, 0);

-- Insert vehicle
CALL InsertVehicle(NULL, 106.625786, 10.810676, 0, RAND()*100+900, 'truck');
CALL InsertVehicle(NULL, 106.625786, 10.810676, 0, RAND()*100+900, 'truck');
CALL InsertVehicle(NULL, 106.625786, 10.810676, 0, RAND()*100+900, 'truck');
CALL InsertVehicle(NULL, 106.625786, 10.810676, 0, RAND()*100+100, 'trolley');
CALL InsertVehicle(NULL, 106.625786, 10.810676, 0, RAND()*100+100, 'trolley');
CALL InsertVehicle(NULL, 106.625786, 10.810676, 0, RAND()*100+100, 'trolley');

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

-- let all current back officers supervise all assets
-- INSERT INTO asset_supervisors SELECT id, user_id FROM asset, back_officer;

-- Insert employee and let the latter back officer manages them
CALL InsertEmployee('trangbku123',sha2('trangthaomai212',0),'Doan Thi Trang',@temp_id,0,SYSDATE(),NULL,NULL,'female','0123567980','trangdoan@gmail.com',0,6000000);
CALL InsertEmployee('giaunhucho999',sha2('lotto77777',0),'Le Van Giau',@temp_id,0,SYSDATE(),NULL,NULL,'male','0987123789','ngheo12@gmail.com',1,7000000);
CALL InsertEmployee('Thythycute666',sha2('06052001Thy',0),'Khuc Thy',@temp_id,0,SYSDATE(),NULL,NULL,'female','0987123789','thythy99@gmail.com',0,6000000);
CALL InsertEmployee('VanAvt1200',sha2('123456789',0),'Nguyen Van A',@temp_id,0,SYSDATE(),NULL,NULL,'male','0977077629','Bomavt11@gmail.com',1,7000000);
CALL InsertEmployee('BBBboyhotrac3',sha2('BBBhotracboy44',0),'Nguyen Van B',@temp_id,0,SYSDATE(),NULL,NULL,'male','0921666111','Brherjfe1@gmail.com',0,6000000);
CALL InsertEmployee('123CsuiRR321',sha2('khoaito3279',0),'Nguyen Van C',@temp_id,0,SYSDATE(),NULL,NULL,'male','0125721021','Hieheit11@gmail.com',1,7000000);

-- Insert routes
INSERT INTO route
VALUES (NULL, DEFAULT, DEFAULT, NULL, @latest_bo_id);
SET @temp_id = last_insert_id();
CALL InsertMCPToRoute(1, @temp_id, 1);
CALL InsertMCPToRoute(3, @temp_id, 3);
CALL InsertMCPToRoute(4, @temp_id, 4);
CALL InsertMCPToRoute(8, @temp_id, 8);

INSERT INTO route
VALUES (NULL, DEFAULT, DEFAULT, NULL, @latest_bo_id);
SET @temp_id = last_insert_id();
CALL InsertMCPToRoute(2, @temp_id, 2);
CALL InsertMCPToRoute(6, @temp_id, 6);
CALL InsertMCPToRoute(7, @temp_id, 7);
CALL InsertMCPToRoute(9, @temp_id, 9);