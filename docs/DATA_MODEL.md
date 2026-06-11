# The Journey RPG - Data Model

> Tài liệu chốt cấu trúc dữ liệu cho prototype đầu tiên
> Mục tiêu: xác định các entity tối thiểu để triển khai gameplay loop trong Godot

---

## 1. Mục tiêu của data model

Data model của `V0.1` cần phục vụ 4 mục tiêu:

1. Đủ đơn giản để làm prototype nhanh.
2. Đủ rõ để không phải hard-code toàn bộ gameplay vào scene hoặc script.
3. Đủ mở để sau này thêm party slot, item rarity, enemy variety và save progression.
4. Tách rõ `data thiết kế` với `runtime state`.

---

## 2. Nguyên tắc mô hình hóa

Trong `V0.1`, nên tách làm 3 lớp:

* `Static Data`: dữ liệu định nghĩa sẵn, ít thay đổi khi runtime chạy.
* `Runtime State`: trạng thái hiện tại của phiên chơi.
* `Save Data`: phần cần lưu lại giữa các lần mở game.

Nguyên tắc:

* `HeroData`, `EnemyData`, `ItemData`, `StageData` là static data.
* `HeroState`, `EnemyState`, `BattleState`, `InventoryState` là runtime state.
* `SaveData` chỉ chứa phần cần khôi phục tiến trình.

---

## 3. Nhóm entity tối thiểu cho V0.1

Các entity nên có trong prototype:

* `HeroData`
* `HeroState`
* `TeamSlotData`
* `TeamState`
* `EnemyData`
* `EnemyState`
* `StageData`
* `BattleState`
* `ItemData`
* `ItemInstance`
* `InventoryState`
* `LootDrop`
* `ProgressionData`
* `SaveData`

Không phải tất cả đều cần thành class độc lập ngay lập tức, nhưng mô hình logic nên tách theo các khái niệm này.

---

## 4. HeroData

`HeroData` là dữ liệu định nghĩa một hero hoặc archetype hero.

Nên chứa:

* `id`
* `display_name`
* `class_id`
* `base_hp`
* `base_attack`
* `base_attack_speed`
* `base_move_speed`
* `attack_range`
* `starting_skill_ids`
* `sprite_id`
* `portrait_id`

Mục đích:

* Xác định đặc tính gốc của nhân vật.
* Không chứa level hiện tại hay equipment đang mặc.

---

## 5. HeroState

`HeroState` là trạng thái runtime của một hero trong phiên chơi.

Nên chứa:

* `hero_id`
* `level`
* `current_hp`
* `max_hp`
* `attack`
* `attack_speed`
* `move_speed`
* `equipped_item_ids`
* `team_slot_index`
* `is_alive`
* `cooldown_state`

Nếu cần tách rõ hơn:

* `base stats` lấy từ `HeroData`
* `final stats` được tính từ `HeroData + level + equipment + bonuses`

Mục tiêu:

* HeroState thay đổi liên tục trong battle.
* Có thể được rebuild từ save và static data.

---

## 6. TeamSlotData và TeamState

### TeamSlotData

`TeamSlotData` định nghĩa từng slot trong đội hình.

Nên chứa:

* `slot_index`
* `unlock_requirement_type`
* `unlock_requirement_value`
* `preferred_role`

Ví dụ:

* Slot 0: mở sẵn.
* Slot 1: mở khi đạt milestone nào đó.

### TeamState

`TeamState` chứa trạng thái đội hình hiện tại.

Nên chứa:

* `unlocked_slot_count`
* `assigned_hero_ids_by_slot`
* `active_slot_indices`

Mục đích:

* Thể hiện rõ game bắt đầu với 1 slot nhưng có thể mở thêm về sau.

---

## 7. EnemyData

`EnemyData` là dữ liệu thiết kế của quái.

Nên chứa:

* `id`
* `display_name`
* `enemy_type`
* `base_hp`
* `base_attack`
* `base_attack_speed`
* `base_move_speed`
* `attack_range`
* `reward_exp`
* `reward_coin`
* `loot_table_id`
* `sprite_id`
* `is_boss`

Trong `V0.1`, chỉ cần 1 đến 2 loại quái thường và 1 boss đơn giản là đủ.

---

## 8. EnemyState

`EnemyState` là trạng thái runtime của quái đang tồn tại trên battlefield.

Nên chứa:

* `enemy_id`
* `current_hp`
* `spawn_time`
* `lane_index`
* `is_alive`
* `status_flags`
* `cooldown_state`

Mục tiêu:

* EnemyState chỉ tồn tại trong battle hiện tại.
* Khi quái chết thì state biến mất và reward được xử lý.

---

## 9. StageData

`StageData` định nghĩa một stage hoặc một bước tiến trình battle.

Nên chứa:

* `id`
* `display_name`
* `background_id`
* `enemy_pool_ids`
* `kill_target`
* `boss_enemy_id`
* `spawn_profile_id`
* `reward_profile_id`

Mục tiêu:

* Stage quyết định quái nào xuất hiện.
* Khi nào boss xuất hiện.
* Reward cơ bản sau stage là gì.

---

## 10. BattleState

`BattleState` là state trung tâm của trận chiến hiện tại.

Nên chứa:

* `current_stage_id`
* `kill_count`
* `kill_target`
* `boss_spawned`
* `boss_defeated`
* `active_enemy_ids`
* `battle_speed`
* `elapsed_time`

Có thể bổ sung:

* `last_loot_drop`
* `recent_events`

Mục đích:

* Cho UI biết battle đang ở đâu.
* Cho gameplay loop biết khi nào spawn boss và khi nào sang stage mới.

---

## 11. ItemData

`ItemData` là dữ liệu định nghĩa item theo thiết kế.

Nên chứa:

