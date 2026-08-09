// Typed mock of PrismaClient scoped to methods used by planResolver and bookingResolver.
// Call resetPrismaMocks() in beforeEach to isolate each test's call history and return values.

export const prismaMock = {
  travelPlan: {
    findMany:   jest.fn(),
    findUnique: jest.fn(),
    count:      jest.fn(),
    update:     jest.fn(),
  },
  booking: {
    create:     jest.fn(),
    findMany:   jest.fn(),
    findUnique: jest.fn(),
    update:     jest.fn(),
  },
  $transaction: jest.fn(),
};

export function resetPrismaMocks(): void {
  (Object.values(prismaMock.travelPlan) as jest.Mock[]).forEach((fn) => fn.mockReset());
  (Object.values(prismaMock.booking)    as jest.Mock[]).forEach((fn) => fn.mockReset());
  prismaMock.$transaction.mockReset();
}
