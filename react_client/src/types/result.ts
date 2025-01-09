export type Result<T, E> = { ok: true; value: T } | { ok: false; value: E };
export type FetchResult<T, E> = undefined | "fetching" | Result<T, E>;
