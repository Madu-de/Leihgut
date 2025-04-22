import { z } from 'zod';

export const User = z.strictObject({
  name: z.string(),
});

export type User = z.infer<typeof User>;