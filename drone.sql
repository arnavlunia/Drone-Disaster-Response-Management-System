-- MASTER SCRIPT: DRONE DATABASE SETUP (STRUCTURE, DATA, AND ROLES)
-- This script should be executed as a root user on your MySQL server.

-- 1. DATABASE SETUP
-- --------------------------------------------------------
DROP DATABASE IF EXISTS drone;
CREATE DATABASE drone;
USE drone;

-- 2. CREATE TABLE STATEMENTS
-- --------------------------------------------------------

CREATE TABLE OPERATOR (
    O_ID CHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Certification VARCHAR(50),
    Experience_Level INT DEFAULT 0
);

CREATE TABLE DISASTER (
    D_ID CHAR(10) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Type VARCHAR(50),
    Location VARCHAR(150) NOT NULL,
    Start_Time DATETIME NOT NULL,
    End_Time DATETIME
);

CREATE TABLE MISSION_REPORT (
    MR_ID CHAR(10) PRIMARY KEY,
    Battery_Remaining DECIMAL(5, 2),
    Distance_Covered DECIMAL(10, 2),
    Success_Rate DECIMAL(5, 2),
    People_Aided INT DEFAULT 0
);

-- Note: The original 'drone' table name is singular, matching its PK D_NO, which simplifies foreign key creation.
CREATE TABLE DRONE (
    D_NO CHAR(10) PRIMARY KEY,
    Model VARCHAR(50) NOT NULL,
    Payload DECIMAL(5, 2),
    Flying_Hours DECIMAL(10, 2) DEFAULT 0,
    D_ID CHAR(10) NOT NULL, -- FK to DISASTER
    FOREIGN KEY (D_ID) REFERENCES DISASTER(D_ID)
);

CREATE TABLE RESOURCE_ACTION (
    R_ID CHAR(10) PRIMARY KEY,
    MR_ID CHAR(10) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity >= 0),
    FOREIGN KEY (MR_ID) REFERENCES MISSION_REPORT(MR_ID)
);

CREATE TABLE ALERTS (
    A_ID CHAR(10) PRIMARY KEY,
    Resolution VARCHAR(255),
    MR_ID CHAR(10) NOT NULL,
    Type VARCHAR(50),
    Severity VARCHAR(20) NOT NULL,
    Time DATETIME NOT NULL,
    D_NO CHAR(10) NOT NULL,
    FOREIGN KEY (MR_ID) REFERENCES MISSION_REPORT(MR_ID),
    FOREIGN KEY (D_NO) REFERENCES DRONE(D_NO)
);

CREATE TABLE DRONE_STATUS (
    G_ID CHAR(10) PRIMARY KEY,
    D_NO CHAR(10) NOT NULL,
    Latitude DECIMAL(10, 8) NOT NULL,
    Longitude DECIMAL(11, 8) NOT NULL,
    Battery DECIMAL(5, 2) NOT NULL,
    FOREIGN KEY (D_NO) REFERENCES DRONE(D_NO)
);

CREATE TABLE OPERATOR_SKILLS (
    O_ID CHAR(10) NOT NULL,
    Skill_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (O_ID, Skill_Name),
    FOREIGN KEY (O_ID) REFERENCES OPERATOR(O_ID)
);

CREATE TABLE DRONE_FEATURES (
    D_NO CHAR(10) NOT NULL,
    Feature_Name VARCHAR(50) NOT NULL,
    PRIMARY KEY (D_NO, Feature_Name),
    FOREIGN KEY (D_NO) REFERENCES DRONE(D_NO)
);

CREATE TABLE ASSIGNED_TO (
    O_ID CHAR(10) NOT NULL,
    D_ID CHAR(10) NOT NULL,
    PRIMARY KEY (O_ID, D_ID),
    FOREIGN KEY (O_ID) REFERENCES OPERATOR(O_ID),
    FOREIGN KEY (D_ID) REFERENCES DISASTER(D_ID)
);

