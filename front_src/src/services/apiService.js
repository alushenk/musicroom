// @flow
import Axios from 'axios';

import {AUTH_LOCAL_STORAGE_FIELDS} from "../common/constants";
import type {TTracksRecord} from "../common/types";

export const axios = new Axios.create({
    baseURL: 'https://musicroom.ml/',
    timeout: 3000,
    headers: {},
});

const dumbEndPoints = ['auth/registration/', 'auth/login/'];
axios.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem(AUTH_LOCAL_STORAGE_FIELDS.token);
    const { url } = config;

    if (!dumbEndPoints.includes(url)) {
      if (token) {
        Object.assign(config.headers.common, {
          Authorization: `JWT ${token}`,
        });
      }
    }

    return config;
  },
  (error) => Promise.reject(error),
);

// axios.interceptors.response.use(
//   (response) => {
//     console.log(response);
//     return response;
//   },
//   (error) => Promise.reject(error),
// );

/* Auth */
const registration = (payload) => axios.post('auth/registration/', payload);

const login = (payload) => axios.post('auth/login/', payload);

const changePassword = (payload) => axios.post('auth/password/change/', payload);

/* Playlists */
const getPlayLists = () => axios.get('api/playlists/');

const getUserPlayLists = (userId: number) => axios.get(`api/users/${userId}/playlists/`);

const getPlayList = (id: number) => axios.get(`api/playlists/${id}/`);

const createPlayList = (payload) => axios.post('api/playlists/', payload);

const updatePlayList = (id: number, payload) => axios.patch(`api/playlists/${id}/`, payload);

const removePlaylist = (id: number) => axios.delete(`api/playlists/${id}/`);

// TODO: this should not be patch but post
const addPlaylistOwner = (playlistId: number, userId: number) =>
  axios.patch(`/api/playlists/${playlistId}/owners/${userId}/`);

const removePlaylistOwner = (playlistId: number, userId: number) =>
  axios.delete(`/api/playlists/${playlistId}/owners/${userId}/`);

const addPlaylistParticipant = (playlistId: number, userId: number) =>
  axios.patch(`/api/playlists/${playlistId}/participants/${userId}/`);

const removePlaylistParticipant = (playlistId: number, userId: number) =>
  axios.delete(`/api/playlists/${playlistId}/participants/${userId}/`);

const playlistUnsubscribe = (playlistId: number, userId: number) =>
  axios.delete(`/api/playlists/${playlistId}/users/${userId}/`);

/* Tracks */
const getVote = (id) => axios.get(`api/votes/${id}/`);

const voteTrack = (id: number) => axios.post(`api/votes/${id}/`);

const addTrack = (playlistId: number, data: TTracksRecord) => axios.post(`api/tracks/`, {
  playlist: playlistId,
  data,
});

const removeTrack = (trackId: number) => axios.delete(`api/tracks/${trackId}/`);

/* User */
const getUsers = () => axios.get('api/users/');

const getUserById = (id: number) => axios.get(`api/users/${id}/`);

const searchUsers = (name: string) => axios.get('api/users/user_search/', {
  params: {
    name,
  }
});

const updateProfile = (id: number, body: {}) => axios.patch(`api/users/${id}/`, body);

export default {
  registration,
  login,
  changePassword,

  getPlayLists,
  getUserPlayLists,
  getPlayList,
  createPlayList,
  updatePlayList,
  removePlaylist,
  addPlaylistOwner,
  removePlaylistOwner,
  addPlaylistParticipant,
  removePlaylistParticipant,
  playlistUnsubscribe,

  getVote,
  voteTrack,
  addTrack,
  removeTrack,

  getUsers,
  getUserById,
  searchUsers,
  updateProfile,
};
