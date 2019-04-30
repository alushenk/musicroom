// @flow
import React from 'react';
import { Icon } from 'antd';

import './TrackLikeButton.styles.scss';

type Props = {
  iconType: string,
  onClick: () => void,
};

export const TrackLikeButton = (props: Props) => (
  <Icon type={props.iconType} onClick={props.onClick} className="action-icon"/>
);

export default TrackLikeButton;

