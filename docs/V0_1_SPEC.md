# The Journey RPG - V0.1 Spec

> Bản đặc tả ngắn cho prototype đầu tiên
> Mục tiêu: chuyển từ ý tưởng sang định nghĩa sản phẩm đủ rõ để bắt đầu làm

---

## 1. Mục tiêu của V0.1

`V0.1` là prototype đầu tiên để kiểm tra xem fantasy cốt lõi của game có hoạt động hay không.

Prototype này không nhằm xây dựng đầy đủ toàn bộ hệ thống idle RPG.

Nó chỉ cần chứng minh 4 điều:

1. Game có thể sống như một cửa sổ nhỏ trên desktop mà không gây khó chịu.
2. Trận chiến nhỏ vẫn dễ đọc khi người chơi chỉ nhìn lướt vài giây.
3. Cơ chế đội hình đặt nền móng cho cảm giác đây sẽ là một party đang phiêu lưu, thay vì một unit đơn lẻ tồn tại cố định suốt game.
4. Loot rơi ra đủ hấp dẫn để khiến người chơi muốn liếc xuống thêm lần nữa.

---

## 2. Fantasy cốt lõi cần giữ

`The Journey RPG` phải mang lại cảm giác:

* Một đội hình nhỏ đang thực sự sống trên desktop.
* Cuộc phiêu lưu vẫn tiếp diễn trong lúc người chơi làm việc khác.
* Mỗi lần nhìn xuống đều có khả năng thấy một diễn biến đáng chú ý.
* Loot là phần thưởng thị giác và tiến trình quan trọng nhất trong bản đầu.

---

## 3. Hành vi desktop

Game trong `V0.1` là một cửa sổ thật:

* Có thể kéo tới nhiều vị trí trên màn hình.
* Ưu tiên đặt sát cạnh dưới màn hình trong trải nghiệm mặc định.
* Có thể có viền hoặc khung khi cần chỉnh vị trí và cấu hình.
* Khi ở trạng thái hiển thị chính, cửa sổ nên tạo cảm giác hòa vào desktop nhiều nhất có thể.

Chưa cần trong `V0.1`:

* Hỗ trợ mọi kiểu taskbar layout phức tạp.
* Tối ưu sâu cho nhiều màn hình.
* Tương thích hoàn chỉnh với mọi trường hợp Linux window manager.

---

## 4. Nhịp sử dụng kỳ vọng

Người chơi không theo dõi game liên tục.

Nhịp sử dụng chính:

* Liếc nhanh 2 đến 5 giây trong lúc làm việc.
* Thỉnh thoảng dừng 10 đến 30 giây để xem loot, thay đồ hoặc chỉnh đội hình.

Hệ quả thiết kế:

* Mọi thông tin quan trọng phải đọc được rất nhanh.
* Hiệu ứng không được quá rối.
* Loot hiếm phải nổi bật hơn mọi tín hiệu phụ.
* Trạng thái trận đấu phải hiểu được ngay cả khi không mở panel quản lý.

---

## 5. Combat Presentation

`V0.1` ưu tiên readability trước phong cách.

Định hướng trình bày:

* Combat 2D nhỏ gọn.
* Có thể dùng pseudo-isometric nhẹ để tạo bản sắc.
* Không dùng true isometric.
* Không để góc nhìn hoặc hiệu ứng làm khó đọc unit và loot.
* Unit cần silhouette rõ.
* Loot cần dễ nhận ra hơn background và hiệu ứng.

Nguyên tắc:

**Nếu một lựa chọn hình ảnh làm game đẹp hơn nhưng khó đọc hơn, ưu tiên phương án dễ đọc hơn.**

---

## 6. Core Gameplay của V0.1

Prototype cần có một vòng lặp đủ ngắn và rõ:

