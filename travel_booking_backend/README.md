# Travel Booking Backend

GraphQL API server built with TypeScript, Apollo Server 4, Prisma ORM, and MySQL.

## Tech Stack

- **Runtime**: Node.js 20+
- **Language**: TypeScript
- **API**: Apollo Server 4 (GraphQL)
- **ORM**: Prisma 5
- **Database**: MySQL 8.0
- **Container**: Docker + Docker Compose

## Quick Start

### Prerequisites
- Docker & Docker Compose V2 (`docker compose` コマンドが使えること)
- Node.js 20+ (Docker を使わないローカル開発時のみ)

### 1. Environment Setup

```bash
cp .env.example .env
```

### 2. Start with Docker

```bash
# Start MySQL + Backend
docker compose up -d

# Run database migrations (MySQL の起動完了まで少し待ってから実行)
docker compose exec backend npm run db:migrate

# Seed the database with sample data
docker compose exec backend npm run db:seed
```

> **Note:** Dockerfile は `npm install` でパッケージをインストールするため、`package-lock.json` がなくても動作します。

The GraphQL server will be available at: `http://localhost:4000/graphql`

### 3. Local Development (without Docker)

```bash
# Install dependencies
npm install

# Set up database (requires MySQL running locally)
npm run db:generate
npm run db:migrate

# Seed sample data
npm run db:seed

# Start dev server with hot reload
npm run dev
```

## GraphQL API

### Queries

#### Get Travel Plans (with filters)
```graphql
query GetTravelPlans($filter: PlanFilterInput, $page: Int, $pageSize: Int) {
  travelPlans(filter: $filter, page: $page, pageSize: $pageSize) {
    plans {
      id
      title
      destination
      country
      price
      discountPrice
      rating
      durationDays
      category
      difficulty
    }
    totalCount
    hasNextPage
    currentPage
    totalPages
  }
}
```

#### Filter Variables
```json
{
  "filter": {
    "keyword": "東京",
    "category": "city",
    "region": "アジア",
    "minPrice": 100000,
    "maxPrice": 300000,
    "maxDuration": 7,
    "difficulty": "easy",
    "sortBy": "rating",
    "sortOrder": "DESC"
  },
  "page": 1,
  "pageSize": 10
}
```

#### Get Single Plan (Full Detail)
```graphql
query GetTravelPlan($id: ID!) {
  travelPlan(id: $id) {
    id
    title
    description
    destination
    country
    latitude
    longitude
    price
    discountPrice
    effectivePrice
    availableSpots
    itinerary {
      dayNumber
      title
      description
      activities {
        name
        startTime
        duration
        description
      }
    }
    reviews {
      reviewerName
      rating
      comment
    }
  }
}
```

### Mutations

#### Create Booking
```graphql
mutation CreateBooking($input: CreateBookingInput!) {
  createBooking(input: $input) {
    success
    message
    booking {
      id
      status
      totalPrice
      travelDate
    }
  }
}
```

Variables:
```json
{
  "input": {
    "planId": "plan-uuid-here",
    "customerName": "山田 太郎",
    "customerEmail": "yamada@example.com",
    "customerPhone": "090-1234-5678",
    "numberOfPeople": 2,
    "travelDate": "2025-08-01T00:00:00.000Z",
    "specialRequests": "アレルギー：甲殻類"
  }
}
```

#### Cancel Booking
```graphql
mutation CancelBooking($id: ID!) {
  cancelBooking(id: $id) {
    success
    message
  }
}
```

## Database Management

> **Docker 環境の場合:** 各コマンドの先頭に `docker compose exec backend` を付けてください。  
> 例: `docker compose exec backend npm run db:studio`

```bash
# Open Prisma Studio (GUI for DB)
npm run db:studio

# Push schema changes without migration files (prototyping)
npm run db:push

# Reset database (WARNING: deletes all data)
npm run db:reset

# Generate Prisma client
npm run db:generate

# Run migrations in production
npm run db:migrate:prod
```

## Filter Options

| Field | Values |
|-------|--------|
| category | city, cultural, nature, adventure, leisure |
| region | アジア, ヨーロッパ, アメリカ大陸, オセアニア, アフリカ |
| difficulty | easy, moderate, hard |
| sortBy | rating, price, duration, createdAt |
| sortOrder | ASC, DESC |

## Sample Data

After seeding, the following 10 travel plans are available:

1. 東京エクスプローラー5日間 (Tokyo, city, ¥150,000)
2. 京都伝統文化探訪4日間 (Kyoto, cultural, ¥120,000)
3. 北海道大自然アドベンチャー7日間 (Hokkaido, nature, ¥200,000)
4. パリ・ロマンス＆カルチャー6日間 (Paris, leisure, ¥280,000)
5. スイスアルプス トレッキング8日間 (Swiss Alps, adventure, ¥350,000)
6. バリ島スピリチュアルリトリート5日間 (Bali, leisure, ¥100,000)
7. ニューヨーク・シティ・エクスペリエンス4日間 (NYC, city, ¥180,000)
8. オーストラリア グレートバリアリーフ6日間 (Cairns, adventure, ¥320,000)
9. モロッコ砂漠とメディナ7日間 (Morocco, adventure, ¥160,000)
10. サントリーニ島 エーゲ海5日間 (Santorini, leisure, ¥250,000)
