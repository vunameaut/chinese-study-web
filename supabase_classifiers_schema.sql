-- ====================================================================
-- SCRIPT IMPORT DỮ LIỆU LƯỢNG TỪ GIÁO TRÌNH CHUẨN HSK 1, 2, 3 VÀO SUPABASE
-- (HSK Standard Course - NXB Đại học Ngôn ngữ Bắc Kinh / BLCUP)
-- ====================================================================
-- HƯỚNG DẪN IMPORT:
-- 1. Truy cập Supabase Dashboard -> chọn Project của bạn.
-- 2. Vào mục "SQL Editor" ở thanh menu bên trái.
-- 3. Bấm "New query", dán toàn bộ nội dung script này vào và bấm "Run" (hoặc Ctrl + Enter).
-- Toàn bộ lượng từ chuẩn theo từng bài HSK 1, 2, 3 sẽ được nạp vào bảng 'classifiers'.
-- ====================================================================

-- 1. Tạo bảng classifiers (nếu chưa có)
CREATE TABLE IF NOT EXISTS classifiers (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT REFERENCES sessions(id) ON DELETE CASCADE,
  hsk_level INT NOT NULL DEFAULT 1,
  lesson_num INT NOT NULL DEFAULT 1,
  lesson_title TEXT,
  hanzi TEXT NOT NULL,
  pinyin TEXT NOT NULL,
  meaning TEXT NOT NULL,
  usage_note TEXT,
  collocations JSONB DEFAULT '[]'::jsonb,
  examples JSONB DEFAULT '[]'::jsonb,
  exercises JSONB DEFAULT '[]'::jsonb,
  order_index INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cập nhật bổ sung cột nếu bảng đã tồn tại
ALTER TABLE classifiers ADD COLUMN IF NOT EXISTS hsk_level INT DEFAULT 1;
ALTER TABLE classifiers ADD COLUMN IF NOT EXISTS lesson_num INT DEFAULT 1;
ALTER TABLE classifiers ADD COLUMN IF NOT EXISTS lesson_title TEXT;
ALTER TABLE classifiers ADD COLUMN IF NOT EXISTS usage_note TEXT;
ALTER TABLE classifiers ADD COLUMN IF NOT EXISTS collocations JSONB DEFAULT '[]'::jsonb;
ALTER TABLE classifiers ADD COLUMN IF NOT EXISTS examples JSONB DEFAULT '[]'::jsonb;
ALTER TABLE classifiers ADD COLUMN IF NOT EXISTS exercises JSONB DEFAULT '[]'::jsonb;
ALTER TABLE classifiers ALTER COLUMN session_id DROP NOT NULL;

-- 2. Đánh index tối ưu tốc độ truy vấn theo cấp độ HSK và bài học
CREATE INDEX IF NOT EXISTS idx_classifiers_session_id ON classifiers(session_id);
CREATE INDEX IF NOT EXISTS idx_classifiers_hsk_lesson ON classifiers(hsk_level, lesson_num);

-- 3. Cấu hình Row Level Security (RLS)
ALTER TABLE classifiers ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'classifiers' AND policyname = 'Allow public read on classifiers') THEN
    CREATE POLICY "Allow public read on classifiers" ON classifiers FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'classifiers' AND policyname = 'Allow public insert on classifiers') THEN
    CREATE POLICY "Allow public insert on classifiers" ON classifiers FOR INSERT TO anon, authenticated WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'classifiers' AND policyname = 'Allow public update on classifiers') THEN
    CREATE POLICY "Allow public update on classifiers" ON classifiers FOR UPDATE TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'classifiers' AND policyname = 'Allow public delete on classifiers') THEN
    CREATE POLICY "Allow public delete on classifiers" ON classifiers FOR DELETE TO anon, authenticated USING (true);
  END IF;
END $$;

-- 4. Xóa dữ liệu mẫu cũ (nếu session_id IS NULL) để tránh trùng lặp khi chạy lại script
DELETE FROM classifiers WHERE session_id IS NULL;

-- 5. NẠP DỮ LIỆU LƯỢNG TỪ HSK 1, 2, 3 THEO TỪNG BÀI

-- ==========================================
-- HSK 1
-- ==========================================

