# The Journey RPG - Implementation Plan

> Kế hoạch triển khai prototype đầu tiên
> Mục tiêu: chia nhỏ công việc để có thể đi từ project rỗng tới một bản `V0.1` chơi được

---

## 1. Mục tiêu của kế hoạch

Kế hoạch này nhằm:

* Xác định thứ tự triển khai hợp lý.
* Giảm rủi ro dựng sai kiến trúc quá sớm.
* Ưu tiên phần chứng minh giá trị cốt lõi trước.
* Giữ scope `V0.1` không bị trôi.

Nguyên tắc:

* Luôn làm phần có thể nhìn thấy và kiểm tra được trước.
* Không xây hệ thống sâu khi chưa có loop tối thiểu để thử.
* Mỗi phase phải tạo ra một bản chạy được, không chỉ thêm code nền.

---

## 2. Kết quả cuối cần đạt

Khi hoàn thành kế hoạch này, project nên có:

* Một window desktop chạy ổn định trong Godot.
* Một battlefield nhỏ luôn hiện trên màn hình.
* Một hero khởi đầu tự chiến đấu.
* Quái spawn, chết, rơi coin hoặc item.
* Stage progress và boss cơ bản.
* Inventory panel mở ra nhưng vẫn thấy combat.
* Local save cơ bản.
* Nền tảng logic sẵn để mở thêm slot đội hình sau đó.

---

## 3. Thứ tự triển khai tổng thể

Đề xuất thứ tự:

1. Project setup
2. Window và battlefield shell
3. Combat loop tối thiểu
4. Stage progress và boss
5. Loot loop
6. Inventory và equip flow
7. Progression và unlock slot nền tảng
8. Save/load
9. Polish cho readability và UX

---

## 4. Phase 0 - Project Setup

### Mục tiêu

Tạo project Godot và bộ khung thư mục đủ sạch để bắt đầu làm.

### Công việc

- [x] Tạo project Godot 4.x.
- [x] Tạo cấu trúc thư mục theo [GODOT_ARCHITECTURE.md](/home/tuanpm1/Dev/common/game-rpg/docs/GODOT_ARCHITECTURE.md:23).
- [x] Tạo `Main.tscn`.
- [x] Tạo script khung `GameController`.
- [x] Tạo script khung `BattleManager`.
- [x] Tạo script khung `LootManager`.
- [x] Tạo script khung `ProgressionManager`.
- [x] Tạo script khung `SaveManager`.
- [x] Tạo script khung `UIManager`.
- [x] Tạo resource hoặc file dữ liệu mẫu cho hero.
- [x] Tạo resource hoặc file dữ liệu mẫu cho enemy.
- [x] Tạo resource hoặc file dữ liệu mẫu cho stage.
- [x] Tạo resource hoặc file dữ liệu mẫu cho item.

### Kết quả mong đợi

* Project mở được.
* Scene gốc chạy được.
* Không có gameplay, nhưng kiến trúc khởi tạo đã sẵn.

---

## 5. Phase 1 - Window và Battlefield Shell

### Mục tiêu

Chứng minh game có thể sống như một cửa sổ desktop nhỏ.

### Công việc

- [x] Tạo window cơ bản.
- [ ] Thử `borderless` nếu phù hợp.
- [ ] Thử `always-on-top` nếu khả thi.
- [x] Thêm `resize` hoặc `scale` cơ bản.
- [x] Tạo `BattleRoot`.
- [x] Tạo `BackgroundLayer`.
- [x] Tạo `UnitLayer`.
- [x] Tạo `LootLayer`.
- [x] Tạo `EffectLayer`.
- [x] Tạo strip battlefield hiển thị được ở cạnh dưới.
- [x] Tạo vài nút UI placeholder để mở panel sau này.

### Kết quả mong đợi

* Có một cửa sổ nhỏ chạy ổn.
* Nhìn rõ battlefield.
* Có đủ không gian cho battle và panel trong cùng window.

### Rủi ro cần kiểm tra sớm

* Kích thước window có đủ để nhìn combat không.
* Cảm giác “hòa vào desktop” có ổn không.

---

## 6. Phase 2 - Combat Loop Tối Thiểu

### Mục tiêu

Có một trận chiến tự động chạy liên tục.

### Công việc

- [ ] Spawn 1 hero.
- [ ] Spawn 1 loại quái.
- [ ] Hero tự tìm mục tiêu.
- [ ] Hero tự đánh.
- [ ] Quái mất máu và chết.
- [ ] Quái respawn.
- [ ] Hiển thị HP hoặc phản hồi hit đủ để debug.

