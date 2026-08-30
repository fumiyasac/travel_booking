import { bookingResolvers } from '../../graphql/resolvers/bookingResolver';
import { prismaMock, resetPrismaMocks } from '../helpers/prismaMock';

// ── テスト共通ダミーデータ ───────────────────────────────────────
const now = new Date('2025-06-01T00:00:00Z');

const mockPlan = {
  id: 'plan-1',
  title: '東京エクスプローラー5日間',
  price: 150000,
  discountPrice: null,
  maxParticipants: 10,
  currentBookings: 2,
  isAvailable: true,
};

const mockBooking = {
  id: 'booking-1',
  planId: 'plan-1',
  plan: mockPlan,
  customerName: 'テスト太郎',
  customerEmail: 'test@example.com',
  customerPhone: '090-0000-0001',
  numberOfPeople: 2,
  travelDate: now,
  specialRequests: null,
  totalPrice: 300000,
  status: 'CONFIRMED',
  paymentMethod: null,
  createdAt: now,
  updatedAt: now,
};

const baseInput = {
  planId: 'plan-1',
  customerName: 'テスト太郎',
  customerEmail: 'test@example.com',
  customerPhone: '090-0000-0001',
  numberOfPeople: 2,
  travelDate: '2025-08-01',
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const ctx = { prisma: prismaMock as any };

// ── テスト ────────────────────────────────────────────────────────
describe('bookingResolvers', () => {
  beforeEach(() => {
    resetPrismaMocks();
  });

  // ────────────────────────────────────────────────────────────────
  describe('Mutation.createBooking', () => {
    // $transaction コールバックを実行する tx モック
    const tx = {
      travelPlan: { findUnique: jest.fn(), update: jest.fn() },
      booking:    { create: jest.fn() },
    };

    beforeEach(() => {
      [tx.travelPlan.findUnique, tx.travelPlan.update, tx.booking.create].forEach(
        (fn) => fn.mockReset(),
      );
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      prismaMock.$transaction.mockImplementation((cb: any) => cb(tx));
    });

    it('正常系: 予約が作成され success: true が返ること', async () => {
      tx.travelPlan.findUnique.mockResolvedValue(mockPlan);
      tx.booking.create.mockResolvedValue(mockBooking);
      tx.travelPlan.update.mockResolvedValue(mockPlan);

      const result = await bookingResolvers.Mutation.createBooking(
        undefined,
        { input: baseInput },
        ctx,
      );

      expect(result.success).toBe(true);
      expect(result.message).toBe('予約が完了しました');
      expect(result.booking?.id).toBe('booking-1');
    });

    it('$transaction が呼ばれていること', async () => {
      tx.travelPlan.findUnique.mockResolvedValue(mockPlan);
      tx.booking.create.mockResolvedValue(mockBooking);
      tx.travelPlan.update.mockResolvedValue(mockPlan);

      await bookingResolvers.Mutation.createBooking(
        undefined,
        { input: baseInput },
        ctx,
      );

      expect(prismaMock.$transaction).toHaveBeenCalledTimes(1);
    });

    it('存在しないプラン id: success: false と適切なメッセージが返ること', async () => {
      tx.travelPlan.findUnique.mockResolvedValue(null);

      const result = await bookingResolvers.Mutation.createBooking(
        undefined,
        { input: baseInput },
        ctx,
      );

      expect(result.success).toBe(false);
      expect(result.message).toBe('指定したプランが見つかりません');
      expect(result.booking).toBeNull();
    });

    it('isAvailable=false のプラン: success: false が返ること', async () => {
      tx.travelPlan.findUnique.mockResolvedValue({ ...mockPlan, isAvailable: false });

      const result = await bookingResolvers.Mutation.createBooking(
        undefined,
        { input: baseInput },
        ctx,
      );

      expect(result.success).toBe(false);
      expect(result.message).toBe('このプランは現在予約を受け付けていません');
    });

    it.each([
      ['customerName 空文字',    { ...baseInput, customerName: '' },         'customerName'],
      ['customerEmail 不正形式', { ...baseInput, customerEmail: 'invalid' }, 'customerEmail'],
      ['customerPhone 空文字',   { ...baseInput, customerPhone: '' },        'customerPhone'],
      ['numberOfPeople が 0',    { ...baseInput, numberOfPeople: 0 },        'numberOfPeople'],
    ])('バリデーション(%s): success: false でエラーメッセージにフィールド名が含まれること', async (_label, input, expectedField) => {
      const result = await bookingResolvers.Mutation.createBooking(
        undefined,
        { input },
        ctx,
      );

      expect(result.success).toBe(false);
      expect(result.message).toContain(expectedField);
      // バリデーションエラーは $transaction を呼ばない
      expect(prismaMock.$transaction).not.toHaveBeenCalled();
    });

    it('バリデーション(planId 空文字): success: false で planId エラーが返ること', async () => {
      const result = await bookingResolvers.Mutation.createBooking(
        undefined,
        { input: { ...baseInput, planId: '' } },
        ctx,
      );

      expect(result.success).toBe(false);
      expect(result.message).toContain('planId');
      expect(prismaMock.$transaction).not.toHaveBeenCalled();
    });

    it('バリデーション(不正なメールアドレス形式): success: false で customerEmail エラーが返ること', async () => {
      const result = await bookingResolvers.Mutation.createBooking(
        undefined,
        { input: { ...baseInput, customerEmail: 'not-an-email' } },
        ctx,
      );

      expect(result.success).toBe(false);
      expect(result.message).toContain('customerEmail');
      expect(prismaMock.$transaction).not.toHaveBeenCalled();
    });
  });

  // ────────────────────────────────────────────────────────────────
  describe('Mutation.cancelBooking', () => {
    const tx = {
      booking:    { findUnique: jest.fn(), update: jest.fn() },
      travelPlan: { update: jest.fn() },
    };

    beforeEach(() => {
      [tx.booking.findUnique, tx.booking.update, tx.travelPlan.update].forEach(
        (fn) => fn.mockReset(),
      );
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      prismaMock.$transaction.mockImplementation((cb: any) => cb(tx));
    });

    it('正常系: キャンセルが成功し success: true が返ること', async () => {
      const cancelledBooking = { ...mockBooking, status: 'CANCELLED' };
      tx.booking.findUnique.mockResolvedValue(mockBooking);
      tx.booking.update.mockResolvedValue(cancelledBooking);
      tx.travelPlan.update.mockResolvedValue(mockPlan);

      const result = await bookingResolvers.Mutation.cancelBooking(
        undefined,
        { id: 'booking-1' },
        ctx,
      );

      expect(result.success).toBe(true);
      expect(result.message).toBe('予約をキャンセルしました');
      expect(result.booking?.status).toBe('CANCELLED');
    });

    it('存在しない予約 id: success: false と適切なメッセージが返ること', async () => {
      tx.booking.findUnique.mockResolvedValue(null);

      const result = await bookingResolvers.Mutation.cancelBooking(
        undefined,
        { id: 'nonexistent' },
        ctx,
      );

      expect(result.success).toBe(false);
      expect(result.message).toBe('予約が見つかりません');
    });

    it('既にキャンセル済みの予約: success: false が返ること', async () => {
      tx.booking.findUnique.mockResolvedValue({ ...mockBooking, status: 'CANCELLED' });

      const result = await bookingResolvers.Mutation.cancelBooking(
        undefined,
        { id: 'booking-1' },
        ctx,
      );

      expect(result.success).toBe(false);
      expect(result.message).toBe('この予約はすでにキャンセル済みです');
    });
  });

  // ────────────────────────────────────────────────────────────────
  describe('Query.bookings', () => {
    it('正常系: customerEmail で絞り込んだ予約一覧が返ること', async () => {
      prismaMock.booking.findMany.mockResolvedValue([mockBooking]);

      const result = await bookingResolvers.Query.bookings(
        undefined,
        { customerEmail: 'test@example.com' },
        ctx,
      );

      expect(result).toHaveLength(1);
      expect(result[0].id).toBe('booking-1');
      expect(result[0].customerEmail).toBe('test@example.com');
    });

    it('該当なし: 空配列が返ること', async () => {
      prismaMock.booking.findMany.mockResolvedValue([]);

      const result = await bookingResolvers.Query.bookings(
        undefined,
        { customerEmail: 'nobody@example.com' },
        ctx,
      );

      expect(result).toEqual([]);
    });
  });
});