-- HSK 1 - Bài 3: Cô ấy là người nước nào? (Lượng từ: 个)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  1, 3, 'Bài 3: Cô ấy là người nước nào? (她是哪国人)',
  '个', 'gè', 'cái, con, người (lượng từ chung thông dụng nhất)',
  'Lượng từ phổ biến nhất trong tiếng Trung. Dùng cho người, các vật thể hình khối thông thường, hoặc khi danh từ không có lượng từ chuyên biệt.',
  '[
    {"noun": "人", "pinyin": "rén", "phrase": "一个人", "meaning": "một người"},
    {"noun": "学生", "pinyin": "xuéshēng", "phrase": "一个学生", "meaning": "một học sinh"},
    {"noun": "朋友", "pinyin": "péngyou", "phrase": "三个朋友", "meaning": "ba người bạn"},
    {"noun": "苹果", "pinyin": "píngguǒ", "phrase": "两个苹果", "meaning": "hai quả táo"},
    {"noun": "杯子", "pinyin": "bēizi", "phrase": "一个杯子", "meaning": "một cái cốc"},
    {"noun": "月", "pinyin": "yuè", "phrase": "一个月", "meaning": "một tháng"}
  ]'::jsonb,
  '[
    {"hanzi": "我有一个中国朋友。", "pinyin": "Wǒ yǒu yí gè Zhōngguó péngyou.", "meaning": "Tôi có một người bạn Trung Quốc."},
    {"hanzi": "桌子上有一个杯子。", "pinyin": "Zhuōzi shàng yǒu yí gè bēizi.", "meaning": "Trên bàn có một cái cốc."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "我认识一___中国朋友。",
      "options": ["个", "本", "条", "张"],
      "answer": "个",
      "explain": "Từ ''朋友'' (bạn bè/người) dùng lượng từ thông dụng là ''个''."
    },
    {
      "type": "choice",
      "question": "桌子上有一___杯子。",
      "options": ["张", "个", "本", "只"],
      "answer": "个",
      "explain": "Cái cốc (杯子) dùng lượng từ ''个''."
    }
  ]'::jsonb,
  1
);

-- HSK 1 - Bài 5: Con gái bạn năm nay mấy tuổi? (Lượng từ: 岁)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  1, 5, 'Bài 5: Con gái bạn năm nay mấy tuổi? (她女儿今年二十岁)',
  '岁', 'suì', 'tuổi',
  'Lượng từ chỉ độ tuổi. Cấu trúc: [Số từ] + 岁 (không cần thêm ''个'').',
  '[
    {"noun": "岁", "pinyin": "suì", "phrase": "二十岁", "meaning": "20 tuổi"},
    {"noun": "岁", "pinyin": "suì", "phrase": "五岁", "meaning": "5 tuổi"},
    {"noun": "岁", "pinyin": "suì", "phrase": "几岁", "meaning": "mấy tuổi"}
  ]'::jsonb,
  '[
    {"hanzi": "李老师今年五十岁。", "pinyin": "Lǐ lǎoshī jīnnián wǔshí suì.", "meaning": "Thầy Lý năm nay 50 tuổi."},
    {"hanzi": "你女儿几岁了？", "pinyin": "Nǐ nǚ''ér jǐ suì le?", "meaning": "Con gái bạn mấy tuổi rồi?"}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "他儿子今年四___了。",
      "options": ["岁", "个", "本", "号"],
      "answer": "岁",
      "explain": "Độ tuổi của người dùng lượng từ ''岁''."
    }
  ]'::jsonb,
  1
);

-- HSK 1 - Bài 7: Hôm nay là ngày mấy? (Lượng từ: 号)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  1, 7, 'Bài 7: Hôm nay là ngày mấy? (今天几号)',
  '号', 'hào', 'ngày, số',
  'Dùng trong khẩu ngữ chỉ ngày trong tháng hoặc số phòng, số hiệu.',
  '[
    {"noun": "号", "pinyin": "hào", "phrase": "一号", "meaning": "ngày mùng 1"},
    {"noun": "号", "pinyin": "hào", "phrase": "二十五号", "meaning": "ngày 25"},
    {"noun": "房间", "pinyin": "fángjiān", "phrase": "102号房间", "meaning": "phòng số 102"}
  ]'::jsonb,
  '[
    {"hanzi": "今天是九月一号。", "pinyin": "Jīntiān shì jiǔ yuè yī hào.", "meaning": "Hôm nay là ngày 1 tháng 9."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "明天是十月五___。",
      "options": ["号", "岁", "个", "块"],
      "answer": "号",
      "explain": "Ngày trong tháng dùng lượng từ ''号''."
    }
  ]'::jsonb,
  1
);

