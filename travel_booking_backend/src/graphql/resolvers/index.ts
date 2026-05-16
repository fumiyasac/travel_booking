import { planResolvers } from './planResolver';
import { bookingResolvers } from './bookingResolver';

export const resolvers = {
  Query: {
    ...planResolvers.Query,
    ...bookingResolvers.Query,
  },
  Mutation: {
    ...bookingResolvers.Mutation,
  },
};
