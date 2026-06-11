# The Journey RPG — Technology Overview

> Tài liệu lựa chọn công nghệ và định hướng kỹ thuật
> Engine chính: Godot
> Thể loại: Idle RPG / Auto Battler / Pseudo-Isometric 2D
> Nền tảng ưu tiên: Windows và Linux
> Nền tảng mở rộng: Android và iOS

---

## 1. Quyết định công nghệ

Dự án sẽ sử dụng:

* **Godot 4.x** làm game engine.
* **GDScript** làm ngôn ngữ gameplay chính.
* **C++ GDExtension** hoặc **Rust GDExtension** khi cần tích hợp sâu với hệ điều hành.
* **Godot Resource** để định nghĩa dữ liệu game.
* **JSON** cho prototype save system.
* **SQLite** cho phiên bản hoàn chỉnh nếu dữ liệu local trở nên phức tạp.
* **Supabase** trong tương lai nếu cần account, cloud save hoặc đồng bộ đa thiết bị.
* **Git và GitHub** để quản lý source code.
* **GitHub Actions** để tự động build Windows và Linux.

---

## 2. Định hướng nền tảng

Thứ tự phát triển:

1. Windows.
2. Linux.
3. Android.
4. iOS.

Windows và Linux là hai nền tảng chính trong giai đoạn đầu.

Android và iOS chỉ được phát triển sau khi:

* Core combat đã ổn định.
* Progression đã cân bằng.
* Save system đã hoàn thiện.
* UI desktop đã hoạt động tốt.
* Game đã chứng minh được gameplay loop đủ hấp dẫn.

---

## 3. Định hướng hình ảnh

Game sử dụng phong cách:

* 2D.
* Pixel Art hoặc Hand-drawn Sprite.
* Pseudo-isometric.
* Góc nhìn chéo 3/4 từ trên xuống.
* Battlefield có cảm giác chiều sâu nhưng không sử dụng mô hình 3D thực.

Tên gọi kỹ thuật phù hợp:

* 2D Pseudo-Isometric Auto Battler.
* 3/4 Top-down Idle RPG.
* Isometric-style Wave Defense.
* Diagonal Lane Auto Battle.

---

## 4. Bố cục chiến đấu

Đội người chơi xuất hiện ở khu vực góc dưới bên trái.

Quân địch xuất hiện ở khu vực góc trên bên phải và tiến dần về phía đội người chơi.

Mô tả theo hướng đồng hồ:

* Đội người chơi: khu vực 7 đến 8 giờ.
* Quân địch: khu vực 1 đến 2 giờ.
* Hướng tiến công chính: từ trên phải xuống dưới trái.

Sơ đồ khái niệm:

```
Enemy Spawn
     1–2 giờ
         ↓
      ↙  ↙  ↙

   Battlefield

      ↗  ↗  ↗
         ↑
     7–8 giờ
    Player Team
```

---

## 5. Đặc điểm battlefield

Battlefield không phải bản đồ lớn để người chơi tự do di chuyển.

Đây là một khu vực chiến đấu nhỏ, được thiết kế để hiển thị sát cạnh dưới màn hình.

Battlefield có thể gồm:

* 2 đến 3 hàng chiều sâu.
* 2 đến 4 lane chiến đấu.
* Vùng frontline.
* Vùng backline.
* Điểm spawn của quái.
* Điểm đứng của boss.
* Vị trí pet và summon.
* Các vùng hiệu ứng kỹ năng.

Nhân vật không nhất thiết đứng cố định hoàn toàn.

Nhân vật có thể:

* Di chuyển một khoảng ngắn để tiếp cận mục tiêu.
* Lùi về sau khi không còn mục tiêu.
* Né kỹ năng boss.
* Di chuyển giữa các lane.
* Bị đẩy lùi.
* Lao đến mục tiêu.
* Teleport.
* Nhảy vào tuyến sau.

---

## 6. Không sử dụng 3D thật trong giai đoạn đầu

Mặc dù game có cảm giác 2.5D, phiên bản đầu vẫn sử dụng hoàn toàn:

