import React  from 'react';
import { Switch, Route, Redirect, withRouter } from 'react-router-dom';

import PlayListPage from "../../pages/PlayListPage/PlayListPage";

import AuthorizationPage from '../../pages/AuthorizationPage';
import ProfilePage from "../../pages/ProfilePage/ProfilePage";
import PlayListsPage from "../../pages/PlayListsPage/PlayListsPage";
import PlayListEditPage from "../../pages/PlayListEditPage/PlayListEditPage";
import {localStorageCredentialsPresent} from "../helpers";

const renderProfilePage = (props) => {
  return (
    localStorageCredentialsPresent() ?
      <ProfilePage {...props} /> :
      <Redirect to={'/auth'}/>
  );
};

const renderPlayListsPage = (props) => {
  return (
    localStorageCredentialsPresent() ?
      <PlayListsPage {...props}/> :
      <Redirect to={'/auth'}/>
  );
};

const renderMyPlayListsPage = (props) => {
  return (
    localStorageCredentialsPresent() ?
      <PlayListsPage myPlaylists {...props}/> :
      <Redirect to={'/auth'}/>
  );
};

const renderAuthPage = (props) => {
  return (<AuthorizationPage {...props} />);
};

const renderPlayListPage = (props) => {
  return (
    localStorageCredentialsPresent() ?
      <PlayListPage {...props} /> :
      <Redirect to={'/auth'}/>
  );
};

const renderPlayListEditPage = (props) => {
  return (
    localStorageCredentialsPresent() ?
      <PlayListEditPage {...props} /> :
      <Redirect to={'/auth'}/>
  );
};

const Routes = ({ history }) => {
  return (
    <Switch>
      <Route exact path='/' render={() => <Redirect to='/playlists'/>} />

      <Route exact path='/main' render={() => <Redirect to='/playlists'/>} />

      <Route exact path='/profile' render={renderProfilePage} />

      <Route exact path='/playlists' render={renderPlayListsPage} />

      <Route exact path='/playlists/my' render={renderMyPlayListsPage} />

      <Route exact path='/auth' render={renderAuthPage} />

      <Route exact path='/playlists/:id' render={renderPlayListPage} />

      <Route exact path='/playlists/:id/edit' render={renderPlayListEditPage} />
    </Switch>
  );
};

export default withRouter(Routes);
