<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 🔥 DB
$conn = new mysqli("localhost", "root", "", "erp_app", 3307);
if ($conn->connect_error) {
    echo json_encode([
        "status" => "db_error",
        "error" => $conn->connect_error
    ]);
    exit();
}

$task = $_GET['task'] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

// ============================
// 🔥 ADD PRICE LEVEL
// ============================
if ($task == "add") {

    if (
        empty($data['company_id']) ||
        empty($data['company_ref_id']) ||
        empty($data['list_name'])
    ) {
        echo json_encode([
            "status" => "error",
            "message" => "Company & List Name required"
        ]);
        exit();
    }

    $company_id = $conn->real_escape_string($data['company_id']);
    $company_ref_id = intval($data['company_ref_id']);
    $list_name = $conn->real_escape_string($data['list_name']);

    // 🔥 DUPLICATE CHECK (company wise)
    $check = $conn->query("
        SELECT id FROM price_level
        WHERE list_name = '$list_name'
        AND company_ref_id = '$company_ref_id'
        AND is_deleted = 0
    ");

    if ($check && $check->num_rows > 0) {
        echo json_encode(["status" => "exists"]);
        exit();
    }

    $sql = "INSERT INTO price_level 
    (company_id, company_ref_id, list_name, is_deleted)
    VALUES 
    ('$company_id', '$company_ref_id', '$list_name', 0)";

    if ($conn->query($sql)) {
        echo json_encode([
            "status" => "success",
            "id" => $conn->insert_id
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "error" => $conn->error
        ]);
    }
}

// ============================
// 🔥 GET (ONLY ACTIVE)
// ============================
else if ($task == "get") {

    $result = $conn->query("
        SELECT * FROM price_level
        WHERE is_deleted = 0
        ORDER BY id DESC
    ");

    $rows = [];

    while ($r = $result->fetch_assoc()) {
        $rows[] = $r;
    }

    echo json_encode($rows);
}

// ============================
// 🔥 SOFT DELETE
// ============================
else if ($task == "delete") {

    $id = $_GET['id'] ?? '';

    if (empty($id)) {
        echo json_encode([
            "status" => "error",
            "message" => "ID missing"
        ]);
        exit();
    }

    $sql = "UPDATE price_level SET is_deleted = 1 WHERE id='$id'";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "deleted"]);
    } else {
        echo json_encode([
            "status" => "error",
            "error" => $conn->error
        ]);
    }
}

// ============================
// 🔥 UPDATE
// ============================
else if ($task == "update") {

    if (
        empty($data['id']) ||
        empty($data['company_id']) ||
        empty($data['company_ref_id']) ||
        empty($data['list_name'])
    ) {
        echo json_encode([
            "status" => "error",
            "message" => "Missing fields"
        ]);
        exit();
    }

    $id = intval($data['id']);
    $company_id = $conn->real_escape_string($data['company_id']);
    $company_ref_id = intval($data['company_ref_id']);
    $list_name = $conn->real_escape_string($data['list_name']);

    // 🔥 DUPLICATE CHECK
    $check = $conn->query("
        SELECT id FROM price_level
        WHERE list_name = '$list_name'
        AND company_ref_id = '$company_ref_id'
        AND id != $id
        AND is_deleted = 0
    ");

    if ($check && $check->num_rows > 0) {
        echo json_encode(["status" => "exists"]);
        exit();
    }

    $sql = "UPDATE price_level SET
        company_id='$company_id',
        company_ref_id='$company_ref_id',
        list_name='$list_name'
        WHERE id=$id";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "updated"]);
    } else {
        echo json_encode([
            "status" => "error",
            "error" => $conn->error
        ]);
    }
}

// ============================
// 🔥 INVALID
// ============================
else {
    echo json_encode(["status" => "invalid_task"]);
}

$conn->close();
?>