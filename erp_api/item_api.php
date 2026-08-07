<?php

// ================= HEADERS =================
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ================= DB =================
$conn = new mysqli("localhost", "root", "", "erp_app", 3307);

if ($conn->connect_error) {
    echo json_encode([
        "status" => "db_error",
        "error" => $conn->connect_error
    ]);
    exit();
}

// ================= INPUT =================
$task = $_GET['task'] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

// ======================================================
// 🔥 ADD ITEM (WITH company_ref_id + is_deleted)
// ======================================================
if ($task == "add") {

    if (
        empty($data['company_id']) ||
        empty($data['company_ref_id']) ||
        empty($data['description'])
    ) {
        echo json_encode([
            "status" => "error",
            "message" => "Company & Description required"
        ]);
        exit();
    }

    $company_id = $conn->real_escape_string($data['company_id']);
    $company_ref_id = intval($data['company_ref_id']);
    $desc = $conn->real_escape_string($data['description']);

    // 🔥 DUPLICATE CHECK (COMPANY WISE)
    $check = $conn->query("
        SELECT id FROM item_master 
        WHERE description='$desc' 
        AND company_ref_id='$company_ref_id'
        AND is_deleted = 0
    ");

    if ($check && $check->num_rows > 0) {
        echo json_encode(["status" => "exists"]);
        exit();
    }

    $sql = "INSERT INTO item_master 
    (
        company_id, company_ref_id, item_id, part_no, description,
        unit, alt_unit, conversion, dominator,
        hsn_code, gst_per,
        opening_stk, opening_rate, opening_bal,
        is_deleted
    )
    VALUES (
        '$company_id',
        '$company_ref_id',
        '".$conn->real_escape_string($data['item_id'])."',
        '".$conn->real_escape_string($data['part_no'])."',
        '$desc',
        '".$conn->real_escape_string($data['unit'])."',
        '".$conn->real_escape_string($data['alt_unit'])."',
        '".$conn->real_escape_string($data['conversion'])."',
        '".$conn->real_escape_string($data['dominator'])."',
        '".$conn->real_escape_string($data['hsn_code'])."',
        '".$conn->real_escape_string($data['gst_per'])."',
        '".$conn->real_escape_string($data['opening_stk'])."',
        '".$conn->real_escape_string($data['opening_rate'])."',
        '".$conn->real_escape_string($data['opening_bal'])."',
        0
    )";

    if ($conn->query($sql)) {
        echo json_encode([
            "status" => "success",
            "id" => $conn->insert_id
        ]);
    } else {
        echo json_encode([
            "status" => "sql_error",
            "error" => $conn->error
        ]);
        exit();
    }
}


// ======================================================
if ($task == "get_by_list") {

    $company_id = $_GET['company_id'];
    $list_name  = $_GET['list_name'];

    $sql = "SELECT 
                im.item_id,
                im.description,
                im.part_no,
                im.hsn_code,
                im.gst_per,
                pl.rate
            FROM price_list pl
            JOIN item_master im 
                ON pl.item_id = im.item_id
            WHERE 
                pl.company_id = ?
                AND pl.list_name = ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $company_id, $list_name);
    $stmt->execute();

    $result = $stmt->get_result();

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit();
}


// ======================================================
else if ($task == "get") {

    $result = $conn->query("
        SELECT * FROM item_master
        WHERE is_deleted = 0
        ORDER BY id DESC
    ");

    $items = [];

    while ($row = $result->fetch_assoc()) {
        $items[] = $row;
    }

    echo json_encode($items);
}


// ======================================================
// 🔥 DELETE (SOFT DELETE)
// ======================================================
else if ($task == "delete") {

    $id = $_GET['id'] ?? '';

    if (empty($id)) {
        echo json_encode(["status" => "error"]);
        exit();
    }

    $sql = "UPDATE item_master 
            SET is_deleted = 1 
            WHERE id = '$id'";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "deleted"]);
    } else {
        echo json_encode([
            "status" => "error",
            "error" => $conn->error
        ]);
    }
}


// ======================================================
// 🔥 UPDATE
// ======================================================
else if ($task == "update") {

    $id = intval($data['id'] ?? 0);

    if ($id == 0) {
        echo json_encode(["status" => "invalid_id"]);
        exit();
    }

    $desc = $conn->real_escape_string($data['description']);

    // 🔥 DUPLICATE CHECK
    $check = $conn->query("
        SELECT id FROM item_master 
        WHERE description='$desc' 
        AND id != $id 
        AND is_deleted = 0
    ");

    if ($check && $check->num_rows > 0) {
        echo json_encode(["status" => "exists"]);
        exit();
    }

    $sql = "UPDATE item_master SET
        company_id='".$conn->real_escape_string($data['company_id'])."',
        company_ref_id='".intval($data['company_ref_id'])."',
        item_id='".$conn->real_escape_string($data['item_id'])."',
        part_no='".$conn->real_escape_string($data['part_no'])."',
        description='$desc',
        unit='".$conn->real_escape_string($data['unit'])."',
        alt_unit='".$conn->real_escape_string($data['alt_unit'])."',
        conversion='".$conn->real_escape_string($data['conversion'])."',
        dominator='".$conn->real_escape_string($data['dominator'])."',
        hsn_code='".$conn->real_escape_string($data['hsn_code'])."',
        gst_per='".$conn->real_escape_string($data['gst_per'])."',
        opening_stk='".$conn->real_escape_string($data['opening_stk'])."',
        opening_rate='".$conn->real_escape_string($data['opening_rate'])."',
        opening_bal='".$conn->real_escape_string($data['opening_bal'])."'
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


// ======================================================
else {
    echo json_encode(["status" => "invalid_task"]);
}

$conn->close();
?>