CREATE TABLE DELIVERABLES (
    R_ID CHAR(10) NOT NULL,
    D_ID CHAR(10) NOT NULL,
    PRIMARY KEY (R_ID, D_ID),
    FOREIGN KEY (R_ID) REFERENCES RESOURCE_ACTION(R_ID),
    FOREIGN KEY (D_ID) REFERENCES DISASTER(D_ID)
);

-- 3. INSERT ALL SAMPLE DATA
-- --------------------------------------------------------

-- OPERATOR (15 Tuples)
INSERT INTO OPERATOR (O_ID, Name, Certification, Experience_Level) VALUES
('OP001', 'Alice Johnson', 'Level 3 Pilot', 5), ('OP002', 'Bob Smith', 'Technician Cert', 2),
('OP003', 'Charlie Brown', NULL, 1), ('OP004', 'Dana Scully', 'Level 4 Pilot', 10),
('OP005', 'Elon Tusk', 'Hardware Eng', 7), ('OP006', 'Fiona Green', 'Level 2 Pilot', 3),
('OP007', 'George Harris', 'Maintenance', 6), ('OP008', 'Hannah Lee', 'Advanced Piloting', 8),
('OP009', 'Ivan Petrova', NULL, 4), ('OP010', 'Jasmine Khan', 'Level 1 Pilot', 1),
('OP011', 'Kyle Llama', 'Search & Rescue', 9), ('OP012', 'Laura Munez', 'Level 2 Pilot', 3),
('OP013', 'Mark Norris', NULL, 1), ('OP014', 'Nancy Olsen', 'Data Analyst', 5),
('OP015', 'Oscar Porter', 'Level 4 Pilot', 11);

-- DISASTER (9 Tuples)
INSERT INTO DISASTER (D_ID, Name, Type, Location, Start_Time, End_Time) VALUES
('DS001', 'Hurricane Zephyr', 'Tropical Storm', 'Coastal City, FL', '2025-09-10 08:00:00', '2025-09-12 18:30:00'),
('DS002', 'Forest Fire Alpha', 'Wildfire', 'Mountain Ridge, CA', '2025-10-01 14:00:00', NULL), 
('DS003', 'Nepal Earthquake', 'Seismic Event', 'Kathmandu, Nepal', '2025-09-25 04:45:00', '2025-09-26 10:00:00'),
('DS004', 'Flooding Delta', 'Flood', 'Riverbank Town, TX', '2025-11-15 02:00:00', NULL), 
('DS005', 'Chemical Spill Gamma', 'Hazmat', 'Industrial Zone, IN', '2025-12-01 10:00:00', '2025-12-01 14:00:00'),
('DS006', 'Tornado Epsilon', 'Severe Weather', 'Prairie County, OK', '2025-12-10 16:30:00', '2025-12-10 17:00:00'),
('DS007', 'Coastal Heatwave', 'Extreme Heat', 'Southern California', '2026-06-01 12:00:00', '2026-06-05 20:00:00'), 
('DS008', 'Volcano Ash Cloud', 'Volcanic Activity', 'Pacific Northwest', '2026-07-20 06:00:00', NULL), 
('DS009', 'Factory Collapse', 'Structural Failure', 'Midwest Industrial Park', '2026-08-05 09:30:00', '2026-08-05 18:00:00');

-- MISSION_REPORT (9 Tuples)
INSERT INTO MISSION_REPORT (MR_ID, Battery_Remaining, Distance_Covered, Success_Rate, People_Aided) VALUES
('MR001', 15.50, 45.20, 95.00, 12), ('MR002', 30.00, 21.00, 78.50, 0),
('MR003', 5.20, 105.80, 100.00, 56), ('MR004', 55.00, 12.80, 85.00, 0),
('MR005', 10.00, 35.00, 60.00, 2), ('MR006', 90.00, 5.50, 99.99, 1),
('MR007', 45.00, 75.30, 92.00, 5), ('MR008', 2.50, 150.00, 50.00, 0),
('MR009', 88.00, 15.00, 100.00, 3);