-- HSK 1 - Bài 8: Tôi muốn uống trà (Lượng từ: 块, 杯)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  1, 8, 'Bài 8: Tôi muốn uống trà (我想喝茶)',
  '块', 'kuài', 'đồng, miếng, cục',
  'Dùng trong khẩu ngữ chỉ đơn vị tiền tệ (đồng/tệ) hoặc các vật thể hình khối/miếng như bánh ngọt, đồng hồ.',
  '[
    {"noun": "钱", "pinyin": "qián", "phrase": "一块钱", "meaning": "một đồng tiền (1 tệ)"},
    {"noun": "蛋糕", "pinyin": "dàngāo", "phrase": "两块蛋糕", "meaning": "hai miếng bánh ngọt"},
    {"noun": "西瓜", "pinyin": "xīguā", "phrase": "一块西瓜", "meaning": "một miếng dưa hấu"}
  ]'::jsonb,
  '[
    {"hanzi": "这个杯子多少钱？——五块钱。", "pinyin": "Zhè ge bēizi duōshǎo qián? —— Wǔ kuài qián.", "meaning": "Cái cốc này bao nhiêu tiền? —— 5 tệ."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "这个苹果三___钱。",
      "options": ["块", "本", "张", "只"],
      "answer": "块",
      "explain": "Tiền tệ trong khẩu ngữ dùng lượng từ ''块''."
    }
  ]'::jsonb,
  1
),
(
  1, 8, 'Bài 8: Tôi muốn uống trà (我想喝茶)',
  '杯', 'bēi', 'cốc, ly, tách',
  'Lượng từ chỉ dung tích đồ uống đựng trong cốc, ly, tách (trà, cà phê, nước).',
  '[
    {"noun": "茶", "pinyin": "chá", "phrase": "一杯茶", "meaning": "một tách trà"},
    {"noun": "水", "pinyin": "shuǐ", "phrase": "一杯水", "meaning": "một cốc nước"},
    {"noun": "咖啡", "pinyin": "kāfēi", "phrase": "一杯咖啡", "meaning": "một ly cà phê"}
  ]'::jsonb,
  '[
    {"hanzi": "我想喝一杯热茶。", "pinyin": "Wǒ xiǎng hē yì bēi rè chá.", "meaning": "Tôi muốn uống một tách trà nóng."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "我想喝一___热茶。",
      "options": ["杯", "本", "块", "只"],
      "answer": "杯",
      "explain": "Đồ uống như trà (茶) dùng lượng từ ''杯'' (cốc/tách)."
    }
  ]'::jsonb,
  2
);

-- HSK 1 - Bài 9: Con trai bạn làm việc ở đâu? (Lượng từ: 本)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  1, 9, 'Bài 9: Con trai bạn làm việc ở đâu? (你儿子在哪儿工作)',
  '本', 'běn', 'quyển, cuốn',
  'Dùng cho sách vở, từ điển, tạp chí, các ấn phẩm đóng thành quyển có gáy.',
  '[
    {"noun": "书", "pinyin": "shū", "phrase": "一本书", "meaning": "một quyển sách"},
    {"noun": "本子", "pinyin": "běnzi", "phrase": "一本本子", "meaning": "một cuốn vở"},
    {"noun": "词典", "pinyin": "cídiǎn", "phrase": "一本词典", "meaning": "một cuốn từ điển"},
    {"noun": "汉语书", "pinyin": "Hànyǔ shū", "phrase": "两本汉语书", "meaning": "hai cuốn sách tiếng Hán"}
  ]'::jsonb,
  '[
    {"hanzi": "桌子上有一本书。", "pinyin": "Zhuōzi shàng yǒu yì běn shū.", "meaning": "Trên bàn có một cuốn sách."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "我买了两___汉语书。",
      "options": ["本", "件", "个", "条"],
      "answer": "本",
      "explain": "Sách (书) dùng lượng từ ''本'' (quyển/cuốn)."
    }
  ]'::jsonb,
  1
);

-- HSK 1 - Bài 12: Ngày mai thời tiết thế nào? (Lượng từ: 些)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  1, 12, 'Bài 12: Ngày mai thời tiết thế nào? (明天天气怎么样)',
  '些', 'xiē', 'những, một số, vài (lượng từ bất định)',
  'Chỉ số lượng nhiều không xác định. Thường dùng với 一些 (một vài), 这些 (những cái này), 那些 (những cái kia).',
  '[
    {"noun": "东西", "pinyin": "dōngxi", "phrase": "一些东西", "meaning": "một số đồ đạc"},
    {"noun": "苹果", "pinyin": "píngguǒ", "phrase": "这些苹果", "meaning": "những quả táo này"},
    {"noun": "人", "pinyin": "rén", "phrase": "那些人", "meaning": "những người kia"}
  ]'::jsonb,
  '[
    {"hanzi": "多吃些水果，对身体好。", "pinyin": "Duō chī xiē shuǐguǒ, duì shēntǐ hǎo.", "meaning": "Ăn nhiều chút hoa quả, tốt cho sức khỏe."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "我想买一___苹果。",
      "options": ["些", "本", "张", "只"],
      "answer": "些",
      "explain": "''一些'' mang nghĩa một vài/một ít (số lượng bất định)."
    }
  ]'::jsonb,
  1
);

