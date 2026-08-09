import { prismaMock, resetPrismaMocks } from './helpers/prismaMock';

describe('prismaMock setup', () => {
  beforeEach(() => {
    resetPrismaMocks();
  });

  it('prismaMock has expected shape', () => {
    expect(typeof prismaMock.travelPlan.findMany).toBe('function');
    expect(typeof prismaMock.travelPlan.findUnique).toBe('function');
    expect(typeof prismaMock.travelPlan.count).toBe('function');
    expect(typeof prismaMock.travelPlan.update).toBe('function');
    expect(typeof prismaMock.booking.create).toBe('function');
    expect(typeof prismaMock.booking.findMany).toBe('function');
    expect(typeof prismaMock.booking.findUnique).toBe('function');
    expect(typeof prismaMock.booking.update).toBe('function');
    expect(typeof prismaMock.$transaction).toBe('function');
  });

  it('resetPrismaMocks clears call history', () => {
    prismaMock.travelPlan.findMany.mockResolvedValueOnce([]);
    prismaMock.travelPlan.findMany({});
    expect(prismaMock.travelPlan.findMany).toHaveBeenCalledTimes(1);

    resetPrismaMocks();

    expect(prismaMock.travelPlan.findMany).toHaveBeenCalledTimes(0);
  });
});
