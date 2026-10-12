# Bài 4 — Custom Network & Named Volume (Docker CLI)

## Cấu trúc nộp

```text
homework/session_10/ex4/
├── commands.sh
└── README.md
```

## Mục tiêu

- Custom bridge network `app-net`: container gọi nhau bằng **tên** (DNS).
- Named volume `db-data`: dữ liệu Postgres còn sau khi xóa container.

## Chạy script

```bash
cd homework/session_10/ex4
chmod +x commands.sh
./commands.sh
```

Hoặc chạy từng lệnh trong `commands.sh`.

## Kiểm tra thủ công

```bash
docker network ls | grep app-net
docker volume ls | grep db-data
docker network inspect app-net
docker exec -it app-container ping -c 2 db-server
```

## Kết quả mong đợi

| Kiểm tra | Kết quả |
|----------|--------|
| `ping db-server` từ `app-container` | Phân giải được IP nội bộ, 2 packets ok |
| Xóa `db-server` rồi tạo lại + volume `db-data` | Bảng `notes` vẫn có dòng `persist-ok` |

## Dọn dẹp

```bash
docker rm -f app-container db-server
docker network rm app-net
docker volume rm db-data
```
