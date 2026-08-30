import { GraphQLError } from 'graphql';
import { planResolvers } from '../../graphql/resolvers/planResolver';
import { prismaMock, resetPrismaMocks } from '../helpers/prismaMock';

// ── テスト共通ダミーデータ ───────────────────────────────────────
const now = new Date('2025-01-01T00:00:00Z');

const mockPlan = {
  id: 'plan-1',
  title: '東京エクスプローラー5日間',
  description: 'テスト説明',
  destination: '東京',
  country: '日本',
  region: 'アジア',
  latitude: 35.6762,
  longitude: 139.6503,
  price: 150000,
  discountPrice: null,
  durationDays: 5,
  maxParticipants: 10,
  currentBookings: 2,
  category: 'city',
  difficulty: 'easy',
  rating: 4.5,
  reviewCount: 10,
  isAvailable: true,
  availableFrom: null,
  availableTo: null,
  language: '日本語',
  meetingPoint: '東京駅',
  cancellationPolicy: '出発7日前まで無料キャンセル',
  minimumAge: null,
  tags: '["観光","グルメ"]',
  images: [],
  highlights: [],
  itinerary: [],
  includedItems: [],
  excludedItems: [],
  reviews: [],
  createdAt: now,
  updatedAt: now,
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const ctx = { prisma: prismaMock as any };

// ── テスト ────────────────────────────────────────────────────────
describe('planResolvers', () => {
  beforeEach(() => {
    resetPrismaMocks();
  });

  // ────────────────────────────────────────────────────────────────
  describe('Query.travelPlans', () => {
    it('正常系: プラン一覧と集計情報が返ること', async () => {
      prismaMock.travelPlan.findMany.mockResolvedValue([mockPlan]);
      prismaMock.travelPlan.count.mockResolvedValue(1);

      const result = await planResolvers.Query.travelPlans(undefined, {}, ctx);

      expect(result.plans).toHaveLength(1);
      expect(result.totalCount).toBe(1);
      expect(result.hasNextPage).toBe(false);
      expect(result.currentPage).toBe(1);
      expect(result.totalPages).toBe(1);
    });

    it('formatPlan: tags がパースされ availableSpots / effectivePrice が付与されること', async () => {
      prismaMock.travelPlan.findMany.mockResolvedValue([mockPlan]);
      prismaMock.travelPlan.count.mockResolvedValue(1);

      const { plans } = await planResolvers.Query.travelPlans(undefined, {}, ctx);

      expect(plans[0].tags).toEqual(['観光', 'グルメ']);
      expect(plans[0].availableSpots).toBe(8);   // 10 - 2
      expect(plans[0].effectivePrice).toBe(150000); // discountPrice=null なので price をそのまま使用
    });

    it('ページネーション: page=2 / pageSize=5 で skip=5, take=5 が渡されること', async () => {
      prismaMock.travelPlan.findMany.mockResolvedValue([]);
      prismaMock.travelPlan.count.mockResolvedValue(10);

      await planResolvers.Query.travelPlans(undefined, { page: 2, pageSize: 5 }, ctx);

      expect(prismaMock.travelPlan.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ skip: 5, take: 5 }),
      );
    });

    it('ページネーション: 10件中 pageSize=3 の page=1 では hasNextPage=true になること', async () => {
      prismaMock.travelPlan.findMany.mockResolvedValue([mockPlan]);
      prismaMock.travelPlan.count.mockResolvedValue(10);

      const result = await planResolvers.Query.travelPlans(undefined, { page: 1, pageSize: 3 }, ctx);

      expect(result.hasNextPage).toBe(true);
      expect(result.totalPages).toBe(4); // ceil(10/3) = 4
    });

    it.each([
      ['category',   { category: 'city' },    { category: 'city' }],
      ['region',     { region: 'アジア' },     { region: 'アジア' }],
      ['difficulty', { difficulty: 'easy' },  { difficulty: 'easy' }],
    ])('フィルタ(%s): where 句に正しく反映されること', async (_label, filter, expectedWhere) => {
      prismaMock.travelPlan.findMany.mockResolvedValue([]);
      prismaMock.travelPlan.count.mockResolvedValue(0);

      await planResolvers.Query.travelPlans(undefined, { filter }, ctx);

      expect(prismaMock.travelPlan.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ where: expect.objectContaining(expectedWhere) }),
      );
    });

    it('空結果: 0件の場合 plans=[] / totalCount=0 / hasNextPage=false が返ること', async () => {
      prismaMock.travelPlan.findMany.mockResolvedValue([]);
      prismaMock.travelPlan.count.mockResolvedValue(0);

      const result = await planResolvers.Query.travelPlans(undefined, {}, ctx);

      expect(result.plans).toEqual([]);
      expect(result.totalCount).toBe(0);
      expect(result.hasNextPage).toBe(false);
    });

    it('バリデーション: 不正な category 値で VALIDATION_ERROR が発生すること', async () => {
      await expect(
        planResolvers.Query.travelPlans(undefined, { filter: { category: 'invalid' } }, ctx),
      ).rejects.toMatchObject({
        extensions: { code: 'VALIDATION_ERROR' },
      });
      expect(prismaMock.travelPlan.findMany).not.toHaveBeenCalled();
    });

    it('バリデーション: minPrice > maxPrice で VALIDATION_ERROR が発生すること', async () => {
      await expect(
        planResolvers.Query.travelPlans(
          undefined,
          { filter: { minPrice: 50000, maxPrice: 10000 } },
          ctx,
        ),
      ).rejects.toMatchObject({
        extensions: { code: 'VALIDATION_ERROR' },
      });
      expect(prismaMock.travelPlan.findMany).not.toHaveBeenCalled();
    });
  });

  // ────────────────────────────────────────────────────────────────
  describe('Query.travelPlan', () => {
    it('正常系: id 指定でプランが返ること', async () => {
      prismaMock.travelPlan.findUnique.mockResolvedValue(mockPlan);

      const result = await planResolvers.Query.travelPlan(undefined, { id: 'plan-1' }, ctx);

      expect(result).not.toBeNull();
      expect(result!.id).toBe('plan-1');
      expect(result!.title).toBe('東京エクスプローラー5日間');
    });

    it('存在しない id: null が返ること', async () => {
      prismaMock.travelPlan.findUnique.mockResolvedValue(null);

      const result = await planResolvers.Query.travelPlan(undefined, { id: 'nonexistent' }, ctx);

      expect(result).toBeNull();
    });
  });
});
