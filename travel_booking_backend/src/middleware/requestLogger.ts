import { ApolloServerPlugin, GraphQLRequestListener } from '@apollo/server';
import { Context } from '../index';
import { logger } from '../utils/logger';

export const requestLoggerPlugin: ApolloServerPlugin<Context> = {
  async requestDidStart({ request }) {
    const operationName = request.operationName ?? 'anonymous';
    const startTime = Date.now();

    logger.debug({ operationName }, 'GraphQL request started');

    return {
      async willSendResponse({ response }) {
        const durationMs = Date.now() - startTime;
        const hasErrors =
          response.body.kind === 'single' && Boolean(response.body.singleResult.errors);

        if (hasErrors) {
          logger.warn({ operationName, durationMs }, 'GraphQL request completed with errors');
        } else {
          logger.info({ operationName, durationMs }, 'GraphQL request completed');
        }
      },

      async didEncounterErrors({ errors }) {
        errors.forEach((error) => {
          logger.error(
            {
              operationName,
              errorMessage: error.message,
              errorPath: error.path,
              errorCode: error.extensions?.code,
            },
            'GraphQL error encountered',
          );
        });
      },
    } satisfies GraphQLRequestListener<Context>;
  },
};
