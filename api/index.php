<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Database configuration
$dbConfig = [
    'host' => 'localhost',
    'dbname' => 'algo_config',
    'user' => 'user2grey',
    'pass' => 'user2grey'
];

$datadbConfig = [
    'host' => 'localhost',
    'dbname' => 'gmblue',
    'user' => 'user2grey',
    'pass' => 'user2grey'
];

function getDB($config) {
    try {
        $pdo = new PDO(
            "mysql:host={$config['host']};dbname={$config['dbname']};charset=utf8mb4",
            $config['user'],
            $config['pass'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
        return $pdo;
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
        exit;
    }
}

function buildQuery($query, $filters, $pdo) {
    // Replace database variables if present
    $dbVars = [
        '$trans_db' => '',  // Add your actual database names
        '$master_db' => 'gmblue',
    ];
    foreach ($dbVars as $var => $value) {
        $query = str_replace($var, $value, $query);
    }

    // Handle filter replacements
    if ($filters && is_array($filters)) {
        foreach ($filters as $key => $value) {
            // Ensure the key starts with $
            $searchKey = (strpos($key, '$') === 0) ? $key : '$' . $key;
            
            // Handle different value types appropriately
            if (is_numeric($value)) {
                $query = str_replace($searchKey, $value, $query);
            } else {
                // Use PDO quote for strings to prevent SQL injection
                $query = str_replace($searchKey, $pdo->quote($value), $query);
            }
        }
    }
    return $query;
}

$basePath = '/api'; // Define the base path where index.php resides relative to doc root
$requestUri = $_SERVER['REQUEST_URI'];
$rawPath = parse_url($requestUri, PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];


// Remove the base path prefix if it exists
if (substr($rawPath, 0, strlen($basePath)) == $basePath) {
    $path = substr($rawPath, strlen($basePath));
} else {
    $path = $rawPath;
}

// Ensure the path starts with a slash for the switch statement
if (empty($path) || $path[0] !== '/') {
    $path = '/' . $path;
}
switch ($path) {
    case '/list':
        if ($method === 'GET') {
            try {
                $pdo = getDB($dbConfig);
                $stmt = $pdo->query("SELECT _id as id, ui_name as 'report_name', filters FROM ui_config");
                $reports = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo json_encode(['reports' => $reports]);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        }
        break;

    case '/execute':
        if ($method === 'POST') {
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($data['report_id'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Report ID is required']);
                break;
            }

            try {
                $pdo = getDB($dbConfig);
                $stmt = $pdo->prepare("SELECT * FROM ui_config WHERE _id = ?");
                $stmt->execute([$data['report_id']]);
                $config = $stmt->fetch(PDO::FETCH_ASSOC);

                if (!$config) {
                    http_response_code(404);
                    echo json_encode(['error' => 'Report not found']);
                    break;
                }

                // Build the query using the new function
                $query = buildQuery($config['query'], $data['filters'] ?? [], $pdo);

                // Execute the query
                $pdo = getDB($datadbConfig);
                $result = $pdo->query($query);
                if (!$result) {
                    throw new PDOException("Query execution failed");
                }
                
                $reportData = $result->fetchAll(PDO::FETCH_ASSOC);

                echo json_encode([
                    'report_id' => $config['_id'],
                    'data' => $reportData,
                    'display_options' => json_decode($config['display_options'], true),
                    'ui_type' => $config['ui_type'],
                    'sub_type' => $config['sub_type']
                ]);

            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        }
        break;

    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint not found']);
        break;
}