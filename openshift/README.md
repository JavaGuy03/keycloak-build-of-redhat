# Triển khai RHBK 26.6 bằng Operator trên OpenShift

Thư mục này triển khai image Keycloak tùy biến bằng **Red Hat build of Keycloak
(RHBK) Operator**. Không áp dụng `Deployment` hoặc `StatefulSet` thủ công. Operator
sẽ tạo và quản lý Pod, StatefulSet, Service, Ingress/Route, clustering và rollout.

## Thành phần

- `keycloak.example.yaml`: trạng thái mong muốn của cụm Keycloak production.
- `deploy.ps1`: tạo/cập nhật DB Secret, DB CA ConfigMap và TLS Secret hoàn toàn qua
  stdin, áp dụng CR và chờ `Ready`. Mật khẩu không được ghi ra manifest hoặc đĩa.
- `provision-realm-roles.ps1`: tiện ích tùy chọn để tạo Realm Role sau triển khai.

PostgreSQL không do RHBK Operator quản lý. Database phải tồn tại, hỗ trợ HA/backup
theo yêu cầu của môi trường và truy cập được từ namespace `ssc3`.

## 1. Chuẩn bị

Cần có:

- quyền tạo project và cài Operator (thường cần cluster-admin cho bước Operator);
- `oc` đã đăng nhập đúng cluster;
- PostgreSQL có TLS và database `keycloak` đã được tạo;
- CA certificate dùng để xác minh PostgreSQL;
- chứng thư TLS cho hostname Keycloak (file PEM certificate và private key);
- image tùy biến đã build/push bằng tag bất biến;
- DNS của hostname trỏ về OpenShift ingress.

Kiểm tra context trước khi thay đổi cluster:

```powershell
oc whoami
oc whoami --show-server
oc get namespace ssc3
```

Nếu project chưa có:

```powershell
oc new-project ssc3
```

Trước production, revoke API key cũ của identity API và rotate mọi Redis password
từng xuất hiện trong lịch sử repository. Thay đổi file Git không vô hiệu credential
đã lộ; phải thu hồi tại chính dịch vụ phát hành credential.

## 2. Kiểm tra hoặc cài RHBK Operator

Trước tiên phải kiểm tra Operator đã được nền tảng cài hay quản lý hay chưa:

```powershell
oc get subscription rhbk-operator -A
oc get csv -A | Select-String 'rhbk-operator'
oc get operatorgroup -n ssc3
```

Nếu Subscription/CSV đã tồn tại, **không tạo thêm OperatorGroup hoặc Subscription**.
Một namespace chỉ được có một OperatorGroup; tạo thêm sẽ làm các Operator trong
namespace chuyển sang `Failed` với lỗi `TooManyOperatorGroups`. Chờ hoặc yêu cầu
platform administrator đưa CSV RHBK về trạng thái `Succeeded`:

```powershell
oc get csv -n ssc3 | Select-String 'rhbk-operator'
oc get events -n ssc3 --sort-by=.lastTimestamp | Select-Object -Last 30
```

Trong cluster hiện tại, `Subscription/rhbk-operator` do
`ibm-integration-platform-navigator-operator` quản lý. Không dùng `oc apply` để
chiếm quyền quản lý hoặc thay đổi Subscription này.

Chỉ khi RHBK chưa tồn tại, platform administrator mới cài từ **OperatorHub**, chọn
namespace/operator scope phù hợp và manual approval theo quy trình quản trị cluster.
Không đặt một OperatorGroup mới vào namespace đã chứa OperatorGroup khác.

Kiểm tra CatalogSource và các channel thực tế trên cluster:

```powershell
oc get packagemanifest rhbk-operator -n openshift-marketplace
oc get packagemanifest rhbk-operator -n openshift-marketplace `
  -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}'
