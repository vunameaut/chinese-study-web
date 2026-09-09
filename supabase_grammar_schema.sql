-- ====================================================================
-- SCRIPT IMPORT DỮ LIỆU NGỮ PHÁP GIÁO TRÌNH CHUẨN HSK 1, 2, 3 VÀO SUPABASE
-- (HSK Standard Course - NXB Đại học Ngôn ngữ Bắc Kinh / BLCUP)
-- ====================================================================
-- HƯỚNG DẪN IMPORT:
-- 1. Truy cập Supabase Dashboard -> chọn Project của bạn.
-- 2. Vào mục "SQL Editor" ở thanh menu bên trái.
-- 3. Bấm "New query", dán toàn bộ nội dung script này vào và bấm "Run" (hoặc Ctrl + Enter).
-- Toàn bộ 50 bài học (58 điểm ngữ pháp) HSK 1, 2, 3 sẽ được nạp vào bảng 'grammar'.
-- ====================================================================

-- 1. Tạo bảng grammar (nếu chưa có) hoặc cập nhật cấu trúc bảng
CREATE TABLE IF NOT EXISTS grammar (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT REFERENCES sessions(id) ON DELETE CASCADE,
  hsk_level INT NOT NULL DEFAULT 1,
  lesson_num INT NOT NULL DEFAULT 1,
  lesson_title TEXT,
  title TEXT NOT NULL,
  structure TEXT,
  explanation TEXT,
  examples JSONB DEFAULT '[]'::jsonb,
  exercises JSONB DEFAULT '[]'::jsonb,
  order_index INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cập nhật bổ sung các cột nếu bạn đã tạo bảng grammar cũ trước đó
ALTER TABLE grammar ADD COLUMN IF NOT EXISTS hsk_level INT DEFAULT 1;
ALTER TABLE grammar ADD COLUMN IF NOT EXISTS lesson_num INT DEFAULT 1;
ALTER TABLE grammar ADD COLUMN IF NOT EXISTS lesson_title TEXT;
ALTER TABLE grammar ALTER COLUMN session_id DROP NOT NULL;

-- 2. Đánh index tối ưu tốc độ truy vấn theo cấp độ HSK và bài học
CREATE INDEX IF NOT EXISTS idx_grammar_session_id ON grammar(session_id);
CREATE INDEX IF NOT EXISTS idx_grammar_hsk_lesson ON grammar(hsk_level, lesson_num);

-- 3. Cấu hình Row Level Security (RLS) để ứng dụng có quyền đọc/ghi
ALTER TABLE grammar ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'grammar' AND policyname = 'Allow public read on grammar') THEN
    CREATE POLICY "Allow public read on grammar" ON grammar FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'grammar' AND policyname = 'Allow public insert on grammar') THEN
    CREATE POLICY "Allow public insert on grammar" ON grammar FOR INSERT TO anon, authenticated WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'grammar' AND policyname = 'Allow public update on grammar') THEN
    CREATE POLICY "Allow public update on grammar" ON grammar FOR UPDATE TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'grammar' AND policyname = 'Allow public delete on grammar') THEN
    CREATE POLICY "Allow public delete on grammar" ON grammar FOR DELETE TO anon, authenticated USING (true);
  END IF;
END $$;

-- 4. Xóa dữ liệu mẫu giáo trình cũ (nếu có) để tránh trùng lặp khi chạy lại script
DELETE FROM grammar WHERE session_id IS NULL;

