import { Prisma } from '@prisma/client';
import { Context } from '../../index';

export interface PlanFilterInput {
  keyword?: string;
  category?: string;
  region?: string;
  minPrice?: number;
  maxPrice?: number;
  maxDuration?: number;
  difficulty?: string;
  sortBy?: string;
  sortOrder?: string;
}

const PLAN_INCLUDE = {
  images: { orderBy: { displayOrder: 'asc' as const } },
  highlights: true,
  itinerary: {
    orderBy: { dayNumber: 'asc' as const },
    include: { activities: true },
  },
  includedItems: true,
  excludedItems: true,
  reviews: { orderBy: { createdAt: 'desc' as const } },
};

function buildPlanWhereClause(filter?: PlanFilterInput): Prisma.TravelPlanWhereInput {
  if (!filter) return {};

  const where: Prisma.TravelPlanWhereInput = {};

  if (filter.keyword) {
    const keyword = filter.keyword;
    where.OR = [
      { title: { contains: keyword } },
      { description: { contains: keyword } },
      { destination: { contains: keyword } },
      { country: { contains: keyword } },
      { tags: { contains: keyword } },
    ];
  }

  if (filter.category) {
    where.category = filter.category;
  }

  if (filter.region) {
    where.region = filter.region;
  }

  if (filter.difficulty) {
    where.difficulty = filter.difficulty;
  }

  if (filter.minPrice !== undefined || filter.maxPrice !== undefined) {
    where.price = {};
    if (filter.minPrice !== undefined) {
      where.price.gte = filter.minPrice;
    }
    if (filter.maxPrice !== undefined) {
      where.price.lte = filter.maxPrice;
    }
  }

  if (filter.maxDuration !== undefined) {
    where.durationDays = { lte: filter.maxDuration };
  }

  where.isAvailable = true;

  return where;
}

function buildOrderByClause(
  sortBy?: string,
  sortOrder?: string,
): Prisma.TravelPlanOrderByWithRelationInput {
  const order = sortOrder?.toLowerCase() === 'asc' ? 'asc' : 'desc';

  switch (sortBy) {
    case 'price':
      return { price: order };
    case 'rating':
      return { rating: order };
    case 'duration':
      return { durationDays: order };
    case 'createdAt':
      return { createdAt: order };
    default:
      return { rating: 'desc' };
  }
}

function parseTags(tagsJson: string): string[] {
  try {
    return JSON.parse(tagsJson) as string[];
  } catch {
    return [];
  }
}

function formatPlan(plan: any) {
  return {
    ...plan,
    tags: parseTags(plan.tags),
    availableSpots: plan.maxParticipants - plan.currentBookings,
    effectivePrice: plan.discountPrice ?? plan.price,
    availableFrom: plan.availableFrom?.toISOString() ?? null,
    availableTo: plan.availableTo?.toISOString() ?? null,
    createdAt: plan.createdAt.toISOString(),
    updatedAt: plan.updatedAt.toISOString(),
    reviews: (plan.reviews ?? []).map((r: any) => ({
      ...r,
      travelDate: r.travelDate.toISOString(),
      createdAt: r.createdAt.toISOString(),
    })),
  };
}

export const planResolvers = {
  Query: {
    travelPlans: async (
      _: unknown,
      args: { filter?: PlanFilterInput; page?: number; pageSize?: number },
      { prisma }: Context,
    ) => {
      const page = Math.max(1, args.page ?? 1);
      const pageSize = Math.min(50, Math.max(1, args.pageSize ?? 20));
      const skip = (page - 1) * pageSize;

      const where = buildPlanWhereClause(args.filter);
      const orderBy = buildOrderByClause(args.filter?.sortBy, args.filter?.sortOrder);

      const [plans, totalCount] = await Promise.all([
        prisma.travelPlan.findMany({
          where,
          orderBy,
          skip,
          take: pageSize,
          include: PLAN_INCLUDE,
        }),
        prisma.travelPlan.count({ where }),
      ]);

      const totalPages = Math.ceil(totalCount / pageSize);

      return {
        plans: plans.map(formatPlan),
        totalCount,
        hasNextPage: page < totalPages,
        currentPage: page,
        totalPages,
      };
    },

    travelPlan: async (_: unknown, args: { id: string }, { prisma }: Context) => {
      const plan = await prisma.travelPlan.findUnique({
        where: { id: args.id },
        include: PLAN_INCLUDE,
      });

      if (!plan) return null;

      return formatPlan(plan);
    },
  },
};
