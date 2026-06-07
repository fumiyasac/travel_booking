# データパターン リファレンス

seed.ts の `prisma.travelPlan.create` パターンに準拠したコードスニペット集。
スキルがデータ生成時に参照する。

---

## 通常プラン

条件なし。`isAvailable: true`、割引なし、空き枠あり。

```typescript
await prisma.travelPlan.create({
  data: {
    title: 'ローマ歴史探訪5日間',
    description: '永遠の都ローマで歴史と美食を堪能する5日間。コロッセオ・バチカン美術館の優先入場、トレヴィの泉でのコイン投げ体験、本場カルボナーラ作り教室まで、ローマの魅力を凝縮したプランです。',
    destination: 'ローマ',
    country: 'イタリア',
    region: 'ヨーロッパ',
    latitude: 41.9028,
    longitude: 12.4964,
    price: 220000,
    discountPrice: null,
    durationDays: 5,
    maxParticipants: 12,
    currentBookings: 3,
    category: 'history',
    difficulty: 'easy',
    rating: 4.3,
    reviewCount: 45,
    isAvailable: true,
    language: '日本語',
    meetingPoint: 'ローマ フィウミチーノ空港 第3ターミナル 到着ホール',
    cancellationPolicy: '出発14日前まで：全額返金\n出発7〜13日前：50%返金\n出発6日前以降：返金不可',
    minimumAge: null,
    tags: JSON.stringify(['ローマ', 'イタリア', '歴史', 'グルメ', 'バチカン']),
    images: {
      create: [
        { url: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800', caption: 'コロッセオ', isPrimary: true, displayOrder: 0 },
        { url: 'https://images.unsplash.com/photo-1555992336-fb0d29498b13?w=800', caption: 'トレヴィの泉', isPrimary: false, displayOrder: 1 },
      ],
    },
    highlights: {
      create: [
        { text: 'コロッセオ・フォロロマーノ優先入場（待ち時間なし）' },
        { text: 'バチカン美術館・システィーナ礼拝堂プライベートツアー' },
        { text: '本場シェフによるカルボナーラ・ティラミス作り体験' },
      ],
    },
  },
});
```

---

## soldOut（満席）

`currentBookings === maxParticipants` かつ `isAvailable: true`。
予約は受け付けているが空き枠がゼロの状態。

```typescript
await prisma.travelPlan.create({
  data: {
    title: 'バルセロナ・ガウディ建築巡り6日間',
    description: 'サグラダ・ファミリアからグエル公園まで、ガウディの奇跡的な建築を余すところなく体験する6日間。フラメンコショー観覧、バルセロナ市場でのスパニッシュ料理体験も含まれます。',
    destination: 'バルセロナ',
    country: 'スペイン',
    region: 'ヨーロッパ',
    latitude: 41.3851,
    longitude: 2.1734,
    price: 260000,
    discountPrice: null,
    durationDays: 6,
    maxParticipants: 10,
    currentBookings: 10,   // ← maxParticipants と同じ値で満席
    category: 'culture',
    difficulty: 'easy',
    rating: 4.6,
    reviewCount: 89,
    isAvailable: true,     // ← 募集中だが空きゼロ
    language: '日本語',
    meetingPoint: 'バルセロナ・エル・プラット国際空港 第1ターミナル 到着ホール',
    cancellationPolicy: '出発14日前まで：全額返金\n出発7〜13日前：50%返金\n出発6日前以降：返金不可',
    minimumAge: null,
    tags: JSON.stringify(['バルセロナ', 'スペイン', 'ガウディ', '建築', 'フラメンコ']),
    images: {
      create: [
        { url: 'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800', caption: 'サグラダ・ファミリア', isPrimary: true, displayOrder: 0 },
        { url: 'https://images.unsplash.com/photo-1562979314-bee7453e911c?w=800', caption: 'グエル公園', isPrimary: false, displayOrder: 1 },
      ],
    },
    highlights: {
      create: [
        { text: 'サグラダ・ファミリア塔内部への優先入場' },
        { text: 'グエル公園プライベートガイドツアー（開園前入場）' },
        { text: 'ボケリア市場での本場パエリア調理体験' },
      ],
    },
  },
});
```

---

## discounted（割引中）

`discountPrice` が `price` の 70% 以下。
早期割引・シーズンオフ割引などのシナリオに使用。