```

Chọn channel cung cấp RHBK 26.6. Không đưa Operator sang major/minor khác ngoài kế
hoạch nâng cấp đã kiểm thử. Nếu dùng manual approval, `<INSTALL_PLAN_NAME>` trong
tài liệu là placeholder; thay bằng tên thật, ví dụ `install-ab123`, và chỉ approve
InstallPlan có CSV RHBK mong muốn.

Đợi Operator và CRD sẵn sàng:

```powershell
oc get csv,pods -n ssc3
oc wait --for=jsonpath='{.status.phase}'=Succeeded --timeout=10m `
  csv/<CSV_NAME> -n ssc3
oc get crd keycloaks.k8s.keycloak.org
```

Không approve InstallPlan chỉ dựa trên tên. Luôn xem danh sách CSV bên trong trước:

```powershell
oc get installplan <INSTALL_PLAN_NAME> -n <OPERATOR_NAMESPACE> -o yaml
```

## 3. Chuẩn hóa CR theo môi trường

Sửa các giá trị sau trong `keycloak.example.yaml`:

| Trường | Giá trị cần thay |
|---|---|
| `metadata.namespace` | project triển khai, mặc định `ssc3` |
| `spec.image` | image Harbor/Quay với tag bất biến hoặc digest |
| `spec.db.host`, `port`, `database` | endpoint PostgreSQL thực tế |
| `spec.hostname.hostname` | FQDN production trên chứng thư TLS |
| `spec.resources` | sizing sau load test |
| `spec.networkPolicy` | namespace được phép truy cập HTTPS/management |

Image trong repository đã được augment ở build time và bật health/metrics, vì vậy
`startOptimized: true` là bắt buộc. Không dùng tag `latest`.

Nếu registry là private, tạo pull secret và gắn vào ServiceAccount mặc định trước
khi tạo Keycloak:

```powershell
oc -n ssc3 create secret docker-registry harbor-pull `
  --docker-server=<REGISTRY_HOST> `
  --docker-username=<REGISTRY_USER> `
  --docker-password=<REGISTRY_TOKEN>

oc -n ssc3 secrets link default harbor-pull --for=pull
```

Không thêm `hostAliases` để giải quyết tên registry. DNS và trust của registry phải
được cấu hình trên các OpenShift node ở tầng hạ tầng.

## 4. Tạo Secret và deploy

Khuyến nghị dùng script để mật khẩu không xuất hiện trong command line hoặc file:

```powershell
.\openshift\deploy.ps1 `
  -DbUsername '<DB_USER>' `
  -DbCaCertificate 'C:\secure\postgres-ca.crt' `
  -TlsCertificate 'C:\secure\keycloak.crt' `
  -TlsPrivateKey 'C:\secure\keycloak.key'
```

Script sẽ hỏi password PostgreSQL bằng secure prompt, tạo/cập nhật:

- `Secret/keycloak-db` với keys `username`, `password`;
- `ConfigMap/keycloak-db-ca` chứa CA công khai để xác minh PostgreSQL;
- `Secret/keycloak-tls` với keys `tls.crt`, `tls.key`;
- `Keycloak/amigo-keycloak`.

Nếu thao tác bằng Bash/CI, tạo Secret từ secret store của pipeline rồi chạy:

```bash
oc -n ssc3 create secret generic keycloak-db \
  --from-literal=username="$KEYCLOAK_DB_USERNAME" \
  --from-literal=password="$KEYCLOAK_DB_PASSWORD" \
  --dry-run=client -o yaml | oc apply -f -

oc -n ssc3 create secret tls keycloak-tls \
  --cert=/secure/keycloak.crt \
  --key=/secure/keycloak.key \
  --dry-run=client -o yaml | oc apply -f -

oc -n ssc3 create configmap keycloak-db-ca \
  --from-file=ca.crt=/secure/postgres-ca.crt \
  --dry-run=client -o yaml | oc apply -f -

oc apply --dry-run=server -f openshift/keycloak.example.yaml
oc apply -f openshift/keycloak.example.yaml
```

Không commit Secret, certificate private key, API key của SPI hoặc output chứa
credential vào Git.

## 5. Xác minh

```powershell
oc -n ssc3 wait --for=condition=Ready --timeout=15m `
  keycloak/amigo-keycloak

oc -n ssc3 get keycloak/amigo-keycloak -o jsonpath='{range .status.conditions[*]}{.type}{"="}{.status}{"  "}{.message}{"\n"}{end}'
oc -n ssc3 get pods,service,ingress,route
oc -n ssc3 logs -l app=keycloak --all-containers --tail=200
```

