# Amigo Keycloak Custom Provider & Theme (Red Hat Build of Keycloak)

Hệ thống Keycloak tích hợp **Custom SPI** (User Federation đồng bộ qua Spring Boot API) kèm theo **Custom Login Theme** (`amigo`) dành riêng cho dự án.

---

## Mục lục

1. [Hướng dẫn đăng nhập Container Registries](#1-hướng-dẫn-đăng-nhập-container-registries)
2. [Cấu trúc thư mục dự án](#2-cấu-trúc-thư-mục-dự-án)
3. [Quy trình Build, Chạy và Triển khai](#3-quy-trình-build-chạy-và-triển-khai)
4. [Cấu hình kích hoạt trên Keycloak Admin](#4-cấu-hình-kích-hoạt-trên-keycloak-admin)

---

## 1. Hướng dẫn Đăng nhập Container Registries

Trước khi tiến hành build hoặc push image lên các môi trường lưu trữ, bạn cần thực hiện đăng nhập vào các registry tương ứng.

### A. Đăng nhập Red Hat Registry (để tải base image)

Red Hat yêu cầu xác thực để kéo image `registry.redhat.io`. Bạn cần có tài khoản Red Hat Developer:

```bash
docker login registry.redhat.io
```

> Nhập Username và Password tài khoản Red Hat của bạn.

### B. Đăng nhập Quay.io (Image Registry nội bộ của Lab)

```bash
docker login quay.ocp.lab.local
```

> Nhập thông tin tài khoản truy cập Quay của bạn.

### C. Đăng nhập Harbor (nếu dự án sử dụng Harbor làm Image Registry)

```bash
docker login <dia_chi_harbor_cua_ban>
```

> Nhập username và password do quản trị viên Harbor cung cấp.

---

## 2. Cấu trúc Thư mục Dự án

```
keycloak-build-of-redhat/
├── amigo/                  # Thư mục chứa Custom Login Theme (Amigo)
├── providers/              # Chứa các file .jar của Custom SPI
├── Dockerfile              # File đóng gói Keycloak + SPI + Theme
├── docker-compose.yaml     # Cấu hình chạy local (Keycloak + PostgreSQL)
└── README.md
```

---

## 3. Quy trình Build, Chạy và Triển khai

### Bước 1: Chuẩn bị Provider và Theme

- Đảm bảo file `.jar` của SPI đã được đặt trong thư mục `providers/`.
- Thư mục giao diện `amigo` đã được đặt ngang hàng với `Dockerfile`.

### Bước 2: Build Docker Image

Thực hiện build image cục bộ chứa cả Keycloak, Custom SPI và Custom Login Theme:

```bash
docker compose build
```

Hoặc dùng lệnh Docker thuần:

```bash
docker build -t keycloak-build-of-redhat-keycloak:latest .
```

### Bước 3: Chạy ứng dụng dưới Local (Docker Compose)

Khởi động hệ thống (bao gồm PostgreSQL và Keycloak Server):

```bash
docker compose up -d
```

- **Keycloak Admin Console:** `http://localhost:8080/admin/` (Tài khoản mặc định: `admin` / `admin`)
- **Realm:** `vietinbank-demo`

### Bước 4: Tag và Push Image lên Registry (Quay.io / Harbor)

Sau khi build thành công ở local, tiến hành đẩy image lên registry để chuẩn bị deploy lên cụm OpenShift/Lab:

1. Tag image theo chuẩn phiên bản:

```bash
docker tag keycloak-build-of-redhat-keycloak:latest quay.ocp.lab.local/dinhhb/keycloak-custom:1.0
```

2. Push image lên registry:

```bash
docker push quay.ocp.lab.local/dinhhb/keycloak-custom:1.0
```

---

## 4. Cấu hình Kích hoạt trên Keycloak Admin

1. Đăng nhập trang Admin, chọn Realm `vietinbank-demo`.
2. **Kích hoạt Login Theme:** Vào `Realm settings` → tab `Themes` → mục `Login theme` chọn `amigo` → nhấn **Save**.
3. **Cấu hình User Federation (SPI):** Vào `User federation` → trỏ các URL kết nối sang Spring Boot API (ví dụ: `http://host.docker.internal:8888/api/internal/users`) và nhập `Internal API Key`.

---

## Ghi chú

- Đảm bảo các registry (`registry.redhat.io`, `quay.ocp.lab.local`, Harbor nội bộ) đã được đăng nhập thành công trước khi build/push, nếu không quá trình sẽ báo lỗi xác thực.
- Kiểm tra kỹ đường dẫn API trong cấu hình `User Federation` để đảm bảo Keycloak container có thể kết nối tới Spring Boot API (đặc biệt khi chạy trên Docker Desktop cần dùng `host.docker.internal`).