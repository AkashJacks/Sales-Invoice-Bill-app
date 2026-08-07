<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$conn = new mysqli("localhost", "root", "", "erp_app", 3307);

if ($conn->connect_error) {
    echo json_encode(["status" => "db_error"]);
    exit();
}

$task = $_GET['task'] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

// =======================================================
if ($task == "add") {

    $company_id     = $data['company_id'] ?? '';
    $company_ref_id = $data['company_ref_id'] ?? '';
    $list_name      = $data['list_name'] ?? '';
    $apply_from     = $data['apply_from'] ?? '';
    $product_name   = $data['product_name'] ?? '';
    $rate           = $data['rate'] ?? '';
    $item_id        = $data['item_id']??'';

    if (
        empty($company_ref_id) ||
        empty($list_name) ||
        empty($product_name) ||
        empty($rate)
    ) {
        echo json_encode([
            "status" => "error",
            "message" => "Missing required fields"
        ]);
        exit();
    }


    // 🔥 INSERT
   $sql = "INSERT INTO price_list 
(company_id, company_ref_id, list_name, apply_from, product_name, rate, is_deleted, item_id)
VALUES 
(
    '$company_id',
    '$company_ref_id',
    '$list_name',
    '$apply_from',
    '$product_name',
    '$rate',
    0,
    '$item_id'
)";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode([
            "status" => "error",
            "error" => $conn->error
        ]);
    }

    exit();
}


// =======================================================
// 🔥 GET LIST NAME (FILTER BY company_ref_id)
// =======================================================
if ($task == "get_price_list") {

    $company_id = $_GET['company_id'];

    $result = $conn->query("
        SELECT DISTINCT list_name 
        FROM price_list 
        WHERE company_id = '$company_id'
    ");

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit();
}


// =======================================================
// GET RATE
if ($task == "get_items_by_list") {

    $company_ref_id = $_GET['company_ref_id'] ?? '';
    $list_name      = $_GET['list_name'] ?? '';

    if (empty($company_ref_id) || empty($list_name)) {
        echo json_encode([]);
        exit;
    }

    $sql = "SELECT 
                im.item_id,
                im.description,
                im.part_no,
                im.hsn_code,
                im.gst_per,
                pl.rate
            FROM price_list pl
            JOIN item_master im ON im.item_id = pl.item_id
            WHERE pl.company_ref_id = ?
            AND pl.list_name = ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("is", $company_ref_id, $list_name);
    $stmt->execute();

    $result = $stmt->get_result();

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
}
// =======================================================
else if ($task == "get") {

    $result = $conn->query("
        SELECT * FROM price_list 
        WHERE is_deleted = 0
        ORDER BY id DESC
    ");

    $dataArr = [];

    while ($row = $result->fetch_assoc()) {
        $dataArr[] = $row;
    }

    echo json_encode($dataArr);
}
// =======================================================
else if ($task == "delete") {

    $id = $_GET['id'] ?? '';

    if (empty($id)) {
        echo json_encode(["status" => "error"]);
        exit();
    }

    $sql = "UPDATE price_list 
            SET is_deleted = 1 
            WHERE id = '$id'";

    echo json_encode([
        "status" => $conn->query($sql) ? "deleted" : "error"
    ]);
}

//  UPDATE
// =======================================================
else if ($task == "update") {

    $id = $data['id'] ?? 0;

    $company_id     = $data['company_id'] ?? '';
    $company_ref_id = $data['company_ref_id'] ?? '';
    $list_name      = $data['list_name'] ?? '';
    $apply_from     = $data['apply_from'] ?? '';
    $product_name   = $data['product_name'] ?? '';
    $rate           = $data['rate'] ?? '';
    $item_id        = $data['item_id']??'';

    if ($id == 0) {
        echo json_encode(["status" => "invalid_id"]);
        exit();
    }

    $sql = "UPDATE price_list SET
        company_id='$company_id',
        company_ref_id='$company_ref_id',
        list_name='$list_name',
        apply_from='$apply_from',
        product_name='$product_name',
        rate='$rate',
        item_id='$item_id'
        WHERE id=$id";

    echo json_encode([
        "status" => $conn->query($sql) ? "updated" : "error"
    ]);
}

$conn->close();
?>  