* Sprite2D.
* AnimatedSprite2D.
* AnimationPlayer.
* TileMap hoặc Node2D.
* CollisionShape2D.
* Area2D.
* GPU Particles 2D.

Không cần sử dụng:

* Mesh 3D.
* Skeleton 3D.
* Camera 3D.
* Lighting 3D.
* Navigation Mesh 3D.

Lợi ích:

* Nhẹ hơn khi chạy nền.
* Dễ làm pixel art.
* Dễ kiểm soát animation.
* Phù hợp với cửa sổ nhỏ.
* Build Windows và Linux đơn giản hơn.
* Giảm thời gian phát triển.
* Dễ tối ưu cho máy cấu hình thấp.

---

## 7. Hệ tọa độ pseudo-isometric

Có hai hướng triển khai.

### 7.1. Visual Isometric

Gameplay vẫn sử dụng tọa độ 2D thông thường.

Sprite và background được vẽ chéo để tạo cảm giác isometric.

Ví dụ:

* Trục gameplay X biểu thị chiều ngang.
* Trục gameplay Y biểu thị chiều sâu.
* Nhân vật được sắp xếp theo lane.
* Không cần chuyển đổi tọa độ isometric phức tạp.

Ưu điểm:

* Dễ phát triển.
* Dễ viết AI.
* Dễ xử lý skill.
* Dễ debug.
* Phù hợp với MVP.

Đây là lựa chọn được khuyến nghị cho giai đoạn đầu.

### 7.2. True Isometric Coordinate

Game sử dụng tọa độ logic riêng và chuyển sang tọa độ màn hình.

Công thức khái niệm:

```
screen_x = world_x - world_y
screen_y = (world_x + world_y) / 2
```

Phù hợp khi:

* Battlefield có grid.
* Nhân vật di chuyển tự do.
* Có nhiều ô chiến thuật.
* Có hệ thống đặt bẫy hoặc summon theo ô.
* Có terrain phức tạp.

Phiên bản đầu chưa cần sử dụng hệ tọa độ này.

---

## 8. Phương án triển khai được chọn

MVP sử dụng:

* Gameplay 2D thông thường.
* Hình ảnh pseudo-isometric.
* Battlefield được chia thành lane và row.
* Nhân vật chỉ di chuyển trong phạm vi được kiểm soát.
* Sprite được sắp xếp bằng Y-sort.
* Không sử dụng grid isometric thực.

Điều này tạo được cảm giác 2.5D nhưng vẫn giữ code combat đơn giản.

---

## 9. Y-Sort và chiều sâu

Vì các sprite có thể đứng trước hoặc sau nhau, game cần sắp xếp thứ tự hiển thị dựa trên tọa độ Y.

Nguyên tắc:

* Nhân vật có vị trí thấp hơn trên màn hình sẽ được vẽ phía trước.
* Nhân vật có vị trí cao hơn sẽ được vẽ phía sau.
* Hiệu ứng mặt đất được vẽ dưới nhân vật.
* Hiệu ứng bay được vẽ trên nhân vật.

Có thể sử dụng:

* Y-sort trong Node2D.
* `z_index`.
* `z_as_relative`.
* Script tự tính thứ tự hiển thị.

Ví dụ khái niệm:

```
character.z_index = int(character.global_position.y)
```

Cần tách riêng layer cho:

1. Background.
2. Ground decal.
3. Unit shadow.
4. Character.
5. Weapon effect.
6. Projectile.
7. Flying effect.
8. Damage text.
9. Interface.

---

## 10. Kích thước cửa sổ desktop

Game không nên nằm đúng bên trong taskbar của hệ điều hành.

Thay vào đó, game sử dụng một cửa sổ trong suốt được đặt:

* Ngay phía trên taskbar.
* Hoặc đè một phần lên taskbar.
* Hoặc sát cạnh dưới màn hình.

Kích thước tham khảo:

### Compact Mode

* 960 × 220.
* 1200 × 240.
* 1280 × 260.

### Standard Mode

* 1280 × 300.
* 1440 × 320.
* 1600 × 360.

### Expanded Mode

* 1280 × 500.
* 1600 × 600.

Game cần hỗ trợ scale theo:

