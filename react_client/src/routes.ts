import { createRouter, defineRoute, param } from "type-route";

const baseRoute = defineRoute("");

export const { RouteProvider, useRoute, routes } = createRouter({
  home: baseRoute.extend("/home"),
  cars: baseRoute.extend("/cars"),
  flutter: baseRoute.extend("/flutter"),
  game: baseRoute.extend(
    {
      game: param.path.string,
    },
    (p) => `/game/${p.game}`,
  ),
});
