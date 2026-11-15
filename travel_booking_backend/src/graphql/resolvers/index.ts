import { planResolvers } from './planResolver';
import { bookingResolvers } from './bookingResolver';
import { authResolvers } from './authResolver';

export const resolvers = {
  Query: {
    ...planResolvers.Query,
    ...bookingResolvers.Query,
  },
  Mutation: {
    ...bookingResolvers.Mutation,
    ...authResolvers.Mutation,
  },
};
