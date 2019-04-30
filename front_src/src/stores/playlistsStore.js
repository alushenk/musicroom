// @flow
import {
  observable,
  action,
  flow, extendObservable, set,
} from 'mobx';

import {ASYNC_STATE} from "../common/constants";
import apiService from "../services/apiService";

import type {IObservableArray, IObservableObject} from 'mobx';
import type {TTracksRecord} from "../common/types";
import {safeGetCurrentUserId} from "../common/helpers";

const defaultPlayListFullData = {
  tracks: [],
  participants: [],
  owners: [],
};

type UserManagementAction = 'add' | 'remove';

export class PlaylistsStore {
  @observable asyncState = ASYNC_STATE.done;
  @observable searchAsyncState = ASYNC_STATE.done;

  @observable playlists: IObservableArray = [];
  @observable myPlaylists: IObservableArray = [];
  @observable fullPlayListData: IObservableObject = {};

  @action('get play lists')
  getPlayLists = flow((function * () {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const { data } = yield apiService.getPlayLists();

      this.playlists = data;
    } catch(e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('get play lists')
  getMyPlaylists = flow((function * () {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const currentUserId = safeGetCurrentUserId();
      const { data } = yield apiService.getUserPlayLists(currentUserId);

      this.myPlaylists = data;
    } catch(e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('create playlist')
  createPlayList = flow((function * (playListData) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const { data: newPlayList } = yield apiService.createPlayList(playListData);

      this.playlists = [
        ...this.playlists,
        newPlayList,
      ];
      this.myPlaylists = [
        ...this.myPlaylists,
        newPlayList,
      ];

      return newPlayList;
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('update playlist')
  updatePlayList = flow((function * (playlistId: number, playListData: {}) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const { data: updateData } = yield apiService.updatePlayList(playlistId, playListData);

      const playlist = this.getPlayListById(playlistId);
      const myPlaylist = this.getMyPlayListById(playlistId);

      if (playlist) {
        set(playlist, updateData);
      }
      if (myPlaylist) {
        set(myPlaylist, updateData);
      }
      if (this.fullPlayListData[playlistId]) {
        set(this.fullPlayListData[playlistId], updateData);
      }
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('remove playlist')
  removePlayListById = flow((function * (id: number) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      yield apiService.removePlaylist(id);

      this.playlists = this.playlists.filter((item) => item.id !== id);
      this.myPlaylists = this.myPlaylists.filter((item) => item.id !== id);
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  getPlayListDataByIdSafe = (id: number) => this.fullPlayListData[id] || defaultPlayListFullData;

  getPlayListDataById = (id: number) => this.fullPlayListData[id];

  getPlayListById = (playlistId: number) => this.playlists.find(({ id }) => playlistId === id);

  getMyPlayListById = (playlistId: number) => this.myPlaylists.find(({ id }) => playlistId === id);

  getPlayListTrackById = (playlistData: {}, trackId: number) => playlistData.tracks.find(({ id }) => id === trackId);

  @action('get playlist tracks')
  loadFullPlayListData = flow((function * (playlistId: number) {
    this.asyncState = ASYNC_STATE.pending;
    const fullData = this.fullPlayListData[playlistId]; // TODO: remove cache

    try {
      const { data: playlistData } = yield apiService.getPlayList(playlistId);

      if (!fullData) {
        extendObservable(this.fullPlayListData, {
          [playlistId]: playlistData || defaultPlayListFullData,
        });
      } else {
        set(this.fullPlayListData, playlistId, playlistData || defaultPlayListFullData);
      }
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('add playlist owner')
  playlistOwner = flow((function * (playlistId: number, userId: number, action: UserManagementAction) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const playlist = this.getPlayListDataById(playlistId);

      if (action === 'add') {
        yield apiService.addPlaylistOwner(playlistId, userId);

        playlist && set(playlist, { owners: [...playlist.owners, userId] });
      } else if (action === 'remove') {
        yield apiService.removePlaylistOwner(playlistId, userId);

        playlist && set(playlist, { owners: playlist.owners.filter(id => id !== userId) });
      }
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('add playlist owner')
  playlistParticipant = flow((function * (playlistId: number, userId: number, action: UserManagementAction) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const playlist = this.getPlayListDataById(playlistId);

      if (action === 'add') {
        yield apiService.addPlaylistParticipant(playlistId, userId);

        playlist && set(playlist, { participants: [...playlist.participants, userId] });
      } else if (action === 'remove') {
        yield apiService.removePlaylistParticipant(playlistId, userId);

        playlist && set(playlist, { participants: playlist.participants.filter(id => id !== userId) });
      }
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  playlistSubscribe = this.playlistParticipant;

  @action('add playlist owner')
  playlistUnsubscribe = flow((function * (playlistId: number, userId: number) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const playlist = this.getPlayListDataById(playlistId);

      yield apiService.playlistUnsubscribe(playlistId, userId);

      playlist && set(playlist, {
        participants: playlist.participants.filter(id => id !== userId),
        owners: playlist.owners.filter(id => id !== userId),
      });
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this));

  @action('add tracks to playlist data')
  addTrackToPlaylist = flow(function * (playlistId: number, data: TTracksRecord) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      yield apiService.addTrack(playlistId, data);

      // if (!newTrack.votes || !Array.isArray(newTrack.votes)) {
      //   Object.assign(newTrack, { votes: [] });
      // }

      // if (newTrack) {
      //   const playlist = this.getPlayListDataById(playlistId);
      //
      //   playlist && playlist.tracks.push(newTrack);
      // }
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this);

  @action('remove track from playlist')
  removeTrackFromPlaylist = flow(function * (playlistId: number, trackId: number) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      yield apiService.removeTrack(trackId);

      // const playlist = this.getPlayListDataById(playlistId);

      // playlist && set(playlist, { tracks: playlist.tracks.filter(({ id }) => id !== trackId) });
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this);

  @action('vote track')
  voteTrack = flow(function * (trackId: number, playlistId: number, isDislike: boolean = false) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const { data } = yield apiService.voteTrack(trackId);

      const currentUserId = safeGetCurrentUserId();
      const playlistData = this.getPlayListDataById(playlistId);

      if (playlistData) {
        const playlistTrack = this.getPlayListTrackById(playlistData, trackId);

        if (playlistTrack) {
          if (!isDislike && data) {
            set(playlistTrack, { votes: [ ...playlistTrack.votes, data ] });
          } else {
            set(playlistTrack, { votes: playlistTrack.votes.filter(({ user }) => Number(user) !== currentUserId) });
          }
        } else {
          console.warn('voteTrack :: no playlist data');
        }
      } else {
        console.warn('voteTrack :: no playlist data');
      }
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this);
}

export default new PlaylistsStore();
