// @flow
import type {TDzSearchOptions} from "../common/types";

// const withCheckDeezerSDK = fn => (...args) => {
//   const { DZ } = window;
//
//   if (!DZ) {
//     throw new Error('Deezer SDK is not present on window instance.');
//   }
//
//   return fn(...args);
// };

const withCallbackToPromise = (...args) => {
  return (
    new Promise((resolve, reject) => {
      window.DZ.api(...args, (response) => {
        if (response.error) {
          reject(response.error);
        }
        resolve(response);
      });
    })
  )
};

const getMyUser = () => withCallbackToPromise('/user/me');

const getUserById = (id: number) => withCallbackToPromise(`user/${id}`);

const searchTracks = (qOptions: TDzSearchOptions) => {
  const parsedQuery = Object.entries(qOptions).reduce(
    (params, [key, value]) => (params + `${key}:"${value}" `),
    '',
  );

  return withCallbackToPromise('search?q=' + parsedQuery);
};

export default {
  getMyUser,
  getUserById,
  searchTracks,
};