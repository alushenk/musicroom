// @flow
import React, { Component } from 'react';
import { Button, Icon, message, Popconfirm, Spin } from 'antd';
import { inject, observer } from 'mobx-react';
import { toJS } from 'mobx';
import LocationPicker from "react-location-picker";
import get from 'lodash.get';

import PlayList from "../../common/components/PlayList/PlayList";
import DzSearch from "../../common/components/DzSearch/DzSearch";
import DzPlayTracksActionButton from "../../common/components/DzPlayTracksActionButton/DzPlayTracksActionButton";
import PlayListModalForm from "../PlayListsPage/PlayListModalForm";

import {distanceInKmBetweenEarthCoordinates, handleGetApiError, locationHasChanged} from "../../common/helpers";
import {
  ASYNC_STATE,
  AUTH_LOCAL_STORAGE_FIELDS,
  TRACK_DUPLICATE_API_MESSAGE,
  WEB_SOCKET_MESSAGE_TYPES,
  webSocketBase
} from "../../common/constants";

import type {PlaylistsStore} from "../../stores/playlistsStore";
import type {SettingsStore} from "../../stores/settingsStore";
import type {TracksStore} from "../../stores/tracksStore";
import type {TLocationCoordinate, TPlayListUserStatuses, TTracksRecord} from "../../common/types";

import './PlaylListPage.styles.scss';

const sortByVotesCount = (trackA, trackB) => {
  return trackB.votes.length - trackA.votes.length;
};

const LOCATION_CHECK_STATE = {
  pending: 0,
  fail: -1,
  success: 1,
};
type Props = {
  playlistsStore: PlaylistsStore,
  settingsStore: SettingsStore,
  tracksStore: TracksStore,
};
type State = {
  playlistEditModalVisible: boolean,
  locationCheckState: $Values<LOCATION_CHECK_STATE>,

  wrongLocationShowHostLocation: boolean,
};
export class PlayListPage extends Component<Props, State> {
  state = {
    playlistEditModalVisible: false,
    locationCheckState: LOCATION_CHECK_STATE.pending,
    wrongLocationShowHostLocation: false,
  };

  prevLocationData = null;
  hostLocation = null;

  serverSocket = null;
  playlistLoadedToPlayer = false;

  currentTrackPosition = null;

  componentDidMount = async (): void  => {
    const {
      match: {
        params: { id }
      }
    } = this.props;

    window.DZ.Event.subscribe('player_position', this.handleDzPlayerPositionEvent);
    // window.DZ.Event.unsubscribe();

    await this.loadPlaylistData(true);

    this.serverSocket = new WebSocket(`${webSocketBase}/playlist/${id}/`);

    // this.serverSocket.addEventListener('open', () => {
    //   console.log('Playlist Socket Opened');
    // });

    this.serverSocket.addEventListener('message', this.handleSocketMessage);

    // this.serverSocket.addEventListener('close', () => {
    //   console.log('Playlist Socket Closed');
    // });

    this.checkPlaylistGeolocation();
  };

  componentWillUnmount = () => {
    window.DZ.Event.unsubscribe('player_position', this.handleDzPlayerPositionEvent);

    if (this.serverSocket) {
      this.serverSocket.removeEventListener('message', this.handleSocketMessage);
      this.serverSocket.close();
    }
  };

  componentDidUpdate = (prevProps): void => {
    const {
      playlistsStore,
      match: {
        params: { id }
      }
    } = this.props;

    const playListData = toJS(playlistsStore.getPlayListDataByIdSafe(id));

    if (playListData.place) {
      if (!this.prevLocationData) {
        this.checkPlaylistGeolocation();
      } else if (locationHasChanged(playListData.place, this.prevLocationData)) {
        this.checkPlaylistGeolocation();
      }
    }

    this.prevLocationData = playListData.place || null;
  };

  handleDzPlayerPositionEvent = (data) => {
    this.currentTrackPosition = data[0] || 0;
  };

  loadPlaylistData = async (toastError = false) => {
    const {
      playlistsStore,
      history,
      match: {
        params: { id }
      }
    } = this.props;

    try {
      await playlistsStore.loadFullPlayListData(id);
    } catch(e) {
      if (handleGetApiError(e)) {
        history.push('/playlists');

        return;
      }

      if (toastError) {
        message.error('Error loading playlist data. Please try again later.');
      } else {
        console.warn('Error loading playlist data. Please try again later.');
      }
    }
  };