1. Đội hình tự chiến đấu.
2. Quái xuất hiện.
3. Quái bị tiêu diệt.
4. Coin, EXP hoặc loot rơi ra.
5. Người chơi liếc xuống để xem có gì đáng chú ý.
6. Khi cần, người chơi mở phần quản lý ngắn để thay đồ hoặc chỉnh đội hình.
7. Đội hình tiếp tục chiến đấu mạnh hơn trước.

---

## 7. Quy mô đội hình

`V0.1` cần có cơ chế đội hình ngay từ đầu.

Yêu cầu:

* Bắt đầu với 1 thành viên.
* Các slot tiếp theo được mở khóa dần qua cây nhân vật hoặc hệ tiến trình tương ứng.
* Giao diện và hệ thống phải được thiết kế sẵn theo hướng có nhiều thành viên trong đội hình về sau.

Mục tiêu của đội hình trong `V0.1` không phải độ sâu chiến thuật tối đa.

Mục tiêu là:

* Đặt nền móng cho fantasy về một party sẽ lớn dần theo tiến trình.
* Tạo động lực mở thêm slot nhân vật.
* Cho phép sản phẩm mở rộng sang frontline, backline và vai trò khác nhau trong các bản sau.

---

## 8. Loot Loop

Loot là điểm nhấn hấp dẫn nhất của bản đầu.

`V0.1` cần làm tốt các điều sau:

* Quái có thể rơi coin và item.
* Item rơi ra phải dễ thấy.
* Người chơi phải nhận ra nhanh item nào đáng chú ý.
* Equip item mới phải tạo khác biệt sức mạnh đủ rõ.

Loot hiếm hoặc loot đáng chú ý nên được nhấn mạnh bằng:

* Màu bao quanh item.
* Cột sáng hoặc beam có màu tương ứng với rarity.

Định hướng:

* Số lượng item không cần nhiều.
* Không cần quá nhiều rarity.
* Tập trung vào cảm giác "có món gì ngon vừa rơi ra không".

---

## 9. Phạm vi hệ thống nên có

`V0.1` nên có:

* Một cửa sổ game hoạt động trên desktop.
* Một battlefield nhỏ.
* Một nhân vật khởi đầu.
* Cơ chế mở thêm slot đội hình về sau.
* Vai trò cơ bản như frontline và backline.
* Auto combat cơ bản.
* Quái thường.
* Một boss đơn giản hoặc elite rõ ràng.
* EXP hoặc level cơ bản.
* Coin hoặc một currency đơn giản.
* Equipment cơ bản.
* Panel tính năng mở dạng thẻ hoặc popup nhưng vẫn giữ combat nhìn thấy được.
* Local save cơ bản.

---

## 10. Phạm vi chưa nên có

`V0.1` chưa cần:

* Gacha.
* Pet system hoàn chỉnh.
* Nhiều chapter.
* Dungeon riêng.
* Prestige.
* Endless tower.
* PvP.
* Cloud save.
* Mobile build.
* Hệ stat quá sâu.
* Quá nhiều class.

---

## 11. Tiêu chí đánh giá V0.1 thành công

`V0.1` được xem là đúng hướng nếu:

* Cửa sổ desktop chạy ổn định trong thời gian dài.
* Người chơi nhìn lướt vẫn hiểu chuyện gì đang xảy ra.
* Cảm giác mở rộng từ một nhân vật khởi đầu sang một party về sau là hợp lý và hấp dẫn.
* Loot tạo ra khoảnh khắc đáng chờ.
* Sau vài phút, người chơi có lý do để liếc xuống thêm.

---

## 12. Câu hỏi còn lại ngay sau V0.1

Sau khi có prototype đầu tiên, các câu hỏi tiếp theo nên là:

* Có cần click-through sớm không?
* Pseudo-isometric nhẹ có thực sự giúp game khác biệt mà vẫn dễ đọc không?
* Tốc độ mở slot đội hình nên nhanh đến mức nào để vừa thấy tiến trình vừa không mất hook sớm?
