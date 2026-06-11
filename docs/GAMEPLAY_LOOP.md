# The Journey RPG - Gameplay Loop

> Tài liệu chốt vòng lặp gameplay cho prototype đầu tiên
> Mục tiêu: xác định rõ người chơi nhìn thấy gì, nhận gì, và quay lại vì điều gì

---

## 1. Mục tiêu của gameplay loop

Gameplay loop của `The Journey RPG` phải phục vụ 3 mục tiêu:

1. Tạo cảm giác một cuộc phiêu lưu nhỏ đang tiếp tục diễn ra trên desktop.
2. Đủ dễ đọc để người chơi chỉ cần liếc vài giây vẫn hiểu đang có tiến triển.
3. Tạo ra những khoảnh khắc chờ đợi rõ ràng, đặc biệt là khi loot rơi ra hoặc khi mở gần tới slot đội hình tiếp theo.

---

## 2. Vòng lặp cốt lõi

Vòng lặp cốt lõi của bản đầu nên là:

1. Nhân vật tự chiến đấu.
2. Quái xuất hiện liên tục.
3. Quái bị tiêu diệt.
4. Người chơi nhận coin, EXP và cơ hội rơi item.
5. Sức mạnh tăng dần nhờ level hoặc thay đồ.
6. Stage tiếp tục đẩy lên nếu đội hình đủ mạnh.
7. Người chơi thỉnh thoảng mở panel để xem loot, thay đồ và kiểm tra tiến trình mở slot đội hình.

Đây là một loop ngắn, lặp nhanh, dễ nhìn, không yêu cầu tương tác liên tục.

---

## 3. Nhịp quan sát của người chơi

Gameplay phải phù hợp với nhịp sử dụng desktop:

* Phần lớn thời gian người chơi chỉ liếc 2 đến 5 giây.
* Thỉnh thoảng họ dừng 10 đến 30 giây để quản lý.

Vì vậy, loop phải có các tín hiệu rõ:

* Quái xuất hiện và chết đủ nhanh để luôn có chuyển động.
* Loot rơi ra đủ nổi để hút mắt.
* Boss hoặc elite tạo nhịp thay đổi rõ rệt.
* Thanh tiến trình stage hoặc kill count tăng đều để tạo cảm giác đang tiến lên.

---

## 4. Flow trong một stage

Mỗi stage trong `V0.1` nên rất đơn giản.

Một stage gồm:

* Một loại quái chính hoặc một nhóm quái rất nhỏ.
* Một mục tiêu cần hoàn thành.
* Một elite hoặc boss ở cuối stage.

Flow đề xuất:

1. Stage bắt đầu.
2. Quái thường xuất hiện theo nhịp.
3. Người chơi tiêu diệt quái để tăng progress.
4. Khi đạt ngưỡng progress, elite hoặc boss xuất hiện.
5. Đánh bại mục tiêu cuối để hoàn thành stage.
6. Nhận thưởng stage và chuyển sang stage tiếp theo.

---

## 5. Nhịp spawn quái

Spawn quái trong bản đầu nên ổn định và dễ đọc hơn là phức tạp.

Định hướng:

* Không spawn quá nhiều cùng lúc.
* Luôn có đủ mục tiêu để battle không bị đứng.
* Có khoảng nghỉ rất ngắn giữa các đợt để người chơi cảm được nhịp.

Mục tiêu UX:

* Luôn có thứ đang diễn ra trên battlefield.
* Không biến combat thành mớ hiệu ứng khó đọc.
* Loot có không gian thị giác để nổi bật.

---

## 6. Kill, progress và boss

Prototype nên dùng một trong hai cách:

* `Kill Count Progress`
* `Wave Progress`

Khuyến nghị cho `V0.1`:

* Dùng `Kill Count Progress` vì dễ hiểu và dễ quan sát.

Ví dụ flow:

* Stage yêu cầu hạ 20 quái.
* Mỗi quái chết tăng progress.
* Khi đạt đủ số lượng, boss xuất hiện.
* Hạ boss để sang stage tiếp theo.

Lợi ích:

* Người chơi hiểu tiến trình ngay.
* Dễ hiển thị bằng thanh hoặc số.
* Phù hợp với nhịp liếc ngắn.

---

## 7. Boss và elite

Boss hoặc elite là điểm nhấn để phá nhịp farm đều.

Vai trò của boss trong `V0.1`:

* Tạo khoảnh khắc dễ nhận ra.
* Làm người chơi muốn nhìn kỹ hơn vài giây.
* Tăng kỳ vọng về reward.

Yêu cầu:

* Boss phải nhìn khác quái thường.
* Có nhiều HP hơn.
* Có thể có 1 hành vi đơn giản khác biệt.
* Có tỉ lệ rơi thưởng tốt hơn.

Không cần trong `V0.1`:

* Nhiều phase boss.
* Cơ chế chiến đấu phức tạp.
* Bullet pattern dày đặc.

---

## 8. Loot loop

Loot là hook chính của gameplay loop.

Vòng lặp loot nên là:

