<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
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

// =====================================
// 🔥 REGISTER
// =====================================
if ($task == "register") {

    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';

    if (empty($email) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Fill all fields"]);
        exit();
    }

    $check = $conn->query("SELECT * FROM users WHERE email='$email'");

    if ($check->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "User exists"]);
        exit();
    }

    $conn->query("INSERT INTO users (email, password) 
                  VALUES ('$email', '$password')");

    echo json_encode(["status" => "success"]);
}

// =====================================
// 🔥 LOGIN
// =====================================
if ($task == "login") {

    $email = $data['email'] ?? '';
    $password = $data['password'] ?? '';

    $sql = "SELECT * FROM users WHERE email='$email'";
    $res = $conn->query($sql);

    if ($res->num_rows == 0) {
        echo json_encode(["status" => "error", "message" => "User not found"]);
        exit();
    }

    $user = $res->fetch_assoc();

    if ($user['password'] != $password) {
        echo json_encode(["status" => "error", "message" => "Wrong password"]);
        exit();
    }

    // 🔥 NEW TOKEN (old token overwrite)
    $token = bin2hex(random_bytes(32));

    $conn->query("UPDATE users SET token='$token' WHERE id=".$user['id']);

    echo json_encode([
        "status" => "success",
        "token" => $token
    ]);
}

// =====================================
// 🔥 CHECK SESSION
// =====================================
if ($task == "check") {

    $headers = getallheaders();
    $token = $headers['Authorization'] ?? '';

    if (empty($token)) {
        echo json_encode(["status" => "unauthorized"]);
        exit();
    }

    $res = $conn->query("SELECT * FROM users WHERE token='$token'");

    if ($res->num_rows == 0) {
        echo json_encode(["status" => "session_expired"]);
        exit();
    }

    echo json_encode(["status" => "valid"]);
}