### Kết quả mong đợi

* Battle có chuyển động liên tục.
* Người chơi nhìn vào là thấy đang có đánh nhau.

### Điều chưa cần ở phase này

* Boss.
* Item.
* Inventory.
* Save.

---

## 7. Phase 3 - Stage Progress và Boss

### Mục tiêu

Biến combat thành một loop có tiến trình rõ ràng.

### Công việc

- [ ] Thêm `kill_count`.
- [ ] Thêm `kill_target`.
- [ ] Thêm HUD stage progress.
- [ ] Khi đủ kill target thì spawn boss.
- [ ] Boss chết thì tăng stage.
- [ ] Reset progress cho stage mới.

### Kết quả mong đợi

* Player liếc vào là hiểu đang ở stage nào và tiến được bao nhiêu.
* Boss tạo được khoảnh khắc nổi bật hơn battle thường.

### Tiêu chí chấp nhận

* Stage loop chạy liên tục mà không cần bấm tay.

---

## 8. Phase 4 - Loot Loop

### Mục tiêu

Thêm hook quan trọng nhất của sản phẩm: loot rơi.

### Công việc

- [x] Tạo `ItemData` mẫu.
- [ ] Tạo loot roll đơn giản cho quái.
- [ ] Khi quái chết, có xác suất rơi item.
- [ ] Hiển thị item trên battlefield.
- [ ] Thêm màu bao quanh cho item hiếm.
- [ ] Thêm beam hoặc cột sáng cho item hiếm.
- [ ] Tạo `LootFeed` ngắn nếu cần.

### Kết quả mong đợi

* Người chơi nhìn lướt có thể nhận ra loot vừa rơi.
* Loot đủ nổi để tạo thói quen nhìn lại.

### Điều nên giữ đơn giản

* Chỉ cần ít item.
* Ít rarity.
* Chưa cần loot filter.

---

## 9. Phase 5 - Inventory và Equip Flow

### Mục tiêu

Cho người chơi mở túi đồ, xem item, equip item mà vẫn thấy battle.

### Công việc

- [x] Tạo `UIRoot`.
- [x] Tạo `QuickButtons`.
- [x] Tạo `PanelHost`.
- [x] Tạo `InventoryPanel`.
- [x] Mở panel từ cạnh phải hoặc theo layout đã chốt ở [UI_FLOW.md](/home/tuanpm1/Dev/common/game-rpg/docs/UI_FLOW.md:1).
- [ ] Giữ battle tiếp tục chạy khi panel mở.
- [ ] Equip item cho hero.
- [ ] Cập nhật stat hero sau khi equip.

### Kết quả mong đợi

* Người chơi có thể nhặt, xem và thay item ngay trong lúc battle tiếp tục.

### Tiêu chí chấp nhận

* Không có chuyển scene khi mở inventory.
* Combat không dừng khi panel mở.

---

## 10. Phase 6 - Progression và Nền Tảng Mở Slot Đội Hình

### Mục tiêu

Thêm cảm giác mạnh lên và chuẩn bị cho fantasy party mở rộng.

### Công việc

- [ ] Thêm EXP.
- [ ] Thêm level cho hero hoặc profile.
- [ ] Thêm currency cơ bản.
- [ ] Thêm dữ liệu `TeamSlot`.
- [ ] UI hiển thị slot đang khóa.
- [ ] Thêm một rule mở slot đơn giản theo level hoặc stage milestone.

### Kết quả mong đợi

* Người chơi thấy rõ ngoài loot còn có một mục tiêu tiến trình khác.
* Dù mới có 1 hero, game vẫn gợi rằng party sẽ lớn dần.

### Ghi chú

Phase này chưa bắt buộc phải spawn hero thứ hai ngay, nhưng nền tảng phải sẵn.

---

## 11. Phase 7 - Save và Load

### Mục tiêu

Giữ được tiến trình giữa các lần mở game.

### Công việc

- [ ] Tạo `SaveData`.
- [ ] Serialize ra JSON.
- [ ] Load lại stage hiện tại.
- [ ] Load lại currency.
- [ ] Load lại inventory.
- [ ] Load lại item đang equip.
- [ ] Load lại level.
- [ ] Load lại số slot đã mở.
- [ ] Thêm auto-save theo timer hoặc theo mốc.

### Kết quả mong đợi