* Độ phân giải màn hình.
* DPI.
* Kích thước taskbar.
* Tỉ lệ UI do người chơi lựa chọn.

---

## 11. Desktop Window Features

Phiên bản Windows và Linux cần hỗ trợ:

* Transparent background.
* Borderless window.
* Always on top.
* Click-through.
* Mouse passthrough.
* Không xuất hiện viền cửa sổ.
* Không chiếm toàn bộ màn hình.
* Có thể ghim sát taskbar.
* Có thể kéo sang màn hình khác.
* Hỗ trợ nhiều màn hình.
* Có Compact Mode.
* Có Expanded Mode.
* Có Performance Mode.
* Có Interactive Mode.

---

## 12. Interaction Mode

### 12.1. Interactive Mode

Trong chế độ này:

* Game nhận input chuột.
* Người chơi có thể bấm vào nhân vật.
* Có thể bấm vào loot.
* Có thể bấm vào rương.
* Có thể mở menu.
* Có thể kéo cửa sổ.

### 12.2. Click-through Mode

Trong chế độ này:

* Chuột xuyên qua cửa sổ game.
* Người chơi vẫn thao tác được với ứng dụng phía dưới.
* Game tiếp tục chạy và hiển thị animation.
* Có thể dùng hotkey để bật lại Interactive Mode.

### 12.3. Hybrid Mode

Chỉ những vùng có thể tương tác mới nhận chuột.

Ví dụ:

* Nhân vật.
* Loot.
* Treasure Chest.
* Merchant.
* Nút mở menu.

Các vùng trong suốt còn lại cho phép chuột xuyên qua.

Hybrid Mode là mục tiêu tốt nhất cho phiên bản hoàn chỉnh.

---

## 13. Windows Integration

Godot xử lý các tính năng cửa sổ cơ bản.

Khi cần tích hợp sâu hơn, có thể sử dụng Win32 API thông qua GDExtension.

Các chức năng có thể cần:

* Tìm kích thước màn hình.
* Phát hiện vị trí taskbar.
* Phát hiện working area.
* Đặt cửa sổ sát taskbar.
* Điều khiển always-on-top.
* Điều khiển click-through.
* Tạo system tray.
* Đăng ký global hotkey.
* Khởi động cùng Windows.

Một số Windows API có thể sử dụng:

* `GetMonitorInfo`.
* `MonitorFromWindow`.
* `SHAppBarMessage`.
* `SetWindowLongPtr`.
* `SetWindowPos`.
* `RegisterHotKey`.

---

## 14. Linux Integration

Linux cần hỗ trợ ít nhất:

* Ubuntu.
* Linux Mint.
* Fedora.
* Arch-based distributions.

Hai môi trường hiển thị chính:

* X11.
* Wayland.

### 14.1. X11

X11 dễ triển khai hơn cho:

* Transparent window.
* Always on top.
* Click-through.
* Window positioning.
* Global hotkey.

X11 sẽ là môi trường Linux được ưu tiên trong giai đoạn đầu.

### 14.2. Wayland

Wayland hạn chế ứng dụng tự ý:

* Đặt chính xác vị trí cửa sổ.
* Đọc vị trí cửa sổ khác.
* Tạo global overlay.
* Bắt global hotkey.
* Can thiệp pointer.

Do đó, trên Wayland cần có fallback mode.

### 14.3. Linux Fallback Mode

Khi không thể đặt cửa sổ tự động, game cho phép:

* Người chơi kéo cửa sổ thủ công.
* Nhớ vị trí cửa sổ.
* Chạy như floating window.
* Tắt click-through.
* Chọn màn hình hiển thị.
* Chọn cạnh màn hình.

---

## 15. Mobile Direction

Android và iOS sử dụng cùng core gameplay nhưng không sử dụng giao diện taskbar.

Mobile sẽ có UI riêng.

### 15.1. Portrait Mode

Dùng cho:

* Quản lý nhân vật.
* Inventory.
* Equipment.
* Skill Tree.
* Account Tree.
* Pet.
* Gacha.
* Quest.
* Codex.
* Offline Reward.

### 15.2. Landscape Mode

Dùng cho:

