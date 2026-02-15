const parseCorsOrigins = (rawOrigins: string | undefined): Array<string | RegExp> => {
  if (!rawOrigins || rawOrigins.trim().length === 0) {
    return [/^http:\/\/localhost:\d+$/];
  }

  return rawOrigins
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0)
    .map((origin) => (origin === 'http://localhost:*' ? /^http:\/\/localhost:\d+$/ : origin));
};

export default () => ({
  app: {
    port: Number(process.env.PORT ?? 3000),
    corsOrigins: parseCorsOrigins(process.env.CORS_ORIGINS)
  }
});
