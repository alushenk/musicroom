// @flow
import {
  observable,
  action,
  flow,
} from 'mobx';

import {ASYNC_STATE} from "../common/constants";

import deezerApiService from "../services/deezerApiService";
import apiService from "../services/apiService";

import type {IObservableArray, IObservableObject} from 'mobx';
import type {TDzSearchOptions, TTracksRecord} from "../common/types";

export class TracksStore {
  @observable asyncState = ASYNC_STATE.done;
  @observable searchAsyncState = ASYNC_STATE.done;

  @observable searchResultTracks: IObservableArray = [];
  @observable playlistsTracks: IObservableObject = {};

  @action('search for tracks')
  searchTracks = flow((function * (queryOptions: TDzSearchOptions) {
    this.searchAsyncState = ASYNC_STATE.pending;

    try {
      const response = yield deezerApiService.searchTracks(queryOptions);

      this.searchResultTracks = response.data.map((data) => ({ id: data.id, data }));
    } catch(e) {
      throw e;
    } finally {
      this.searchAsyncState = ASYNC_STATE.done;
    }
  }).bind(this)); // with bind you can pass method as prop separated from store

  @action('add tracks to playlist by id')
  addTrackToPlaylist = flow(function * (playlistId: number, data: TTracksRecord) {
    this.asyncState = ASYNC_STATE.pending;

    try {
      const newTrack = yield apiService.addTrack(playlistId, data);
      // console.log(newTrack);

      if (newTrack) {
        this.playlistsTracks[playlistId].push(newTrack);
      }
    } catch (e) {
      throw e;
    } finally {
      this.asyncState = ASYNC_STATE.done;
    }
  }).bind(this);

  @action('bulk add tracks to playlist')
  bulkAddTracksToPlaylist = flow(function * (playlistId: number, data: TTracksRecord[]) {
    this.asyncState = ASYNC_STATE.pending;

    for (let track of data) {
      try {
        yield apiService.addTrack(playlistId, track);
      } catch(e) {}
    }

    this.asyncState = ASYNC_STATE.done;
  }).bind(this);
}

export default new TracksStore();
