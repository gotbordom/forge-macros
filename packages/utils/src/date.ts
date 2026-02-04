export function toIsoDate(input: Date | string | number): string {
  const date = input instanceof Date ? input : new Date(input);
  return date.toISOString();
}