-- DRONE (12 Tuples)
INSERT INTO DRONE (D_NO, Model, Payload, Flying_Hours, D_ID) VALUES
('DRN01', 'Phantom 4', 1.5, 120.5, 'DS001'), ('DRN02', 'Matrice M300', 5.0, 45.3, 'DS002'),
('DRN03', 'Mavic Pro', 0.5, 200.0, 'DS001'), ('DRN04', 'Heavy Lifter X', 10.0, 10.1, 'DS003'),
('DRN05', 'Swarm Scout', 0.2, 500.0, 'DS004'), ('DRN06', 'Hazard Mapper', 3.0, 15.0, 'DS005'),
('DRN07', 'Guardian Pro', 2.5, 80.0, 'DS004'), ('DRN08', 'Mini-Copter', 0.1, 5.0, 'DS006'),
('DRN09', 'DJI Inspire', 2.0, 30.0, 'DS007'), ('DRN10', 'Sensor Rover', 0.1, 550.0, 'DS008'),
('DRN11', 'Thermal Eagle', 4.0, 12.0, 'DS009'), ('DRN12', 'Cargo Master', 15.0, 5.0, 'DS009');

-- RESOURCE_ACTION (12 Tuples)
INSERT INTO RESOURCE_ACTION (R_ID, MR_ID, Type, Quantity) VALUES
('RA001', 'MR001', 'Search & Rescue', 1), ('RA002', 'MR001', 'Medical Supplies', 50),
('RA003', 'MR002', 'Infrastructure Survey', 1), ('RA004', 'MR003', 'Food Drop', 200),
('RA005', 'MR004', 'Water Testing', 1), ('RA006', 'MR004', 'Evacuation Route Mapping', 1),
('RA007', 'MR005', 'Air Quality Sample', 2), ('RA008', 'MR006', 'Shelter Location', 1),
('RA009', 'MR007', 'Temperature Monitoring', 3), ('RA010', 'MR007', 'Public Service Announcement', 10),
('RA011', 'MR008', 'Atmospheric Sample', 5), ('RA012', 'MR009', 'Victim Location', 1);

-- ALERTS (12 Tuples)
INSERT INTO ALERTS (A_ID, Resolution, MR_ID, Type, Severity, Time, D_NO) VALUES
('AL001', 'Rerouted drone', 'MR001', 'Obstacle Detected', 'Medium', '2025-09-11 10:15:00', 'DRN01'),
('AL002', NULL, 'MR002', 'Low Battery', 'High', '2025-10-02 15:40:00', 'DRN02'), 
('AL003', 'Pilot took manual control', 'MR001', 'GPS Error', 'Medium', '2025-09-11 11:05:00', 'DRN01'),
('AL004', 'Auto-land initiated', 'MR003', 'Critical Battery', 'High', '2025-09-25 18:22:00', 'DRN04'),
('AL005', 'System reset', 'MR004', 'Communication Loss', 'High', '2025-11-15 03:30:00', 'DRN05'),
('AL006', 'Sensor recalibrated', 'MR004', 'Sensor Drift', 'Low', '2025-11-15 04:00:00', 'DRN05'),
('AL007', NULL, 'MR005', 'Chemical Leakage', 'Critical', '2025-12-01 11:30:00', 'DRN06'), 
('AL008', 'Wind warning issued', 'MR006', 'High Winds', 'Medium', '2025-12-10 16:45:00', 'DRN08'),
('AL009', 'Flight path adjusted', 'MR007', 'Overheating Warning', 'Medium', '2026-06-02 14:00:00', 'DRN09'),
('AL010', NULL, 'MR008', 'High Wind Turbulence', 'Critical', '2026-07-21 08:00:00', 'DRN10'),
('AL011', 'Manual reset applied', 'MR009', 'Compass Drift', 'Low', '2026-08-05 11:00:00', 'DRN11'),
('AL012', 'Payload stabilized', 'MR009', 'Weight Shift', 'Medium', '2026-08-05 12:30:00', 'DRN12');

