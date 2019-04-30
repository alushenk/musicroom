// @flow
import React, { Component } from 'react';
import { Button, Spin, message } from 'antd';
import { inject, observer } from 'mobx-react';
import { toJS } from 'mobx';

import PlayLists from "../../common/components/PlayLists/PlayLists";
import PlayListModalForm from "./PlayListModalForm";
import {safeGetCurrentUserId} from "../../common/helpers";

import {ASYNC_STATE, WEB_SOCKET_MESSAGE_TYPES, webSocketBase} from "../../common/constants";

import type {PlaylistsStore} from "../../stores/playlistsStore";
import type {TracksStore} from "../../stores/tracksStore";

import "./PlayListsPage.styles.scss";
import get from "lodash.get";

type Props = {
  myPlaylists?: boolean,
  playlistsStore: PlaylistsStore,
  tracksStore: TracksStore
};
type State = {
  newPlayListModalVisible: boolean,
};

export class PlayListsPage extends Component<Props, State> {
  state = {
    newPlayListModalVisible: false,
  };

  serverSocket = null;

  componentDidMount = async () => {
    const { playlistsStore } = this.props;

    const currentUserId = safeGetCurrentUserId();
    this.serverSocket = new WebSocket(`${webSocketBase}/user/${currentUserId}/`);

    // this.serverSocket.addEventListener('open', () => {
    //   console.log('Playlists Socket Opened');
    // });
    this.serverSocket.addEventListener('message', this.handleSocketMessage);
    // this.serverSocket.addEventListener('close', () => {
    //   console.log('Playlists Socket Closed');
    // });

    try {
      await playlistsStore.getPlayLists();
      await playlistsStore.getMyPlaylists();
    } catch(e) {
      message.error('Error loading playlists. Please try again later.');
    }
  };

  componentWillUnmount = () => {
    if (this.serverSocket) {
      this.serverSocket.close();
    }
  };

  handleSocketMessage = async (event) => {
    const { playlistsStore } = this.props;

    try {
      const data = JSON.parse(get(event, ['data']) || '{}');

      if (data.message === WEB_SOCKET_MESSAGE_TYPES.refresh) {
        console.log('Refresh Playlists');
        await playlistsStore.getMyPlaylists();
      } else if (data.message === WEB_SOCKET_MESSAGE_TYPES.delete) {
        console.warn("I don't know what to do on 'delete' message");
      }
    } catch(e) {
      console.warn('Web Socket message processing error.');
    }
  };

  hidePlayListModalForm = () => this.setState({ newPlayListModalVisible: false });

  handleCreatePlayList = async (values) => {
    const { playlistsStore, tracksStore } = this.props;
    const tracks = [...values.tracks];

    delete(values.tracks);


    try {
      const playList  = await playlistsStore.createPlayList(values);

      if (playList) {
        // TODO: errors is not handled
        tracksStore.bulkAddTracksToPlaylist(playList.id, tracks);
      }
    } catch(e) {
      message.error('Error creating play list. Try again later.');
    }
  };

  render() {
    const { playlistsStore, myPlaylists, history } = this.props;
    const { newPlayListModalVisible } = this.state;

    const playLists = myPlaylists ?
      toJS(playlistsStore.myPlaylists) :
      toJS(playlistsStore.playlists);

    return (
      <div className="content-outer-container">
        <Spin spinning={playlistsStore.asyncState === ASYNC_STATE.pending}>
          <div className="playlists-header">
            <h2 className="page-header">{myPlaylists ? 'My Playlists' : 'Playlists'}</h2>
            <span
              className="link-like"
              onClick={() => history.push(myPlaylists ? '/playlists' : '/playlists/my')}
            >{`${myPlaylists ? 'All playlists' : 'My playlists'}`}</span>
          </div>

          <PlayLists
            playlists={playLists}
          />

          <Button
            id="add-new-playlist"
            type="primary"
            onClick={() => this.setState({ newPlayListModalVisible: true })}
          >
            Add New Playlist
          </Button>

          <PlayListModalForm
            isCreateForm={true}
            visible={newPlayListModalVisible}
            hideModal={this.hidePlayListModalForm}
            handleOk={this.handleCreatePlayList}
          />
        </Spin>
      </div>
    );
  }
}

export default inject('playlistsStore', 'tracksStore')(observer(PlayListsPage));
