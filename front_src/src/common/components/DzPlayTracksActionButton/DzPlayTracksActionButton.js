// @flow
import React from 'react';
import { Icon } from 'antd';

import './DzPlayTracksActionButton.styles.scss';
import {noop} from "../../helpers";

const dzPlayerPlayTracks = (ids: number[], startIndex: number = 0) => {
  if (window.DZ !== undefined && window.DZ.player) {
    window.DZ.player.playTracks(ids, startIndex, (tackObjects) => {
      // window.DZ.player.play();
      // console.log('DZ player is playing now: ');
      // console.log(tackObjects);
    });
  } else {
    console.warn('Deezer player is not present on current page. Sorry for inconvenience.');
  }
};

type Props = {
  trackIds: number[],
  startTrackIndex?: number,
  className?: string,
  onClickSideEffect?: () => void,
};

export const DzPlayTracksActionButton = (props: Props) => {
  const {
    trackIds = [],
    startTrackIndex = 0,
    className = '',
    onClickSideEffect = noop,
  } = props;

  return (
    <Icon
      type="play-circle"
      className={`action-icon ${className}`}
      onClick={() => {
        dzPlayerPlayTracks(trackIds, startTrackIndex);
        onClickSideEffect();
      }}
    />
  );
};

export default DzPlayTracksActionButton;
