# Phần 4: Cấu hình gửi logs lên Grafana Loki

## Tổng quan

Phần này hướng dẫn cấu hình để các service Spring Boot gửi logs lên Grafana Loki thông qua Promtail.

## Cấu trúc logs

- **JSON Format**: Tất cả logs được xuất dưới dạng JSON
- **Trace ID**: Logs bao gồm trace ID để liên kết với Zipkin
- **Service identification**: Mỗi log có label service để phân biệt

## Các thành phần đã cấu hình

### 1. Logback Configuration

- **File**: `src/main/resources/logback-spring.xml` (cho mỗi service)
- **Features**:
  - JSON format logging
  - File appender với rotation
  - Console appender
  - Trace ID extraction

### 2. Promtail Configuration

- **File**: `docker/promtail/config.yml`
- **Features**:
  - Docker container logs collection
  - File-based logs collection
  - Multi-line parsing
  - Service labeling

### 3. Docker Compose Configuration

- **File**: `docker-compose.yml`
- **Changes**:
  - Added volume mounts for logs
  - Added logging labels
  - Configured log rotation

## Cách chạy

### Bước 1: Build và Deploy

```bash
# Cấp quyền execute cho script
chmod +x deploy-logging.sh

# Chạy script deploy
./deploy-logging.sh
```

### Bước 2: Kiểm tra logs

```bash
# Xem logs của service cụ thể
docker-compose logs -f api-gateway

# Xem logs của Promtail
docker-compose logs -f promtail

# Xem logs của Loki
docker-compose logs -f loki
```

### Bước 3: Truy cập Grafana

1. Mở trình duyệt: http://localhost:3030
2. Đăng nhập: admin/admin
3. Vào Explore → Chọn Loki datasource
4. Query logs: `{service="api-gateway"}`

## Các query logs hữu ích

### Query theo service

```logql
{service="api-gateway"}
```

### Query theo log level

```logql
{service="customers-service"} |= "ERROR"
```

### Query theo trace ID

```logql
{job="docker-containers"} | json | traceId="abc123"
```

### Query logs trong khoảng thời gian

```logql
{service="visits-service"} | json | level="INFO" | __timestamp__ > now() - 1h
```

## Cấu trúc thư mục logs

```
logs/
├── spring-petclinic/
│   ├── api-gateway.log
│   ├── customers-service.log
│   ├── visits-service.log
│   ├── vets-service.log
│   └── genai-service.log
└── [Docker container logs tự động thu thập]
```

## Xử lý sự cố

### Lỗi: Logs không xuất hiện trong Loki

1. Kiểm tra Promtail logs: `docker-compose logs promtail`
2. Kiểm tra Loki logs: `docker-compose logs loki`
3. Xác minh file paths trong promtail config

### Lỗi: JSON parsing thất bại

1. Kiểm tra format logs trong file log
2. Xem lại cấu hình logback-spring.xml
3. Restart service sau khi thay đổi config

### Lỗi: Permission denied trên thư mục logs

```bash
# Cấp quyền write cho thư mục logs
chmod -R 777 logs/
```

## Kết quả mong đợi

Sau khi cấu hình thành công:

- ✅ Logs được gửi tới Loki qua Promtail
- ✅ Có thể query logs trong Grafana
- ✅ Logs có format JSON với trace ID
- ✅ Phân biệt được logs theo service

## Bước tiếp theo

Phần 5: Cấu hình Grafana để hiển thị biểu đồ metrics
Phần 6: Cấu hình Grafana để hiển thị logs từ Loki
Phần 7: Cấu hình alerts cho Prometheus
