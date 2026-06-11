# The Journey RPG - UI Flow

> Tài liệu chốt luồng giao diện cho prototype đầu tiên
> Mục tiêu: mọi thao tác quản lý vẫn giữ combat hiện diện trên màn hình

---

## 1. Nguyên tắc UI cốt lõi

UI của `The Journey RPG` không nên tách người chơi ra khỏi trận chiến.

Khi người chơi mở một tính năng như:

* Túi đồ.
* Nhân vật.
* Đội hình.
* Nâng cấp.
* Cài đặt nhanh.

thì combat vẫn phải tiếp tục chạy và vẫn phải nhìn thấy được.

Nguyên tắc cốt lõi:

**Mở UI là để quản lý cuộc phiêu lưu đang diễn ra, không phải để rời khỏi nó.**

---

## 2. Cấu trúc window tổng quát

`V0.1` nên dùng một cửa sổ chính duy nhất.

Bên trong cửa sổ này có 2 lớp:

* `Battle Layer`: khu vực combat luôn hiển thị.
* `Panel Layer`: các thẻ hoặc panel quản lý trượt ra khi cần.

Battle Layer là phần luôn được ưu tiên giữ visible.

Panel Layer chỉ chiếm một phần cửa sổ, không che toàn bộ battlefield.

---

## 3. Trạng thái mặc định

Khi người chơi không mở panel nào, cửa sổ nên ở trạng thái:

* Gọn.
* Ít chrome.
* Tập trung vào combat.
* Chỉ hiển thị vài thông tin ngắn như:
  * stage.
  * coin.
  * loot nổi bật.
  * nút mở panel.

Trạng thái này là trạng thái người chơi nhìn thấy nhiều nhất trong ngày.

---

## 4. Cách mở panel

Các tính năng chính nên mở dưới dạng:

* Tab trượt ra.
* Thẻ nổi gắn vào mép cửa sổ.
* Side panel hẹp.

Không nên dùng trong `V0.1`:

* Menu full-screen.
* Popup che toàn bộ trận đấu.
* Cửa sổ quản lý hoàn toàn tách rời combat cho các thao tác thường xuyên.

---

## 5. Hướng mở panel đề xuất

Đề xuất thực dụng cho `V0.1`:

* Combat nằm ở phần trung tâm hoặc lệch trái của window.
* Panel quản lý trượt ra từ cạnh phải.

Lý do:

* Dễ giữ battlefield còn nhìn thấy.
* Phù hợp với thói quen đọc thông tin từ trái sang phải.
* Hạn chế che khu vực spawn hoặc loot nếu combat được bố trí ổn định.

Nếu battlefield sau này thiên về trải dài ngang mạnh hơn, có thể xem xét panel đáy hoặc panel nổi hẹp.

---

## 6. Luồng túi đồ

Khi người chơi bấm `Túi đồ`:

* Một panel mở ra từ cạnh phải.
* Combat vẫn tiếp tục chạy phía còn lại.
* Item mới nhặt vẫn có thể tiếp tục xuất hiện trên battlefield.
* Người chơi có thể xem item, so sánh nhanh và equip.

Mục tiêu UX:

* Không mất nhịp quan sát loot.
* Không bị cảm giác chuyển sang một màn hình khác.

---

## 7. Luồng nhân vật và đội hình

Khi người chơi bấm `Nhân vật` hoặc `Đội hình`:

* Mở panel quản lý cùng kiểu với túi đồ.
* Hiển thị slot hiện có.
* Hiển thị slot khóa nếu chưa mở.
* Cho thấy rõ rằng đội hình sẽ còn mở rộng về sau.

Trong `V0.1`, dù bắt đầu chỉ với 1 thành viên, UI vẫn nên biểu đạt:

* Có nhiều slot tiềm năng.
* Có tiến trình để mở thêm.
* Battle hiện tại chỉ là giai đoạn khởi đầu của một party lớn hơn.

---

## 8. Luồng loot

Loot là tín hiệu thị giác quan trọng nhất trong bản đầu.

UI cần hỗ trợ:

* Item rơi ra đủ nổi.
* Nếu item đáng chú ý, người chơi nhận ra ngay cả khi panel đang mở.
* Có thể có một vùng feed nhỏ hoặc dấu hiệu ngắn cho item mới nhặt.

Loot hiếm nên có:

* Màu bao quanh.
* Beam hoặc cột sáng theo rarity.
* Tên item hoặc icon ngắn nếu cần.

---

## 9. Luồng settings nhanh

`V0.1` không cần menu settings lớn.

Chỉ cần một panel nhỏ cho các tùy chọn hay dùng:

* Bật hoặc tắt viền.
* Kéo vị trí window.
* Scale cơ bản.
* Always on top.
* Click-through nếu có.

Nếu cần cấu hình sâu hơn sau này, có thể thêm cửa sổ riêng.

---

## 10. Những gì UI phải tránh

Trong prototype đầu, UI nên tránh:

* Quá nhiều chữ.
* Quá nhiều panel cùng lúc.
* Chuyển scene khi chỉ muốn xem inventory.
* Popup xác nhận dày đặc.
* Combat bị che quá nhiều.
* Loot bị chìm khi panel đang mở.

---

## 11. Tiêu chí UI của V0.1 thành công

UI được xem là đi đúng hướng nếu:

* Người chơi luôn thấy combat khi đang quản lý.
* Mở panel không làm mất cảm giác game đang sống.
* Loot vẫn là điểm hút mắt mạnh nhất.
* Người chơi có thể chỉnh vài thứ nhanh rồi quay lại quan sát ngay.
* Window vẫn gọn và không gây cảm giác chiếm desktop quá mức.

---

## 12. Câu hỏi còn mở

Sau khi prototype UI xuất hiện, cần tiếp tục chốt:

* Panel nên rộng bao nhiêu phần trăm so với battlefield?
* Có nên cho phép ghim panel luôn mở không?
* Có cần mini log cho loot gần đây không?
* Có cần auto-close panel sau một thời gian không thao tác không?