* Xem battlefield.
* Boss Fight.
* Endless Mode.
* Dungeon.
* Survival.
* Tower.

### 15.3. Mobile Background Limitation

Mobile không cho phép game chạy liên tục trên màn hình như desktop trong thời gian dài.

Do đó mobile sẽ sử dụng:

* Offline Progress.
* Time simulation.
* Push notification.
* Background save.
* Cloud synchronization.

Mobile không cố mô phỏng taskbar overlay của PC.

---

## 16. Shared Core Architecture

Gameplay không được phụ thuộc trực tiếp vào giao diện desktop.

Core game phải có thể chạy độc lập.

Kiến trúc tổng thể:

```
Core Game
├── Combat
├── Characters
├── Monsters
├── Skills
├── Buffs
├── Equipment
├── Inventory
├── Pets
├── Progression
├── Chapters
├── Dungeons
├── Economy
├── Gacha
├── Prestige
└── Save System

Presentation
├── Desktop Taskbar View
├── Desktop Expanded View
├── Mobile Portrait View
└── Mobile Landscape View

Platform Layer
├── Windows
├── Linux X11
├── Linux Wayland
├── Android
└── iOS
```

---

## 17. Godot Scene Architecture

Cấu trúc scene đề xuất:

```
Main
├── GameState
├── SaveManager
├── AudioManager
├── PlatformManager
├── BattleManager
├── WindowManager
└── UIManager
```

Battle scene:

```
BattleScene
├── Background
├── Ground
├── UnitContainer
│   ├── PlayerUnits
│   ├── EnemyUnits
│   ├── Pets
│   └── Summons
├── ProjectileContainer
├── EffectContainer
├── LootContainer
└── BattleUI
```

Character scene:

```
Character
├── Shadow
├── AnimatedSprite2D
├── HealthBar
├── ManaBar
├── Hitbox
├── Hurtbox
├── SkillOrigin
└── StateMachine
```

Monster scene:

```
Monster
├── Shadow
├── AnimatedSprite2D
├── HealthBar
├── Hitbox
├── Hurtbox
├── StatusEffectContainer
└── StateMachine
```

---

## 18. Character State Machine

Mỗi nhân vật sử dụng state machine.

Các state cơ bản:

* Idle.
* Move.
* Chase.
* Attack.
* CastSkill.
* Hit.
* Stunned.
* Knockback.
* Dead.
* Victory.
* Rest.

Luồng ví dụ:

```
Idle
  ↓
Find Target
  ↓
Move
  ↓
Attack
  ↓
Cooldown
  ↓
Find Target
```

Khi có kỹ năng:

```
Attack
  ↓
Skill Ready
  ↓
Cast Skill
  ↓
Cooldown
```

---

## 19. Combat Tick

Combat logic không nên phụ thuộc hoàn toàn vào animation frame.

Nên tách:

* Visual frame.
* Combat simulation.
* Animation event.

Combat có thể chạy theo fixed tick.

Ví dụ:

* 10 đến 30 logic tick mỗi giây.
* Animation chạy 30 hoặc 60 FPS.
* Performance Mode có thể giảm animation xuống 15 hoặc 30 FPS.
* Offline simulation không cần chạy animation.

Lợi ích:

* Dễ cân bằng.
* Dễ tính offline reward.
* Không phụ thuộc FPS.
* Dễ tăng tốc trận đấu.
* Dễ chạy simulation nền.

---

## 20. Data-driven Design

Character, monster, skill và equipment không nên hard-code toàn bộ trong script.

Nên sử dụng Godot Resource.

Các resource chính:

* CharacterData.
* CharacterClassData.
* MonsterData.
* BossData.
* SkillData.
* BuffData.
* EquipmentData.
* EquipmentAffixData.
* PetData.
* StageData.
* ChapterData.
* DungeonData.
* LootTableData.
* GachaBannerData.

Ví dụ cấu trúc CharacterData:

```
CharacterData
├── ID
├── Name
├── Class
├── Base HP
├── Base Damage
├── Base Armor
├── Attack Speed
├── Movement Speed
├── Basic Attack
├── Active Skills
├── Ultimate
├── Passives
└── Sprite Set
```

