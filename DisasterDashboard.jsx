// disasterdashboard.jsx
const { useState, useEffect } = React;

function Panel({ title, endpoint }) {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  async function fetchData() {
    setLoading(true);
    try {
      const res = await fetch(endpoint);
      const json = await res.json();
      setData(json);
    } catch (err) {
      setData([{ Error: err.message }]);
    }
    setLoading(false);
  }

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <div className="panel">
      <h3>
        {title}{" "}
        <button onClick={fetchData}>Refresh</button>
      </h3>
      {loading ? (
        <p>Loading...</p>
      ) : Array.isArray(data) && data.length > 0 ? (
        <table>
          <thead>
            <tr>
              {Object.keys(data[0]).map((key) => (
                <th key={key}>{key}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.map((row, i) => (
              <tr key={i}>
                {Object.values(row).map((val, j) => (
                  <td key={j}>{String(val)}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <p>No data found</p>
      )}
    </div>
  );
}

function Dashboard() {
  const panels = [
    { title: "1) Mission performance by Disaster Type", endpoint: "/api/query1" },
    { title: "2) Available Personnel for Deployment", endpoint: "/api/query2" },
    { title: "3) Drones flagged for maintenance (High/Critical alerts)", endpoint: "/api/query3" },
    { title: "4) Resources used by ongoing disasters", endpoint: "/api/query4" },
    { title: "5) Drone Payload Tier Summary", endpoint: "/api/query5" },
  ];

  return (
    <div className="dashboard">
      {panels.map((p, i) => (
        <Panel key={i} title={p.title} endpoint={p.endpoint} />
      ))}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<Dashboard />);
