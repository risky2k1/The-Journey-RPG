# The Journey RPG - Godot Architecture

> Tài liệu chốt kiến trúc Godot cho prototype đầu tiên
> Mục tiêu: xác định cấu trúc project đủ rõ để bắt đầu dựng game mà không kéo scope kỹ thuật đi quá xa

---

## 1. Mục tiêu của kiến trúc

Kiến trúc `V0.1` cần phục vụ 5 mục tiêu:

1. Dựng prototype nhanh trong Godot 4.
2. Giữ combat loop, UI và save tách nhau đủ rõ.
3. Hỗ trợ một cửa sổ desktop luôn hiện, có panel quản lý nhưng vẫn thấy battle.
4. Cho phép thêm content bằng data thay vì nhét hết vào scene logic.
5. Không over-engineer khi game còn ở giai đoạn chứng minh ý tưởng.

---

## 2. Nguyên tắc kiến trúc

Trong `V0.1`, nên ưu tiên:

* Ít layer.
* Dễ debug.
* Data-driven ở mức vừa đủ.
* Combat logic không phụ thuộc trực tiếp vào UI.
* Save/load không phụ thuộc scene ngẫu nhiên.

Không nên trong giai đoạn đầu:

* ECS tự chế.
* Event bus quá trừu tượng.
* Plugin native phức tạp khi chưa chứng minh cần thiết.
* Tách quá nhiều scene nhỏ nếu chưa có lợi rõ ràng.

---

## 3. Phân lớp hệ thống

Có thể chia project thành 4 lớp chính:

* `App Layer`
* `Game Logic Layer`
* `Presentation Layer`
* `Data Layer`

### 3.1. App Layer

Chịu trách nhiệm:

* Boot game.
* Tạo window chính.
* Load save.
* Khởi tạo các manager.

### 3.2. Game Logic Layer

Chịu trách nhiệm:

* Battle loop.
* Stage progression.
* Loot generation.
* Hero progression.
* Team slot progression.

### 3.3. Presentation Layer

Chịu trách nhiệm:

* Render battlefield.
* Render unit.
* Render loot highlight.
* Render HUD và panel UI.

### 3.4. Data Layer

Chịu trách nhiệm:

* Static resources.
* Runtime state object.
* Save/load serialization.

---

## 4. Scene tree cấp cao

Đề xuất scene tree chính cho `V0.1`:

```text
Main
|- AppRoot
|  |- GameController
|  |- SaveManager
|  |- DataRegistry
|- WindowRoot
|  |- BattleRoot
|  |  |- BackgroundLayer
|  |  |- UnitLayer
|  |  |- LootLayer
|  |  |- EffectLayer
|  |- UIRoot
|  |  |- TopBar
|  |  |- QuickButtons
|  |  |- PanelHost
|  |  |- LootFeed
|  |- OverlayRoot
```

Ý nghĩa:

* `BattleRoot` luôn hiện diện.
* `UIRoot` mở panel nhưng không thay scene battle.
* `PanelHost` là nơi spawn inventory, character, team, settings panel.

---

## 5. Main scene

`Main.tscn` là scene gốc của game.

Nhiệm vụ:

* Khởi tạo game.
* Load save.
* Tạo runtime state ban đầu.
* Kết nối manager với các layer hiển thị.

`Main` không nên chứa logic battle chi tiết.

Nó chỉ nên là nơi lắp ráp hệ thống.

---

## 6. GameController

`GameController` là coordinator trung tâm của `V0.1`.

Nhiệm vụ:

* Start session.
* Tạo `BattleState`, `TeamState`, `InventoryState`, `ProgressionState`.
* Điều phối giữa battle, loot, save và UI.
* Chuyển stage khi đủ điều kiện.

`GameController` không nên trực tiếp xử lý mọi frame logic của từng unit.

Nó nên đóng vai trò:

* Điều phối cấp cao.
* Gọi đúng manager hoặc system.

---

## 7. Các manager hoặc system nên có

Trong `V0.1`, nên giữ danh sách nhỏ và thực dụng:

* `BattleManager`
* `StageManager`
* `LootManager`
* `ProgressionManager`
* `SaveManager`
* `UIManager`

Nếu muốn gọn hơn, `StageManager` có thể nằm trong `BattleManager` ở bản đầu.

---

## 8. BattleManager

`BattleManager` chịu trách nhiệm battle runtime.

Nhiệm vụ:

* Spawn quái.
* Tick logic combat.
* Theo dõi unit chết.
* Báo kill count.
* Báo khi boss cần xuất hiện.
* Báo khi stage hoàn tất.

`BattleManager` nên làm việc với:

* `BattleState`
* `HeroState`
* `EnemyState`
* `StageData`

Không nên để `BattleManager` gọi thẳng UI node để cập nhật text.

Thay vào đó:

* Cập nhật state.
* Phát signal.
* `UIManager` hoặc view node đọc state và render.

