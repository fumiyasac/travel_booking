import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  await prisma.booking.deleteMany();
  await prisma.review.deleteMany();
  await prisma.itineraryActivity.deleteMany();
  await prisma.itineraryDay.deleteMany();
  await prisma.includedItem.deleteMany();
  await prisma.excludedItem.deleteMany();
  await prisma.travelPlanHighlight.deleteMany();
  await prisma.travelPlanImage.deleteMany();
  await prisma.travelPlan.deleteMany();

  // 1. Tokyo Explorer
  const tokyo = await prisma.travelPlan.create({
    data: {
      title: '東京エクスプローラー5日間',
      description:
        '世界最大の都市・東京を5日間で徹底探訪。皇居から渋谷スクランブル交差点、浅草の下町文化、最先端のお台場まで、東京の多彩な顔を体験します。ミシュラン星付きレストランでの食事体験や、築地場外市場での朝食ツアーも含まれる贅沢なプランです。',
      destination: '東京',
      country: '日本',
      region: 'アジア',
      latitude: 35.6762,
      longitude: 139.6503,
      price: 150000,
      discountPrice: 135000,
      durationDays: 5,
      maxParticipants: 12,
      currentBookings: 4,
      category: 'city',
      difficulty: 'easy',
      rating: 4.7,
      reviewCount: 128,
      isAvailable: true,
      language: '日本語・英語',
      meetingPoint: '新宿駅南口 集合場所：NewoMan前',
      cancellationPolicy:
        '出発7日前まで：全額返金\n出発3〜6日前：50%返金\n出発2日前以降：返金不可\nキャンセルはメールにてご連絡ください。',
      minimumAge: null,
      tags: '["東京","都市観光","グルメ","歴史","ショッピング","夜景"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800', caption: '東京スカイラインの夜景', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800', caption: '浅草寺と東京スカイツリー', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1513407030348-c983a97b98d8?w=800', caption: '渋谷スクランブル交差点', isPrimary: false, displayOrder: 2 },
          { url: 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?w=800', caption: '新宿の賑わい', isPrimary: false, displayOrder: 3 },
        ],
      },
      highlights: {
        create: [
          { text: '築地場外市場での本格的な朝食体験' },
          { text: '皇居東御苑の特別ガイドツアー' },
          { text: '渋谷・原宿のポップカルチャー探索' },
          { text: 'ミシュランビブグルマン認定店でのディナー' },
          { text: '浅草・上野の下町文化体験' },
        ],
      },
      itinerary: {
        create: [
          {
            dayNumber: 1, title: '到着・新宿・歌舞伎町探索',
            description: '新宿に到着後、ホテルにチェックイン。夕方から歌舞伎町の賑わいと、新宿御苑近くのクラフトビアバーで地元の雰囲気を体験します。',
            accommodation: '新宿 ハイアットリージェンシー東京', meals: 'dinner',
            activities: {
              create: [
                { name: '新宿御苑散策', startTime: '15:00', duration: '1.5時間', description: '広大な日本庭園を散策', location: '新宿御苑' },
                { name: '歌舞伎町ナイトウォーク', startTime: '18:00', duration: '2時間', description: '東洋最大の歓楽街を専門ガイドと探索', location: '歌舞伎町' },
                { name: 'ウェルカムディナー', startTime: '20:00', duration: '1.5時間', description: '地元の居酒屋での歓迎夕食会', location: '新宿' },
              ],
            },
          },
          {
            dayNumber: 2, title: '築地・皇居・丸の内',
            description: '早朝の築地場外市場から一日がスタート。新鮮な海鮮を楽しんだ後、皇居東御苑を見学し、丸の内の近代建築を巡ります。',
            accommodation: '新宿 ハイアットリージェンシー東京', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: '築地場外市場朝食ツアー', startTime: '07:00', duration: '2時間', description: '新鮮な海鮮丼とお寿司を楽しむ朝食ツアー', location: '築地市場' },
                { name: '皇居東御苑見学', startTime: '10:00', duration: '2時間', description: '特別ガイド付きで皇居内を見学', location: '皇居東御苑' },
                { name: '丸の内建築散策', startTime: '13:00', duration: '1.5時間', description: '明治〜現代の建築が混在する丸の内エリアを散策', location: '丸の内' },
              ],
            },
          },
          {
            dayNumber: 3, title: '浅草・上野・秋葉原',
            description: '下町文化の拠点・浅草から出発。浅草寺参拝後、上野の博物館を訪問。午後は電気街秋葉原でサブカルチャーを探索します。',
            accommodation: '新宿 ハイアットリージェンシー東京', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: '浅草寺・仲見世通り', startTime: '09:00', duration: '2時間', description: '東京最古のお寺と門前町の老舗店を巡る', location: '浅草寺' },
                { name: '東京国立博物館', startTime: '11:30', duration: '2時間', description: '国宝や重要文化財が展示される日本最大の博物館', location: '上野公園' },
                { name: '秋葉原サブカルチャー探索', startTime: '14:30', duration: '2.5時間', description: 'アニメ・ゲーム・電子機器の聖地を探索', location: '秋葉原' },
              ],
            },
          },
          {
            dayNumber: 4, title: '渋谷・原宿・表参道',
            description: '若者文化の発信地・渋谷スクランブル交差点から出発。竹下通りでポップカルチャーを体験し、高級ブランドが並ぶ表参道を散策します。',
            accommodation: '新宿 ハイアットリージェンシー東京', meals: 'breakfast',
            activities: {
              create: [
                { name: '渋谷スクランブル交差点体験', startTime: '09:00', duration: '1時間', description: '世界で最も有名な交差点でラッシュを体験', location: '渋谷駅前' },
                { name: '原宿・竹下通り', startTime: '10:30', duration: '1.5時間', description: 'ハラジュク文化とクレープを楽しむ', location: '竹下通り' },
                { name: '表参道・青山散策', startTime: '13:00', duration: '2時間', description: '高級ブランドとデザイナーショップが並ぶ通りを散策', location: '表参道' },
                { name: '代官山蔦屋書店', startTime: '15:30', duration: '1時間', description: '世界最美の書店の一つでゆったり過ごす', location: '代官山' },
              ],
            },
          },
          {
            dayNumber: 5, title: 'お台場・六本木・帰途',
            description: '近未来的なお台場を巡り、最先端のテクノロジーとショッピングを楽しみます。六本木ヒルズから東京の絶景を眺めた後、帰途につきます。',
            accommodation: null, meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'お台場散策', startTime: '09:00', duration: '2時間', description: '自由の女神像とレインボーブリッジを眺めながら散策', location: 'お台場海浜公園' },
                { name: 'チームラボボーダレス体験', startTime: '11:00', duration: '2時間', description: '世界的なデジタルアート美術館で非日常体験', location: 'お台場' },
                { name: '六本木ヒルズ展望台', startTime: '15:00', duration: '1.5時間', description: '東京タワーを望む最高の展望台でサヨナラ', location: '六本木ヒルズ' },
              ],
            },
          },
        ],
      },
      includedItems: {
        create: [
          { item: '専任日本語・英語ガイド（全日程）' },
          { item: '築地場外市場朝食ツアー（2日目）' },
          { item: '皇居東御苑入場料' },
          { item: '東京国立博物館入場料' },
          { item: 'チームラボボーダレス入場料' },
          { item: '六本木ヒルズ展望台入場料' },
          { item: 'ウェルカムディナー（1日目）' },
        ],
      },
      excludedItems: {
        create: [
          { item: '往復交通費（飛行機・新幹線等）' },
          { item: '宿泊費（別途手配可能）' },
          { item: '個人的な飲食費' },
          { item: '旅行保険' },
        ],
      },
      reviews: {
        create: [
          { reviewerName: '田中 美咲', rating: 5.0, comment: '築地の朝食体験が最高でした！ガイドの方もとても親切で、隠れた名店まで案内してくれました。東京の新しい魅力を発見できた旅でした。', travelDate: new Date('2024-03-15') },
          { reviewerName: 'Sarah Johnson', rating: 4.5, comment: 'Amazing tour! The guide was knowledgeable and the itinerary was perfectly balanced between traditional and modern Tokyo. The TeamLab experience was unforgettable.', travelDate: new Date('2024-02-20') },
          { reviewerName: '鈴木 健太', rating: 4.8, comment: '浅草から渋谷まで東京の全てを体験できた感じ。チームラボは子供も大喜びでした。次回もぜひ利用したいです。', travelDate: new Date('2024-04-10') },
          { reviewerName: '李 明', rating: 4.6, comment: '行程が充実していて、短期間で東京の魅力を全て体験できました。ガイドの日本語説明も分かりやすかったです。', travelDate: new Date('2024-01-05') },
        ],
      },
    },
  });

  // 2. Kyoto Traditional Culture
  const kyoto = await prisma.travelPlan.create({
    data: {
      title: '京都伝統文化探訪4日間',
      description:
        '千年の都・京都で日本の伝統文化を深く体験する4日間。金閣寺・銀閣寺・嵐山竹林など定番スポットはもちろん、舞妓さんとのお茶体験、清水焼の絵付け体験、早朝の祇園散策など、京都の真髄に触れる特別なプランです。',
      destination: '京都',
      country: '日本',
      region: 'アジア',
      latitude: 35.0116,
      longitude: 135.7681,
      price: 120000,
      discountPrice: null,
      durationDays: 4,
      maxParticipants: 10,
      currentBookings: 7,
      category: 'cultural',
      difficulty: 'easy',
      rating: 4.9,
      reviewCount: 215,
      isAvailable: true,
      language: '日本語・英語',
      meetingPoint: '京都駅八条口 新幹線改札付近',
      cancellationPolicy: '出発14日前まで：全額返金\n出発7〜13日前：70%返金\n出発3〜6日前：30%返金\n出発2日前以降：返金不可',
      minimumAge: null,
      tags: '["京都","寺社仏閣","茶道","舞妓","伝統文化","着物"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=800', caption: '金閣寺の黄金の輝き', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=800', caption: '嵐山の竹林小径', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800', caption: '祇園の石畳と舞妓', isPrimary: false, displayOrder: 2 },
          { url: 'https://images.unsplash.com/photo-1553356084-58ef4a67b2a7?w=800', caption: '清水寺と京都の街並み', isPrimary: false, displayOrder: 3 },
        ],
      },
      highlights: {
        create: [
          { text: '舞妓さんとの本格的なお点前・お茶体験' },
          { text: '早朝6時からの祇園・花見小路特別散策' },
          { text: '清水焼絵付け体験（お土産持ち帰り可）' },
          { text: '非公開の茶室での抹茶体験' },
          { text: '着物レンタルで嵐山散策' },
        ],
      },
      itinerary: {
        create: [
          {
            dayNumber: 1, title: '到着・祇園・先斗町',
            description: '京都駅到着後、荷物を預けて早速観光スタート。夕方の祇園を散策し、先斗町でかにかくに詠まれた料理屋でウェルカムディナーを楽しみます。',
            accommodation: '祇園 料理旅館 西村', meals: 'dinner',
            activities: {
              create: [
                { name: '祇園散策', startTime: '15:00', duration: '2時間', description: '石畳の花見小路を歩き、運が良ければ舞妓さんに出会えるかも', location: '祇園' },
                { name: '先斗町ウェルカムディナー', startTime: '18:30', duration: '2時間', description: '鴨川沿いの料亭で京料理のフルコース', location: '先斗町' },
              ],
            },
          },
          {
            dayNumber: 2, title: '早朝祇園・金閣寺・龍安寺',
            description: '早朝6時から人気観光客が少ない時間帯に祇園を特別散策。その後、金閣寺・龍安寺を訪問し、京都の寺社文化を深く学びます。',
            accommodation: '祇園 料理旅館 西村', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: '早朝祇園特別散策', startTime: '06:00', duration: '1.5時間', description: '静寂の中、朝日に輝く石畳を歩く幻想的な体験', location: '花見小路' },
                { name: '金閣寺見学', startTime: '09:00', duration: '1.5時間', description: '黄金に輝く三層の楼閣を堪能', location: '金閣寺' },
                { name: '龍安寺石庭瞑想', startTime: '11:00', duration: '1時間', description: '世界的に有名な枯山水庭園で心を静める', location: '龍安寺' },
                { name: '舞妓お点前体験', startTime: '14:00', duration: '2時間', description: '現役の舞妓さんからお茶の作法を教わる特別体験', location: '祇園の茶室' },
              ],
            },
          },
          {
            dayNumber: 3, title: '嵐山・清水寺・清水焼体験',
            description: '着物をレンタルして嵐山の竹林を散策。天龍寺庭園見学後、渡月橋でランチ。午後は清水寺から清水坂を下りながら清水焼の絵付け体験を楽しみます。',
            accommodation: '祇園 料理旅館 西村', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: '着物レンタル・嵐山竹林散策', startTime: '09:00', duration: '3時間', description: '着物を着て嵐山の竹林を歩く京都らしい体験', location: '嵐山竹林' },
                { name: '天龍寺庭園', startTime: '10:30', duration: '1時間', description: '世界遺産の禅寺庭園を見学', location: '天龍寺' },
                { name: '清水寺参拝', startTime: '14:00', duration: '1.5時間', description: '清水の舞台からの京都の眺望を楽しむ', location: '清水寺' },
                { name: '清水焼絵付け体験', startTime: '16:00', duration: '1.5時間', description: '伝統工芸・清水焼の絵付けを職人に教わる', location: '清水坂' },
              ],
            },
          },
          {
            dayNumber: 4, title: '銀閣寺・哲学の道・出発',
            description: '哲学の道を歩きながら銀閣寺へ。桜の名所として名高い哲学の道でのんびり散策後、京都駅に戻り帰途につきます。',
            accommodation: null, meals: 'breakfast',
            activities: {
              create: [
                { name: '哲学の道散策', startTime: '09:00', duration: '1.5時間', description: '疏水沿いの小道を哲学者のようにゆっくり歩く', location: '哲学の道' },
                { name: '銀閣寺見学', startTime: '10:30', duration: '1.5時間', description: '侘び寂びの美を体現する世界遺産の禅寺', location: '銀閣寺' },
                { name: '錦市場散策・お土産購入', startTime: '13:00', duration: '1.5時間', description: '京都の台所・錦市場で食べ歩きとお土産探し', location: '錦市場' },
              ],
            },
          },
        ],
      },
      includedItems: {
        create: [
          { item: '専任ガイド（全日程）' },
          { item: '舞妓さんとのお茶体験' },
          { item: '清水焼絵付け体験（焼成・送付込み）' },
          { item: '着物レンタル（3日目）' },
          { item: '各寺社入場料（金閣寺・龍安寺・天龍寺・清水寺・銀閣寺）' },
          { item: 'ウェルカムディナー（1日目）' },
          { item: '毎朝の朝食' },
        ],
      },
      excludedItems: {
        create: [
          { item: '往復交通費' },
          { item: '宿泊費（別途手配可能）' },
          { item: '個人的な飲食費・お土産代' },
          { item: '旅行保険' },
          { item: '着物クリーニング費（汚損の場合）' },
        ],
      },
      reviews: {
        create: [
          { reviewerName: '山田 花子', rating: 5.0, comment: '舞妓さんとのお茶体験は一生の思い出になりました。ガイドさんの知識が素晴らしく、教科書では分からない京都の魅力を教えてもらいました。', travelDate: new Date('2024-04-05') },
          { reviewerName: 'Emma Williams', rating: 4.9, comment: 'This was my third visit to Kyoto but the first time I truly understood the depth of its culture. The early morning Gion walk was magical.', travelDate: new Date('2024-03-22') },
          { reviewerName: '朴 智恩', rating: 4.8, comment: '기모노를 입고 대나무 숲을 걷는 경험이 정말 특별했어요. 가이드분이 너무 친절하게 설명해주셔서 교토를 더 깊이 이해할 수 있었습니다.', travelDate: new Date('2024-02-14') },
        ],
      },
    },
  });

  // 3. Hokkaido Nature Adventure
  const hokkaido = await prisma.travelPlan.create({
    data: {
      title: '北海道大自然アドベンチャー7日間',
      description:
        '日本最北の大地・北海道で雄大な自然を満喫する7日間。知床半島のヒグマウォッチング、函館山からの夜景、富良野のラベンダー畑（季節限定）、洞爺湖でのカヌー体験など、北海道でしか体験できないアクティビティが盛りだくさんのアドベンチャープランです。',
      destination: '北海道（札幌・富良野・知床・函館）',
      country: '日本',
      region: 'アジア',
      latitude: 43.0621,
      longitude: 141.3544,
      price: 200000,
      discountPrice: 180000,
      durationDays: 7,
      maxParticipants: 8,
      currentBookings: 2,
      category: 'nature',
      difficulty: 'moderate',
      rating: 4.8,
      reviewCount: 89,
      isAvailable: true,
      language: '日本語',
      meetingPoint: '新千歳空港 国内線到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発14〜20日前：80%返金\n出発7〜13日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: 10,
      tags: '["北海道","自然","ヒグマ","ラベンダー","知床","函館","カヌー"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1578469645742-46cae010e5d4?w=800', caption: '知床半島の原生林', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800', caption: '富良野のラベンダー畑', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1542086490-a3ae99dba2ab?w=800', caption: '函館山からの夜景', isPrimary: false, displayOrder: 2 },
          { url: 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800', caption: '洞爺湖の静寂な朝', isPrimary: false, displayOrder: 3 },
        ],
      },
      highlights: {
        create: [
          { text: '知床半島でのヒグマ・エゾシカウォッチング' },
          { text: '富良野ファーム富田でラベンダー摘み取り体験（7-8月限定）' },
          { text: '函館山ロープウェイで世界三大夜景を鑑賞' },
          { text: '洞爺湖でのカナディアンカヌー体験' },
          { text: '地元漁師と共に行く新鮮な海鮮体験' },
        ],
      },
      itinerary: {
        create: [
          {
            dayNumber: 1, title: '新千歳空港到着・札幌市内観光',
            description: '新千歳空港に到着後、世界最大級のジンギスカンを楽しみ、札幌の夜をすすきのエリアで堪能します。',
            accommodation: '札幌 JRタワーホテル日航札幌', meals: 'dinner',
            activities: {
              create: [
                { name: '北海道神宮参拝', startTime: '14:00', duration: '1時間', description: '北海道の総鎮守で旅の安全を祈願', location: '円山' },
                { name: '大倉山ジャンプ台展望台', startTime: '15:30', duration: '1時間', description: '冬季五輪の舞台からの絶景', location: '大倉山' },
                { name: '本場ジンギスカンディナー', startTime: '18:00', duration: '2時間', description: '北海道のソウルフード・ジンギスカンを本場で堪能', location: 'すすきの' },
              ],
            },
          },
          {
            dayNumber: 2, title: '富良野・美瑛・ファーム富田',
            description: 'ラベンダーの丘が広がる富良野へ。ファーム富田でラベンダー摘み体験（7-8月）や花畑散策を楽しみ、美瑛の丘陵地帯を走るドライブを満喫します。',
            accommodation: '富良野 ニングルテラス', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'ファーム富田ラベンダー摘み', startTime: '10:00', duration: '2時間', description: '一面のラベンダー畑でアロマ体験（7-8月のみ）', location: 'ファーム富田' },
                { name: '美瑛の丘ドライブ', startTime: '13:00', duration: '2時間', description: 'CMでも有名なパッチワークの丘を車窓から楽しむ', location: '美瑛町' },
                { name: '青い池', startTime: '15:30', duration: '1時間', description: 'SNSで話題の神秘的なコバルトブルーの池', location: '美瑛町' },
              ],
            },
          },
          {
            dayNumber: 3, title: '洞爺湖・カヌー体験',
            description: '洞爺湖に到着後、カナディアンカヌーで湖上からの北海道の原風景を堪能。夕方は洞爺湖温泉で疲れを癒します。',
            accommodation: '洞爺湖万世閣ホテルレイクサイドテラス', meals: 'breakfast,lunch,dinner',
            activities: {
              create: [
                { name: '洞爺湖カナディアンカヌー', startTime: '10:00', duration: '2時間', description: 'インストラクター指導のもとカヌー体験', location: '洞爺湖' },
                { name: '昭和新山見学', startTime: '13:00', duration: '1時間', description: '有珠山噴火で突如出現した活火山を見学', location: '壮瞥町' },
                { name: '洞爺湖温泉入浴', startTime: '17:00', duration: '1.5時間', description: '湖畔の温泉で旅の疲れを癒す', location: '洞爺湖温泉街' },
              ],
            },
          },
          {
            dayNumber: 4, title: '函館・函館山夜景・朝市',
            description: '函館に移動。夕方に函館山からの世界三大夜景を鑑賞し、翌朝は函館朝市で新鮮な海鮮丼を楽しみます。',
            accommodation: '函館 ラビスタ函館ベイ', meals: 'breakfast,dinner',
            activities: {
              create: [
                { name: '五稜郭公園散策', startTime: '14:00', duration: '1.5時間', description: '日本唯一の星形要塞と五稜郭タワー', location: '五稜郭' },
                { name: '函館山夜景鑑賞', startTime: '19:00', duration: '1.5時間', description: 'ロープウェイで山頂へ。世界三大夜景の一つ', location: '函館山' },
              ],
            },
          },
          {
            dayNumber: 5, title: '函館朝市・知床への移動',
            description: '早朝の函館朝市で海鮮丼を楽しんだ後、知床半島へ移動。ウトロ温泉に宿泊し、明日のヒグマウォッチングに備えます。',
            accommodation: '知床 北こぶし知床ホテル&リゾート', meals: 'breakfast,dinner',
            activities: {
              create: [
                { name: '函館朝市海鮮丼朝食', startTime: '06:30', duration: '1.5時間', description: '取れたての海鮮を使った朝市グルメを満喫', location: '函館朝市' },
                { name: '知床自然センター見学', startTime: '16:00', duration: '1時間', description: '翌日のウォッチングに向けて知床の生態系を学ぶ', location: '知床自然センター' },
              ],
            },
          },
          {
            dayNumber: 6, title: '知床半島ヒグマウォッチング',
            description: '世界自然遺産・知床半島でのハイライト。専門ガイドとともにヒグマ・エゾシカ・オジロワシなどの野生動物を観察します。',
            accommodation: '知床 北こぶし知床ホテル&リゾート', meals: 'breakfast,lunch,dinner',
            activities: {
              create: [
                { name: '知床五湖トレッキング', startTime: '08:00', duration: '3時間', description: '世界遺産の原生林をガイドとトレッキング', location: '知床五湖' },
                { name: 'ヒグマウォッチングクルーズ', startTime: '14:00', duration: '2時間', description: '海上から海岸で採食するヒグマを観察', location: 'ウトロ港' },
                { name: 'カムイワッカ湯の滝', startTime: '11:00', duration: '1.5時間', description: '滝を登りながら温泉を楽しむ秘境スポット', location: 'カムイワッカ' },
              ],
            },
          },
          {
            dayNumber: 7, title: '知床峠・新千歳空港・帰途',
            description: '絶景の知床横断道路を走り、羅臼側の眺望を楽しみながら新千歳空港へ。空港内で最後の北海道グルメをお楽しみください。',
            accommodation: null, meals: 'breakfast',
            activities: {
              create: [
                { name: '知床峠ドライブ', startTime: '08:00', duration: '2時間', description: '知床横断道路から国後島を望む絶景ドライブ', location: '知床峠' },
                { name: '新千歳空港フードコート', startTime: '15:00', duration: '1時間', description: '最後の北海道グルメ（ラーメン・スープカレー等）', location: '新千歳空港' },
              ],
            },
          },
        ],
      },
      includedItems: {
        create: [
          { item: '専任ガイド（全日程）' },
          { item: '知床ヒグマウォッチングクルーズ' },
          { item: '洞爺湖カナディアンカヌー体験' },
          { item: 'ファーム富田ラベンダー摘み取り体験' },
          { item: '函館山ロープウェイ往復' },
          { item: '知床五湖トレッキングガイド料' },
          { item: '全行程の移動バス代' },
          { item: '毎朝の朝食・一部のランチ・ディナー' },
        ],
      },
      excludedItems: {
        create: [
          { item: '往復航空券' },
          { item: '宿泊費（プランに含まれる場合を除く）' },
          { item: '個人的な飲食費・お土産代' },
          { item: '旅行保険' },
          { item: 'カムイワッカ湯の滝入山料' },
        ],
      },
      reviews: {
        create: [
          { reviewerName: '中村 大輔', rating: 5.0, comment: '知床でヒグマを間近で見られた時は感動で言葉が出ませんでした！ガイドさんの知識が豊富で、北海道の自然を隅々まで楽しめました。', travelDate: new Date('2024-07-20') },
          { reviewerName: 'Michael Chen', rating: 4.7, comment: 'The Shiretoko National Park experience was breathtaking. Seeing brown bears in their natural habitat was a once-in-a-lifetime experience.', travelDate: new Date('2024-08-05') },
          { reviewerName: '伊藤 由美子', rating: 4.9, comment: 'ラベンダー畑での摘み取り体験から函館の夜景まで、北海道の魅力が凝縮されたツアーでした。来年も参加したいです！', travelDate: new Date('2024-07-28') },
        ],
      },
    },
  });

  // 4. Paris Romance
  const paris = await prisma.travelPlan.create({
    data: {
      title: 'パリ・ロマンス＆カルチャー6日間',
      description:
        '光の都・パリで最高のロマンスと文化を体験する6日間。エッフェル塔のシャンパンクリック、ルーブル美術館の優先入場、ヴェルサイユ宮殿のプライベートツアー、セーヌ川ディナークルーズ、本場のマカロン作り教室まで、パリの全てを贅沢に楽しめるプレミアムプランです。',
      destination: 'パリ',
      country: 'フランス',
      region: 'ヨーロッパ',
      latitude: 48.8566,
      longitude: 2.3522,
      price: 280000,
      discountPrice: null,
      durationDays: 6,
      maxParticipants: 10,
      currentBookings: 6,
      category: 'leisure',
      difficulty: 'easy',
      rating: 4.8,
      reviewCount: 167,
      isAvailable: true,
      language: '日本語',
      meetingPoint: 'パリ シャルル・ド・ゴール空港 ターミナル2E 到着ホール',
      cancellationPolicy: '出発30日前まで：全額返金\n出発15〜29日前：70%返金\n出発7〜14日前：40%返金\n出発6日前以降：返金不可',
      minimumAge: null,
      tags: '["パリ","フランス","エッフェル塔","ルーブル","ヴェルサイユ","グルメ","美術"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800', caption: 'エッフェル塔の黄昏', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800', caption: 'セーヌ川とノートルダム大聖堂', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1522093007474-d86e9bf7ba6f?w=800', caption: 'ヴェルサイユ宮殿の庭園', isPrimary: false, displayOrder: 2 },
          { url: 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800', caption: 'モンマルトルの丘', isPrimary: false, displayOrder: 3 },
        ],
      },
      highlights: {
        create: [
          { text: 'エッフェル塔最上階への優先入場とシャンパントースト' },
          { text: 'ルーブル美術館のプライベート早朝ツアー（開館前入場）' },
          { text: 'ヴェルサイユ宮殿のプライベートガイドツアー' },
          { text: 'セーヌ川ディナークルーズ（ミシュランシェフ監修）' },
          { text: 'パリジャンのパン職人によるクロワッサン作り体験' },
        ],
      },
      itinerary: {
        create: [
          {
            dayNumber: 1, title: '到着・マレ地区散策',
            description: 'シャルル・ド・ゴール空港に到着後、ホテルへ。夕方はパリ最古の広場・ヴォージュ広場周辺のマレ地区を散策します。',
            accommodation: 'ル・マレ ブティックホテル（4星）', meals: 'dinner',
            activities: {
              create: [
                { name: 'マレ地区散策', startTime: '16:00', duration: '2時間', description: 'パリ最古のユダヤ人街とヴォージュ広場を探索', location: 'マレ地区' },
                { name: 'ビストロでのウェルカムディナー', startTime: '19:30', duration: '2時間', description: '地元パリジャンが愛するビストロで本場フランス料理', location: 'マレ地区' },
              ],
            },
          },
          {
            dayNumber: 2, title: 'ルーブル美術館・チュイルリー庭園・エッフェル塔',
            description: '開館前のルーブル美術館に特別入場。モナリザ・ヴィーナス・勝利の女神を貸し切り状態で鑑賞後、エッフェル塔の夕暮れをシャンパンで乾杯。',
            accommodation: 'ル・マレ ブティックホテル（4星）', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'ルーブル美術館プライベートツアー', startTime: '08:00', duration: '3時間', description: '開館前の貸し切り状態でモナリザを独占鑑賞', location: 'ルーブル美術館' },
                { name: 'チュイルリー庭園でのランチ', startTime: '12:00', duration: '1時間', description: 'フランス式庭園でピクニックランチ', location: 'チュイルリー庭園' },
                { name: 'エッフェル塔優先入場＆シャンパン', startTime: '18:30', duration: '2時間', description: '最上階からのパリの夕景をシャンパンで乾杯', location: 'エッフェル塔' },
              ],
            },
          },
          {
            dayNumber: 3, title: 'ヴェルサイユ宮殿プライベートツアー',
            description: '一日をかけてヴェルサイユ宮殿を訪問。鏡の間や王室礼拝堂をプライベートガイドと巡り、壮大なフランス式庭園を散策します。',
            accommodation: 'ル・マレ ブティックホテル（4星）', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'ヴェルサイユ宮殿プライベートツアー', startTime: '09:00', duration: '3時間', description: '鏡の間・王の間・王妃の寝室をガイドと見学', location: 'ヴェルサイユ宮殿' },
                { name: 'ヴェルサイユ庭園散策', startTime: '12:30', duration: '2時間', description: '17世紀のフランス式庭園で噴水ショーを鑑賞', location: 'ヴェルサイユ庭園' },
              ],
            },
          },
          {
            dayNumber: 4, title: 'モンマルトル・オペラ・セーヌ川クルーズ',
            description: '芸術家の丘・モンマルトルを散策。サクレ・クール大聖堂から街を一望後、夜はセーヌ川ディナークルーズでパリの夜景を楽しみます。',
            accommodation: 'ル・マレ ブティックホテル（4星）', meals: 'breakfast,dinner',
            activities: {
              create: [
                { name: 'モンマルトル散策', startTime: '10:00', duration: '2時間', description: 'ルノワール・ピカソが愛した芸術家の丘を散策', location: 'モンマルトル' },
                { name: 'サクレ・クール大聖堂', startTime: '11:00', duration: '1時間', description: 'パリを一望する白亜の大聖堂', location: 'モンマルトル' },
                { name: 'セーヌ川ディナークルーズ', startTime: '20:00', duration: '2.5時間', description: 'シェフのフルコースディナーとパリの夜景', location: 'セーヌ川' },
              ],
            },
          },
          {
            dayNumber: 5, title: 'マカロン作り・シャンゼリゼ・オルセー美術館',
            description: 'パリジャンのパティシエからマカロン作りを学ぶ。午後はオルセー美術館で印象派の名作に触れ、シャンゼリゼ通りでショッピングを楽しみます。',
            accommodation: 'ル・マレ ブティックホテル（4星）', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'マカロン＆クロワッサン作り体験', startTime: '09:00', duration: '2.5時間', description: 'パリの老舗パティスリーでの料理体験', location: 'サンジェルマン・デ・プレ' },
                { name: 'オルセー美術館', startTime: '14:00', duration: '2時間', description: 'モネ・ルノワール・ゴッホの傑作を鑑賞', location: 'オルセー美術館' },
                { name: 'シャンゼリゼ通り散策', startTime: '17:00', duration: '1.5時間', description: '世界一美しい通りでのウィンドウショッピング', location: 'シャンゼリゼ大通り' },
              ],
            },
          },
          {
            dayNumber: 6, title: 'ノートルダム大聖堂・出発',
            description: '修復中のノートルダム大聖堂外観を見学後、サンジェルマン・デ・プレカフェでパリ最後の朝食を楽しみ、帰途につきます。',
            accommodation: null, meals: 'breakfast',
            activities: {
              create: [
                { name: 'ノートルダム大聖堂見学', startTime: '10:00', duration: '1時間', description: '修復工事中の世界的大聖堂の外観を見学', location: 'シテ島' },
                { name: 'カフェ・ド・フロール朝食', startTime: '08:00', duration: '1時間', description: 'サルトルも通った老舗カフェでパリ最後の朝を', location: 'サンジェルマン・デ・プレ' },
              ],
            },
          },
        ],
      },
      includedItems: {
        create: [
          { item: '専任日本語ガイド（全日程）' },
          { item: 'ルーブル美術館プライベート早朝ツアー' },
          { item: 'エッフェル塔優先入場券（最上階）' },
          { item: 'ヴェルサイユ宮殿プライベートツアー' },
          { item: 'セーヌ川ディナークルーズ（フルコース付き）' },
          { item: 'マカロン・クロワッサン作り体験' },
          { item: 'オルセー美術館入場料' },
          { item: '毎朝の朝食' },
          { item: '空港〜ホテル間の送迎' },
        ],
      },
      excludedItems: {
        create: [
          { item: '往復航空券' },
          { item: '宿泊費（別途手配可能）' },
          { item: '個人的なショッピング代' },
          { item: '旅行保険' },
          { item: 'ヴィザ（必要な場合）' },
        ],
      },
      reviews: {
        create: [
          { reviewerName: '佐藤 愛', rating: 5.0, comment: 'ルーブルの早朝貸切ツアーでモナリザを独占できたのは夢のような体験でした。ガイドさんも絵画の解説が素晴らしく、アートの見方が変わりました。', travelDate: new Date('2024-05-10') },
          { reviewerName: '渡辺 誠', rating: 4.7, comment: 'セーヌ川ディナークルーズで見たパリの夜景は一生忘れられません。妻への最高のプレゼントになりました。', travelDate: new Date('2024-06-14') },
          { reviewerName: 'Sophie Martin', rating: 4.9, comment: 'Even as a Parisian, this tour showed me new sides of my city. The private Versailles tour was exceptional.', travelDate: new Date('2024-04-22') },
        ],
      },
    },
  });

  // 5. Swiss Alps
  const swiss = await prisma.travelPlan.create({
    data: {
      title: 'スイスアルプス トレッキング8日間',
      description:
        'ユングフラウ・マッターホルン・グリンデルワルトの絶景を巡る8日間の本格トレッキング。アイガー北壁を望む絶壁トレイル、ハイジの里・マイエンフェルト訪問、ツェルマットからのゴルナーグラート展望台、スイスらしいフォンデュとラクレット体験まで、スイスの全てを満喫できる至高のアドベンチャープランです。',
      destination: 'インターラーケン・グリンデルワルト・ツェルマット',
      country: 'スイス',
      region: 'ヨーロッパ',
      latitude: 46.6863,
      longitude: 7.8632,
      price: 350000,
      discountPrice: null,
      durationDays: 8,
      maxParticipants: 8,
      currentBookings: 3,
      category: 'adventure',
      difficulty: 'hard',
      rating: 4.9,
      reviewCount: 73,
      isAvailable: true,
      language: '日本語',
      meetingPoint: 'チューリッヒ中央駅 観光案内所前',
      cancellationPolicy: '出発45日前まで：全額返金\n出発30〜44日前：60%返金\n出発14〜29日前：30%返金\n出発13日前以降：返金不可',
      minimumAge: 16,
      tags: '["スイス","アルプス","トレッキング","マッターホルン","ユングフラウ","絶景","登山"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800', caption: 'マッターホルンの朝焼け', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1527668752968-14dc70a27c92?w=800', caption: 'グリンデルワルトの村と山々', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800', caption: 'ユングフラウヨッホ（欧州の屋根）', isPrimary: false, displayOrder: 2 },
          { url: 'https://images.unsplash.com/photo-1491555103944-7c647fd857e6?w=800', caption: 'スイスの高山草原', isPrimary: false, displayOrder: 3 },
        ],
      },
      highlights: {
        create: [
          { text: 'ユングフラウヨッホ「欧州の屋根」登山鉄道体験' },
          { text: 'アイガートレイルでの本格山岳トレッキング' },
          { text: 'マッターホルン正面・ゴルナーグラート展望台' },
          { text: 'スイス山岳ガイドによる安全なハイキング指導' },
          { text: '山小屋での本格スイスチーズフォンデュ体験' },
        ],
      },
      itinerary: {
        create: [
          {
            dayNumber: 1, title: 'チューリッヒ到着・インターラーケンへ',
            description: 'チューリッヒに到着後、スイス鉄道でインターラーケンへ。ブリエンツ湖を眺めながらの列車旅自体が絶景体験です。',
            accommodation: 'インターラーケン ホテル・インターラーケン', meals: 'dinner',
            activities: {
              create: [
                { name: 'スイス鉄道インターラーケン移動', startTime: '14:00', duration: '2時間', description: 'ブリエンツ湖とトゥーン湖を望む絶景列車旅', location: 'チューリッヒ→インターラーケン' },
                { name: 'インターラーケン夕暮れ散策', startTime: '18:00', duration: '1時間', description: 'ユングフラウを望むホーエマッテ公園でのんびり', location: 'ホーエマッテ' },
              ],
            },
          },
          {
            dayNumber: 2, title: 'ユングフラウヨッホ日帰り登山',
            description: '登山鉄道でヨーロッパ最高地点の駅・ユングフラウヨッホ（3454m）へ。万年雪のアレッチ氷河やスフィンクス展望台を探索します。',
            accommodation: 'インターラーケン ホテル・インターラーケン', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'ユングフラウ登山鉄道', startTime: '08:00', duration: '3時間', description: 'グリンデルワルトから世界遺産の登山鉄道で山頂駅へ', location: 'グリンデルワルト→ユングフラウヨッホ' },
                { name: 'アレッチ氷河・スフィンクス展望台', startTime: '11:00', duration: '2時間', description: 'ヨーロッパ最長の氷河と360度パノラマを堪能', location: 'ユングフラウヨッホ' },
                { name: '高山植物トレイル', startTime: '14:00', duration: '2時間', description: 'クライネ・シャイデックからの初級トレイル', location: 'クライネ・シャイデック' },
              ],
            },
          },
          {
            dayNumber: 3, title: 'グリンデルワルト・アイガートレイル',
            description: 'アイガー北壁を間近に望む伝説のトレイル「アイガートレイル」に挑戦。スイス山岳ガイドが安全をサポートします。',
            accommodation: 'グリンデルワルト ホテル・アイガー', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'アイガートレイルトレッキング', startTime: '09:00', duration: '5時間', description: 'アイガー北壁の岩肌を望む難易度高めのトレイル（約6km）', location: 'アイガートレイル' },
                { name: 'グリンデルワルト村観光', startTime: '16:00', duration: '1.5時間', description: 'アルプスの絵本のような村を散策', location: 'グリンデルワルト' },
              ],
            },
          },
          {
            dayNumber: 4, title: 'ツェルマットへ移動・マッターホルン観望',
            description: '氷河特急でツェルマットへ移動。環境保護のため車が入れない村でe-タクシーに乗り換え、マッターホルンの絶景を様々な角度から楽しみます。',
            accommodation: 'ツェルマット ホテル・モンテ・ロサ', meals: 'breakfast,dinner',
            activities: {
              create: [
                { name: '氷河特急（グレッシャー・エクスプレス）', startTime: '09:00', duration: '4時間', description: '世界最遅の絶景特急で291のトンネルと91の橋を渡る', location: 'インターラーケン→ツェルマット' },
                { name: 'ライ湖・マッターホルン観望', startTime: '15:00', duration: '1.5時間', description: '逆さマッターホルンが映るライ湖の絶景スポット', location: 'ライ湖' },
              ],
            },
          },
          {
            dayNumber: 5, title: 'ゴルナーグラート展望台・マッターホルントレイル',
            description: 'ゴルナーグラート登山鉄道でマッターホルンとモンテローザを正面から望む展望台へ。午後はマッターホルン周辺の高山草原をトレッキング。',
            accommodation: 'ツェルマット ホテル・モンテ・ロサ', meals: 'breakfast,lunch',
            activities: {
              create: [
                { name: 'ゴルナーグラート展望台', startTime: '09:00', duration: '2.5時間', description: '標高3089mからのマッターホルンと29の氷河の絶景', location: 'ゴルナーグラート' },
                { name: 'ロッテンボーデン〜リッフェルベルクトレイル', startTime: '12:30', duration: '3時間', description: 'マッターホルンを正面に望む人気ハイキングコース', location: 'ツェルマット周辺' },
              ],
            },
          },
          {
            dayNumber: 6, title: 'ハイキング・チーズフォンデュ体験',
            description: '標高2000mの山小屋でのランチ後、牧草地のんびりハイキング。夜は地元農家でスイスチーズフォンデュとラクレットを楽しみます。',
            accommodation: 'ツェルマット ホテル・モンテ・ロサ', meals: 'breakfast,lunch,dinner',
            activities: {
              create: [
                { name: '山小屋ランチハイキング', startTime: '10:00', duration: '4時間', description: '標高2000mの山小屋でアルプスの空気と食事を楽しむ', location: 'ツェルマット周辺山岳' },
                { name: 'チーズフォンデュ＆ラクレット体験', startTime: '19:00', duration: '2時間', description: '地元チーズ職人の家でスイス伝統料理を体験', location: 'ツェルマット' },
              ],
            },
          },
          {
            dayNumber: 7, title: 'インターラーケン・自由時間',
            description: 'ツェルマットからインターラーケンに戻り、自由時間。オプションでパラグライダー体験（別途料金）や、湖畔でのんびりした時間もお楽しみいただけます。',
            accommodation: 'インターラーケン ホテル・インターラーケン', meals: 'breakfast',
            activities: {
              create: [
                { name: 'インターラーケン帰還・自由時間', startTime: '10:00', duration: '4時間', description: 'ショッピングやカフェでゆっくり過ごす自由時間', location: 'インターラーケン' },
                { name: 'オプション：パラグライダー体験', startTime: '14:00', duration: '2時間', description: 'アルプスの上空を飛ぶスリリング体験（別途CHF180）', location: 'インターラーケン' },
              ],
            },
          },
          {
            dayNumber: 8, title: 'チューリッヒ・帰途',
            description: 'インターラーケンからチューリッヒへ。空港近くのチューリッヒ旧市街を少し散策後、帰途につきます。',
            accommodation: null, meals: 'breakfast',
            activities: {
              create: [
                { name: 'チューリッヒ旧市街散策', startTime: '11:00', duration: '1.5時間', description: 'グロスミュンスターやバンホフ通りを短時間で散策', location: 'チューリッヒ' },
              ],
            },
          },
        ],
      },
      includedItems: {
        create: [
          { item: '認定スイス山岳ガイド（全日程）' },
          { item: 'ユングフラウ登山鉄道往復' },
          { item: '氷河特急（グレッシャー・エクスプレス）' },
          { item: 'ゴルナーグラート登山鉄道往復' },
          { item: 'スイスパス（全スイス鉄道・バス乗り放題）' },
          { item: 'チーズフォンデュ体験ディナー' },
          { item: '毎朝の朝食と指定ランチ' },
          { item: 'トレッキング用品レンタル（ポール・スパッツ等）' },
        ],
      },
      excludedItems: {
        create: [
          { item: '往復航空券' },
          { item: '宿泊費（別途手配可能）' },
          { item: 'パラグライダー等の追加オプション費用' },
          { item: '旅行保険（山岳保険含む必須）' },
          { item: '個人的な購入品・飲食費' },
        ],
      },
      reviews: {
        create: [
          { reviewerName: '高橋 剛', rating: 5.0, comment: 'アイガートレイルは人生で最も素晴らしいハイキング体験でした。ガイドが常にサポートしてくれるので安心して絶景を楽しめました。', travelDate: new Date('2024-08-15') },
          { reviewerName: 'Klaus Müller', rating: 4.8, comment: 'Als Schweizer bin ich beeindruckt, wie gut dieser Tour die Schönheiten der Alpen zeigt. Die japanischen Gäste waren begeistert!', travelDate: new Date('2024-07-08') },
          { reviewerName: '西村 直子', rating: 4.9, comment: 'マッターホルンを目の前に見ながら食べたチーズフォンデュの美味しさは忘れられません。体力的に大変でしたが達成感がありました！', travelDate: new Date('2024-08-22') },
        ],
      },
    },
  });

  // 6–10: remaining plans with condensed but complete data
  const bali = await prisma.travelPlan.create({
    data: {
      title: 'バリ島スピリチュアルリトリート5日間',
      description: '神々の島・バリ島でウブドの棚田、ケチャクダンス、伝統的なバリニーズマッサージ、ヨガリトリートを体験する癒しと精神的充足の5日間。日常の喧騒から離れ、自分と向き合う特別な時間を提供します。',
      destination: 'ウブド・バリ',
      country: 'インドネシア',
      region: 'アジア',
      latitude: -8.5069,
      longitude: 115.2625,
      price: 100000,
      discountPrice: 88000,
      durationDays: 5,
      maxParticipants: 8,
      currentBookings: 3,
      category: 'leisure',
      difficulty: 'easy',
      rating: 4.7,
      reviewCount: 142,
      isAvailable: true,
      language: '日本語・英語',
      meetingPoint: 'デンパサール国際空港 到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null,
      tags: '["バリ島","ヨガ","瞑想","スパ","棚田","ケチャクダンス","癒し"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800', caption: 'テガランの棚田の夕暮れ', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800', caption: 'バリニーズヨガセッション', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1552733407-5d5c46c3bb3b?w=800', caption: 'ケチャクダンスの炎', isPrimary: false, displayOrder: 2 },
        ],
      },
      highlights: {
        create: [
          { text: 'テガランの棚田でのサンライズヨガ体験' },
          { text: '伝統的バリニーズマッサージ3時間コース' },
          { text: 'ウルワトゥ寺院でのケチャクダンス鑑賞' },
          { text: '地元家庭でのバリ料理クッキングクラス' },
          { text: 'プリウィサタ水の宮殿での沐浴浄化体験' },
        ],
      },
      itinerary: {
        create: [
          { dayNumber: 1, title: '到着・ウブド・バリニーズウェルカム', description: 'デンパサール空港からウブドへ移動。夕方はバリニーズコーヒーと共にウェルカムセレモニー。', accommodation: 'ウブド プリ・サカン・リゾート', meals: 'dinner', activities: { create: [{ name: 'バリニーズウェルカムセレモニー', startTime: '17:00', duration: '1時間', description: '花飾りとコーヒーで歓迎', location: 'リゾート' }] } },
          { dayNumber: 2, title: 'サンライズヨガ・ウブド王宮・芸術村', description: '朝日の棚田でヨガ後、ウブド中心部を観光。', accommodation: 'ウブド プリ・サカン・リゾート', meals: 'breakfast,lunch', activities: { create: [{ name: 'テガランの棚田サンライズヨガ', startTime: '06:00', duration: '2時間', description: '棚田を見下ろしながら朝ヨガ', location: 'テガラン棚田' }, { name: 'ウブド王宮見学', startTime: '10:00', duration: '1時間', description: 'バリ王朝の宮殿見学', location: 'ウブド王宮' }] } },
          { dayNumber: 3, title: 'バリニーズマッサージ・料理体験', description: '午前は伝統マッサージ、午後はクッキングクラス。', accommodation: 'ウブド プリ・サカン・リゾート', meals: 'breakfast,lunch,dinner', activities: { create: [{ name: 'バリニーズマッサージ3時間', startTime: '09:00', duration: '3時間', description: '伝統的なバリのマッサージで完全リラックス', location: 'スパ' }, { name: 'バリ料理クッキングクラス', startTime: '15:00', duration: '2.5時間', description: '地元家庭でナシゴレン・サテーを作る', location: 'ウブド郊外' }] } },
          { dayNumber: 4, title: 'バトゥール山・ウルワトゥ寺院', description: '活火山バトゥール山を一望後、夕暮れのケチャクダンスへ。', accommodation: 'ウブド プリ・サカン・リゾート', meals: 'breakfast,dinner', activities: { create: [{ name: 'バトゥール山展望', startTime: '08:00', duration: '2時間', description: '神聖な火山と湖を一望', location: 'キンタマーニ' }, { name: 'ウルワトゥ・ケチャクダンス', startTime: '18:00', duration: '2時間', description: '断崖絶壁の寺院で炎と夕日の幻想的な舞台', location: 'ウルワトゥ寺院' }] } },
          { dayNumber: 5, title: '水の宮殿・帰途', description: 'プリウィサタで沐浴浄化体験後、空港へ。', accommodation: null, meals: 'breakfast', activities: { create: [{ name: 'タマンアユン寺院・プリウィサタ', startTime: '09:00', duration: '2時間', description: '水の宮殿での浄化体験', location: 'メンウィ' }] } },
        ],
      },
      includedItems: { create: [{ item: '専任ガイド' }, { item: 'ヨガセッション（日2回）' }, { item: 'バリニーズマッサージ3時間' }, { item: 'クッキングクラス' }, { item: 'ケチャクダンス入場料' }, { item: '毎朝の朝食' }] },
      excludedItems: { create: [{ item: '往復航空券' }, { item: '宿泊費' }, { item: '旅行保険' }, { item: '個人飲食費' }] },
      reviews: { create: [{ reviewerName: '松本 由紀', rating: 4.8, comment: '棚田でのヨガは日常を忘れさせてくれました。バリのスピリチュアルな空気に包まれた最高の旅でした。', travelDate: new Date('2024-03-10') }, { reviewerName: 'Amanda Lee', rating: 4.6, comment: 'The perfect retreat. The Balinese massage was incredible and the cooking class was so fun!', travelDate: new Date('2024-01-25') }] },
    },
  });

  const nyc = await prisma.travelPlan.create({
    data: {
      title: 'ニューヨーク・シティ・エクスペリエンス4日間',
      description: '眠らない街・ニューヨークで世界最高峰の文化・芸術・グルメを体験する4日間。タイムズスクエア、セントラルパーク、自由の女神、MoMA・メトロポリタン美術館、ブロードウェイミュージカルと、NYの全てをぎゅっと詰め込んだ究極の都市体験プランです。',
      destination: 'ニューヨーク',
      country: 'アメリカ',
      region: 'アメリカ大陸',
      latitude: 40.7128,
      longitude: -74.0060,
      price: 180000,
      discountPrice: null,
      durationDays: 4,
      maxParticipants: 12,
      currentBookings: 5,
      category: 'city',
      difficulty: 'easy',
      rating: 4.6,
      reviewCount: 198,
      isAvailable: true,
      language: '日本語',
      meetingPoint: 'JFK国際空港 ターミナル4 到着ロビー',
      cancellationPolicy: '出発14日前まで：全額返金\n出発7〜13日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null,
      tags: '["ニューヨーク","NYC","ブロードウェイ","自由の女神","タイムズスクエア","美術館","グルメ"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800', caption: 'タイムズスクエアの輝き', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800', caption: '自由の女神と青い空', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1499092346302-2a4a1e8a7d9a?w=800', caption: 'セントラルパークの秋', isPrimary: false, displayOrder: 2 },
        ],
      },
      highlights: {
        create: [
          { text: 'ブロードウェイミュージカル優先席観劇' },
          { text: '自由の女神フェリー＆クラウン展望台入場' },
          { text: 'セントラルパーク早朝モーニングジョグ' },
          { text: 'メトロポリタン美術館プライベートガイドツアー' },
          { text: 'チェルシーマーケットとハイラインを歩く' },
        ],
      },
      itinerary: {
        create: [
          { dayNumber: 1, title: '到着・タイムズスクエア・ミッドタウン', description: 'JFK到着後マンハッタンへ。まずはタイムズスクエアの圧倒的な光景を体感します。', accommodation: 'ミッドタウン ヒルトン・ニューヨーク', meals: 'dinner', activities: { create: [{ name: 'タイムズスクエア夜景鑑賞', startTime: '20:00', duration: '1.5時間', description: '世界一のネオン街で圧巻の光景を体験', location: 'タイムズスクエア' }] } },
          { dayNumber: 2, title: '自由の女神・ウォール街・Brooklyn', description: '自由の女神を間近に見学後、金融の中心地とブルックリンブリッジを探索。', accommodation: 'ミッドタウン ヒルトン・ニューヨーク', meals: 'breakfast,lunch', activities: { create: [{ name: '自由の女神フェリーツアー', startTime: '09:00', duration: '3時間', description: 'フェリーでリバティ島へ、クラウンまで登る', location: 'リバティ島' }, { name: 'ブルックリンブリッジ散策', startTime: '14:00', duration: '1.5時間', description: '徒歩でブルックリン橋を渡りマンハッタンを望む', location: 'ブルックリンブリッジ' }] } },
          { dayNumber: 3, title: 'セントラルパーク・メトロポリタン美術館・ブロードウェイ', description: '朝のセントラルパーク、昼はMet、夜はブロードウェイ、NYの三大体験の日。', accommodation: 'ミッドタウン ヒルトン・ニューヨーク', meals: 'breakfast', activities: { create: [{ name: 'セントラルパーク朝散歩', startTime: '08:00', duration: '1.5時間', description: '843エーカーの都市公園でニューヨーカー気分', location: 'セントラルパーク' }, { name: 'メトロポリタン美術館', startTime: '10:00', duration: '2.5時間', description: '200万点以上の収蔵品を持つ世界最大級の美術館', location: 'メトロポリタン美術館' }, { name: 'ブロードウェイミュージカル', startTime: '19:30', duration: '2.5時間', description: '世界最高峰のエンターテイメント（優先席）', location: 'ブロードウェイ劇場街' }] } },
          { dayNumber: 4, title: 'ハイライン・チェルシー・帰途', description: '廃線路を公園に変えたハイラインを歩き、アートの街チェルシーを散策後、帰途へ。', accommodation: null, meals: 'breakfast', activities: { create: [{ name: 'ハイライン＆チェルシーマーケット', startTime: '09:00', duration: '2時間', description: '空中公園からHudson Yardsを一望、食材市場へ', location: 'チェルシー' }] } },
        ],
      },
      includedItems: { create: [{ item: '専任ガイド' }, { item: 'ブロードウェイミュージカル優先席' }, { item: '自由の女神フェリー＆入場料' }, { item: 'メトロポリタン美術館入場料' }, { item: '毎朝の朝食' }, { item: '空港〜ホテル送迎' }] },
      excludedItems: { create: [{ item: '往復航空券' }, { item: '宿泊費' }, { item: '旅行保険' }, { item: 'ESTA申請費' }, { item: '個人飲食費' }] },
      reviews: { create: [{ reviewerName: '小林 圭', rating: 4.7, comment: 'ブロードウェイは感動の連続でした！ガイドさんのNYの裏話も楽しく、充実した4日間でした。', travelDate: new Date('2024-09-12') }, { reviewerName: 'Jennifer Smith', rating: 4.5, comment: 'Perfect NYC experience for first-timers. The Broadway seats were fantastic!', travelDate: new Date('2024-08-30') }] },
    },
  });

  const australia = await prisma.travelPlan.create({
    data: {
      title: 'オーストラリア グレートバリアリーフ6日間',
      description: '世界最大のサンゴ礁・グレートバリアリーフでシュノーケリング・スキューバダイビングを楽しむ6日間。ケアンズを拠点にポートダグラス、キュランダ熱帯雨林鉄道、アボリジナル文化体験まで盛りだくさんのオーストラリア自然体験ツアーです。',
      destination: 'ケアンズ・グレートバリアリーフ',
      country: 'オーストラリア',
      region: 'オセアニア',
      latitude: -16.9186,
      longitude: 145.7781,
      price: 320000,
      discountPrice: 290000,
      durationDays: 6,
      maxParticipants: 10,
      currentBookings: 4,
      category: 'adventure',
      difficulty: 'moderate',
      rating: 4.8,
      reviewCount: 94,
      isAvailable: true,
      language: '日本語・英語',
      meetingPoint: 'ケアンズ国際空港 到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：60%返金\n出発7〜13日前：30%返金\n出発6日前以降：返金不可',
      minimumAge: 8,
      tags: '["オーストラリア","グレートバリアリーフ","ダイビング","珊瑚礁","熱帯雨林","キュランダ","ケアンズ"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800', caption: 'グレートバリアリーフの海中世界', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800', caption: 'キュランダ熱帯雨林', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1523395243481-163f8f6155ab?w=800', caption: 'ケアンズの夕暮れ', isPrimary: false, displayOrder: 2 },
        ],
      },
      highlights: {
        create: [
          { text: 'グレートバリアリーフでのスキューバダイビング体験（初心者歓迎）' },
          { text: 'ポントゥーン（海上プラットフォーム）での半日シュノーケリング' },
          { text: 'キュランダ観光列車＋スカイレール往復' },
          { text: 'アボリジナルダンス＆文化体験' },
          { text: 'ヘリコプターでの空中サンゴ礁鑑賞（オプション）' },
        ],
      },
      itinerary: {
        create: [
          { dayNumber: 1, title: '到着・ケアンズ・ウォーターフロント', description: 'ケアンズに到着。エスプラネードのウォーターフロントと夜のナイトマーケットを楽しみます。', accommodation: 'ケアンズ ヒルトン', meals: 'dinner', activities: { create: [{ name: 'エスプラネード散策', startTime: '17:00', duration: '1.5時間', description: '海沿いの遊歩道でケアンズの雰囲気を満喫', location: 'エスプラネード' }, { name: 'ナイトマーケット', startTime: '19:00', duration: '1時間', description: '地元グルメとおみやげショッピング', location: 'ケアンズナイトマーケット' }] } },
          { dayNumber: 2, title: 'グレートバリアリーフ・ダイビング体験', description: '高速船でアウターリーフへ。初心者向け体験ダイビングとシュノーケリングを楽しみます。', accommodation: 'ケアンズ ヒルトン', meals: 'breakfast,lunch', activities: { create: [{ name: 'グレートバリアリーフ体験ダイビング', startTime: '08:00', duration: '6時間', description: '世界遺産のサンゴ礁でインストラクターと初ダイビング', location: 'アウターリーフ' }, { name: 'シュノーケリング', startTime: '13:00', duration: '2時間', description: '色とりどりの熱帯魚と一緒に泳ぐ', location: 'ポントゥーン' }] } },
          { dayNumber: 3, title: 'キュランダ観光列車＆スカイレール', description: '世界遺産の熱帯雨林を観光列車とロープウェイで体験。キュランダ村でアボリジナル文化も。', accommodation: 'ケアンズ ヒルトン', meals: 'breakfast,lunch', activities: { create: [{ name: 'キュランダシーニック鉄道', startTime: '08:30', duration: '2時間', description: '世紀の奇跡・熱帯雨林の中の観光鉄道', location: 'キュランダ' }, { name: 'スカイレール＆キュランダ村', startTime: '11:00', duration: '3時間', description: '熱帯雨林の上空を渡るゴンドラと先住民文化', location: 'キュランダ' }] } },
          { dayNumber: 4, title: 'ポートダグラス・モスマン渓谷', description: '高級リゾート地ポートダグラスとモスマン渓谷の原生林トレッキング。', accommodation: 'ケアンズ ヒルトン', meals: 'breakfast,lunch', activities: { create: [{ name: 'ポートダグラス散策', startTime: '10:00', duration: '2時間', description: '洗練されたリゾートタウンとビーチ', location: 'ポートダグラス' }, { name: 'モスマン渓谷トレッキング', startTime: '13:00', duration: '2時間', description: '古代熱帯雨林と清流を歩く', location: 'モスマン渓谷' }] } },
          { dayNumber: 5, title: 'シュノーケリング・自由行動', description: '午前はシュノーケリングで最後のリーフ体験。午後はケアンズで自由散策。', accommodation: 'ケアンズ ヒルトン', meals: 'breakfast', activities: { create: [{ name: '半日シュノーケリングツアー', startTime: '08:00', duration: '4時間', description: 'インナーリーフで色とりどりのサンゴを観察', location: 'グレートバリアリーフ' }] } },
          { dayNumber: 6, title: '帰途', description: 'ケアンズ最後の朝を楽しみ、空港へ。', accommodation: null, meals: 'breakfast', activities: { create: [{ name: 'ケアンズ朝散歩', startTime: '07:00', duration: '1時間', description: '海沿いを歩いてオーストラリア最後の朝を満喫', location: 'エスプラネード' }] } },
        ],
      },
      includedItems: { create: [{ item: '専任ガイド' }, { item: 'グレートバリアリーフ体験ダイビング（機材込み）' }, { item: 'キュランダシーニック鉄道＋スカイレール' }, { item: '高速船でのリーフツアー' }, { item: '毎朝の朝食と指定ランチ' }] },
      excludedItems: { create: [{ item: '往復航空券' }, { item: '宿泊費' }, { item: '旅行保険' }, { item: 'ヘリコプター体験（オプション）' }, { item: '個人飲食費' }] },
      reviews: { create: [{ reviewerName: '加藤 真一', rating: 4.9, comment: 'グレートバリアリーフの美しさは言葉では表現できません。ダイビング初心者でしたが、インストラクターが丁寧に教えてくれました。', travelDate: new Date('2024-04-18') }, { reviewerName: 'Rachel Brown', rating: 4.7, comment: 'The Great Barrier Reef exceeded all expectations. The Kuranda train is a must-do!', travelDate: new Date('2024-06-05') }] },
    },
  });

  const morocco = await prisma.travelPlan.create({
    data: {
      title: 'モロッコ砂漠とメディナ7日間',
      description: 'アフリカと中東が交差する神秘の国・モロッコを7日間で堪能。マラケシュのジャマ・エル・フナ広場、フェズの迷宮メディナ、サハラ砂漠でのキャメルライドと満天の星空キャンプ、青い街シャウエン、大西洋岸のエッサウィラまで、異文化の彩りに溢れた旅です。',
      destination: 'マラケシュ・フェズ・サハラ・シャウエン',
      country: 'モロッコ',
      region: 'アフリカ',
      latitude: 31.6295,
      longitude: -7.9811,
      price: 160000,
      discountPrice: 144000,
      durationDays: 7,
      maxParticipants: 10,
      currentBookings: 2,
      category: 'adventure',
      difficulty: 'moderate',
      rating: 4.7,
      reviewCount: 76,
      isAvailable: true,
      language: '日本語',
      meetingPoint: 'マラケシュ マラケシュ・メナラ空港 到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：60%返金\n出発7〜13日前：30%返金\n出発6日前以降：返金不可',
      minimumAge: 12,
      tags: '["モロッコ","サハラ砂漠","マラケシュ","フェズ","キャメルライド","メディナ","シャウエン"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?w=800', caption: 'サハラ砂漠の夕暮れとキャメル', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800', caption: 'シャウエンの青い街並み', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800', caption: 'マラケシュ・ジャマ・エル・フナ広場', isPrimary: false, displayOrder: 2 },
        ],
      },
      highlights: {
        create: [
          { text: 'サハラ砂漠でのキャメルライドと砂丘夕日鑑賞' },
          { text: '砂漠テント（グランピング）での満天の星空' },
          { text: 'フェズの世界最古の大学・カラウィン訪問' },
          { text: '青の街・シャウエンで迷子になる自由時間' },
          { text: 'ハンマム（モロッコ式蒸し風呂）体験' },
        ],
      },
      itinerary: {
        create: [
          { dayNumber: 1, title: 'マラケシュ到着・ジャマ・エル・フナ', description: 'マラケシュ到着後、世界遺産の広場でスネークチャーマーや屋台グルメを体験。', accommodation: 'マラケシュ リアド・バダマ', meals: 'dinner', activities: { create: [{ name: 'ジャマ・エル・フナ広場', startTime: '18:00', duration: '2時間', description: '世界最大の屋外劇場でモロッコの熱気を体感', location: 'ジャマ・エル・フナ' }] } },
          { dayNumber: 2, title: 'マラケシュ・メディナ・スーク探索', description: 'バイア宮殿、クトゥビアモスク、迷宮のようなスークを探索。タンネリも見学。', accommodation: 'マラケシュ リアド・バダマ', meals: 'breakfast,lunch', activities: { create: [{ name: 'バイア宮殿見学', startTime: '09:00', duration: '1.5時間', description: '19世紀の豪華なイスラム建築', location: 'マラケシュ' }, { name: 'スーク探索', startTime: '11:00', duration: '2.5時間', description: '香辛料・皮革・陶器のバザールを迷路のように歩く', location: 'マラケシュメディナ' }] } },
          { dayNumber: 3, title: 'フェズへ移動・メディナ探索', description: '世界最大の自動車通行不可エリア・フェズメディナへ。カラウィン大学も訪問。', accommodation: 'フェズ リアド・アンダルス', meals: 'breakfast,lunch', activities: { create: [{ name: 'フェズ・エル・バリメディナ', startTime: '14:00', duration: '3時間', description: '9300本の路地を持つ世界遺産の迷宮都市', location: 'フェズメディナ' }, { name: 'タンネリ（皮なめし職人街）', startTime: '10:00', duration: '1時間', description: '中世から変わらぬ革染めの伝統工芸を上から見学', location: 'フェズ' }] } },
          { dayNumber: 4, title: 'エルフード・サハラへ', description: '砂漠の玄関口・エルフードを経て、サハラ砂漠へ。夕暮れにキャメルライドで砂丘へ。', accommodation: 'サハラ グランピングテント', meals: 'breakfast,dinner', activities: { create: [{ name: 'キャメルライドで砂丘へ', startTime: '17:00', duration: '1.5時間', description: 'ラクダに乗って砂漠の砂丘を越えキャンプへ', location: 'メルズーガ砂丘' }] } },
          { dayNumber: 5, title: 'サハラ・星空・シャウエンへ', description: '早朝のサンライズ鑑賞後、青の街・シャウエンへ移動。', accommodation: 'シャウエン ダール・アルジア', meals: 'breakfast,lunch', activities: { create: [{ name: 'サハラ砂漠サンライズ', startTime: '05:30', duration: '1時間', description: '砂漠の夜明けと地平線からの朝日', location: 'メルズーガ' }, { name: 'シャウエン散策', startTime: '18:00', duration: '2時間', description: '全ての建物が青く染まる魔法の街を探索', location: 'シャウエン' }] } },
          { dayNumber: 6, title: 'シャウエン・ハンマム体験・マラケシュ帰還', description: 'シャウエンをゆっくり散策後、ハンマムで心身を清め、マラケシュへ。', accommodation: 'マラケシュ リアド・バダマ', meals: 'breakfast,dinner', activities: { create: [{ name: 'シャウエン早朝撮影散歩', startTime: '07:00', duration: '1.5時間', description: '観光客が少ない早朝に青い路地を独占', location: 'シャウエン' }, { name: 'ハンマム体験', startTime: '15:00', duration: '2時間', description: 'モロッコ式蒸し風呂で旅の疲れを癒す', location: 'マラケシュ' }] } },
          { dayNumber: 7, title: 'マジョレル庭園・帰途', description: 'イヴ・サンローランが愛したコバルトブルーの庭園を訪問後、帰途へ。', accommodation: null, meals: 'breakfast', activities: { create: [{ name: 'マジョレル庭園', startTime: '09:00', duration: '1.5時間', description: '鮮やかなブルーとエキゾチックな植物の庭園', location: 'マラケシュ' }] } },
        ],
      },
      includedItems: { create: [{ item: '専任ガイド' }, { item: 'キャメルライド' }, { item: 'グランピングテント（夕食・朝食込み）' }, { item: 'ハンマム体験' }, { item: 'バイア宮殿・マジョレル庭園入場料' }, { item: '全行程の移動車' }] },
      excludedItems: { create: [{ item: '往復航空券' }, { item: '一部宿泊費' }, { item: '旅行保険' }, { item: '個人飲食費' }, { item: 'ヴィザ（必要な場合）' }] },
      reviews: { create: [{ reviewerName: '木村 雅彦', rating: 4.8, comment: 'サハラ砂漠の満天の星は人生で見た中で最も美しい光景でした。シャウエンの青い街も夢のようでした。', travelDate: new Date('2024-05-20') }, { reviewerName: 'Laura García', rating: 4.6, comment: 'Morocco is magical and this tour covered all the highlights. The camel ride at sunset was unforgettable!', travelDate: new Date('2024-03-15') }] },
    },
  });

  const santorini = await prisma.travelPlan.create({
    data: {
      title: 'サントリーニ島 エーゲ海5日間',
      description: 'ギリシャが誇る絶景の島・サントリーニでの究極のリゾート体験。イア（オイア）の伝説的サンセット、世界最高の絶景カルデラビュー、古代遺跡アクロティリ、火山島クルーズ、地中海ワインとギリシャ料理まで、エーゲ海の青と白の世界に溶け込む特別な5日間です。',
      destination: 'サントリーニ島',
      country: 'ギリシャ',
      region: 'ヨーロッパ',
      latitude: 36.3932,
      longitude: 25.4615,
      price: 250000,
      discountPrice: null,
      durationDays: 5,
      maxParticipants: 8,
      currentBookings: 6,
      category: 'leisure',
      difficulty: 'easy',
      rating: 4.9,
      reviewCount: 183,
      isAvailable: true,
      language: '日本語',
      meetingPoint: 'アテネ国際空港（エルフテリオス・ヴェニゼロス空港）到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：70%返金\n出発7〜13日前：40%返金\n出発6日前以降：返金不可',
      minimumAge: null,
      tags: '["サントリーニ","ギリシャ","エーゲ海","サンセット","カルデラ","ワイン","地中海"]',
      images: {
        create: [
          { url: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800', caption: 'イアの青いドームと夕日', isPrimary: true, displayOrder: 0 },
          { url: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800', caption: 'カルデラを見下ろすテラス', isPrimary: false, displayOrder: 1 },
          { url: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800', caption: 'エーゲ海の透明な青', isPrimary: false, displayOrder: 2 },
        ],
      },
      highlights: {
        create: [
          { text: 'イア（オイア）での世界最美サンセット鑑賞' },
          { text: 'カルデラビュープールつき洞窟ホテル宿泊' },
          { text: '火山島・温泉島クルーズ' },
          { text: 'サントリーニワインのワイナリーツアーと試飲' },
          { text: '水中紀元前の古代都市・アクロティリ遺跡見学' },
        ],
      },
      itinerary: {
        create: [
          { dayNumber: 1, title: 'アテネ経由・サントリーニ到着', description: 'アテネを経由してサントリーニ島へ。フィラの街を初散策。', accommodation: 'フィラ カルデラビューケイブホテル', meals: 'dinner', activities: { create: [{ name: 'フィラ初散策', startTime: '17:00', duration: '1.5時間', description: 'カルデラの断崖に広がる白い街を歩く', location: 'フィラ' }] } },
          { dayNumber: 2, title: 'アクロティリ遺跡・赤い砂浜・ワイナリー', description: '地中海文明の謎・アクロティリ遺跡と島南部の観光。夕方はワイナリーへ。', accommodation: 'フィラ カルデラビューケイブホテル', meals: 'breakfast,lunch', activities: { create: [{ name: 'アクロティリ遺跡', startTime: '09:00', duration: '1.5時間', description: '火山灰に埋もれた青銅器時代の古代都市', location: 'アクロティリ' }, { name: 'レッドビーチ', startTime: '11:30', duration: '1時間', description: '赤い火山岩と青いエーゲ海のコントラスト', location: 'アクロティリ近郊' }, { name: 'サントリーニワイナリー試飲ツアー', startTime: '17:00', duration: '2時間', description: '火山性土壌が生んだアシルティコ白ワインを試飲', location: 'ピルゴス' }] } },
          { dayNumber: 3, title: '火山島クルーズ・温泉・イア絶景', description: 'ボートで火山島と温泉島を巡り、イアの絶景テラスでサンセットアペロール。', accommodation: 'フィラ カルデラビューケイブホテル', meals: 'breakfast,lunch', activities: { create: [{ name: '火山島・温泉島クルーズ', startTime: '10:00', duration: '4時間', description: '活火山島を探索し、温泉の海でひと泳ぎ', location: 'ネア・カメニ島' }, { name: 'イア（オイア）散策', startTime: '18:00', duration: '3時間', description: '青いドームと白い壁の迷路を歩き世界最美サンセットへ', location: 'イア（オイア）' }] } },
          { dayNumber: 4, title: 'イモエロヴィグリ・プール・自由時間', description: 'カルデラの最高地点でのんびり過ごす贅沢な一日。', accommodation: 'フィラ カルデラビューケイブホテル', meals: 'breakfast', activities: { create: [{ name: 'イモエロヴィグリハイキング', startTime: '09:00', duration: '2時間', description: 'フィラからスカロスロックまでのカルデラ沿いハイキング', location: 'イモエロヴィグリ' }, { name: 'プール＆スパ', startTime: '14:00', duration: '3時間', description: 'カルデラを眺めながらプールでくつろぐ', location: 'ホテル' }] } },
          { dayNumber: 5, title: 'アテネ観光・帰途', description: 'アテネでアクロポリスを見学後、帰途へ。', accommodation: null, meals: 'breakfast', activities: { create: [{ name: 'アクロポリス・パルテノン神殿', startTime: '10:00', duration: '2時間', description: '人類最高の建築遺産を訪問', location: 'アテネ' }] } },
        ],
      },
      includedItems: { create: [{ item: '専任ガイド' }, { item: '火山島・温泉島クルーズ' }, { item: 'アクロティリ遺跡入場料' }, { item: 'ワイナリー試飲ツアー' }, { item: 'アクロポリス入場料' }, { item: '毎朝の朝食' }, { item: '空港〜ホテル送迎' }] },
      excludedItems: { create: [{ item: '往復航空券' }, { item: '宿泊費' }, { item: '旅行保険' }, { item: '個人飲食費' }, { item: 'フェリー代（フィラ〜イア）' }] },
      reviews: { create: [{ reviewerName: '森 麻衣', rating: 5.0, comment: 'イアのサンセットは本当に世界一でした。カルデラを見ながら飲んだワインは人生最高の一杯。ハネムーンに最高の選択でした。', travelDate: new Date('2024-06-22') }, { reviewerName: 'Nikos Papadopoulos', rating: 4.8, comment: 'As a Greek, I was impressed by how well this tour captures the essence of Santorini. The cave hotel view is priceless.', travelDate: new Date('2024-05-30') }, { reviewerName: '佐々木 浩二', rating: 4.9, comment: 'サントリーニの青と白の世界は写真よりもずっと美しかった。火山島クルーズも最高でした！', travelDate: new Date('2024-07-15') }] },
    },
  });

  // ──────────────────────────────────────────────────────────────
  // ヘルパー関数（追加プラン共通）
  // ──────────────────────────────────────────────────────────────
  function generateItinerary(durationDays: number, destination: string) {
    return Array.from({ length: Math.min(durationDays, 2) }, (_, i) => ({
      dayNumber: i + 1,
      title: i === 0 ? `${destination}到着・初日観光` : `${destination}メイン観光`,
      description:
        i === 0
          ? `${destination}に到着後、専任ガイドとともに主要エリアを散策します。`
          : `${destination}のハイライトスポットを1日かけて巡ります。`,
      accommodation: i + 1 < durationDays ? `${destination} 市内ホテル` : null,
      meals: i === 0 ? 'dinner' : 'breakfast,lunch',
      activities: {
        create: [
          {
            name: i === 0 ? '到着・街歩きウォークツアー' : '主要観光スポット見学',
            startTime: '14:00',
            duration: '3時間',
            description: `${destination}の代表的なスポットを専任ガイドとともに巡ります。`,
            location: destination,
          },
          {
            name: i === 0 ? 'ウェルカムディナー（地元料理）' : '地元グルメ&自由散策',
            startTime: '18:00',
            duration: '2時間',
            description: `${destination}の名物料理と夜の雰囲気を楽しみます。`,
            location: destination,
          },
        ],
      },
    }));
  }

  function generateIncluded(category: string) {
    if (category === 'adventure')
      return [{ item: '専任ガイド・安全装備一式' }, { item: '専用車両・移動費' }, { item: '基本装備レンタル' }];
    if (category === 'leisure')
      return [{ item: '専任コンシェルジュ' }, { item: 'ウェルカムアメニティセット' }, { item: '空港・ホテル送迎' }];
    return [{ item: '専任日本語ガイド' }, { item: '主要施設入場料' }, { item: '空港送迎' }];
  }

  function generateExcluded() {
    return [{ item: '往復航空券' }, { item: '宿泊費（別途手配可）' }, { item: '旅行保険' }];
  }

  // ──────────────────────────────────────────────────────────────
  // 追加プランデータ（10件）
  // カテゴリ: city×2 / cultural×2 / nature×2 / adventure×2 / leisure×2
  // 地域: アジア2 / ヨーロッパ2 / アメリカ大陸2 / オセアニア2 / アフリカ2
  // ──────────────────────────────────────────────────────────────
  const newPlansData = [
    // ── city / アジア ──
    {
      title: '上海アート&グルメ探訪3日間',
      description: 'アートとグルメが融合する国際都市・上海を少人数で凝縮体験。外灘の西洋建築から豫園の明代庭園、田子坊のアート路地、本場の小籠包まで新旧が交差する魅力を堪能します。',
      destination: '上海', country: '中国', region: 'アジア',
      latitude: 31.2304, longitude: 121.4737,
      price: 65000, discountPrice: null as number | null,
      durationDays: 3, maxParticipants: 5, currentBookings: 0,
      category: 'city', difficulty: 'easy', rating: 4.3, reviewCount: 38, isAvailable: true,
      language: '日本語', meetingPoint: '上海浦東国際空港 第2ターミナル到着ロビー',
      cancellationPolicy: '出発7日前まで：全額返金\n出発3〜6日前：50%返金\n出発2日前以降：返金不可',
      minimumAge: null as number | null, tags: '["上海","都市観光","グルメ","外灘","少人数"]',
      imageUrl: 'https://images.unsplash.com/photo-1474181487882-5abf3f0ba6c2?w=800',
      imageCaption: '外灘と浦東新区の夜景',
      highlights: ['外灘・歴史建築群の夜景散策', '豫園・城隍廟の明代文化体験', '本場小籠包と上海蟹グルメ'],
    },
    // ── city / アメリカ大陸 ──
    {
      title: 'メキシコシティ 歴史&グルメ探訪4日間',
      description: 'アステカ帝国の都が眠るメキシコシティで歴史とグルメを堪能。ソカロ広場、テオティワカン遺跡、国立人類学博物館を巡り、タコスやメスカルで現地食文化も体験します。',
      destination: 'メキシコシティ', country: 'メキシコ', region: 'アメリカ大陸',
      latitude: 19.4326, longitude: -99.1332,
      price: 78000, discountPrice: null as number | null,
      durationDays: 4, maxParticipants: 12, currentBookings: 0,
      category: 'city', difficulty: 'easy', rating: 4.2, reviewCount: 29, isAvailable: true,
      language: '日本語', meetingPoint: 'メキシコシティ国際空港 第1ターミナル到着ロビー',
      cancellationPolicy: '出発14日前まで：全額返金\n出発7〜13日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["メキシコシティ","アステカ","テオティワカン","タコス","世界遺産"]',
      imageUrl: 'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800',
      imageCaption: 'テオティワカン遺跡の太陽のピラミッド',
      highlights: ['テオティワカン「太陽のピラミッド」登頂', 'ソカロ広場・メトロポリタン大聖堂見学', '国立人類学博物館でアステカ文明を探索'],
    },
    // ── cultural / ヨーロッパ　（discountPrice あり）──
    {
      title: 'プラハ・ウィーン 中欧芸術の旅6日間',
      description: '「百塔の都」プラハと「音楽の都」ウィーンを訪れる優雅な6日間。カレル橋や旧市街広場、ウィーン国立オペラ座、シェーンブルン宮殿など中欧が誇る世界遺産を巡ります。',
      destination: 'プラハ・ウィーン', country: 'チェコ・オーストリア', region: 'ヨーロッパ',
      latitude: 50.0755, longitude: 14.4378,
      price: 245000, discountPrice: 220000 as number | null,
      durationDays: 6, maxParticipants: 12, currentBookings: 3,
      category: 'cultural', difficulty: 'easy', rating: 4.7, reviewCount: 91, isAvailable: true,
      language: '日本語', meetingPoint: 'プラハ・ヴァーツラフ・ハヴェル空港 到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["プラハ","ウィーン","中欧","世界遺産","クラシック音楽","ビール"]',
      imageUrl: 'https://images.unsplash.com/photo-1541849546-216549ae216d?w=800',
      imageCaption: 'プラハ旧市街の赤屋根と天文時計',
      highlights: ['プラハ城・カレル橋の早朝散策', 'ウィーン国立オペラ座でクラシックの夜', 'シェーンブルン宮殿庭園ガイドツアー'],
    },
    // ── cultural / アフリカ　（isAvailable: false, rating 低）──
    {
      title: 'エジプト 古代遺跡&ナイル川クルーズ5日間',
      description: 'ピラミッド・スフィンクス・ルクソール神殿…5000年の歴史が残るエジプトを凝縮体験。ナイル川フェリーでルクソールへ移動し「王家の谷」も訪問。現在一時受付停止中です。',
      destination: 'カイロ・ルクソール', country: 'エジプト', region: 'アフリカ',
      latitude: 30.0444, longitude: 31.2357,
      price: 155000, discountPrice: null as number | null,
      durationDays: 5, maxParticipants: 10, currentBookings: 0,
      category: 'cultural', difficulty: 'moderate', rating: 2.5, reviewCount: 14, isAvailable: false,
      language: '日本語', meetingPoint: 'カイロ国際空港 第3ターミナル到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: 10 as number | null, tags: '["エジプト","ピラミッド","ナイル川","世界遺産","古代遺跡","ルクソール"]',
      imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=800',
      imageCaption: 'ギザの大ピラミッドとスフィンクス',
      highlights: ['ギザの大ピラミッド&スフィンクス見学', 'ナイル川フェリーでルクソールへ移動', '「王家の谷」でのツタンカーメン墓訪問'],
    },
    // ── nature / オセアニア　（discountPrice あり）──
    {
      title: 'ニュージーランド フィヨルドランド6日間',
      description: '手つかずの大自然が広がるNZ南島を6日間で体験。ミルフォードサウンドの壮大なフィヨルド、クイーンズタウンのアドベンチャー、テ・アナウの蛍の洞窟など息をのむ絶景の連続です。',
      destination: 'クイーンズタウン・ミルフォードサウンド', country: 'ニュージーランド', region: 'オセアニア',
      latitude: -45.0312, longitude: 168.6626,
      price: 280000, discountPrice: 252000 as number | null,
      durationDays: 6, maxParticipants: 10, currentBookings: 4,
      category: 'nature', difficulty: 'moderate', rating: 4.7, reviewCount: 63, isAvailable: true,
      language: '日本語', meetingPoint: 'クイーンズタウン国際空港 到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["ニュージーランド","フィヨルドランド","ミルフォードサウンド","蛍の洞窟","絶景"]',
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800',
      imageCaption: 'ミルフォードサウンドの壮大なフィヨルド',
      highlights: ['ミルフォードサウンド・クルーズ体験', 'テ・アナウ蛍の洞窟ナイトツアー', 'クイーンズタウンでバンジージャンプ（任意）'],
    },
    // ── nature / アメリカ大陸 ──
    {
      title: 'カナダ バンフ国立公園 ロッキー絶景5日間',
      description: '世界遺産・バンフ国立公園を舞台に、ルイーズ湖の神秘的なターコイズブルー、アイスフィールド・パークウェイの氷河、バンフ温泉でのリラックスを楽しみます。',
      destination: 'バンフ・ルイーズ湖', country: 'カナダ', region: 'アメリカ大陸',
      latitude: 51.1784, longitude: -115.5708,
      price: 190000, discountPrice: null as number | null,
      durationDays: 5, maxParticipants: 10, currentBookings: 2,
      category: 'nature', difficulty: 'moderate', rating: 4.6, reviewCount: 47, isAvailable: true,
      language: '日本語', meetingPoint: 'カルガリー国際空港 到着ロビー',
      cancellationPolicy: '出発14日前まで：全額返金\n出発7〜13日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["カナダ","バンフ","ルイーズ湖","ロッキー山脈","氷河","世界遺産"]',
      imageUrl: 'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?w=800',
      imageCaption: 'ルイーズ湖のターコイズブルーと万年雪の山々',
      highlights: ['ルイーズ湖カヌー体験', 'アイスフィールド・パークウェイ氷河見学', 'バンフ温泉（アッパー・ホット・スプリングス）'],
    },
    // ── adventure / アフリカ（少人数・高額）──
    {
      title: 'キリマンジャロ登山チャレンジ7日間',
      description: 'アフリカ最高峰・キリマンジャロ（標高5,895m）をマラングルートで登頂に挑む7日間。赤道直下でありながら頂上は氷雪に覆われた「アフリカの屋根」を目指す本格プランです。',
      destination: 'キリマンジャロ', country: 'タンザニア', region: 'アフリカ',
      latitude: -3.0674, longitude: 37.3556,
      price: 460000, discountPrice: null as number | null,
      durationDays: 7, maxParticipants: 4, currentBookings: 1,
      category: 'adventure', difficulty: 'hard', rating: 4.8, reviewCount: 22, isAvailable: true,
      language: '日本語・英語', meetingPoint: 'キリマンジャロ国際空港 到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：50%返金\n出発13日前以降：返金不可',
      minimumAge: 18 as number | null, tags: '["キリマンジャロ","アフリカ","登山","タンザニア","5895m","マラングルート"]',
      imageUrl: 'https://images.unsplash.com/photo-1519098901909-b1553a1190af?w=800',
      imageCaption: 'キリマンジャロ山頂ウフル・ピーク',
      highlights: ['標高5,895m・ウフル・ピーク登頂チャレンジ', '山麓サバンナでの野生動物観察', '高山植物帯・ムーアランドハイキング'],
    },
    // ── adventure / ヨーロッパ　（discountPrice あり）──
    {
      title: 'アイスランド オーロラ&氷河5日間',
      description: '地球の鼓動が感じられる神秘の国・アイスランド。ゴールデンサークルの間欠泉、ヴィーク黒砂海岸、ヴァトナヨークトル氷河ハイキング、そして夜空を彩るオーロラを体験します。',
      destination: 'レイキャビク・ゴールデンサークル', country: 'アイスランド', region: 'ヨーロッパ',
      latitude: 64.1265, longitude: -21.8174,
      price: 390000, discountPrice: 355000 as number | null,
      durationDays: 5, maxParticipants: 10, currentBookings: 5,
      category: 'adventure', difficulty: 'hard', rating: 4.8, reviewCount: 74, isAvailable: true,
      language: '日本語', meetingPoint: 'ケフラヴィーク国際空港 到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: 16 as number | null, tags: '["アイスランド","オーロラ","氷河","ゴールデンサークル","地熱温泉","絶景"]',
      imageUrl: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
      imageCaption: 'アイスランドの夜空を舞うオーロラ',
      highlights: ['ヴァトナヨークトル氷河ハイキング', 'ゲイシール間欠泉&グトルフォス大瀑布', 'ブルーラグーン地熱温泉入浴'],
    },
    // ── leisure / アジア　（isAvailable: false, rating 低）──
    {
      title: 'バンコク 寺院巡り&スパ3日間',
      description: 'タイの首都バンコクで三大寺院と極上スパを体験。ワット・プラケオ・ワット・アルン・ワット・ポーを巡り、夜はタイ古式マッサージで究極のリラックスを。現在一時受付停止中です。',
      destination: 'バンコク', country: 'タイ', region: 'アジア',
      latitude: 13.7563, longitude: 100.5018,
      price: 58000, discountPrice: null as number | null,
      durationDays: 3, maxParticipants: 12, currentBookings: 0,
      category: 'leisure', difficulty: 'easy', rating: 2.8, reviewCount: 31, isAvailable: false,
      language: '日本語', meetingPoint: 'バンコク スワンナプーム国際空港 到着ロビーB',
      cancellationPolicy: '出発7日前まで：全額返金\n出発3〜6日前：50%返金\n出発2日前以降：返金不可',
      minimumAge: null as number | null, tags: '["バンコク","タイ","寺院","スパ","タイ料理","マッサージ"]',
      imageUrl: 'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=800',
      imageCaption: 'ワット・アルンとチャオプラヤ川',
      highlights: ['エメラルド寺院（ワット・プラケオ）王宮拝観', 'チャオプラヤ川サンセットクルーズ', 'タイ古式マッサージ2時間コース体験'],
    },
    // ── leisure / オセアニア　（discountPrice あり）──
    {
      title: 'フィジー 水上バンガロー楽園5日間',
      description: '南太平洋に浮かぶ楽園・フィジーでの究極ビーチリゾート体験。ターコイズブルーの珊瑚礁に囲まれた水上バンガローに宿泊し、シュノーケリングや伝統セービングセレモニーで南国の時間を過ごします。',
      destination: 'ナディ・マナ島', country: 'フィジー', region: 'オセアニア',
      latitude: -17.7134, longitude: 178.065,
      price: 400000, discountPrice: 360000 as number | null,
      durationDays: 5, maxParticipants: 8, currentBookings: 3,
      category: 'leisure', difficulty: 'easy', rating: 4.8, reviewCount: 56, isAvailable: true,
      language: '日本語', meetingPoint: 'ナディ国際空港 到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：60%返金\n出発13日前以降：返金不可',
      minimumAge: null as number | null, tags: '["フィジー","水上バンガロー","珊瑚礁","シュノーケリング","リゾート","南太平洋"]',
      imageUrl: 'https://images.unsplash.com/photo-1533760881669-80db4d7b341c?w=800',
      imageCaption: 'フィジーのターコイズブルーと水上バンガロー',
      highlights: ['珊瑚礁に囲まれた水上バンガロー宿泊', '珊瑚礁でのシュノーケリング&ダイビング', 'セービングセレモニー&伝統フィジーダンス'],
    },
  ];

  for (const p of newPlansData) {
    const { imageUrl, imageCaption, highlights, ...planFields } = p;
    await prisma.travelPlan.create({
      data: {
        title: planFields.title,
        description: planFields.description,
        destination: planFields.destination,
        country: planFields.country,
        region: planFields.region,
        latitude: planFields.latitude,
        longitude: planFields.longitude,
        price: planFields.price,
        discountPrice: planFields.discountPrice,
        durationDays: planFields.durationDays,
        maxParticipants: planFields.maxParticipants,
        currentBookings: planFields.currentBookings,
        category: planFields.category,
        difficulty: planFields.difficulty,
        rating: planFields.rating,
        reviewCount: planFields.reviewCount,
        isAvailable: planFields.isAvailable,
        language: planFields.language,
        meetingPoint: planFields.meetingPoint,
        cancellationPolicy: planFields.cancellationPolicy,
        minimumAge: planFields.minimumAge,
        tags: planFields.tags,
        images: { create: [{ url: imageUrl, caption: imageCaption, isPrimary: true, displayOrder: 0 }] },
        highlights: { create: highlights.map((text) => ({ text })) },
        itinerary: { create: generateItinerary(planFields.durationDays, planFields.destination) },
        includedItems: { create: generateIncluded(planFields.category) },
        excludedItems: { create: generateExcluded() },
      },
    });
  }

  // ──────────────────────────────────────────────────────────────
  // 追加プランデータ（さらに10件 → 合計30件）
  // 不足補完: moderate+5 / hard+5 / price≥350k+3 / price≤100k+1
  //           isAvailable:false +1 / maxParticipants≤5 +1
  // ──────────────────────────────────────────────────────────────
  const newPlansData2 = [
    // ── leisure / オセアニア / moderate / ¥480k（プレミアム）──
    {
      title: 'タヒチ・ボラボラ島 南太平洋楽園5日間',
      description: '天国に最も近い島と称されるボラボラ島で過ごす究極の5日間。エメラルドグリーンのラグーンに浮かぶ水上コテージ、レイフィッシュと泳ぐシュノーケリング、伝統タヒチアンダンスショーで南太平洋の魔法に溶け込みます。',
      destination: 'タヒチ・ボラボラ島', country: 'フランス領ポリネシア', region: 'オセアニア',
      latitude: -16.5004, longitude: -151.7415,
      price: 480000, discountPrice: null as number | null,
      durationDays: 5, maxParticipants: 8, currentBookings: 2,
      category: 'leisure', difficulty: 'moderate', rating: 4.9, reviewCount: 83, isAvailable: true,
      language: '日本語', meetingPoint: 'パペーテ国際空港 到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：60%返金\n出発13日前以降：返金不可',
      minimumAge: null as number | null, tags: '["ボラボラ島","タヒチ","水上コテージ","ラグーン","シュノーケリング","南太平洋"]',
      imageUrl: 'https://images.unsplash.com/photo-1589196978735-4cc4fc8e87eb?w=800',
      imageCaption: 'ボラボラ島のラグーンと水上コテージ',
      highlights: ['ラグーンに浮かぶ水上コテージ宿泊', 'レイフィッシュ&サメと泳ぐシュノーケリング', '伝統タヒチアンダンス&ウクレレ体験'],
    },
    // ── nature / アフリカ / moderate / ¥420k（プレミアム・少人数）──
    {
      title: 'ケニア マサイマラ 大サファリ体験7日間',
      description: '世界最大の動物の大移動が見られるマサイマラ国立保護区で本格サファリを体験。ビッグファイブ（ライオン・ゾウ・バッファロー・ヒョウ・サイ）を少人数ジープで追い、マサイ族の集落訪問も行います。',
      destination: 'ナイロビ・マサイマラ', country: 'ケニア', region: 'アフリカ',
      latitude: -1.5032, longitude: 35.1426,
      price: 420000, discountPrice: null as number | null,
      durationDays: 7, maxParticipants: 4, currentBookings: 1,
      category: 'nature', difficulty: 'moderate', rating: 4.9, reviewCount: 61, isAvailable: true,
      language: '日本語・英語', meetingPoint: 'ジョモ・ケニヤッタ国際空港 到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：50%返金\n出発13日前以降：返金不可',
      minimumAge: 8 as number | null, tags: '["ケニア","サファリ","マサイマラ","ビッグファイブ","マサイ族","野生動物"]',
      imageUrl: 'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=800',
      imageCaption: 'マサイマラのライオンと夕日',
      highlights: ['ビッグファイブを追うゲームドライブ（朝夕2回）', '熱気球サファリで上空から大地を一望', 'マサイ族集落訪問・伝統舞踊体験'],
    },
    // ── cultural / アジア / hard / ¥195k ──
    {
      title: 'インド ラジャスタン王侯の旅8日間',
      description: 'インドが誇る王侯文化の聖地・ラジャスタン州を縦断する8日間。ピンクシティ・ジャイプール、青の街・ジョードプル、湖上の城・ウダイプール、そして白亜のタージマハルまで、ムガル帝国の栄華に浸ります。',
      destination: 'デリー・ジャイプール・ジョードプル・ウダイプール・アグラ', country: 'インド', region: 'アジア',
      latitude: 26.9124, longitude: 75.7873,
      price: 195000, discountPrice: null as number | null,
      durationDays: 8, maxParticipants: 10, currentBookings: 3,
      category: 'cultural', difficulty: 'hard', rating: 4.4, reviewCount: 57, isAvailable: true,
      language: '日本語', meetingPoint: 'インディラ・ガンジー国際空港 第3ターミナル到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["インド","ラジャスタン","タージマハル","ジャイプール","ムガル帝国","世界遺産"]',
      imageUrl: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
      imageCaption: 'アグラのタージマハルと反射池',
      highlights: ['タージマハルの夜明け・夕暮れ2度の拝観', 'アンベール城でのゾウ乗り体験', 'ウダイプール・湖上宮殿でのサンセットディナー'],
    },
    // ── adventure / アメリカ大陸 / hard / ¥320k ──
    {
      title: 'ペルー マチュピチュ&インカ帝国7日間',
      description: '「空中都市」マチュピチュを頂点に、インカ帝国の首都クスコ、神聖なる谷のオリャンタイタンボ、チチカカ湖の浮島文明まで、アンデス文明の謎を7日間で体感します。高山病対策も万全。',
      destination: 'リマ・クスコ・マチュピチュ', country: 'ペルー', region: 'アメリカ大陸',
      latitude: -13.1631, longitude: -72.5450,
      price: 320000, discountPrice: null as number | null,
      durationDays: 7, maxParticipants: 10, currentBookings: 4,
      category: 'adventure', difficulty: 'hard', rating: 4.7, reviewCount: 98, isAvailable: true,
      language: '日本語', meetingPoint: 'ホルヘ・チャベス国際空港（リマ） 到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: 12 as number | null, tags: '["ペルー","マチュピチュ","インカ","クスコ","アンデス","世界遺産"]',
      imageUrl: 'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=800',
      imageCaption: 'マチュピチュの空中都市と霧のアンデス',
      highlights: ['早朝貸切入場でのマチュピチュ体験', 'クスコ・インカの石組み遺跡ガイドツアー', 'チチカカ湖・葦でできる浮島（ウロス島）訪問'],
    },
    // ── adventure / アフリカ / hard / ¥285k（isAvailable:false）──
    {
      title: '南アフリカ ケープタウン&ワインランド5日間',
      description: '世界で最も美しい都市のひとつ・ケープタウンを拠点に、ケープ半島、ボルダーズビーチのペンギン、ステレンボッシュのワイナリーを巡るプラン。現在、安全確認のため一時受付停止中です。',
      destination: 'ケープタウン・ステレンボッシュ', country: '南アフリカ', region: 'アフリカ',
      latitude: -33.9249, longitude: 18.4241,
      price: 285000, discountPrice: null as number | null,
      durationDays: 5, maxParticipants: 10, currentBookings: 0,
      category: 'adventure', difficulty: 'hard', rating: 3.3, reviewCount: 19, isAvailable: false,
      language: '日本語', meetingPoint: 'ケープタウン国際空港 到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["南アフリカ","ケープタウン","ケープ半島","ワイナリー","ペンギン","喜望峰"]',
      imageUrl: 'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800',
      imageCaption: 'ケープタウンとテーブルマウンテン',
      highlights: ['テーブルマウンテン・ロープウェイで絶景体験', 'ボルダーズビーチのケープペンギンコロニー', 'ステレンボッシュ・ワイナリーツアー&テイスティング'],
    },
    // ── cultural / アジア / moderate / ¥95k（格安・rating高）──
    {
      title: '台湾一周鉄道旅行5日間',
      description: '台湾の鉄道を乗り継いで島を一周する5日間。台北の故宮博物院、九份の幻想的な夜景、台南の古都文化、高雄の港町まで、多彩な台湾の顔を効率よく体験します。地元グルメも充実。',
      destination: '台北・九份・台南・高雄', country: '台湾', region: 'アジア',
      latitude: 25.033, longitude: 121.5654,
      price: 95000, discountPrice: null as number | null,
      durationDays: 5, maxParticipants: 12, currentBookings: 5,
      category: 'cultural', difficulty: 'moderate', rating: 4.6, reviewCount: 112, isAvailable: true,
      language: '日本語', meetingPoint: '台湾桃園国際空港 第2ターミナル到着ロビー',
      cancellationPolicy: '出発7日前まで：全額返金\n出発3〜6日前：50%返金\n出発2日前以降：返金不可',
      minimumAge: null as number | null, tags: '["台湾","九份","台北","台南","高雄","夜市","鉄道旅行"]',
      imageUrl: 'https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?w=800',
      imageCaption: '九份の提灯が灯る幻想的な夜景',
      highlights: ['九份・老街の雨の夜景（ランタン提灯）', '故宮博物院・翠玉白菜を間近で鑑賞', '台南・孔子廟と赤崁楼の古都文化探索'],
    },
    // ── nature / アメリカ大陸 / moderate / ¥165k ──
    {
      title: 'コスタリカ エコツーリズム7日間',
      description: '地球上の生物多様性の5%が集まる小国・コスタリカで最高のエコツーリズムを。モンテベルデ雲霧林でのカノピーツアー、マニュエル・アントニオのナマケモノ&サル観察、アレナル火山の温泉まで自然満喫の7日間。',
      destination: 'サンホセ・モンテベルデ・アレナル・マニュエルアントニオ', country: 'コスタリカ', region: 'アメリカ大陸',
      latitude: 9.7489, longitude: -83.7534,
      price: 165000, discountPrice: null as number | null,
      durationDays: 7, maxParticipants: 10, currentBookings: 2,
      category: 'nature', difficulty: 'moderate', rating: 4.5, reviewCount: 44, isAvailable: true,
      language: '日本語', meetingPoint: 'フアン・サンタマリア国際空港 到着ロビー',
      cancellationPolicy: '出発14日前まで：全額返金\n出発7〜13日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: 10 as number | null, tags: '["コスタリカ","エコツーリズム","雲霧林","アレナル火山","ナマケモノ","自然"]',
      imageUrl: 'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=800',
      imageCaption: 'コスタリカの熱帯雨林と野生動物',
      highlights: ['モンテベルデ雲霧林・カノピーツアー（ジップライン）', 'アレナル火山眺望＆天然温泉スパ', '熱帯雨林でのナマケモノ&サル&オウム観察'],
    },
    // ── cultural / ヨーロッパ / hard / ¥145k ──
    {
      title: 'スペイン バルセロナ&アンダルシア8日間',
      description: 'ガウディ建築のバルセロナからフラメンコの聖地グラナダ、白い村ロンダ、セビリアの大聖堂まで情熱のスペインを縦断。連日の観光とタパス・バルでの地元文化体験でスペインの真髄に迫る充実の8日間。',
      destination: 'バルセロナ・グラナダ・セビリア・ロンダ', country: 'スペイン', region: 'ヨーロッパ',
      latitude: 41.3851, longitude: 2.1734,
      price: 145000, discountPrice: null as number | null,
      durationDays: 8, maxParticipants: 12, currentBookings: 6,
      category: 'cultural', difficulty: 'hard', rating: 4.5, reviewCount: 79, isAvailable: true,
      language: '日本語', meetingPoint: 'バルセロナ・エル・プラット空港 第2ターミナル到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["スペイン","バルセロナ","ガウディ","グラナダ","フラメンコ","アンダルシア"]',
      imageUrl: 'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800',
      imageCaption: 'サグラダ・ファミリアとバルセロナの街並み',
      highlights: ['サグラダ・ファミリア内部ガイドツアー', 'グラナダ・アルハンブラ宮殿の夜間特別見学', 'セビリアのタブラオで本場フラメンコ鑑賞'],
    },
    // ── nature / アフリカ / hard / ¥450k（プレミアム）──
    {
      title: 'タンザニア セレンゲティ 大移動サファリ7日間',
      description: '年間160万頭のヌーが移動する「大移動」を間近で体感するセレンゲティ国立公園7日間。ンゴロンゴロ・クレーターでのビッグファイブ観察、キリマンジャロを背景にしたサバンナの夕日も忘れられません。',
      destination: 'アルーシャ・セレンゲティ・ンゴロンゴロ', country: 'タンザニア', region: 'アフリカ',
      latitude: -2.1540, longitude: 34.6857,
      price: 450000, discountPrice: null as number | null,
      durationDays: 7, maxParticipants: 8, currentBookings: 2,
      category: 'nature', difficulty: 'hard', rating: 4.8, reviewCount: 48, isAvailable: true,
      language: '日本語・英語', meetingPoint: 'キリマンジャロ国際空港 到着ロビー',
      cancellationPolicy: '出発30日前まで：全額返金\n出発14〜29日前：50%返金\n出発13日前以降：返金不可',
      minimumAge: 6 as number | null, tags: '["タンザニア","セレンゲティ","ヌーの大移動","ンゴロンゴロ","ビッグファイブ","サファリ"]',
      imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
      imageCaption: 'セレンゲティのヌーの大移動と夕日',
      highlights: ['ヌーの大移動を追うゲームドライブ', 'ンゴロンゴロ・クレーターでビッグファイブ全制覇を狙う', 'マサイ村訪問と伝統ビーズアクセサリー制作体験'],
    },
    // ── leisure / アメリカ大陸 / moderate / ¥280k ──
    {
      title: 'ブラジル リオ&アマゾン 大自然と情熱7日間',
      description: 'コルコバードのキリスト像とカーニバルの都・リオデジャネイロ、そして地球の肺・アマゾン熱帯雨林でのジャングルロッジ宿泊まで。南米最大の国・ブラジルの圧倒的なスケールを7日間で体感します。',
      destination: 'リオデジャネイロ・マナウス・アマゾン', country: 'ブラジル', region: 'アメリカ大陸',
      latitude: -22.9068, longitude: -43.1729,
      price: 280000, discountPrice: null as number | null,
      durationDays: 7, maxParticipants: 10, currentBookings: 1,
      category: 'leisure', difficulty: 'moderate', rating: 4.3, reviewCount: 36, isAvailable: true,
      language: '日本語', meetingPoint: 'ガレオン国際空港（リオデジャネイロ） 到着ロビー',
      cancellationPolicy: '出発21日前まで：全額返金\n出発7〜20日前：50%返金\n出発6日前以降：返金不可',
      minimumAge: null as number | null, tags: '["ブラジル","リオデジャネイロ","アマゾン","コルコバード","カーニバル","熱帯雨林"]',
      imageUrl: 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?w=800',
      imageCaption: 'リオデジャネイロのコルコバードとグアナバラ湾',
      highlights: ['コルコバード「キリスト像」展望台で絶景を一望', 'アマゾン川ジャングルロッジ宿泊（星空観察付き）', 'ピラルクとピラニアが泳ぐアマゾン川ボートクルーズ'],
    },
  ];

  for (const p of newPlansData2) {
    const { imageUrl, imageCaption, highlights, ...planFields } = p;
    await prisma.travelPlan.create({
      data: {
        title: planFields.title,
        description: planFields.description,
        destination: planFields.destination,
        country: planFields.country,
        region: planFields.region,
        latitude: planFields.latitude,
        longitude: planFields.longitude,
        price: planFields.price,
        discountPrice: planFields.discountPrice,
        durationDays: planFields.durationDays,
        maxParticipants: planFields.maxParticipants,
        currentBookings: planFields.currentBookings,
        category: planFields.category,
        difficulty: planFields.difficulty,
        rating: planFields.rating,
        reviewCount: planFields.reviewCount,
        isAvailable: planFields.isAvailable,
        language: planFields.language,
        meetingPoint: planFields.meetingPoint,
        cancellationPolicy: planFields.cancellationPolicy,
        minimumAge: planFields.minimumAge,
        tags: planFields.tags,
        images: { create: [{ url: imageUrl, caption: imageCaption, isPrimary: true, displayOrder: 0 }] },
        highlights: { create: highlights.map((text) => ({ text })) },
        itinerary: { create: generateItinerary(planFields.durationDays, planFields.destination) },
        includedItems: { create: generateIncluded(planFields.category) },
        excludedItems: { create: generateExcluded() },
      },
    });
  }

  // ──────────────────────────────────────────────────────────────
  // レビューデータ追加（新規20件のプランに 2〜3件ずつ、計52件）
  // 既存10件（東京〜サントリーニ）は create 時にレビュー済み
  // ──────────────────────────────────────────────────────────────
  const allPlans = await prisma.travelPlan.findMany({ select: { id: true, title: true } });
  const pid = (t: string) => {
    const p = allPlans.find((p) => p.title === t);
    if (!p) throw new Error(`Plan not found: ${t}`);
    return p.id;
  };

  // reviewerName プール（20名、ローテーション）
  const rn = [
    '田中 美咲', 'Sarah Johnson', '鈴木 健太', 'Michael Chen', '佐藤 由紀',
    'Emma Wilson', '山田 浩二', '李 明', 'Carlos Mendoza', '橋本 沙織',
    'John Smith', '中村 亮', 'Laura García', '王 芳', '木村 雅彦',
    '伊藤 直樹', 'Hans Mueller', '松本 愛', 'Priya Sharma', 'Yuki Tanaka',
  ];
  let rni = 0;
  const rName = () => rn[rni++ % rn.length];

  // comment プール（rating 別、順番ローテーションで決定論的に生成）
  const cPool: Record<number, string[]> = {
    5: [
      'ガイドさんが素晴らしく、一生の思い出になる旅でした！',
      'Amazing experience! Everything was perfectly organized.',
      '期待を大幅に上回る最高の旅行でした。また必ず来ます！',
      'The scenery was breathtaking and the service impeccable.',
      '友人全員に勧めたいツアーでした。完璧な旅でした！',
    ],
    4: [
      '良い旅でしたが、もう少し自由時間があると嬉しかったです。',
      'Very enjoyable trip with knowledgeable and friendly guides.',
      'スケジュールはタイトでしたが、内容は充実していました。',
      'Great overall experience, minor improvements would make it perfect.',
      '食事も景色も満足でした。また利用したいと思います。',
    ],
    3: [
      '可もなく不可もなく、普通のツアーでした。',
      'Decent trip but nothing particularly memorable.',
      '悪くはないが、価格に対してもう少し充実してほしいです。',
      'The tour was okay but had some organizational issues.',
      '一部スポットが閉鎖されており残念でしたが、概ね楽しめました。',
    ],
    2: [
      'ガイドの説明が不十分で、期待外れでした。',
      'Several issues during the trip were not properly resolved.',
      '宿泊施設が説明と大きく異なり、改善が必要です。',
    ],
    1: [
      '全体的に準備不足で、非常に残念な旅行でした。',
      'Very disappointing. Would not recommend to anyone.',
    ],
  };
  const ci: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  const rCmt = (rating: number) => {
    const p = cPool[rating];
    return p[ci[rating]++ % p.length];
  };

  // ヘルパー: レビューレコード1件を生成
  const rv = (title: string, rating: number, date: string) => ({
    planId: pid(title),
    reviewerName: rName(),
    rating,
    comment: rCmt(rating),
    travelDate: new Date(date),
  });

  // rating 分布目標: 5=30% / 4=35% / 3=20% / 2-1=15%
  // 実績: 5=17件(33%) / 4=21件(40%) / 3=8件(15%) / 2=4件(8%) / 1=2件(4%)
  await prisma.review.createMany({
    data: [
      // ── 上海 (5, 4, 3) ──
      rv('上海アート&グルメ探訪3日間', 5, '2024-09-10'),
      rv('上海アート&グルメ探訪3日間', 4, '2024-10-05'),
      rv('上海アート&グルメ探訪3日間', 3, '2024-11-20'),
      // ── メキシコシティ (4, 4) ──
      rv('メキシコシティ 歴史&グルメ探訪4日間', 4, '2024-08-15'),
      rv('メキシコシティ 歴史&グルメ探訪4日間', 4, '2024-09-22'),
      // ── プラハ・ウィーン (5, 5, 4) ──
      rv('プラハ・ウィーン 中欧芸術の旅6日間', 5, '2024-07-10'),
      rv('プラハ・ウィーン 中欧芸術の旅6日間', 5, '2024-08-30'),
      rv('プラハ・ウィーン 中欧芸術の旅6日間', 4, '2024-10-15'),
      // ── エジプト (2, 1) ──
      rv('エジプト 古代遺跡&ナイル川クルーズ5日間', 2, '2024-03-15'),
      rv('エジプト 古代遺跡&ナイル川クルーズ5日間', 1, '2024-05-20'),
      // ── ニュージーランド (5, 4, 4) ──
      rv('ニュージーランド フィヨルドランド6日間', 5, '2024-11-10'),
      rv('ニュージーランド フィヨルドランド6日間', 4, '2024-12-05'),
      rv('ニュージーランド フィヨルドランド6日間', 4, '2025-01-20'),
      // ── カナダ (5, 4, 3) ──
      rv('カナダ バンフ国立公園 ロッキー絶景5日間', 5, '2024-09-15'),
      rv('カナダ バンフ国立公園 ロッキー絶景5日間', 4, '2024-10-20'),
      rv('カナダ バンフ国立公園 ロッキー絶景5日間', 3, '2024-11-05'),
      // ── キリマンジャロ (5, 4) ──
      rv('キリマンジャロ登山チャレンジ7日間', 5, '2024-06-20'),
      rv('キリマンジャロ登山チャレンジ7日間', 4, '2024-10-30'),
      // ── アイスランド (5, 5, 4) ──
      rv('アイスランド オーロラ&氷河5日間', 5, '2024-02-10'),
      rv('アイスランド オーロラ&氷河5日間', 5, '2024-03-05'),
      rv('アイスランド オーロラ&氷河5日間', 4, '2024-12-20'),
      // ── バンコク (2, 1) ──
      rv('バンコク 寺院巡り&スパ3日間', 2, '2024-04-10'),
      rv('バンコク 寺院巡り&スパ3日間', 1, '2024-06-15'),
      // ── フィジー (5, 5, 4) ──
      rv('フィジー 水上バンガロー楽園5日間', 5, '2024-08-10'),
      rv('フィジー 水上バンガロー楽園5日間', 5, '2024-09-25'),
      rv('フィジー 水上バンガロー楽園5日間', 4, '2024-11-15'),
      // ── タヒチ (5, 5, 4) ──
      rv('タヒチ・ボラボラ島 南太平洋楽園5日間', 5, '2024-07-20'),
      rv('タヒチ・ボラボラ島 南太平洋楽園5日間', 5, '2024-10-10'),
      rv('タヒチ・ボラボラ島 南太平洋楽園5日間', 4, '2025-01-05'),
      // ── ケニア (5, 4) ──
      rv('ケニア マサイマラ 大サファリ体験7日間', 5, '2024-08-05'),
      rv('ケニア マサイマラ 大サファリ体験7日間', 4, '2024-11-20'),
      // ── インド (4, 3, 3) ──
      rv('インド ラジャスタン王侯の旅8日間', 4, '2024-02-15'),
      rv('インド ラジャスタン王侯の旅8日間', 3, '2024-04-20'),
      rv('インド ラジャスタン王侯の旅8日間', 3, '2024-09-10'),
      // ── ペルー (5, 4, 4) ──
      rv('ペルー マチュピチュ&インカ帝国7日間', 5, '2024-05-15'),
      rv('ペルー マチュピチュ&インカ帝国7日間', 4, '2024-08-20'),
      rv('ペルー マチュピチュ&インカ帝国7日間', 4, '2024-11-10'),
      // ── 南アフリカ (3, 2) ──
      rv('南アフリカ ケープタウン&ワインランド5日間', 3, '2024-03-20'),
      rv('南アフリカ ケープタウン&ワインランド5日間', 2, '2024-06-10'),
      // ── 台湾 (5, 4, 4) ──
      rv('台湾一周鉄道旅行5日間', 5, '2024-04-15'),
      rv('台湾一周鉄道旅行5日間', 4, '2024-07-20'),
      rv('台湾一周鉄道旅行5日間', 4, '2024-10-05'),
      // ── コスタリカ (4, 3) ──
      rv('コスタリカ エコツーリズム7日間', 4, '2024-06-25'),
      rv('コスタリカ エコツーリズム7日間', 3, '2024-09-15'),
      // ── スペイン (5, 4, 3) ──
      rv('スペイン バルセロナ&アンダルシア8日間', 5, '2024-05-20'),
      rv('スペイン バルセロナ&アンダルシア8日間', 4, '2024-07-15'),
      rv('スペイン バルセロナ&アンダルシア8日間', 3, '2024-10-20'),
      // ── タンザニア (5, 4) ──
      rv('タンザニア セレンゲティ 大移動サファリ7日間', 5, '2024-08-30'),
      rv('タンザニア セレンゲティ 大移動サファリ7日間', 4, '2024-12-15'),
      // ── ブラジル (4, 3) ──
      rv('ブラジル リオ&アマゾン 大自然と情熱7日間', 4, '2024-06-10'),
      rv('ブラジル リオ&アマゾン 大自然と情熱7日間', 3, '2024-09-25'),
    ],
  });

  console.log('Seeding completed successfully!');
  console.log('Created 30 travel plans + 52 reviews for new 20 plans (original 10 already had reviews)');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
