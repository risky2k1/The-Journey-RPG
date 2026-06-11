# The Journey RPG - Open Questions

> Danh sách các quyết định chưa chốt
> Mục tiêu: tách rõ câu hỏi mở khỏi phần đã quyết định

---

## 1. Product Positioning

* Game này là một desktop companion có combat RPG, hay là một RPG idle hiển thị trên desktop?
* Người chơi nên nhớ tới game vì cảm giác ambient trên desktop, hay vì chiều sâu build?
* Mức độ tương tác lý tưởng là rất ít, vừa phải, hay thường xuyên?

---

## 2. Desktop Behavior

* Game sẽ nằm đè lên taskbar, nằm ngay phía trên taskbar, hay là một strip riêng ở cạnh dưới màn hình?
* Click-through là mặc định hay tùy chọn?
* Có cần cho phép kéo thả tự do vị trí cửa sổ không?
* Có cần hỗ trợ nhiều màn hình ngay từ đầu không?
* Linux có hỗ trợ Wayland từ đầu hay chỉ tập trung X11 trước?

---

## 3. Visual Readability

* Kích thước nhân vật tối thiểu là bao nhiêu để vẫn đọc được animation?
* Pseudo-isometric có thực sự rõ hơn góc nhìn 2D đơn giản hơn không?
* Damage text có cần xuất hiện thường xuyên không, hay nên giảm để đỡ rối?
* Loot hiếm sẽ được làm nổi bật bằng màu, ánh sáng, âm thanh, hay icon?

---

## 4. Core Combat

* Nhân vật chủ yếu đứng lane cố định hay có di chuyển đáng kể?
* Combat nên thiên về wave defense, lane battle, hay stage push liên tục?
* Một trận nên kéo dài bao lâu để phù hợp nhịp nhìn-lướt?
* Boss xuất hiện theo số kill, theo thời gian, hay theo stage progress?
* Người chơi có được can thiệp trong combat bằng skill thủ công không?

---

## 5. Progression

* Tiến độ chính nên xoay quanh hero đơn lẻ lúc đầu hay mở đội hình rất sớm?
* Hero là nhân vật cụ thể có tên tuổi riêng, hay chỉ là đại diện class?
* Điểm hấp dẫn dài hạn là loot, build, hay mở thêm thành viên đội hình?
* Có thật sự cần prestige trong các giai đoạn đầu không?

---

## 6. Content Scope

* Class đầu tiên nên là gì để dễ đọc và dễ làm nhất?
* Có cần healer trong bản đầu hay chỉ tank và DPS là đủ?
* Có cần nhiều biome và chapter sớm không, hay chỉ một môi trường là đủ cho prototype?
* Pet có phải hệ thống tạo khác biệt sớm, hay chỉ là phần mở rộng về sau?

---

## 7. UX and Management

* Panel quản lý nên mở như popup nhỏ, side panel, hay cửa sổ riêng?
* Người chơi sẽ thay đồ trực tiếp nhiều lần, hay game nên có auto-equip cơ bản?
* Inventory có thật sự cần hiển thị nhiều item từ đầu không?
* Có cần chế độ compact và expanded ngay trong giai đoạn đầu không?

---

## 8. Technical Decisions

* Có cần native integration ngay từ đầu để bám desktop tốt hơn không, hay Godot thuần là đủ cho prototype?
* Save format nên bắt đầu bằng JSON đơn giản hay thiết kế luôn hướng có migration?
* Nên tối ưu cho Windows trước hoàn toàn, hay cố giữ Linux chạy sớm để tránh lệch kiến trúc?

---

## 9. Quyết định tạm thời cho MVP

Đây là nhóm quyết định đã tạm chốt vì ảnh hưởng trực tiếp tới MVP:

1. Game là một cửa sổ thật trên desktop, có thể kéo tới nhiều vị trí. Khi cần chỉnh hoặc cấu hình thì có khung hoặc viền đủ để thao tác, còn ở trạng thái hiển thị chính thì ưu tiên cảm giác hòa vào desktop.
2. Người chơi chủ yếu nhìn game theo nhịp liếc ngắn 2 đến 5 giây trong lúc làm việc, và thỉnh thoảng dừng 10 đến 30 giây để xem loot, thay đồ hoặc chỉnh đội hình.
3. Combat của MVP ưu tiên readability trước. Pseudo-isometric chỉ nên dùng ở mức nhẹ để tạo bản sắc thị giác, không được làm giảm độ rõ của unit, loot và trạng thái trận đấu.
4. MVP cần có cơ chế đội hình ngay từ đầu. Bản đầu có thể bắt đầu với 1 thành viên, nhưng hệ thống phải được thiết kế sẵn để người chơi mở thêm slot và mở rộng party theo tiến trình.
5. Khoảnh khắc hấp dẫn nhất khiến người chơi muốn liếc xuống thêm lần nữa là xem có loot gì vừa rơi ra, đặc biệt là đồ ngon hoặc đồ hiếm.

---

## 10. Câu hỏi còn mở tiếp theo

Sau khi chốt nhóm quyết định trên, đây là những câu hỏi còn nên tiếp tục làm rõ:

* Click-through sẽ là tùy chọn thủ công hay tự bật theo trạng thái?
* Combat sẽ thiên về lane cố định hay có dịch chuyển ngắn giữa các vị trí?
* Tốc độ mở slot nhân vật tiếp theo nên diễn ra sớm đến mức nào?
* Panel tính năng sẽ mở từ cạnh nào của window để vẫn giữ combat dễ quan sát nhất?