---

## 9. StageManager

`StageManager` chịu trách nhiệm tiến trình stage.

Nhiệm vụ:

* Biết stage hiện tại là gì.
* Cấp `StageData` cho battle.
* Tăng stage khi boss chết.
* Cấp reward stage cơ bản nếu có.

Trong `V0.1`, có thể gộp phần này vào `GameController` hoặc `BattleManager`.

Tuy vậy, nên tách khái niệm trong tài liệu để sau này scale dễ hơn.

---

## 10. LootManager

`LootManager` xử lý toàn bộ flow loot.

Nhiệm vụ:

* Nhận event quái chết.
* Roll loot dựa trên `loot_table` hoặc `ItemData`.
* Tạo `LootDrop`.
* Chuyển loot vào inventory khi nhặt hoặc auto-pickup.
* Gửi tín hiệu cho `LootLayer` và `LootFeed`.

Đây là manager quan trọng vì loot là hook chính của sản phẩm.

---

## 11. ProgressionManager

`ProgressionManager` xử lý tăng trưởng dài hơn battle hiện tại.

Nhiệm vụ:

* Nhận EXP.
* Tăng level nếu đủ điều kiện.
* Tính lại stat cơ bản.
* Theo dõi currency.
* Theo dõi tiến trình mở slot đội hình.

Trong `V0.1`, manager này chưa cần xử lý cây nâng cấp phức tạp.

Chỉ cần đủ cho:

* Level.
* Currency.
* Unlock slot.

---

## 12. SaveManager

`SaveManager` chịu trách nhiệm:

* Load save khi game khởi động.
* Save định kỳ.
* Save khi có mốc quan trọng.
* Serialize và deserialize `SaveData`.

Nên có các điểm save đơn giản:

* Khi mở game.
* Sau khi đổi equipment.
* Sau khi qua stage.
* Theo timer định kỳ.

`SaveManager` không nên đọc trực tiếp UI scene để lấy dữ liệu.

Nó chỉ nên lấy state logic từ controller hoặc state container.

---

## 13. UIManager

`UIManager` điều phối UI ở mức cao.

Nhiệm vụ:

* Mở và đóng panel.
* Đồng bộ dữ liệu lên HUD.
* Giữ battle luôn visible khi panel mở.
* Điều phối trạng thái của `PanelHost`.

Nó không nhất thiết phải tự render mọi widget.

Nó chỉ cần:

* Quản lý luồng UI.
* Kết nối state với view scene tương ứng.

---

## 14. DataRegistry

`DataRegistry` là nơi tập trung truy cập static data.

Nhiệm vụ:

* Load `HeroDataResource`
* Load `EnemyDataResource`
* Load `StageDataResource`
* Load `ItemDataResource`

Mục tiêu:

* Tránh việc mỗi manager tự load resource lung tung.
* Tạo một nơi rõ ràng để tra data theo `id`.

---

## 15. Runtime state container

Trong `V0.1`, nên có một container cho state hiện tại của phiên chơi.

Ví dụ:

* `SessionState`
  * `battle_state`
  * `team_state`
  * `inventory_state`
  * `progression_state`

Lợi ích:

* SaveManager biết lấy gì để save.
* UI biết đọc gì để render.
* Manager biết cập nhật vào đâu.

---

## 16. Battle scene composition

`BattleRoot` nên được chia theo layer hiển thị:

* `BackgroundLayer`
* `UnitLayer`
* `LootLayer`
* `EffectLayer`

### BackgroundLayer

Chứa:

* Background stage.
* Ground strip hoặc battlefield strip.

### UnitLayer

Chứa:

* Hero node.
* Enemy node.
* Có thể dùng `YSort` hoặc tự tính `z_index`.

### LootLayer

Chứa:

* Loot drop đang hiển thị.
* Beam hoặc glow.

### EffectLayer

Chứa:

* Hit effect.
* Damage number nếu dùng.
* Boss indicator.

---

## 17. UI scene composition

`UIRoot` nên có:

* `TopBar`
* `QuickButtons`
* `PanelHost`
* `LootFeed`

### TopBar

Hiển thị:

* Stage.
* Kill progress.
* Currency.

### QuickButtons

Gồm:

* Inventory
* Character
* Team
* Settings

### PanelHost

Chứa panel đang mở:

* InventoryPanel
* CharacterPanel
* TeamPanel
* SettingsPanel

### LootFeed

Hiển thị:

* Loot mới nhặt.
* Item hiếm gần đây.

---

## 18. Flow khi game khởi động

Luồng khởi động đề xuất:

1. `Main` chạy.
2. `DataRegistry` load static data.
3. `SaveManager` đọc save gần nhất nếu có.
4. `GameController` tạo `SessionState`.
5. `BattleManager` khởi tạo stage hiện tại.
6. `UIManager` bind state vào HUD và panel.
7. Combat bắt đầu chạy.

