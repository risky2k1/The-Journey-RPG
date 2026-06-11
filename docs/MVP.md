# The Journey RPG - MVP Definition

> Tài liệu chốt phạm vi bản đầu tiên
> Nguyên tắc: chỉ giữ phần đủ để kiểm tra giá trị cốt lõi

---

## 1. Mục tiêu của MVP

MVP không nhằm chứng minh toàn bộ hệ thống progression dài hạn.

MVP chỉ cần trả lời 3 câu hỏi:

1. Một game auto-battle sống sát cạnh màn hình desktop có thực sự hấp dẫn không?
2. Combat ở kích thước nhỏ có đủ dễ đọc và đủ vui để theo dõi không?
3. Loot và tiến độ cơ bản có đủ để người chơi muốn quay lại kiểm tra không?

---

## 2. Phạm vi phải có

### 2.1. Desktop Window

* Cửa sổ trong suốt hoặc gần trong suốt.
* Borderless.
* Always on top.
* Có thể đặt sát cạnh dưới màn hình.
* Có chế độ click-through cơ bản hoặc một chế độ hiển thị không cản trở người dùng.

### 2.2. Battlefield

* Một battlefield nhỏ.
* Hiển thị tốt ở cạnh dưới màn hình.
* Hướng giao chiến rõ: đội người chơi từ dưới trái, quái từ trên phải.
* Pseudo-isometric hoặc góc nhìn chéo dễ đọc.
* Y-sort cơ bản.

### 2.3. Combat Core

* 1 hero ban đầu.
* 1 đến 2 loại quái.
* Auto move.
* Auto attack.
* HP.
* Damage.
* Enemy respawn hoặc wave loop.
* Stage progress cơ bản.
* 1 boss đơn giản.

### 2.4. Progression Core

* EXP.
* Level cơ bản.
* Coin hoặc 1 currency đơn giản.
* Nhận thưởng sau trận hoặc theo stage.
* Tăng sức mạnh đủ thấy được sau một thời gian ngắn.

### 2.5. Loot Core

* Một số món trang bị cơ bản.
* Có khác biệt sức mạnh rõ.
* Equip trực tiếp cho hero.
* 2 đến 3 rarity là đủ.

### 2.6. Save Core

* Local save.
* Auto-save cơ bản.
* Lưu progress, level, equipment đang dùng.

---

## 3. Phạm vi nên có nếu còn thời gian

* Hero thứ hai.
* Frontline và backline đơn giản.
* 1 kỹ năng active dễ nhìn.
* Auto retry.
* Basic idle reward hoặc offline reward ngắn.
* Một panel quản lý đội hình hoặc equipment tối thiểu.

---

## 4. Phạm vi chưa nên có

* Gacha.
* Pet system đầy đủ.
* Nhiều class.
* Dungeon riêng.
* Prestige.
* Endless tower.
* Codex lớn.
* Nhiều loại event desktop.
* Cloud save.
* Android.
* iOS.
* PvP hoặc social feature.

---

## 5. Chân dung bản đầu lý tưởng

Người chơi mở game và thấy:

* Một nhân vật nhỏ liên tục chiến đấu sát cạnh màn hình.
* Quái xuất hiện, chết đi, rơi coin hoặc item.
* Có thể mở panel nhỏ để thay đồ hoặc xem level.
* Sau 10 đến 20 phút, sức mạnh tăng lên đủ để cảm nhận rõ.
* Thỉnh thoảng boss xuất hiện để tạo điểm nhấn.

Nếu trải nghiệm này đã vui, dự án mới nên mở rộng tiếp.

---

## 6. Tiêu chí cắt scope

Khi phân vân có nên thêm tính năng nào vào MVP hay không, dùng 2 câu hỏi sau:

1. Tính năng này có làm trải nghiệm nhìn-lướt-trên-desktop tốt hơn không?
2. Tính năng này có giúp chứng minh core loop nhanh hơn không?

Nếu câu trả lời cho cả hai đều là không, tính năng đó nên hoãn.
