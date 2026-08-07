<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json");

//  OPTIONS FIX
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

//  DB CONNECT
$conn = new mysqli("localhost", "root", "", "erp_app", 3307);

if ($conn->connect_error) {
    echo json_encode(["status" => "db_error", "error" => $conn->connect_error]);
    exit();
}

//  GET INPUT
$task = $_GET['task'] ?? '';
$data = json_decode(file_get_contents("php://input"), true);

// =======================================================
//  ADD SALES INVOICE
// =======================================================
if ($task == "add") {

      //  VALIDATION
if (
    empty($data['company_id']) ||
    empty($data['invoice_no']) ||
    empty($data['invoice_date'])
) {
    echo json_encode([
        "status" => "error",
        "message" => "Required fields missing"
    ]);
    exit();
}

    //  VALIDATE ITEMS
    if (!isset($data['items']) || !is_array($data['items']) || count($data['items']) == 0) {
        echo json_encode(["status" => "no_items"]);
        exit();
    }

    //  START TRANSACTION (VERY IMPORTANT)
    $conn->begin_transaction();

    try {

        // 🔹 HEADER INSERT
        $sql = "INSERT INTO sales_invoice (
            company_id, invoice_no, invoice_date,  list_name, dealer_id, buying_name,
            buying_address1, buying_address2, buying_address3,
            buying_district, buying_city, buying_state, buying_pincode,
            place_of_supply,
            delivery_name, delivery_address1, delivery_address2, delivery_address3,
            delivery_district, delivery_city, delivery_state, delivery_pincode,
            discount, freight, grand_total
        ) VALUES (
            '{$data['company_id']}',
            '{$data['invoice_no']}',
            '{$data['invoice_date']}',
            '{$data['list_name']}',
            '{$data['dealer_id']}',
            '{$data['buying_name']}',
            '{$data['buying_address1']}',
            '{$data['buying_address2']}',
            '{$data['buying_address3']}',
            '{$data['buying_district']}',
            '{$data['buying_city']}',
            '{$data['buying_state']}',
            '{$data['buying_pincode']}',
            '{$data['place_of_supply']}',
            '{$data['delivery_name']}',
            '{$data['delivery_address1']}',
            '{$data['delivery_address2']}',
            '{$data['delivery_address3']}',
            '{$data['delivery_district']}',
            '{$data['delivery_city']}',
            '{$data['delivery_state']}',
            '{$data['delivery_pincode']}',
            '{$data['discount']}',
            '{$data['freight']}',
            '{$data['grand_total']}'
        )";

        if (!$conn->query($sql)) {
            throw new Exception("Header Error: " . $conn->error);
        }

        $invoice_id = $conn->insert_id;

        // 🔹 ITEMS INSERT
        foreach ($data['items'] as $item) {

            //  skip empty rows
            if (empty($item['item_id'])) continue;

            $sql2 = "INSERT INTO sales_invoice_items (
                invoice_id, item_id, part_no, product_name,
                actual_qty, billed_qty, rate, discount,
                amount, hsn_code, gst, cgst_per, sgst_per, igst_per,
                cgst_amt, sgst_amt, igst_amt, net_amt
            ) VALUES (
                '$invoice_id',
                '{$item['item_id']}',
                '{$item['part_no']}',
                '{$item['product_name']}',
                '{$item['actual_qty']}',
                '{$item['billed_qty']}',
                '{$item['rate']}',
                '{$item['discount']}',
                '{$item['amount']}',
                '{$item['hsn_code']}',
                '{$item['gst']}',
                '{$item['cgst_per']}',
                '{$item['sgst_per']}',
                '{$item['igst_per']}',
                '{$item['cgst_amt']}',
                '{$item['sgst_amt']}',
                '{$item['igst_amt']}',
                '{$item['net_amt']}'
            )";

            if (!$conn->query($sql2)) {
                throw new Exception("Item Error: " . $conn->error);
            }
        }

        //  COMMIT
        $conn->commit();

        echo json_encode([
            "status" => "success",
            "invoice_id" => $invoice_id
        ]);

    } catch (Exception $e) {

        //  ROLLBACK
        $conn->rollback();

        echo json_encode([
            "status" => "error",
            "message" => $e->getMessage()
        ]);
    }

    exit();
}



// =======================================================
//  GET NEXT INVOICE NUMBER
// =======================================================
if ($task == "get_invoice") {

    $company_id = $_GET['company_id'];

    $sql = "SELECT MAX(invoice_no) as lastNo 
            FROM sales_invoice 
            WHERE company_id = '$company_id'";

    $result = $conn->query($sql);
    $row = $result->fetch_assoc();

    $nextNo = 1;

    if ($row['lastNo'] != null) {
        $nextNo = $row['lastNo'] + 1;
    }

    echo json_encode([
        "status" => "success",
        "next_invoice" => $nextNo
    ]);
       exit();
}