-- ==========================================
-- HSK 2
-- ==========================================

-- HSK 2 - Bài 4: Công việc này là do anh ấy giới thiệu (Lượng từ: 件)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  2, 4, 'Bài 4: Công việc này là do anh ấy giới thiệu (这个工作是他帮我介绍的)',
  '件', 'jiàn', 'chiếc, cái, vụ, kiện',
  'Dùng cho trang phục thân trên hoặc toàn thân (áo sơ mi, áo khoác, sườn xám), hoặc dùng cho sự việc, món quà.',
  '[
    {"noun": "衣服", "pinyin": "yīfu", "phrase": "一件衣服", "meaning": "một bộ/chiếc quần áo"},
    {"noun": "衬衫", "pinyin": "chènshān", "phrase": "一件衬衫", "meaning": "một chiếc áo sơ mi"},
    {"noun": "事", "pinyin": "shì", "phrase": "一件事", "meaning": "một sự việc"},
    {"noun": "礼物", "pinyin": "lǐwù", "phrase": "一件礼物", "meaning": "một món quà"}
  ]'::jsonb,
  '[
    {"hanzi": "这件衣服很漂亮，但是有点贵。", "pinyin": "Zhè jiàn yīfu hěn piàoliang, dànshì yǒudiǎnr guì.", "meaning": "Bộ quần áo này rất đẹp, nhưng hơi đắt."},
    {"hanzi": "我想请你帮我做一件事。", "pinyin": "Wǒ xiǎng qǐng nǐ bāng wǒ zuò yí jiàn shì.", "meaning": "Tôi muốn nhờ bạn giúp tôi một việc."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "我想买一___漂亮的衣服。",
      "options": ["件", "张", "条", "本"],
      "answer": "件",
      "explain": "Quần áo (衣服) dùng lượng từ ''件''."
    },
    {
      "type": "choice",
      "question": "我有一___重要的事要告诉你。",
      "options": ["件", "只", "双", "本"],
      "answer": "件",
      "explain": "Sự việc (事) dùng lượng từ ''件'' (一件事)."
    }
  ]'::jsonb,
  1
);

-- HSK 2 - Bài 7: Bạn đến trường bằng cách nào? (Lượng từ: 条, 张)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  2, 7, 'Bài 7: Bạn đến trường bằng cách nào? (你怎么去学校)',
  '条', 'tiáo', 'con, chiếc, dải, sợi',
  'Dùng cho các sự vật có hình dáng thon dài, mềm mại hoặc uốn lượn (cá, quần, váy, con đường, dòng sông, cà vạt).',
  '[
    {"noun": "鱼", "pinyin": "yú", "phrase": "一条鱼", "meaning": "một con cá"},
    {"noun": "裤子", "pinyin": "kùzi", "phrase": "一条裤子", "meaning": "một chiếc quần"},
    {"noun": "裙子", "pinyin": "qúnzi", "phrase": "一条裙子", "meaning": "một chiếc váy"},
    {"noun": "路", "pinyin": "lù", "phrase": "一条路", "meaning": "một con đường"},
    {"noun": "河", "pinyin": "hé", "phrase": "一条河", "meaning": "một dòng sông"}
  ]'::jsonb,
  '[
    {"hanzi": "前面有一条很长的路。", "pinyin": "Qiánmiàn yǒu yì tiáo hěn cháng de lù.", "meaning": "Phía trước có một con đường rất dài."},
    {"hanzi": "这条裤子多少钱？", "pinyin": "Zhè tiáo kùzi duōshǎo qián?", "meaning": "Chiếc quần này bao nhiêu tiền?"}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "这条___很合身，颜色也很好看。",
      "options": ["裤子", "衣服", "书", "桌子"],
      "answer": "裤子",
      "explain": "Lượng từ ''条'' dùng cho quần (裤子) hoặc váy (裙子)."
    },
    {
      "type": "choice",
      "question": "河里有许多___在游来游去。",
      "options": ["鱼", "猫", "狗", "鸟"],
      "answer": "鱼",
      "explain": "Cá (鱼) thon dài bơi dưới nước dùng lượng từ ''条'' (一条鱼)."
    }
  ]'::jsonb,
  1
),
(
  2, 7, 'Bài 7: Bạn đến trường bằng cách nào? (你怎么去学校)',
  '张', 'zhāng', 'tờ, tấm, chiếc, cái',
  'Dùng cho các vật mỏng, phẳng hoặc có bề mặt phẳng rộng (giấy, bàn, giường, vé, ảnh, thẻ ngân hàng, mặt).',
  '[
    {"noun": "纸", "pinyin": "zhǐ", "phrase": "一张纸", "meaning": "một tờ giấy"},
    {"noun": "桌子", "pinyin": "zhuōzi", "phrase": "一张桌子", "meaning": "một chiếc bàn"},
    {"noun": "床", "pinyin": "chuáng", "phrase": "一张床", "meaning": "một chiếc giường"},
    {"noun": "票", "pinyin": "piào", "phrase": "两张票", "meaning": "hai tấm vé"},
    {"noun": "照片", "pinyin": "zhàopiàn", "phrase": "一张照片", "meaning": "một tấm ảnh"},
    {"noun": "脸", "pinyin": "liǎn", "phrase": "一张脸", "meaning": "một khuôn mặt"}
  ]'::jsonb,
  '[
    {"hanzi": "我买了两张电影票。", "pinyin": "Wǒ mǎi le liǎng zhāng diànyǐng piào.", "meaning": "Tôi đã mua hai tấm vé xem phim."},
    {"hanzi": "房间里有一张大桌子。", "pinyin": "Fángjiān lǐ yǒu yì zhāng dà zhuōzi.", "meaning": "Trong phòng có một chiếc bàn lớn."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "我买了两___明天去北京的火车票。",
      "options": ["张", "条", "本", "件"],
      "answer": "张",
      "explain": "Vé (票) là vật phẳng mỏng, dùng lượng từ ''张''."
    },
    {
      "type": "choice",
      "question": "请给我一___白纸。",
      "options": ["张", "条", "只", "双"],
      "answer": "张",
      "explain": "Giấy (纸) phẳng mỏng dùng lượng từ ''张''."
    }
  ]'::jsonb,
  2
);