-- DRONE_STATUS (15 Tuples)
INSERT INTO DRONE_STATUS (G_ID, D_NO, Latitude, Longitude, Battery) VALUES
('GS001', 'DRN01', 25.761680, -80.191790, 85.00), ('GS002', 'DRN02', 34.052235, -118.243683, 70.50),
('GS003', 'DRN01', 25.761685, -80.191800, 75.00), ('GS004', 'DRN03', 25.761690, -80.191810, 60.00),
('GS005', 'DRN04', 27.761695, -80.191820, 99.00), ('GS006', 'DRN05', 30.000000, -95.000000, 45.00),
('GS007', 'DRN06', 40.000000, -100.000000, 80.00), ('GS008', 'DRN07', 30.000000, -95.000005, 40.00),
('GS009', 'DRN08', 35.000000, -97.000000, 95.00), ('GS010', 'DRN03', 25.761695, -80.191820, 50.00),
('GS011', 'DRN09', 33.700000, -117.800000, 72.00), ('GS012', 'DRN10', 45.000000, -122.000000, 15.00),
('GS013', 'DRN11', 39.000000, -90.000000, 90.00), ('GS014', 'DRN12', 39.000000, -90.000001, 80.00),
('GS015', 'DRN09', 33.700005, -117.800005, 65.00);

-- JUNCTION TABLES (M:N)
INSERT INTO OPERATOR_SKILLS (O_ID, Skill_Name) VALUES
('OP001', 'First Aid'), ('OP001', 'Advanced Piloting'), ('OP004', 'Thermal Imaging'),
('OP006', 'Search Pattern Design'), ('OP008', 'Maintenance'), ('OP011', 'Heavy Payload'),
('OP012', 'Thermal Analysis');

INSERT INTO DRONE_FEATURES (D_NO, Feature_Name) VALUES
('DRN01', 'Night Vision'), ('DRN02', 'Lidar Scanner'), ('DRN04', 'Heavy Lift'),
('DRN05', 'Waterproof'), ('DRN06', 'Gas Sensor'), ('DRN09', 'High Altitude'),
('DRN10', 'Radiation Shielding');

INSERT INTO ASSIGNED_TO (O_ID, D_ID) VALUES
('OP001', 'DS001'), ('OP004', 'DS002'), ('OP005', 'DS003'),
('OP006', 'DS004'), ('OP007', 'DS005'), ('OP011', 'DS007'),
('OP012', 'DS008'), ('OP014', 'DS009');

INSERT INTO DELIVERABLES (R_ID, D_ID) VALUES
('RA001', 'DS001'), ('RA002', 'DS001'), ('RA003', 'DS002'),
('RA004', 'DS003'), ('RA005', 'DS004'), ('RA009', 'DS007'),
('RA010', 'DS007'), ('RA011', 'DS008'), ('RA012', 'DS009');


-- 4. USER AND ROLE SETUP (FOR NODE.JS/FRONTEND ACCESS)
-- --------------------------------------------------------

-- Create roles
CREATE ROLE IF NOT EXISTS 'data_viewer';
CREATE ROLE IF NOT EXISTS 'data_editor';

-- Grant privileges to roles
GRANT SELECT ON drone.* TO 'data_viewer';
GRANT SELECT, INSERT, UPDATE, DELETE ON drone.* TO 'data_editor';

-- Create and set up the 'editor_staff' user for backend connection (localhost)
-- NOTE: Uses the final, strong password: 'Dr0n3Writ3r!'
-- 4. USER AND ROLE SETUP (FOR NODE.JS/FRONTEND ACCESS)
-- --------------------------------------------------------

-- 1. Create the user for the 'localhost' host with the password.
-- This command handles user creation and password definition.
DROP USER 'editor_staff'@'localhost';
CREATE USER 'editor_staff'@'localhost' IDENTIFIED BY 'Dr0n3Writ3r!';

-- 2. Grant the explicit permissions needed for the data_editor role.
-- This replaces the complex 'GRANT role TO user' syntax with simple table permissions.
GRANT SELECT, INSERT, UPDATE, DELETE ON drone.* TO 'editor_staff'@'localhost';

-- 3. Create the user for the external IP connection.
DROP USER  'editor_staff'@'10.205.41.121';
CREATE USER 'editor_staff'@'10.205.41.121' IDENTIFIED BY 'Dr0n3Writ3r!'; 

