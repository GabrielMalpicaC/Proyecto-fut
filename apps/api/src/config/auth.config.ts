export default () => ({
  auth: {
    accessSecret: process.env.JWT_ACCESS_SECRET ?? 'access_secret_dev',
    refreshSecret: process.env.JWT_REFRESH_SECRET ?? 'refresh_secret_dev',
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES ?? '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES ?? '7d'
  }
});