-- HSK 2 - Bài 10: Đừng xem tivi nữa (Lượng từ: 只, 双)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  2, 10, 'Bài 10: Đừng xem tivi nữa, ngày mai còn phải thi (别看了，明天还要考试呢)',
  '只', 'zhī', 'con, chiếc',
  'Dùng cho hầu hết các loài động vật nhỏ/chim muông (mèo, gà, chim, chó nhỏ), hoặc 1 chiếc trong đồ vật có đôi (1 bàn tay, 1 con mắt, 1 chiếc giày).',
  '[
    {"noun": "猫", "pinyin": "māo", "phrase": "一只猫", "meaning": "một con mèo"},
    {"noun": "狗", "pinyin": "gǒu", "phrase": "一只狗", "meaning": "một con chó"},
    {"noun": "鸟", "pinyin": "niǎo", "phrase": "两只鸟", "meaning": "hai con chim"},
    {"noun": "手", "pinyin": "shǒu", "phrase": "一只手", "meaning": "một bàn tay"},
    {"noun": "眼睛", "pinyin": "yǎnjing", "phrase": "一只眼睛", "meaning": "một con mắt"}
  ]'::jsonb,
  '[
    {"hanzi": "我家养了一只可爱的小猫。", "pinyin": "Wǒ jiā yǎng le yì zhī kě''ài de xiǎomāo.", "meaning": "Nhà tôi nuôi một chú mèo nhỏ đáng yêu."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "树上有三___小鸟在唱歌。",
      "options": ["只", "条", "本", "张"],
      "answer": "只",
      "explain": "Chim chóc (鸟) và động vật nhỏ dùng lượng từ ''只''."
    }
  ]'::jsonb,
  1
),
(
  2, 10, 'Bài 10: Đừng xem tivi nữa, ngày mai còn phải thi (别看了，明天还要考试呢)',
  '双', 'shuāng', 'đôi',
  'Dùng cho các đồ vật tự nhiên đi liền theo cặp/đôi (đôi đũa, đôi giày, đôi tất, đôi mắt).',
  '[
    {"noun": "鞋", "pinyin": "xié", "phrase": "一双鞋", "meaning": "một đôi giày"},
    {"noun": "筷子", "pinyin": "kuàizi", "phrase": "一双筷子", "meaning": "một đôi đũa"},
    {"noun": "袜子", "pinyin": "wàzi", "phrase": "一双袜子", "meaning": "một đôi tất"},
    {"noun": "手", "pinyin": "shǒu", "phrase": "一双手", "meaning": "một đôi bàn tay"}
  ]'::jsonb,
  '[
    {"hanzi": "我想买一双舒服的运动鞋。", "pinyin": "Wǒ xiǎng mǎi yì shuāng shūfu de yùndòngxié.", "meaning": "Tôi muốn mua một đôi giày thể thao thoải mái."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "中国人吃饭一般用一___筷子。",
      "options": ["双", "只", "件", "张"],
      "answer": "双",
      "explain": "Đũa (筷子) đi thành đôi dùng lượng từ ''双''."
    }
  ]'::jsonb,
  2
);