  getPlayListData = () => {
    const {
      playlistsStore,
      match: { params: { id } }
    } = this.props;
    const playlistId = Number(id);

    return toJS(playlistsStore.getPlayListDataByIdSafe(playlistId));
  };

  handleDzTrackRemoveFromQueue = (prevTracks, nextTracks) => {
    const { DZ } = window;

    const wasPlaying = DZ.player.isPlaying();
    const currentTrack = DZ.player.getCurrentTrack();

    // console.log(wasPlaying);
    // console.log(currentTrack);
    // console.log(this.currentTrackPosition);
    // console.log(currentTrack);
    // console.log(nextTracks);
    const trackIndexToPlay = nextTracks.findIndex(({ data }) => Number(data.id) === Number(currentTrack.id));
    // console.log('Index: ', trackIndexToPlay);

    DZ.player.pause();
    DZ.player.playTracks(
      nextTracks.map(({ data }) => data.id),
      ...(trackIndexToPlay !== -1 ? [ trackIndexToPlay, this.currentTrackPosition || 0 ] : [0, 0]),
      () => {
        // console.log('After Remove Track Play Started');
        if (wasPlaying) {
          DZ.player.play();
        } else {
          DZ.player.pause();
        }
      }
    );
  };

  handleSocketMessage = async (event) => {
    try {
      const data = JSON.parse(get(event, ['data']) || '{}');

      if (data.message === WEB_SOCKET_MESSAGE_TYPES.refresh) {
        const prevPlayListTracks = get(this.getPlayListData(), 'tracks') || [];

        // console.log('Refreshing Playlist');
        await this.loadPlaylistData();

        if (this.playlistLoadedToPlayer) {
          const nextPlayListTracks = get(this.getPlayListData(), 'tracks') || [];
          const { DZ } = window;

          // console.log(prevPlayListTracks);
          // console.log(nextPlayListTracks);
          if (nextPlayListTracks.length > prevPlayListTracks.length) {
            const prevTrackIds = prevPlayListTracks.map(({ id }) => id);
            const newTracks = nextPlayListTracks.filter(({ id }) => !prevTrackIds.includes(id));

            // TODO: unsafe DZ usage
            DZ.player.addToQueue(newTracks.map(({ data }) => data.id), () => {
              DZ.player.changeTrackOrder(nextPlayListTracks.map(({ data }) => data.id));
            });
          } else if (nextPlayListTracks.length < prevPlayListTracks.length) {
            this.handleDzTrackRemoveFromQueue(prevPlayListTracks, nextPlayListTracks);
          } else {
            // TODO: unsafe DZ usage
            DZ.player.changeTrackOrder(nextPlayListTracks.map(({ data }) => data.id));
          }
        }
      } else if (data.message === WEB_SOCKET_MESSAGE_TYPES.delete) {
        if (this.serverSocket) {
          this.serverSocket.close();
        }

        message.info('Playlist was deleted.');

        this.props.history.push('/playlists');
      }
    } catch(e) {
      console.warn('Web Socket message processing error.');
    }
  };

  checkPlaylistGeolocation = () => {
    const {
      playlistsStore,
      match: {
        params: { id }
      }
    } = this.props;

    const playListData = toJS(playlistsStore.getPlayListDataByIdSafe(id));

    this.prevLocationData = playListData.place;

    if (playListData.place) {
      navigator.geolocation.getCurrentPosition((position) => {
        const first = {
          lat: position.coords.latitude,
          lon: position.coords.longitude,
        };
        this.hostLocation = first;
        // console.log(this.hostLocation);
        const second = playListData.place;

        const locationDistance = distanceInKmBetweenEarthCoordinates(second, first) * 1000;

        this.setState({
          locationCheckState: (locationDistance <= playListData.place.radius) ?
            LOCATION_CHECK_STATE.success :
            LOCATION_CHECK_STATE.fail,
        });
      }, (error) => {
        console.warn("Unable to read your geolocation.");
        this.setState({ locationCheckState: LOCATION_CHECK_STATE.fail });
      }, {
        enableHighAccuracy: true,
      });
    } else {
      this.setState({ locationCheckState: LOCATION_CHECK_STATE.success });
    }
  };

  showEditModal = () => this.setState({ playlistEditModalVisible: true });

  hideEditModal = () => this.setState({ playlistEditModalVisible: false });