* Đóng game và mở lại không mất tiến trình cơ bản.

### Tiêu chí chấp nhận

* Save không phụ thuộc trạng thái scene ngẫu nhiên.

---

## 12. Phase 8 - Polish cho Readability và UX

### Mục tiêu

Biến prototype từ “chạy được” thành “dễ nhìn, dễ hiểu”.

### Công việc

- [ ] Tinh chỉnh kích thước unit.
- [ ] Tinh chỉnh spacing battlefield.
- [ ] Tinh chỉnh màu loot.
- [ ] Tinh chỉnh beam hoặc highlight rarity.
- [ ] Giảm visual noise.
- [ ] Tinh chỉnh panel width để vẫn thấy battle.
- [ ] Kiểm tra tempo quái chết có đủ đều không.
- [ ] Kiểm tra tempo loot có đủ xuất hiện không.
- [ ] Kiểm tra tempo boss có đủ nổi bật không.

### Kết quả mong đợi

* Người chơi liếc nhanh vẫn nắm được trạng thái.
* Loot nổi bật hơn background và effect phụ.

---

## 13. Phase 9 - Mở Rộng Sau Khi V0.1 Ổn

Chỉ làm phase này khi `V0.1` đã chứng minh được core loop.

Các hướng mở rộng:

* Hero thứ hai.
* Hero thứ ba.
* Frontline và backline rõ hơn.
* Thêm loại item.
* Thêm nhiều stage theme.
* Character panel.
* Team panel.
* Click-through.

---

## 14. Milestone kiểm tra

### Milestone A

- [ ] Window + battlefield nhìn được.

### Milestone B

- [ ] Hero và quái đánh nhau ổn.

### Milestone C

- [ ] Stage progress + boss hoạt động.

### Milestone D

- [ ] Loot rơi ra và nổi bật.

### Milestone E

- [ ] Inventory mở ra nhưng vẫn thấy battle.

### Milestone F

- [ ] Save/load ổn định.

Nếu milestone nào chưa đạt, không nên nhảy sang quá nhiều tính năng mới.

---

## 15. Thứ tự ưu tiên nếu thời gian ít

Nếu cần cắt scope mạnh, ưu tiên theo thứ tự:

1. Window + battlefield
2. Combat loop
3. Stage progress
4. Loot highlight
5. Inventory + equip
6. Save/load
7. Team slot unlock foundation

Điều này giữ được phần hồn của sản phẩm ngay cả khi chưa đủ thời gian cho mọi hệ thống phụ.

---

## 16. Những gì không nên làm quá sớm

Không nên đầu tư sớm vào:

* Nhiều class.
* Hệ stat sâu.
* Crafting.
* Pet.
* Gacha.
* Nhiều loại panel phức tạp.
* Native desktop integration quá sâu.
* Tối ưu quá sớm khi battle còn chưa đọc được.

---

## 17. Rủi ro chính

### 17.1. Combat nhìn không rõ

Nếu unit, loot và effect quá nhỏ hoặc quá dày, hook chính sẽ hỏng.

### 17.2. UI che battle quá nhiều

Nếu panel mở ra mà battle mất vai trò trung tâm, game sẽ giống idle menu manager hơn là desktop ambient RPG.

### 17.3. Loot không đủ nổi

Nếu item rơi mà không đủ gây chú ý, người chơi sẽ không có lý do liếc lại thường xuyên.

### 17.4. Progress quá chậm

Nếu 10 đến 20 phút đầu không cho cảm giác mạnh lên hoặc gần mở slot mới, loop sẽ bị nguội.

---

## 18. Tiêu chí hoàn thành V0.1

`V0.1` được xem là hoàn thành khi:

* Có thể chạy battle liên tục trong window desktop.
* Stage progress và boss hoạt động.
* Loot rơi ra và dễ nhận ra.
* Inventory/equip hoạt động trong khi battle vẫn nhìn thấy.
* Save/load giữ được tiến trình cơ bản.
* Nền tảng slot đội hình đã có mặt trong logic và UI.

---

## 19. Bước tiếp theo sau tài liệu này

Sau khi chốt kế hoạch, có 2 hướng hợp lý:

1. Scaffold project Godot ngay theo phase 0 và phase 1.
2. Viết thêm một `TASK_BREAKDOWN.md` chi tiết hơn ở mức file, scene và script nếu muốn triển khai theo checklist rất cụ thể.

Nếu làm một mình, tôi khuyên đi thẳng sang scaffold project để giữ đà.