-- HSK 2 - Bài 12: Bạn đã từng đi Bắc Kinh chưa? (Lượng từ: 次)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  2, 12, 'Bài 12: Bạn đã từng đi Bắc Kinh chưa? (你去过北京吗)',
  '次', 'cì', 'lần, lượt (động lượng từ)',
  'Động lượng từ chỉ số lần phát sinh hành động. Đứng sau động từ hoặc tân ngữ.',
  '[
    {"noun": "次", "pinyin": "cì", "phrase": "一次", "meaning": "một lần"},
    {"noun": "次", "pinyin": "cì", "phrase": "去过两次", "meaning": "từng đi hai lần"},
    {"noun": "次", "pinyin": "cì", "phrase": "第一次", "meaning": "lần đầu tiên"}
  ]'::jsonb,
  '[
    {"hanzi": "我去过一次中国旅游。", "pinyin": "Wǒ qù guo yí cì Zhōngguó lǚyóu.", "meaning": "Tôi từng đi du lịch Trung Quốc một lần."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "这是我第一___来中国。",
      "options": ["次", "个", "本", "张"],
      "answer": "次",
      "explain": "Chỉ số lần thực hiện hành vi dùng ''次'' (第一次: lần đầu tiên)."
    }
  ]'::jsonb,
  1
);

-- ==========================================
-- HSK 3
-- ==========================================

-- HSK 3 - Bài 1: Cuối tuần bạn có kế hoạch gì? (Lượng từ: 把, 辆)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  3, 1, 'Bài 1: Cuối tuần bạn có kế hoạch gì? (周末你有什么打算)',
  '把', 'bǎ', 'chiếc, cây, nắm',
  'Dùng cho các đồ vật có tay cầm, cán nắm hoặc có thể cầm nắm bằng tay (ô/dù, ghế dựa, dao, kéo, chìa khóa, quạt).',
  '[
    {"noun": "雨伞", "pinyin": "yǔsǎn", "phrase": "一把雨伞", "meaning": "một cây dù / ô"},
    {"noun": "椅子", "pinyin": "yǐzi", "phrase": "一把椅子", "meaning": "một chiếc ghế dựa"},
    {"noun": "钥匙", "pinyin": "yàoshi", "phrase": "一把钥匙", "meaning": "một chiếc chìa khóa"},
    {"noun": "刀", "pinyin": "dāo", "phrase": "一把刀", "meaning": "một con dao"}
  ]'::jsonb,
  '[
    {"hanzi": "外面下雨了，带上一把雨伞吧。", "pinyin": "Wàimiàn xiàyǔ le, dài shàng yì bǎ yǔsǎn ba.", "meaning": "Bên ngoài trời mưa rồi, mang theo một cây dù đi."},
    {"hanzi": "房间里只有两把椅子。", "pinyin": "Fángjiān lǐ zhǐyǒu liǎng bǎ yǐzi.", "meaning": "Trong phòng chỉ có hai chiếc ghế."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "外面下大雨了，你带上一___伞吧。",
      "options": ["把", "张", "条", "件"],
      "answer": "把",
      "explain": "Cây dù/ô (伞) có cán cầm nên dùng lượng từ ''把''."
    },
    {
      "type": "choice",
      "question": "请帮我搬一___椅子过来。",
      "options": ["把", "条", "只", "本"],
      "answer": "把",
      "explain": "Ghế (椅子) có chỗ dựa/tay vịn dùng lượng từ ''把''."
    }
  ]'::jsonb,
  1
),
(
  3, 1, 'Bài 1: Cuối tuần bạn có kế hoạch gì? (周末你有什么打算)',
  '辆', 'liàng', 'chiếc (xe)',
  'Dùng chuyên cho các loại phương tiện giao thông đường bộ có bánh xe (ô tô, xe đạp, xe máy, xe buýt).',
  '[
    {"noun": "车", "pinyin": "chē", "phrase": "一辆车", "meaning": "một chiếc xe"},
    {"noun": "自行车", "pinyin": "zìxíngchē", "phrase": "一辆自行车", "meaning": "một chiếc xe đạp"},
    {"noun": "出租车", "pinyin": "chūzūchē", "phrase": "一辆出租车", "meaning": "một chiếc xe taxi"},
    {"noun": "公共汽车", "pinyin": "gōnggòng qìchē", "phrase": "一辆公共汽车", "meaning": "một chiếc xe buýt"}
  ]'::jsonb,
  '[
    {"hanzi": "他买了一辆新自行车。", "pinyin": "Tā mǎi le yí liàng xīn zìxíngchē.", "meaning": "Anh ấy đã mua một chiếc xe đạp mới."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "校门口停着一___新汽车。",
      "options": ["辆", "把", "张", "本"],
      "answer": "辆",
      "explain": "Xe cộ có bánh xe (汽车) dùng lượng từ ''辆''."
    }
  ]'::jsonb,
  2
);

