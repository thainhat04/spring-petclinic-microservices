#!/bin/bash

echo "=== TRIỂN KHAI PETCLINIC VỚI LOGGING ==="

# Tạo thư mục logs nếu chưa có
mkdir -p logs
mkdir -p logs/spring-petclinic

# Dọn dẹp containers cũ
echo "Dọn dẹp containers cũ..."
docker-compose down -v

# Build lại images
echo "Building images..."
mvn clean package -DskipTests
docker-compose build

# Khởi động hệ thống
echo "Khởi động hệ thống..."
docker-compose up -d

# Chờ hệ thống khởi động
echo "Chờ hệ thống khởi động..."
sleep 30

# Kiểm tra trạng thái
echo "Kiểm tra trạng thái services:"
docker-compose ps

echo "=== TRUY CẬP HỆ THỐNG ==="
echo "Petclinic UI: http://localhost:8080"
echo "Grafana: http://localhost:3030 (admin/admin)"
echo "Prometheus: http://localhost:9091"
echo "Loki: http://localhost:3100"
echo "Zipkin: http://localhost:9411"

echo "=== KIỂM TRA LOGS ==="
echo "Logs của services sẽ được lưu tại thư mục: ./logs/"
echo "Để xem logs: docker-compose logs -f [service_name]" 