  setShowHostLocation = (a: boolean) => this.setState({ wrongLocationShowHostLocation: a });

  handleSubscriptionClick = async (unsubscribe = false) => {
    const {
      playlistsStore,
      match: { params: { id } }
    } = this.props;
    const playlistId = Number(id);
    const currentUserId = Number(localStorage.getItem(AUTH_LOCAL_STORAGE_FIELDS.userId));
    const currentUserIdIsValid = isFinite(currentUserId) && !isNaN(currentUserId);

    if (!currentUserIdIsValid) {
      message.error("Auth data malformed. Please repeat login.");

      return;
    }

    if (unsubscribe) {
      try {
        await playlistsStore.playlistUnsubscribe(playlistId, currentUserId);
      } catch(e) {
        message.error('Error proceeding un-subscription.');
      }
    } else {
      try {
        await playlistsStore.playlistSubscribe(playlistId, currentUserId, 'add');
      } catch(e) {
        message.error('Error proceeding subscription.');
      }
    }
  };

  handleDeletePlayList = async () => {
    const {
      playlistsStore,
      history,
      match: { params: { id: playListId } }
    } = this.props;

    try {
      await playlistsStore.removePlayListById(Number(playListId));

      history.push('/playlists');
    } catch (e) {
      message.error(`Can't delete play list.`);
    }
  };

  handlePlaylistUpdate = async (values) => {
    const {
      playlistsStore,
      match: {
        params: { id }
      }
    } = this.props;
    const playlistId = Number(id);

    this.setShowHostLocation(false);

    try {
      await playlistsStore.updatePlayList(Number(playlistId), values);

      message.success('Playlist updated.');

      // this.checkPlaylistGeolocation();
    } catch(e) {
      message.error('Error updating play list. Please try again later.');
      throw (e);
    }
  };

  addTrackToList = async (track: TTracksRecord) => {
    const {
      playlistsStore,
      match: {
        params: { id }
      }
    } = this.props;
    const playlistId = Number(id);

    try {
      await playlistsStore.addTrackToPlaylist(playlistId, toJS(track.data));
    } catch(e) {

      const [ status, data ] = [ get(e, ['response', 'status']), get(e, ['response', 'data']) || {} ];

      if (status === 302 && data.detail === TRACK_DUPLICATE_API_MESSAGE) {
        message.warning('Track duplicates are forbidden.');
      } else {
        message.error('Error adding track to playlist.');
      }
    }
  };

  removeTrackById = async (trackId: number) => {
    const {
      playlistsStore,
      match: { params: { id } }
    } = this.props;
    const playlistId = Number(id);

    try {
      await playlistsStore.removeTrackFromPlaylist(playlistId, trackId);
    } catch(e) {
      message.error('Error removing track.');
    }
  };

  getWrongLocationProps = (place: TLocationCoordinate) => {
    const { wrongLocationShowHostLocation } = this.state;
    const { lat, lon, radius } = place;

    return wrongLocationShowHostLocation ? {
      radius: -1,
      defaultPosition: {
        lat: this.hostLocation.lat,
        lng: this.hostLocation.lon,
      },
    } : {
      radius: Number(radius) || -1,
      defaultPosition: {
        lat,
        lng: lon,
      },
    }
  };

  renderPlaylistView = (tracks, place, options: TPlayListUserStatuses) => {
    const { locationCheckState } = this.state;
    const {
      playlistsStore,
      match: { params: { id: playlistId } }
    } = this.props;
    const canUserRemoveTrack = options.owner || options.creator;

    if (place && locationCheckState === LOCATION_CHECK_STATE.pending) {
      return (
        <Spin spinning={true}>
          <div className="play-list-container empty">
            Checking location data...
          </div>
        </Spin>
      );
    } else if (place && locationCheckState === LOCATION_CHECK_STATE.fail) {
      return (
        <div>
          <LocationPicker
            containerElement={ <div style={ {height: '100%'} } /> }
            mapElement={ <div style={ {height: '400px'} } /> }
            {...this.getWrongLocationProps(place)}
            onChange={() => {}}
            zoom={15}
          />
          <div className='wrong-location-info-block'>
            <span>To view this play-list you must be located&nbsp;</span>
            <span
              onClick={() => this.setShowHostLocation(false)}
              className="link-like"
            >HERE</span>
            <span>.&nbsp;But according to browsers location data you are&nbsp;</span>
            <span
              onClick={() => this.setShowHostLocation(true)}
              className="link-like"
            >HERE</span>.
          </div>
        </div>
      )
    } else {
      return (
        <div className="play-list-container">
          <PlayList
            showRatingColumn
            onPlaySideEffect={() => this.playlistLoadedToPlayer = true}
            // userStatusOptions={options}
            playlistId={Number(playlistId)}
            playlistsStore={playlistsStore}
            items={tracks.sort(sortByVotesCount)}
            configureActionColumn={() => ({
              title: 'Action',
              key: 'action',
              width: '15%`',
              className: 'ant-actions-column',
              render: ({ data, id }) => (
                <div className="actions-container">
                  {canUserRemoveTrack && (
                    <Popconfirm
                      title={`Are you sure? Track rating will be lost.`}
                      okText="Delete"
                      onConfirm={() => this.removeTrackById(id)}
                    >
                      <Icon
                        type="minus-circle"
                        className="action-icon"
                      />
                    </Popconfirm>
                  )}
                </div>
              ),
            })}
          />
        </div>
      );
    }
  };

