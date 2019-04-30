// @flow
import React, { Component } from 'react';
import { Button, message } from 'antd';
import { inject, observer } from 'mobx-react';
import { toJS } from 'mobx';
import get from 'lodash.get';

import DzSearch from "../common/components/DzSearch/DzSearch";
import PlayList from "../common/components/PlayList/PlayList";
import PlayListSelectField from "../common/components/FormFields/PlayListSelectField/PlayListSelectField";

import {ASYNC_STATE, GENERAL_ERROR_MESSAGE} from "../common/constants";
import deezerApiService from "../services/deezerApiService";
import {WithSelectableRow} from "../common/components/WithSelectableRow";
import apiService from "../services/apiService";
import type {TracksStore} from "../stores/tracksStore";
import type {PlaylistsStore} from "../stores/playlistsStore";

type Props = {
  tracksStore: TracksStore,
  playlistsStore: PlaylistsStore,
};

export class ComponentSandboxPage extends Component<Props> {
  componentDidMount = async () => {
    const myUser = await deezerApiService.getMyUser();

    console.log('result');
    console.log(myUser);
  };

  fetchMyUser = async () => {
    console.log('Before API request');
    try {
      const userData = await deezerApiService.getMyUser();
      console.log('After API request');
      console.log(userData);
    } catch(error) {
      message.error(get(error, 'message', GENERAL_ERROR_MESSAGE));
    }
  };

  fetchPlayLists = async () => {
    try {
      const response = await apiService.getPlayLists();

      console.log(response);
    } catch(e) {
      console.error(e);
    }
  };

  render() {
    console.log('Render ComponentSandbox');
    const { tracksStore, playlistsStore } = this.props;
    const { searchResultTracks, searchTracks, searchAsyncState } = tracksStore;

    return (
      <div className="content-outer-container">
        <DzSearch
          renderItems={() => (
            <WithSelectableRow renderRows={
              (activeItem, setActiveItem) => (
                <PlayList
                  playlistId={null}
                  withSelectableRows
                  items={searchResultTracks}
                  selectedItem={activeItem}
                  handleItemSelect={setActiveItem}
                />
              )
            }/>
          )}
          handleSearch={searchTracks}
          searchIsLoading={searchAsyncState === ASYNC_STATE.pending}
        />

        <Button
          onClick={this.fetchMyUser}
        >Get My User</Button>

        <PlayListSelectField playlists={toJS(playlistsStore.playlists)}/>

        <Button
          onClick={() => {
            window.DZ.login((response) => {
              console.log(response);

              if (response.authResponse) {
                window.DZ.api('/user/me', (response) => {
                  console.log('Good to see you, ' + response.name + '.');
                });
              } else {
                console.warn('User cancelled login or did not fully authorize.');
              }
            }, { perms: 'basic_access,email' });
          }}
        >Deezer Login</Button>

        <Button onClick={this.fetchPlayLists}>
          Fetch MR Play Lists
        </Button>
      </div>
    );
  }
}

export default inject('tracksStore', 'playlistsStore')(
  observer(ComponentSandboxPage)
);