```typescript
await prisma.travelPlan.create({
  data: {
    title: 'カナダ・ロッキー山脈大自然8日間',
    description: 'バンフ国立公園を拠点にロッキー山脈の壮大な自然を体験する8日間。モレーン湖のエメラルドグリーン、ジャスパーでのオーロラ観測、ホワイトウォーターラフティングまで盛りだくさんです。',
    destination: 'バンフ',
    country: 'カナダ',
    region: '北アメリカ',
    latitude: 51.1784,
    longitude: -115.5708,
    price: 380000,
    discountPrice: 248000,  // ← price の約 65%（70% 以下）
    durationDays: 8,
    maxParticipants: 8,
    currentBookings: 2,
    category: 'nature',
    difficulty: 'moderate',
    rating: 4.4,
    reviewCount: 62,
    isAvailable: true,
    language: '日本語',
    meetingPoint: 'カルガリー国際空港 到着ホール',
    cancellationPolicy: '出発30日前まで：全額返金\n出発15〜29日前：60%返金\n出発14日前以降：返金不可',
    minimumAge: 12,
    tags: JSON.stringify(['カナダ', 'ロッキー山脈', '自然', 'オーロラ', 'アドベンチャー', '割引']),
    images: {
      create: [
        { url: 'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?w=800', caption: 'モレーン湖', isPrimary: true, displayOrder: 0 },
        { url: 'https://images.unsplash.com/photo-1472396961693-142e6e269027?w=800', caption: 'バンフ国立公園', isPrimary: false, displayOrder: 1 },
      ],
    },
    highlights: {
      create: [
        { text: 'モレーン湖・ルイーズ湖カヌー体験' },
        { text: 'ジャスパーでのオーロラ観測ツアー（条件付き保証）' },
        { text: 'コロンビア大氷原アイスフィールド・スカイウォーク' },
      ],
    },
  },
});
```

---

## unavailable（募集停止）

`isAvailable: false`。メンテナンス中・シーズンオフ・一時休止などのシナリオ。

```typescript
await prisma.travelPlan.create({
  data: {
    title: 'アイスランド・オーロラと絶景7日間',
    description: '北欧の秘境アイスランドで神秘的なオーロラと壮大な自然を体験する7日間。ゴールデンサークル観光、ブルーラグーン温泉、氷河ハイキングなど見どころ満載のプランです。',
    destination: 'レイキャヴィーク',
    country: 'アイスランド',
    region: 'ヨーロッパ',
    latitude: 64.1355,
    longitude: -21.8954,
    price: 420000,
    discountPrice: null,
    durationDays: 7,
    maxParticipants: 8,
    currentBookings: 0,
    category: 'nature',
    difficulty: 'moderate',
    rating: 4.7,
    reviewCount: 34,
    isAvailable: false,    // ← 募集停止
    language: '日本語',
    meetingPoint: 'ケフラヴィーク国際空港 到着ホール',
    cancellationPolicy: '出発30日前まで：全額返金\n出発15〜29日前：50%返金\n出発14日前以降：返金不可',
    minimumAge: null,
    tags: JSON.stringify(['アイスランド', 'オーロラ', '自然', '温泉', '氷河', '募集停止']),
    images: {
      create: [
        { url: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800', caption: 'オーロラ', isPrimary: true, displayOrder: 0 },
        { url: 'https://images.unsplash.com/photo-1476610182048-b716b8518aae?w=800', caption: 'ブルーラグーン', isPrimary: false, displayOrder: 1 },
      ],
    },
    highlights: {
      create: [
        { text: 'オーロラ鑑賞ナイトツアー（ガイド付き）' },
        { text: 'ブルーラグーン温泉プレミアムパッケージ' },
        { text: 'ゴールデンサークル（ゲイシール・グトルフォス）終日観光' },
      ],
    },
  },
});
```

---

## highRating（高評価）

`rating` が 4.5 以上、`reviewCount` が 100 件以上。
人気プランとして一覧上位に表示されるシナリオ。

```typescript
await prisma.travelPlan.create({
  data: {
    title: 'ニュージーランド南島・大自然冒険10日間',
    description: '映画「ロード・オブ・ザ・リング」のロケ地として知られるニュージーランド南島を10日間かけて縦断。ミルフォードサウンドクルーズ、バンジージャンプ発祥の地クイーンズタウン、南十字星を望む星空ツアーなど、一生の思い出になる体験が満載です。',
    destination: 'クライストチャーチ',
    country: 'ニュージーランド',
    region: 'オセアニア',
    latitude: -43.5321,
    longitude: 172.6362,
    price: 480000,
    discountPrice: null,
    durationDays: 10,
    maxParticipants: 8,
    currentBookings: 5,
    category: 'adventure',
    difficulty: 'hard',
    rating: 4.9,           // ← 4.5 以上
    reviewCount: 143,      // ← 100 件以上
    isAvailable: true,
    language: '日本語',
    meetingPoint: 'クライストチャーチ国際空港 到着ホール',
    cancellationPolicy: '出発30日前まで：全額返金\n出発15〜29日前：70%返金\n出発14日前以降：返金不可',
    minimumAge: 16,
    tags: JSON.stringify(['ニュージーランド', '南島', 'アドベンチャー', 'ミルフォード', '星空', '高評価']),
    images: {
      create: [
        { url: 'https://images.unsplash.com/photo-1507699622108-4be3abd695ad?w=800', caption: 'ミルフォードサウンド', isPrimary: true, displayOrder: 0 },
        { url: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800', caption: 'クイーンズタウンの山岳', isPrimary: false, displayOrder: 1 },
      ],
    },
    highlights: {
      create: [
        { text: 'ミルフォードサウンド終日クルーズ（ランチ付き）' },
        { text: 'クイーンズタウン・バンジージャンプまたはスカイダイビング体験' },
        { text: 'テカポ湖での星空観測ツアー（天体望遠鏡使用）' },
        { text: 'マウントクック国立公園ガイドハイキング' },
      ],
    },
  },
});
```
