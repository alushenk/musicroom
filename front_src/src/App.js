// @flow
import React, {Component} from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
import { Icon, Layout, Spin } from 'antd';
import { Provider, observer } from 'mobx-react';
import { configure } from 'mobx';

import Routes from './common/router/Routes';

import sandboxStore from "./stores/sandboxStore";
import settingsStore from "./stores/settingsStore";
import tracksStore from "./stores/tracksStore";
import playlistsStore from "./stores/playlistsStore";
import AppHeader from "./common/components/AppHeader/AppHeader";

import 'antd/dist/antd.css';
import './App.scss';

configure({ enforceActions: "always" });

const isDevelopment = process.env.NODE_ENV === 'development';
const basename = isDevelopment ? '' : '/';

type Props = {};
type State = {
  globalInitiallyLoading: boolean;
  playerExpanded: boolean,
  hasError: boolean,
};

class App extends Component<Props, State> {
  state = {
    globalInitiallyLoading: true,
    playerExpanded: false,
    hasError: false,
  };

  componentDidMount = () => {
    try {
      settingsStore.getMyUser()
        .catch(() => this.setState({
          hasError: true,
        }))
        .finally(() => this.setState({
          globalInitiallyLoading: false,
        }));
    } catch (e) {
      console.error('Error caught in App.componentDidMount');
    }

  };

  componentDidUpdate = (_, prevState) => {
    if (
      prevState.globalInitiallyLoading &&
      !this.state.globalInitiallyLoading &&
      !this.state.hasError
    ) {
      if (window.DZ !== undefined) {
        console.log('Deezer SDK is loaded');

        // console.log('Before init');
        window.DZ.init({
          appId: '336362',
          channelUrl: isDevelopment ?
            'http://localhost:3000/channel.html' :
            'https://front.musicroom.ml/channel.html',
          player : {
            container: 'dz-player',
            width : 800,
            height : 300,
            playlist: true,
            onload : () => {
              console.log('Player is loaded');
            }
          }
        });
        // console.log('After init');
        // console.log(initResult);
      }
    }
  };

  togglePlayerExpanded = () => {
    this.setState((prevState) => ({
      playerExpanded: !prevState.playerExpanded,
    }));
  };

  render() {
    const { playerExpanded, globalInitiallyLoading, hasError } = this.state;

    if (globalInitiallyLoading) {
      return (
        <Spin spinning={true}>
          <div id="the-great-loader"></div>
        </Spin>
      );
    }

    if (hasError) {
      return (
        <div id="the-great-error">
          <p>Error occurred</p>
          <p>Please clean the <strong><i>localStorage</i></strong></p>
          <p>and reload application.</p>
        </div>
      )
    }

    return (
      <Provider
        sandboxStore={sandboxStore}
        settingsStore={settingsStore}
        tracksStore={tracksStore}
        playlistsStore={playlistsStore}
      >
        <Router basename={basename}>
          <Layout>
            <AppHeader />

            <Layout className='main-content-wrapper'>
              <Routes/>
            </Layout>

            <div id="dz-player-container" className={playerExpanded ? "expanded" : ""}>
              <span
                id="dz-player-anchor"
                onClick={this.togglePlayerExpanded}
              >
                <Icon type={playerExpanded ? "caret-down" : "caret-up"}/>
              </span>
              <div id="dz-player"></div>
            </div>
          </Layout>
        </Router>

      </Provider>
    );
  }
}

export default observer(App);