---

## 21. Script Structure

Cấu trúc script đề xuất:

```
scripts/
├── core/
│   ├── game_manager.gd
│   ├── event_bus.gd
│   ├── game_clock.gd
│   └── constants.gd
├── combat/
│   ├── battle_manager.gd
│   ├── damage_calculator.gd
│   ├── target_selector.gd
│   ├── combat_unit.gd
│   └── status_effect_manager.gd
├── characters/
│   ├── character.gd
│   ├── character_state_machine.gd
│   └── character_progression.gd
├── monsters/
│   ├── monster.gd
│   ├── monster_spawner.gd
│   └── monster_ai.gd
├── skills/
│   ├── skill.gd
│   ├── skill_executor.gd
│   └── skill_targeting.gd
├── equipment/
│   ├── equipment_manager.gd
│   ├── equipment_generator.gd
│   ├── equipment_merge.gd
│   └── slot_enhancement.gd
├── progression/
│   ├── account_progression.gd
│   ├── prestige_manager.gd
│   └── unlock_manager.gd
├── save/
│   ├── save_manager.gd
│   ├── save_migration.gd
│   └── offline_progress.gd
├── platform/
│   ├── platform_manager.gd
│   ├── window_manager.gd
│   ├── windows_adapter.gd
│   ├── linux_adapter.gd
│   └── mobile_adapter.gd
└── ui/
    ├── ui_manager.gd
    ├── tooltip_manager.gd
    └── notification_manager.gd
```

---

## 22. Repository Structure

Cấu trúc repository đề xuất:

```
taskbar-heroes/
├── project.godot
├── README.md
├── LICENSE
├── assets/
│   ├── characters/
│   ├── monsters/
│   ├── bosses/
│   ├── pets/
│   ├── equipment/
│   ├── environments/
│   ├── effects/
│   ├── ui/
│   ├── fonts/
│   └── audio/
├── data/
│   ├── characters/
│   ├── classes/
│   ├── monsters/
│   ├── skills/
│   ├── buffs/
│   ├── equipment/
│   ├── pets/
│   ├── stages/
│   ├── chapters/
│   ├── dungeons/
│   └── loot_tables/
├── scenes/
│   ├── main/
│   ├── battle/
│   ├── characters/
│   ├── monsters/
│   ├── bosses/
│   ├── pets/
│   ├── effects/
│   ├── desktop/
│   ├── mobile/
│   └── ui/
├── scripts/
│   ├── core/
│   ├── combat/
│   ├── characters/
│   ├── monsters/
│   ├── skills/
│   ├── equipment/
│   ├── inventory/
│   ├── pets/
│   ├── progression/
│   ├── stages/
│   ├── dungeons/
│   ├── save/
│   ├── platform/
│   └── ui/
├── native/
│   ├── windows/
│   └── linux/
├── tests/
├── tools/
├── docs/
│   ├── GAME_OVERVIEW.md
│   ├── TECH_STACK.md
│   ├── COMBAT_DESIGN.md
│   ├── DATA_MODEL.md
│   └── ROADMAP.md
└── builds/
    ├── windows/
    ├── linux/
    ├── android/
    └── ios/
```

---

## 23. Save System

### Prototype

Prototype có thể sử dụng JSON.

Dữ liệu lưu:

* Account Level.
* Account EXP.
* Coin.
* Character List.
* Character Level.
* Character EXP.
* Skills.
* Equipment.
* Equipment Slot Level.
* Inventory.
* Pet.
* Stage Progress.
* Chapter Progress.
* Dungeon Progress.
* Prestige.
* Settings.
* Last Login Time.

### Phiên bản hoàn chỉnh

Có thể chuyển sang:

* Binary save.
* SQLite.
* Encrypted local save.
* Cloud save.

Save cần có:

* Version number.
* Migration system.
* Backup file.
* Auto-save.
* Manual recovery.
* Corruption protection.

---

## 24. Offline Progress

Offline progress không chạy lại từng frame chiến đấu.

Thay vào đó, hệ thống tính toán dựa trên:

