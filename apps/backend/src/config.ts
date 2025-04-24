const getValue = (name: string) => {
  return process.env[name] || '';
};

export default () => ({
  http: {
    port: getValue('LEIHGUT_BACKEND_PORT'),
  },
  database: {
    user: getValue('LEIHGUT_BACKEND_DATABASE_USER'),
    name: getValue('LEIHGUT_BACKEND_DATABASE_NAME'),
    password: getValue('LEIHGUT_BACKEND_DATABASE_PASSWORD'),
  },
});
