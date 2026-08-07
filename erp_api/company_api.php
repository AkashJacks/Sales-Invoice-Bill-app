<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
error_reporting(E_ALL);
ini_set('display_errors', 1);

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$conn = new mysqli("localhost", "root", "", "erp_app", 3307);
if ($conn->connect_error) {
    die("DB Error: " . $conn->connect_error);
}

$task = $_GET['task'] ?? '';

$data = json_decode(file_get_contents("php://input"), true);

//  ADD COMPANY
if ($task == "add") {

    $sql = "INSERT INTO company_master 
    (company_id, company_name, address1, address2, address3, district, city, pincode, state, country, gstin, mobile, email, website)
    VALUES 
    ('{$data['company_id']}', '{$data['company_name']}', '{$data['address1']}', '{$data['address2']}', '{$data['address3']}', '{$data['district']}', '{$data['city']}', '{$data['pincode']}', '{$data['state']}', '{$data['country']}', '{$data['gstin']}', '{$data['mobile']}', '{$data['email']}', '{$data['website']}')";

    echo json_encode([
        "status" => $conn->query($sql) ? "success" : "error"
    ]);
    exit();
}

//  GET ALL COMPANIES
if ($task == "get") {

    $result = $conn->query("
        SELECT * FROM company_master 
        WHERE is_deleted = 0
        ORDER BY id DESC
    ");

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
    exit();
}

//  UPDATE COMPANY
 if ($task == "update") {

    $id = $data['id'];

    $sql = "UPDATE company_master SET
        company_id='{$data['company_id']}',
        company_name='{$data['company_name']}',
        address1='{$data['address1']}',
        address2='{$data['address2']}',
        address3='{$data['address3']}',
        district='{$data['district']}',
        city='{$data['city']}',
        pincode='{$data['pincode']}',
        state='{$data['state']}',
        country='{$data['country']}',
        gstin='{$data['gstin']}',
        mobile='{$data['mobile']}',
        email='{$data['email']}',
        website='{$data['website']}'
        WHERE id=$id";

    echo json_encode([
        "status" => $conn->query($sql) ? "updated" : "error"
    ]);
}

// =======================================================
// 🔥 DELETE COMPANY (SOFT DELETE + CASCADE)
// =======================================================
if ($task == "delete") {

    $companyId = $_GET['id'] ?? '';

    // 🔥 VALIDATION
    if (empty($companyId)) {
        echo json_encode([
            "status" => "error",
            "message" => "Company ID missing"
        ]);
        exit();
    }

    // 🔥 COMPANY DELETE
    $sql1 = "UPDATE company_master 
             SET is_deleted = 1 
             WHERE id = '$companyId'";

    // 🔥 DEALER DELETE
    $sql2 = "UPDATE dealer_master 
             SET is_deleted = 1 
             WHERE company_ref_id = '$companyId'";

    // 🔥 ITEM DELETE (🔥 THIS WAS MISSING)
    $sql3 = "UPDATE item_master 
             SET is_deleted = 1 
             WHERE company_ref_id = '$companyId'";

    $sql4 ="UPDATE price_level 
             SET is_deleted = 1 
             WHERE company_ref_id = '$companyId'";

             
    // 🔥 PRICE LIST CASCADE DELETE
    $sql5="UPDATE price_list 
              SET is_deleted = 1 
              WHERE company_ref_id = '$companyId'";

    if ($conn->query($sql1)) {

        $conn->query($sql2);
        $conn->query($sql3); // 🔥 IMPORTANT
        $conn->query($sql4);
        $conn->query($sql5);

        echo json_encode([
            "status" => "deleted"
        ]);

    } else {
        echo json_encode([
            "status" => "error",
            "error" => $conn->error
        ]);
    }

    exit();
}

$conn->close();

?>