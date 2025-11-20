// ================================
// Drone Disaster Response Dashboard Backend (CJS Version)
// ================================
const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
const path = require("path");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(__dirname)); // serve static files

(async () => {
  try {
    const con = await mysql.createConnection({
      host: "localhost",
      user: "editor_staff",
      password: "Dr0n3Writ3r!",
      database: "drone",
    });

    console.log("✅ Connected to MySQL database");

    // ------------------------------------
    // Ensure APP_USERS table exists (for GUI user management)
    // ------------------------------------
    await con.query(`
      CREATE TABLE IF NOT EXISTS APP_USERS (
        Username VARCHAR(50) PRIMARY KEY,
        Password VARCHAR(100),
        Role ENUM('viewer','editor') NOT NULL
      )
    `);

    // Serve index.html
    app.get("/", (req, res) => {
      res.sendFile(path.join(__dirname, "index.html"));
    });

    // -----------------------------
    // Helper lists for dropdowns
    // -----------------------------
    app.get("/api/list/disasters", async (req, res) => {
      const [rows] = await con.query(
        `SELECT D_ID, Name FROM DISASTER ORDER BY Start_Time DESC`
      );
      res.json(rows);
    });
    app.get("/api/list/drones", async (req, res) => {
      const [rows] = await con.query(
        `SELECT D_NO, Model FROM DRONE ORDER BY D_NO`
      );
      res.json(rows);
    });
    app.get("/api/list/operators", async (req, res) => {
      const [rows] = await con.query(
        `SELECT O_ID, Name FROM OPERATOR ORDER BY Name`
      );
      res.json(rows);
    });
    app.get("/api/list/missions", async (req, res) => {
      const [rows] = await con.query(
        `SELECT MR_ID FROM MISSION_REPORT ORDER BY MR_ID DESC`
      );
      res.json(rows);
    });

    // ================================
    // Overview Endpoint
    // ================================
    app.get("/api/overview", async (req, res) => {
      try {
        const [activeDisasters] = await con.query(
          `SELECT COUNT(*) AS count FROM DISASTER WHERE End_Time IS NULL`
        );

        const [ongoingMissions] = await con.query(`
          SELECT COUNT(DISTINCT MR.MR_ID) AS count
          FROM MISSION_REPORT MR
          JOIN ALERTS A ON MR.MR_ID = A.MR_ID
          JOIN DRONE DR ON A.D_NO = DR.D_NO
          JOIN DISASTER D ON DR.D_ID = D.D_ID
          WHERE D.End_Time IS NULL
        `);

        const [completedMissions] = await con.query(
          `SELECT COUNT(*) AS count FROM MISSION_REPORT`
        );

        const [totalDrones] = await con.query(
          `SELECT COUNT(*) AS count FROM DRONE`
        );

        const maintenanceDrones = [{ count: 0 }];

        const [disasters] = await con.query(`
          SELECT
            Name,
            Type,
            Location,
            Start_Time,
            CASE WHEN End_Time IS NULL THEN 'Ongoing' ELSE 'Resolved' END AS Status
          FROM DISASTER
          ORDER BY Start_Time DESC
          LIMIT 5;
        `);

        const [personnel] = await con.query(`
          SELECT Name, Certification
          FROM OPERATOR
          ORDER BY Name
        `);

        res.json({
          activeDisasters: activeDisasters[0].count,
          ongoingMissions: ongoingMissions[0].count,
          completedMissions: completedMissions[0].count,
          totalDrones: totalDrones[0].count,
          maintenanceDrones: maintenanceDrones[0].count,
          disasters,
          personnel,
        });
      } catch (err) {
        console.error("Error fetching overview:", err);
        res.status(500).json({ error: "Failed to load overview" });
      }
    });

    // ================================
    // Query Endpoints (1–5)
    // ================================
    app.get("/api/query1", async (req, res) => {
      try {
        const [rows] = await con.query(`
          SELECT 
            D.Type AS Disaster_Type,
            ROUND(AVG(MR.Success_Rate), 2) AS Average_Success_Rate,
            COUNT(MR.MR_ID) AS Total_Missions_Completed
          FROM DISASTER D
          JOIN DRONE DR ON D.D_ID = DR.D_ID
          JOIN ALERTS A ON DR.D_NO = A.D_NO
          JOIN MISSION_REPORT MR ON A.MR_ID = MR.MR_ID
          GROUP BY D.Type
          HAVING COUNT(MR.MR_ID) > 1
          ORDER BY Average_Success_Rate DESC;
        `);
        res.json(rows);
      } catch (err) {
        console.error("Error in query1:", err);
        res.status(500).json({ error: "Failed to load data" });
      }
    });

    app.get("/api/query2", async (req, res) => {
      try {
        const [rows] = await con.query(`
          SELECT O_ID, Name, Certification
          FROM OPERATOR
          WHERE O_ID NOT IN (
              SELECT A.O_ID
              FROM ASSIGNED_TO A
              JOIN DISASTER D ON A.D_ID = D.D_ID
              WHERE D.End_Time IS NULL
          )
          ORDER BY Name;
        `);
        res.json(rows);
      } catch (err) {
        console.error("Error in query2:", err);
        res.status(500).json({ error: "Failed to load data" });
      }
    });

    app.get("/api/query3", async (req, res) => {
      try {
        const [rows] = await con.query(`
          SELECT A.D_NO, D.Model, COUNT(A.A_ID) AS Critical_Alert_Count
          FROM ALERTS A
          JOIN DRONE D ON A.D_NO = D.D_NO
          WHERE A.Severity IN ('High','Critical')
          GROUP BY A.D_NO, D.Model
          ORDER BY Critical_Alert_Count DESC;
        `);
        res.json(rows);
      } catch (err) {
        console.error("Error in query3:", err);
        res.status(500).json({ error: "Failed to load data" });
      }
    });

    app.get("/api/query4", async (req, res) => {
      try {
        const [rows] = await con.query(`
          SELECT D.D_ID, D.Type AS Disaster_Type,
                 COUNT(DR.D_NO) AS Active_Drones,
                 ROUND(SUM(DR.Payload), 2) AS Total_Payload_Used
          FROM DISASTER D
          JOIN DRONE DR ON D.D_ID = DR.D_ID
          WHERE D.End_Time IS NULL
          GROUP BY D.D_ID, D.Type;
        `);
        res.json(rows);
      } catch (err) {
        console.error("Error in query4:", err);
        res.status(500).json({ error: "Failed to load data" });
      }
    });

    app.get("/api/query5", async (req, res) => {
      try {
        const [rows] = await con.query(`
          SELECT 
            CASE
              WHEN Payload <= 10 THEN 'Light'
              WHEN Payload BETWEEN 10.01 AND 25 THEN 'Medium'
              ELSE 'Heavy'
            END AS Payload_Tier,
            COUNT(*) AS Total_Drones
          FROM DRONE
          GROUP BY Payload_Tier
          ORDER BY Payload_Tier;
        `);
        res.json(rows);
      } catch (err) {
        console.error("Error in query5:", err);
        res.status(500).json({ error: "Failed to load data" });
      }
    });

    // ================================
    // INSERT ROUTES
    // ================================
    // Add Disaster
    app.post("/api/add-disaster", async (req, res) => {
      try {
        const { D_ID, Name, Type, Location, Start_Time } = req.body;
        await con.query(
          `INSERT INTO DISASTER (D_ID, Name, Type, Location, Start_Time)
           VALUES (?, ?, ?, ?, ?)`,
          [D_ID, Name, Type, Location, Start_Time]
        );
        res.json({ success: true, message: "✅ Disaster added successfully!" });
      } catch (err) {
        console.error("❌ Insert disaster error:", err);
        res.status(500).json({ error: "Failed to add disaster" });
      }
    });

    // Add Drone
    app.post("/api/add-drone", async (req, res) => {
      try {
        const { D_NO, Model, Payload, Flying_Hours, D_ID } = req.body;
        await con.query(
          `INSERT INTO DRONE (D_NO, Model, Payload, Flying_Hours, D_ID)
           VALUES (?, ?, ?, ?, ?)`,
          [D_NO, Model, Payload || null, Flying_Hours || null, D_ID]
        );
        res.json({ success: true, message: "✅ Drone added successfully!" });
      } catch (err) {
        console.error("❌ Insert drone error:", err);
        res.status(500).json({ error: "Failed to add drone" });
      }
    });

    // Add Operator
    app.post("/api/add-operator", async (req, res) => {
      try {
        const { O_ID, Name, Certification } = req.body;
        await con.query(
          `INSERT INTO OPERATOR (O_ID, Name, Certification)
           VALUES (?, ?, ?)`,
          [O_ID, Name, Certification || null]
        );
        res.json({ success: true, message: "✅ Operator added successfully!" });
      } catch (err) {
        console.error("❌ Insert operator error:", err);
        res.status(500).json({ error: "Failed to add operator" });
      }
    });

    // Add Mission Report
    app.post("/api/add-mission", async (req, res) => {
      try {
        const {
          MR_ID,
          Battery_Remaining,
          Distance_Covered,
          Success_Rate,
          People_Aided,
        } = req.body;
        await con.query(
          `INSERT INTO MISSION_REPORT (MR_ID, Battery_Remaining, Distance_Covered, Success_Rate, People_Aided)
           VALUES (?, ?, ?, ?, ?)`,
          [
            MR_ID,
            Battery_Remaining || null,
            Distance_Covered || null,
            Success_Rate || null,
            People_Aided || 0,
          ]
        );
        res.json({
          success: true,
          message: "✅ Mission report added successfully!",
        });
      } catch (err) {
        console.error("❌ Insert mission error:", err);
        res.status(500).json({ error: "Failed to add mission report" });
      }
    });

    // Add Alert
    app.post("/api/add-alert", async (req, res) => {
      try {
        const { A_ID, Resolution, MR_ID, Type, Severity, Time, D_NO } = req.body;
        await con.query(
          `INSERT INTO ALERTS (A_ID, Resolution, MR_ID, Type, Severity, Time, D_NO)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [A_ID, Resolution || null, MR_ID, Type || null, Severity, Time, D_NO]
        );
        res.json({ success: true, message: "✅ Alert added successfully!" });
      } catch (err) {
        console.error("❌ Insert alert error:", err);
        res.status(500).json({ error: "Failed to add alert" });
      }
    });

    // Resolve Disaster (set End_Time = NOW())
    app.post("/api/resolve-disaster", async (req, res) => {
      try {
        const { D_ID } = req.body;
        const [result] = await con.query(
          `UPDATE DISASTER SET End_Time = NOW() WHERE D_ID = ?`,
          [D_ID]
        );
        if (result.affectedRows === 0) {
          return res.status(404).json({ error: "Disaster ID not found" });
        }
        res.json({ success: true, message: "✅ Disaster marked as resolved." });
      } catch (err) {
        console.error("❌ Resolve disaster error:", err);
        res.status(500).json({ error: "Failed to resolve disaster" });
      }
    });

    // ================================
    // NEW: DELETE DISASTER ROUTE (for GUI Delete operation)
    // ================================
    app.post("/api/delete-disaster", async (req, res) => {
      try {
        const { D_ID } = req.body;
        if (!D_ID) {
          return res
            .status(400)
            .json({ success: false, message: "D_ID is required" });
        }

        const [result] = await con.query(
          `DELETE FROM DISASTER WHERE D_ID = ?`,
          [D_ID]
        );

        if (result.affectedRows === 0) {
          return res.status(404).json({
            success: false,
            message: "No disaster found with that ID (or already deleted).",
          });
        }

        res.json({
          success: true,
          message: `✅ Disaster ${D_ID} deleted successfully.`,
        });
      } catch (err) {
        console.error("❌ Delete disaster error:", err);
        // likely foreign key constraint
        res.status(500).json({
          success: false,
          message:
            "Failed to delete disaster. It may be referenced by other tables.",
        });
      }
    });

    // ================================
    // NEW: APP USER MANAGEMENT ROUTES
    // ================================
    // Create or update an app-level user
    app.post("/api/app-users/create", async (req, res) => {
      try {
        const { username, password, role } = req.body;

        if (!username || !role) {
          return res.status(400).json({
            success: false,
            message: "Username and role are required",
          });
        }

        // Upsert-style logic: if exists, update; else, insert
        await con.query(
          `
          INSERT INTO APP_USERS (Username, Password, Role)
          VALUES (?, ?, ?)
          ON DUPLICATE KEY UPDATE Password = VALUES(Password), Role = VALUES(Role)
        `,
          [username, password || null, role]
        );

        res.json({
          success: true,
          message: `✅ App user '${username}' saved with role '${role}'.`,
        });
      } catch (err) {
        console.error("❌ Create app user error:", err);
        res
          .status(500)
          .json({ success: false, message: "Failed to save app user" });
      }
    });

    // List all app-level users
    app.get("/api/app-users", async (req, res) => {
      try {
        const [rows] = await con.query(
          `SELECT Username, Role FROM APP_USERS ORDER BY Username`
        );
        res.json(rows);
      } catch (err) {
        console.error("❌ Fetch app users error:", err);
        res.status(500).json({ success: false, message: "Failed to load users" });
      }
    });

    // ================================
    // Start Server
    // ================================
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("❌ MySQL connection failed:", err);
    process.exit(1);
  }
})();