* `id`
* `display_name`
* `slot_type`
* `rarity`
* `icon_id`
* `stat_profile`
* `drop_weight`

Trong `V0.1`, item nên đơn giản:

* Vũ khí.
* Giáp.
* Phụ kiện nếu thật sự cần.

Không cần quá nhiều slot từ đầu.

---

## 12. ItemInstance

`ItemInstance` là item thực tế mà người chơi sở hữu.

Nên chứa:

* `instance_id`
* `item_data_id`
* `rarity`
* `rolled_stats`
* `is_equipped`
* `owner_hero_id`

Lý do phải tách khỏi `ItemData`:

* Hai item cùng loại có thể có khác stat hoặc trạng thái equip khác nhau.

---

## 13. InventoryState

`InventoryState` chứa danh sách item đang sở hữu.

Nên chứa:

* `items`
* `capacity`
* `recent_item_instance_ids`

Mục đích:

* Hỗ trợ UI inventory.
* Theo dõi item mới nhặt để highlight.

Trong `V0.1`, inventory chưa cần quá nhiều tính năng như sort phức tạp hay filter sâu.

---

## 14. LootDrop

`LootDrop` là state ngắn hạn của item vừa rơi trên battlefield.

Nên chứa:

* `drop_id`
* `item_instance_id`
* `world_position`
* `rarity`
* `visual_highlight_type`
* `spawn_time`
* `pickup_state`

Mục tiêu:

* Tách `item đang hiện trên battlefield` khỏi `item đã vào inventory`.
* Cho phép beam, màu viền hoặc hiệu ứng highlight mà không trộn vào InventoryState.

---

## 15. ProgressionData

`ProgressionData` là nơi chứa các biến tiến trình dài hơn battle hiện tại.

Nên chứa:

* `account_level` hoặc `profile_level`
* `current_stage_unlocked`
* `unlocked_team_slot_count`
* `currency`
* `total_play_time`

Nếu chưa muốn dùng khái niệm account quá sớm, có thể đặt tên đơn giản hơn như `ProfileProgressState`.

---

## 16. SaveData

`SaveData` là dữ liệu tối thiểu cần lưu giữa các lần chơi.

Nên chứa:

* `save_version`
* `current_stage_id`
* `currency`
* `hero_progress`
* `inventory_items`
* `equipped_items_by_hero`
* `unlocked_team_slot_count`
* `last_session_time`

Nguyên tắc:

* Không lưu các object runtime thừa.
* Chỉ lưu đủ để rebuild trạng thái gameplay.

---

## 17. Tách static data và save data

Một lỗi phổ biến ở prototype là trộn dữ liệu thiết kế với dữ liệu người chơi.

Nên tránh:

* Lưu trực tiếp toàn bộ `HeroData` vào save.
* Lưu trực tiếp toàn bộ `ItemData` vào save.
* Sửa static resource khi runtime chạy.

Nên làm:

* Static data có `id` ổn định.
* Save chỉ lưu `id` và state cần thiết.
* Runtime build lại state từ static data + save data.

---

## 18. Cách map sang Godot

Đề xuất thực dụng cho `V0.1`:

* `Static Data` dùng `Resource`.
* `Runtime State` dùng `Dictionary`, `RefCounted` hoặc script object nhẹ.
* `SaveData` serialize ra `JSON`.

Ví dụ nhóm resource:

* `HeroDataResource`
* `EnemyDataResource`
* `StageDataResource`
* `ItemDataResource`

Lợi ích:

* Dễ sửa dữ liệu.
* Không hard-code quá nhiều giá trị trong script battle.
* Dễ mở rộng khi số lượng content tăng.

---

## 19. Quan hệ giữa các entity

Quan hệ chính trong `V0.1`:

* `HeroState` tham chiếu `HeroData`
* `HeroState` nằm trong `TeamState`
* `EnemyState` tham chiếu `EnemyData`
* `BattleState` tham chiếu `StageData`
* `ItemInstance` tham chiếu `ItemData`
* `InventoryState` chứa nhiều `ItemInstance`
* `LootDrop` tham chiếu `ItemInstance`
* `SaveData` chứa snapshot của `TeamState`, `InventoryState` và `ProgressionData`

---

## 20. Những gì chưa cần cho V0.1

Chưa cần thêm vào data model giai đoạn đầu:

* Skill tree phức tạp.
* Pet data.
* Crafting recipe.
* Gacha banner data.
* Social data.
* Quest chain phức tạp.
* Buff/debuff system đầy đủ nếu combat chưa cần.

Nếu những thứ này xuất hiện quá sớm, data model sẽ phình nhanh hơn nhu cầu prototype.

---

## 21. Tiêu chí data model tốt cho V0.1

Data model được xem là đủ tốt nếu:

* Thêm một hero hoặc một loại quái mới không cần sửa nhiều logic.
* Đổi reward stage không cần sửa script combat lõi.
* Item rơi ra, vào inventory và equip được theo một luồng dữ liệu rõ ràng.
* Save và load không phụ thuộc vào scene state ngẫu nhiên.
* Hệ thống vẫn đủ đơn giản để phát triển nhanh.

---

## 22. Câu hỏi còn mở

Sau khi bắt đầu dựng project Godot, các câu hỏi tiếp theo nên là:

* `Hero` trong V0.1 là nhân vật cụ thể hay chỉ là một class archetype?
* Item nên có stat cố định hoàn toàn hay có roll ngẫu nhiên nhẹ?
* Slot đội hình mở theo `stage milestone`, `level`, hay `currency unlock`?
* Có cần tách `reward profile` và `loot table` thành entity riêng ngay từ đầu không?
* Runtime state nên ưu tiên `Dictionary` nhanh gọn hay class/script object rõ kiểu hơn?