-- 5. Nạp toàn bộ dữ liệu 50 bài học HSK 1, 2, 3
INSERT INTO grammar (hsk_level, lesson_num, lesson_title, title, structure, explanation, examples, exercises, order_index)
VALUES
(
  1,
  1,
  'Bài 1: 你好 (Xin chào)',
  '1. Đại từ nhân xưng: 你 (nǐ), 您 (nín), 你们 (nǐmen)',
  '你 (bạn) | 您 (ngài / thầy - kính ngữ) | 你们 (các bạn - số nhiều)',
  'Trong tiếng Trung:<br>• <b>你</b> (nǐ) dùng với bạn bè, đồng trang lứa hoặc người dưới.<br>• <b>您</b> (nín) là dạng tôn kính, lịch sự dùng để xưng hô với người lớn tuổi, thầy cô, bề trên, đối tác.<br>• Thêm hậu tố <b>们</b> (men) vào sau đại từ để biểu thị số nhiều: <b>你们</b> (nǐmen - các bạn), 我们 (chúng tôi), 他们 (họ).',
  $$[{"hanzi":"你好！","pinyin":"Nǐ hǎo!","meaning":"Chào bạn!"},{"hanzi":"老师，您好！","pinyin":"Lǎoshī, nín hǎo!","meaning":"Em chào thầy/cô giáo ạ!"},{"hanzi":"你们好！","pinyin":"Nǐmen hǎo!","meaning":"Chào các bạn!"}]$$::jsonb,
  $$[{"type":"choice","question":"Chào thầy cô giáo một cách kính trọng, ta nói: 老师，___ 好！","options":["您","你","吗","谁"],"answer":"您","pinyin":"Lǎoshī, ___ hǎo!","meaning":"Em kính chào thầy ạ!","explanation":"Dạng kính ngữ tôn kính ngôi thứ hai là '您' (nín)."},{"type":"order","words":["老师","，","您","好","！"],"answer":"老师，您好！","pinyin":"Lǎoshī, nín hǎo!","meaning":"Em chào thầy giáo ạ!","explanation":"Thứ tự chào hỏi: Chức danh/Tên gọi trước, sau đó là lời chào '您好！'."}]$$::jsonb,
  1
),
(
  1,
  2,
  'Bài 2: 谢谢你 (Cảm ơn bạn)',
  '1. Lời cảm ơn và cách đáp lại lịch sự',
  'Cảm ơn: 谢谢 (你)！ -> Đáp lại: 不客气 / 不谢！',
  'Khi người khác giúp đỡ hoặc quan tâm, ta nói <b>谢谢</b> (Xièxie) hoặc <b>谢谢你</b> (Xièxie nǐ).<br>Để đáp lại lời cảm ơn một cách nhã nhặn, ta dùng:<br>• <b>不客气</b> (Bú kèqi - Đừng khách sáo / Không có chi).<br>• <b>不谢</b> (Bú xiè - Không cần cảm ơn).',
  $$[{"hanzi":"谢谢你！——不客气。","pinyin":"Xièxie nǐ! —— Bú kèqi.","meaning":"Cảm ơn bạn! —— Không có gì đâu."},{"hanzi":"谢谢！——不谢。","pinyin":"Xièxie! —— Bú xiè.","meaning":"Cảm ơn! —— Đừng khách khí."}]$$::jsonb,
  $$[{"type":"choice","question":"A: 谢谢你！ —— B: ___ 。","options":["不客气","没关系","你好","再见"],"answer":"不客气","pinyin":"Bú kèqi.","meaning":"Đừng khách sáo / Không có gì đâu.","explanation":"Đáp lại lời cảm ơn 谢谢 dùng '不客气'."}]$$::jsonb,
  1
),
(
  1,
  2,
  'Bài 2: 谢谢你 (Cảm ơn bạn)',
  '2. Lời xin lỗi và cách đáp lại',
  'Xin lỗi: 对不起！ -> Đáp lại: 没关系！',
  'Khi muốn xin lỗi vì làm phiền hoặc có lỗi, ta dùng <b>对不起</b> (Duìbuqǐ - Xin lỗi).<br>Người nghe khi chấp nhận lời xin lỗi sẽ nói <b>没关系</b> (Méi guānxi - Không sao đâu / Không có chi).',
  $$[{"hanzi":"对不起！——没关系。","pinyin":"Duìbuqǐ! —— Méi guānxi.","meaning":"Xin lỗi bạn! —— Không sao đâu."}]$$::jsonb,
  $$[{"type":"choice","question":"A: 对不起！ —— B: ___ 。","options":["没关系","不客气","不谢","明天见"],"answer":"没关系","pinyin":"Méi guānxi.","meaning":"Không sao đâu.","explanation":"Đáp lại lời xin lỗi 对不起 dùng '没关系'."}]$$::jsonb,
  2
),
(
  1,
  3,
  'Bài 3: 你叫什么名字 (Bạn tên là gì?)',
  '1. Đại từ nghi vấn 什么 (shénme - cái gì / gì)',
  'Động từ + 什么 (+ Danh từ)？',
  'Đại từ <b>什么</b> (shénme) dùng để hỏi về người hoặc sự vật. Trong câu hỏi tiếng Trung, trật tự từ giữ nguyên như câu trần thuật: từ nghi vấn đặt đúng vào vị trí của thông tin cần hỏi.',
  $$[{"hanzi":"你叫什么名字？","pinyin":"Nǐ jiào shénme míngzi?","meaning":"Bạn tên là gì?"},{"hanzi":"这是什么书？","pinyin":"Zhè shì shénme shū?","meaning":"Đây là sách gì?"},{"hanzi":"你想吃什么？","pinyin":"Nǐ xiǎng chī shénme?","meaning":"Bạn muốn ăn cái gì?"}]$$::jsonb,
  $$[{"type":"choice","question":"你叫 ___ 名字？","options":["什么","谁","哪","吗"],"answer":"什么","pinyin":"Nǐ jiào ___ míngzi?","meaning":"Bạn tên là gì?","explanation":"Hỏi tên gì dùng cụm '什么名字'."},{"type":"order","words":["你","叫","什么","名字","？"],"answer":"你叫什么名字？","pinyin":"Nǐ jiào shénme míngzi?","meaning":"Bạn tên là gì?","explanation":"Trật tự câu hỏi: Chủ ngữ (你) + Động từ (叫) + Đại từ nghi vấn (什么) + Danh từ (名字)."}]$$::jsonb,
  1
),
(
  1,
  3,
  'Bài 3: 你叫什么名字 (Bạn tên là gì?)',
  '2. Câu vị ngữ động từ với 叫 (jiào) và 是 (shì)',
  'Chủ ngữ + 叫 + Tên | Chủ ngữ + 是 + Danh tính/Nghề nghiệp',
  'Động từ <b>叫</b> (jiào) nghĩa là ''gọi là / tên là'', dùng để giới thiệu họ tên.<br>Động từ <b>是</b> (shì) nghĩa là ''là'', dùng để phán đoán danh tính, quốc tịch, nghề nghiệp.',
  $$[{"hanzi":"我叫李月。","pinyin":"Wǒ jiào Lǐ Yuè.","meaning":"Tôi tên là Lý Nguyệt."},{"hanzi":"我是中国人。","pinyin":"Wǒ shì Zhōngguó rén.","meaning":"Tôi là người Trung Quốc."},{"hanzi":"我不是美国人。","pinyin":"Wǒ bú shì Měiguó rén.","meaning":"Tôi không phải là người Mỹ."}]$$::jsonb,
  $$[{"type":"choice","question":"我 ___ 李月，我是学生。","options":["叫","吗","什么","的"],"answer":"叫","pinyin":"Wǒ ___ Lǐ Yuè, wǒ shì xuésheng.","meaning":"Tôi tên là Lý Nguyệt, tôi là học sinh.","explanation":"Nói tên riêng dùng động từ '叫'."}]$$::jsonb,
  2
),
(
  1,
  4,
  'Bài 4: 她是我的汉语老师 (Cô ấy là giáo viên tiếng Hán của tôi)',
  '1. Đại từ nghi vấn 谁 (shéi) và 哪 (nǎ)',
  'Ai: 谁？ | Cái nào/Nước nào: 哪 + Lượng từ + Danh từ？',
  '• <b>谁</b> (shéi) dùng để hỏi về người (ai).<br>• <b>哪</b> (nǎ) dùng để hỏi lựa chọn (nào), khi hỏi quốc tịch dùng cấu trúc: <b>哪国人</b> (nǎ guó rén - người nước nào).',
  $$[{"hanzi":"他是谁？——他是我的汉语老师。","pinyin":"Tā shì shéi? —— Tā shì wǒ de hànyǔ lǎoshī.","meaning":"Anh ấy là ai? —— Anh ấy là giáo viên tiếng Trung của tôi."},{"hanzi":"你是哪国人？——我是越南人。","pinyin":"Nǐ shì nǎ guó rén? —— Wǒ shì Yuènán rén.","meaning":"Bạn là người nước nào? —— Tôi là người Việt Nam."}]$$::jsonb,
  $$[{"type":"choice","question":"李老师是 ___ 国人？","options":["哪","什么","谁","几"],"answer":"哪","pinyin":"Lǐ lǎoshī shì ___ guó rén?","meaning":"Thầy Lý là người nước nào?","explanation":"Hỏi quốc tịch người nước nào bắt buộc dùng '哪国人'."}]$$::jsonb,
  1
),
(
  1,
  4,
  'Bài 4: 她是我的汉语老师 (Cô ấy là giáo viên tiếng Hán của tôi)',
  '2. Trợ từ kết cấu 的 (de) biểu thị sở hữu',
  'Định ngữ (Chủ sở hữu) + 的 + Trung tâm ngữ (Sự vật được sở hữu)',
  'Trợ từ <b>的</b> (de) nối giữa định ngữ và trung tâm ngữ để biểu thị mối quan hệ sở hữu (''của'').<br>Lưu ý: Khi trung tâm ngữ là người thân trong gia đình hoặc mối quan hệ mật thiết, có thể lược bỏ <b>的</b> (ví dụ: 我妈妈, 我朋友).',
  $$[{"hanzi":"这是我的书。","pinyin":"Zhè shì wǒ de shū.","meaning":"Đây là sách của tôi."},{"hanzi":"她是我的汉语老师。","pinyin":"Tā shì wǒ de hànyǔ lǎoshī.","meaning":"Cô ấy là giáo viên tiếng Trung của tôi."}]$$::jsonb,
  $$[{"type":"order","words":["她","是","我","的","汉语老师"],"answer":"她是我的汉语老师","pinyin":"Tā shì wǒ de hànyǔ lǎoshī.","meaning":"Cô ấy là giáo viên tiếng Trung của tôi.","explanation":"Cấu trúc sở hữu: Chủ ngữ (她) + 是 + Sở hữu (我的) + Danh từ (汉语老师)."}]$$::jsonb,
  2
),
(
  1,
  5,
  'Bài 5: 她女儿今年二十岁 (Con gái cô ấy năm nay 20 tuổi)',
  '1. Hỏi tuổi tác: 几岁 (jǐ suì) vs 多大 (duō dà)',
  'Hỏi trẻ em (< 10 tuổi): 你几岁了？ | Hỏi người ngang/lớn tuổi: 你多大了？',
  '• Dưới 10 tuổi: dùng <b>几岁</b> (jǐ suì).<br>• Đồng trang lứa hoặc người lớn: dùng <b>多大</b> (duō dà).<br>• Với người già, bề trên cần thêm kính ngữ: <b>您多大年纪了？</b>',
  $$[{"hanzi":"你女儿几岁了？——她今年四岁了。","pinyin":"Nǐ nǚ'ér jǐ suì le? —— Tā jīnnián sì suì le.","meaning":"Con gái bạn mấy tuổi rồi? —— Cháu năm nay 4 tuổi rồi."},{"hanzi":"李老师多大了？——她今年五十岁。","pinyin":"Lǐ lǎoshī duō dà le? —— Tā jīnnián wǔshí suì.","meaning":"Cô Lý bao nhiêu tuổi rồi? —— Cô năm nay 50 tuổi."}]$$::jsonb,
  $$[{"type":"choice","question":"你儿子今年 ___ 了？——他今年五岁。","options":["几岁","多大","多少","什么"],"answer":"几岁","pinyin":"Nǐ érzi jīnnián ___ le?","meaning":"Con trai bạn năm nay mấy tuổi rồi?","explanation":"Trẻ nhỏ (5 tuổi) dùng '几岁'."}]$$::jsonb,
  1
),
(
  1,
  5,
  'Bài 5: 她女儿今年二十岁 (Con gái cô ấy năm nay 20 tuổi)',
  '2. Trợ từ ngữ khí 了 (le) biểu thị sự thay đổi hoặc tình hình mới',
  'Số tuổi + 岁 + 了',
  'Khi đặt <b>了</b> ở cuối câu chỉ tuổi tác hoặc thời gian, nó biểu thị sự biến đổi, bước sang giai đoạn mới hoặc phát sinh sự việc mới (''rồi'').',
  $$[{"hanzi":"她女儿今年二十岁了。","pinyin":"Tā nǚ'ér jīnnián èrshí suì le.","meaning":"Con gái cô ấy năm nay đã 20 tuổi rồi."}]$$::jsonb,
  $$[{"type":"order","words":["她","今年","二十","岁","了"],"answer":"她今年二十岁了","pinyin":"Tā jīnnián èrshí suì le.","meaning":"Cô ấy năm nay 20 tuổi rồi.","explanation":"Trật tự câu chỉ tuổi tác: Chủ ngữ + Thời gian + Số tuổi + 岁 + 了."}]$$::jsonb,
  2
),
(
  1,
  6,
  'Bài 6: 我会说汉语 (Tôi biết nói tiếng Hán)',
  '1. Động từ năng nguyện 会 (huì - biết qua học tập)',
  'Chủ ngữ + 会 + Động từ | Phủ định: 主语 + 不会 + Động từ',
  '<b>会</b> (huì) đặt trước động từ để diễn tả một kỹ năng có được nhờ quá trình học hỏi, rèn luyện (biết nói tiếng Trung, biết bơi, biết lái xe...). Dạng phủ định là <b>不会</b> (bú huì).',
  $$[{"hanzi":"你会说汉语吗？——我会说汉语。","pinyin":"Nǐ huì shuō hànyǔ ma? —— Wǒ huì shuō hànyǔ.","meaning":"Bạn biết nói tiếng Trung không? —— Tôi biết nói tiếng Trung."},{"hanzi":"我妈妈不会做中国菜。","pinyin":"Wǒ māma bú huì zuò zhōngguó cài.","meaning":"Mẹ tôi không biết nấu món ăn Trung Quốc."}]$$::jsonb,
  $$[{"type":"choice","question":"我 ___ 写汉字，但是不会说。","options":["会","是","想","有"],"answer":"会","pinyin":"Wǒ ___ xiě hànzì.","meaning":"Tôi biết viết chữ Hán.","explanation":"Kỹ năng qua học tập dùng '会'."}]$$::jsonb,
  1
),
(
  1,
  6,
  'Bài 6: 我会说汉语 (Tôi biết nói tiếng Hán)',
  '2. Đại từ nghi vấn 怎么 (zěnme) hỏi phương thức thực hiện',
  '怎么 + Động từ？ (Làm thế nào? / Như thế nào?)',
  'Đặt <b>怎么</b> trước động từ để hỏi cách thức, phương pháp tiến hành một hành động.',
  $$[{"hanzi":"这个汉字怎么读？","pinyin":"Zhège hànzì zěnme dú?","meaning":"Chữ Hán này đọc như thế nào?"},{"hanzi":"中国菜怎么做？","pinyin":"Zhōngguó cài zěnme zuò?","meaning":"Món ăn Trung Quốc nấu như thế nào?"}]$$::jsonb,
  $$[{"type":"order","words":["这个","字","怎么","写","？"],"answer":"这个字怎么写？","pinyin":"Zhège zì zěnme xiě?","meaning":"Chữ này viết thế nào?","explanation":"Trật tự hỏi cách làm: Chủ ngữ (这个字) + 怎么 + Động từ (写) + ？"}]$$::jsonb,
  2
),
(
  1,
  7,
  'Bài 7: 今天几号 (Hôm nay ngày mấy?)',
  '1. Biểu đạt thời gian: Năm -> Tháng -> Ngày (号/日) -> Thứ (星期)',
  '...年 ...月 ...号 (日) 星期...',
  'Trong tiếng Trung, quy tắc diễn đạt thời gian đi từ <b>lớn đến nhỏ</b>: Năm -> Tháng -> Ngày -> Thứ.<br>Trong khẩu ngữ hàng ngày dùng <b>号</b> (hào), văn viết dùng <b>日</b> (rì).<br>Các thứ trong tuần: 星期一 (Thứ 2) đến 星期六 (Thứ 7), Chủ Nhật là 星期天 hoặc 星期日.',
  $$[{"hanzi":"今天几号？——今天九月一号。","pinyin":"Jīntiān jǐ hào? —— Jīntiān jiǔ yuè yī hào.","meaning":"Hôm nay ngày mấy? —— Hôm nay là ngày 1 tháng 9."},{"hanzi":"明天是星期几？——明天是星期三。","pinyin":"Míngtiān shì xīngqījǐ? —— Míngtiān shì xīngqīsān.","meaning":"Ngày mai là thứ mấy? —— Ngày mai là thứ Tư."}]$$::jsonb,
  $$[{"type":"choice","question":"今天九月 ___ 号？","options":["几","多少","什么","哪"],"answer":"几","pinyin":"Jīntiān jiǔ yuè ___ hào?","meaning":"Hôm nay ngày mấy tháng 9?","explanation":"Hỏi ngày trong tháng (<31) dùng '几号'."},{"type":"order","words":["今天","是","九月","一号","星期三"],"answer":"今天是九月一号星期三","pinyin":"Jīntiān shì jiǔ yuè yī hào xīngqīsān.","meaning":"Hôm nay là thứ Tư ngày 1 tháng 9.","explanation":"Quy tắc từ lớn đến nhỏ: Tháng (九月) -> Ngày (一号) -> Thứ (星期三)."}]$$::jsonb,
  1
),
(
  1,
  8,
  'Bài 8: 我想喝茶 (Tôi muốn uống trà)',
  '1. Động từ năng nguyện 想 (xiǎng - muốn / dự định)',
  'Chủ ngữ + 想 + Động từ | Phủ định: Chủ ngữ + 不想 + Động từ',
  '<b>想</b> (xiǎng) đặt trước động từ biểu thị mong muốn, nguyện vọng hoặc dự định làm một việc gì đó.',
  $$[{"hanzi":"我想喝茶。","pinyin":"Wǒ xiǎng hē chá.","meaning":"Tôi muốn uống trà."},{"hanzi":"下午你想去哪儿？——我想去商店。","pinyin":"Xiàwǔ nǐ xiǎng qù nǎr? —— Wǒ xiǎng qù shāngdiàn.","meaning":"Buổi chiều bạn muốn đi đâu? —— Tôi muốn đi cửa hàng."}]$$::jsonb,
  $$[{"type":"choice","question":"下午我 ___ 去买东西。","options":["想","是","在","很"],"answer":"想","pinyin":"Xiàwǔ wǒ ___ qù mǎi dōngxi.","meaning":"Buổi chiều tôi muốn đi mua đồ.","explanation":"Biểu thị mong muốn làm việc gì dùng '想'."}]$$::jsonb,
  1
),
(
  1,
  8,
  'Bài 8: 我想喝茶 (Tôi muốn uống trà)',
  '2. Hỏi số lượng và giá cả: 多少钱 (duōshao qián) & Lượng từ 个, 块',
  'Sự vật + 多少钱？ | Số từ + Lượng từ (块/个) + Danh từ',
  '• Khi hỏi số lượng trên 10 hoặc giá tiền, dùng <b>多少</b> (duōshao). Cụm từ <b>多少钱</b> nghĩa là ''bao nhiêu tiền?''.<br>• <b>块</b> (kuài) là đơn vị tiền tệ phổ thông trong khẩu ngữ (tương đương tệ / đồng).',
  $$[{"hanzi":"这个杯子多少钱？——十八块。","pinyin":"Zhège bēizi duōshao qián? —— Shíbā kuài.","meaning":"Cái cốc này bao nhiêu tiền? —— 18 tệ."}]$$::jsonb,
  $$[{"type":"order","words":["这个","杯子","多少","钱","？"],"answer":"这个杯子多少钱？","pinyin":"Zhège bēizi duōshao qián?","meaning":"Cái cốc này bao nhiêu tiền?","explanation":"Trật tự hỏi giá: Đồ vật (这个杯子) + 多少钱 + ？"}]$$::jsonb,
  2
),
(
  1,
  9,
  'Bài 9: 你儿子在哪儿工作 (Con trai bạn làm việc ở đâu?)',
  '1. Giới từ 在 (zài) biểu thị nơi chốn diễn ra hành động',
  'Chủ ngữ + 在 + Địa điểm + Động từ',
  'Trong ngữ pháp tiếng Trung, nơi chốn luôn đứng <b>TRƯỚC</b> hành động: <b>Ở ĐÂU LÀM GÌ</b> (khác với tiếng Việt thường nói ''Làm gì ở đâu'').',
  $$[{"hanzi":"我儿子在医院工作，他是医生。","pinyin":"Wǒ érzi zài yīyuàn gōngzuò, tā shì yīshēng.","meaning":"Con trai tôi làm việc ở bệnh viện, nó là bác sĩ."},{"hanzi":"你朋友在哪儿喝茶？","pinyin":"Nǐ péngyou zài nǎr hē chá?","meaning":"Bạn của bạn uống trà ở đâu?"}]$$::jsonb,
  $$[{"type":"choice","question":"我妈妈 ___ 学校工作。","options":["在","是","去","有"],"answer":"在","pinyin":"Wǒ māma ___ xuéxiào gōngzuò.","meaning":"Mẹ tôi làm việc ở trường học.","explanation":"Chỉ địa điểm diễn ra hành động dùng giới từ '在'."},{"type":"order","words":["我","在","中国","学","汉语"],"answer":"我在中国学汉语","pinyin":"Wǒ zài Zhōngguó xué hànyǔ.","meaning":"Tôi học tiếng Trung ở Trung Quốc.","explanation":"Trật tự vàng tiếng Trung: Ở đâu làm gì (在 + Địa điểm + Động từ + Tân ngữ)."}]$$::jsonb,
  1
),
(
  1,
  10,
  'Bài 10: 我能坐这儿吗 (Tôi có thể ngồi đây không?)',
  '1. Động từ năng nguyện 能 (néng - có thể / xin phép)',
  'Chủ ngữ + 能 + Động từ？ (Có thể ... không?)',
  '<b>能</b> (néng) dùng để diễn tả năng lực khách quan hoặc dùng trong câu hỏi để xin phép một cách lịch sự.',
  $$[{"hanzi":"这儿有人吗？——没有。——我能坐这儿吗？——请坐。","pinyin":"Zhèr yǒu rén ma? —— Méiyǒu. —— Wǒ néng zuò zhèr ma? —— Qǐng zuò.","meaning":"Ở đây có ai không? —— Không có. —— Tôi có thể ngồi đây không? —— Mời ngồi."},{"hanzi":"明天你能来我家吗？","pinyin":"Míngtiān nǐ néng lái wǒ jiā ma?","meaning":"Ngày mai bạn có thể đến nhà tôi không?"}]$$::jsonb,
  $$[{"type":"choice","question":"我 ___ 坐这儿吗？——请坐。","options":["能","会","是","在"],"answer":"能","pinyin":"Wǒ ___ zuò zhèr ma?","meaning":"Tôi có thể ngồi ở đây không?","explanation":"Xin phép làm việc gì một cách lịch sự dùng '能'."},{"type":"order","words":["我","能","坐","这儿","吗","？"],"answer":"我能坐这儿吗？","pinyin":"Wǒ néng zuò zhèr ma?","meaning":"Tôi có thể ngồi đây không?","explanation":"Trật tự xin phép: Chủ ngữ (我) + 能 + Động từ (坐) + Địa điểm (这儿) + 吗？"}]$$::jsonb,
  1
),
(
  1,
  11,
  'Bài 11: 现在几点 (Bây giờ là mấy giờ?)',
  '1. Cách nói giờ giấc: 点 (diǎn - giờ) và 分 (fēn - phút)',
  '...点 ...分 | 现在几点？',
  'Trong tiếng Trung:<br>• <b>点</b> (diǎn) = giờ.<br>• <b>分</b> (fēn) = phút.<br>• <b>半</b> (bàn) = rưỡi (30 phút).<br>Khi hỏi giờ, ta dùng: <b>现在几点？</b> (Hiện tại mấy giờ?).',
  $$[{"hanzi":"现在几点？——现在十点十分。","pinyin":"Xiànzài jǐ diǎn? —— Xiànzài shí diǎn shí fēn.","meaning":"Bây giờ mấy giờ? —— Bây giờ là 10 giờ 10 phút."},{"hanzi":"我们中午十二点半吃饭。","pinyin":"Wǒmen zhōngwǔ shí'èr diǎn bàn chī fàn.","meaning":"Chúng tôi ăn cơm lúc 12 giờ rưỡi trưa."}]$$::jsonb,
  $$[{"type":"choice","question":"现在 ___ 点？——现在八点。","options":["几","多少","什么","哪"],"answer":"几","pinyin":"Xiànzài ___ diǎn?","meaning":"Bây giờ mấy giờ?","explanation":"Hỏi giờ (<12 hoặc <24) dùng '几点'."}]$$::jsonb,
  1
),
(
  1,
  11,
  'Bài 11: 现在几点 (Bây giờ là mấy giờ?)',
  '2. Thời gian làm trạng ngữ trong câu',
  'Chủ ngữ + Thời gian + Động từ | Thời gian + Chủ ngữ + Động từ',
  'Từ chỉ thời gian trong câu tiếng Trung phải đứng <b>TRƯỚC</b> động từ, có thể đứng trước hoặc ngay sau chủ ngữ, nhưng tuyệt đối không đứng cuối câu như tiếng Việt.',
  $$[{"hanzi":"爸爸六点回家。","pinyin":"Bàba liù diǎn huí jiā.","meaning":"Bố về nhà lúc 6 giờ."},{"hanzi":"明天下午我想去图书馆。","pinyin":"Míngtiān xiàwǔ wǒ xiǎng qù túshūguǎn.","meaning":"Chiều mai tôi muốn đi thư viện."}]$$::jsonb,
  $$[{"type":"order","words":["我","明天","早上","七点","起床"],"answer":"我明天早上七点起床","pinyin":"Wǒ míngtiān zǎoshang qī diǎn qǐchuáng.","meaning":"Sáng mai 7 giờ tôi thức dậy.","explanation":"Thời gian đứng trước động từ: Chủ ngữ + Thời gian + Động từ."}]$$::jsonb,
  2
),
(
  1,
  12,
  'Bài 12: 明天天气怎么样 (Thời tiết ngày mai thế nào?)',
  '1. Đại từ nghi vấn 怎么样 (zěnmeyàng - như thế nào / ra sao)',
  'Chủ ngữ + 怎么样？',
  '<b>怎么样</b> dùng để hỏi về tính chất, tình hình, thời tiết, sức khỏe hoặc hỏi ý kiến đề xuất.',
  $$[{"hanzi":"明天天气怎么样？——明天天气很好，不冷不热。","pinyin":"Míngtiān tiānqì zěnmeyàng? —— Míngtiān tiānqì hěn hǎo, bù lěng bú rè.","meaning":"Thời tiết ngày mai thế nào? —— Ngày mai thời tiết rất đẹp, không lạnh không nóng."},{"hanzi":"你身体怎么样？——我很好。","pinyin":"Nǐ shēntǐ zěnmeyàng? —— Wǒ hěn hǎo.","meaning":"Sức khỏe bạn thế nào? —— Tôi rất khỏe."}]$$::jsonb,
  $$[{"type":"choice","question":"今天天气 ___ ？","options":["怎么样","什么","怎么","谁"],"answer":"怎么样","pinyin":"Jīntiān tiānqì ___ ?","meaning":"Hôm nay thời tiết thế nào?","explanation":"Hỏi tình hình thời tiết thế nào dùng '怎么样'."}]$$::jsonb,
  1
),
(
  1,
  12,
  'Bài 12: 明天天气怎么样 (Thời tiết ngày mai thế nào?)',
  '2. Cấu trúc cảm thán 太...了 (tài... le - quá / lắm)',
  '太 + Tính từ + 了',
  'Dùng để biểu thị mức độ rất cao, mang ý tán thưởng khen ngợi hoặc phàn nàn quá mức.',
  $$[{"hanzi":"今天太热了！","pinyin":"Jīntiān tài rè le!","meaning":"Hôm nay nóng quá rồi!"},{"hanzi":"太好了！","pinyin":"Tài hǎo le!","meaning":"Tốt quá rồi!"}]$$::jsonb,
  $$[{"type":"order","words":["今天","太","冷","了"],"answer":"今天太冷了","pinyin":"Jīntiān tài lěng le.","meaning":"Hôm nay lạnh quá rồi.","explanation":"Cấu trúc cảm thán: Chủ ngữ (今天) + 太 + Tính từ (冷) + 了."}]$$::jsonb,
  2
),
(
  1,
  13,
  'Bài 13: 他在学做中国菜呢 (Anh ấy đang học nấu món Trung Quốc)',
  '1. Biểu thị hành động đang tiếp diễn: 在 / 正在 ... 呢',
  'Chủ ngữ + 在 / 正在 + Động từ (+ Tân ngữ) (+ 呢)',
  'Để diễn tả một hành động <b>ĐANG</b> diễn ra tại thời điểm nói, ta dùng phó từ <b>在</b> hoặc <b>正在</b> trước động từ, cuối câu có thể thêm trợ từ <b>呢</b>.<br>Phủ định của hành động tiếp diễn dùng <b>没在</b> (méi zài).',
  $$[{"hanzi":"你在做什么呢？——我在看书呢。","pinyin":"Nǐ zài zuò shénme ne? —— Wǒ zài kàn shū ne.","meaning":"Bạn đang làm gì đấy? —— Tôi đang đọc sách này."},{"hanzi":"他没在看电视，他在学习呢。","pinyin":"Tā méi zài kàn diànshì, tā zài xuéxí ne.","meaning":"Anh ấy không đang xem TV, anh ấy đang học bài."}]$$::jsonb,
  $$[{"type":"choice","question":"喂，你 ___ 做什么呢？","options":["在","是","会","了"],"answer":"在","pinyin":"Wèi, nǐ ___ zuò shénme ne?","meaning":"Alo, bạn đang làm gì đấy?","explanation":"Diễn tả hành động đang tiếp diễn kết hợp với '呢' dùng phó từ '在'."},{"type":"order","words":["他","在","学","做","中国菜","呢"],"answer":"他在学做中国菜呢","pinyin":"Tā zài xué zuò Zhōngguó cài ne.","meaning":"Anh ấy đang học nấu món ăn Trung Quốc đấy.","explanation":"Trật tự tiếp diễn: Chủ ngữ (他) + 在 + Động từ (学做中国菜) + 呢."}]$$::jsonb,
  1
),
(
  1,
  14,
  'Bài 14: 她买了不少衣服 (Cô ấy đã mua không ít quần áo)',
  '1. Trợ từ động thái 了 (le) biểu thị hành động đã hoàn thành',
  'Chủ ngữ + Động từ + 了 + Số lượng / Định ngữ + Tân ngữ',
  'Khi <b>了</b> đứng ngay sau động từ, nó là <b>trợ từ động thái</b>, biểu thị hành động đã thực hiện hoặc đã hoàn thành. Thường tân ngữ phía sau có định ngữ số lượng đi kèm.',
  $$[{"hanzi":"她买了不少衣服。","pinyin":"Tā mǎi le bù shǎo yīfu.","meaning":"Cô ấy đã mua không ít quần áo."},{"hanzi":"我买了一本书。","pinyin":"Wǒ mǎi le yì běn shū.","meaning":"Tôi đã mua một cuốn sách."}]$$::jsonb,
  $$[{"type":"choice","question":"昨天我买 ___ 一个杯子。","options":["了","过","着","在"],"answer":"了","pinyin":"Zuótiān wǒ mǎi ___ yí gè bēizi.","meaning":"Hôm qua tôi đã mua một cái cốc.","explanation":"Hành động đã hoàn thành trong quá khứ dùng trợ từ động thái '了'."},{"type":"order","words":["她","买","了","不少","衣服"],"answer":"她买了不少衣服","pinyin":"Tā mǎi le bù shǎo yīfu.","meaning":"Cô ấy đã mua không ít quần áo.","explanation":"Trật tự: Chủ ngữ (她) + Động từ + 了 (买了) + Định ngữ (不少) + Tân ngữ (衣服)."}]$$::jsonb,
  1
),
(
  1,
  15,
  'Bài 15: 我是坐飞机来的 (Tôi đến đây bằng máy bay)',
  '1. Cấu trúc nhấn mạnh: 是...的 (shì... de)',
  'Chủ ngữ + 是 + [Thời gian / Địa điểm / Phương thức] + Động từ + 的',
  'Khi một sự việc đã biết là <b>đã xảy ra trong quá khứ</b>, người ta dùng cấu trúc <b>是...的</b> để nhấn mạnh vào một chi tiết cụ thể:<br>• Thời gian: 你是<b>什么时候</b>来的？ (Bạn đến khi nào?)<br>• Địa điểm: 你是<b>在哪儿</b>买的？ (Bạn mua ở đâu?)<br>• Phương thức: 我是<b>坐飞机</b>来的。 (Tôi đến bằng máy bay).<br>Trong câu khẳng định, có thể lược bỏ 是, nhưng không được bỏ 的. Phủ định bắt buộc dùng <b>不是...的</b>.',
  $$[{"hanzi":"我是坐飞机来的。","pinyin":"Wǒ shì zuò fēijī lái de.","meaning":"Tôi đến đây bằng máy bay."},{"hanzi":"我们是二〇一一年认识的。","pinyin":"Wǒmen shì èr líng yīyī nián rènshi de.","meaning":"Chúng tôi quen nhau vào năm 2011."},{"hanzi":"这本书不是在商店买的。","pinyin":"Zhè běn shū bú shì zài shāngdiàn mǎi de.","meaning":"Cuốn sách này không phải mua ở cửa hàng."}]$$::jsonb,
  $$[{"type":"choice","question":"你们是几点到北京 ___ ？","options":["的","了","吗","呢"],"answer":"的","pinyin":"Nǐmen shì jǐ diǎn dào Běijīng ___ ?","meaning":"Các bạn đến Bắc Kinh lúc mấy giờ vậy?","explanation":"Cấu trúc nhấn mạnh thời gian đã xảy ra: 是...的."},{"type":"order","words":["我","是","坐飞机","来","的"],"answer":"我是坐飞机来的","pinyin":"Wǒ shì zuò fēijī lái de.","meaning":"Tôi đến bằng máy bay.","explanation":"Trật tự cấu trúc nhấn mạnh phương thức: Chủ ngữ + 是 + Phương thức (坐飞机) + Động từ (来) + 的."}]$$::jsonb,
  1
),
(
  2,
  1,
  'Bài 1: 九月去北京旅游最好 (Tháng 9 đi du lịch Bắc Kinh là tuyệt nhất)',
  '1. Phó từ chỉ mức độ cao nhất: 最 (zuì - nhất)',
  '最 + Tính từ / Động từ tâm lý (+ Danh từ)',
  '<b>最</b> (zuì) đứng trước tính từ hoặc động từ chỉ cảm xúc/tâm lý (như 喜欢, 想, 爱) để biểu thị mức độ cao nhất (nhất).',
  $$[{"hanzi":"九月去北京旅游最好。","pinyin":"Jiǔ yuè qù Běijīng lǚyóu zuì hǎo.","meaning":"Tháng 9 đi du lịch Bắc Kinh là tuyệt nhất."},{"hanzi":"我最喜欢吃中国菜。","pinyin":"Wǒ zuì xǐhuan chī Zhōngguó cài.","meaning":"Tôi thích ăn món Trung Quốc nhất."}]$$::jsonb,
  $$[{"type":"choice","question":"水果里我 ___ 喜欢苹果。","options":["最","太","很","真"],"answer":"最","pinyin":"Shuǐguǒ lǐ wǒ ___ xǐhuan píngguǒ.","meaning":"Trong các loại hoa quả tôi thích táo nhất.","explanation":"Thích nhất dùng '最喜欢'."},{"type":"order","words":["九月","去","北京","旅游","最好"],"answer":"九月去北京旅游最好","pinyin":"Jiǔ yuè qù Běijīng lǚyóu zuì hǎo.","meaning":"Tháng 9 đi du lịch Bắc Kinh là tuyệt nhất.","explanation":"Trật tự câu: Thời gian (九月) + Đi đâu làm gì (去北京旅游) + Vị ngữ (最好)."}]$$::jsonb,
  1
),
(
  2,
  2,
  'Bài 2: 我每天六点起床 (Mỗi ngày tôi đều thức dậy lúc 6 giờ)',
  '1. Từ chỉ tần suất và thói quen: 每天 (měitiān - mỗi ngày) & 每...都...',
  '每 + Lượng từ + Danh từ + 都 + Động từ',
  '<b>每</b> (měi) biểu thị ''mỗi / từng''. Phía sau ''每'' là lượng từ + danh từ (ví dụ: 每个人, 每天, 每年), vế sau thường có phó từ <b>都</b> đi kèm để biểu thị tính phổ quát toàn bộ.',
  $$[{"hanzi":"我每天六点起床。","pinyin":"Wǒ měitiān liù diǎn qǐchuáng.","meaning":"Mỗi ngày tôi đều thức dậy lúc 6 giờ."},{"hanzi":"他每天都去跑步。","pinyin":"Tā měitiān dōu qù pǎobù.","meaning":"Anh ấy ngày nào cũng đi chạy bộ."}]$$::jsonb,
  $$[{"type":"choice","question":"我们班 ___ 个学生都学得很努力。","options":["每","各","多","几"],"answer":"每","pinyin":"Wǒmen bān ___ gè xuésheng dōu xué de hěn nǔlì.","meaning":"Lớp chúng tôi mỗi học sinh đều học rất chăm chỉ.","explanation":"Cấu trúc '每...都...' biểu thị mọi thành viên đều như vậy."}]$$::jsonb,
  1
),
(
  2,
  3,
  'Bài 3: 左边那个红色的是我的 (Cái màu đỏ ở bên trái là của tôi)',
  '1. Phương vị từ và kết cấu chữ 的 biểu thị đồ vật',
  'Phương vị từ: 左边 (trái) / 右边 (phải) | Tính từ / Danh từ + 的 = Cụm danh từ',
  'Khi phía sau tính từ, động từ hoặc đại từ thêm <b>的</b>, cụm từ này biến thành <b>kết cấu chữ 的</b> thay thế cho danh từ đã được nhắc tới trước đó để tránh lặp từ (ví dụ: 红色的 = cái màu đỏ, 我的 = của tôi).',
  $$[{"hanzi":"左边那个红色的是我的。","pinyin":"Zuǒbian nàge hóngsè de shì wǒ de.","meaning":"Cái màu đỏ ở bên trái là của tôi."},{"hanzi":"这本书是新买的，那本是旧的。","pinyin":"Zhè běn shū shì xīn mǎi de, nà běn shì jiù de.","meaning":"Quyển sách này là mới mua, quyển kia là cũ."}]$$::jsonb,
  $$[{"type":"order","words":["左边","那个","红色的","是","我的"],"answer":"左边那个红色的是我的","pinyin":"Zuǒbian nàge hóngsè de shì wǒ de.","meaning":"Cái màu đỏ ở bên trái là của tôi.","explanation":"Trật tự: Vị trí (左边) + Đối tượng (那个红色的) + 是 + Sở hữu (我的)."}]$$::jsonb,
  1
),
(
  2,
  4,
  'Bài 4: 这个工作是他帮我介绍的 (Công việc này là do anh ấy giới thiệu cho tôi)',
  '1. Giới từ 帮 (bāng) và 给 (gěi) biểu thị làm giúp / cho ai',
  'Chủ ngữ + 帮 / 给 + Người nhận + Động từ',
  '• <b>帮</b> (bāng) nghĩa là giúp đỡ ai làm việc gì.<br>• Kết hợp với cấu trúc nhấn mạnh <b>是...的</b> để làm nổi bật người thực hiện hành động giúp đỡ.',
  $$[{"hanzi":"这个工作是他帮我介绍的。","pinyin":"Zhège gōngzuò shì tā bāng wǒ jièshào de.","meaning":"Công việc này là do anh ấy giới thiệu cho tôi."},{"hanzi":"你可以帮我开一下门吗？","pinyin":"Nǐ kěyǐ bāng wǒ kāi yíxià mén ma?","meaning":"Bạn có thể giúp tôi mở cửa một chút không?"}]$$::jsonb,
  $$[{"type":"choice","question":"这个电脑是他 ___ 我买的。","options":["帮","在","对","向"],"answer":"帮","pinyin":"Zhège diànnǎo shì tā ___ wǒ mǎi de.","meaning":"Chiếc máy tính này là anh ấy mua giúp tôi.","explanation":"Làm hộ / mua giúp ai việc gì dùng '帮'."}]$$::jsonb,
  1
),
(
  2,
  5,
  'Bài 5: 就买这件吧 (Mua chiếc này đi)',
  '1. Lượng từ 件 (jiàn - áo, sự việc) & Phó từ 就 biểu thị quyết định nhanh',
  'Phó từ 就 + Động từ ... 吧 (Thôi thì cứ ... đi)',
  '• <b>件</b> (jiàn) là lượng từ dùng cho áo, quần áo, sự việc (一件衣服, 这件事).<br>• Phó từ <b>就</b> kết hợp trợ từ <b>吧</b> ở cuối câu biểu thị sự quyết định dứt khoát sau khi cân nhắc hoặc đưa ra gợi ý, thương lượng nhẹ nhàng.',
  $$[{"hanzi":"这件衣服很漂亮，就买这件吧！","pinyin":"Zhè jiàn yīfu hěn piàoliang, jiù mǎi zhè jiàn ba!","meaning":"Bộ quần áo này rất đẹp, thôi cứ mua bộ này đi!"}]$$::jsonb,
  $$[{"type":"order","words":["就","买","这件","吧"],"answer":"就买这件吧","pinyin":"Jiù mǎi zhè jiàn ba.","meaning":"Mua chiếc này đi.","explanation":"Trật tự đưa ra quyết định: 就 + Động từ (买) + Đối tượng (这件) + Trợ từ ngữ khí (吧)."}]$$::jsonb,
  1
),
(
  2,
  6,
  'Bài 6: 你怎么不吃了 (Sao bạn không ăn nữa?)',
  '1. Đại từ 怎么 hỏi nguyên nhân bất ngờ (Sao / Vì sao)',
  '怎么 + Phủ định (不 / 没) + Động từ？',
  'Khi <b>怎么</b> kết hợp với từ phủ định (不 hoặc 没), nó mang nghĩa hỏi nguyên nhân kèm sắc thái ngạc nhiên, thắc mắc (''Sao lại không...?'', ''Vì sao lại chưa...?'').',
  $$[{"hanzi":"你怎么不吃了？——我胃有点儿不舒服。","pinyin":"Nǐ zěnme bù chī le? —— Wǒ wèi yǒudiǎnr bù shūfu.","meaning":"Sao bạn không ăn nữa? —— Dạ dày tôi hơi khó chịu."},{"hanzi":"你今天怎么没去上班？","pinyin":"Nǐ jīntiān zěnme méi qù shàngbān?","meaning":"Sao hôm nay bạn không đi làm?"}]$$::jsonb,
  $$[{"type":"choice","question":"你今天 ___ 不高兴？","options":["怎么","什么","哪儿","几"],"answer":"怎么","pinyin":"Nǐ jīntiān ___ bù gāoxìng?","meaning":"Sao hôm nay bạn không vui thế?","explanation":"Hỏi nguyên nhân bất ngờ dùng '怎么不'."}]$$::jsonb,
  1
),
(
  2,
  7,
  'Bài 7: 你家离公司远吗 (Nhà bạn cách công ty có xa không?)',
  '1. Giới từ 离 (lí - cách) biểu thị khoảng cách không gian / thời gian',
  'Địa điểm A + 离 + Địa điểm B + (很) 远 / 近',
  'Giới từ <b>离</b> dùng để nói về cự ly khoảng cách giữa hai địa điểm hoặc hai mốc thời gian.<br>• 远 (yuǎn) = xa.<br>• 近 (jìn) = gần.<br>Khi hỏi khoảng cách: <b>A 离 B 远吗？</b> hoặc <b>A 离 B 有多远？</b>',
  $$[{"hanzi":"你家离公司远吗？——我家离公司不远，很近。","pinyin":"Nǐ jiā lí gōngsī yuǎn ma? —— Wǒ jiā lí gōngsī bù yuǎn, hěn jìn.","meaning":"Nhà bạn cách công ty xa không? —— Nhà tôi cách công ty không xa, rất gần."},{"hanzi":"学校离机场有二十公里。","pinyin":"Xuéxiào lí jīchǎng yǒu èrshí gōnglǐ.","meaning":"Trường học cách sân bay 20 km."}]$$::jsonb,
  $$[{"type":"choice","question":"医院 ___ 宾馆很近，走五分钟就到了。","options":["离","从","向","往"],"answer":"离","pinyin":"Yīyuàn ___ bīnguǎn hěn jìn.","meaning":"Bệnh viện cách khách sạn rất gần.","explanation":"Chỉ cự ly khoảng cách giữa 2 điểm dùng giới từ '离'."},{"type":"order","words":["你家","离","公司","远","吗","？"],"answer":"你家离公司远吗？","pinyin":"Nǐ jiā lí gōngsī yuǎn ma?","meaning":"Nhà bạn cách công ty có xa không?","explanation":"Cấu trúc khoảng cách: A (你家) + 离 + B (公司) + 远 + 吗？"}]$$::jsonb,
  1
),
(
  2,
  8,
  'Bài 8: 让我想想再告诉你 (Để tôi nghĩ đã rồi nói với bạn)',
  '1. Động từ kiêm ngữ: 让 (ràng - bảo / để / cho phép)',
  'Chủ ngữ 1 + 让 / 叫 / 请 + Người khác + Làm gì đó',
  '<b>让</b> (ràng) dùng trong câu cầu khiến, sai khiến hoặc đề nghị (''để tôi...'', ''bảo ai làm gì'', ''cho phép ai làm gì'').',
  $$[{"hanzi":"让我想想再告诉你。","pinyin":"Ràng wǒ xiǎngxiang zài gàosù nǐ.","meaning":"Để tôi nghĩ một lát đã rồi nói cho bạn biết."},{"hanzi":"老师让我读生词。","pinyin":"Lǎoshī ràng wǒ dú shēngcí.","meaning":"Thầy giáo bảo tôi đọc từ mới."}]$$::jsonb,
  $$[{"type":"choice","question":"请 ___ 我看一看你的新手机。","options":["让","向","被","从"],"answer":"让","pinyin":"Qǐng ___ wǒ kànyíkan nǐ de xīn shǒujī.","meaning":"Xin hãy để tôi xem điện thoại mới của bạn một chút.","explanation":"Đề nghị cho phép mình làm gì dùng '让'."},{"type":"order","words":["让","我","想想","再","告诉","你"],"answer":"让我想想再告诉你","pinyin":"Ràng wǒ xiǎngxiang zài gàosù nǐ.","meaning":"Để tôi nghĩ đã rồi nói với bạn.","explanation":"Trật tự câu: 让 + 我 + 想想 + 再 + 告诉 + 你."}]$$::jsonb,
  1
),
(
  2,
  9,
  'Bài 9: 题太多，我没做完 (Nhiều câu hỏi quá, tôi chưa làm xong)',
  '1. Bổ ngữ kết quả: 完 (xong), 错 (sai), 好 (xong xuôi)',
  'Động từ + 完 / 错 / 好 | Phủ định: 没 + Động từ + 完',
  'Bổ ngữ kết quả đặt ngay sau động từ để biểu thị kết quả mà hành động đó đạt được.<br>• <b>做完</b>: làm xong.<br>• <b>写错</b>: viết sai.<br>• <b>吃好</b>: ăn xong xuôi.<br>Phủ định bắt buộc dùng <b>没</b> hoặc <b>没有</b> trước động từ (không được dùng 不).',
  $$[{"hanzi":"考试题太多，我没做完。","pinyin":"Kǎoshì tí tài duō, wǒ méi zuò wán.","meaning":"Đề thi nhiều câu hỏi quá, tôi chưa làm xong."},{"hanzi":"这个字你写错了。","pinyin":"Zhège zì nǐ xiě cuò le.","meaning":"Chữ này bạn viết sai rồi."}]$$::jsonb,
  $$[{"type":"choice","question":"作业我还没做 ___ 呢。","options":["完","了","在","着"],"answer":"完","pinyin":"Zuòyè wǒ hái méi zuò ___ ne.","meaning":"Bài tập tôi vẫn chưa làm xong.","explanation":"Bổ ngữ chỉ hoàn tất công việc là '完'."},{"type":"order","words":["题","太","多","，","我","没","做完"],"answer":"题太多，我没做完","pinyin":"Tí tài duō, wǒ méi zuò wán.","meaning":"Nhiều câu hỏi quá, tôi chưa làm xong.","explanation":"Trật tự câu: Vế 1 (题太多) + Vế 2 (我没做完)."}]$$::jsonb,
  1
),
(
  2,
  10,
  'Bài 10: 别找了，手机在桌子上呢 (Đừng tìm nữa, điện thoại ở trên bàn kìa)',
  '1. Phó từ cấm đoán hoặc khuyên ngăn: 别...了 (bié... le - đừng ... nữa)',
  '别 + Động từ (+ Tân ngữ) (+ 了) = 不要 + Động từ (+ Tân ngữ) (+ 了)',
  'Dùng để ngăn cản hoặc khuyên ai dừng một hành động nào đó đang diễn ra hoặc sắp làm (''đừng... nữa'').',
  $$[{"hanzi":"别找了，手机在桌子上呢。","pinyin":"Bié zhǎo le, shǒujī zài zhuōzi shang ne.","meaning":"Đừng tìm nữa, điện thoại ở trên bàn kìa."},{"hanzi":"时间不早了，别看电视了，快睡觉吧。","pinyin":"Shíjiān bù zǎo le, bié kàn diànshì le, kuài shuìjiào ba.","meaning":"Muộn rồi, đừng xem TV nữa, ngủ mau đi."}]$$::jsonb,
  $$[{"type":"choice","question":"外面在下雨，你 ___ 出去了。","options":["别","没","不是","不"],"answer":"别","pinyin":"Wàimiàn zài xià yǔ, nǐ ___ chūqù le.","meaning":"Bên ngoài đang mưa, bạn đừng ra ngoài nữa.","explanation":"Khuyên can dừng hành động dùng '别...了'."}]$$::jsonb,
  1
),
(
  2,
  11,
  'Bài 11: 他比我大三岁 (Anh ấy lớn hơn tôi 3 tuổi)',
  '1. Câu so sánh chữ 比 kèm số lượng chênh lệch cụ thể',
  'A + 比 + B + Tính từ + Số lượng chênh lệch cụ thể',
  'Khi muốn nêu rõ mức độ chênh lệch cụ thể (như bao nhiêu tuổi, bao nhiêu cm, bao nhiêu cân), ta đặt số lượng đó ở ngay <b>SAU</b> tính từ so sánh.',
  $$[{"hanzi":"他比我大三岁。","pinyin":"Tā bǐ wǒ dà sān suì.","meaning":"Anh ấy lớn hơn tôi 3 tuổi."},{"hanzi":"哥哥比弟弟高五厘米。","pinyin":"Gēge bǐ dìdi gāo wǔ límǐ.","meaning":"Anh trai cao hơn em trai 5 cm."}]$$::jsonb,
  $$[{"type":"choice","question":"姐姐比妹妹大两 ___ 。","options":["岁","个","本","件"],"answer":"岁","pinyin":"Jiějie bǐ mèimei dà liǎng ___ .","meaning":"Chị gái lớn hơn em gái 2 tuổi.","explanation":"Chỉ độ tuổi dùng đơn vị '岁'."},{"type":"order","words":["他","比","我","大","三","岁"],"answer":"他比我大三岁","pinyin":"Tā bǐ wǒ dà sān suì.","meaning":"Anh ấy lớn hơn tôi 3 tuổi.","explanation":"Trật tự so sánh chênh lệch: A (他) + 比 + B (我) + Tính từ (大) + Số lượng (三岁)."}]$$::jsonb,
  1
),
(
  2,
  12,
  'Bài 12: 你穿得太少了 (Bạn mặc quá ít áo rồi)',
  '1. Bổ ngữ trạng thái với trợ từ kết cấu 得 (de)',
  'Động từ + 得 + (很 / 太 / 非常) + Tính từ',
  'Bổ ngữ trạng thái dùng để đánh giá, miêu tả về kết quả, mức độ hay trạng thái mà động tác tiến hành đạt được.<br>Nếu có tân ngữ, lặp lại động từ: <b>说汉语说得很好</b>.<br>Phủ định: <b>Động từ + 得 + 不 + Tính từ</b>.',
  $$[{"hanzi":"外面冷，你穿得太少了。","pinyin":"Wàimiàn lěng, nǐ chuān de tài shǎo le.","meaning":"Bên ngoài lạnh, bạn mặc ít áo quá rồi đấy."},{"hanzi":"他跑得很快，我跑得慢。","pinyin":"Tā pǎo de hěn kuài, wǒ pǎo de màn.","meaning":"Anh ấy chạy rất nhanh, tôi chạy chậm."}]$$::jsonb,
  $$[{"type":"choice","question":"他说汉语说 ___ 很好。","options":["得","的","地","了"],"answer":"得","pinyin":"Tā shuō hànyǔ shuō ___ hěn hǎo.","meaning":"Anh ấy nói tiếng Trung rất hay.","explanation":"Nối giữa động từ và bổ ngữ chỉ trạng thái / mức độ bắt buộc dùng '得'."},{"type":"order","words":["你","穿","得","太","少","了"],"answer":"你穿得太少了","pinyin":"Nǐ chuān de tài shǎo le.","meaning":"Bạn mặc quá ít áo rồi.","explanation":"Trật tự bổ ngữ trạng thái: Chủ ngữ (你) + Động từ (穿) + 得 + Bổ ngữ (太少了)."}]$$::jsonb,
  1
),
(
  2,
  13,
  'Bài 13: 门开着呢 (Cửa đang mở kìa)',
  '1. Trợ từ động thái 着 (zhe) biểu thị trạng thái đang được duy trì',
  'Chủ ngữ + Động từ + 着 (+ Tân ngữ) (+ 呢)',
  '<b>着</b> (zhe) đặt ngay sau động từ để biểu thị kết quả của hành động vẫn đang tiếp tục tồn tại hoặc duy trì (ví dụ: cửa đang mở, anh ấy đang cầm quyển sách, đang mặc áo sơ mi...).',
  $$[{"hanzi":"门开着呢，请进吧！","pinyin":"Mén kāi zhe ne, qǐng jìn ba!","meaning":"Cửa đang mở kìa, xin mời vào!"},{"hanzi":"他手里拿着一本书。","pinyin":"Tā shǒulǐ ná zhe yì běn shū.","meaning":"Trong tay anh ấy đang cầm một cuốn sách."}]$$::jsonb,
  $$[{"type":"choice","question":"外面的门开 ___ 呢。","options":["着","了","过","在"],"answer":"着","pinyin":"Wàimiàn de mén kāi ___ ne.","meaning":"Cửa ngoài kia đang mở đấy.","explanation":"Biểu thị trạng thái duy trì dùng trợ từ '着'."},{"type":"order","words":["门","开","着","呢"],"answer":"门开着呢","pinyin":"Mén kāi zhe ne.","meaning":"Cửa đang mở kìa.","explanation":"Trật tự câu duy trì trạng thái: Chủ ngữ (门) + Động từ (开) + 着 + 呢."}]$$::jsonb,
  1
),
(
  2,
  14,
  'Bài 14: 你看过那个电影吗 (Bạn đã từng xem bộ phim đó chưa?)',
  '1. Trợ từ động thái 过 (guo) biểu thị trải nghiệm trong quá khứ',
  'Chủ ngữ + Động từ + 过 (+ Tân ngữ) | Phủ định: 没 + Động từ + 过',
  '<b>过</b> (guo) đặt sau động từ để nhấn mạnh một hành động <b>ĐÃ TỪNG</b> xảy ra trong quá khứ và có trải nghiệm đó (''đã từng làm gì'').<br>Dạng phủ định: <b>没(有) + Động từ + 过</b> (chưa từng làm gì).',
  $$[{"hanzi":"你看过那个电影吗？——我没看过。","pinyin":"Nǐ kàn guo nàge diànyǐng ma? —— Wǒ méi kàn guo.","meaning":"Bạn đã từng xem bộ phim đó chưa? —— Tôi chưa từng xem."},{"hanzi":"我去过中国两次。","pinyin":"Wǒ qù guo Zhōngguó liǎng cì.","meaning":"Tôi đã từng đi Trung Quốc hai lần."}]$$::jsonb,
  $$[{"type":"choice","question":"中国菜很好吃，你吃 ___ 吗？","options":["过","了","着","在"],"answer":"过","pinyin":"Nǐ chī ___ ma?","meaning":"Bạn đã từng ăn qua chưa?","explanation":"Hỏi trải nghiệm đã từng làm trong quá khứ dùng '过'."},{"type":"order","words":["你","看","过","那个","电影","吗","？"],"answer":"你看过那个电影吗？","pinyin":"Nǐ kàn guo nàge diànyǐng ma?","meaning":"Bạn đã từng xem bộ phim đó chưa?","explanation":"Trật tự hỏi trải nghiệm: Chủ ngữ (你) + Động từ + 过 (看过) + Tân ngữ (那个电影) + 吗？"}]$$::jsonb,
  1
),
(
  2,
  15,
  'Bài 15: 新年就要到了 (Năm mới sắp đến rồi)',
  '1. Cấu trúc hành động sắp xảy ra: 快要 / 就要 ... 了 (sắp sửa ... rồi)',
  'Chủ ngữ + 快要 / 就要 + Động từ / Tính từ + 了',
  'Biểu thị một sự việc sắp sửa xảy ra trong một tương lai rất gần.<br>• Lưu ý: Nếu trong câu có mốc thời gian cụ thể (như 明天, 下星期, 八点), bắt buộc dùng <b>就要...了</b>, không được dùng 快要...了.',
  $$[{"hanzi":"新年就要到了！","pinyin":"Xīnnián jiù yào dào le!","meaning":"Năm mới sắp đến rồi!"},{"hanzi":"火车快要开走了，快跑！","pinyin":"Huǒchē kuài yào kāi zǒu le, kuài pǎo!","meaning":"Xe lửa sắp chạy rồi, chạy nhanh lên!"}]$$::jsonb,
  $$[{"type":"choice","question":"明天我们 ___ 考试了。","options":["就要","快要","正在","已经"],"answer":"就要","pinyin":"Míngtiān wǒmen ___ kǎoshì le.","meaning":"Ngày mai chúng tôi sắp thi rồi.","explanation":"Có trạng ngữ thời gian cụ thể (明天) chỉ dùng '就要...了'."},{"type":"order","words":["新年","就","要","到","了"],"answer":"新年就要到了","pinyin":"Xīnnián jiù yào dào le.","meaning":"Năm mới sắp đến rồi.","explanation":"Trật tự câu: Chủ ngữ (新年) + 就要 + Động từ (到) + 了."}]$$::jsonb,
  1
),
(
  3,
  1,
  'Bài 1: 周末你有什么打算 (Cuối tuần bạn có dự định gì?)',
  '1. Động từ / Danh từ: 打算 (dǎsuan - dự định / tính làm gì)',
  'Chủ ngữ + 打算 + Động từ...？ | Có dự định gì: 有什么打算',
  '<b>打算</b> có thể làm động từ (''dự định làm gì'') hoặc danh từ (''kế hoạch, dự định'').',
  $$[{"hanzi":"周末你有什么打算？——我打算去旅游。","pinyin":"Zhōumò nǐ yǒu shénme dǎsuan? —— Wǒ dǎsuan qù lǚyóu.","meaning":"Cuối tuần bạn có dự định gì? —— Tôi dự tính đi du lịch."},{"hanzi":"下个月你打算做什么？","pinyin":"Xià ge yuè nǐ dǎsuan zuò shénme?","meaning":"Tháng sau bạn dự định làm gì?"}]$$::jsonb,
  $$[{"type":"choice","question":"周末你有什么 ___ ？","options":["打算","决定","意思","希望"],"answer":"打算","pinyin":"Zhōumò nǐ yǒu shénme ___ ?","meaning":"Cuối tuần bạn có dự định gì?","explanation":"Hỏi dự tính/kế hoạch dùng '打算'."},{"type":"order","words":["周末","你","有","什么","打算","？"],"answer":"周末你有什么打算？","pinyin":"Zhōumò nǐ yǒu shénme dǎsuan?","meaning":"Cuối tuần bạn có dự định gì?","explanation":"Trật tự câu: Thời gian (周末) + Chủ ngữ (你) + Có cái gì (有什么打算) + ？"}]$$::jsonb,
  1
),
(
  3,
  2,
  'Bài 2: 他什么时候回来 (Khi nào anh ấy quay lại?)',
  '1. Bổ ngữ xu hướng đơn: 来 (lái) và 去 (qù)',
  'Động từ (上/下/进/出/回/过) + 来 / 去',
  '• Dùng <b>来</b> khi động tác hướng <b>về phía</b> người nói (ví dụ: 回来: quay về chỗ người nói).<br>• Dùng <b>去</b> khi động tác hướng <b>rời xa</b> người nói (ví dụ: 回去: quay về nơi xa người nói).',
  $$[{"hanzi":"他什么时候回来？——他十分钟后回来。","pinyin":"Tā shénme shíhou huílái? —— Tā shí fēnzhōng hòu huílái.","meaning":"Khi nào anh ấy quay lại đây? —— Mười phút nữa anh ấy quay lại."},{"hanzi":"快进来吧，外面太冷了！","pinyin":"Kuài jìnlái ba, wàimiàn tài lěng le!","meaning":"Vào mau đi, bên ngoài lạnh quá!"}]$$::jsonb,
  $$[{"type":"choice","question":"老师在办公室里，请你进 ___ 吧。","options":["去","来","回","上"],"answer":"去","pinyin":"Qǐng nǐ jìn ___ ba.","meaning":"Thầy giáo ở trong văn phòng, mời bạn đi vào trong đó.","explanation":"Người nói đang ở ngoài, hướng vào trong xa người nói dùng '去' (进去)."}]$$::jsonb,
  1
),
(
  3,
  3,
  'Bài 3: 桌子上放着很多饮料 (Trên bàn để rất nhiều đồ uống)',
  '1. Câu tồn hiện (Câu miêu tả sự vật tồn tại ở một địa điểm)',
  'Từ chỉ nơi chốn + Động từ + 着 + Tân ngữ (Sự vật)',
  'Câu tồn hiện dùng để miêu tả sự tồn tại của một đồ vật hoặc người tại một vị trí cụ thể. Các động từ thường gặp: 放 (đặt/để), 挂 (treo), 坐 (ngồi), 站 (đứng).',
  $$[{"hanzi":"桌子上放着很多饮料。","pinyin":"Zhuōzi shang fàng zhe hěn duō yǐnliào.","meaning":"Trên bàn để rất nhiều đồ uống."},{"hanzi":"墙上挂着一张中国地图。","pinyin":"Qiáng shang guà zhe yì zhāng Zhōngguó dìtú.","meaning":"Trên tường đang treo một tấm bản đồ Trung Quốc."}]$$::jsonb,
  $$[{"type":"order","words":["桌子上","放着","很多","饮料"],"answer":"桌子上放着很多饮料","pinyin":"Zhuōzi shang fàng zhe hěn duō yǐnliào.","meaning":"Trên bàn để rất nhiều đồ uống.","explanation":"Trật tự câu tồn hiện: Nơi chốn (桌子上) + Động từ + 着 (放着) + Sự vật (很多饮料)."}]$$::jsonb,
  1
),
(
  3,
  4,
  'Bài 4: 她总是笑着跟客人说话 (Cô ấy luôn tươi cười khi nói chuyện với khách)',
  '1. Cấu trúc V1 + 着 + V2 biểu thị phương thức tiến hành động tác',
  'Chủ ngữ + Động từ 1 + 着 + (+ Tân ngữ 1) + Động từ 2',
  'Hành động thứ nhất mang ''着'' đóng vai trò phương thức hoặc trạng thái đệm cho hành động thứ hai diễn ra (ví dụ: vừa cười vừa nói chuyện, đứng nói chuyện, nằm xem điện thoại).',
  $$[{"hanzi":"她总是笑着跟客人说话。","pinyin":"Tā zǒngshì xiào zhe gēn kèrén shuōhuà.","meaning":"Cô ấy luôn tươi cười khi nói chuyện với khách."},{"hanzi":"弟弟常常躺着看书。","pinyin":"Dìdi chángcháng tǎng zhe kàn shū.","meaning":"Em trai thường nằm đọc sách."}]$$::jsonb,
  $$[{"type":"order","words":["她","总是","笑着","跟","客人","说话"],"answer":"她总是笑着跟客人说话","pinyin":"Tā zǒngshì xiào zhe gēn kèrén shuōhuà.","meaning":"Cô ấy luôn tươi cười khi nói chuyện với khách.","explanation":"Trật tự: Chủ ngữ (她) + 总是 + Trạng thái V1+着 (笑着) + Hành động chính (跟客人说话)."}]$$::jsonb,
  1
),
(
  3,
  5,
  'Bài 5: 我最近越来越胖了 (Dạo này tôi ngày càng béo lên)',
  '1. Cấu trúc biến chuyển cấp độ: 越来越 + Tính từ / Động từ tâm lý',
  'Chủ ngữ + 越来越 + Tính từ / Động từ + (了)',
  'Cấu trúc này biểu thị mức độ của sự vật tăng dần theo thời gian (''càng ngày càng...''). Chú ý: Phía sau <b>越来越</b> KHÔNG ĐƯỢC thêm phó từ mức độ như 很, 非常, 太.',
  $$[{"hanzi":"我最近越来越胖了。","pinyin":"Wǒ zuìjìn yuèláiyuè pàng le.","meaning":"Dạo này tôi ngày càng béo lên rồi."},{"hanzi":"天气越来越冷了。","pinyin":"Tiānqì yuèláiyuè lěng le.","meaning":"Thời tiết càng ngày càng lạnh rồi."}]$$::jsonb,
  $$[{"type":"choice","question":"他的汉语说得越来越 ___ 了。","options":["好","很好","非常好","太好"],"answer":"好","pinyin":"Tā de hànyǔ shuō de yuèláiyuè ___ le.","meaning":"Tiếng Trung của anh ấy càng ngày càng tốt.","explanation":"Sau 越来越 không được dùng 很, 非常, 太."},{"type":"order","words":["我","最近","越来越","胖","了"],"answer":"我最近越来越胖了","pinyin":"Wǒ zuìjìn yuèláiyuè pàng le.","meaning":"Dạo này tôi ngày càng béo lên.","explanation":"Trật tự: Chủ ngữ (我) + Thời gian (最近) + 越来越 + Tính từ (胖) + 了."}]$$::jsonb,
  1
),
(
  3,
  6,
  'Bài 6: 怎么突然找不到了 (Sao tự nhiên lại không tìm thấy nữa?)',
  '1. Bổ ngữ khả năng: V + 得 / 不 + Bổ ngữ kết quả/xu hướng',
  'Khẳng định: V + 得 + C | Phủ định: V + 不 + C (Tìm được / Không tìm thấy)',
  'Dùng để biểu thị một hành động có đủ điều kiện hoặc năng lực để đạt được kết quả nào đó hay không.<br>• <b>找得到</b> (tìm thấy được) vs <b>找不到</b> (không tìm thấy).<br>• <b>看得见</b> (nhìn thấy) vs <b>看不见</b> (không nhìn thấy).<br>• <b>听得懂</b> (nghe hiểu) vs <b>听不懂</b> (nghe không hiểu).',
  $$[{"hanzi":"我的钥匙怎么突然找不到了？","pinyin":"Wǒ de yàoshi zěnme tūrán zhǎo bú dào le?","meaning":"Chìa khóa của tôi sao tự nhiên không tìm thấy nữa rồi?"},{"hanzi":"你说得太快了，我听不懂。","pinyin":"Nǐ shuō de tài kuài le, wǒ tīng bù dǒng.","meaning":"Bạn nói nhanh quá, tôi nghe không hiểu."}]$$::jsonb,
  $$[{"type":"choice","question":"字太小了，我看不 ___ 。","options":["见","到","在","着"],"answer":"见","pinyin":"Zì tài xiǎo le, wǒ kàn bù ___ .","meaning":"Chữ nhỏ quá, tôi không nhìn thấy.","explanation":"Không nhìn thấy dùng '看不见'."},{"type":"order","words":["怎么","突然","找","不","到","了"],"answer":"怎么突然找不到了","pinyin":"Zěnme tūrán zhǎo bú dào le.","meaning":"Sao tự nhiên lại không tìm thấy nữa?","explanation":"Trật tự: 怎么 + 突然 + Bổ ngữ khả năng phủ định (找不到) + 了."}]$$::jsonb,
  1
),
(
  3,
  7,
  'Bài 7: 我跟她都认识五年了 (Tôi và cô ấy đã quen nhau 5 năm rồi)',
  '1. Bổ ngữ thời lượng biểu thị hành động kéo dài',
  'Chủ ngữ + Động từ + (了) + Khoảng thời gian + (了)',
  'Bổ ngữ thời lượng dùng để biểu thị hành động diễn ra trong bao lâu.<br>• Nếu cuối câu có thêm <b>了</b>: biểu thị hành động bắt đầu từ quá khứ và <b>vẫn đang tiếp tục diễn ra</b> ở hiện tại.',
  $$[{"hanzi":"我跟她都认识五年了。","pinyin":"Wǒ gēn tā dōu rènshi wǔ nián le.","meaning":"Tôi và cô ấy đã quen nhau được 5 năm rồi (hiện vẫn đang quen nhau)."},{"hanzi":"他在中国学了两年汉语了。","pinyin":"Tā zài Zhōngguó xué le liǎng nián hànyǔ le.","meaning":"Anh ấy đã học tiếng Trung ở Trung Quốc 2 năm rồi."}]$$::jsonb,
  $$[{"type":"order","words":["我","跟","她","都","认识","五年","了"],"answer":"我跟她都认识五年了","pinyin":"Wǒ gēn tā dōu rènshi wǔ nián le.","meaning":"Tôi và cô ấy đã quen nhau 5 năm rồi.","explanation":"Trật tự bổ ngữ thời lượng: Chủ ngữ (我跟她) + 都 + Động từ (认识) + Thời lượng (五年) + 了."}]$$::jsonb,
  1
),
(
  3,
  8,
  'Bài 8: 你去哪儿我就去哪儿 (Bạn đi đâu thì tôi đi đó)',
  '1. Đại từ nghi vấn dùng linh hoạt / Cặp hô ứng với 就',
  'Đại từ nghi vấn (哪儿/什么/谁) ... 就 ... Đại từ nghi vấn đó',
  'Khi cùng một đại từ nghi vấn xuất hiện ở hai phân câu nối tiếp nhau bằng <b>就</b>, nó biểu thị phân câu sau sẽ tuân theo và phụ thuộc hoàn toàn vào phân câu trước (''ai thì nấy...'', ''cái gì thì cái nấy...'', ''ở đâu thì ở đó...'').',
  $$[{"hanzi":"你去哪儿我就去哪儿。","pinyin":"Nǐ qù nǎr wǒ jiù qù nǎr.","meaning":"Bạn đi đâu thì tôi đi đó."},{"hanzi":"你想吃什么就吃什么。","pinyin":"Nǐ xiǎng chī shénme jiù chī shénme.","meaning":"Bạn muốn ăn gì thì ăn nấy."}]$$::jsonb,
  $$[{"type":"choice","question":"你想喝什么，我 ___ 喝什么。","options":["就","才","也","还"],"answer":"就","pinyin":"Nǐ xiǎng hē shénme, wǒ ___ hē shénme.","meaning":"Bạn muốn uống gì thì tôi uống nấy.","explanation":"Cặp liên từ hô ứng đại từ nghi vấn dùng '就'."},{"type":"order","words":["你","去","哪儿","我","就","去","哪儿"],"answer":"你去哪儿我就去哪儿","pinyin":"Nǐ qù nǎr wǒ jiù qù nǎr.","meaning":"Bạn đi đâu thì tôi đi đó.","explanation":"Cấu trúc hô ứng: 你去哪儿 + 我就去哪儿."}]$$::jsonb,
  1
),
(
  3,
  9,
  'Bài 9: 她的汉语说得跟中国人一样好 (Cô ấy nói tiếng Hán giỏi như người Trung Quốc)',
  '1. Cấu trúc so sánh ngang bằng: A 跟 / 和 B 一样 (+ Tính từ)',
  'A + 跟 / 和 + B + 一样 (+ Tính từ) | Phủ định: A 跟 B 不一样',
  'Dùng để biểu thị hai đối tượng A và B có đặc điểm, tính chất ngang bằng nhau (''giống như / bằng như'').',
  $$[{"hanzi":"她的汉语说得跟中国人一样好。","pinyin":"Tā de hànyǔ shuō de gēn Zhōngguó rén yíyàng hǎo.","meaning":"Tiếng Trung của cô ấy nói giỏi như người Trung Quốc."},{"hanzi":"这个手机跟我的一样贵。","pinyin":"Zhège shǒujī gēn wǒ de yíyàng guì.","meaning":"Cái điện thoại này đắt ngang cái của tôi."}]$$::jsonb,
  $$[{"type":"choice","question":"哥哥长得跟爸爸 ___ 高。","options":["一样","非常","很多","太"],"answer":"一样","pinyin":"Gēge zhǎng de gēn bàba ___ gāo.","meaning":"Anh trai cao ngang bằng bố.","explanation":"So sánh ngang bằng: 跟...一样 + Tính từ."}]$$::jsonb,
  1
),
(
  3,
  10,
  'Bài 10: 数学比历史难多了 (Toán khó hơn Lịch sử nhiều)',
  '1. Câu so sánh chữ 比 có mức độ chênh lệch lớn: 多了 / 得多',
  'A + 比 + B + Tính từ + 多了 / 得多 / 一点儿',
  'Để nói mức độ chênh lệch giữa hai đối tượng là nhiều hay ít, ta đặt <b>多了</b> (duō le) hoặc <b>得多</b> (de duō) ở sau tính từ.',
  $$[{"hanzi":"数学比历史难多了。","pinyin":"Shùxué bǐ lìshǐ nán duō le.","meaning":"Toán học khó hơn Lịch sử nhiều."},{"hanzi":"今天比昨天冷得多。","pinyin":"Jīntiān bǐ zuótiān lěng de duō.","meaning":"Hôm nay lạnh hơn hôm qua rất nhiều."}]$$::jsonb,
  $$[{"type":"order","words":["数学","比","历史","难","多了"],"answer":"数学比历史难多了","pinyin":"Shùxué bǐ lìshǐ nán duō le.","meaning":"Toán khó hơn Lịch sử nhiều.","explanation":"Trật tự câu so sánh: A (数学) + 比 + B (历史) + Tính từ (难) + 多了."}]$$::jsonb,
  1
),
(
  3,
  11,
  'Bài 11: 别忘了把空调关了 (Đừng quên tắt điều hòa đi nhé)',
  '1. Câu chữ 把 (bǎ) cơ bản - Tác động làm thay đổi sự vật',
  'Chủ ngữ + 把 + Tân ngữ + Động từ + Thành phần khác (了/bổ ngữ)',
  'Câu chữ <b>把</b> dùng để nhấn mạnh vào hành động tác động lên đối tượng cụ thể (tân ngữ xác định) và làm thay đổi vị trí, hình thái hoặc trạng thái của đối tượng đó.<br>Chú ý: Động từ trong câu chữ 把 không được đứng trơ trọi một mình, phía sau bắt buộc phải có thành phần khác (ví dụ: 了, Bổ ngữ kết quả, Bổ ngữ xu hướng).',
  $$[{"hanzi":"别忘了把空调关了。","pinyin":"Bié wàng le bǎ kōngtiáo guān le.","meaning":"Đừng quên tắt điều hòa đi nhé."},{"hanzi":"你把药喝了吧。","pinyin":"Nǐ bǎ yào hē le ba.","meaning":"Bạn uống thuốc đi."}]$$::jsonb,
  $$[{"type":"choice","question":"请你 ___ 门关上。","options":["把","被","让","向"],"answer":"把","pinyin":"Qǐng nǐ ___ mén guān shang.","meaning":"Xin bạn hãy đóng cửa lại.","explanation":"Tác động lên đối tượng xác định (cửa) dùng câu chữ '把'."},{"type":"order","words":["别忘了","把","空调","关","了"],"answer":"别忘了把空调关了","pinyin":"Bié wàng le bǎ kōngtiáo guān le.","meaning":"Đừng quên tắt điều hòa đi nhé.","explanation":"Trật tự câu chữ 把: 别忘了 + 把 + Tân ngữ (空调) + Động từ (关) + 了."}]$$::jsonb,
  1
),
(
  3,
  12,
  'Bài 12: 把重要的东西放在我这儿吧 (Hãy để những đồ quan trọng ở chỗ tôi)',
  '1. Câu chữ 把 kết hợp bổ ngữ nơi chốn: 把 + O + V + 在 / 到 / 给',
  'Chủ ngữ + 把 + Tân ngữ + Động từ + 在 / 到 / 给 + Nơi chốn / Người nhận',
  'Biểu thị hành động tác động làm cho sự vật di chuyển đến hoặc lưu lại ở một địa điểm/người nhận mới.',
  $$[{"hanzi":"把重要的东西放在我这儿吧。","pinyin":"Bǎ zhòngyào de dōngxi fàng zài wǒ zhèr ba.","meaning":"Hãy để những đồ vật quan trọng ở chỗ của tôi đi."},{"hanzi":"请把作业交给老师。","pinyin":"Qǐng bǎ zuòyè jiāo gěi lǎoshī.","meaning":"Xin hãy nộp bài tập cho thầy giáo."}]$$::jsonb,
  $$[{"type":"order","words":["把","重要的东西","放在","我这儿","吧"],"answer":"把重要的东西放在我这儿吧","pinyin":"Bǎ zhòngyào de dōngxi fàng zài wǒ zhèr ba.","meaning":"Hãy để những đồ quan trọng ở chỗ tôi.","explanation":"Trật tự: 把 + Tân ngữ (重要的东西) + Động từ + 在 (放在) + Nơi chốn (我这儿) + 吧."}]$$::jsonb,
  1
),
(
  3,
  13,
  'Bài 13: 我是走回来的 (Tôi đi bộ về đấy)',
  '1. Bổ ngữ xu hướng kép: Động từ + (上/下/进/出/回/过) + 来/去',
  'Động từ hành vi + Động từ chỉ hướng (进/出/回...) + 来 / 去',
  'Bổ ngữ xu hướng kép miêu tả phương thức di chuyển đồng thời chỉ rõ phương hướng đang hướng về hay rời xa người nói (ví dụ: 走回来 = đi bộ quay trở lại chỗ tôi).',
  $$[{"hanzi":"路上车太多，我是走回来的。","pinyin":"Lù shang chē tài duō, wǒ shì zǒu huílái de.","meaning":"Trên đường đông xe quá, tôi đi bộ về đấy."},{"hanzi":"他从包里拿出一本书来。","pinyin":"Tā cóng bāo lǐ ná chū yì běn shū lái.","meaning":"Anh ấy từ trong túi lấy ra một cuốn sách."}]$$::jsonb,
  $$[{"type":"choice","question":"你怎么这么慢？——我是走回 ___ 的。","options":["来","去","到","在"],"answer":"来","pinyin":"Wǒ shì zǒu huí ___ de.","meaning":"Tôi đi bộ về chỗ này.","explanation":"Hướng về phía người đang nói dùng '走回来'."}]$$::jsonb,
  1
),
(
  3,
  14,
  'Bài 14: 你把水果拿过来 (Bạn mang trái cây qua đây đi)',
  '1. Câu chữ 把 kết hợp Bổ ngữ xu hướng kép',
  'Chủ ngữ + 把 + Tân ngữ + Động từ + 过来 / 过去 / 出来...',
  'Dùng để yêu cầu hoặc miêu tả việc dịch chuyển vị trí của đối tượng theo phương hướng cụ thể.',
  $$[{"hanzi":"你把水果拿过来。","pinyin":"Nǐ bǎ shuǐguǒ ná guòlái.","meaning":"Bạn mang trái cây qua đây đi."},{"hanzi":"请把这封信送过去。","pinyin":"Qǐng bǎ zhè fēng xìn sòng guòqù.","meaning":"Xin hãy đem bức thư này đưa qua bên đó."}]$$::jsonb,
  $$[{"type":"order","words":["你","把","水果","拿","过来"],"answer":"你把水果拿过来","pinyin":"Nǐ bǎ shuǐguǒ ná guòlái.","meaning":"Bạn mang trái cây qua đây đi.","explanation":"Trật tự câu: Chủ ngữ (你) + 把 + Tân ngữ (水果) + Động từ (拿) + Bổ ngữ xu hướng (过来)."}]$$::jsonb,
  1
),
(
  3,
  15,
  'Bài 15: 其他都没什么问题 (Những thứ khác đều không có vấn đề gì)',
  '1. Cấu trúc loại trừ: 除了...以外, (其他 / 都)...',
  '除了 + Đối tượng + (以外), Chủ ngữ + 都 / 也...',
  '• Dùng để biểu thị ngoại trừ một đối tượng nào đó ra, những cái còn lại đều như nhau.<br>• Đại từ <b>其他</b> (qítā) nghĩa là ''cái khác, những người khác''.',
  $$[{"hanzi":"除了这个，其他都没什么问题。","pinyin":"Chúle zhège, qítā dōu méi shénme wèntí.","meaning":"Ngoại trừ cái này ra, những thứ khác đều không có vấn đề gì."},{"hanzi":"除了星期天以外，他每天都去图书馆。","pinyin":"Chúle xīngqītiān yǐwài, tā měitiān dōu qù túshūguǎn.","meaning":"Ngoại trừ Chủ nhật ra, anh ấy ngày nào cũng đến thư viện."}]$$::jsonb,
  $$[{"type":"order","words":["其他","都","没什么","问题"],"answer":"其他都没什么问题","pinyin":"Qítā dōu méi shénme wèntí.","meaning":"Những thứ khác đều không có vấn đề gì.","explanation":"Trật tự câu: Chủ ngữ (其他) + Phó từ (都) + Vị ngữ (没什么问题)."}]$$::jsonb,
  1
),
(
  3,
  16,
  'Bài 16: 我现在累得下了班就想睡觉 (Bây giờ tôi mệt đến mức tan làm chỉ muốn đi ngủ)',
  '1. Bổ ngữ trạng thái mở rộng: Tính từ + 得 + Cụm vị ngữ chỉ mức độ',
  'Chủ ngữ + Tính từ + 得 + Cụm phân câu / hành động diễn tả mức độ',
  'Dùng để biểu thị trạng thái đạt đến một mức độ làm phát sinh một hành động cụ thể (''đến mức mà...'').',
  $$[{"hanzi":"我现在累得下了班就想睡觉。","pinyin":"Wǒ xiànzài lèi de xià le bān jiù xiǎng shuìjiào.","meaning":"Bây giờ tôi mệt đến mức tan ca xong chỉ muốn đi ngủ."},{"hanzi":"他高兴得跳了起来。","pinyin":"Tā gāoxìng de tiào le qǐlái.","meaning":"Anh ấy vui sướng đến mức nhảy cẫng lên."}]$$::jsonb,
  $$[{"type":"choice","question":"孩子高兴 ___ 笑了。","options":["得","的","地","了"],"answer":"得","pinyin":"Háizi gāoxìng ___ xiào le.","meaning":"Đứa trẻ vui đến mức cười tươi.","explanation":"Nối tính từ với cụm miêu tả mức độ bắt buộc dùng '得'."}]$$::jsonb,
  1
),
(
  3,
  17,
  'Bài 17: 谁都有办法看好你的病 (Ai cũng có cách chữa khỏi bệnh cho bạn)',
  '1. Đại từ nghi vấn biểu thị phiếm chỉ (Bất kỳ ai / Bất kỳ cái gì 都/也)',
  '谁 / 什么 / 哪儿 + 都 / 也 + Vị ngữ',
  'Khi đại từ nghi vấn đi cùng <b>都</b> hoặc <b>也</b> trong câu trần thuật, nó không còn là câu hỏi mà mang nghĩa phiếm chỉ tất cả (''ai cũng...'', ''cái gì cũng...'', ''ở đâu cũng...'').',
  $$[{"hanzi":"这里的医生谁都有办法看好你的病。","pinyin":"Zhèlǐ de yīshēng shéi dōu yǒu bànfǎ kànhǎo nǐ de bìng.","meaning":"Bác sĩ ở đây ai cũng có cách chữa khỏi bệnh cho bạn."},{"hanzi":"今天我什么都不想吃。","pinyin":"Jīntiān wǒ shénme dōu bù xiǎng chī.","meaning":"Hôm nay tôi cái gì cũng không muốn ăn."}]$$::jsonb,
  $$[{"type":"choice","question":"这个汉字太容易了，谁 ___ 认识。","options":["都","就","才","很"],"answer":"都","pinyin":"Zhège hànzì tài róngyì le, shéi ___ rènshi.","meaning":"Chữ Hán này dễ quá, ai cũng biết.","explanation":"Đại từ phiếm chỉ kết hợp '谁都'."}]$$::jsonb,
  1
),
(
  3,
  18,
  'Bài 18: 我相信他们会同意的 (Tôi tin là họ sẽ đồng ý)',
  '1. Cấu trúc biểu thị sự tin chắc: 会 ... 的',
  'Chủ ngữ + 会 + Động từ + 的',
  'Dùng để biểu thị khả năng nhất định sẽ xảy ra một sự việc, thể hiện thái độ tin tưởng, khẳng định chắc chắn của người nói.',
  $$[{"hanzi":"我相信他们会同意的。","pinyin":"Wǒ xiāngxìn tāmen huì tóngyì de.","meaning":"Tôi tin là họ nhất định sẽ đồng ý thôi."},{"hanzi":"别担心，一切都会好起来的。","pinyin":"Bié dānxīn, yíqiè dōu huì hǎo qǐlái de.","meaning":"Đừng lo lắng, mọi thứ đều sẽ tốt đẹp lên thôi."}]$$::jsonb,
  $$[{"type":"order","words":["我","相信","他们","会","同意","的"],"answer":"我相信他们会同意的","pinyin":"Wǒ xiāngxìn tāmen huì tóngyì de.","meaning":"Tôi tin là họ sẽ đồng ý.","explanation":"Trật tự: 我相信 + 他们 + 会 + 同意 + 的."}]$$::jsonb,
  1
),
(
  3,
  19,
  'Bài 19: 你没看出来吗 (Bạn không nhìn ra sao?)',
  '1. Nghĩa mở rộng của bổ ngữ xu hướng 出来 (chūlái - nhận ra / làm sáng tỏ)',
  'Động từ (看/听/想) + 出来',
  'Khi <b>出来</b> đi sau các động từ tri giác như 看 (nhìn), 听 (nghe), 想 (nghĩ), nó biểu thị việc nhận biết, phát hiện ra sự thật qua quan sát hoặc suy nghĩ (''nhận ra'', ''nghe ra'', ''nghĩ ra'').',
  $$[{"hanzi":"他今天穿了新衣服，你没看出来吗？","pinyin":"Tā jīntiān chuān le xīn yīfu, nǐ méi kàn chūlái ma?","meaning":"Hôm nay anh ấy mặc áo mới, bạn không nhìn ra sao?"},{"hanzi":"我想出来了这个题的做法。","pinyin":"Wǒ xiǎng chūlái le zhège tí de zuòfǎ.","meaning":"Tôi đã nghĩ ra cách làm của bài này rồi."}]$$::jsonb,
  $$[{"type":"choice","question":"他是哪国人，你听 ___ 来了吗？","options":["出","起","进","过"],"answer":"出","pinyin":"Tā shì nǎ guó rén, nǐ tīng ___ lái le ma?","meaning":"Bạn có nghe nhận ra anh ấy là người nước nào không?","explanation":"Nhận biết qua thính giác dùng '听出来'."}]$$::jsonb,
  1
),
(
  3,
  20,
  'Bài 20: 我被他影响了 (Tôi bị anh ấy ảnh hưởng rồi)',
  '1. Câu bị động với giới từ 被 (bèi - bị / được)',
  'Chủ ngữ (Người chịu tác động) + 被 (+ Tác nhân) + Động từ + Thành phần khác',
  'Câu bị động dùng để nhấn mạnh chủ ngữ bị một tác nhân khác tác động vào (thường mang ý kết quả không mong muốn hoặc bị tác động sâu sắc). Trong khẩu ngữ có thể dùng <b>叫</b> hoặc <b>让</b> thay cho 被.',
  $$[{"hanzi":"我被他影响了。","pinyin":"Wǒ bèi tā yǐngxiǎng le.","meaning":"Tôi bị anh ấy ảnh hưởng rồi."},{"hanzi":"我的苹果被弟弟吃了。","pinyin":"Wǒ de píngguǒ bèi dìdi chī le.","meaning":"Quả táo của tôi bị em trai ăn mất rồi."}]$$::jsonb,
  $$[{"type":"choice","question":"蛋糕 ___ 猫吃掉了。","options":["被","把","比","向"],"answer":"被","pinyin":"Dàngāo ___ māo chī diào le.","meaning":"Bánh ngọt bị mèo ăn mất rồi.","explanation":"Câu bị động dùng giới từ '被'."},{"type":"order","words":["我","被","他","影响","了"],"answer":"我被他影响了","pinyin":"Wǒ bèi tā yǐngxiǎng le.","meaning":"Tôi bị anh ấy ảnh hưởng rồi.","explanation":"Trật tự câu bị động chữ 被: Chủ ngữ (我) + 被 + Tác nhân (他) + Động từ (影响) + 了."}]$$::jsonb,
  1
);

-- Hoàn tất import 50 bài Giáo trình Chuẩn HSK 1, 2, 3!