-- 4. Grant explicit permissions to the external IP user.
GRANT SELECT, INSERT, UPDATE, DELETE ON drone.* TO 'editor_staff'@'10.205.41.121';

-- 5. Finalize changes
FLUSH PRIVILEGES;


-- enum

ALTER TABLE ALERTS
MODIFY COLUMN Severity ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL;

-- on delete cascade 

-- For ASSIGNED_TO (Operator Assignment to a Disaster)
ALTER TABLE ASSIGNED_TO
DROP FOREIGN KEY assigned_to_ibfk_2; -- Assuming this is the default FK name for D_ID

-- Recreate with CASCADE
ALTER TABLE ASSIGNED_TO
ADD CONSTRAINT FK_ASSIGNED_TO_DISASTER 
FOREIGN KEY (D_ID) 
REFERENCES DISASTER(D_ID) 
ON DELETE CASCADE;

-- For DELIVERABLES (Resource Action assigned to a Disaster)
ALTER TABLE DELIVERABLES
DROP FOREIGN KEY deliverables_ibfk_2; -- Assuming this is the default FK name for D_ID

-- Recreate with CASCADE
ALTER TABLE DELIVERABLES
ADD CONSTRAINT FK_DELIVERABLES_DISASTER
FOREIGN KEY (D_ID) 
REFERENCES DISASTER(D_ID) 
ON DELETE CASCADE;



-- trigger: Automatically increase a drone's Flying_Hours whenever 
-- a new status update is recorded for it.




DELIMITER //

CREATE TRIGGER TRG_UPDATE_FLYING_HOURS
AFTER INSERT ON DRONE_STATUS
FOR EACH ROW
BEGIN
    -- Update the Flying_Hours in the DRONE table
    UPDATE DRONE
    SET Flying_Hours = Flying_Hours + 0.50 -- Adds 0.5 hours for every new status entry
    WHERE D_NO = NEW.D_NO;
END;
//

-- Reset the delimiter back to semicolon
DELIMITER ;

SELECT D_NO, Flying_Hours FROM DRONE WHERE D_NO = 'DRN01';
INSERT INTO DRONE_STATUS (G_ID, D_NO, Latitude, Longitude, Battery) VALUES
('GS_TEST', 'DRN01', 30.00, -90.00, 99.00);




-- function : apply rating to employees





DELIMITER //