1. Quái chết.
2. Có khả năng rơi item.
3. Nếu item đáng chú ý, nó nổi bật ngay.
4. Người chơi liếc xuống xem có món gì tốt.
5. Người chơi mở panel túi đồ nếu muốn kiểm tra hoặc equip.
6. Nhân vật mạnh lên thấy rõ.

Loot cần tạo được 3 tầng cảm giác:

* `Rơi đồ chưa?`
* `Đồ này có hiếm không?`
* `Có đáng thay món đang mặc không?`

---

## 9. EXP và tăng sức mạnh

Loop tăng sức mạnh trong `V0.1` nên ngắn và thấy rõ.

Nguồn tăng sức mạnh:

* EXP từ quái.
* Coin từ quái hoặc stage.
* Item rơi ra.

Kỳ vọng:

* Người chơi cảm thấy mạnh lên chỉ sau vài phút.
* Tăng level phải có phản hồi rõ.
* Trang bị mới phải tạo chênh lệch dễ nhận ra.

Không nên để progress quá chậm trong bản đầu, vì game cần chứng minh cảm giác "liếc lại là thấy tiến bộ".

---

## 10. Loop mở slot đội hình

Dù bắt đầu với 1 nhân vật, game cần gieo kỳ vọng rõ rằng party sẽ mở rộng.

Loop mở slot nên là:

1. Người chơi chiến đấu và nhận tài nguyên.
2. Tài nguyên hoặc mốc tiến trình được tích lũy cho việc mở slot mới.
3. UI luôn cho thấy còn các slot bị khóa.
4. Người chơi có động lực tiếp tục farm để mở thêm thành viên.

Mục tiêu của loop này:

* Tạo một đường tiến trình dài hơn ngoài loot.
* Làm người chơi nghĩ tới tương lai của party.
* Tăng cảm giác phát triển tài khoản hoặc đội hình.

Trong `V0.1`, chưa cần mở slot quá muộn.

Ngược lại, slot tiếp theo nên đủ gần để người chơi thấy đây là mục tiêu thực tế.

---

## 11. Hành vi khi người chơi không làm gì

Game phải vận hành tốt kể cả khi người chơi không tương tác.

Khi người chơi chỉ quan sát:

* Nhân vật vẫn đánh.
* Stage vẫn tiến.
* Quái vẫn rơi coin hoặc item.
* Progress vẫn tăng.

Điều này rất quan trọng vì phần lớn trải nghiệm của game diễn ra trong trạng thái bán-thụ-động.

---

## 12. Hành vi khi người chơi tương tác

Khi người chơi can thiệp, loop không bị tách khỏi battle.

Người chơi có thể:

* Mở túi đồ.
* Equip item.
* Xem nhân vật.
* Xem slot khóa.
* Kiểm tra progress.

Trong lúc đó:

* Combat vẫn tiếp tục.
* Loot vẫn có thể rơi.
* Boss vẫn có thể xuất hiện.

Đây là phần khác biệt quan trọng của trải nghiệm desktop-first.

---

## 13. Tempo mục tiêu cho V0.1

Tempo nên được thiết kế để luôn có điều gì đó xảy ra trong thời gian ngắn.

Đề xuất cảm giác tempo:

* Mỗi vài giây có ít nhất một quái chết.
* Mỗi khoảng ngắn có ít nhất một tín hiệu reward hoặc progress.
* Mỗi chu kỳ vừa phải có một khoảnh khắc nổi bật như item, elite hoặc boss.

Không nhất thiết chốt số giây chính xác ở giai đoạn tài liệu này, nhưng nhịp chung phải tránh hai lỗi:

* Quá chậm nên nhìn vào không thấy gì thú vị.
* Quá nhanh nên mọi thứ thành hỗn loạn.

---

## 14. Điều gì làm người chơi muốn liếc lại

Gameplay loop phải tối ưu cho các lý do liếc lại sau:

* Có loot gì vừa rơi ra không.
* Boss đã xuất hiện chưa.
* Progress stage đã đi tới đâu.
* Đã gần mở slot đội hình tiếp theo chưa.
* Nhân vật có đang bị kẹt hoặc chậm lại không.

Trong số này, loot vẫn là tín hiệu mạnh nhất.

---

## 15. Tiêu chí gameplay loop thành công

Gameplay loop của `V0.1` được xem là thành công nếu:

* Người chơi nhìn lướt vẫn thấy battle đang tiến triển.
* Loot là một phần thưởng thị giác rõ ràng.
* Mở panel quản lý không làm đứt mạch trải nghiệm.
* Progression đủ nhanh để tạo cảm giác mạnh lên sớm.
* Mở slot đội hình tiếp theo trở thành mục tiêu có ý nghĩa.

---

## 16. Câu hỏi còn mở

Sau khi prototype gameplay loop xuất hiện, cần tiếp tục chốt:

* Một stage nên kéo dài khoảng bao lâu?
* Slot đội hình thứ hai nên mở theo level, currency hay milestone stage?
* Boss reward nên thiên về coin, item hay cả hai?
* Có cần auto-equip đơn giản trong giai đoạn đầu không?
* Khi người chơi bị kẹt stage, game sẽ tự farm lại hay chờ người chơi quyết định?
