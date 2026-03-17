from pymongo import MongoClient
import bcrypt
from datetime import datetime
from backendSrc.schema.UserSche import UserQuery
from backendSrc.schema.NoteSche import Note
from datetime import datetime


client = MongoClient("mongodb+srv://TonMinhDang:06122005@webnote.tdp1lfx.mongodb.net/?appName=WebNote") # Ẩn cái này vào .env sau
db = client["WebNote"] # lấy cái tủ (database)
users = db["User"]  # lấy ngăn kéo (collection)

def create_user(email: str, password: str, provider, full_name: str = "", provider_id: str = ""):
    # 1. Hash password
    hashed_pw = None if not password else bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    pro_id = None if provider == "local" else provider_id

    new_user = UserQuery(
        full_name = full_name,
        password = hashed_pw,
        email = email,
        provider = provider,
        provider_id = pro_id
    )

    # 2. Insert user
    users.insert_one(new_user.__todict__())

    print("✅ User created")

# create_user("admin@gmail.com", "admin", "local", "Tôn Minh Đăng")
# create_user("tonminhdang9@gmail.com", None, "google", "07-Tôn Minh Đăng", "101842663870047426757")

def create_note(user_id: str):
    notes = db["Note"]
    new_note = Note.default_note(user_id, datetime.now().strftime("%d/%m/%Y"))
    
    notes.insert_one(new_note.__todict__())
    print("✅ Note created")

for i in range(0, 5):
    create_note("696fbdd0be46967353045384")



'''
❌ 1. Chưa kiểm tra trùng email

Hiện tại:

users.insert_one(...)


👉 Nếu chạy lại lần nữa → trùng email → lỗi logic rất nặng

✅ Cách sửa
if users.find_one({"email": email}):
    raise ValueError("Email already exists")

❌ 2. Cho phép tạo user local nhưng password rỗng

Ví dụ:

create_user("a@gmail.com", None, "local", "A")


👉 Điều này nguy hiểm

✅ Bắt buộc password với local
if provider == "local" and not password:
    raise ValueError("Local user must have password")

❌ 3. Không validate provider

Hiện tại:

provider = provider


👉 Truyền "facebook" vẫn lọt

✅ Fix nhanh
if provider not in ("local", "google"):
    raise ValueError("Invalid provider")

❌ 4. Chưa lưu created_at

Sau này:

audit

debug

analytics
→ rất cần

✅ Nên thêm
created_at = datetime.utcnow()

❌ 5. Đang hard-code Mongo URI

Bạn đã biết rồi 😄 nhưng nhắc lại cho đủ checklist:

MongoClient("mongodb+srv://...")


➡ BẮT BUỘC đưa vào .env
'''