  render () {
    const { locationCheckState } = this.state;
    const {
      playlistsStore,
      settingsStore,
      tracksStore,
      match: { params: { id: playListId } }
    } = this.props;

    const playListData = toJS(playlistsStore.getPlayListDataByIdSafe(playListId));
    const tracks = playListData.tracks.filter(({ data }) => Boolean(data));
    const trackIds = tracks.map((track) => track.data.id);

    // TODO: could cause troubles here
    const currentUserId = get(settingsStore, ['currentUser', 'id']);

    const userSubscribed = playListData.participants.includes(currentUserId) || playListData.owners.includes(currentUserId);
    const isUserOwner = playListData.owners.includes(currentUserId);
    const isUserCreator = playListData.creator === currentUserId;

    const locationIsValid = locationCheckState === LOCATION_CHECK_STATE.success;

    const subscriptionButton = userSubscribed ? (
      <Popconfirm
        title={`Are you sure?${isUserCreator || isUserOwner ? ` You wan't be able to edit this playlist anymore.` : ''}`}
        onConfirm={() => this.handleSubscriptionClick(true)}
        okText="Yes"
      >
        <Button>Unsubscribe</Button>
      </Popconfirm>
    ) : (
      <Button
        onClick={() => this.handleSubscriptionClick()}
      >Subscribe</Button>
    );

    return (
      <div className="content-outer-container dz-player-avoiding-view">
        <div className="playlist-header">
          <h2>{playListData.name}</h2>
          {locationIsValid && (
            <DzPlayTracksActionButton
              className="dz-play-button-l"
              trackIds={trackIds}
              onClickSideEffect={() => this.playlistLoadedToPlayer = true}
            />
          )}
        </div>
        {this.renderPlaylistView(tracks, playListData.place, {
          subscribed: userSubscribed,
          owner: isUserOwner,
          creator: isUserCreator,
        })}

        <div className="play-list-action-buttons-container">
          {isUserCreator && (
            <Popconfirm
              title={`Are you sure. Deleted playlist can't be restored.`}
              onConfirm={this.handleDeletePlayList}
              okText="Delete"
            >
              <Button>Delete</Button>
            </Popconfirm>
          )}
          {(isUserCreator || isUserOwner) && (
            <Button onClick={this.showEditModal}>Edit</Button>
          )}
          {subscriptionButton}
        </div>

        {userSubscribed && (
          <DzSearch
            renderItems={() => (
              <PlayList
                playlistId={null}
                items={toJS(tracksStore.searchResultTracks)}
                configureActionColumn={() => ({
                  title: 'Action',
                  key: 'action',
                  width: '15%`',
                  className: 'ant-actions-column',
                  render: (record) => (
                    <div className="actions-container">
                      <Icon type="plus-circle" className="action-icon" onClick={() => this.addTrackToList(record)}/>
                    </div>
                  ),
                })}
              />
            )}
            handleSearch={tracksStore.searchTracks}
            searchIsLoading={tracksStore.searchAsyncState === ASYNC_STATE.pending}
          />
        )}

        <PlayListModalForm
          playListItem={playListData}
          visible={this.state.playlistEditModalVisible}
          hideModal={this.hideEditModal}
          handleOk={this.handlePlaylistUpdate}
        />
      </div>
    );
  }
}

export default inject('playlistsStore', 'settingsStore', 'tracksStore')(
  observer(PlayListPage)
);
