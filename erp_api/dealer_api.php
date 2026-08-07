<?php 

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");

// 🔥 OPTIONS FIX
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 🔥 DB CONNECT
$conn = new mysqli("localhost", "root", "", "erp_app", 3307);

if ($conn->connect_error) {
    echo json_encode(["status" => "db_error"]);
    exit();
}

$task = $_GET['task'] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

// =======================================================
// 🔥 ADD DEALER
// =======================================================
if ($task == "add") {

    // 🔥 VALIDATION
  $company_id = $data['company_id'] ?? '';
$company_ref_id = $data['company_ref_id'] ?? 0;

if ($company_ref_id == 0) {
    echo json_encode([
        "status" => "error",
        "message" => "company_ref_id missing"
    ]);
    exit();
}

    $sql = "INSERT INTO dealer_master 
    (company_id, dealer_id, dealer_name, address1, address2, address3,
    district, city, pincode, state, country, gstin, salesman,
    mobile, email, website, opening_bal, company_ref_id, is_deleted)
    VALUES 
    (
        '{$data['company_id']}',
        '{$data['dealer_id']}',
        '{$data['dealer_name']}',
        '{$data['address1']}',
        '{$data['address2']}',
        '{$data['address3']}',
        '{$data['district']}',
        '{$data['city']}',
        '{$data['pincode']}',
        '{$data['state']}',
        '{$data['country']}',
        '{$data['gstin']}',
        '{$data['salesman']}',
        '{$data['mobile']}',
        '{$data['email']}',
        '{$data['website']}',
        '{$data['opening_bal']}',
        '{$data['company_ref_id']}',
        0
    )";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "error" => $conn->error]);
    }

    exit();
}


// =======================================================
// 🔥 GET DEALERS (ONLY ACTIVE)
// =======================================================
if ($task == "get") {

    $result = $conn->query("
        SELECT * FROM dealer_master 
        WHERE is_deleted = 0
        ORDER BY id DESC
    ");

    $output = [];

    while ($row = $result->fetch_assoc()) {
        $output[] = $row;
    }

    echo json_encode($output);
    exit();
}


// =======================================================
// 🔥 DELETE (SOFT DELETE)
// =======================================================
if ($task == "delete") {

    $id = $_GET['id'] ?? '';

    if (empty($id)) {
        echo json_encode(["status" => "error", "message" => "ID missing"]);
        exit();
    }

    $sql = "UPDATE dealer_master 
            SET is_deleted = 1 
            WHERE id = '$id'";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "deleted"]);
    } else {
        echo json_encode(["status" => "error"]);
    }

    exit();
}


// =======================================================
// 🔥 UPDATE
// =======================================================
if ($task == "update") {

    $id = $data['id'];

    $sql = "UPDATE dealer_master SET
        company_id='{$data['company_id']}',
        dealer_id='{$data['dealer_id']}',
        dealer_name='{$data['dealer_name']}',
        address1='{$data['address1']}',
        address2='{$data['address2']}',
        address3='{$data['address3']}',
        district='{$data['district']}',
        city='{$data['city']}',
        pincode='{$data['pincode']}',
        state='{$data['state']}',
        country='{$data['country']}',
        gstin='{$data['gstin']}',
        salesman='{$data['salesman']}',
        mobile='{$data['mobile']}',
        email='{$data['email']}',
        website='{$data['website']}',
        opening_bal='{$data['opening_bal']}'
        WHERE id='$id'";

    if ($conn->query($sql)) {
        echo json_encode(["status" => "updated"]);
    } else {
        echo json_encode(["status" => "error"]);
    }

    exit();
}

$conn->close();
?>