CR cấu hình TLS passthrough. Route được Operator sinh từ Ingress; không tạo Route
thứ hai trỏ vào cùng Service. Lấy hostname thực tế:

```powershell
oc -n ssc3 get route -o custom-columns=NAME:.metadata.name,HOST:.spec.host,TLS:.spec.tls.termination
```

Sau lần khởi tạo đầu tiên, Operator tạo Secret admin tạm thời. Đọc credential, đăng
nhập, tạo tài khoản quản trị lâu dài rồi xóa/rotate credential tạm theo chính sách:

```powershell
oc -n ssc3 get secret amigo-keycloak-initial-admin `
  -o jsonpath='{.data.username}' | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }

oc -n ssc3 get secret amigo-keycloak-initial-admin `
  -o jsonpath='{.data.password}' | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }
```

Kiểm tra OIDC discovery sau khi tạo Realm:

```powershell
Invoke-RestMethod https://keycloak.apps.example.com/realms/<REALM>/.well-known/openid-configuration
```

## 6. Cấu hình nghiệp vụ sau deploy

Trong Admin Console:

1. Tạo/chọn Realm và cấu hình theme `amigo`.
2. Thêm User Federation provider `vietinbank-user-storage`.
3. Nhập identity API HTTPS URLs và API key đã rotate; không đưa API key vào CR.
4. Cấu hình cache, timeout, circuit breaker và mapper `external_roles` theo README
   ở thư mục gốc.
5. Chỉ bật provider sau khi lưu và kiểm tra endpoint thành công.

NetworkPolicy mẫu chỉ cho OpenShift router và workload cùng namespace truy cập
HTTPS; monitoring namespace được truy cập management port. Nếu một namespace khác
cần gọi trực tiếp Service Keycloak, thêm namespace đó vào `networkPolicy.https`.

## 7. Nâng cấp image

Build/push image bằng tag mới bất biến, ví dụ `1.0.1`, sau đó sửa duy nhất:

```yaml
spec:
  image: quay.ocp.lab.local/dinhhb/keycloak-custom:1.0.1
```

Áp dụng và theo dõi:

```powershell
oc apply --dry-run=server -f .\openshift\keycloak.example.yaml
oc apply -f .\openshift\keycloak.example.yaml
oc -n ssc3 wait --for=condition=Ready --timeout=15m keycloak/amigo-keycloak
oc -n ssc3 get keycloak/amigo-keycloak -o yaml
```

`update.strategy: Auto` yêu cầu Operator chạy compatibility check. Rolling update
không gián đoạn chỉ khả dụng khi có ít nhất hai instance và thay đổi được đánh giá
tương thích (đặc biệt patch update cùng dòng `major.minor`). Nếu condition
`RecreateUpdateUsed=True`, Operator đã chủ động dùng recreate và có thể có downtime.
Major/minor upgrade phải được thử ở non-production, backup database và lên lịch
maintenance; không mặc định coi mọi thay đổi image là zero-downtime.

## Troubleshooting nhanh

```powershell
oc -n ssc3 describe keycloak amigo-keycloak
oc -n ssc3 get events --sort-by=.lastTimestamp
oc -n ssc3 get pods
oc -n ssc3 logs deployment/rhbk-operator --tail=200
```

- `ImagePullBackOff`: kiểm tra registry DNS/CA, pull secret và tag image.
- DB connection lỗi: kiểm tra Service/DNS, NetworkPolicy, DB user, TLS và firewall.
- Route không được tạo: kiểm tra `ingress.className: openshift-default` và log Operator.
- Pod không Ready: kiểm tra log, certificate SAN khớp hostname và probe conditions.

Tài liệu tham chiếu chính thức: [RHBK 26.6 Operator Guide](https://docs.redhat.com/en/documentation/red_hat_build_of_keycloak/26.6/html-single/operator_guide/index).