CREATE FUNCTION FN_GET_EXPERIENCE_LEVEL(
    experience INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE seniority VARCHAR(20);

    -- Apply rating based on experience level
    CASE
        WHEN experience < 3 THEN
            SET seniority = 'Novice';
        WHEN experience BETWEEN 3 AND 7 THEN
            SET seniority = 'Intermediate';
        WHEN experience BETWEEN 8 AND 10 THEN
            SET seniority = 'Senior';
        ELSE
            SET seniority = 'Expert';
    END CASE;

    RETURN seniority;
END //

-- Reset the delimiter back to semicolon
DELIMITER ;

SELECT FN_GET_EXPERIENCE_LEVEL(10) AS Seniority_Rating;





-- procedures: SP_RESOLVE_DISASTER, is designed to be the definitive, single-click mechanism for 
-- closing out an ongoing disaster event in your database.





DELIMITER //

CREATE PROCEDURE SP_RESOLVE_DISASTER(
    IN disaster_id CHAR(10)
)
BEGIN
    -- 1. Check if the disaster is currently ongoing (End_Time is NULL)
    IF EXISTS (
        SELECT 1 FROM DISASTER 
        WHERE D_ID = disaster_id AND End_Time IS NULL
    ) THEN
        -- 2. Update the End_Time to the current timestamp
        UPDATE DISASTER
        SET End_Time = NOW()
        WHERE D_ID = disaster_id;

        -- 3. Report success
        SELECT CONCAT('Disaster ', disaster_id, ' successfully closed at ', NOW()) AS Status;
    ELSE
        -- 4. Report failure (already resolved or ID invalid)
        SELECT CONCAT('Disaster ', disaster_id, ' is already resolved or does not exist.') AS Status;
    END IF;
END //

-- Reset the delimiter back to semicolon
DELIMITER ;


SELECT D_ID, Name, End_Time FROM DISASTER WHERE End_Time IS NULL LIMIT 1;
CALL SP_RESOLVE_DISASTER('DS002');






-- sql complex queries:



-- 1. analyze the performance of missions against different types of disasters.




SELECT 
    D.Type AS Disaster_Type,
    -- Calculate the average success rate for all missions associated with this disaster type
    ROUND(AVG(MR.Success_Rate), 2) AS Average_Success_Rate,
    COUNT(MR.MR_ID) AS Total_Missions_Completed
FROM 
    DISASTER D
JOIN 
    DRONE DR ON D.D_ID = DR.D_ID
JOIN 
    ALERTS A ON DR.D_NO = A.D_NO
JOIN 
    MISSION_REPORT MR ON A.MR_ID = MR.MR_ID
GROUP BY 
    D.Type
HAVING
    COUNT(MR.MR_ID) > 1 -- Only show types with more than one mission recorded
ORDER BY 
    Average_Success_Rate DESC;
    
    
    
    
    
-- 2. list of personnel who are currently available for deployment to a new, urgent disaster.





SELECT
    O_ID,
    Name,
    Certification
FROM 
    OPERATOR
WHERE 
    O_ID NOT IN (
        -- Subquery: Find the O_ID of operators currently assigned to an ONGOING disaster (End_Time IS NULL)
        SELECT 
            A.O_ID
        FROM 
            ASSIGNED_TO A
        JOIN 
            DISASTER D ON A.D_ID = D.D_ID
        WHERE 
            D.End_Time IS NULL
    )
ORDER BY 
    Name;
    
    
    
    
    
    
-- 3. dentify drones with a high number of critical alerts, flagging them for maintenance.






SELECT
    A.D_NO,
    D.Model,
    COUNT(A.A_ID) AS Critical_Alert_Count
FROM
    ALERTS A
JOIN
    DRONE D ON A.D_NO = D.D_NO
WHERE
    A.Severity IN ('High', 'Critical')
GROUP BY
    A.D_NO, D.Model
HAVING
    COUNT(A.A_ID) >= 2 -- Filters for drones with 2 or more serious alerts
ORDER BY
    Critical_Alert_Count DESC;
    
    
    
    
    
    
    
-- 4. calculate the total quantity of resources deployed for each ongoing disaster.






SELECT
    D.D_ID,
    D.Name AS Disaster_Name,
    D.Type,
    SUM(RA.Quantity) AS Total_Resources_Used
FROM
    DISASTER D
JOIN
    DELIVERABLES DL ON D.D_ID = DL.D_ID
JOIN
    RESOURCE_ACTION RA ON DL.R_ID = RA.R_ID
WHERE
    D.End_Time IS NULL -- Focus only on Ongoing Disasters
GROUP BY
    D.D_ID, D.Name, D.Type
ORDER BY
    Total_Resources_Used DESC;
    
    
    
    
    
    
    
-- 5. to categorize drones into payload tiers and then calculates the average flying hours and total payload for each tier.






SELECT
    -- Use a CASE statement to categorize drones by payload size
    CASE
        WHEN Payload <= 1.0 THEN 'Light (< 1 kg)'
        WHEN Payload <= 5.0 THEN 'Medium (1-5 kg)'
        ELSE 'Heavy (> 5 kg)'
    END AS Payload_Tier,
    COUNT(D_NO) AS Total_Drones,
    ROUND(AVG(Flying_Hours), 2) AS Avg_Flying_Hours,
    SUM(Payload) AS Total_Payload_Capacity
FROM
    DRONE
GROUP BY
    Payload_Tier
ORDER BY
    Total_Drones DESC;
    
    
    
    
    
    
    -- user creation : mysql -u editor_staff -p and mysql -u viewer_user -p

-- password: View0nly! and Dr0n3Writ3r!
    
    
    
    
CREATE USER 'viewer_user'@'localhost' IDENTIFIED BY 'View0nly!';
GRANT SELECT ON drone.* TO 'viewer_user'@'localhost';
FLUSH PRIVILEGES;