---

## 19. Flow khi quái chết

Luồng xử lý đề xuất:

1. `BattleManager` nhận quái chết.
2. `BattleState.kill_count` tăng.
3. `ProgressionManager` nhận EXP và coin.
4. `LootManager` roll loot.
5. Nếu có drop, `LootDrop` được tạo và gửi sang `LootLayer`.
6. `UIManager` hoặc `LootFeed` cập nhật tín hiệu nếu item đáng chú ý.
7. Nếu đủ kill target, `BattleManager` spawn boss hoặc đánh dấu ready.

---

## 20. Flow khi item được equip

Luồng equip nên là:

1. Người chơi mở `InventoryPanel`.
2. Chọn item.
3. `UIManager` gửi action cho `GameController` hoặc `ProgressionManager`.
4. `InventoryState` và `HeroState` được cập nhật.
5. Stat hero được tính lại.
6. `SaveManager` được đánh dấu dirty để save sớm.
7. Battle tiếp tục mà không chuyển scene.

---

## 21. Flow khi qua stage

Luồng qua stage đề xuất:

1. Boss chết.
2. `BattleManager` phát signal `stage_completed`.
3. `StageManager` hoặc `GameController` tăng stage.
4. `BattleState` reset kill progress cho stage mới.
5. Stage background hoặc enemy pool được cập nhật nếu cần.
6. `UI` refresh stage info.
7. `SaveManager` save mốc mới.

---

## 22. Save strategy

`V0.1` nên dùng save strategy đơn giản:

* Một file save chính.
* JSON.
* Có `save_version`.

Save theo kiểu snapshot:

* Currency
* Stage hiện tại
* Hero progression
* Equipment
* Inventory
* Team slot unlock

Không cần trong `V0.1`:

* Nhiều slot save.
* Cloud sync.
* Delta save phức tạp.

---

## 23. Thư mục project đề xuất

Đề xuất cấu trúc thư mục:

```text
project/
|- scenes/
|  |- main/
|  |- battle/
|  |- ui/
|  |- units/
|- scripts/
|  |- app/
|  |- managers/
|  |- state/
|  |- data/
|  |- ui/
|- data/
|  |- heroes/
|  |- enemies/
|  |- stages/
|  |- items/
|- assets/
|  |- sprites/
|  |- ui/
|  |- fx/
|- saves/
```

Mục tiêu:

* Scene, script, data và asset tách đủ rõ.
* Dễ đọc khi project còn nhỏ.

---

## 24. Mapping từ docs sang implementation

Mapping ngắn gọn:

* [V0_1_SPEC.md](/home/tuanpm1/Dev/common/game-rpg/docs/V0_1_SPEC.md:1) xác định phạm vi.
* [UI_FLOW.md](/home/tuanpm1/Dev/common/game-rpg/docs/UI_FLOW.md:1) xác định luồng panel và battle visibility.
* [GAMEPLAY_LOOP.md](/home/tuanpm1/Dev/common/game-rpg/docs/GAMEPLAY_LOOP.md:1) xác định combat và progression rhythm.
* [DATA_MODEL.md](/home/tuanpm1/Dev/common/game-rpg/docs/DATA_MODEL.md:1) xác định entity và state.

`GODOT_ARCHITECTURE.md` là cầu nối giữa các tài liệu trên và project thực tế.

---

## 25. Những gì chưa cần ở V0.1

Chưa cần trong kiến trúc giai đoạn đầu:

* Networking layer.
* Plugin native riêng cho từng nền tảng ngay từ đầu.
* Tool editor custom.
* Asset pipeline phức tạp.
* Animation state machine quá sâu.
* Dependency injection framework.

Nếu prototype chứng minh được ý tưởng, các phần này mới đáng đầu tư thêm.

---

## 26. Tiêu chí kiến trúc tốt cho V0.1

Kiến trúc được xem là đủ tốt nếu:

* Có thể thêm một stage mới bằng data.
* Có thể thêm một loại quái mới mà không sửa quá nhiều chỗ.
* UI panel mở ra không làm battle dừng hoặc thay scene.
* Save và load ổn định với ít logic đặc biệt.
* Project vẫn dễ hiểu khi chỉ có 1 đến 2 người phát triển.

---

## 27. Câu hỏi còn mở

Sau khi bắt đầu dựng project, các câu hỏi tiếp theo nên là:

* `BattleManager` nên tick combat tập trung hay để từng unit node tự xử lý nhiều hơn?
* `SessionState` nên dùng class typed rõ ràng hay dictionary nhẹ để làm nhanh?
* Có cần Autoload cho `GameController` hoặc `SaveManager` ngay từ đầu không?
* Khi nào mới cần GDExtension cho desktop integration?
* Window behavior đặc biệt như click-through nên đặt ở `AppRoot` hay tách riêng `DesktopWindowController`?