-- HSK 3 - Bài 4: Cô ấy luôn cười khi nói chuyện (Lượng từ: 位)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  3, 4, 'Bài 4: Cô ấy luôn cười khi nói chuyện (她总是笑着跟客人说话)',
  '位', 'wèi', 'vị, ngài',
  'Cách dùng lịch sự, trang trọng để chỉ người (thay thế cho ''个''). Thường dùng cho thầy cô, khách hàng, bác sĩ, giáo sư.',
  '[
    {"noun": "老师", "pinyin": "lǎoshī", "phrase": "一位老师", "meaning": "một vị thầy cô giáo"},
    {"noun": "客人", "pinyin": "kèrén", "phrase": "两位客人", "meaning": "hai vị khách"},
    {"noun": "医生", "pinyin": "yīshēng", "phrase": "一位医生", "meaning": "một vị bác sĩ"},
    {"noun": "先生", "pinyin": "xiānsheng", "phrase": "哪一位先生", "meaning": "vị tiên sinh nào"}
  ]'::jsonb,
  '[
    {"hanzi": "请问您找哪一位？", "pinyin": "Qǐngwèn nín zhǎo nǎ yí wèi?", "meaning": "Xin hỏi ngài tìm vị nào ạ?"},
    {"hanzi": "张老师是一位非常优秀的老师。", "pinyin": "Zhāng lǎoshī shì yí wèi fēicháng yōuxiù de lǎoshī.", "meaning": "Thầy Trương là một vị giáo viên vô cùng ưu tú."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "门口有两___客人想找经理。",
      "options": ["位", "把", "条", "本"],
      "answer": "位",
      "explain": "Chỉ người trang trọng lịch sự như khách (客人) dùng lượng từ ''位''."
    }
  ]'::jsonb,
  1
);

-- HSK 3 - Bài 7: Tôi không mang theo tiền (Lượng từ: 瓶, 种)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  3, 7, 'Bài 7: Tôi không mang theo ví tiền (我跟我最好的朋友一起去)',
  '瓶', 'píng', 'chai, bình, lọ',
  'Lượng từ dung tích dùng cho chất lỏng đóng chai/bình (nước suối, bia, nước ngọt, sữa).',
  '[
    {"noun": "水", "pinyin": "shuǐ", "phrase": "一瓶水", "meaning": "một chai nước"},
    {"noun": "可乐", "pinyin": "kělè", "phrase": "两瓶可乐", "meaning": "hai chai coca"},
    {"noun": "啤酒", "pinyin": "píjiǔ", "phrase": "一瓶啤酒", "meaning": "một chai bia"},
    {"noun": "牛奶", "pinyin": "niúnǎi", "phrase": "一瓶牛奶", "meaning": "một chai sữa"}
  ]'::jsonb,
  '[
    {"hanzi": "我口渴了，想买一瓶水。", "pinyin": "Wǒ kǒukě le, xiǎng mǎi yì píng shuǐ.", "meaning": "Tôi khát nước rồi, muốn mua một chai nước."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "请给我来一___矿泉水。",
      "options": ["瓶", "把", "张", "条"],
      "answer": "瓶",
      "explain": "Nước khoáng đóng chai (矿泉水) dùng lượng từ ''瓶''."
    }
  ]'::jsonb,
  1
),
(
  3, 7, 'Bài 7: Tôi không mang theo ví tiền (我跟我最好的朋友一起去)',
  '种', 'zhǒng', 'loại, thứ, giống',
  'Dùng để chỉ chủng loại, phân loại sự vật, ngôn ngữ, cảm xúc hoặc động thực vật.',
  '[
    {"noun": "人", "pinyin": "rén", "phrase": "这种人", "meaning": "loại người này"},
    {"noun": "水果", "pinyin": "shuǐguǒ", "phrase": "好几种水果", "meaning": "mấy loại trái cây"},
    {"noun": "颜色", "pinyin": "yánsè", "phrase": "两种颜色", "meaning": "hai loại màu sắc"},
    {"noun": "动物", "pinyin": "dòngwù", "phrase": "一种动物", "meaning": "một loài động vật"}
  ]'::jsonb,
  '[
    {"hanzi": "超市里有许多种新鲜水果。", "pinyin": "Chāoshì lǐ yǒu xǔduō zhǒng xīnxiān shuǐguǒ.", "meaning": "Trong siêu thị có rất nhiều loại hoa quả tươi."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "这种苹果和那___苹果有什么不同？",
      "options": ["种", "本", "张", "辆"],
      "answer": "种",
      "explain": "Chỉ chủng loại (loại táo này, loại táo kia) dùng ''种''."
    }
  ]'::jsonb,
  2
);

