// @flow
import React, { Component } from 'react';
import { observer, inject } from 'mobx-react';
import { Icon } from 'antd';
import { withRouter } from 'react-router-dom';

import type {SettingsStore} from "../../../stores/settingsStore";

import "./AppHeader.styles.scss";
import {NavLink} from "react-router-dom";
import {localStorageCredentialsPresent} from "../../helpers";

const MENU_ITEMS = [
  {
    title: 'User profile',
    link: '/profile',
    icon: 'message',
  },
  {
    title: 'Playlists',
    link: '/playlists',
    icon: 'link',
  },
  {
    title: 'Authorization',
    link: '/auth',
    icon: 'check',
  },
];

type Props = {
  settingsStore: SettingsStore,
};
type State = {
  menuOpened: boolean,
};

export class AppHeader extends Component<Props, State> {
  state = {
    menuOpened: false,
  };

  toggleMenuOpened = () => {
    this.setState((prevState) => ({ menuOpened: !prevState.menuOpened }));
  };

  render () {
    const { menuOpened } = this.state;
    const { settingsStore, history } = this.props;

    const dynamicProps = menuOpened ? {
      type: 'menu-fold',
      menuClassName: '',
    } : {
      type: 'menu-unfold',
      menuClassName: ' collapsed'
    };

    return (
      <div id="app-header">
        <ul className={`ant-menu ant-menu-dark ant-menu-root ant-menu-inline${dynamicProps.menuClassName}`}>
          <Icon
            type={dynamicProps.type}
            className="main-menu-icon"
            onClick={this.toggleMenuOpened}
          />
          {MENU_ITEMS.map(({ title, link, icon }) => (
            <li key={title} onClick={this.toggleMenuOpened}>
              <NavLink
                to={link}
                className='ant-menu-item'
                activeClassName='ant-menu-item-selected'
                onContextMenu={(e) => e.preventDefault()}
                strict
              >
                <Icon type={icon}/>
                <span>{title}</span>
              </NavLink>
            </li>
          ))}
        </ul>

        <h2>Music Room</h2>

        {localStorageCredentialsPresent() && (
          <div className="app-header-logout-panel">
            Hello, <strong>{settingsStore.currentUser.username}</strong>
            <span
              className="link-like"
              onClick={() => {
                settingsStore.userLogout();
                history.push('/auth');
              }}
            >Logout</span>
          </div>
        )}
      </div>
    );
  }
}

export default inject('settingsStore')(
  observer(withRouter(AppHeader))
);