// =======================================================
//  GET SALES REGISTER
if ($task == "sales_register") {

    $company_id = $_GET['company_id'];
    $from = $_GET['from_date'];
    $to = $_GET['to_date'];

   $sql = "SELECT invoice_no, invoice_date, dealer_id, buying_name, grand_total 
        FROM sales_invoice
        WHERE company_id = '$company_id'
        AND DATE(created_at) BETWEEN '$from' AND '$to'";

    $result = $conn->query($sql);

    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode(["status" => "success", "data" => $data]);
    exit();
}

// =======================================================
//  GET ALL INVOICES
// =======================================================
else if ($task == "get") {

    $result = $conn->query("SELECT * FROM sales_invoice ORDER BY id DESC");

    $dataArr = [];

    while ($row = $result->fetch_assoc()) {

        $invoice_id = $row['id'];

        $items = [];
        $res2 = $conn->query("SELECT * FROM sales_invoice_items WHERE invoice_id=$invoice_id");

        while ($r2 = $res2->fetch_assoc()) {
            $items[] = $r2;
        }

        $row['items'] = $items;

        $dataArr[] = $row;
    }

    echo json_encode($dataArr);
       exit();
}


// =======================================================
//  DELETE
// =======================================================
else if ($task == "delete") {

    $id = $_GET['id'];

    $conn->query("DELETE FROM sales_invoice_items WHERE invoice_id=$id");

    $conn->query("DELETE FROM sales_invoice WHERE id=$id");

    echo json_encode(["status" => "deleted"]);
}


// =======================================================
//  UPDATE
// =======================================================
else if ($task == "update") {

    $id = $data['id'];

    // 🔹 UPDATE HEADER
    $sql = "UPDATE sales_invoice SET
        company_id='{$data['company_id']}',
        invoice_no = '{$data['invoice_no']}',
        invoice_date = '{$data['invoice_date']}',
        dealer_id='{$data['dealer_id']}',
        buying_name='{$data['buying_name']}',
        buying_address1='{$data['buying_address1']}',
        buying_address2='{$data['buying_address2']}',
        buying_address3='{$data['buying_address3']}',
        buying_district='{$data['buying_district']}',
        buying_city='{$data['buying_city']}',
        buying_state='{$data['buying_state']}',
        buying_pincode='{$data['buying_pincode']}',
        place_of_supply='{$data['place_of_supply']}',
        delivery_name='{$data['delivery_name']}',
        delivery_address1='{$data['delivery_address1']}',
        delivery_address2='{$data['delivery_address2']}',
        delivery_address3='{$data['delivery_address3']}',
        delivery_district='{$data['delivery_district']}',
        delivery_city='{$data['delivery_city']}',
        delivery_state='{$data['delivery_state']}',
        delivery_pincode='{$data['delivery_pincode']}',
        discount='{$data['discount']}',
        freight='{$data['freight']}',
        grand_total='{$data['grand_total']};
        WHERE id=$id";

    if (!$conn->query($sql)) {
        echo json_encode(["status" => "error"]);
        exit();
    }

    //  DELETE OLD ITEMS
    $conn->query("DELETE FROM sales_invoice_items WHERE invoice_id=$id");

    //  INSERT NEW ITEMS
    foreach ($data['items'] as $item) {

        $conn->query("INSERT INTO sales_invoice_items (
            invoice_id, item_id, part_no, product_name,
            actual_qty, billed_qty, rate, discount,
            amount, hsn_code, gst, cgst_per, sgst_per, igst_per,
            cgst_amt, sgst_amt, igst_amt, net_amt
        ) VALUES (
            '$id',
            '{$item['item_id']}',
            '{$item['part_no']},
            '{$item['product_name']}',            
            '{$item['actual_qty']}',
            '{$item['billed_qty']}',
            '{$item['rate']}',
            '{$item['discount']}',
            '{$item['amount']}',
            '{$item['hsn_code']}',
            '{$item['gst']}',
            '{$item['cgst_per']}',
            '{$item['sgst_per']}',
            '{$item['igst_per']}',
            '{$item['cgst_amt']}',
            '{$item['sgst_amt']}',
            '{$item['igst_amt']}',
            '{$item['net_amt']}'
        )");
    }

    echo json_encode(["status" => "updated"]);
}


// =======================================================
else {
    echo json_encode(["status" => "invalid_task"]);
}

$conn->close();

?>