-- HSK 3 - Bài 10: Toán khó hơn lịch sử nhiều (Lượng từ: 家, 封)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  3, 10, 'Bài 10: Toán khó hơn lịch sử nhiều (数学比历史难多了)',
  '家', 'jiā', 'nhà, tiệm, quán, công ty',
  'Dùng cho các địa điểm cơ sở kinh doanh, doanh nghiệp, dịch vụ thương mại (quán ăn, công ty, siêu thị, bệnh viện, khách sạn).',
  '[
    {"noun": "饭馆", "pinyin": "fànguǎn", "phrase": "一家饭馆", "meaning": "một quán ăn"},
    {"noun": "公司", "pinyin": "gōngsī", "phrase": "一家公司", "meaning": "một công ty"},
    {"noun": "超市", "pinyin": "chāoshì", "phrase": "一家超市", "meaning": "một siêu thị"},
    {"noun": "医院", "pinyin": "yīyuàn", "phrase": "一家医院", "meaning": "một bệnh viện"},
    {"noun": "银行", "pinyin": "yínháng", "phrase": "一家银行", "meaning": "một ngân hàng"}
  ]'::jsonb,
  '[
    {"hanzi": "我家附近新开了一家中国饭馆。", "pinyin": "Wǒ jiā fùjìn xīn kāi le yì jiā Zhōngguó fànguǎn.", "meaning": "Gần nhà tôi mới mở một quán ăn Trung Quốc."},
    {"hanzi": "他在一家大公司工作。", "pinyin": "Tā zài yì jiā dà gōngsī gōngzuò.", "meaning": "Anh ấy làm việc ở một công ty lớn."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "学校附近有一___很大的超市。",
      "options": ["家", "只", "张", "条"],
      "answer": "家",
      "explain": "Cửa hàng/siêu thị (超市) dùng lượng từ ''家''."
    }
  ]'::jsonb,
  1
),
(
  3, 10, 'Bài 10: Toán khó hơn lịch sử nhiều (数学比历史难多了)',
  '封', 'fēng', 'bức, lá (thư)',
  'Dùng cho thư từ, bưu thiếp, email được niêm phong hoặc đóng phong bì.',
  '[
    {"noun": "信", "pinyin": "xìn", "phrase": "一封信", "meaning": "một bức thư"},
    {"noun": "电子邮件", "pinyin": "diànzǐ yóujiàn", "phrase": "一封电子邮件", "meaning": "một bức thư điện tử (email)"}
  ]'::jsonb,
  '[
    {"hanzi": "我昨天收到了朋友的一封信。", "pinyin": "Wǒ zuótiān shōudào le péngyou de yì fēng xìn.", "meaning": "Hôm qua tôi đã nhận được một bức thư của bạn bè."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "我给老师写了一___电子邮件。",
      "options": ["封", "本", "张", "把"],
      "answer": "封",
      "explain": "Thư tín/email (信 / 电子邮件) dùng lượng từ ''封''."
    }
  ]'::jsonb,
  2
);

-- HSK 3 - Bài 14: Bạn có mang theo ô không (Lượng từ: 段)
INSERT INTO classifiers (hsk_level, lesson_num, lesson_title, hanzi, pinyin, meaning, usage_note, collocations, examples, exercises, order_index)
VALUES (
  3, 14, 'Bài 14: Bạn có mang theo ô không (你看过那个电影没有)',
  '段', 'duàn', 'đoạn, khúc, quãng',
  'Dùng cho một quãng thời gian, một đoạn đường, một đoạn văn bản hoặc trích đoạn âm nhạc/video.',
  '[
    {"noun": "时间", "pinyin": "shíjiān", "phrase": "一段时间", "meaning": "một khoảng thời gian"},
    {"noun": "路", "pinyin": "lù", "phrase": "一段路", "meaning": "một đoạn đường"},
    {"noun": "话", "pinyin": "huà", "phrase": "一段话", "meaning": "một đoạn lời nói/văn"},
    {"noun": "历史", "pinyin": "lìshǐ", "phrase": "一段历史", "meaning": "một giai đoạn lịch sử"}
  ]'::jsonb,
  '[
    {"hanzi": "这一段时间他一直很忙。", "pinyin": "Zhè yí duàn shíjiān tā yìzhí hěn máng.", "meaning": "Khoảng thời gian này anh ấy luôn rất bận rộn."}
  ]'::jsonb,
  '[
    {
      "type": "choice",
      "question": "走完这___路就到家了。",
      "options": ["段", "本", "只", "把"],
      "answer": "段",
      "explain": "Đoạn đường (路) dùng lượng từ ''段'' (一段路)."
    }
  ]'::jsonb,
  1
);
