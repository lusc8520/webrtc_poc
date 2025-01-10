declare global {
  interface PromiseConstructor {
    wait(millis: number): Promise<void>;
  }
}

Promise.wait = function (millis: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, millis));
};
