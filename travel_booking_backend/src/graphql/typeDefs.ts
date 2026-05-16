export const typeDefs = `#graphql
  type Query {
    travelPlans(filter: PlanFilterInput, page: Int, pageSize: Int): TravelPlansResult!
    travelPlan(id: ID!): TravelPlan
    bookings(customerEmail: String): [Booking!]!
    booking(id: ID!): Booking
  }

  type Mutation {
    createBooking(input: CreateBookingInput!): BookingResult!
    cancelBooking(id: ID!): BookingResult!
  }

  type TravelPlan {
    id: ID!
    title: String!
    description: String!
    destination: String!
    country: String!
    region: String!
    latitude: Float!
    longitude: Float!
    price: Float!
    discountPrice: Float
    durationDays: Int!
    maxParticipants: Int!
    currentBookings: Int!
    category: String!
    difficulty: String!
    rating: Float!
    reviewCount: Int!
    isAvailable: Boolean!
    availableFrom: String
    availableTo: String
    language: String!
    meetingPoint: String!
    cancellationPolicy: String!
    minimumAge: Int
    tags: [String!]!
    images: [TravelPlanImage!]!
    highlights: [TravelPlanHighlight!]!
    itinerary: [ItineraryDay!]!
    includedItems: [IncludedItem!]!
    excludedItems: [ExcludedItem!]!
    reviews: [Review!]!
    availableSpots: Int!
    effectivePrice: Float!
    createdAt: String!
    updatedAt: String!
  }

  type TravelPlanImage {
    id: ID!
    url: String!
    caption: String
    isPrimary: Boolean!
    displayOrder: Int!
  }

  type TravelPlanHighlight {
    id: ID!
    text: String!
  }

  type ItineraryDay {
    id: ID!
    dayNumber: Int!
    title: String!
    description: String!
    accommodation: String
    meals: String!
    activities: [ItineraryActivity!]!
  }

  type ItineraryActivity {
    id: ID!
    name: String!
    startTime: String
    duration: String!
    description: String!
    location: String
  }

  type IncludedItem {
    id: ID!
    item: String!
  }

  type ExcludedItem {
    id: ID!
    item: String!
  }

  type Review {
    id: ID!
    reviewerName: String!
    rating: Float!
    comment: String!
    travelDate: String!
    createdAt: String!
  }

  type Booking {
    id: ID!
    planId: String!
    plan: TravelPlan
    customerName: String!
    customerEmail: String!
    customerPhone: String!
    numberOfPeople: Int!
    travelDate: String!
    specialRequests: String
    totalPrice: Float!
    status: String!
    paymentMethod: String
    createdAt: String!
    updatedAt: String!
  }

  type TravelPlansResult {
    plans: [TravelPlan!]!
    totalCount: Int!
    hasNextPage: Boolean!
    currentPage: Int!
    totalPages: Int!
  }

  type BookingResult {
    success: Boolean!
    message: String!
    booking: Booking
  }

  input PlanFilterInput {
    keyword: String
    category: String
    region: String
    minPrice: Float
    maxPrice: Float
    maxDuration: Int
    difficulty: String
    sortBy: String
    sortOrder: String
  }

  input CreateBookingInput {
    planId: ID!
    customerName: String!
    customerEmail: String!
    customerPhone: String!
    numberOfPeople: Int!
    travelDate: String!
    specialRequests: String
    paymentMethod: String
  }
`;