* Thời gian offline.
* Stage hiện tại.
* Sức mạnh đội hình.
* Kill rate trung bình.
* Coin per minute.
* EXP per minute.
* Item drop rate.
* Dungeon bonus.
* Account upgrade.

Luồng xử lý:

1. Lưu thời điểm đóng game.
2. Khi mở game, lấy thời gian hiện tại.
3. Tính thời gian offline.
4. Giới hạn theo Offline Time Cap.
5. Tính phần thưởng.
6. Sinh danh sách loot.
7. Hiển thị Offline Report.
8. Lưu dữ liệu mới.

---

## 25. Art Pipeline

Công cụ đề xuất:

* Aseprite.
* LibreSprite.
* Krita.
* Photoshop.
* Affinity Photo.
* Blender nếu cần dựng mẫu hoặc render sprite.

Sprite cần có các animation cơ bản:

* Idle.
* Walk.
* Attack.
* Skill.
* Ultimate.
* Hit.
* Dead.
* Victory.
* Rest.

Quái có thể sử dụng ít animation hơn:

* Idle.
* Walk.
* Attack.
* Hit.
* Dead.

---

## 26. Sprite Direction

Vì quân địch tiến từ trên phải xuống dưới trái:

* Nhân vật người chơi chủ yếu quay về hướng trên phải.
* Quái chủ yếu quay về hướng dưới trái.

Có thể chỉ cần hai hướng sprite:

* Facing North-East.
* Facing South-West.

Nếu có kỹ năng di chuyển phức tạp, có thể bổ sung:

* North-West.
* South-East.

MVP nên ưu tiên hai hướng để giảm khối lượng art.

---

## 27. Sprite Size

Kích thước sprite tham khảo:

### Pixel Art nhỏ

* 32 × 32.
* 48 × 48.
* 64 × 64.

### Pixel Art chi tiết

* 96 × 96.
* 128 × 128.

Với cửa sổ cao khoảng 250 đến 350 pixel, kích thước hợp lý:

* Nhân vật thường: 64 đến 96 pixel.
* Quái thường: 64 đến 110 pixel.
* Boss: 140 đến 240 pixel.
* Pet: 32 đến 64 pixel.

Kích thước cuối cùng cần được kiểm tra trực tiếp trên battlefield prototype.

---

## 28. Animation Performance

Game chạy nền nên giới hạn tài nguyên.

Các chế độ:

### High Quality

* 60 FPS.
* Full particle.
* Damage text đầy đủ.
* Background animation đầy đủ.

### Balanced

* 30 FPS.
* Particle giảm.
* Gộp damage text.
* Background animation đơn giản.

### Performance

* 15 đến 30 FPS.
* Tắt particle phụ.
* Ẩn damage text nhỏ.
* Giảm animation background.
* Giảm số unit hiển thị.
* Có thể tạm dừng rendering khi bị che.

Combat simulation vẫn tiếp tục độc lập với rendering.

---

## 29. Audio Pipeline

Định dạng đề xuất:

* WAV cho âm thanh ngắn cần chất lượng cao.
* OGG cho nhạc và âm thanh dài.

Audio bus:

* Master.
* Music.
* Combat.
* Interface.
* Notification.
* Ambient.

Người chơi có thể:

* Tắt toàn bộ âm thanh.
* Chỉ bật âm loot hiếm.
* Chỉ bật âm boss.
* Chỉ bật âm desktop event.
* Giảm âm lượng khi game không được focus.

---

## 30. Testing Strategy

Các hệ thống cần unit test hoặc automated test:

* Damage calculation.
* Critical calculation.
* Equipment generation.
* Equipment merge.
* Loot table.
* EXP progression.
* Offline reward.
* Prestige reward.
* Save migration.
* Character stat calculation.
* Skill cooldown.
* Buff duration.

Các phần cần test thủ công:

* Animation.
* Window transparency.
* Click-through.
* Taskbar positioning.
* Multi-monitor.
* Linux desktop compatibility.
* DPI scaling.
* Mouse interaction.
* Visual overlap.
* Performance khi chạy nền.

---

## 31. Continuous Integration

GitHub Actions có thể tự động:

