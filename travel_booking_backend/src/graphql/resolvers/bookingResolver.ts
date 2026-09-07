import { z } from 'zod';
import { GraphQLError } from 'graphql';
import { Context } from '../../index';
import { validate } from '../validations/validate';
import { createBookingSchema } from '../validations/schemas';
import { handlePrismaError } from '../validations/prismaErrorMapper';

export interface CreateBookingInput {
  planId: string;
  customerName: string;
  customerEmail: string;
  customerPhone: string;
  numberOfPeople: number;
  travelDate: string;
  specialRequests?: string;
  paymentMethod?: string;
}

function formatBooking(booking: any) {
  return {
    ...booking,
    travelDate: booking.travelDate instanceof Date
      ? booking.travelDate.toISOString()
      : booking.travelDate,
    createdAt: booking.createdAt instanceof Date
      ? booking.createdAt.toISOString()
      : booking.createdAt,
    updatedAt: booking.updatedAt instanceof Date
      ? booking.updatedAt.toISOString()
      : booking.updatedAt,
  };
}

export const bookingResolvers = {
  Query: {
    bookings: async (
      _: unknown,
      args: { customerEmail?: string },
      { prisma }: Context,
    ) => {
      if (args.customerEmail !== undefined) {
        validate(
          z.object({ customerEmail: z.string().email('Invalid email address') }),
          { customerEmail: args.customerEmail },
        );
      }
      try {
        const bookings = await prisma.booking.findMany({
          where: args.customerEmail ? { customerEmail: args.customerEmail } : undefined,
          include: { plan: true },
          orderBy: { createdAt: 'desc' },
        });
        return bookings.map(formatBooking);
      } catch (error) {
        if (error instanceof GraphQLError) throw error;
        return handlePrismaError(error);
      }
    },

    booking: async (_: unknown, args: { id: string }, { prisma }: Context) => {
      try {
        const booking = await prisma.booking.findUnique({
          where: { id: args.id },
          include: { plan: true },
        });
        if (!booking) return null;
        return formatBooking(booking);
      } catch (error) {
        if (error instanceof GraphQLError) throw error;
        return handlePrismaError(error);
      }
    },
  },

  Mutation: {
    createBooking: async (
      _: unknown,
      args: { input: CreateBookingInput },
      { prisma }: Context,
    ) => {
      const { input } = args;

      try {
        validate(createBookingSchema, input);
        const result = await prisma.$transaction(async (tx) => {
          const plan = await tx.travelPlan.findUnique({
            where: { id: input.planId },
          });

          if (!plan) {
            throw new GraphQLError('指定したプランが見つかりません', {
              extensions: { code: 'NOT_FOUND' },
            });
          }

          if (!plan.isAvailable) {
            throw new GraphQLError('このプランは現在予約を受け付けていません', {
              extensions: { code: 'PLAN_UNAVAILABLE' },
            });
          }

          const availableSpots = plan.maxParticipants - plan.currentBookings;
          if (input.numberOfPeople > availableSpots) {
            throw new GraphQLError(
              `空き枠が不足しています。残り${availableSpots}名まで予約可能です`,
              { extensions: { code: 'INSUFFICIENT_CAPACITY' } },
            );
          }

          const effectivePrice = plan.discountPrice ?? plan.price;
          const totalPrice = effectivePrice * input.numberOfPeople;

          const booking = await tx.booking.create({
            data: {
              planId: input.planId,
              customerName: input.customerName.trim(),
              customerEmail: input.customerEmail.trim().toLowerCase(),
              customerPhone: input.customerPhone.trim(),
              numberOfPeople: input.numberOfPeople,
              travelDate: new Date(input.travelDate),
              specialRequests: input.specialRequests?.trim() ?? null,
              totalPrice,
              status: 'CONFIRMED',
              paymentMethod: input.paymentMethod ?? null,
            },
            include: { plan: true },
          });

          await tx.travelPlan.update({
            where: { id: input.planId },
            data: { currentBookings: { increment: input.numberOfPeople } },
          });

          return booking;
        });

        return {
          success: true,
          message: '予約が完了しました',
          booking: formatBooking(result),
        };
      } catch (error) {
        if (error instanceof GraphQLError) {
          return { success: false, message: error.message, booking: null };
        }
        console.error('Booking creation error:', error);
        return handlePrismaError(error);
      }
    },

    cancelBooking: async (_: unknown, args: { id: string }, { prisma }: Context) => {
      validate(z.object({ id: z.string().min(1, 'id is required') }), args);
      try {
        const result = await prisma.$transaction(async (tx) => {
          const booking = await tx.booking.findUnique({
            where: { id: args.id },
          });

          if (!booking) {
            throw new GraphQLError('予約が見つかりません', {
              extensions: { code: 'NOT_FOUND' },
            });
          }

          if (booking.status === 'CANCELLED') {
            throw new GraphQLError('この予約はすでにキャンセル済みです', {
              extensions: { code: 'ALREADY_CANCELLED' },
            });
          }

          const updated = await tx.booking.update({
            where: { id: args.id },
            data: { status: 'CANCELLED' },
            include: { plan: true },
          });

          await tx.travelPlan.update({
            where: { id: booking.planId },
            data: {
              currentBookings: {
                decrement: booking.numberOfPeople,
              },
            },
          });

          return updated;
        });

        return {
          success: true,
          message: '予約をキャンセルしました',
          booking: formatBooking(result),
        };
      } catch (error) {
        if (error instanceof GraphQLError) {
          return { success: false, message: error.message, booking: null };
        }
        console.error('Booking cancellation error:', error);
        return handlePrismaError(error);
      }
    },
  },
};