* Kiểm tra GDScript.
* Chạy test.
* Export Windows.
* Export Linux.
* Tạo artifact.
* Tạo development build.
* Gắn version number.

Các branch đề xuất:

* `main`: phiên bản ổn định.
* `develop`: nhánh phát triển chính.
* `feature/*`: tính năng.
* `fix/*`: sửa lỗi.
* `release/*`: chuẩn bị phát hành.

---

## 32. Distribution

### Windows

Các lựa chọn:

* Portable ZIP.
* Installer.
* Steam.
* Itch.io.
* Microsoft Store trong tương lai.

### Linux

Các lựa chọn:

* Portable binary.
* AppImage.
* Flatpak.
* Steam.
* Itch.io.

AppImage phù hợp cho bản thử nghiệm vì dễ phân phối.

Flatpak phù hợp cho phiên bản hoàn chỉnh nhưng cần kiểm tra hạn chế sandbox đối với window integration.

### Android

* APK cho testing.
* AAB cho Google Play.

### iOS

* Xcode project.
* TestFlight.
* App Store.

Build iOS yêu cầu macOS và Xcode.

---

## 33. Cloud Save

Cloud save chưa cần thiết trong MVP.

Có thể thêm khi bắt đầu phát triển mobile.

Giải pháp đề xuất:

* Supabase Auth.
* Supabase Database.
* Supabase Storage.
* Row Level Security.

Dữ liệu có thể đồng bộ:

* Account Progress.
* Characters.
* Equipment.
* Pets.
* Prestige.
* Settings.
* Purchase History nếu có.

Không nên đồng bộ liên tục mỗi thay đổi nhỏ.

Có thể đồng bộ khi:

* Người chơi mở game.
* Người chơi đóng game.
* Hoàn thành chapter.
* Thực hiện prestige.
* Nhận vật phẩm hiếm.
* Bấm nút Sync.

---

## 34. Monetization Direction

MVP không cần monetization.

Nếu phát hành thương mại, có thể lựa chọn:

### Premium Game

* Mua game một lần.
* Không quảng cáo.
* Không bán sức mạnh.

### Cosmetic DLC

* Skin nhân vật.
* Skin pet.
* Battlefield theme.
* Hiệu ứng kỹ năng.
* UI theme.

### Expansion

* Chapter mới.
* Class mới.
* Dungeon mới.
* Boss mới.

Nếu có gacha, ưu tiên sử dụng currency kiếm trong gameplay.

Không nên thiết kế core progression phụ thuộc vào thanh toán.

---

## 35. MVP Technical Scope

MVP kỹ thuật gồm:

### Window

* Transparent window.
* Borderless.
* Always on top.
* Vị trí sát cạnh dưới màn hình.
* Interactive Mode.
* Click-through Mode cơ bản.

### Battlefield

* Pseudo-isometric background.
* Player spawn ở dưới trái.
* Enemy spawn ở trên phải.
* Một lane chính.
* Y-sort.
* Unit shadow.

### Combat

* Một nhân vật.
* Một loại quái.
* Auto target.
* Auto move.
* Auto attack.
* HP.
* Damage.
* Attack cooldown.
* Death.
* Respawn quái.

### Progression

* Coin.
* EXP.
* Character Level.
* Stage Counter.
* Kill Counter.

### Data

* CharacterData.
* MonsterData.
* StageData.

### Save

* JSON save.
* Auto-save.
* Last login timestamp.

### Platform

* Windows build.
* Linux X11 build.

---

## 36. Prototype Milestones

### Milestone 1: Window Prototype

Mục tiêu:

* Tạo cửa sổ trong suốt.
* Không có viền.
* Luôn nổi.
* Đặt sát cạnh dưới màn hình.
* Có thể bật và tắt click-through.

### Milestone 2: Isometric Visual Prototype

Mục tiêu:

* Vẽ battlefield chéo.
* Đặt nhân vật ở dưới trái.
* Đặt quái ở trên phải.
* Cho quái tiến đến đội hình.
* Kiểm tra Y-sort.

### Milestone 3: Combat Prototype

Mục tiêu:

* Nhân vật tìm mục tiêu.
* Di chuyển.
* Đánh thường.
* Quái phản công.
* Unit chết.
* Spawn quái mới.

### Milestone 4: Stage Loop

Mục tiêu:

* Kill Counter.
* Stage Progress.
* Boss xuất hiện.
* Chuyển stage.
* Nhận coin và EXP.

### Milestone 5: Team Prototype

Mục tiêu:

* Ba nhân vật.
* Frontline.
* Backline.
* Tank.
* DPS.
* Healer.

### Milestone 6: Equipment Prototype

Mục tiêu:

* Trang bị rơi.
* Inventory.
* Equip.
* Rarity.
* Bonus Stat.
* Slot Enhancement.

---

## 37. Những rủi ro kỹ thuật

### 37.1. Wayland

Rủi ro:

* Không đặt được cửa sổ chính xác.
* Click-through bị giới hạn.
* Always-on-top phụ thuộc compositor.
* Global hotkey bị giới hạn.

Giải pháp:

* Hỗ trợ X11 trước.
* Có Floating Mode cho Wayland.
* Cho phép kéo và lưu vị trí thủ công.

### 37.2. Transparent Window

Rủi ro:

* Khác biệt giữa GPU driver.
* Viền đen trên một số compositor.
* Artifact khi dùng particle.
* Không tương thích tốt với HDR.

Giải pháp:

* Test nhiều GPU.
* Có Solid Background Mode.
* Cho phép chọn transparency.
* Giảm hiệu ứng shader phức tạp.

### 37.3. Multi-monitor

Rủi ro:

* Khác DPI.
* Taskbar nằm ở màn hình phụ.
* Taskbar nằm bên trái hoặc bên phải.
* Độ phân giải hỗn hợp.

Giải pháp:

* Cho phép chọn monitor.
* Cho phép chọn cạnh màn hình.
* Lưu vị trí theo monitor.
* Có nút Reset Window Position.

### 37.4. Performance

Rủi ro:

* Game chạy nền quá nặng.
* Particle và animation sử dụng GPU.
* Nhiều unit gây tụt FPS.
* Game ảnh hưởng ứng dụng chính.

Giải pháp:

* Giới hạn FPS.
* Performance Mode.
* Giảm particle.
* Object pooling.
* Tách simulation khỏi rendering.
* Tạm dừng rendering khi không cần thiết.

---

## 38. Coding Principles

Các nguyên tắc phát triển:

* Data-driven thay vì hard-code.
* Composition thay vì inheritance quá sâu.
* Core gameplay không phụ thuộc UI.
* Core gameplay không phụ thuộc platform.
* Simulation không phụ thuộc FPS.
* Mọi hệ thống phải hỗ trợ save/load.
* Mọi dữ liệu cần có ID ổn định.
* Không tối ưu quá sớm.
* Prototype mechanic trước khi làm art hoàn chỉnh.
* Không phát triển Windows và Linux bằng hai codebase riêng.

---

## 39. Kết luận

Công nghệ chính của dự án:

* Godot 4.x.
* GDScript.
* 2D Pseudo-Isometric.
* Godot Resource.
* JSON hoặc SQLite.
* C++ hoặc Rust GDExtension khi cần native integration.
* Windows và Linux trước.
* Android và iOS sau.

Game sử dụng góc nhìn chéo 3/4.

Đội người chơi đứng ở khu vực dưới bên trái và quân địch tiến đến từ khu vực trên bên phải.

Gameplay sử dụng hệ tọa độ 2D thông thường, kết hợp sprite pseudo-isometric và Y-sort để tạo cảm giác 2.5D.

MVP không sử dụng hệ thống 3D thật và không sử dụng grid isometric phức tạp.

Ưu tiên đầu tiên của dự án là tạo một prototype chứng minh ba yếu tố:

1. Cửa sổ game trong suốt hoạt động ổn định trên desktop.
2. Battlefield pseudo-isometric nhìn rõ trong không gian sát taskbar.
3. Quan sát đội hình tự động chiến đấu trong thời gian dài vẫn tạo cảm giác thú vị.

Sau khi ba yếu tố này hoạt động tốt, dự án mới mở rộng sang progression, equipment, pet, dungeon, prestige và mobile.
